const http = require('http'), fs = require('fs'), path = require('path');
const dir = path.resolve(process.argv[2] || '.');
const port = +(process.argv[3] || 8124);
http.createServer((req, res) => {
  const u = new URL(req.url, 'http://x');
  const p = decodeURIComponent(u.pathname);
  res.setHeader('Access-Control-Allow-Origin', '*');
  if (p === '/list') {
    const files = fs.readdirSync(dir).filter(f => /\.(mp3|ogg|wav)$/i.test(f)).sort();
    res.writeHead(200, {'Content-Type': 'application/json'});
    return res.end(JSON.stringify(files));
  }
  if (p === '/relay.html') {
    res.writeHead(200, {'Content-Type': 'text/html'});
    return res.end('<!doctype html><title>relay</title><body>relay</body>');
  }
  const f = path.join(dir, p);
  if (!f.startsWith(dir) || !fs.existsSync(f) || fs.statSync(f).isDirectory()) {
    res.writeHead(404);
    return res.end();
  }
  res.writeHead(200, {'Content-Type': 'application/octet-stream'});
  fs.createReadStream(f).pipe(res);
}).listen(port, '127.0.0.1', () => console.log('up ' + port + ' ' + dir));
