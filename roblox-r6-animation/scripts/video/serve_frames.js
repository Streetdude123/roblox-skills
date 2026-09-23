const http = require("http"), fs = require("fs"), path = require("path");
const ROOT = path.resolve(process.argv[2] || ".");
const PORT = parseInt(process.argv[3] || "8790", 10);
const types = {".html": "text/html", ".js": "text/javascript", ".jpg": "image/jpeg", ".png": "image/png", ".txt": "text/plain", ".json": "application/json", ".mp4": "video/mp4", ".webm": "video/webm"};
http.createServer((req, res) => {
  const u = new URL(req.url, "http://x");
  if (req.method === "POST" && u.pathname === "/save") {
    const name = (u.searchParams.get("name") || "out.bin").replace(/[^a-z0-9_.-]/gi, "_");
    const chunks = [];
    req.on("data", (d) => chunks.push(d));
    req.on("end", () => {
      const buf = Buffer.concat(chunks);
      fs.writeFileSync(path.join(ROOT, "videos", name), buf);
      res.writeHead(200, {"Access-Control-Allow-Origin": "*"});
      res.end("saved " + buf.length);
    });
    return;
  }
  if (u.pathname === "/list") {
    const dir = path.join(ROOT, decodeURIComponent(u.searchParams.get("dir") || ""));
    res.writeHead(200, {"Content-Type": "application/json"});
    res.end(JSON.stringify(fs.existsSync(dir) ? fs.readdirSync(dir) : []));
    return;
  }
  const f = path.join(ROOT, decodeURIComponent(u.pathname));
  if (!f.startsWith(ROOT) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) {
    res.writeHead(404);
    res.end("no");
    return;
  }
  res.writeHead(200, {"Content-Type": types[path.extname(f)] || "application/octet-stream", "Cache-Control": "no-store"});
  fs.createReadStream(f).pipe(res);
}).listen(PORT, "127.0.0.1", () => console.log("up " + PORT + " " + ROOT));
