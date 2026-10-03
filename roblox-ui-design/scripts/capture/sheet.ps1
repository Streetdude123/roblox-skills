param([string]$out, [string]$title, [string[]]$files, [string[]]$labels, [int]$cell = 900)
Add-Type -AssemblyName System.Drawing
$cols = 2
$rows = [math]::Ceiling($files.Count / $cols)
$imgs = @()
foreach ($f in $files) { $imgs += [System.Drawing.Image]::FromFile($f) }
$heights = @()
for ($r = 0; $r -lt $rows; $r++) {
  $h = 0
  for ($c = 0; $c -lt $cols; $c++) {
    $i = $r * $cols + $c
    if ($i -lt $imgs.Count) { $h = [math]::Max($h, [int]($imgs[$i].Height * $cell / $imgs[$i].Width)) }
  }
  $heights += $h
}
$pad = 24
$head = 64
$lab = 34
$W = $cols * $cell + ($cols + 1) * $pad
$H = $head + ($heights | Measure-Object -Sum).Sum + $rows * ($lab + $pad) + $pad
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.Clear([System.Drawing.Color]::FromArgb(18, 18, 22))
$white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(240, 240, 240))
$grey = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(160, 160, 170))
$big = New-Object System.Drawing.Font "Segoe UI Semibold", 22
$small = New-Object System.Drawing.Font "Segoe UI", 13
$g.DrawString($title, $big, $white, $pad, 16)
$y = $head
for ($r = 0; $r -lt $rows; $r++) {
  for ($c = 0; $c -lt $cols; $c++) {
    $i = $r * $cols + $c
    if ($i -ge $imgs.Count) { continue }
    $x = $pad + $c * ($cell + $pad)
    $g.DrawString($labels[$i], $small, $grey, $x, $y + 4)
    $h = [int]($imgs[$i].Height * $cell / $imgs[$i].Width)
    $g.DrawImage($imgs[$i], $x, $y + $lab, $cell, $h)
  }
  $y += $lab + $heights[$r] + $pad
}
$g.Dispose()
foreach ($im in $imgs) { $im.Dispose() }
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
"sheet ${W}x${H}"
