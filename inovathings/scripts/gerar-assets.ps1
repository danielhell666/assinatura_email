$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent (Split-Path -Parent $PSScriptRoot)) 'scripts\recortes.ps1')

$empresa = Split-Path -Parent $PSScriptRoot
$root = Join-Path $empresa 'assets\originais'
$assets = Join-Path $empresa 'assets'
$completas = Join-Path $assets 'completas'
New-Item -ItemType Directory -Force -Path $completas | Out-Null

$black = [System.Drawing.Color]::FromArgb(0, 0, 0)
$white = [System.Drawing.Color]::White
$muted = [System.Drawing.Color]::FromArgb(148, 148, 148)
$blue = [System.Drawing.Color]::FromArgb(12, 111, 233)

# Layout em pixels 1x (642x176), desenhado em 2x para ficar nitido em telas de celular.
function New-Assinatura([string] $foto, [string] $nome, [string] $cargo, [string] $telefone, [string] $email, [string] $saida) {
  $bitmap = [System.Drawing.Bitmap]::new(1284, 352)
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.Clear($black)
  $g.ScaleTransform(2, 2)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

  $whiteBrush = [System.Drawing.SolidBrush]::new($white)
  $mutedBrush = [System.Drawing.SolidBrush]::new($muted)
  $blueBrush = [System.Drawing.SolidBrush]::new($blue)

  # Foto com moldura branca, centralizada na altura e afastada 20px do texto
  $g.FillRectangle($whiteBrush, 24, 36, 104, 104)
  $g.FillRectangle([System.Drawing.SolidBrush]::new($black), 26, 38, 100, 100)
  $imagem = [System.Drawing.Image]::FromFile($foto)
  $g.DrawImage($imagem, [System.Drawing.RectangleF]::new(30, 42, 92, 92))
  $imagem.Dispose()

  # Nome, cargo e traco azul antes dos contatos
  $nameFont = [System.Drawing.Font]::new('Segoe UI', 15, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
  $roleFont = [System.Drawing.Font]::new('Segoe UI', 8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point)
  $g.DrawString($nome, $nameFont, $whiteBrush, 146, 18)
  $g.DrawString($cargo.ToUpperInvariant(), $roleFont, $mutedBrush, 147, 46)
  $g.FillRectangle($blueBrush, 148, 68, 24, 2)

  # Contatos: linhas de 28px em y 80, 108 e 136
  $font = [System.Drawing.Font]::new('Segoe UI', 9.75, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Point)
  $linhas = @(@('ic-tel.png', $telefone, 80), @('ic-email.png', $email, 108), @('ic-cnpj.png', 'CNPJ 65.301.520/0001-80', 136))
  foreach ($linha in $linhas) {
    $icone = [System.Drawing.Image]::FromFile((Join-Path $root $linha[0]))
    $g.DrawImage($icone, [System.Drawing.RectangleF]::new(148, $linha[2] + 6, 16, 16))
    $icone.Dispose()
    $g.DrawString($linha[1], $font, $whiteBrush, 172, $linha[2] + 4)
  }

  # Separador e logo
  $g.FillRectangle($blueBrush, 446, 38, 1, 100)
  $logo = [System.Drawing.Image]::FromFile((Join-Path $root 'logo-inovathings-brasil-branco.png'))
  $g.DrawImage($logo, [System.Drawing.RectangleF]::new(474, 58.5, 140, 59))
  $logo.Dispose()

  $nameFont.Dispose(); $roleFont.Dispose(); $font.Dispose()
  $whiteBrush.Dispose(); $mutedBrush.Dispose(); $blueBrush.Dispose()
  $g.Dispose()
  $bitmap.Save($saida, [System.Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

$tecnico = 'Diretor T' + [char]0x00E9 + 'cnico'
$pessoas = @(
  @{ Arquivo = 'charles'; Foto = 'charles-bird-quadrada.jpg'; Nome = 'Charles Altair'; Cargo = 'Diretor Comercial'; Telefone = '+5561981795356'; TelefoneTexto = '+55 (61) 98179-5356'; Email = 'comercial@inovathingsbrasil.com.br' },
  @{ Arquivo = 'daniel'; Foto = 'daniel-quadrada.jpg'; Nome = 'Daniel Nobre'; Cargo = $tecnico; Telefone = '+5561982200488'; TelefoneTexto = '+55 (61) 98220-0488'; Email = 'solucoes@inovathingsbrasil.com.br' }
)

foreach ($p in $pessoas) {
  $completa = Join-Path $completas "$($p.Arquivo)-assinatura.png"
  New-Assinatura (Join-Path $root $p.Foto) $p.Nome $p.Cargo $p.TelefoneTexto $p.Email $completa
  $faixas = @(
    @{ Altura = 160; Alt ="$($p.Nome) $([char]0x2014) $($p.Cargo) | InovaThings" },
    @{ Altura = 56; Alt = "Telefone: $($p.TelefoneTexto)"; Link = "tel:$($p.Telefone)" },
    @{ Altura = 56; Alt = "E-mail: $($p.Email)"; Link = "mailto:$($p.Email)" },
    @{ Altura = 80; Alt = 'CNPJ 65.301.520/0001-80' }
  )
  New-AssinaturaRecortada `
    -Imagem $completa `
    -Pasta (Join-Path $assets 'recortes') `
    -Prefixo $p.Arquivo `
    -Faixas $faixas `
    -Html (Join-Path $empresa "assinatura-$($p.Arquivo)-institucional.html") `
    -Titulo "Assinatura $([char]0x2014) $($p.Nome) | InovaThings" `
    -Fundo '#000000'
}
