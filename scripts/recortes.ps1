# Recorta uma assinatura em imagem 2x em faixas horizontais de largura inteira e gera o HTML.
# Cada faixa pode ter seu proprio link (telefone, e-mail, site) sem depender de CSS de fundo.
# As faixas ficam empilhadas na mesma celula, sem divisoes verticais: celulas lado a lado com
# largura em porcentagem arredondam alturas diferentes em telas com escala de 125% ou 150%.

Add-Type -AssemblyName System.Drawing

$script:baseUrl = 'https://raw.githubusercontent.com/danielhell666/assinatura_email/main/'
$script:repo = Split-Path -Parent $PSScriptRoot

function Save-Recorte([System.Drawing.Bitmap] $origem, [System.Drawing.Rectangle] $area, [string] $destino) {
  $recorte = $origem.Clone($area, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
  if ($destino.EndsWith('.jpg')) {
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $parametros = [System.Drawing.Imaging.EncoderParameters]::new(1)
    $parametros.Param[0] = [System.Drawing.Imaging.EncoderParameter]::new([System.Drawing.Imaging.Encoder]::Quality, [long] 90)
    $recorte.Save($destino, $codec, $parametros)
  } else {
    $recorte.Save($destino, [System.Drawing.Imaging.ImageFormat]::Png)
  }
  $recorte.Dispose()
}

function Get-UrlPublica([string] $caminho) {
  $relativo = [IO.Path]::GetFullPath($caminho).Substring($script:repo.Length + 1).Replace('\', '/')
  return $script:baseUrl + (($relativo -split '/' | ForEach-Object { [Uri]::EscapeDataString($_) }) -join '/')
}

# $Faixas: lista de @{ Altura; Alt; Link } com alturas em pixels da imagem 2x.
function New-AssinaturaRecortada {
  param(
    [Parameter(Mandatory)] [string] $Imagem,
    [Parameter(Mandatory)] [string] $Pasta,
    [Parameter(Mandatory)] [string] $Prefixo,
    [Parameter(Mandatory)] [object[]] $Faixas,
    [Parameter(Mandatory)] [string] $Html,
    [Parameter(Mandatory)] [string] $Titulo,
    [string] $Extensao = 'png',
    [string] $Fundo = '#ffffff'
  )

  New-Item -ItemType Directory -Force -Path $Pasta | Out-Null
  Get-ChildItem -LiteralPath $Pasta -Filter "$Prefixo-faixa*" -File | Remove-Item
  $origem = [System.Drawing.Bitmap]::new($Imagem)
  $largura = $origem.Width / 2
  if ((($Faixas | ForEach-Object { $_.Altura }) | Measure-Object -Sum).Sum -ne $origem.Height) { throw "As alturas das faixas devem somar $($origem.Height)" }

  $linhas = [System.Collections.Generic.List[string]]::new()
  $y = 0
  for ($i = 0; $i -lt $Faixas.Count; $i++) {
    $faixa = $Faixas[$i]
    $arquivo = Join-Path $Pasta "$Prefixo-faixa$($i + 1).$Extensao"
    Save-Recorte $origem ([System.Drawing.Rectangle]::new(0, $y, $origem.Width, $faixa.Altura)) $arquivo
    $alt = [System.Net.WebUtility]::HtmlEncode($faixa.Alt)
    $img = "<img src=""$(Get-UrlPublica $arquivo)"" width=""$largura"" alt=""$alt"" style=""display:block;width:100%;max-width:${largura}px;height:auto;border:0;outline:none;text-decoration:none;"">"
    if ($faixa.Link) {
      $alvo = if ($faixa.Link -match '^https?:') { ' target="_blank"' } else { '' }
      $href = [System.Net.WebUtility]::HtmlEncode($faixa.Link)
      $img = "<a href=""$href""$alvo style=""display:block;font-size:0;line-height:0;text-decoration:none;"">$img</a>"
    }
    $linhas.Add("      $img")
    $y += $faixa.Altura
  }
  $origem.Dispose()

  $titulo = [System.Net.WebUtility]::HtmlEncode($Titulo)
  $documento = @"
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>$titulo</title>
</head>
<body style="margin:0;padding:24px;background:#ffffff;">
  <table role="presentation" width="$largura" cellpadding="0" cellspacing="0" border="0" bgcolor="$Fundo" style="width:100%;max-width:${largura}px;background-color:$Fundo;border:0;border-spacing:0;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;">
    <tr><td style="padding:0;font-size:0;line-height:0;">
$($linhas -join "`n")
    </td></tr>
  </table>
</body>
</html>
"@
  [IO.File]::WriteAllText($Html, $documento.Replace("`r`n", "`n"), [Text.UTF8Encoding]::new($false))
  Write-Output $Html
}
