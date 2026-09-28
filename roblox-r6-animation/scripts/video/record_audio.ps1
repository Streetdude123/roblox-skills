param([string]$dir = "rec", [double]$seconds = 10)
if (-not ("LoopRec" -as [type])) {
Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Diagnostics;
using System.Threading;
using System.Runtime.InteropServices;

[ComImport, Guid("BCDE0395-E52F-467C-8E3D-C4579291692E")] class MMDeviceEnumeratorCom {}

[Guid("A95664D2-9614-4F35-A746-DE8DB63617E6"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDeviceEnumerator {
  int EnumAudioEndpoints(int dataFlow, int stateMask, out IntPtr devices);
  int GetDefaultAudioEndpoint(int dataFlow, int role, out IMMDevice device);
}

[Guid("D666063F-1587-4E43-81F1-B948E807363F"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IMMDevice {
  int Activate(ref Guid iid, int clsCtx, IntPtr activationParams, [MarshalAs(UnmanagedType.IUnknown)] out object iface);
}

[Guid("1CB9AD4C-DBFA-4c32-B178-C2F568A703B2"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioClient {
  int Initialize(int shareMode, int streamFlags, long bufferDuration, long periodicity, IntPtr format, IntPtr sessionGuid);
  int GetBufferSize(out uint frames);
  int GetStreamLatency(out long latency);
  int GetCurrentPadding(out uint padding);
  int IsFormatSupported(int shareMode, IntPtr format, out IntPtr closest);
  int GetMixFormat(out IntPtr format);
  int GetDevicePeriod(out long defPeriod, out long minPeriod);
  int Start();
  int Stop();
  int Reset();
  int SetEventHandle(IntPtr handle);
  int GetService(ref Guid iid, [MarshalAs(UnmanagedType.IUnknown)] out object service);
}

[Guid("C8ADBD64-E71E-48a0-A4DE-185C395CD317"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IAudioCaptureClient {
  int GetBuffer(out IntPtr data, out uint frames, out uint flags, out ulong devPos, out ulong qpcPos);
  int ReleaseBuffer(uint frames);
  int GetNextPacketSize(out uint frames);
}

public static class LoopRec {
  public static string Run(string dir, double seconds) {
    Directory.CreateDirectory(dir);
    var en = (IMMDeviceEnumerator)new MMDeviceEnumeratorCom();
    IMMDevice dev; en.GetDefaultAudioEndpoint(0, 0, out dev);
    Guid iidClient = new Guid("1CB9AD4C-DBFA-4c32-B178-C2F568A703B2");
    object o; dev.Activate(ref iidClient, 23, IntPtr.Zero, out o);
    var client = (IAudioClient)o;
    IntPtr fmt; client.GetMixFormat(out fmt);
    int channels = Marshal.ReadInt16(fmt, 2);
    int rate = Marshal.ReadInt32(fmt, 4);
    int blockAlign = Marshal.ReadInt16(fmt, 12);
    int bits = Marshal.ReadInt16(fmt, 14);
    int hr = client.Initialize(0, 0x00020000, 10000000, 0, fmt, IntPtr.Zero);
    if (hr != 0) return "init failed " + hr.ToString("X");
    Guid iidCap = new Guid("C8ADBD64-E71E-48a0-A4DE-185C395CD317");
    object c; client.GetService(ref iidCap, out c);
    var cap = (IAudioCaptureClient)c;
    var pcm = new MemoryStream();
    var bw = new BinaryWriter(pcm);
    long written = 0;
    var sw = Stopwatch.StartNew();
    long startMs = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    double qpcStart = Stopwatch.GetTimestamp() * 1e7 / Stopwatch.Frequency;
    client.Start();
    File.WriteAllText(Path.Combine(dir, "audio_live.txt"), startMs.ToString());
    byte[] buf = new byte[1 << 20];
    while (sw.Elapsed.TotalSeconds < seconds) {
      Thread.Sleep(5);
      uint next; cap.GetNextPacketSize(out next);
      bool got = false;
      while (next > 0) {
        IntPtr data; uint frames, flags; ulong dp, qp;
        cap.GetBuffer(out data, out frames, out flags, out dp, out qp);
        long at = (long)((qp - qpcStart) * rate / 1e7);
        if (at > written) {
          for (long i = 0; i < (at - written) * channels; i++) bw.Write((short)0);
          written = at;
        }
        int bytes = (int)frames * blockAlign;
        if (bytes > buf.Length) buf = new byte[bytes];
        if ((flags & 2) != 0) Array.Clear(buf, 0, bytes); else Marshal.Copy(data, buf, 0, bytes);
        for (int i = 0; i < frames * channels; i++) {
          float v = bits == 32 ? BitConverter.ToSingle(buf, i * 4) : BitConverter.ToInt16(buf, i * 2) / 32768f;
          if (v > 1) v = 1; if (v < -1) v = -1;
          bw.Write((short)(v * 32767));
        }
        written += frames;
        cap.ReleaseBuffer(frames);
        cap.GetNextPacketSize(out next);
        got = true;
      }
      long want = (long)(sw.Elapsed.TotalSeconds * rate) - rate / 20;
      if (!got && written < want) {
        long pad = want - written;
        for (long i = 0; i < pad * channels; i++) bw.Write((short)0);
        written += pad;
      }
    }
    client.Stop();
    bw.Flush();
    byte[] body = pcm.ToArray();
    using (var f = new BinaryWriter(File.Create(Path.Combine(dir, "audio.wav")))) {
      f.Write(new char[] { 'R', 'I', 'F', 'F' }); f.Write(36 + body.Length);
      f.Write(new char[] { 'W', 'A', 'V', 'E', 'f', 'm', 't', ' ' }); f.Write(16);
      f.Write((short)1); f.Write((short)channels); f.Write(rate); f.Write(rate * channels * 2);
      f.Write((short)(channels * 2)); f.Write((short)16);
      f.Write(new char[] { 'd', 'a', 't', 'a' }); f.Write(body.Length); f.Write(body);
    }
    File.WriteAllText(Path.Combine(dir, "audio_start.txt"), startMs.ToString());
    return "audio " + rate + " Hz " + channels + " ch " + bits + " bit, " + written + " frames = " + (written / (double)rate).ToString("F2") + " s";
  }
}
"@
}
[LoopRec]::Run($dir, $seconds)
