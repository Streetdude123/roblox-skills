param([string]$dir, [string]$frames, [string]$out, [int]$cols = 2, [int]$w = 720)
Add-Type -AssemblyName System.Drawing
$list = $frames.Split(",") | ForEach-Object { [int]$_ }
$first = [System.Drawing.Image]::FromFile((Join-Path $dir ("f{0:D5}.jpg" -f $list[0])))
$h = [int]($w * $first.Height / $first.Width)
$first.Dispose()
$rows = [math]::Ceiling($list.Count / $cols)
$bmp = New-Object System.Drawing.Bitmap ($w * $cols), ($h * $rows)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = "HighQualityBilinear"
$font = New-Object System.Drawing.Font "Arial", 14
for ($i = 0; $i -lt $list.Count; $i++) {
  $img = [System.Drawing.Image]::FromFile((Join-Path $dir ("f{0:D5}.jpg" -f $list[$i])))
  $x = ($i % $cols) * $w; $y = [math]::Floor($i / $cols) * $h
  $g.DrawImage($img, $x, $y, $w, $h)
  $g.DrawString("#" + $list[$i], $font, [System.Drawing.Brushes]::Yellow, $x + 6, $y + 4)
  $img.Dispose()
}
$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$g.Dispose(); $bmp.Dispose()
"saved $out"
