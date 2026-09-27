param([int]$seed = 5)
$dir = $PSScriptRoot
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class Column {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	static double[] Noise(Random rng, int n, int smooth) {
		var raw = new double[n]; for (int i = 0; i < n; i++) raw[i] = rng.NextDouble() * 2 - 1;
		var o = new double[n];
		for (int i = 0; i < n; i++) { double s = 0; int c = 0; for (int j = -smooth; j <= smooth; j++) { int k = i + j; if (k >= 0 && k < n) { s += raw[k]; c++; } } o[i] = s / c; }
		return o;
	}
	static void Save(double[] a, int W, int H, string path) {
		var bmp = new Bitmap(W, H, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			int k = y * d.Stride + x * 4; buf[k] = 255; buf[k + 1] = 255; buf[k + 2] = 255;
			buf[k + 3] = (byte)(Math.Max(0, Math.Min(1, a[y * W + x])) * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
		bmp.Save(path, ImageFormat.Png);
	}
	public static void Core(string path, int seed) {
		int W = 128, H = 512;
		var rng = new Random(seed);
		var edgeL = Noise(rng, H, 3); var edgeR = Noise(rng, H, 3);
		var streak = Noise(rng, W, 2);
		int T = 6;
		var tx = new double[T]; var th = new double[T]; var tw = new double[T];
		for (int t = 0; t < T; t++) { tx[t] = -0.3 + 0.6 * (t + 0.5) / T + (rng.NextDouble() - 0.5) * 0.06; th[t] = 0.08 + rng.NextDouble() * 0.3; tw[t] = 0.05 + rng.NextDouble() * 0.05; }
		th[2] = 0.36; th[3] = 0.3;
		var a = new double[W * H];
		for (int y = 0; y < H; y++) {
			double v = y / (double)(H - 1);
			for (int x = 0; x < W; x++) {
				double u = (x + 0.5) / W - 0.5;
				double hw = 0.34;
				double l = -hw + 0.04 * edgeL[y], r = hw + 0.04 * edgeR[y];
				double side = Smooth(l - 0.02, l + 0.015, u) * (1 - Smooth(r - 0.015, r + 0.02, u));
				double top = 0.62;
				for (int t = 0; t < T; t++) {
					double q = (u - tx[t]) / tw[t];
					top = Math.Min(top, 0.62 - th[t] * Math.Exp(-q * q) - 0.03);
				}
				double lick = 0.02 * edgeL[(x * 4) % H];
				double vert = Smooth(top + lick - 0.05, top + lick + 0.04, v);
				double tex = 0.85 + 0.15 * streak[x];
				double bottom = 1 - Smooth(0.94, 1.0, v);
				a[y * W + x] = side * vert * tex * bottom;
			}
		}
		Save(a, W, H, path);
	}
	public static void Sheath(string path, int seed) {
		int W = 128, H = 512;
		var rng = new Random(seed);
		int N = 26;
		var ux = new double[N]; var sg = new double[N]; var vs = new double[N]; var iv = new double[N];
		for (int i = 0; i < N; i++) {
			ux[i] = (rng.NextDouble() * 2 - 1) * 0.92;
			sg[i] = 0.012 + rng.NextDouble() * 0.03;
			vs[i] = rng.NextDouble() * 0.45 * (0.3 + Math.Abs(ux[i]));
			iv[i] = 0.25 + rng.NextDouble() * 0.5;
		}
		var edge = Noise(rng, H, 4);
		var a = new double[W * H];
		for (int y = 0; y < H; y++) {
			double v = y / (double)(H - 1);
			double hw = v > 0.5 ? 0.44 : 0.02 + 0.42 * Math.Pow(v / 0.5, 0.8);
			hw += 0.03 * edge[y];
			for (int x = 0; x < W; x++) {
				double u = (x + 0.5) / W - 0.5;
				double s = 0;
				for (int i = 0; i < N; i++) {
					double dx = (u - ux[i] * hw) / (sg[i] + 0.004);
					s += iv[i] * Math.Exp(-dx * dx) * Smooth(vs[i], vs[i] + 0.1, v);
				}
				double cx = u / (0.008 + 0.04 * Math.Min(1, v * 2));
				s += Math.Exp(-cx * cx);
				double edgeK = Math.Exp(-Math.Pow(Math.Abs(u) / Math.Max(0.01, hw), 6));
				a[y * W + x] = (1 - Math.Exp(-s * 1.5)) * edgeK * (1 - 0.5 * Smooth(0.9, 1.0, v));
			}
		}
		Save(a, W, H, path);
	}
}
"@
[Column]::Core((Join-Path $dir "colcore.png"), $seed)
[Column]::Sheath((Join-Path $dir "colsheath.png"), $seed + 1)
$out = New-Object System.Drawing.Bitmap 700, 520
$g = [System.Drawing.Graphics]::FromImage($out)
$g.Clear([System.Drawing.Color]::FromArgb(255, 40, 30, 34))
$core = [System.Drawing.Image]::FromFile((Join-Path $dir "colcore.png"))
$sh = [System.Drawing.Image]::FromFile((Join-Path $dir "colsheath.png"))
$g.DrawImage($core, 4, 4, 128, 512)
$g.DrawImage($sh, 150, 4, 128, 512)
$ia1 = New-Object System.Drawing.Imaging.ImageAttributes
$m1 = New-Object System.Drawing.Imaging.ColorMatrix; $m1.Matrix00 = 0.3; $m1.Matrix11 = 0.03; $m1.Matrix22 = 0.12; $ia1.SetColorMatrix($m1)
$ia2 = New-Object System.Drawing.Imaging.ImageAttributes
$m2 = New-Object System.Drawing.Imaging.ColorMatrix; $m2.Matrix00 = 1; $m2.Matrix11 = 0.15; $m2.Matrix22 = 0.78; $ia2.SetColorMatrix($m2)
$g.DrawImage($sh, (New-Object System.Drawing.Rectangle 300, 4, 150, 512), 0, 0, 128, 512, [System.Drawing.GraphicsUnit]::Pixel, $ia1)
$g.DrawImage($sh, (New-Object System.Drawing.Rectangle 318, 4, 114, 512), 0, 0, 128, 512, [System.Drawing.GraphicsUnit]::Pixel, $ia2)
$g.DrawImage($core, 336, 150, 78, 366)
$ref = [System.Drawing.Image]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$g.DrawImage($ref, (New-Object System.Drawing.Rectangle 470, 4, 220, 512), (New-Object System.Drawing.Rectangle 590, 100, 110, 400), [System.Drawing.GraphicsUnit]::Pixel)
$out.Save((Join-Path $dir "preview_column.png"))
"ok"

