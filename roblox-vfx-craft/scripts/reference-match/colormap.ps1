param([string]$img = "C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png", [int]$bx = 647, [int]$by = 482, [string]$out)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
public static class CMap {
	public static double[,,] Build(Bitmap b, int bx, int by, int sectors, int rings, int ringPx) {
		int W = b.Width, H = b.Height;
		var d = b.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		var acc = new double[sectors, rings, 4];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			double dx = x - bx, dy = y - by;
			double r = Math.Sqrt(dx * dx + dy * dy);
			int ri = (int)(r / ringPx); if (ri >= rings) continue;
			double a = Math.Atan2(dy, dx) * 180 / Math.PI; if (a < 0) a += 360;
			int si = (int)(a / (360.0 / sectors)) % sectors;
			int i = y * d.Stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			if (orange || !(R > 95 && R - G > 40)) continue;
			acc[si, ri, 0] += R; acc[si, ri, 1] += G; acc[si, ri, 2] += B; acc[si, ri, 3] += 1;
		}
		var res = new double[sectors, rings, 3];
		for (int s = 0; s < sectors; s++) for (int r = 0; r < rings; r++) {
			double n = acc[s, r, 3];
			for (int c = 0; c < 3; c++) res[s, r, c] = n > 3 ? acc[s, r, c] / n / 255.0 : -1;
		}
		return res;
	}
}
"@
$b = [System.Drawing.Bitmap]::FromFile($img)
$nsec = 12; $Rn = 24; $Rp = 10
$m = [CMap]::Build($b, $bx, $by, $nsec, $Rn, $Rp)
$lines = @()
for ($s = 0; $s -lt $nsec; $s++) { $row = @(); for ($r = 0; $r -lt $Rn; $r++) { $row += ("{0:F3},{1:F3},{2:F3}" -f $m[$s,$r,0], $m[$s,$r,1], $m[$s,$r,2]) }; $lines += ($row -join ";") }
$lines -join "`n" | Set-Content $out
"sector 9 (up-left..up) rings: " + ((0..20 | ForEach-Object { "{0}:{1:F2}/{2:F2}/{3:F2}" -f ($_ * 10), $m[9,$_,0], $m[9,$_,1], $m[9,$_,2] }) -join " ")
"sector 1 (down-right) rings: " + ((0..20 | ForEach-Object { "{0}:{1:F2}/{2:F2}/{3:F2}" -f ($_ * 10), $m[1,$_,0], $m[1,$_,1], $m[1,$_,2] }) -join " ")
