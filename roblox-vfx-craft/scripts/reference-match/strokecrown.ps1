param([double]$k = 0.502, [double]$baseTy = 547, [string]$name = "strokecrown.png", [double]$step = 1.5, [double]$w0 = 1.6, [double]$occT = 0.45, [double]$tipExp = 0.9, [int]$seed = 7, [double]$fillTo = 0.55, [double]$hazeA = 0.55)
$dir = $PSScriptRoot
$sp = Split-Path $dir
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class StrokeCrown {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	public static double fillTo = 0.55, hazeA = 0.55;
	public static string Paint(Bitmap reff, string path, double[,,] cmap, double k, double baseTy, double step, double w0, double occT, double tipExp, int seed) {
		int bx = 647, by = 482, RW = reff.Width, RH = reff.Height, rp = 4, rn = 60;
		var d = reff.LockBits(new Rectangle(0, 0, RW, RH), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * RH]; System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length); int rs = d.Stride; reff.UnlockBits(d);
		int na = (int)Math.Round(360 / step);
		var hit = new double[na, rn]; var cnt = new double[na, rn];
		for (int y = 0; y < RH; y++) for (int x = 0; x < RW; x++) {
			double dx = x - bx, dy = y - by; double r = Math.Sqrt(dx * dx + dy * dy); int ri = (int)(r / rp); if (ri >= rn) continue;
			double a = Math.Atan2(dy, dx) * 180 / Math.PI; if (a < 0) a += 360; int ai = (int)(a / step) % na;
			int i = y * rs + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			bool p = orange || (R > 95 && R - G > 40);
			cnt[ai, ri] += 1; if (p) hit[ai, ri] += 1;
		}
		var tip = new double[na];
		for (int s = 0; s < na; s++) {
			double t = 0;
			for (int r = 0; r < rn; r++) if (cnt[s, r] > 0 && hit[s, r] / cnt[s, r] >= occT) t = (r + 1) * rp;
			tip[s] = t;
		}
		for (int s = 0; s < na; s++) {
			double ac = s * step + step / 2;
			if (ac > 245 && ac < 295) { double m = 0; for (int j = -3; j <= 3; j++) m = Math.Max(m, 0); }
		}
		var rng = new Random(seed);
		var gain = new double[na]; var jitter = new double[na];
		for (int s = 0; s < na; s++) { gain[s] = 0.8 + rng.NextDouble() * 0.3; jitter[s] = (rng.NextDouble() - 0.5) * step * 0.5; }
		int S = 1024;
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		var o = bmp.LockBits(new Rectangle(0, 0, S, S), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var ob = new byte[o.Stride * S];
		int csec = cmap.GetLength(0), crn = cmap.GetLength(1);
		for (int ty = 0; ty < S; ty++) for (int tx = 0; tx < S; tx++) {
			double dx = (tx + 0.5 - 512) * k, dy = (ty + 0.5 - baseTy) * k;
			double r = Math.Sqrt(dx * dx + dy * dy);
			double a = Math.Atan2(dy, dx) * 180 / Math.PI; if (a < 0) a += 360;
			int s0 = (int)(a / step);
			double best = 0, bg = 1, bt = 0;
			for (int j = -3; j <= 3; j++) {
				int s = ((s0 + j) % na + na) % na;
				double T = tip[s]; if (T < 6) continue;
				double ca = s * step + step / 2 + jitter[s];
				double da = a - ca; if (da > 180) da -= 360; if (da < -180) da += 360;
				double arc = Math.Abs(da) * Math.PI / 180 * Math.Max(r, 1);
				double t = r / T; if (t >= 1) continue;
				double wBase = w0 * step * Math.PI / 180 * Math.Max(r, 1);
				double w = wBase * Math.Pow(1 - t, tipExp) + 0.35;
				double v = 1 - Smooth(w - 0.9, w + 0.5, arc);
				v *= 1 - 0.3 * Smooth(0.75, 1.0, t);
				if (v > best) { best = v; bg = gain[s]; bt = t; }
			}
			double env = 0;
			for (int j = -2; j <= 2; j++) env = Math.Max(env, tip[((s0 + j) % na + na) % na]);
			double fill = env > 6 ? 1 - Smooth(fillTo - 0.1, fillTo + 0.05, r / env) : 0;
			if (fill > best) { best = fill; bt = Math.Min(bt, r / Math.Max(1, env)); if (best == fill) bt = r / Math.Max(1, env); }
			double op = r / rp - 0.5; int o0 = Math.Max(0, Math.Min(rn - 1, (int)Math.Floor(op))); int o1 = Math.Min(rn - 1, o0 + 1); double fo = Math.Max(0, Math.Min(1, op - o0));
			double ap = a / step - 0.5; int q0 = (((int)Math.Floor(ap)) % na + na) % na, q1 = (q0 + 1) % na; double fq = ap - Math.Floor(ap);
			Func<int, int, double> oc = (qa, qr) => cnt[qa, qr] > 0 ? hit[qa, qr] / cnt[qa, qr] : 0;
			double ov = (oc(q0, o0) * (1 - fq) + oc(q1, o0) * fq) * (1 - fo) + (oc(q0, o1) * (1 - fq) + oc(q1, o1) * fq) * fo;
			double haze = hazeA * Smooth(0.4, 0.7, ov);
			bool hazeWins = haze > best;
			if (hazeWins) best = haze;
			double alpha = best * Smooth(-2, 6, r);
			if (Math.Abs(dx) < 27 && dy < -2) alpha *= Smooth(20, 27, Math.Abs(dx));
			double sPos = a / (360.0 / csec) - 0.5; int c0 = (int)Math.Floor(sPos); double fs = sPos - c0;
			double rP = r / 10 - 0.5; int r0 = Math.Max(0, Math.Min(crn - 1, (int)Math.Floor(rP))); int r1 = Math.Min(crn - 1, r0 + 1); double fr = Math.Max(0, Math.Min(1, rP - r0));
			double[] col = new double[3]; double wsum = 0;
			for (int si = 0; si < 2; si++) for (int ri = 0; ri < 2; ri++) {
				int ss = ((c0 + si) % csec + csec) % csec, rr = ri == 0 ? r0 : r1;
				int rq = rr; while (rq >= 0 && cmap[ss, rq, 0] < 0) rq--;
				if (rq < 0) { rq = rr; while (rq < crn && cmap[ss, rq, 0] < 0) rq++; }
				if (rq < 0 || rq >= crn) continue;
				double wgt = (si == 0 ? 1 - fs : fs) * (ri == 0 ? 1 - fr : fr);
				for (int c = 0; c < 3; c++) col[c] += cmap[ss, rq, c] * wgt; wsum += wgt;
			}
			if (wsum > 0) for (int c = 0; c < 3; c++) col[c] /= wsum;
			double[] tipCol;
			if (bt < 0.78) { double u = Smooth(0.55, 0.78, bt); tipCol = new double[] { 1.0, 0.565 - 0.047 * u, 0.64 - 0.08 * u }; }
			else { double u = Smooth(0.78, 1.0, bt); tipCol = new double[] { 1.0 - 0.12 * u, 0.518 - 0.18 * u, 0.56 - 0.2 * u }; }
			double mixT = hazeWins ? 0 : Smooth(0.35, 0.6, bt);
			if (hazeWins) { double u2 = Math.Min(1, r / Math.Max(1, env)); bt = u2; }
			int kk = ty * o.Stride + tx * 4;
			for (int c = 0; c < 3; c++) { double v = (col[c] * (1 - mixT) + tipCol[c] * mixT) * bg; ob[kk + 2 - c] = (byte)Math.Max(0, Math.Min(255, v * 255)); }
			ob[kk + 3] = (byte)(Math.Max(0, Math.Min(1, alpha)) * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(ob, 0, o.Scan0, ob.Length);
		bmp.UnlockBits(o);
		bmp.Save(path, ImageFormat.Png);
		return "strokes " + na;
	}
}
"@
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$cmLines = Get-Content "$sp\ref_colormap.txt"
$cm = New-Object 'double[,,]' $cmLines.Count, 24, 3
for ($q = 0; $q -lt $cmLines.Count; $q++) { $cells = $cmLines[$q] -split ";"; for ($ring = 0; $ring -lt 24; $ring++) { $v = $cells[$ring] -split ","; for ($c = 0; $c -lt 3; $c++) { $cm[$q, $ring, $c] = [double]$v[$c] } } }
[StrokeCrown]::fillTo = $fillTo
[StrokeCrown]::hazeA = $hazeA
[StrokeCrown]::Paint($ref, (Join-Path $dir $name), $cm, $k, $baseTy, $step, $w0, $occT, $tipExp, $seed)
