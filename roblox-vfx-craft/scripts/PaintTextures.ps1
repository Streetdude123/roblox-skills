param([string]$only = "all", [int]$seed = 4)
$dir = $PSScriptRoot
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;

public class Canvas {
	public int W, H;
	public double[] R, G, B, A;
	public Canvas(int w, int h) { W = w; H = h; R = new double[w * h]; G = new double[w * h]; B = new double[w * h]; A = new double[w * h]; }
	public void Screen(int i, double r, double g, double b, double a) {
		if (a <= 0) return;
		double na = 1 - (1 - A[i]) * (1 - a);
		double k = na > 0 ? a / na : 0;
		R[i] = R[i] * (1 - k) + r * k; G[i] = G[i] * (1 - k) + g * k; B[i] = B[i] * (1 - k) + b * k;
		A[i] = na;
	}
	public void CutBelow(double cy, double soft) {
		for (int y = 0; y < H; y++) {
			double t = Math.Max(0, Math.Min(1, (y - (cy - soft * 0.2)) / (soft * 1.2)));
			double k = 1 - t * t * (3 - 2 * t);
			for (int x = 0; x < W; x++) A[y * W + x] *= k;
		}
	}
	public void ZoomBlur(double cx, double cy, double amount, int taps) {
		var r2 = new double[W * H]; var g2 = new double[W * H]; var b2 = new double[W * H]; var a2 = new double[W * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			double sr = 0, sg = 0, sb = 0, sa = 0;
			for (int t = 0; t < taps; t++) {
				double f = 1 - amount * t / (taps - 1);
				int px = (int)Math.Round(cx + (x - cx) * f), py = (int)Math.Round(cy + (y - cy) * f);
				if (px < 0 || py < 0 || px >= W || py >= H) continue;
				int j = py * W + px;
				sr += R[j] * A[j]; sg += G[j] * A[j]; sb += B[j] * A[j]; sa += A[j];
			}
			int i = y * W + x;
			a2[i] = sa / taps;
			if (sa > 0) { r2[i] = sr / sa; g2[i] = sg / sa; b2[i] = sb / sa; }
		}
		R = r2; G = g2; B = b2; A = a2;
	}
	public void Save(string path) {
		var bmp = new Bitmap(W, H, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			int i = y * W + x, k = y * d.Stride + x * 4;
			buf[k] = C(B[i]); buf[k + 1] = C(G[i]); buf[k + 2] = C(R[i]); buf[k + 3] = C(A[i]);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
		bmp.Save(path, ImageFormat.Png);
	}
	static byte C(double v) { return (byte)Math.Max(0, Math.Min(255, Math.Round(v * 255))); }
}

public static class Paint {
	public static double taperExp = 0.85, bodyK = 1.3, blur = 0.34, centerGlow = 0.9; public static bool hard = false;
	public static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	static double Lerp(double a, double b, double t) { return a + (b - a) * t; }
	static double[] Ramp(double[][] stops, double t) {
		for (int i = 1; i < stops.Length; i++) if (t <= stops[i][0] || i == stops.Length - 1) {
			double u = Math.Max(0, Math.Min(1, (t - stops[i - 1][0]) / (stops[i][0] - stops[i - 1][0])));
			return new double[] { Lerp(stops[i - 1][1], stops[i][1], u), Lerp(stops[i - 1][2], stops[i][2], u), Lerp(stops[i - 1][3], stops[i][3], u) };
		}
		return new double[] { 1, 1, 1 };
	}
	static readonly double[][] Pink = {
		new double[] { 0.00, 1.00, 0.86, 0.93 },
		new double[] { 0.20, 1.00, 0.50, 0.72 },
		new double[] { 0.55, 1.00, 0.34, 0.54 },
		new double[] { 1.00, 1.00, 0.48, 0.40 },
	};
	static readonly double[][] Salmon = {
		new double[] { 0.00, 1.00, 0.84, 0.90 },
		new double[] { 0.30, 1.00, 0.45, 0.58 },
		new double[] { 0.65, 1.00, 0.42, 0.40 },
		new double[] { 1.00, 1.00, 0.60, 0.34 },
	};

