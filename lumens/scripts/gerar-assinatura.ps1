[CmdletBinding()]
param(
  [Parameter(Mandatory)] [string] $Nome,
  [Parameter(Mandatory)] [string] $Cargo,
  [Parameter(Mandatory)] [string] $Email,
  [Parameter(Mandatory)] [string] $Telefone,
  [Parameter(Mandatory)] [string] $FotoUrl,
  [Parameter(Mandatory)] [string] $Destino,
  [string] $Localizacao = ('Bras' + [char]0x00ED + 'lia/DF'),
  [string] $MapaUrl = 'https://www.google.com/maps/search/?api=1&query=Bras%C3%ADlia%2CDF',
  [string] $SiteUrl = 'https://lumens.pro.br',
  [string] $AssetBaseUrl = 'legado/assets'
)

function ConvertTo-HtmlText([string] $Value) {
  [System.Net.WebUtility]::HtmlEncode($Value)
}

$telefoneDigitos = $Telefone -replace '\D', ''
if ($telefoneDigitos.Length -in 10, 11) {
  $telefoneDigitos = '55' + $telefoneDigitos
}
$telefoneLink = '+' + $telefoneDigitos
$telefoneExibicao = $Telefone
$empresa = Split-Path -Parent $PSScriptRoot
$templatePath = Join-Path $empresa 'modelos\assinatura-modelo.html'

if (-not (Test-Path -LiteralPath $templatePath)) {
  throw "Modelo não encontrado: $templatePath"
}

$values = @{
  '{{NOME}}'              = ConvertTo-HtmlText $Nome
  '{{CARGO}}'             = ConvertTo-HtmlText $Cargo
  '{{EMAIL}}'             = ConvertTo-HtmlText $Email
  '{{TELEFONE_LINK}}'     = $telefoneLink
  '{{TELEFONE_EXIBICAO}}' = ConvertTo-HtmlText $telefoneExibicao
  '{{FOTO_URL}}'          = ConvertTo-HtmlText $FotoUrl
  '{{LOCALIZACAO}}'       = ConvertTo-HtmlText $Localizacao
  '{{MAPA_URL}}'          = ConvertTo-HtmlText $MapaUrl
  '{{SITE_URL}}'          = ConvertTo-HtmlText $SiteUrl
  '{{ASSET_BASE_URL}}'    = ConvertTo-HtmlText $AssetBaseUrl.TrimEnd('/')
}

$html = Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8
foreach ($key in $values.Keys) {
  $html = $html.Replace($key, $values[$key])
}

$outputPath = Join-Path $empresa $Destino
Set-Content -LiteralPath $outputPath -Value $html -Encoding UTF8 -NoNewline
Write-Host "Assinatura criada: $outputPath"
