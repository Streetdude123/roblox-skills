const http = require("http");
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const out = path.resolve(process.argv[2]);
const port = Number(process.argv[3]);
fs.mkdirSync(out, { recursive: true });

const table = new Uint32Array(256);
for (let n = 0; n < 256; n++) {
  let c = n;
  for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
  table[n] = c >>> 0;
}
function crc(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = table[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}
function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length);
  const td = Buffer.concat([Buffer.from(type, "ascii"), data]);
  const c = Buffer.alloc(4);
  c.writeUInt32BE(crc(td));
  return Buffer.concat([len, td, c]);
}
function png(w, h, rgba) {
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(w, 0);
  ihdr.writeUInt32BE(h, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) {
    raw[y * (w * 4 + 1)] = 0;
    rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4);
  }
  return Buffer.concat([
    Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]),
    chunk("IHDR", ihdr),
    chunk("IDAT", zlib.deflateSync(raw, { level: 9 })),
    chunk("IEND", Buffer.alloc(0)),
  ]);
}
function smooth(a, b, x) {
  const t = Math.min(1, Math.max(0, (x - a) / (b - a)));
  return t * t * (3 - 2 * t);
}
function feather(w, h, rgba, e0, e1) {
  for (let y = 0; y < h; y++) {
    for (let x = 0; x < w; x++) {
      const u = (x + 0.5) / w - 0.5;
      const v = (y + 0.5) / h - 0.5;
      const d = Math.sqrt(u * u + v * v) * 2;
      const k = 1 - smooth(e0, e1, d);
      const i = (y * w + x) * 4 + 3;
      rgba[i] = Math.round(rgba[i] * k);
    }
  }
}

const parts = {};
http.createServer((req, res) => {
  const u = new URL(req.url, "http://x");
  if (req.method === "GET") {
    const file = path.join(out, path.basename(u.pathname));
    if (!fs.existsSync(file)) {
      res.writeHead(404);
      return res.end("missing");
    }
    res.writeHead(200, { "Content-Type": "image/png" });
    return res.end(fs.readFileSync(file));
  }
  let body = "";
  req.on("data", (c) => (body += c));
  req.on("end", () => {
    const name = u.searchParams.get("name");
    const i = Number(u.searchParams.get("i"));
    const n = Number(u.searchParams.get("n"));
    parts[name] = parts[name] || [];
    parts[name][i] = body;
    const got = parts[name].filter((p) => p !== undefined).length;
    if (got < n) {
      res.writeHead(200);
      return res.end("ok " + got);
    }
    const w = Number(u.searchParams.get("w"));
    const h = Number(u.searchParams.get("h"));
    const e0 = Number(u.searchParams.get("e0") || 0.72);
    const e1 = Number(u.searchParams.get("e1") || 0.97);
    const rgba = Buffer.from(parts[name].join(""), "base64");
    delete parts[name];
    if (rgba.length !== w * h * 4) {
      res.writeHead(500);
      return res.end("bad size " + rgba.length);
    }
    feather(w, h, rgba, e0, e1);
    fs.writeFileSync(path.join(out, name + ".png"), png(w, h, rgba));
    res.writeHead(200);
    res.end("saved " + name + ".png");
  });
}).listen(port, "127.0.0.1");
