param([string]$dir = "rec", [int]$fps = 30, [double]$seconds = 5, [int]$quality = 85, [int]$left = 11, [int]$top = 233, [int]$right = 470, [int]$bottom = 231, [int]$delayMs = 0, [double]$scale = 0.8)
Add-Type -AssemblyName System.Drawing
if (-not ("Rec4" -as [type])) {
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @"
using System;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Imaging;
using System.Diagnostics;
using System.Threading;
using System.Collections.Concurrent;
using System.Runtime.InteropServices;
using System.Text;
public static class Rec4 {
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern bool SetForegroundWindow(IntPtr h);
  [DllImport("user32.dll")] static extern bool IsIconic(IntPtr h);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int c);
  [DllImport("user32.dll")] static extern bool SetProcessDPIAware();
  [DllImport("winmm.dll")] static extern uint timeBeginPeriod(uint p);
  [DllImport("winmm.dll")] static extern uint timeEndPeriod(uint p);
  struct RECT { public int L, T, R, B; }
  public static string Run(IntPtr h, int left, int top, int right, int bottom, int fps, double seconds, string dir, long quality, int delayMs, double scale) {
    SetProcessDPIAware();
    if (IsIconic(h)) ShowWindow(h, 9);
    SetForegroundWindow(h);
    Thread.Sleep(300 + delayMs);
    RECT r; GetWindowRect(h, out r);
    int x = r.L + left, y = r.T + top, w = (r.R - right) - x, hh = (r.B - bottom) - y;
    w -= w % 2; hh -= hh % 2;
    Directory.CreateDirectory(dir);
    var codec = ImageCodecInfo.GetImageEncoders().First(c => c.MimeType == "image/jpeg");
    int sw2 = (int)(w * scale); sw2 -= sw2 % 2; int sh2 = (int)(hh * scale); sh2 -= sh2 % 2;
    var q = new BlockingCollection<Tuple<Bitmap, double, int>>(16);
    var times = new ConcurrentDictionary<int, double>();
    int dropped = 0;
    Action work = () => {
      var ep = new EncoderParameters(1);
      ep.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
      foreach (var it in q.GetConsumingEnumerable()) {
        using (var small = new Bitmap(sw2, sh2, PixelFormat.Format24bppRgb)) {
          using (var sg = Graphics.FromImage(small)) { sg.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.Bilinear; sg.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighSpeed; sg.DrawImage(it.Item1, 0, 0, sw2, sh2); }
          small.Save(Path.Combine(dir, string.Format("f{0:D5}.jpg", it.Item3)), codec, ep);
        }
        it.Item1.Dispose();
        times[it.Item3] = it.Item2;
      }
    };
    var workers = new Thread[4];
    for (int i = 0; i < workers.Length; i++) { workers[i] = new Thread(new ThreadStart(work)); workers[i].IsBackground = true; workers[i].Start(); }
    long startMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    timeBeginPeriod(1);
    double capSum = 0; double capMax = 0;
    var sw = Stopwatch.StartNew();
    double step = 1000.0 / fps;
    int n = 0; double next = 0;
    while (sw.Elapsed.TotalSeconds < seconds) {
      double now = sw.Elapsed.TotalMilliseconds;
      if (now < next) { Thread.Sleep(Math.Max(0, (int)(next - now) - 1)); continue; }
      next += step;
      if (now - next > step * 2) next = now + step;
      double t = sw.Elapsed.TotalMilliseconds;
      var bmp = new Bitmap(w, hh, PixelFormat.Format24bppRgb);
      double c0 = sw.Elapsed.TotalMilliseconds;
      using (var g = Graphics.FromImage(bmp)) g.CopyFromScreen(x, y, 0, 0, new Size(w, hh));
      double cd = sw.Elapsed.TotalMilliseconds - c0; capSum += cd; capMax = Math.Max(capMax, cd);
      if (!q.TryAdd(Tuple.Create(bmp, t, n))) { bmp.Dispose(); dropped++; continue; }
      n++;
    }
    timeEndPeriod(1);
    q.CompleteAdding();
    foreach (var th in workers) th.Join();
    var sb = new StringBuilder();
    sb.AppendLine("start " + startMs);
    foreach (var k in times.Keys.OrderBy(k => k)) sb.AppendLine(k + " " + times[k].ToString("F1"));
    File.WriteAllText(Path.Combine(dir, "times.txt"), sb.ToString());
    var tl = times.Keys.OrderBy(k => k).Select(k => times[k]).ToList();
    double maxGap = 0; int gaps = 0;
    for (int i = 1; i < tl.Count; i++) { double gp = tl[i] - tl[i - 1]; maxGap = Math.Max(maxGap, gp); if (gp > 45) gaps++; }
    return string.Format("frames {0} dropped {1} size {2}x{3} over {4:F1}s = {5:F1} fps, gaps>45ms {6}, max gap {7:F0} ms, copy avg {8:F1} max {9:F1} ms", n, dropped, sw2, sh2, seconds, n / seconds, gaps, maxGap, capSum / Math.Max(1, n + dropped), capMax);
  }
}
"@
}
$p = Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Output "no studio window"; exit 1 }
[Rec4]::Run($p.MainWindowHandle, $left, $top, $right, $bottom, $fps, $seconds, $dir, $quality, $delayMs, $scale)
