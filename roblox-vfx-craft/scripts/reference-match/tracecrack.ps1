param([double]$Sz = 4.4, [string]$name = "tracecrack.png", [int]$flip = 0)
$dir = $PSScriptRoot
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class TraceCrack {
	public static string Run(Bitmap reff, string path, double Sz, int flip) {
		int RW = reff.Width, RH = reff.Height;
		var d = reff.LockBits(new Rectangle(0, 0, RW, RH), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var rb = new byte[d.Stride * RH]; System.Runtime.InteropServices.Marshal.Copy(d.Scan0, rb, 0, rb.Length); int rs = d.Stride; reff.UnlockBits(d);
		double cx = 0.231, cy = 17.85, cz = 7.15;
		double fy = 7.84 - 17.85, fz = 24.46 - 7.15; double fl = Math.Sqrt(fy * fy + fz * fz); fy /= fl; fz /= fl;
		double uy = fz, uz = -fy;
		double focal = 1 / Math.Tan(22.5 * Math.PI / 180) * 360;
		int S = 512, hits = 0;
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		var o = bmp.LockBits(new Rectangle(0, 0, S, S), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var ob = new byte[o.Stride * S];
		for (int ty = 0; ty < S; ty++) for (int tx = 0; tx < S; tx++) {
			double u = (tx + 0.5) / S - 0.5, v = (ty + 0.5) / S - 0.5;
			if ((flip & 1) != 0) u = -u; if ((flip & 2) != 0) v = -v;
			if ((flip & 4) != 0) { double t = u; u = v; v = t; }
			double X = u * Sz, Z = 30 + v * Sz, Y = 0.06;
			double dx = X - cx, dy = Y - cy, dz = Z - cz;
			double dF = dy * fy + dz * fz, dU = dy * uy + dz * uz, dR = -dx;
			double px = 640 + dR / dF * focal, py = 360 - dU / dF * focal;
			int ix = (int)px, iy = (int)py;
			double a = 0;
			if (ix >= 1 && iy >= 1 && ix < RW - 1 && iy < RH - 1) {
				int n = 0;
				for (int yy = -1; yy <= 1; yy++) for (int xx = -1; xx <= 1; xx++) {
					int i = (iy + yy) * rs + (ix + xx) * 4; int B = rb[i], G = rb[i + 1], R = rb[i + 2];
					if (G < 28 && R < 215 && B < 115 && R > 90) n++;
				}
				double rr = Math.Sqrt(X * X + (Z - 30) * (Z - 30));
				if (rr > 0.45 && rr < Sz / 2) a = n / 9.0;
			}
			int k = ty * o.Stride + tx * 4;
			ob[k] = 255; ob[k + 1] = 255; ob[k + 2] = 255; ob[k + 3] = (byte)(Math.Min(1, a * 1.6) * 255);
			if (a > 0.3) hits++;
		}
		System.Runtime.InteropServices.Marshal.Copy(ob, 0, o.Scan0, ob.Length);
		bmp.UnlockBits(o);
		bmp.Save(path, ImageFormat.Png);
		return "texels " + hits;
	}
}
"@
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
[TraceCrack]::Run($ref, (Join-Path $dir $name), $Sz, $flip)
$out = New-Object System.Drawing.Bitmap 1040, 520
$g = [System.Drawing.Graphics]::FromImage($out)
$g.Clear([System.Drawing.Color]::FromArgb(255, 240, 130, 190))
$cm = New-Object System.Drawing.Imaging.ColorMatrix
$cm.Matrix00 = 0.2; $cm.Matrix11 = 0.02; $cm.Matrix22 = 0.09
$ia = New-Object System.Drawing.Imaging.ImageAttributes
$ia.SetColorMatrix($cm)
$im = [System.Drawing.Image]::FromFile((Join-Path $dir $name))
$g.DrawImage($im, (New-Object System.Drawing.Rectangle 4, 4, 512, 512), 0, 0, 512, 512, [System.Drawing.GraphicsUnit]::Pixel, $ia)
$g.DrawImage($ref, (New-Object System.Drawing.Rectangle 524, 4, 512, 512), (New-Object System.Drawing.Rectangle 567, 402, 160, 160), [System.Drawing.GraphicsUnit]::Pixel)
$out.Save((Join-Path $dir "preview_tracecrack.png"))
