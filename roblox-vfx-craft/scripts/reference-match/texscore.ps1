param([string]$tex, [double]$k = 0.502, [double]$baseTy = 547)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class TexScore {
	public static string Run(Bitmap tex, Bitmap reff, double k, double baseTy) {
		int TW = tex.Width, TH = tex.Height, RW = reff.Width, RH = reff.Height;
		var d1 = tex.LockBits(new Rectangle(0, 0, TW, TH), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var t = new byte[d1.Stride * TH]; System.Runtime.InteropServices.Marshal.Copy(d1.Scan0, t, 0, t.Length); int ts = d1.Stride; tex.UnlockBits(d1);
		var d2 = reff.LockBits(new Rectangle(0, 0, RW, RH), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var r = new byte[d2.Stride * RH]; System.Runtime.InteropServices.Marshal.Copy(d2.Scan0, r, 0, r.Length); int rs = d2.Stride; reff.UnlockBits(d2);
		int inter = 0, uni = 0, na = 0, nb = 0;
		double sa = 0, sb = 0, saa = 0, sbb = 0, sab = 0; int n = 0;
		for (int y = 250; y < 690; y++) for (int x = 400; x < 900; x++) {
			if (Math.Abs(x - 647) < 26 && y < 480) continue;
			double tx = (x - 647) / k + 512, ty = (y - 482) / k + baseTy;
			bool q = false; double tl = 0;
			if (tx >= 0 && ty >= 0 && tx < TW && ty < TH) { int i = (int)ty * ts + (int)tx * 4; q = t[i + 3] > 90; tl = t[i + 3] / 255.0 * (0.3 * t[i + 2] + 0.59 * t[i + 1] + 0.11 * t[i]); }
			int j = y * rs + x * 4; int B = r[j], G = r[j + 1], R = r[j + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			bool p = !orange && R > 95 && R - G > 40;
			double rl = orange ? 0 : 0.3 * R + 0.59 * G + 0.11 * B;
			if (p && q) inter++; if (p || q) uni++; if (p) na++; if (q) nb++;
			sa += rl; sb += tl; saa += rl * rl; sbb += tl * tl; sab += rl * tl; n++;
		}
		double ma = sa / n, mb = sb / n;
		double corr = (sab / n - ma * mb) / Math.Sqrt(Math.Max(1e-9, (saa / n - ma * ma) * (sbb / n - mb * mb)));
		return String.Format("IoU {0:F1}% size {1:F3} luminance corr {2:F3}", 100.0 * inter / Math.Max(1, uni), (double)nb / Math.Max(1, na), corr);
	}
}
"@
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$t = [System.Drawing.Bitmap]::FromFile($tex)
[TexScore]::Run($t, $ref, $k, $baseTy)
