$ErrorActionPreference = 'Stop'
$empresa = Split-Path -Parent $PSScriptRoot
$chrome = 'C:\Program Files\Google\Chrome\Application\chrome.exe'
if (-not (Test-Path -LiteralPath $chrome)) { $chrome = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
if (-not (Test-Path -LiteralPath $chrome)) { throw 'Chrome ou Microsoft Edge não encontrado.' }

$svg = Join-Path $empresa 'fontes\assinatura-pabline.svg'
$png = Join-Path $empresa 'assets\assinatura-pabline.png'
& $chrome --headless --disable-gpu --screenshot=$png --window-size=1400,600 "file:///$($svg -replace '\\','/')"
if (-not (Test-Path -LiteralPath $png)) { throw 'Não foi possível gerar o PNG da assinatura.' }
Write-Host "Preview gerado: $png"
