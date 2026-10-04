param([string]$json, [string]$out, [string]$title = "", [int]$x0 = -280, [int]$x1 = 280, [int]$z0 = -130, [int]$z1 = 130, [int]$scale = 3)
Add-Type -AssemblyName System.Drawing
$rows = Get-Content $json -Raw | ConvertFrom-Json
$W = ($x1 - $x0) * $scale
$H = ($z1 - $z0) * $scale + 40
$bmp = New-Object System.Drawing.Bitmap $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(24, 60, 90))
$font = New-Object System.Drawing.Font "Segoe UI", 9
$big = New-Object System.Drawing.Font "Segoe UI", 13, ([System.Drawing.FontStyle]::Bold)
function col($name, $grp) {
  switch -regex ($name) {
    "^Teleport" { return @(150, 90, 230) }
    "Shopkeeper|Merchant" { return @(220, 60, 60) }
    "SpawnLocation" { return @(255, 255, 255) }
    "Lamp" { return @(255, 220, 60) }
    "Fireflies" { return @(255, 255, 140) }
    "Path|Stone$|entrance" { return @(170, 120, 70) }
    "Tree|Bush|Grass" { return @(60, 170, 70) }
    "Flower" { return @(240, 130, 200) }
    "Rock|rock" { return @(110, 110, 120) }
    "Baseplate|cylinder|^Part$" { return @(90, 100, 80) }
    default { return @(200, 200, 200) }
  }
}
$order = @()
foreach ($r in $rows) { $order += ,$r }
$sorted = $order | Sort-Object { - ($_[4] * $_[5]) }
foreach ($r in $sorted) {
  $name = $r[1]
  if ($name -eq "Model" -and $r[4] -gt 150) { continue }
  $c = col $name $r[0]
  $x = ($r[2] - $r[4] / 2 - $x0) * $scale
  $z = ($r[3] - $r[5] / 2 - $z0) * $scale + 40
  $w = [math]::Max(2, $r[4] * $scale)
  $h = [math]::Max(2, $r[5] * $scale)
  $alpha = 200
  if ($name -match "Baseplate|cylinder|^Part$") { $alpha = 90 }
  $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alpha, $c[0], $c[1], $c[2]))
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 20, 20, 20)), 1
  if ($name -match "Tree|Flower|Rock|rock|Bush|Grass") {
    $g.FillEllipse($brush, $x, $z, $w, $h)
  } else {
    $g.FillRectangle($brush, $x, $z, $w, $h)
    $g.DrawRectangle($pen, $x, $z, $w, $h)
  }
  if ($name -notmatch "Tree|Flower|Rock|rock|Bush|Grass|Stone$|^Part$|cylinder|Baseplate|Lamp|happi") {
    $g.DrawString($name, $font, [System.Drawing.Brushes]::White, $x + 2, $z + 2)
  }
}
$axis = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 255, 255, 255)), 1
for ($gx = [math]::Ceiling($x0 / 50) * 50; $gx -le $x1; $gx += 50) { $px = ($gx - $x0) * $scale; $g.DrawLine($axis, $px, 40, $px, 46); $g.DrawString("x$gx", $font, [System.Drawing.Brushes]::White, $px + 2, 44) }
for ($gz = [math]::Ceiling($z0 / 50) * 50; $gz -le $z1; $gz += 50) { $pz = ($gz - $z0) * $scale + 40; $g.DrawLine($axis, 0, $pz, 6, $pz); $g.DrawString("z$gz", $font, [System.Drawing.Brushes]::White, 6, $pz + 2) }
$g.DrawString($title, $big, [System.Drawing.Brushes]::White, 8, 8)
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"plan ${W}x${H}"