	static readonly double[][] Coral = {
		new double[] { 0.00, 1.00, 0.86, 0.88 },
		new double[] { 0.30, 1.00, 0.58, 0.62 },
		new double[] { 0.70, 1.00, 0.47, 0.45 },
		new double[] { 1.00, 1.00, 0.58, 0.36 },
	};
	public static bool useRef = false;
	static readonly double[][] RefRamp = {
		new double[] { 0.00, 0.93, 0.38, 0.74 },
		new double[] { 0.35, 0.98, 0.40, 0.68 },
		new double[] { 0.65, 1.00, 0.47, 0.58 },
		new double[] { 1.00, 0.96, 0.46, 0.46 },
	};
	static void Wedge(Canvas c, double cx, double cy, double ang, double len, double baseHalf, double inner, double gain, double[][] ramp, double[] streaks) {
		double ca = Math.Cos(ang), sa = Math.Sin(ang);
		int x0 = (int)Math.Max(0, cx - len - 4), x1 = (int)Math.Min(c.W - 1, cx + len + 4);
		int y0 = (int)Math.Max(0, cy - len - 4), y1 = (int)Math.Min(c.H - 1, cy + len + 4);
		var br = new Random((int)(ang * 10007 + len * 131));
		double tint = 0.9 + br.NextDouble() * 0.2, tint2 = 0.88 + br.NextDouble() * 0.24;
		int K = 5 + br.Next(4);
		var kp = new double[K]; var kw = new double[K]; var kl = new double[K]; var ki = new double[K];
		for (int k = 0; k < K; k++) { kp[k] = -0.85 + 1.7 * (k + br.NextDouble() * 0.8) / K; kw[k] = 0.14 + br.NextDouble() * 0.18; kl[k] = 0.5 + 0.5 * Math.Pow(br.NextDouble(), 0.6) * (1 - 0.35 * Math.Abs(kp[k])); ki[k] = 0.55 + br.NextDouble() * 0.45; }
		for (int y = y0; y <= y1; y++) for (int x = x0; x <= x1; x++) {
			double dx = x - cx, dy = y - cy;
			double along = dx * ca + dy * sa;
			if (along <= 0 || along >= len) continue;
			double side = -dx * sa + dy * ca;
			double t = along / len;
			double hw = baseHalf * Math.Pow(1 - t, taperExp) + 0.6;
			double q = side / hw;
			double body;
			if (hard) {
				double env = (1 - Smooth(hw - 1.4, hw + 0.6, Math.Abs(side)));
				double bundle = 0;
				for (int k = 0; k < K; k++) {
					double tk = t / kl[k];
					if (tk >= 1) continue;
					double hk = kw[k] * hw * Math.Pow(1 - tk, 0.6) + 0.5;
					double dk = Math.Abs(side - kp[k] * hw * (1 - 0.3 * tk));
					bundle = Math.Max(bundle, ki[k] * (1 - Smooth(hk - 1.0, hk + 0.6, dk)));
				}
				body = Math.Max(bundle, env * 0.7 * (1 - Smooth(0.5, 0.85, t)));
			} else body = Math.Exp(-q * q * bodyK);
			double fadeIn = Smooth(inner * 0.4, inner, along);
			int si = (int)((q * 0.5 + 0.5) * (streaks.Length - 1));
			double st = (si >= 0 && si < streaks.Length) ? streaks[si] : 1;
			if (hard) st = 0.5 + 0.5 * Math.Max(0, Math.Min(1, (st - 0.72) / 0.28));
			double tipSoft = 1 - Smooth(0.86, 1.0, t) * 0.7;
			double a = body * fadeIn * tipSoft * gain * st;
			var col = Ramp(useRef ? RefRamp : ramp, t);
			if (useRef) { col[1] *= tint; col[2] *= tint2; }
			c.Screen(y * c.W + x, col[0], col[1], col[2], Math.Min(1, a));
		}
	}

	static double[] Streaks(Random rng, int n) {
		var raw = new double[n];
		for (int i = 0; i < n; i++) raw[i] = rng.NextDouble();
		var s = new double[n];
		for (int i = 0; i < n; i++) { double v = 0; for (int j = -2; j <= 2; j++) v += raw[Math.Max(0, Math.Min(n - 1, i + j))]; s[i] = 0.72 + 0.28 * (v / 5); }
		return s;
	}

