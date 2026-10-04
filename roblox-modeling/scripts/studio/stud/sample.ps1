param([string]$img, [string]$points)
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile($img)
foreach ($p in $points.Split(";")) {
  $parts = $p.Split(",")
  $name = $parts[0]
  $cx = [int]$parts[1]
  $cy = [int]$parts[2]
  $r = 0; $gg = 0; $b = 0; $n = 0
  for ($x = $cx - 4; $x -le $cx + 4; $x++) {
    for ($y = $cy - 4; $y -le $cy + 4; $y++) {
      if ($x -ge 0 -and $y -ge 0 -and $x -lt $bmp.Width -and $y -lt $bmp.Height) {
        $c = $bmp.GetPixel($x, $y)
        $r += $c.R; $gg += $c.G; $b += $c.B; $n++
      }
    }
  }
  "{0,-14} {1,3} {2,3} {3,3}" -f $name, [int]($r / $n), [int]($gg / $n), [int]($b / $n)
}
$bmp.Dispose()
