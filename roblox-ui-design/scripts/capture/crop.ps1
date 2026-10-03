param([string]$src, [string]$out, [int]$x0 = 297, [int]$y0 = 166, [int]$x1 = 1452, [int]$y1 = 818)
Add-Type -AssemblyName System.Drawing
$bmp = [System.Drawing.Bitmap]::FromFile($src)
$rect = New-Object System.Drawing.Rectangle 0, 0, $bmp.Width, $bmp.Height
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadOnly, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$stride = $data.Stride
$bytes = New-Object byte[] ($stride * $bmp.Height)
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $bytes, 0, $bytes.Length)
$bmp.UnlockBits($data)
function px($x, $y) { $i = $y * $stride + $x * 4; return @($bytes[$i + 2], $bytes[$i + 1], $bytes[$i]) }
$bg = px ($x0 + 3) ($y0 + 3)
function isfg($x, $y) { $c = px $x $y; return ([math]::Abs($c[0] - $bg[0]) + [math]::Abs($c[1] - $bg[1]) + [math]::Abs($c[2] - $bg[2])) -gt 24 }
$top = $y0; while ($top -lt $y1) { $hit = $false; for ($x = $x0; $x -lt $x1; $x += 3) { if (isfg $x $top) { $hit = $true; break } }; if ($hit) { break }; $top++ }
$bot = $y1; while ($bot -gt $top) { $hit = $false; for ($x = $x0; $x -lt $x1; $x += 3) { if (isfg $x $bot) { $hit = $true; break } }; if ($hit) { break }; $bot-- }
$left = $x0; while ($left -lt $x1) { $hit = $false; for ($y = $top; $y -lt $bot; $y += 3) { if (isfg $left $y) { $hit = $true; break } }; if ($hit) { break }; $left++ }
$right = $x1; while ($right -gt $left) { $hit = $false; for ($y = $top; $y -lt $bot; $y += 3) { if (isfg $right $y) { $hit = $true; break } }; if ($hit) { break }; $right-- }
$w = $right - $left + 1
$h = $bot - $top + 1
$crop = $bmp.Clone((New-Object System.Drawing.Rectangle $left, $top, $w, $h), $bmp.PixelFormat)
$bmp.Dispose()
$crop.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$crop.Dispose()
"crop $left,$top ${w}x$h"
