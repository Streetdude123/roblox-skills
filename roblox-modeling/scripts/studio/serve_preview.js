const http = require("http")
const fs = require("fs")
const path = require("path")

const dir = process.argv[2]
const port = Number(process.argv[3] || 8768)
const chunk = 512 * 1024
const cache = {}

function load(name) {
  if (!cache[name]) {
    const buf = fs.readFileSync(path.join(dir, path.basename(name)))
    cache[name] = name.endsWith(".json") ? buf.toString("utf8") : buf.toString("base64")
  }
  return cache[name]
}

http.createServer((req, res) => {
  const url = new URL(req.url, "http://localhost")
  const name = decodeURIComponent(url.pathname.slice(3))
  try {
    const body = load(name)
    if (url.pathname.startsWith("/n/")) {
      res.end(String(Math.ceil(body.length / chunk)))
    } else {
      const k = Number(url.searchParams.get("part") || 0)
      res.end(body.slice(k * chunk, (k + 1) * chunk))
    }
  } catch (e) {
    res.statusCode = 404
    res.end("missing " + name)
  }
}).listen(port, "127.0.0.1")
console.log("serving " + dir + " on " + port)
