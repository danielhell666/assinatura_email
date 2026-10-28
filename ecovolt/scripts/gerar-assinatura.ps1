# Gera a assinatura de uma pessoa: preenche modelos/arte.html, captura a arte em 2x
# com o Chrome (ou Edge) sem janela, recorta em faixas de largura inteira e cria o HTML com
# um link por faixa: telefone (tel:), e-mail (mailto:), mapa do endereco e site.
[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $Nome,
  [Parameter(Mandatory)] [string] $Cargo,
  [Parameter(Mandatory)] [string] $Email,
  [Parameter(Mandatory)] [string] $Foto,
  # Dados comuns da empresa (DADOS EMAIL.docx).
  [string] $Telefone = '(61) 3963-3959',
  [string] $Cnpj = '26.762.139/0001-66',
  [string] $SiteUrl = 'https://www.grupoecovolt.com.br',
  # Duas linhas na arte; o link do mapa usa o endereco completo.
  [string] $Endereco1 = 'SHIN CA 01 Lote A, Bloco A, Sala 233',
  [string] $Endereco2 = 'Lago Norte, Bras' + [char]0x00ED + 'lia - DF, 71503-501',
  [string] $EnderecoMapa = 'Setor Shin CA 01 Lote A Bloco A, Sala 233, Lago Norte, Bras' + [char]0x00ED + 'lia - DF, 71503-501',
  # Ajustes da foto, em pixels da arte de referencia (1816 x 866).
  [double] $FotoZoom = 1,
  [double] $FotoDeslocX = 0,
  [double] $FotoDeslocY = 0
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$empresa = Split-Path -Parent $PSScriptRoot
$repo = Split-Path -Parent $empresa
$cultura = [Globalization.CultureInfo]::InvariantCulture
. (Join-Path $repo 'scripts\recortes.ps1')

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
  '{{ENDERECO_1}}'  = ConvertTo-HtmlText $Endereco1
  '{{ENDERECO_2}}'  = ConvertTo-HtmlText $Endereco2
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

# Faixas de largura inteira cortadas entre as linhas de contato (coordenadas da arte, 866 de altura).
# Cada contato com link ocupa a propria faixa; o restante leva o link do site.
$travessao = [char]0x2014
$escala = 724 / 866
$cortes = 0, 508, 558, 602, 646, 690, 768, 866 | ForEach-Object { [int][math]::Round($_ * $escala) }
$digitos = $Telefone -replace '\D', ''
$mapa = 'https://www.google.com/maps/search/?api=1&query=' + [Uri]::EscapeDataString($EnderecoMapa)
$destinos = @(
  @{ Alt = "$Nome $travessao $Cargo | Grupo Ecovolt"; Link = $SiteUrl },
  @{ Alt = "Telefone: $Telefone"; Link = "tel:+55$digitos" },
  @{ Alt = "E-mail: $Email"; Link = "mailto:$Email" },
  @{ Alt = "Site: $($SiteUrl -replace '^https?://', '')"; Link = $SiteUrl },
  @{ Alt = "CNPJ $Cnpj" },
  @{ Alt = "Endere$([char]0x00E7)o: $Endereco1, $Endereco2"; Link = $mapa },
  @{ Alt = 'Inova' + [char]0x00E7 + [char]0x00E3 + 'o | Efici' + [char]0x00EA + 'ncia | Tecnologia'; Link = $SiteUrl }
)
$faixas = for ($i = 0; $i -lt $destinos.Count; $i++) {
  $destinos[$i] + @{ Altura = $cortes[$i + 1] - $cortes[$i] }
}
$htmlPath = Join-Path $empresa "assinatura-ecovolt-$slug.html"
New-AssinaturaRecortada `
  -Imagem $png `
  -Pasta (Join-Path $assets 'recortes') `
  -Prefixo "ecovolt-$slug" `
  -Faixas $faixas `
  -Html $htmlPath `
  -Titulo "Assinatura $travessao $Nome | Grupo Ecovolt" `
  -Extensao 'jpg' `
  -Fundo '#fefefe' | Out-Null
Write-Output $jpg
Write-Output $htmlPath
