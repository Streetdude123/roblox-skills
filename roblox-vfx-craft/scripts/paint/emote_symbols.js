function canvas(n) {
  const c = document.createElement("canvas");
  c.width = n;
  c.height = n;
  return c;
}

function paintAnger(n = 256) {
  const c = canvas(n);
  const g = c.getContext("2d");
  const k = n / 256;
  const C = n / 2;
  g.lineCap = "round";
  g.lineJoin = "round";
  function vein(sx, sy, width, color, dx = 0, dy = 0) {
    g.strokeStyle = color;
    g.lineWidth = width * k;
    g.beginPath();
    g.moveTo(C + (sx * 30 + dx) * k, C + (sy * 100 + dy) * k);
    g.quadraticCurveTo(C + (sx * 26 + dx) * k, C + (sy * 26 + dy) * k, C + (sx * 100 + dx) * k, C + (sy * 30 + dy) * k);
    g.stroke();
  }
  const quads = [[-1, -1], [1, -1], [-1, 1], [1, 1]];
  for (const [sx, sy] of quads) vein(sx, sy, 44, "rgb(105, 0, 12)");
  for (const [sx, sy] of quads) vein(sx, sy, 28, "rgb(232, 28, 40)");
  for (const [sx, sy] of quads) vein(sx, sy, 7, "rgba(255, 130, 130, 0.9)", -sx * 3, -sy * 3);
  return c;
}

function paintExclaim(n = 256) {
  const c = canvas(n);
  const g = c.getContext("2d");
  g.scale(n / 256, n / 256);
  g.lineJoin = "round";
  g.lineCap = "round";
  function bar() {
    g.beginPath();
    g.moveTo(90, 26);
    g.quadraticCurveTo(128, 8, 166, 26);
    g.lineTo(150, 162);
    g.quadraticCurveTo(128, 176, 106, 162);
    g.closePath();
  }
  function dot() {
    g.beginPath();
    g.arc(128, 212, 25, 0, Math.PI * 2);
  }
  const fill = g.createLinearGradient(0, 10, 0, 240);
  fill.addColorStop(0, "rgb(255, 226, 96)");
  fill.addColorStop(1, "rgb(245, 156, 28)");
  for (const shape of [bar, dot]) {
    shape();
    g.strokeStyle = "rgb(74, 34, 0)";
    g.lineWidth = 16;
    g.stroke();
    g.fillStyle = fill;
    g.fill();
  }
  g.strokeStyle = "rgba(255, 252, 225, 0.85)";
  g.lineWidth = 7;
  g.beginPath();
  g.moveTo(100, 36);
  g.lineTo(112, 140);
  g.stroke();
  g.beginPath();
  g.arc(120, 206, 9, Math.PI * 1.05, Math.PI * 1.55);
  g.stroke();
  return c;
}

async function savePng(c, name) {
  const blob = await new Promise((r) => c.toBlob(r, "image/png"));
  const res = await fetch("/save?name=" + encodeURIComponent(name), {method: "POST", body: blob});
  return res.text();
}
