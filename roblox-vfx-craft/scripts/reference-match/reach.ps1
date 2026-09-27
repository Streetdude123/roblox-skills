param([string]$mine, [int]$bx = 647, [int]$by = 482)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class Reach {
	static byte[] Load(Bitmap b, out int stride) {
		var d = b.LockBits(new Rectangle(0, 0, b.Width, b.Height), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * b.Height];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		stride = d.Stride; b.UnlockBits(d); return buf;
	}
	public static string Rays(Bitmap b, int bx, int by, string kind) {
		int stride; var buf = Load(b, out stride);
		var sb = new System.Text.StringBuilder();
		for (int deg = -180; deg < 180; deg += 30) {
			double a = deg * Math.PI / 180;
			int last = 0;
			for (int r = 8; r < 420; r++) {
				int x = bx + (int)(r * Math.Cos(a)), y = by + (int)(r * Math.Sin(a));
				if (x < 0 || y < 0 || x >= b.Width || y >= b.Height) break;
				int i = y * stride + x * 4;
				int B = buf[i], G = buf[i + 1], R = buf[i + 2];
				bool hit = kind == "pink" ? (R > 110 && R - G > 45 && R > B) : (R > 200 && G > 110 && B < 110 && R - B > 110);
				if (hit) last = r;
			}
			sb.Append(deg + ":" + last + " ");
		}
		return sb.ToString();
	}
	public static string Stats(Bitmap b, int x0, int y0, int x1, int y1) {
		int stride; var buf = Load(b, out stride);
		double sr = 0, sg = 0, sbb = 0; int n = 0, pink = 0, white = 0, dark = 0, orange = 0;
		for (int y = y0; y < y1; y++) for (int x = x0; x < x1; x++) {
			int i = y * stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			sr += R; sg += G; sbb += B; n++;
			if (R > 230 && G > 200 && B > 210) white++;
			else if (R > 200 && G > 110 && B < 110 && R - B > 110) orange++;
			else if (R > 110 && R - G > 45 && R > B) pink++;
			if (R < 90 && G < 30 && B < 50 && R > G + 15) dark++;
		}
		return String.Format("mean {0:F0},{1:F0},{2:F0} white {3:F1}% pink {4:F1}% orange {5:F1}% maroon {6:F1}%", sr / n, sg / n, sbb / n, 100.0 * white / n, 100.0 * pink / n, 100.0 * orange / n, 100.0 * dark / n);
	}
}
"@
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$me = [System.Drawing.Bitmap]::FromFile($mine)
"pink reach ref : " + [Reach]::Rays($ref, 647, 482, "pink")
"pink reach mine: " + [Reach]::Rays($me, $bx, $by, "pink")
"spark reach ref : " + [Reach]::Rays($ref, 647, 482, "orange")
"spark reach mine: " + [Reach]::Rays($me, $bx, $by, "orange")
"effect box ref : " + [Reach]::Stats($ref, 420, 80, 880, 640)
"effect box mine: " + [Reach]::Stats($me, 420, 80, 880, 640)
"spike box ref : " + [Reach]::Stats($ref, 600, 100, 690, 470)
"spike box mine: " + [Reach]::Stats($me, 600, 100, 690, 470)
"base box ref : " + [Reach]::Stats($ref, 580, 430, 720, 530)
"base box mine: " + [Reach]::Stats($me, 580, 430, 720, 530)
"lower box ref : " + [Reach]::Stats($ref, 480, 500, 820, 640)
"lower box mine: " + [Reach]::Stats($me, 480, 500, 820, 640)