	public static void Crown(string path, int seed) {
		int S = 1024; double cx = S / 2.0, cy = S / 2.0, R = S * 0.4;
		var rng = new Random(seed);
		var c = new Canvas(S, S);
		for (int y = 0; y < S; y++) for (int x = 0; x < S; x++) {
			double dx = (x - cx) / R, dy = (y - cy) / R;
			double r = Math.Sqrt(dx * dx + dy * dy * (dy > 0 ? 2.2 : 1.1));
			double g = Math.Exp(-r * r / 0.035) * 0.95;
			c.Screen(y * S + x, 1.0, 0.32 + 0.58 * Math.Exp(-r * r / 0.006), 0.62 + 0.32 * Math.Exp(-r * r / 0.006), g);
		}
		int N = 32;
		for (int i = 0; i < N; i++) {
			double ang;
			if (rng.NextDouble() < 0.72) ang = -Math.PI * (0.02 + rng.NextDouble() * 0.96);
			else ang = Math.PI * (0.08 + rng.NextDouble() * 0.84);
			double up = Math.Max(0, -Math.Sin(ang));
			double sideW = Math.Abs(Math.Cos(ang));
			double down = Math.Max(0, Math.Sin(ang));
			double len = R * (0.58 + 0.34 * rng.NextDouble()) * (0.72 + 0.28 * Math.Max(up, sideW)) * (1 - 0.42 * down);
			double half = S * (0.05 + rng.NextDouble() * 0.05);
			var ramp = rng.NextDouble() < 0.45 ? Salmon : Pink;
			Wedge(c, cx, cy, ang, len, half, R * 0.02, 0.6 + rng.NextDouble() * 0.35, ramp, Streaks(rng, 24));
		}
		c.ZoomBlur(cx, cy, hard ? 0.07 : 0.34, 30);
		c.Save(path);
	}

	public static void Upper(string path, int seed) {
		int S = 1024; double cx = S / 2.0, cy = S / 2.0, R = S * 0.4;
		var rng = new Random(seed);
		var c = new Canvas(S, S);
		for (int y = 0; y < S; y++) for (int x = 0; x < S; x++) {
			double dx = (x - cx) / R, dy = (y - cy) / R;
			double r = Math.Sqrt(dx * dx + dy * dy * 1.1);
			double g = Math.Exp(-r * r / 0.035) * centerGlow;
			c.Screen(y * S + x, 1.0, 0.32 + 0.58 * Math.Exp(-r * r / 0.006), 0.62 + 0.32 * Math.Exp(-r * r / 0.006), g);
		}
		int N = hard ? 13 : 30;
		for (int i = 0; i < N; i++) {
			double ang = -Math.PI * (-0.06 + rng.NextDouble() * 1.12);
			double up = Math.Max(0, -Math.Sin(ang));
			double sideW = Math.Abs(Math.Cos(ang));
			double len = R * (0.58 + 0.36 * rng.NextDouble()) * (0.74 + 0.26 * Math.Max(up, sideW));
			double half = hard ? S * (0.05 + rng.NextDouble() * 0.035) : S * (0.05 + rng.NextDouble() * 0.05);
			var ramp = hard ? (rng.NextDouble() < 0.6 ? Coral : Pink) : (rng.NextDouble() < 0.45 ? Salmon : Pink);
			Wedge(c, cx, cy + R * 0.03, ang, len, half, hard ? R * 0.1 : R * 0.02, hard ? 0.9 + rng.NextDouble() * 0.1 : 0.6 + rng.NextDouble() * 0.35, ramp, Streaks(rng, 24));
		}
		c.ZoomBlur(cx, cy, blur, 30);
		c.CutBelow(cy + R * 0.06, R * 0.14);
		c.Save(path);
	}

