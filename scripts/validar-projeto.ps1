$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$baseUrl = 'https://raw.githubusercontent.com/danielhell666/assinatura_email/main/'
$total = 0
$falhas = [System.Collections.Generic.List[string]]::new()

foreach ($empresa in @('ecovolt', 'inovathings', 'lumens', 'pabline')) {
  foreach ($arquivo in Get-ChildItem -LiteralPath (Join-Path $repo $empresa) -Recurse -File | Where-Object { $_.Extension -in '.html', '.svg' }) {
    $texto = Get-Content -LiteralPath $arquivo.FullName -Raw -Encoding UTF8
    foreach ($match in [regex]::Matches($texto, '(?i)(?:\bsrc|\bxlink:href)="([^"]+)"')) {
      $src = [System.Net.WebUtility]::HtmlDecode($match.Groups[1].Value)
      if ($src -match '\{\{') { continue }
      if ($src.StartsWith($baseUrl)) {
        $local = Join-Path $repo ([Uri]::UnescapeDataString($src.Substring($baseUrl.Length)))
      } elseif ($src -match '^(?:[a-z][a-z0-9+.-]*:|//|#)') {
        continue
      } else {
        $local = Join-Path $arquivo.DirectoryName ([Uri]::UnescapeDataString($src))
      }
      $total++
      if (-not (Test-Path -LiteralPath $local -PathType Leaf)) { $falhas.Add($arquivo.FullName + ': ' + $src) }
    }
  }
}

foreach ($nome in @('charles-bird-quadrada.jpg', 'daniel-quadrada.jpg', 'ic-cnpj.png', 'ic-email.png', 'ic-tel.png', 'logo-inovathings-brasil-branco.png', 'separador-azul.png')) {
  $publicado = Join-Path $repo $nome
  $original = Join-Path $repo ('inovathings\assets\originais\' + $nome)
  if (-not (Test-Path -LiteralPath $publicado -PathType Leaf) -or -not (Test-Path -LiteralPath $original -PathType Leaf)) {
    $falhas.Add('Imagem de compatibilidade ausente: ' + $nome)
  } elseif ((Get-FileHash -LiteralPath $publicado).Hash -ne (Get-FileHash -LiteralPath $original).Hash) {
    $falhas.Add('Imagem de compatibilidade diferente do original: ' + $nome)
  }
}

if ($falhas.Count -gt 0) { throw ($falhas -join [Environment]::NewLine) }
Write-Output "OK: $total referencias de imagem resolvidas; 7 imagens de compatibilidade preservadas. Validacao local, sem consultar o GitHub."
