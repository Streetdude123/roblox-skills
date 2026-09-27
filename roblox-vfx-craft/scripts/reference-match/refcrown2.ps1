param([double]$k = 0.502, [double]$baseTy = 547, [string]$name = "refcrown2.png", [double]$gap = 1.6, [switch]$useOcc, [double]$lo = 0.3, [double]$hi = 0.65)
$dir = $PSScriptRoot
$sp = Split-Path $dir
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing @"
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;
public static class RefCrown2 {
	static double Smooth(double a, double b, double x) { double t = Math.Max(0, Math.Min(1, (x - a) / (b - a))); return t * t * (3 - 2 * t); }
	public static double[,] BodyRamp(Bitmap b, int bx, int by, int rings, int ringPx) {
		int W = b.Width, H = b.Height;
		var d = b.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		var lists = new List<int[]>[rings];
		for (int i = 0; i < rings; i++) lists[i] = new List<int[]>();
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			double dx = x - bx, dy = y - by; int ri = (int)(Math.Sqrt(dx * dx + dy * dy) / ringPx); if (ri >= rings) continue;
			if (Math.Abs(dx) < 22 && dy < 0) continue;
			int i = y * d.Stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			if (orange || !(R > 95 && R - G > 40)) continue;
			lists[ri].Add(new int[] { R, G, B });
		}
		var res = new double[rings, 3];
		for (int r = 0; r < rings; r++) {
			var l = lists[r];
			if (l.Count < 10) { for (int c = 0; c < 3; c++) res[r, c] = r > 0 ? res[r - 1, c] : 1; continue; }
			l.Sort((p, q) => (0.3 * q[0] + 0.59 * q[1] + 0.11 * q[2]).CompareTo(0.3 * p[0] + 0.59 * p[1] + 0.11 * p[2]));
			int n = Math.Max(1, (int)(l.Count * 0.3));
			double sr = 0, sg = 0, sb = 0; for (int i = 0; i < n; i++) { sr += l[i][0]; sg += l[i][1]; sb += l[i][2]; }
			res[r, 0] = sr / n / 255; res[r, 1] = sg / n / 255; res[r, 2] = sb / n / 255;
		}
		return res;
	}
	public static bool pointed = true;
	public static double[,] occ; public static int occRp = 8, occRn = 30; public static double occLo = 0.3, occHi = 0.65;
	public static double[,] Occupancy(Bitmap b, int bx, int by) {
		int W = b.Width, H = b.Height;
		var d = b.LockBits(new Rectangle(0, 0, W, H), ImageLockMode.ReadOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * H];
		System.Runtime.InteropServices.Marshal.Copy(d.Scan0, buf, 0, buf.Length);
		b.UnlockBits(d);
		var hit = new double[360, occRn]; var cnt = new double[360, occRn];
		for (int y = 0; y < H; y++) for (int x = 0; x < W; x++) {
			double dx = x - bx, dy = y - by; double r = Math.Sqrt(dx * dx + dy * dy); int ri = (int)(r / occRp); if (ri >= occRn) continue;
			double a = Math.Atan2(dy, dx) * 180 / Math.PI; if (a < 0) a += 360; int ai = (int)a % 360;
			int i = y * d.Stride + x * 4; int B = buf[i], G = buf[i + 1], R = buf[i + 2];
			bool orange = R > 165 && G > 60 && B < 0.62 * G + 30 && R - B > 110;
			bool p = orange || (R > 95 && R - G > 40);
			cnt[ai, ri] += 1; if (p) hit[ai, ri] += 1;
		}
		var o = new double[360, occRn];
		for (int a = 0; a < 360; a++) for (int r = 0; r < occRn; r++) o[a, r] = cnt[a, r] > 0 ? hit[a, r] / cnt[a, r] : 0;
		return o;
	}
	public static double[,,] cmap; public static int csec = 12;
	public static string Paint(string path, double[] prof, double[,] ramp, int rings, double ringPx, double k, double baseTy, double gapDeg, int seed) {
		var peaks = new List<int>();
		for (int a = 0; a < 360; a++) {
			bool isMax = true;
			for (int j = 1; j <= 3; j++) if (prof[(a + j) % 360] > prof[a] || prof[(a - j + 360) % 360] > prof[a]) { isMax = false; break; }
			if (isMax && (peaks.Count == 0 || a - peaks[peaks.Count - 1] > 2)) peaks.Add(a);
		}
		var valleys = new List<int>();
		for (int i = 0; i < peaks.Count; i++) {
			int a0 = peaks[i], a1 = i + 1 < peaks.Count ? peaks[i + 1] : peaks[0] + 360;
			int best = a0; double bv = 1e9;
			for (int a = a0; a <= a1; a++) { double v = prof[a % 360]; if (v < bv) { bv = v; best = a; } }
			valleys.Add(best % 360);
		}
		int S = 1024;
		var rng = new Random(seed);
		var wedgeOf = new int[3600];
		var bmp = new Bitmap(S, S, PixelFormat.Format32bppArgb);
		var d = bmp.LockBits(new Rectangle(0, 0, S, S), ImageLockMode.WriteOnly, PixelFormat.Format32bppArgb);
		var buf = new byte[d.Stride * S];
		var streak = new double[3600]; var raw = new double[3600];
		for (int i = 0; i < 3600; i++) raw[i] = rng.NextDouble();
		int sm = pointed ? 3 : 2;
		for (int i = 0; i < 3600; i++) { double s = 0; for (int j = -sm; j <= sm; j++) s += raw[(i + j + 3600) % 3600]; streak[i] = s / (2 * sm + 1); }
		int P = peaks.Count;
		for (int ty = 0; ty < S; ty++) for (int tx = 0; tx < S; tx++) {
			double dx = (tx + 0.5 - 512) * k, dy = (ty + 0.5 - baseTy) * k;
			double r = Math.Sqrt(dx * dx + dy * dy);
			double a = Math.Atan2(dy, dx) * 180 / Math.PI; if (a < 0) a += 360;
			int ai = (int)Math.Floor(a) % 360; double fa = a - Math.Floor(a);
			double R = prof[ai] * (1 - fa) + prof[(ai + 1) % 360] * fa;
			double inside = 1 - Smooth(R - 1.2, R + 0.4, r);
			int w = 0;
			for (int i = 0; i < P; i++) { int vL = valleys[(i - 1 + P) % P], vR = valleys[i]; double lo = vL, hi = vR; if (hi < lo) hi += 360; double aa = a; if (aa < lo) aa += 360; if (aa >= lo && aa <= hi) { w = i; break; } }
			int vl = valleys[(w - 1 + P) % P], vr = valleys[w];
			double lo2 = vl, hi2 = vr; if (hi2 < lo2) hi2 += 360; double a2 = a; if (a2 < lo2) a2 += 360;
			double distL = a2 - lo2, distR = hi2 - a2;
			double distEdge = Math.Min(distL, distR);
			double tipR = prof[peaks[w]];
			double vDepthL = Math.Max(0, (Math.Min(tipR, prof[peaks[(w - 1 + P) % P]]) - prof[vl]) / Math.Max(1, prof[vl]));
			double vDepthR = Math.Max(0, (Math.Min(tipR, prof[peaks[(w + 1) % P]]) - prof[vr]) / Math.Max(1, prof[vr]));
			double gL = gapDeg * Math.Min(1.6, vDepthL * 4) * Smooth(prof[vl] * 0.35, prof[vl] * 0.75, r);
			double gR = gapDeg * Math.Min(1.6, vDepthR * 4) * Smooth(prof[vr] * 0.35, prof[vr] * 0.75, r);
			double gapA = Smooth(gL * 0.6, gL + 0.5, distL) * Smooth(gR * 0.6, gR + 0.5, distR);
			double pk = peaks[w]; if (pk < lo2) pk += 360;
			double side = a2 < pk ? pk - lo2 : hi2 - pk;
			double dp = Math.Abs(a2 - pk);
			double rs = tipR * 0.55;
			double allow = side * Math.Pow(Math.Max(0, 1 - Math.Max(0, r - rs) / Math.Max(1, tipR - rs)), 0.8) + 0.8;
			if (pointed) gapA *= 1 - Smooth(allow - 0.6, allow + 0.4, dp);
			double t = Math.Min(1, r / Math.Max(1, tipR));
			double half = Math.Max(0.5, (hi2 - lo2) / 2);
			double edgeDark = pointed ? 0.72 + 0.28 * Smooth(0, 5, distEdge) : 0.8 + 0.2 * Math.Pow(Smooth(0, half, distEdge), 0.7);
			double fade = pointed ? 1 : 1 - 0.65 * Smooth(0.62 * R, R, r);
			double alpha = inside * gapA * Smooth(-2, 8, r) * fade;
			if (occ != null) {
				double op = r / occRp - 0.5; int o0 = Math.Max(0, Math.Min(occRn - 1, (int)Math.Floor(op))); int o1 = Math.Min(occRn - 1, o0 + 1); double fo = Math.Max(0, Math.Min(1, op - o0));
				int b0 = (int)Math.Floor(a) % 360, b1 = (b0 + 1) % 360; double fb = a - Math.Floor(a);
				double ov = (occ[b0, o0] * (1 - fb) + occ[b1, o0] * fb) * (1 - fo) + (occ[b0, o1] * (1 - fb) + occ[b1, o1] * fb) * fo;
				alpha = Math.Max(Smooth(occLo, occHi, ov), 1 - Smooth(55, 70, r)) * Smooth(-2, 8, r) * (1 - 0.35 * Smooth(0.7 * R, R, r));
				if (Math.Abs(dx) < 27 && dy < -2) alpha *= Smooth(20, 27, Math.Abs(dx));
			}
			if (Math.Abs(dx) < 17 && dy < -2) alpha *= Smooth(12, 17, Math.Abs(dx));
			double rp = r / ringPx - 0.5; int r0 = Math.Max(0, Math.Min(rings - 1, (int)Math.Floor(rp))); int r1 = Math.Min(rings - 1, r0 + 1); double fr = Math.Max(0, Math.Min(1, rp - r0));
			double st = pointed ? 0.84 + 0.32 * (streak[(int)(a * 10) % 3600] - 0.5) * 2 : 0.78 + 0.3 * Smooth(0.25, 0.75, streak[(int)(a * 10) % 3600]) + 0.08 * (streak[((int)(a * 23) + 777) % 3600] - 0.5);
			int kk = ty * d.Stride + tx * 4;
			double[] col = new double[3];
			if (cmap != null) {
				double sPos = a / (360.0 / csec) - 0.5; int s0 = (int)Math.Floor(sPos); double fs = sPos - s0; double wsum = 0;
				for (int si = 0; si < 2; si++) for (int ri = 0; ri < 2; ri++) {
					int ss = ((s0 + si) % csec + csec) % csec, rr = ri == 0 ? r0 : r1;
					double wgt = (si == 0 ? 1 - fs : fs) * (ri == 0 ? 1 - fr : fr);
					int rq = rr; while (rq >= 0 && cmap[ss, rq, 0] < 0) rq--;
					if (rq < 0) { rq = rr; while (rq < rings && cmap[ss, rq, 0] < 0) rq++; }
					if (rq < 0 || rq >= rings) continue;
					for (int c = 0; c < 3; c++) col[c] += cmap[ss, rq, c] * wgt;
					wsum += wgt;
				}
				for (int c = 0; c < 3; c++) col[c] = wsum > 0 ? col[c] / wsum : ramp[r0, c];
			} else for (int c = 0; c < 3; c++) col[c] = ramp[r0, c] * (1 - fr) + ramp[r1, c] * fr;
			for (int c = 0; c < 3; c++) {
				double v = col[c] * st * edgeDark;
				buf[kk + 2 - c] = (byte)Math.Max(0, Math.Min(255, v * 255));
			}
			buf[kk + 3] = (byte)(Math.Max(0, Math.Min(1, alpha)) * 255);
		}
		System.Runtime.InteropServices.Marshal.Copy(buf, 0, d.Scan0, buf.Length);
		bmp.UnlockBits(d);
		bmp.Save(path, ImageFormat.Png);
		return "peaks " + P;
	}
}
"@
$prof = [double[]]((Get-Content "$sp\ref_profile.txt") -split ",")
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$ramp = [RefCrown2]::BodyRamp($ref, 647, 482, 24, 10)
"body ramp: " + ((0..21 | ForEach-Object { "{0}:{1:F0},{2:F0},{3:F0}" -f ($_ * 10), ($ramp[$_, 0] * 255), ($ramp[$_, 1] * 255), ($ramp[$_, 2] * 255) }) -join " ")
[RefCrown2]::pointed = $false
$cmLines = Get-Content "$sp\ref_colormap.txt"
$cm = New-Object 'double[,,]' $cmLines.Count, 24, 3
for ($q = 0; $q -lt $cmLines.Count; $q++) { $cells = $cmLines[$q] -split ";"; for ($ring = 0; $ring -lt 24; $ring++) { $v = $cells[$ring] -split ","; for ($c = 0; $c -lt 3; $c++) { $cm[$q, $ring, $c] = [double]$v[$c] } } }
[RefCrown2]::cmap = $cm
if ($useOcc) { [RefCrown2]::occ = [RefCrown2]::Occupancy($ref, 647, 482); [RefCrown2]::occLo = $lo; [RefCrown2]::occHi = $hi }
[RefCrown2]::Paint((Join-Path $dir $name), $prof, $ramp, 24, 10, $k, $baseTy, $gap, 21)
$out = New-Object System.Drawing.Bitmap 520, 520
$g = [System.Drawing.Graphics]::FromImage($out)
$g.Clear([System.Drawing.Color]::FromArgb(255, 14, 12, 13))
$im = [System.Drawing.Image]::FromFile((Join-Path $dir $name))
$g.DrawImage($im, 0, 0, 520, 520)
$out.Save((Join-Path $dir "preview_refcrown2.png"))