	static readonly double[][] Fire = {
		new double[] { 0.00, 1.00, 0.95, 0.99 },
		new double[] { 0.18, 1.00, 0.82, 0.93 },
		new double[] { 0.65, 1.00, 0.55, 0.80 },
		new double[] { 1.00, 1.00, 0.35, 0.66 },
	};
	static void Tongue(Canvas c, int ox, int oy, int cell, double bx, double by, double ang, double len, double w0, double bend, Random rng, double gain) {
		int K = 48;
		var jag = new double[K + 1];
		for (int i = 0; i <= K; i++) jag[i] = rng.NextDouble() * 2 - 1;
		double ca = Math.Cos(ang), sa = Math.Sin(ang);
		int x0 = (int)Math.Max(ox, bx - len - w0 * 2), x1 = (int)Math.Min(ox + cell - 1, bx + len + w0 * 2);
		int y0 = (int)Math.Max(oy, by - len - w0 * 2), y1 = (int)Math.Min(oy + cell - 1, by + len + w0 * 2);
		for (int y = y0; y <= y1; y++) for (int x = x0; x <= x1; x++) {
			double dx = x - bx, dy = y - by;
			double along = dx * ca + dy * sa;
			if (along < -w0 || along > len) continue;
			double t = Math.Max(0, along / len);
			double side = -dx * sa + dy * ca - bend * t * t * len;
			int k = (int)(t * K);
			double j = 1 + 0.45 * (jag[Math.Min(K, k)] * (1 - (t * K - k)) + jag[Math.Min(K, k + 1)] * (t * K - k));
			double hw = w0 * Math.Pow(1 - t, 0.75) * j + 0.8;
			double q = side / hw;
			double body = hard ? (1 - Smooth(hw - 1.3, hw + 0.6, Math.Abs(side))) : Math.Exp(-q * q * 1.6);
			double a = body * gain * (1 - Smooth(0.82, 1.0, t)) * Smooth(-1.0, 0.05, t);
			var col = Ramp(Fire, t);
			c.Screen(y * c.W + x, col[0], col[1], col[2], Math.Min(1, a));
		}
	}
	public static void InnerFire(string path, int seed) {
		int cell = 512, S = cell * 2;
		var rng = new Random(seed);
		var c = new Canvas(S, S);
		for (int f = 0; f < 4; f++) {
			int ox = (f % 2) * cell, oy = (f / 2) * cell;
			double bx = ox + cell * 0.5 + (rng.NextDouble() - 0.5) * 12, by = oy + cell * 0.56;
			int N0 = hard ? 16 + rng.Next(6) : 0;
			double R = cell * 0.42;
			int N = hard ? N0 : 12 + rng.Next(6);
			for (int i = 0; i < N; i++) {
				double g = 0; for (int k = 0; k < 3; k++) g += rng.NextDouble() - 0.5;
				double ang = -Math.PI / 2 + g * 1.5 + (rng.NextDouble() < 0.2 ? (rng.NextDouble() - 0.5) * 2.4 : 0);
				double down = Math.Max(0, Math.Sin(ang));
				double len = R * (0.18 + 0.82 * Math.Pow(rng.NextDouble(), 0.8)) * (1 - 0.75 * down);
				double w0 = cell * (hard ? 0.012 + rng.NextDouble() * 0.022 : 0.02 + rng.NextDouble() * 0.035);
				double bend = (rng.NextDouble() - 0.5) * 0.35;
				Tongue(c, ox, oy, cell, bx, by, ang, len, w0, bend, rng, 0.75 + rng.NextDouble() * 0.25);
			}
			for (int i = 0; i < (hard ? 0 : 5); i++) {
				double ang = -Math.PI / 2 + (rng.NextDouble() - 0.5) * 0.5;
				Tongue(c, ox, oy, cell, bx + (rng.NextDouble() - 0.5) * 20, by + 6, ang, R * (0.35 + rng.NextDouble() * 0.4), cell * 0.05, (rng.NextDouble() - 0.5) * 0.3, rng, 1.0);
			}
		}
		for (int f = 0; f < 4; f++) {
			int ox = (f % 2) * cell, oy = (f / 2) * cell;
			for (int y = oy; y < oy + cell; y++) {
				double v = (y - oy) / (double)cell;
				double k = 1 - Smooth(0.6, 0.78, v);
				for (int x = ox; x < ox + cell; x++) c.A[y * S + x] *= k;
			}
		}
		c.Save(path);
	}

