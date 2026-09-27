param([string]$mine)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class Shape {
	static byte[] Load(Bitmap b, out int stride) {
		var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * b.Height];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		stride = d.Stride; b.UnlockBits(d); return buf;
	}
	static bool[] Mask(byte[] buf, int stride, int W, int H) {
		var m = new bool[W * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			int i = y * stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			double lum = 0.3 * R + 0.59 * G + 0.11 * B;
			m[y * W + x] = lum > 55 || (R > 95 && R - G > 40);
		}
		return m;
	}
	static double[] Blur(bool[] m, int W, int H, int r) {
		var o = new double[W * H];
		var tmp = new double[W * H];
		for (int y = 0; y < H; y++) { double s = 0; for (int x = -r; x < W + r; x++) { if (x + r < W && x + r >= 0) s += m[y * W + x + r] ? 1 : 0; if (x - r - 1 >= 0 && x - r - 1 < W) s -= m[y * W + x - r - 1] ? 1 : 0; if (x >= 0 && x < W) tmp[y * W + x] = s / (2 * r + 1); } }
		for (int x = 0; x < W; x++) { double s = 0; for (int y = -r; y < H + r; y++) { if (y + r < H && y + r >= 0) s += tmp[(y + r) * W + x]; if (y - r - 1 >= 0 && y - r - 1 < H) s -= tmp[(y - r - 1) * W + x]; if (y >= 0 && y < H) o[y * W + x] = s / (2 * r + 1); } }
		return o;
	}
	static double Corr(double[] a, double[] b, int W, int x0, int y0, int x1, int y1) {
		double sa = 0, sb = 0, saa = 0, sbb = 0, sab = 0; int n = 0;
		for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) { double u = a[y * W + x], v = b[y * W + x]; sa += u; sb += v; saa += u * u; sbb += v * v; sab += u * v; n++; }
		double ma = sa / n, mb = sb / n;
		return (sab / n - ma * mb) / Math.Sqrt(Math.Max(1e-12, (saa / n - ma * ma) * (sbb / n - mb * mb)));
	}
	public static string Run(Bitmap ra, Bitmap rb, int x0, int y0, int x1, int y1) {
		int W = ra.Width, H = ra.Height, s1, s2;
		var A = Load(ra, out s1); var B = Load(rb, out s2);
		var ma = Mask(A, s1, W, H); var mb = Mask(B, s2, W, H);
		int inter = 0, uni = 0, na = 0, nb = 0;
		for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) { bool p = ma[y * W + x], q = mb[y * W + x]; if (p && q) inter++; if (p || q) uni++; if (p) na++; if (q) nb++; }
		var fa = new double[W * H]; var fb = new double[W * H];
		for (int i = 0; i < W * H; i++) { fa[i] = ma[i] ? 1 : 0; fb[i] = mb[i] ? 1 : 0; }
		double mc = Corr(fa, fb, W, x0, y0, x1, y1);
		double sc = Corr(Blur(ma, W, H, 4), Blur(mb, W, H, 4), W, x0, y0, x1, y1);
		var ch = new double[3];
		for (int c = 0; c < 3; c++) {
			var ca = new double[W * H]; var cb = new double[W * H];
			for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) { ca[y * W + x] = A[y * s1 + x * 4 + (2 - c)]; cb[y * W + x] = B[y * s2 + x * 4 + (2 - c)]; }
			ch[c] = Corr(ca, cb, W, x0, y0, x1, y1);
		}
		return String.Format("SIZE area ratio {0:F3} | SHAPE outline IoU {1:F1}%, mask corr {2:F3}, soft-mask corr {3:F3} | COLOR corr R {4:F3} G {5:F3} B {6:F3} (mean {7:F3})", (double)nb / Math.Max(1, na), 100.0 * inter / Math.Max(1, uni), mc, sc, ch[0], ch[1], ch[2], (ch[0] + ch[1] + ch[2]) / 3);
	}
}
"@
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$me = [System.Drawing.Bitmap]::FromFile($mine)
"effect box: " + [Shape]::Run($ref, $me, 400, 80, 900, 640)
"spike 600-700 x 100-470: " + [Shape]::Run($ref, $me, 600, 100, 700, 470)
"left burst 440-600 x 300-620: " + [Shape]::Run($ref, $me, 440, 300, 600, 620)
"right burst 700-880 x 300-620: " + [Shape]::Run($ref, $me, 700, 300, 880, 620)
"base 580-720 x 430-540: " + [Shape]::Run($ref, $me, 580, 430, 720, 540)
