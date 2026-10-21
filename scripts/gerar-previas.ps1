[CmdletBinding()]
param(
  [ValidateSet('todas', 'inovathings', 'lumens', 'pabline')]
  [string] $Empresa = 'todas'
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$baseUrl = 'https://raw.githubusercontent.com/danielhell666/assinatura_email/main/'
$empresas = if ($Empresa -eq 'todas') { @('inovathings', 'lumens', 'pabline') } else { @($Empresa) }

foreach ($nome in $empresas) {
  $pasta = Join-Path $repo $nome
  $previas = Join-Path $pasta 'previews'
  New-Item -ItemType Directory -Force -Path $previas | Out-Null
  foreach ($arquivo in Get-ChildItem -LiteralPath $pasta -Filter '*.html' -File) {
    $html = Get-Content -LiteralPath $arquivo.FullName -Raw -Encoding UTF8
    $html = [regex]::Replace($html, '(?i)\bsrc="([^"]+)"', {
      param($match)
      $src = $match.Groups[1].Value
      if ($src.StartsWith($baseUrl)) {
        $relativo = [Uri]::UnescapeDataString($src.Substring($baseUrl.Length))
        $local = [IO.Path]::GetFullPath((Join-Path $repo $relativo))
      } elseif ($src -match '^(?:[a-z][a-z0-9+.-]*:|//|#)') {
        return $match.Value
      } else {
        $local = [IO.Path]::GetFullPath((Join-Path $pasta $src))
      }
      if (-not $local.StartsWith($repo + '\', [StringComparison]::OrdinalIgnoreCase)) { throw "Imagem fora do projeto: $local" }
      if (-not (Test-Path -LiteralPath $local -PathType Leaf)) { throw "Imagem ausente: $local" }
      $base = [Uri]::new($previas + '\')
      $novoSrc = $base.MakeRelativeUri([Uri]::new($local)).ToString()
      return 'src="' + $novoSrc + '"'
    })
    $destino = Join-Path $previas $arquivo.Name
    Set-Content -LiteralPath $destino -Value $html -Encoding UTF8 -NoNewline
    Write-Output $destino
  }
}
