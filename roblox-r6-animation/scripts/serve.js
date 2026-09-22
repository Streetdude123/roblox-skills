// a tiny local file server for the studio round trip
// GET  /stand/<Name>.lua  serves a module source from LUA_DIR so execute_luau can pull it with HttpService:GetAsync
// POST /put?name=<file>   writes the request body into OUT_DIR so ReadClips.lua can hand decoded clips to disk
// usage: node serve.js [OUT_DIR] [LUA_DIR] [PORT]
const http = require('http'), fs = require('fs'), path = require('path');
const OUT = path.resolve(process.argv[2] || './out');
const LUA = path.resolve(process.argv[3] || '.');
const PORT = parseInt(process.argv[4] || '8766', 10);
fs.mkdirSync(OUT, { recursive: true });
http.createServer((req, res) => {
  const u = new URL(req.url, 'http://x');
  if (u.pathname === '/put' && req.method === 'POST') {
    const name = (u.searchParams.get('name') || 'out.txt').replace(/[^a-z0-9_.-]/gi, '_');
    let body = '';
    req.on('data', d => body += d);
    req.on('end', () => { fs.writeFileSync(path.join(OUT, name), body); res.writeHead(200); res.end('ok ' + body.length); });
    return;
  }
  const m = u.pathname.match(/^\/stand\/([A-Za-z0-9_]+\.lua)$/);
  if (m) {
    const f = path.join(LUA, m[1]);
    if (!fs.existsSync(f)) { res.writeHead(404); res.end('no'); return; }
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(fs.readFileSync(f, 'utf8'));
    return;
  }
  res.writeHead(404); res.end();
}).listen(PORT, '127.0.0.1', () => console.log('up on ' + PORT + ' out=' + OUT + ' lua=' + LUA));
