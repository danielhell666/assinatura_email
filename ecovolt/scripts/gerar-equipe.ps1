# Gera as assinaturas de todas as pessoas de equipe.csv que ja tem foto.
# Fotos sao relativas a pasta ecovolt/; ajustes de enquadramento vazios usam o padrao.
$ErrorActionPreference = 'Stop'
$empresa = Split-Path -Parent $PSScriptRoot
$gerador = Join-Path $PSScriptRoot 'gerar-assinatura.ps1'
$cultura = [Globalization.CultureInfo]::InvariantCulture

foreach ($pessoa in Import-Csv -LiteralPath (Join-Path $empresa 'equipe.csv') -Delimiter ';' -Encoding UTF8) {
  if (-not $pessoa.Foto) {
    Write-Warning "Sem foto, ignorado: $($pessoa.Nome)"
    continue
  }
  $parametros = @{
    Nome  = $pessoa.Nome
    Cargo = $pessoa.Cargo
    Email = $pessoa.Email
    Foto  = Join-Path $empresa $pessoa.Foto
  }
  foreach ($ajuste in 'FotoZoom', 'FotoDeslocX', 'FotoDeslocY') {
    if ($pessoa.$ajuste) { $parametros[$ajuste] = [double]::Parse($pessoa.$ajuste, $cultura) }
  }
  & $gerador @parametros
}
