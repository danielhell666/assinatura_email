$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'scripts\recortes.ps1')

$empresa = Split-Path -Parent $PSScriptRoot
$assets = Join-Path $empresa 'assets'
$tecnico = 'Diretor T' + [char]0x00E9 + 'cnico'

# Medidas na imagem completa 2x (1520x608): telefone em y 371-398 e e-mail em y 419-449,
# texto entre x 584 e 925.
$pessoas = @(
  @{ Arquivo = 'lumens-daniel-nobre'; Nome = 'Daniel Nobre'; Cargo = $tecnico; Telefone = '+5561982200488'; TelefoneTexto = '+55 61 98220-0488'; Email = 'daniel.nobre@lumens.pro.br' },
  @{ Arquivo = 'lumens-paulo-soares'; Nome = 'Paulo Soares'; Cargo = 'Gerente de Projetos'; Telefone = '+5561983510703'; TelefoneTexto = '+55 61 98351-0703'; Email = 'paulo.soares@lumens.pro.br' }
)

foreach ($p in $pessoas) {
  $faixas = @(
    @{ Altura = 362; Alt = "$($p.Nome) $([char]0x2014) $($p.Cargo) | Lumens"; Link = 'https://lumens.pro.br' },
    @{ Altura = 48; Alt = "Telefone: $($p.TelefoneTexto)"; Link = "tel:$($p.Telefone)"; Colunas = $true },
    @{ Altura = 48; Alt = "E-mail: $($p.Email)"; Link = "mailto:$($p.Email)"; Colunas = $true },
    @{ Altura = 150; Alt = 'Projetos, instala' + [char]0x00E7 + [char]0x00E3 + 'o, fornecimento e integra' + [char]0x00E7 + [char]0x00E3 + 'o A/V'; Link = 'https://lumens.pro.br' }
  )
  New-AssinaturaRecortada `
    -Imagem (Join-Path $assets "$($p.Arquivo)-assinatura.jpg") `
    -Pasta (Join-Path $assets 'recortes') `
    -Prefixo $p.Arquivo `
    -Faixas $faixas `
    -CortesX @(570, 510, 440) `
    -Extensao 'jpg' `
    -Html (Join-Path $empresa "assinatura-$($p.Arquivo).html") `
    -Titulo "Assinatura $([char]0x2014) $($p.Nome) | Lumens"
}
