Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'
$empresa = Split-Path -Parent $PSScriptRoot
$root = Join-Path $empresa 'assets\originais'
$assets = Join-Path $empresa 'assets'
New-Item -ItemType Directory -Force -Path $assets | Out-Null

$black = [System.Drawing.Color]::FromArgb(0, 0, 0)
$white = [System.Drawing.Color]::White
$muted = [System.Drawing.Color]::FromArgb(148, 148, 148)
$blue = [System.Drawing.Color]::FromArgb(12, 111, 233)

function New-Canvas([int] $width, [int] $height) {
  $bitmap = [System.Drawing.Bitmap]::new($width, $height)
  $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
  $graphics.Clear($black)
  $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  return @{ Bitmap = $bitmap; Graphics = $graphics }
}

function Save-Canvas($canvas, [string] $name) {
  $canvas.Graphics.Dispose()
  $canvas.Bitmap.Save((Join-Path $assets $name), [System.Drawing.Imaging.ImageFormat]::Png)
  $canvas.Bitmap.Dispose()
}

function New-Photo([string] $source, [string] $name) {
  $canvas = New-Canvas 136 136
  $g = $canvas.Graphics
  $g.FillRectangle([System.Drawing.SolidBrush]::new($white), 24, 15, 108, 108)
  $photo = [System.Drawing.Image]::FromFile($source)
  $g.DrawImage($photo, [System.Drawing.Rectangle]::new(30, 21, 96, 96))
  $photo.Dispose()
  Save-Canvas $canvas $name
}

function New-Header([string] $name, [string] $role, [string] $output) {
  $canvas = New-Canvas 310 60
  $g = $canvas.Graphics
  $g.FillRectangle([System.Drawing.SolidBrush]::new($blue), 0, 7, 24, 2)
  $nameFont = [System.Drawing.Font]::new('Segoe UI', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
  $roleFont = [System.Drawing.Font]::new('Segoe UI', 8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
  $whiteBrush = [System.Drawing.SolidBrush]::new($white)
  $mutedBrush = [System.Drawing.SolidBrush]::new($muted)
  $g.DrawString($name, $nameFont, $whiteBrush, 0, 16)
  $g.DrawString($role.ToUpperInvariant(), $roleFont, $mutedBrush, 0, 43)
  $nameFont.Dispose(); $roleFont.Dispose(); $whiteBrush.Dispose(); $mutedBrush.Dispose()
  Save-Canvas $canvas $output
}

function New-ContactRow([string] $icon, [string] $text, [string] $output, [int] $height = 25) {
  $canvas = New-Canvas 310 $height
  $g = $canvas.Graphics
  $image = [System.Drawing.Image]::FromFile((Join-Path $root $icon))
  $g.DrawImage($image, [System.Drawing.Rectangle]::new(0, 4, 16, 16))
  $font = [System.Drawing.Font]::new('Segoe UI', 9.75, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
  $brush = [System.Drawing.SolidBrush]::new($white)
  $g.DrawString($text, $font, $brush, 26, 3)
  $image.Dispose(); $font.Dispose(); $brush.Dispose()
  Save-Canvas $canvas $output
}

function New-Separator {
  $canvas = New-Canvas 2 136
  $canvas.Graphics.FillRectangle([System.Drawing.SolidBrush]::new($blue), 0, 28, 2, 80)
  Save-Canvas $canvas 'separador.png'
}

function New-Logo {
  $canvas = New-Canvas 194 136
  $logo = [System.Drawing.Image]::FromFile((Join-Path $root 'logo-inovathings-brasil-branco.png'))
  $canvas.Graphics.DrawImage($logo, [System.Drawing.Rectangle]::new(27, 38, 140, 59))
  $logo.Dispose()
  Save-Canvas $canvas 'logo.png'
}

New-Photo (Join-Path $root 'charles-bird-quadrada.jpg') 'charles-foto.png'
New-Photo (Join-Path $root 'daniel-quadrada.jpg') 'daniel-foto.png'
New-Header 'Charles Altair' 'Diretor Comercial' 'charles-cabecalho.png'
New-Header 'Daniel Nobre' ('Diretor T' + [char]0x00E9 + 'cnico') 'daniel-cabecalho.png'
New-ContactRow 'ic-tel.png' '+55 (61) 98179-5356' 'charles-telefone.png'
New-ContactRow 'ic-email.png' 'comercial@inovathingsbrasil.com.br' 'charles-email.png'
New-ContactRow 'ic-cnpj.png' 'CNPJ 65.301.520/0001-80' 'cnpj.png' 26
New-ContactRow 'ic-tel.png' '+55 (61) 98220-0488' 'daniel-telefone.png'
New-ContactRow 'ic-email.png' 'solucoes@inovathingsbrasil.com.br' 'daniel-email.png'
New-Separator
New-Logo
Write-Host "Assets gerados em $assets"