	public static void Single(string path, int seed) {
		int S = 512; double cx = S / 2.0, cy = S * 0.97;
		var rng = new Random(seed);
		var c = new Canvas(S, S);
		Wedge(c, cx, cy, -Math.PI / 2, S * 0.93, S * 0.13, S * 0.12, 0.95, Pink, Streaks(rng, 24));
		c.ZoomBlur(cx, cy, hard ? 0.04 : 0.1, 10);
		c.Save(path);
	}

	public static void Ember(string path) {
		int S = 256; double cx = S / 2.0;
		var c = new Canvas(S, S);
		for (int y = 0; y < S; y++) for (int x = 0; x < S; x++) {
			double v = (y + 0.5) / S;
			double t = Math.Max(0, Math.Min(1, (v - 0.04) / 0.9));
			double taper = Math.Pow(Math.Sin(Math.PI * Math.Pow(t, 0.7)), 0.8);
			double u = (x + 0.5 - cx) / S;
			double cw = 0.006 + 0.012 * taper;
			double core = hard ? (1 - Smooth(cw * 0.7, cw * 1.15, Math.Abs(u))) * Smooth(0, 0.08, taper) : Math.Exp(-Math.Pow(u / cw, 2)) * taper;
			double halo = hard ? (1 - Smooth(cw * 1.1, cw * 2.2, Math.Abs(u))) * taper * 0.9 : Math.Exp(-Math.Pow(u / (0.02 + 0.03 * taper), 2)) * taper * 0.75;
			int i = y * S + x;
			c.Screen(i, 1.0, 0.52, 0.12, halo);
			c.Screen(i, 1.0, 0.96, 0.78, core);
		}
		c.Save(path);
	}
}
"@
if ($only -eq "upper") { [Paint]::Upper((Join-Path $dir "crown_up.png"), $seed); "upper"; exit }
if ($only -eq "fire") { [Paint]::InnerFire((Join-Path $dir "innerfire.png"), $seed); "fire"; exit }
if ($only -eq "upper3") { [Paint]::taperExp = 1.05; [Paint]::bodyK = 2.0; [Paint]::blur = 0.2; [Paint]::centerGlow = 0.3; [Paint]::Upper((Join-Path $dir "crown_up3.png"), $seed); "upper3"; exit }
if ($only -eq "refset") {
  [Paint]::hard = $true; [Paint]::useRef = $true; [Paint]::taperExp = 1.0; [Paint]::centerGlow = 0.0; [Paint]::blur = 0.05
  [Paint]::Upper((Join-Path $dir "crown_up5.png"), $seed)
  [Paint]::Crown((Join-Path $dir "crown5.png"), $seed)
  [Paint]::Single((Join-Path $dir "wedgec3.png"), $seed)
  "refset"; exit }
if ($only -eq "hardset") {
  [Paint]::hard = $true; [Paint]::taperExp = 1.0; [Paint]::centerGlow = 0.08; [Paint]::blur = 0.05
  [Paint]::Upper((Join-Path $dir "crown_up4.png"), $seed)
  [Paint]::centerGlow = 0.3; [Paint]::Crown((Join-Path $dir "crown4.png"), $seed)
  [Paint]::Single((Join-Path $dir "wedgec2.png"), $seed)
  [Paint]::Ember((Join-Path $dir "ember2.png"))
  [Paint]::InnerFire((Join-Path $dir "innerfire2.png"), 12)
  "hardset"; exit }
if ($only -eq "upper2") { [Paint]::taperExp = 1.05; [Paint]::bodyK = 2.0; [Paint]::blur = 0.2; [Paint]::Upper((Join-Path $dir "crown_up2.png"), $seed); "upper2"; exit }
if ($only -eq "all" -or $only -eq "crown") { [Paint]::Crown((Join-Path $dir "crown.png"), $seed); "crown" }
if ($only -eq "all" -or $only -eq "single") { [Paint]::Single((Join-Path $dir "wedgec.png"), $seed); "wedgec" }
if ($only -eq "all" -or $only -eq "ember") { [Paint]::Ember((Join-Path $dir "ember.png")); "ember" }









