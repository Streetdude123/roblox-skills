async function peek(src, times, name, cols, cellW) {
  const buf = await (await fetch(src)).arrayBuffer();
  const v = demux(buf);
  const cellH = Math.round(cellW * v.height / v.width);
  const rows = Math.ceil(times.length / cols);
  const sheet = new OffscreenCanvas(cellW * cols, cellH * rows);
  const g = sheet.getContext("2d");
  const want = times.map((t) => Math.round(t * 1e6));
  const best = want.map(() => ({d: Infinity}));
  const grabbed = [];
  await new Promise((resolve, reject) => {
    const decoder = new VideoDecoder({
      output: (frame) => {
        want.forEach((w, i) => {
          const d = Math.abs(frame.timestamp - w);
          if (d < best[i].d) {
            best[i].d = d;
            g.drawImage(frame, (i % cols) * cellW, Math.floor(i / cols) * cellH, cellW, cellH);
            best[i].ts = frame.timestamp;
          }
        });
        frame.close();
      },
      error: reject,
    });
    decoder.configure({codec: v.codec, description: v.desc, codedWidth: v.width, codedHeight: v.height});
    const bytes = new Uint8Array(buf);
    for (const s of v.samples) decoder.decode(new EncodedVideoChunk({type: s.key ? "key" : "delta", timestamp: Math.round(s.pts * 1e6), duration: Math.round(s.dur * 1e6), data: bytes.subarray(s.offset, s.offset + s.size)}));
    decoder.flush().then(resolve, reject);
  });
  g.fillStyle = "yellow";
  g.font = "18px sans-serif";
  best.forEach((b, i) => g.fillText((b.ts / 1e6).toFixed(2) + " s", (i % cols) * cellW + 6, Math.floor(i / cols) * cellH + 22));
  const blob = await sheet.convertToBlob({type: "image/jpeg", quality: 0.85});
  const saved = await (await fetch("/save?name=" + name, {method: "POST", body: blob})).text();
  document.getElementById("log").textContent = saved + " " + v.samples.length + " samples";
}
