param([string]$img = "C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png", [int]$bx = 647, [int]$by = 482, [string]$out = "")
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class Outline {
	public static bool[] Mask(Bitmap b, out int W, out int H) {
		W = b.Width; H = b.Height;
		var d = b.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		var m = new bool[W * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			int i = y * d.Stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			m[y * W + x] = !orange && R > 95 && R - G > 40;
		}
		return m;
	}
	public static double[] Profile(bool[] m, int W, int H, int bx, int by) {
		var R = new double[360];
		for (int a = 0; a < 360; a++) {
			double th = a * Math.PI / 180;
			int last = 0, miss = 0;
			for (int r = 6; r < 400; r++) {
				int x = bx + (int)Math.Round(r * Math.Cos(th)), y = by + (int)Math.Round(r * Math.Sin(th));
				if (x < 0 || y < 0 || x >= W || y >= H) break;
				if (m[y * W + x]) { last = r; miss = 0; } else if (last > 0 && ++miss > 18) break;
			}
			R[a] = last;
		}
		return R;
	}
	public static string Compare(bool[] a, bool[] b, int W, int H, int x0, int y0, int x1, int y1) {
		int inter = 0, uni = 0, na = 0, nb = 0; double sa = 0, sb = 0, sab = 0; int n = 0;
		for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) {
			bool p = a[y * W + x], q = b[y * W + x];
			if (p && q) inter++; if (p || q) uni++; if (p) na++; if (q) nb++;
			double u = p ? 1 : 0, v = q ? 1 : 0; sa += u; sb += v; sab += u * v; n++;
		}
		double ma = sa / n, mb = sb / n;
		double corr = (sab / n - ma * mb) / Math.Sqrt(Math.Max(1e-12, (ma - ma * ma) * (mb - mb * mb)));
		return String.Format("outline IoU {0:F1}%  mask correlation {1:F3}  area ref {2} mine {3} (size ratio {4:F3})", 100.0 * inter / Math.Max(1, uni), corr, na, nb, (double)nb / Math.Max(1, na));
	}
}
"@
$b = [System.Drawing.Bitmap]::FromFile($img)
$W = 0; $H = 0
$m = [Outline]::Mask($b, [ref]$W, [ref]$H)
$R = [Outline]::Profile($m, $W, $H, $bx, $by)
if ($out -ne "") { ($R -join ",") | Set-Content $out }
$line = @(); for ($a = 0; $a -lt 360; $a += 5) { $line += "$a`:$($R[$a])" }; $line -join " "
