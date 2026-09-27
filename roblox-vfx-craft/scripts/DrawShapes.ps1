param([string]$dir = $PSScriptRoot, [int]$seed = 7, [string]$only = "")
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class Tex {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	static void Put(Bitmap bmp, Func<int, int, double> alpha) {
		var d = bmp.LockBits(new Rectangle(0, 0, bmp.Width, bmp.Height), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * bmp.Height];
		for (int y = 0; y < bmp.Height; y++) for (int x = 0; x < bmp.Width; x++) {
			double a = Math.Max(0, Math.Min(1, alpha(x, y)));
			int i = y * d.Stride + x * 4;
			buf[i] = 255; buf[i + 1] = 255; buf[i + 2] = 255; buf[i + 3] = (byte)(a * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
	}
	public static void Wedge(string path, int seed) {
		int W = 128, H = 512;
		var rng = new Random(seed);
		var streak = new double[W];
		double[] k = new double[W];
		for (int i = 0; i < W; i++) k[i] = rng.NextDouble();
		for (int i = 0; i < W; i++) { double s = 0; for (int j = -3; j <= 3; j++) s += k[Math.Max(0, Math.Min(W - 1, i + j))]; streak[i] = s / 7; }
		var bmp = new Bitmap(W, H, PixelFormat.Format32bppArgb);
		Put(bmp, (x, y) => {
			double v = y / (double)(H - 1);
			double half = 0.5 * (0.04 + 0.96 * Math.Pow(v, 0.85));
			double u = (x + 0.5) / W - 0.5;
			double dd = Math.Abs(u) / half;
			double across = Math.Exp(-dd * dd * 2.6);
			double along = Smooth(0.0, 0.6, v) * (1 - 0.55 * Smooth(0.82, 1.0, v));
			double st = 0.62 + 0.76 * (streak[x] - 0.5) + 0.38;
			return across * along * Math.Min(1.0, st);
		});
		bmp.Save(path, ImageFormat.Png);
	}
	public static void Vignette(string path) {
		int S = 256;
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		Put(bmp, (x, y) => {
			double u = (x + 0.5) / S * 2 - 1, v = (y + 0.5) / S * 2 - 1;
			double r = Math.Sqrt(u * u + v * v);
			double t = Math.Max(0, Math.Min(1, (r - 0.28) / 0.9));
			return Math.Pow(t, 1.35) * 0.98;
		});
		for (int y = 0; y < S; y++) for (int x = 0; x < S; x++) { var c = bmp.GetPixel(x, y); bmp.SetPixel(x, y, Color.FromArgb(c.A, 0, 0, 0)); }
		bmp.Save(path, ImageFormat.Png);
	}
	static PointF P(double cx, double cy, double r, double a) { return new PointF((float)(cx + r * Math.Cos(a)), (float)(cy + r * Math.Sin(a))); }
	public static void Crack(string path, int seed) {
		int S = 512; double c = S / 2.0;
		var rng = new Random(seed);
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		using (var g = Graphics.FromImage(bmp)) {
			g.Clear(Color.Transparent);
			g.SmoothingMode = SmoothingMode.AntiAlias;
			var brush = new SolidBrush(Color.White);
			double ang = rng.NextDouble() * Math.PI * 2;
			double total = 0;
			var spans = new List<double[]>();
			while (total < Math.PI * 2 - 0.3) {
				double span = 0.5 + rng.NextDouble() * 0.35;
				double gap = rng.NextDouble() < 0.3 ? 0.2 + rng.NextDouble() * 0.14 : 0.07 + rng.NextDouble() * 0.1;
				if (total + span > Math.PI * 2 - 0.1) span = Math.PI * 2 - 0.1 - total;
				spans.Add(new double[] { ang + total, ang + total + span });
				total += span + gap;
			}
			foreach (var sp in spans) {
				var pts = new List<PointF>();
				double a0 = sp[0], a1 = sp[1];
				int n = 12 + rng.Next(4);
				double rin = 104 + rng.NextDouble() * 12;
				double sp1 = (a1 - a0) / n;
				for (int i = 0; i <= n; i++) {
					double a = a0 + sp1 * i;
					double taper = Math.Sin(Math.PI * i / n);
					double r = rin + 16 * (1 - taper) + rng.NextDouble() * 12 - 6;
					pts.Add(P(c, c, r, a));
					if (i < n && rng.NextDouble() < 0.25) {
						double tip = r - 10 - rng.NextDouble() * 18;
						pts.Add(P(c, c, r, a + sp1 * 0.15));
						pts.Add(P(c, c, tip, a + sp1 * 0.5 + (rng.NextDouble() - 0.5) * sp1 * 0.6));
						pts.Add(P(c, c, r, a + sp1 * 0.85));
					}
				}
				int m = 16 + rng.Next(4);
				double sp2 = (a1 - a0) / m;
				double thick = 48 + rng.NextDouble() * 22;
				for (int i = m; i >= 0; i--) {
					double a = a0 + sp2 * i;
					double taper = Math.Sin(Math.PI * i / m);
					double r = rin + 4 + thick * Math.Pow(Math.Max(0, taper), 0.6) + rng.NextDouble() * 16 - 8;
					pts.Add(P(c, c, r, a));
					if (i > 0 && rng.NextDouble() < 0.3) {
						double tip = r + 8 + rng.NextDouble() * 20 * (0.5 + taper);
						double skew = (rng.NextDouble() - 0.5) * sp2 * 1.4;
						pts.Add(P(c, c, r - 4, a - sp2 * 0.02));
						pts.Add(P(c, c, tip, a - sp2 * 0.5 + skew));
						pts.Add(P(c, c, r - 4, a - sp2 * 0.98));
					}
				}
				g.FillPolygon(brush, pts.ToArray());
			}
			for (int s = 0; s < 4; s++) {
				double a = rng.NextDouble() * Math.PI * 2;
				double r = 178 + rng.NextDouble() * 30;
				double len = 14 + rng.NextDouble() * 20;
				double w = 0.04 + rng.NextDouble() * 0.03;
				g.FillPolygon(brush, new PointF[] { P(c, c, r, a - w), P(c, c, r + len, a + (rng.NextDouble() - 0.5) * 0.05), P(c, c, r, a + w), P(c, c, r - 6, a) });
			}
		}
		bmp.Save(path, ImageFormat.Png);
	}
}
"@
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class Crack2 {
	static PointF P(double c, double r, double a) { return new PointF((float)(c + r * Math.Cos(a)), (float)(c + r * Math.Sin(a))); }
	public static void Draw(string path, int seed) {
		int S = 512; double c = S / 2.0;
		var rng = new Random(seed);
		double p1 = rng.NextDouble() * 6.3, p2 = rng.NextDouble() * 6.3, p3 = rng.NextDouble() * 6.3;
		Func<double, double> thickF = a => 0.55 + 0.45 * Math.Sin(a + p1) + 0.25 * Math.Sin(2 * a + p2);
		Func<double, double> radF = a => 1 + 0.12 * Math.Sin(a + p3) + 0.06 * Math.Sin(3 * a + p2);
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		using (var g = Graphics.FromImage(bmp)) {
			g.Clear(Color.Transparent);
			g.SmoothingMode = SmoothingMode.AntiAlias;
			var brush = new SolidBrush(Color.White);
			double rin = 98;
			double ang = rng.NextDouble() * Math.PI * 2, total = 0;
			var tips = new List<double[]>();
			while (total < Math.PI * 2 - 0.2) {
				double span = 0.25 + rng.NextDouble() * 1.05;
				double gap = rng.NextDouble() < 0.25 ? 0.25 + rng.NextDouble() * 0.25 : 0.04 + rng.NextDouble() * 0.12;
				if (total + span > Math.PI * 2 - 0.05) span = Math.PI * 2 - 0.05 - total;
				double a0 = ang + total, a1 = a0 + span;
				total += span + gap;
				double mid = (a0 + a1) / 2;
				double tf = thickF(mid);
				if (tf < 0.12) continue;
				double thick = 18 + 46 * Math.Min(1.2, tf) + rng.NextDouble() * 12;
				var pts = new List<PointF>();
				int n = Math.Max(6, (int)(span * 18));
				double s1 = span / n;
				for (int i = 0; i <= n; i++) {
					double a = a0 + s1 * i;
					double r = rin * radF(a) + rng.NextDouble() * 14 - 7;
					pts.Add(P(c, r, a));
					if (i < n && rng.NextDouble() < 0.2) {
						pts.Add(P(c, r, a + s1 * 0.2));
						pts.Add(P(c, r - 8 - rng.NextDouble() * 16, a + s1 * 0.5));
						pts.Add(P(c, r, a + s1 * 0.8));
					}
				}
				int m = Math.Max(8, (int)(span * 22));
				double s2 = span / m;
				for (int i = m; i >= 0; i--) {
					double a = a0 + s2 * i;
					double taper = Math.Pow(Math.Max(0, Math.Sin(Math.PI * i / m)), 0.55);
					double r = rin * radF(a) + 3 + thick * taper * (0.65 + 0.7 * rng.NextDouble());
					pts.Add(P(c, r, a));
					if (i > 0 && rng.NextDouble() < 0.35) {
						double len = rng.NextDouble() < 0.15 ? 28 + rng.NextDouble() * 26 : 6 + rng.NextDouble() * 18;
						double skew = (rng.NextDouble() - 0.5) * s2 * 3;
						pts.Add(P(c, r - 3, a - s2 * 0.05));
						pts.Add(P(c, r + len, a - s2 * 0.5 + skew));
						pts.Add(P(c, r - 3, a - s2 * 0.95));
						if (len > 28) tips.Add(new double[] { r + len, a - s2 * 0.5 + skew });
					}
				}
				g.FillPolygon(brush, pts.ToArray());
			}
			int strokes = Math.Min(4, tips.Count);
			for (int k = 0; k < strokes; k++) {
				var t = tips[rng.Next(tips.Count)];
				double r = t[0] - 4, a = t[1];
				float w = 5f;
				for (int seg = 0; seg < 4; seg++) {
					double r2 = r + 8 + rng.NextDouble() * 12;
					double a2 = a + (rng.NextDouble() - 0.5) * 0.18;
					using (var pen = new Pen(Color.White, w)) { pen.StartCap = LineCap.Round; pen.EndCap = LineCap.Triangle; g.DrawLine(pen, P(c, r, a), P(c, r2, a2)); }
					r = r2; a = a2; w *= 0.7f;
				}
			}
			for (int s = 0; s < 4; s++) {
				double a = rng.NextDouble() * Math.PI * 2;
				double r = rin * radF(a) + 60 + rng.NextDouble() * 40;
				double len = 8 + rng.NextDouble() * 16;
				double w = 0.03 + rng.NextDouble() * 0.04;
				g.FillPolygon(brush, new PointF[] { P(c, r, a - w), P(c, r + len, a + (rng.NextDouble() - 0.5) * 0.08), P(c, r + 2, a + w * 1.4), P(c, r - 5, a + w * 0.3) });
			}
		}
		bmp.Save(path, ImageFormat.Png);
	}
}
public static class Spire {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	public static void Draw(string path, int seed) {
		int W = 128, H = 512;
		var rng = new Random(seed);
		int N = 24;
		var ux = new double[N]; var sg = new double[N]; var vs = new double[N]; var iv = new double[N];
		for (int i = 0; i < N; i++) {
			ux[i] = (rng.NextDouble() * 2 - 1) * 0.9;
			sg[i] = 0.01 + rng.NextDouble() * 0.028;
			vs[i] = rng.NextDouble() * 0.55 * (0.3 + Math.Abs(ux[i]));
			iv[i] = 0.2 + rng.NextDouble() * 0.5;
		}
		var bmp = new Bitmap(W, H, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			double v = y / (double)(H - 1);
			double hw = 0.02 + 0.46 * Math.Pow(v, 0.85);
			double u = (x + 0.5) / W - 0.5;
			double a = 0;
			for (int i = 0; i < N; i++) {
				double dx = (u - ux[i] * hw) / (sg[i] * (0.35 + 0.65 * v) + 0.004);
				a += iv[i] * Math.Exp(-dx * dx) * Smooth(vs[i], vs[i] + 0.1, v);
			}
			double cx = u / (0.006 + 0.03 * v);
			a += Math.Exp(-cx * cx);
			double edge = Math.Exp(-Math.Pow(Math.Abs(u) / hw, 6));
			a = (1 - Math.Exp(-a * 1.5)) * edge * (1 - 0.35 * Smooth(0.9, 1.0, v));
			int k = y * d.Stride + x * 4;
			buf[k] = 255; buf[k + 1] = 255; buf[k + 2] = 255; buf[k + 3] = (byte)(Math.Max(0, Math.Min(1, a)) * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
		bmp.Save(path, ImageFormat.Png);
	}
}
"@
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class Wedge2 {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	public static void Draw(string path, int seed) {
		int S = 256;
		var rng = new Random(seed);
		var k = new double[S]; for (int i = 0; i < S; i++) k[i] = rng.NextDouble();
		var st = new double[S]; for (int i = 0; i < S; i++) { double s = 0; for (int j = -4; j <= 4; j++) s += k[Math.Max(0, Math.Min(S - 1, i + j))]; st[i] = s / 9; }
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, S, S), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * S];
		for (int y = 0; y < S; y++) for (int x = 0; x < S; x++) {
			double v = (y + 0.5) / S, u = (x + 0.5) / S - 0.5;
			double s = Math.Max(0, Math.Min(1, (v - 0.04) / 0.92));
			double half = 0.015 + 0.2 * Math.Pow(s, 0.8);
			double dd = u / half;
			double across = Math.Exp(-dd * dd * 2.2);
			double along = Smooth(0, 0.5, s) * (1 - Smooth(0.72, 1.0, s));
			double streak = 0.7 + 0.6 * (st[x] - 0.5) * 2;
			double a = Math.Max(0, Math.Min(1, across * along * Math.Min(1, streak)));
			int i = y * d.Stride + x * 4;
			buf[i] = 255; buf[i + 1] = 255; buf[i + 2] = 255; buf[i + 3] = (byte)(a * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
		bmp.Save(path, ImageFormat.Png);
	}
}
"@
if ($only -eq "wedge2") { [Wedge2]::Draw((Join-Path $dir "wedge2.png"), $seed); "wedge2 done"; exit }
if ($only -eq "crack2") { [Crack2]::Draw((Join-Path $dir ("crack2_" + $seed + ".png")), $seed); "crack2 $seed"; exit }
if ($only -eq "spire") { [Spire]::Draw((Join-Path $dir "spire.png"), $seed); "spire done"; exit }
[Tex]::Wedge((Join-Path $dir "wedge.png"), $seed)
[Tex]::Vignette((Join-Path $dir "vignette.png"))
[Tex]::Crack((Join-Path $dir "crack.png"), $seed)
Get-ChildItem $dir -Filter *.png | ForEach-Object { "$($_.Name) $($_.Length)" }








