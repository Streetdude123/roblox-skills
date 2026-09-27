param([string]$dir = "rec", [int]$fps = 26, [double]$seconds = 5, [int]$quality = 85, [int]$left = 8, [int]$top = 8, [int]$right = 8, [int]$bottom = 8, [double]$scale = 0.7, [int]$capThreads = 2, [int]$encThreads = 3)
Add-Type -AssemblyName System.Drawing
if (-not ("Rec5" -as [type])) {
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
public static class Rec5 {
  [DllImport("user32.dll")] static extern bool GetWindowRect(IntPtr h, out RECT r);
  [DllImport("user32.dll")] static extern bool SetProcessDPIAware();
  [DllImport("user32.dll")] static extern IntPtr GetDC(IntPtr h);
  [DllImport("user32.dll")] static extern int ReleaseDC(IntPtr h, IntPtr dc);
  [DllImport("gdi32.dll")] static extern bool BitBlt(IntPtr d, int x, int y, int w, int h, IntPtr s, int sx, int sy, uint op);
  [DllImport("winmm.dll")] static extern uint timeBeginPeriod(uint p);
  [DllImport("winmm.dll")] static extern uint timeEndPeriod(uint p);
  struct RECT { public int L, T, R, B; }
  public static string Run(IntPtr h, int left, int top, int right, int bottom, int fps, double seconds, string dir, long quality, double scale, int capThreads, int encThreads) {
    SetProcessDPIAware();
    RECT r; GetWindowRect(h, out r);
    int x = r.L + left, y = r.T + top, w = (r.R - right) - x, hh = (r.B - bottom) - y;
    w -= w % 2; hh -= hh % 2;
    Directory.CreateDirectory(dir);
    var codec = ImageCodecInfo.GetImageEncoders().First(c => c.MimeType == "image/jpeg");
    int sw2 = (int)(w * scale); sw2 -= sw2 % 2; int sh2 = (int)(hh * scale); sh2 -= sh2 % 2;
    var q = new BlockingCollection<Tuple<Bitmap, double, int>>(24);
    var times = new ConcurrentDictionary<int, double>();
    int dropped = 0, skipped = 0;
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
    var workers = new Thread[encThreads];
    for (int i = 0; i < workers.Length; i++) { workers[i] = new Thread(new ThreadStart(work)); workers[i].IsBackground = true; workers[i].Start(); }
    long startMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    timeBeginPeriod(1);
    var sw = Stopwatch.StartNew();
    double step = 1000.0 / fps;
    int total = (int)(seconds * fps);
    int next = -1;
    var caps = new Thread[capThreads];
    for (int c = 0; c < capThreads; c++) {
      caps[c] = new Thread(() => {
        while (true) {
          int k = Interlocked.Increment(ref next);
          if (k >= total) break;
          double due = k * step;
          double now = sw.Elapsed.TotalMilliseconds;
          if (now > due + step * 1.5) { Interlocked.Increment(ref skipped); continue; }
          if (now < due) Thread.Sleep(Math.Max(0, (int)(due - now)));
          var bmp = new Bitmap(w, hh, PixelFormat.Format24bppRgb);
          double t = sw.Elapsed.TotalMilliseconds;
          using (var g = Graphics.FromImage(bmp)) {
            IntPtr dst = g.GetHdc(); IntPtr src = GetDC(IntPtr.Zero);
            BitBlt(dst, 0, 0, w, hh, src, x, y, 0x00CC0020);
            ReleaseDC(IntPtr.Zero, src); g.ReleaseHdc(dst);
          }
          if (!q.TryAdd(Tuple.Create(bmp, t, k))) { bmp.Dispose(); Interlocked.Increment(ref dropped); }
        }
      });
      caps[c].Start();
    }
    foreach (var c in caps) c.Join();
    timeEndPeriod(1);
    q.CompleteAdding();
    foreach (var th in workers) th.Join();
    var sb = new StringBuilder();
    sb.AppendLine("start " + startMs);
    var keys = times.Keys.OrderBy(k => k).ToList();
    for (int i = 0; i < keys.Count; i++) sb.AppendLine(keys[i] + " " + times[keys[i]].ToString("F1"));
    File.WriteAllText(Path.Combine(dir, "times.txt"), sb.ToString());
    return string.Format("frames {0} skipped {1} dropped {2} size {3}x{4} over {5:F1}s = {6:F1} fps", keys.Count, skipped, dropped, sw2, sh2, seconds, keys.Count / seconds);
  }
}
"@
}
$p = Get-Process RobloxStudioBeta -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1
if (-not $p) { Write-Output "no studio window"; exit 1 }
[Rec5]::Run($p.MainWindowHandle, $left, $top, $right, $bottom, $fps, $seconds, $dir, $quality, $scale, $capThreads, $encThreads)
