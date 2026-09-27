param([string]$img = "C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png", [int]$bx = 647, [int]$by = 482, [string]$outJson = "")
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class Emb {
	public static List<double[]> Find(Bitmap b) {
		int W = b.Width, H = b.Height;
		var d = b.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		var mask = new bool[W * H];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			int i = y * d.Stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			mask[y * W + x] = (R > 190 && G > 85 && B < 0.62 * G + 30 && R - B > 110) || (R > 225 && G > 165 && B < 175 && R - B > 70 && G - B > 45) || (R > 165 && G > 60 && B < 85 && R - B > 110);
		}
		var seen = new bool[W * H];
		var res = new List<double[]>();
		var stack = new Stack<int>();
		for (int s = 0; s < W * H; s++) {
			if (!mask[s] || seen[s]) continue;
			var px = new List<int>();
			stack.Push(s); seen[s] = true;
			while (stack.Count > 0) {
				int p = stack.Pop(); px.Add(p);
				int x = p % W, y = p / W;
				for (int dy = -1; dy <= 1; dy++) for (int dx = -1; dx <= 1; dx++) {
					int nx = x + dx, ny = y + dy; if (nx < 0 || ny < 0 || nx >= W || ny >= H) continue;
					int q = ny * W + nx; if (mask[q] && !seen[q]) { seen[q] = true; stack.Push(q); }
				}
			}
			if (px.Count < 25) continue;
			double mx = 0, my = 0, lum = 0, lmax = 0;
			foreach (int p in px) {
				int x = p % W, y = p / W; mx += x; my += y;
				int i = y * d.Stride + x * 4; double l = 0.3 * buf[i + 2] + 0.59 * buf[i + 1] + 0.11 * buf[i]; lum += l; lmax = Math.Max(lmax, l);
			}
			mx /= px.Count; my /= px.Count; lum /= px.Count;
			double sxx = 0, syy = 0, sxy = 0;
			foreach (int p in px) { double x = p % W - mx, y = p / W - my; sxx += x * x; syy += y * y; sxy += x * y; }
			double ang = 0.5 * Math.Atan2(2 * sxy, sxx - syy);
			double ca = Math.Cos(ang), sa = Math.Sin(ang);
			double lo = 1e9, hi = -1e9, wl = 1e9, wh = -1e9;
			foreach (int p in px) { double x = p % W - mx, y = p / W - my; double a = x * ca + y * sa, c = -x * sa + y * ca; lo = Math.Min(lo, a); hi = Math.Max(hi, a); wl = Math.Min(wl, c); wh = Math.Max(wh, c); }
			res.Add(new double[] { mx, my, ang * 180 / Math.PI, hi - lo, wh - wl, lum, lmax, px.Count });
		}
		return res;
	}
}
"@
$b = [System.Drawing.Bitmap]::FromFile($img)
$list = [Emb]::Find($b)
$rows = @()
foreach ($e in $list) {
  $dx = $e[0] - $bx; $dy = $e[1] - $by
  $radAng = [Math]::Atan2($dy, $dx) * 180 / [Math]::PI
  $rows += [pscustomobject]@{ x = [Math]::Round($e[0], 1); y = [Math]::Round($e[1], 1); dist = [Math]::Round([Math]::Sqrt($dx * $dx + $dy * $dy), 1); radial = [Math]::Round($radAng, 1); axis = [Math]::Round($e[2], 1); len = [Math]::Round($e[3], 1); wid = [Math]::Round($e[4], 1); lum = [Math]::Round($e[5], 1); lmax = [Math]::Round($e[6], 1); area = $e[7] }
}
$rows | Sort-Object radial | Format-Table -AutoSize | Out-String -Width 200
if ($outJson -ne "") { $rows | ConvertTo-Json | Set-Content $outJson }
