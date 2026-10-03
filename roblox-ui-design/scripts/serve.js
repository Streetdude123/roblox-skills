const http = require('http'), fs = require('fs'), path = require('path');
const OUT = path.resolve(process.argv[2] || './out');
const SRC = path.resolve(process.argv[3] || __dirname);
const PORT = parseInt(process.argv[4] || '8775', 10);
fs.mkdirSync(OUT, { recursive: true });
const types = { '.png': 'image/png', '.html': 'text/html; charset=utf-8', '.lua': 'text/plain; charset=utf-8', '.json': 'application/json', '.svg': 'image/svg+xml' };
const send = (res, f) => {
  if (!fs.existsSync(f)) { res.writeHead(404); res.end('no'); return; }
  res.writeHead(200, { 'Content-Type': types[path.extname(f)] || 'application/octet-stream', 'Access-Control-Allow-Origin': '*' });
  res.end(fs.readFileSync(f));
};
http.createServer((req, res) => {
  const u = new URL(req.url, 'http://x');
  if (u.pathname === '/put' && req.method === 'POST') {
    const name = (u.searchParams.get('name') || 'out.txt').replace(/[^a-z0-9_.-]/gi, '_');
    const chunks = [];
    req.on('data', d => chunks.push(d));
    req.on('end', () => {
      let body = Buffer.concat(chunks);
      const s = body.toString('utf8', 0, Math.min(body.length, 64));
      if (s.startsWith('data:')) body = Buffer.from(body.toString('utf8').split(',')[1], 'base64');
      fs.writeFileSync(path.join(OUT, name), body);
      res.writeHead(200, { 'Access-Control-Allow-Origin': '*' });
      res.end('ok ' + body.length);
    });
    return;
  }
  let m = u.pathname.match(/^\/src\/((?:examples\/)?[A-Za-z0-9_]+\.lua)$/);
  if (m) return send(res, path.join(SRC, m[1]));
  m = u.pathname.match(/^\/out\/([A-Za-z0-9_.-]+)$/);
  if (m) return send(res, path.join(OUT, m[1]));
  m = u.pathname.match(/^\/([A-Za-z0-9_-]+\.html)$/);
  if (m) return send(res, path.join(SRC, m[1]));
  res.writeHead(404); res.end();
}).listen(PORT, '127.0.0.1', () => console.log('up on ' + PORT + ' out=' + OUT + ' src=' + SRC));
