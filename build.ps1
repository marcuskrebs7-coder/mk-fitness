# Bygger web-appen i docs\ ud fra kettlebell.html (kilden) og web\ (manifest, service worker).
# Kør:  powershell -File build.ps1   og push derefter - GitHub Pages udgiver docs\, og appen henter selv den nye version.
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$docs = Join-Path $root 'docs'
New-Item -ItemType Directory -Force $docs | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
$version = (Get-Date).ToString('yyyy.MM.dd-HHmm')

$body = [IO.File]::ReadAllText((Join-Path $root 'kettlebell.html'), $utf8).Replace('__VERSION__', $version)
$head = @'
<!doctype html>
<html lang="da">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#0a5f8a">
<link rel="manifest" href="manifest.webmanifest">
<link rel="icon" href="icon-192.png">
<link rel="apple-touch-icon" href="icon-192.png">
<style>:root{padding-top:env(safe-area-inset-top,0px);padding-bottom:env(safe-area-inset-bottom,0px)}body{margin:0}img{max-width:100%}[hidden]{display:none!important}</style>
</head>
<body>
'@
[IO.File]::WriteAllText((Join-Path $docs 'index.html'), $head + $body + "`n</body>`n</html>`n", $utf8)
[IO.File]::WriteAllText((Join-Path $docs 'version.json'), '{"v":"' + $version + '"}', $utf8)
Copy-Item (Join-Path $root 'web\sw.js'), (Join-Path $root 'web\manifest.webmanifest') $docs -Force
[IO.File]::WriteAllText((Join-Path $docs '.nojekyll'), '', $utf8)

# Ikon K "Stemplet": MK i en ring paa moerk bund. Tegnes forfra ved hvert byg.
Add-Type -AssemblyName System.Drawing
function New-Icon([int]$size, [string]$name, [double]$scale) {
  $path = Join-Path $docs $name
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'AntiAliasGridFit'
  $g.Clear([System.Drawing.Color]::FromArgb(21, 33, 43))
  $blue = [System.Drawing.Color]::FromArgb(77, 181, 230)
  $s = $size * $scale; $c = $size / 2
  $r1 = $s * 0.40; $r2 = $s * 0.345
  $pen1 = New-Object System.Drawing.Pen $blue, ([single]($s * 0.024))
  $pen2 = New-Object System.Drawing.Pen $blue, ([single]($s * 0.008))
  $g.DrawEllipse($pen1, [single]($c - $r1), [single]($c - $r1), [single]($r1 * 2), [single]($r1 * 2))
  $g.DrawEllipse($pen2, [single]($c - $r2), [single]($c - $r2), [single]($r2 * 2), [single]($r2 * 2))
  $fmt = New-Object System.Drawing.StringFormat
  $fmt.Alignment = 'Center'; $fmt.LineAlignment = 'Center'
  $f1 = New-Object System.Drawing.Font 'Segoe UI', ([single]($s * 0.27)), ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $f2 = New-Object System.Drawing.Font 'Segoe UI', ([single]($s * 0.075)), ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
  $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
  $bb = New-Object System.Drawing.SolidBrush $blue
  $g.DrawString('MK', $f1, $white, [single]$c, [single]($c - $s * 0.035), $fmt)
  $g.DrawString('f i t n e s s', $f2, $bb, [single]$c, [single]($c + $s * 0.19), $fmt)
  $g.Dispose(); $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
New-Icon 192 'icon-192.png' 1.0
New-Icon 512 'icon-512.png' 1.0
New-Icon 512 'icon-maskable.png' 0.72
Write-Output "Bygget version $version i $docs"
