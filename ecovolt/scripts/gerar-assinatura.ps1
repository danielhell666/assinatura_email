# Gera a assinatura de uma pessoa: preenche modelos/arte.html, captura a arte em 2x
# com o Chrome (ou Edge) sem janela e cria o HTML com a imagem unica e o link do site.
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $Nome,
  [Parameter(Mandatory)] [string] $Cargo,
  [Parameter(Mandatory)] [string] $Email,
  [Parameter(Mandatory)] [string] $Foto,
  # Dados comuns da empresa (DADOS EMAIL.docx); o endereco ficou de fora por espaco.
  [string] $Telefone = '(61) 3963-3959',
  [string] $Cnpj = '26.762.139/0001-66',
  [string] $SiteUrl = 'https://www.grupoecovolt.com.br',
  # Ajustes da foto, em pixels da arte de referencia (1816 x 866).
  [double] $FotoZoom = 1,
  [double] $FotoDeslocX = 0,
  [double] $FotoDeslocY = 0
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$empresa = Split-Path -Parent $PSScriptRoot
$repo = Split-Path -Parent $empresa
$baseUrl = 'https://raw.githubusercontent.com/danielhell666/assinatura_email/main/'
$cultura = [Globalization.CultureInfo]::InvariantCulture

function ConvertTo-HtmlText([string] $Value) {
  [System.Net.WebUtility]::HtmlEncode($Value)
}

function ConvertTo-Slug([string] $Value) {
  $semAcento = -join ($Value.Normalize([Text.NormalizationForm]::FormD).ToCharArray() |
    Where-Object { [Globalization.CharUnicodeInfo]::GetUnicodeCategory($_) -ne 'NonSpacingMark' })
  ($semAcento.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
}

function Get-UrlRelativa([string] $De, [string] $Para) {
  [Uri]::new($De + '\').MakeRelativeUri([Uri]::new([IO.Path]::GetFullPath($Para))).ToString()
}

$fotoPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Foto)
if (-not (Test-Path -LiteralPath $fotoPath -PathType Leaf)) { throw "Foto nao encontrada: $fotoPath" }
$navegador = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $navegador) { throw 'Chrome ou Edge nao encontrado.' }

$slug = ConvertTo-Slug $Nome
$previas = Join-Path $empresa 'previews'
$assets = Join-Path $empresa 'assets'
New-Item -ItemType Directory -Force -Path $previas, $assets | Out-Null

# Caixa da foto: cobre a janela da moldura (modelos/moldura.json).
$fotoL = 530 * $FotoZoom
$fotoA = 750 * $FotoZoom
$moldura = Get-Content -LiteralPath (Join-Path $empresa 'modelos\moldura.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$valores = @{
  '{{MOLDURA_FUNDO}}'  = $moldura.fundo
  '{{MOLDURA_FRENTE}}' = $moldura.frente
  '{{JANELA}}'         = $moldura.janela
  '{{NOME}}'        = ConvertTo-HtmlText $Nome
  '{{CARGO}}'       = ConvertTo-HtmlText $Cargo
  '{{TELEFONE}}'    = ConvertTo-HtmlText $Telefone
  '{{EMAIL}}'       = ConvertTo-HtmlText $Email
  '{{CNPJ}}'        = ConvertTo-HtmlText $Cnpj
  '{{SITE}}'        = ConvertTo-HtmlText ($SiteUrl -replace '^https?://', '').TrimEnd('/')
  '{{MODELOS}}'     = Get-UrlRelativa $previas (Join-Path $empresa 'modelos')
  '{{LOGO}}'        = Get-UrlRelativa $previas (Join-Path $assets 'logo.png')
  '{{FOTO}}'        = Get-UrlRelativa $previas $fotoPath
  '{{FOTO_X}}'      = (88 - ($fotoL - 530) / 2 + $FotoDeslocX).ToString($cultura)
  '{{FOTO_Y}}'      = (40 + $FotoDeslocY).ToString($cultura)
  '{{FOTO_L}}'      = $fotoL.ToString($cultura)
  '{{FOTO_A}}'      = $fotoA.ToString($cultura)
}
$arte = Get-Content -LiteralPath (Join-Path $empresa 'modelos\arte.html') -Raw -Encoding UTF8
foreach ($chave in $valores.Keys) { $arte = $arte.Replace($chave, $valores[$chave]) }
$artePath = Join-Path $previas "arte-$slug.html"
Set-Content -LiteralPath $artePath -Value $arte -Encoding UTF8 -NoNewline

# Captura 760 x 362 em escala 2; o tempo virtual espera fontes e imagens carregarem.
$png = Join-Path $previas "arte-$slug.png"
if (Test-Path -LiteralPath $png) { Remove-Item -LiteralPath $png }
$perfil = Join-Path ([IO.Path]::GetTempPath()) "ecovolt-chrome-$PID"
# O Chrome informa o arquivo gravado no stderr; no PowerShell 5.1 isso viraria erro com 'Stop'.
$ErrorActionPreference = 'Continue'
& $navegador --headless=new --disable-gpu --hide-scrollbars --no-first-run --user-data-dir="$perfil" `
  --force-device-scale-factor=2 --window-size=760,362 --virtual-time-budget=5000 `
  --screenshot="$png" ([Uri]::new($artePath).AbsoluteUri) 2>&1 | Out-Null
$ErrorActionPreference = 'Stop'
Remove-Item -LiteralPath $perfil -Recurse -Force -ErrorAction SilentlyContinue
if (-not (Test-Path -LiteralPath $png)) { throw 'A captura da arte falhou.' }

$jpg = Join-Path $assets "ecovolt-$slug-assinatura.jpg"
$imagem = [System.Drawing.Bitmap]::new($png)
try {
  if ($imagem.Width -ne 1520 -or $imagem.Height -ne 724) { throw "Captura com tamanho inesperado: $($imagem.Width)x$($imagem.Height)" }
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
  $parametros = [System.Drawing.Imaging.EncoderParameters]::new(1)
  $parametros.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long] 90)
  $imagem.Save($jpg, $codec, $parametros)
} finally {
  $imagem.Dispose()
}

$src = $baseUrl + 'ecovolt/assets/' + [IO.Path]::GetFileName($jpg)
$travessao = [char]0x2014
$alt = ConvertTo-HtmlText "$Nome $travessao $Cargo | Grupo Ecovolt"
$titulo = ConvertTo-HtmlText "Assinatura $travessao $Nome | Grupo Ecovolt"
$site = ConvertTo-HtmlText $SiteUrl
$html = @"
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>$titulo</title>
</head>
<body style="margin:0;padding:24px;background:#eef1f4;">
  <table role="presentation" width="760" cellpadding="0" cellspacing="0" border="0" bgcolor="#ffffff" style="width:100%;max-width:760px;background:#ffffff;background-color:#ffffff;border:0;border-spacing:0;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;">
    <tr><td width="760" valign="top" bgcolor="#ffffff" style="width:760px;padding:0;background:#ffffff;background-color:#ffffff;font-size:0;line-height:0;vertical-align:top;"><a href="$site" target="_blank" style="display:block;font-size:0;line-height:0;text-decoration:none;"><img src="$src" width="760" height="362" alt="$alt" style="display:block;width:100%;max-width:760px;height:auto;border:0;outline:none;text-decoration:none;"></a></td></tr>
  </table>
</body>
</html>
"@
$htmlPath = Join-Path $empresa "assinatura-ecovolt-$slug.html"
Set-Content -LiteralPath $htmlPath -Value $html -Encoding UTF8 -NoNewline
Write-Output $jpg
Write-Output $htmlPath
