const http = require("http");
const fs = require("fs");
const path = require("path");
const dir = __dirname;
const port = Number(process.argv[2] || 8781);
http.createServer((req, res) => {
	const name = path.basename(decodeURIComponent(req.url.split("?")[0]));
	const file = path.join(dir, name);
	if (!fs.existsSync(file)) { res.writeHead(404); res.end(); return; }
	res.writeHead(200, { "Content-Type": "image/png" });
	fs.createReadStream(file).pipe(res);
}).listen(port, "127.0.0.1", () => console.log("serving " + dir + " on " + port));
