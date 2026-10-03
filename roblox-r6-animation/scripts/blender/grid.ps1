param([string]$dir, [string]$out, [int]$cols = 6, [string]$filter = "*.png", [int]$cell = 300)
Add-Type -AssemblyName System.Drawing
$files = Get-ChildItem $dir -Filter $filter | Sort-Object Name
$rows = [math]::Ceiling($files.Count / $cols)
$bmp = New-Object Drawing.Bitmap ($cols * $cell), ($rows * $cell)
$g = [Drawing.Graphics]::FromImage($bmp)
$g.Clear([Drawing.Color]::Black)
$g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$font = New-Object Drawing.Font "Arial", 13, ([Drawing.FontStyle]::Bold)
$i = 0
foreach ($f in $files) {
  $img = [Drawing.Image]::FromFile($f.FullName)
  $x = ($i % $cols) * $cell; $y = [math]::Floor($i / $cols) * $cell
  $g.DrawImage($img, $x, $y, $cell, $cell)
  $img.Dispose()
  $g.DrawString(($f.BaseName -replace '^\d+_', ''), $font, [Drawing.Brushes]::Yellow, $x + 4, $y + 4)
  $i++
}
$bmp.Save($out, [Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose()
"grid $($files.Count) -> $out"
