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

# Ikoner tegnes kun, hvis de mangler
Add-Type -AssemblyName System.Drawing
function New-Icon([int]$size, [string]$name, [double]$scale) {
  $path = Join-Path $docs $name
  if (Test-Path $path) { return }
  $bmp = New-Object System.Drawing.Bitmap $size, $size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.Clear([System.Drawing.Color]::FromArgb(10, 95, 138))
  $white = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
  $s = $size * $scale; $o = ($size - $s) / 2
  $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::White), ($s * 0.07)
  $g.DrawArc($pen, [single]($o + $s * 0.34), [single]($o + $s * 0.14), [single]($s * 0.32), [single]($s * 0.36), 180, 180)
  $g.DrawLine($pen, [single]($o + $s * 0.34), [single]($o + $s * 0.32), [single]($o + $s * 0.34), [single]($o + $s * 0.45))
  $g.DrawLine($pen, [single]($o + $s * 0.66), [single]($o + $s * 0.32), [single]($o + $s * 0.66), [single]($o + $s * 0.45))
  $g.FillEllipse($white, [single]($o + $s * 0.22), [single]($o + $s * 0.34), [single]($s * 0.56), [single]($s * 0.54))
  $g.Dispose(); $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}
New-Icon 192 'icon-192.png' 1.0
New-Icon 512 'icon-512.png' 1.0
New-Icon 512 'icon-maskable.png' 0.7
Write-Output "Bygget version $version i $docs"
