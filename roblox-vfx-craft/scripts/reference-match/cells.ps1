param([string]$mine)
Add-Type -AssemblyName System.Drawing
$ref = [System.Drawing.Bitmap]::FromFile("C:\Users\vietb\.claude\uploads\5b9de98d-9717-4290-b4e5-cbd2ba9e0056\9dc18469-image.png")
$me = [System.Drawing.Bitmap]::FromFile($mine)
function Mean($b, $x0, $y0, $w, $h) {
  $sr = 0; $sg = 0; $sb = 0; $n = 0
  for ($y = $y0; $y -lt $y0 + $h; $y += 3) { for ($x = $x0; $x -lt $x0 + $w; $x += 3) { $p = $b.GetPixel($x, $y); $sr += $p.R; $sg += $p.G; $sb += $p.B; $n++ } }
  @([int]($sr / $n), [int]($sg / $n), [int]($sb / $n))
}
$x0 = 420; $y0 = 80; $cw = 80; $ch = 90
for ($j = 0; $j -lt 6; $j++) {
  $row = @()
  for ($i = 0; $i -lt 6; $i++) {
    $a = Mean $ref ($x0 + $i * $cw) ($y0 + $j * $ch) $cw $ch
    $b = Mean $me ($x0 + $i * $cw) ($y0 + $j * $ch) $cw $ch
    $row += ("{0},{1},{2}>{3},{4},{5}" -f $a[0], $a[1], $a[2], $b[0], $b[1], $b[2])
  }
  "y$($y0 + $j * $ch): " + ($row -join " | ")
}
