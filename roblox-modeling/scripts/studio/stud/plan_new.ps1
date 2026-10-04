param([string]$out)
Add-Type -AssemblyName System.Drawing
$x0 = -150; $x1 = 160; $z0 = -120; $z1 = 120; $k = 4
$W0 = ($x1 - $x0) * $k
$H0 = ($z1 - $z0) * $k + 70
$bmp = New-Object System.Drawing.Bitmap $W0, $H0
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(40, 150, 190))
$font = New-Object System.Drawing.Font "Segoe UI", 10, ([System.Drawing.FontStyle]::Bold)
$small = New-Object System.Drawing.Font "Segoe UI", 9
$big = New-Object System.Drawing.Font "Segoe UI", 15, ([System.Drawing.FontStyle]::Bold)
$items = @(
  @("Meadow (ground, y 0)", 95, 0, 110, 160, 95, 185, 85, 0, 1, 8, -70),
  @("Village plateau (y +8, studded dirt cliffs)", -33, 0, 154, 200, 70, 165, 75, 0, 1, -105, -95),
  @("Square (studded paving)", -20, 0, 124, 124, 190, 150, 110, 1, 0, 0, 0),
  @("Statue", -20, 0, 30, 26, 200, 200, 205, 0, 1, -10, -6),
  @("Portal 1", -21, -49, 35, 35, 150, 90, 230, 1, 1, -16, -4),
  @("Portal 2", -56, -31, 35, 35, 150, 90, 230, 1, 1, -16, -4),
  @("Portal 3", -57, 29, 35, 35, 150, 90, 230, 1, 1, -16, -4),
  @("Portal 4", -20, 48, 35, 35, 150, 90, 230, 1, 1, -16, -4),
  @("Stairs", 42, -16, 16, 12, 110, 80, 60, 0, 1, -8, -6),
  @("Stairs", 42, 16, 16, 12, 110, 80, 60, 0, 1, -8, -6),
  @("Mushroom", 54, 0, 5, 5, 220, 50, 60, 1, 1, -6, -13),
  @("Big tree", 28, 0, 14, 14, 30, 120, 55, 1, 1, -10, 8),
  @("Round stone tower", 30, 50, 24, 24, 110, 120, 145, 1, 1, -22, 13),
  @("Timber house", 30, -48, 20, 16, 230, 220, 200, 0, 1, -24, -22),
  @("Shop", 14, -26, 15, 20, 220, 60, 60, 0, 1, -6, -4),
  @("Tall timber tower", -98, 0, 16, 16, 230, 220, 200, 0, 1, -30, -22),
  @("Timber tower", -92, -78, 14, 14, 230, 220, 200, 0, 1, -24, -20),
  @("Timber tower", -92, 78, 14, 14, 230, 220, 200, 0, 1, -24, 10),
  @("Timber house", -45, -88, 22, 16, 230, 220, 200, 0, 1, -24, -20),
  @("Timber house", -45, 88, 22, 16, 230, 220, 200, 0, 1, -24, 10),
  @("Training yard (watch tower, dummies, targets, rack)", 10, 80, 50, 34, 160, 130, 90, 0, 1, -24, 18),
  @("His tree tunnel path (55 studs, lanterns, fireflies)", 87, 0, 55, 12, 170, 120, 70, 0, 1, -30, 8),
  @("Fireflies", 90, 0, 70, 60, 255, 255, 140, 0, 0, 0, 0),
  @("Pond", 92, -45, 22, 16, 60, 200, 230, 1, 1, -12, -10),
  @("Wheat field", 92, 45, 36, 26, 230, 200, 110, 0, 1, -16, -8),
  @("Spawn", 122, 0, 12, 12, 255, 255, 255, 0, 1, -14, -22)
)
foreach ($it in $items) {
  $px = ($it[1] - $it[3] / 2 - $x0) * $k
  $pz = ($it[2] - $it[4] / 2 - $z0) * $k + 70
  $pw = $it[3] * $k
  $ph = $it[4] * $k
  $alpha = 225
  if ($it[0] -eq "Fireflies") { $alpha = 35 }
  $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb($alpha, $it[5], $it[6], $it[7]))
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(230, 20, 20, 20)), 2
  if ($it[8] -eq 1) { $g.FillEllipse($brush, $px, $pz, $pw, $ph); $g.DrawEllipse($pen, $px, $pz, $pw, $ph) }
  else { $g.FillRectangle($brush, $px, $pz, $pw, $ph); $g.DrawRectangle($pen, $px, $pz, $pw, $ph) }
}
foreach ($it in $items) {
  if ($it[9] -eq 1) {
    $lx = ($it[1] + $it[10] - $x0) * $k
    $lz = ($it[2] + $it[11] - $z0) * $k + 70
    $g.DrawString($it[0], $font, [System.Drawing.Brushes]::Black, $lx + 1, $lz + 1)
    $g.DrawString($it[0], $font, [System.Drawing.Brushes]::White, $lx, $lz)
  }
}
$lantern = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 230, 60))
foreach ($lx in 64, 78, 92, 106) { foreach ($lz in -8, 8) { $g.FillEllipse($lantern, ($lx - $x0) * $k - 5, ($lz - $z0) * $k + 70 - 5, 10, 10) } }
$arrow = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(255, 255, 255, 255)), 3
$arrow.EndCap = [System.Drawing.Drawing2D.LineCap]::ArrowAnchor
$g.DrawLine($arrow, (116 - $x0) * $k, (-2 - $z0) * $k + 70, (52 - $x0) * $k, (-2 - $z0) * $k + 70)
$g.DrawString("Lobby plan v1 - stud village (reference 1). East is right.", $big, [System.Drawing.Brushes]::White, 10, 6)
$g.DrawString("Spawn -> your tree tunnel (shorter) -> two stud stairs up the cliff -> square with the 4 portals around the statue.", $small, [System.Drawing.Brushes]::White, 12, 32)
$g.DrawString("1 grid = 10 studs. Spawn to nearest portal about 150 studs (now 210-245). Cube trees ring the plateau edge; fences on the cliff tops; lamp posts around the square.", $small, [System.Drawing.Brushes]::White, 12, 48)
$grid = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(40, 255, 255, 255)), 1
for ($gx = $x0; $gx -le $x1; $gx += 10) { $g.DrawLine($grid, ($gx - $x0) * $k, 70, ($gx - $x0) * $k, $H0) }
for ($gz = $z0; $gz -le $z1; $gz += 10) { $g.DrawLine($grid, 0, ($gz - $z0) * $k + 70, $W0, ($gz - $z0) * $k + 70) }
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"plan ${W0}x${H0}"
