param([string]$shot, [string]$tag = "cmp")
$dir = Split-Path $shot
$refPath = "C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png"
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class Cmp {
	public static int[] FindGreen(Bitmap b) {
		int x0 = int.MaxValue, y0 = int.MaxValue, x1 = -1, y1 = -1;
		var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * b.Height];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		for (int y = 0; y < b.Height; y++) for (int x = 0; x < b.Width; x++) {
			int i = y * d.Stride + x * 4;
			int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			if (G > 245 && R < 12 && B < 12) { if (x < x0) x0 = x; if (y < y0) y0 = y; if (x > x1) x1 = x; if (y > y1) y1 = y; }
		}
		return new int[] { x0, y0, x1, y1 };
	}
	public static double[,,] Grid(Bitmap b, int gw, int gh) {
		var g = new double[gw, gh, 3];
		var n = new int[gw, gh];
		var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * b.Height];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		for (int y = 0; y < b.Height; y++) for (int x = 0; x < b.Width; x++) {
			int gx = x * gw / b.Width, gy = y * gh / b.Height, i = y * d.Stride + x * 4;
			g[gx, gy, 0] += buf[i + 2]; g[gx, gy, 1] += buf[i + 1]; g[gx, gy, 2] += buf[i]; n[gx, gy]++;
		}
		for (int x = 0; x < gw; x++) for (int y = 0; y < gh; y++) for (int c = 0; c < 3; c++) g[x, y, c] /= Math.Max(1, n[x, y]);
		return g;
	}
	public static string Score(Bitmap a, Bitmap r, int gw, int gh, int bx0, int by0, int bx1, int by1) {
		var A = Grid(a, gw, gh); var Rg = Grid(r, gw, gh);
		double mad = 0; int cnt = 0;
		double sa = 0, sr = 0, saa = 0, srr = 0, sar = 0;
		for (int x = bx0; x < bx1; x++) for (int y = by0; y < by1; y++) {
			for (int c = 0; c < 3; c++) mad += Math.Abs(A[x, y, c] - Rg[x, y, c]);
			double la = 0.3 * A[x, y, 0] + 0.59 * A[x, y, 1] + 0.11 * A[x, y, 2];
			double lr = 0.3 * Rg[x, y, 0] + 0.59 * Rg[x, y, 1] + 0.11 * Rg[x, y, 2];
			sa += la; sr += lr; saa += la * la; srr += lr * lr; sar += la * lr; cnt++;
		}
		mad /= cnt * 3;
		double ma = sa / cnt, mr = sr / cnt;
		double corr = (sar / cnt - ma * mr) / Math.Sqrt(Math.Max(1e-9, (saa / cnt - ma * ma) * (srr / cnt - mr * mr)));
		return String.Format("grid {0}x{1}: colour similarity {2:F1}% (mean abs diff {3:F1}/255), luminance correlation {4:F3}", gw, gh, 100 * (1 - mad / 255), mad, corr);
	}
}
"@
$img = [System.Drawing.Bitmap]::FromFile($shot)
$box = [Cmp]::FindGreen($img)
"green bbox: $($box -join ',')"
$vx = $box[0]; $vy = $box[1]; $vw = $box[2] - $box[0] + 1; $vh = $box[3] - $box[1] + 1
if ($vw / $vh -gt 16 / 9) { $ch = $vh; $cw = [int]($vh * 16 / 9) } else { $cw = $vw; $ch = [int]($vw * 9 / 16) }
$cx = $vx + [int](($vw - $cw) / 2); $cy = $vy + [int](($vh - $ch) / 2)
$mine = New-Object System.Drawing.Bitmap 1280, 720
$g = [System.Drawing.Graphics]::FromImage($mine)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.DrawImage($img, (New-Object System.Drawing.Rectangle 0, 0, 1280, 720), (New-Object System.Drawing.Rectangle $cx, $cy, $cw, $ch), [System.Drawing.GraphicsUnit]::Pixel)
$mine.Save("$dir\$tag`_mine.png")
$ref = [System.Drawing.Bitmap]::FromFile($refPath)
"effect box 400-900 x 80-640:"
[Cmp]::Score($mine, $ref, 160, 90, 50, 10, 113, 80)
[Cmp]::Score($mine, $ref, 64, 36, 20, 4, 45, 32)
"whole frame:"
[Cmp]::Score($mine, $ref, 160, 90, 0, 0, 160, 90)
$side = New-Object System.Drawing.Bitmap 1600, 900
$s = [System.Drawing.Graphics]::FromImage($side)
$s.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$s.Clear([System.Drawing.Color]::Black)
$s.DrawImage($ref, (New-Object System.Drawing.Rectangle 0, 0, 800, 450), (New-Object System.Drawing.Rectangle 0, 0, 1280, 720), [System.Drawing.GraphicsUnit]::Pixel)
$s.DrawImage($mine, (New-Object System.Drawing.Rectangle 800, 0, 800, 450), (New-Object System.Drawing.Rectangle 0, 0, 1280, 720), [System.Drawing.GraphicsUnit]::Pixel)
$s.DrawImage($ref, (New-Object System.Drawing.Rectangle 0, 450, 800, 450), (New-Object System.Drawing.Rectangle 420, 80, 460, 560), [System.Drawing.GraphicsUnit]::Pixel)
$s.DrawImage($mine, (New-Object System.Drawing.Rectangle 800, 450, 800, 450), (New-Object System.Drawing.Rectangle 420, 80, 460, 560), [System.Drawing.GraphicsUnit]::Pixel)
$side.Save("$dir\$tag`_side.png")
"saved $dir\$tag`_side.png"

