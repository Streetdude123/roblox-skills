param([string]$out = '.')
Add-Type -AssemblyName System.Drawing
$k = 8
$icons = @{
  'px_heart' = @(
    '.XXX...XXX.',
    'XXXXX.XXXXX',
    'XXXXXXXXXXX',
    'XXXXXXXXXXX',
    'XXXXXXXXXXX',
    '.XXXXXXXXX.',
    '..XXXXXXX..',
    '...XXXXX...',
    '....XXX....',
    '.....X.....')
  'px_star' = @(
    '....X....',
    '....X....',
    '...XXX...',
    'XXXXXXXXX',
    '.XXXXXXX.',
    '..XXXXX..',
    '..XX.XX..',
    '.XX...XX.',
    '.X.....X.')
  'px_lock' = @(
    '..XXXXX..',
    '.XX...XX.',
    '.X.....X.',
    'XXXXXXXXX',
    'XXXXXXXXX',
    'XXXX.XXXX',
    'XXXX.XXXX',
    'XXXXXXXXX',
    'XXXXXXXXX')
  'px_check' = @(
    '........X',
    '.......XX',
    '......XX.',
    'X....XX..',
    'XX..XX...',
    '.XXXX....',
    '..XX.....')
  'px_bolt' = @(
    '.....XX..',
    '....XX...',
    '...XX....',
    '..XXXXX..',
    '.....XX..',
    '....XX...',
    '...XX....',
    '..XX.....',
    '.XX......')
  'px_shield' = @(
    'XXXXXXXXX',
    'XXXXXXXXX',
    'XXXXXXXXX',
    'XXXXXXXXX',
    '.XXXXXXX.',
    '.XXXXXXX.',
    '..XXXXX..',
    '...XXX...',
    '....X....')
  'px_plus' = @(
    '...XXX...',
    '...XXX...',
    '...XXX...',
    'XXXXXXXXX',
    'XXXXXXXXX',
    'XXXXXXXXX',
    '...XXX...',
    '...XXX...',
    '...XXX...')
  'px_bone' = @(
    '.XX.....XX.',
    'XXXX...XXXX',
    '.XXXXXXXXX.',
    'XXXX...XXXX',
    '.XX.....XX.')
  'px_gear' = @(
    '....XXX....',
    '.X..XXX..X.',
    '.XXXXXXXXX.',
    '..XXX.XXX..',
    'XXXX...XXXX',
    'XXX.....XXX',
    'XXXX...XXXX',
    '..XXX.XXX..',
    '.XXXXXXXXX.',
    '.X..XXX..X.',
    '....XXX....')
}
foreach ($name in $icons.Keys) {
  $rows = $icons[$name]
  $h = $rows.Count
  $w = $rows[0].Length
  $bmp = New-Object System.Drawing.Bitmap ($w * $k), ($h * $k), ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::Transparent)
  $b = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
  for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
      if ($rows[$y][$x] -eq 'X') { $g.FillRectangle($b, $x * $k, $y * $k, $k, $k) }
    }
  }
  $g.Dispose()
  $bmp.Save((Join-Path $out "$name.png"), [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  "$name ${w}x${h}"
}
