# Recorta uma assinatura em imagem 2x em faixas horizontais e gera o HTML.
# Faixas com Colunas = $true viram tres celulas (esquerda, centro com link, direita),
# o que permite links separados para telefone e e-mail sem depender de CSS de fundo.
# Larguras em porcentagem mantem as celulas alinhadas quando o app reduz a assinatura.

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

function Get-TagImagem([string] $src, [int] $largura, [string] $alt) {
  $alt = [System.Net.WebUtility]::HtmlEncode($alt)
  return "<img src=""$src"" width=""$largura"" alt=""$alt"" style=""display:block;width:100%;max-width:${largura}px;height:auto;border:0;outline:none;text-decoration:none;"">"
}

function Add-Link([string] $conteudo, [string] $href) {
  if (-not $href) { return $conteudo }
  $alvo = if ($href -match '^https?:') { ' target="_blank"' } else { '' }
  $href = [System.Net.WebUtility]::HtmlEncode($href)
  return "<a href=""$href""$alvo style=""display:block;font-size:0;line-height:0;text-decoration:none;"">$conteudo</a>"
}

# $Faixas: lista de @{ Altura; Alt; Link; Colunas } com medidas em pixels da imagem 2x.
# $CortesX: tres larguras em pixels 2x (esquerda, centro, direita) usadas nas faixas com Colunas.
function New-AssinaturaRecortada {
  param(
    [Parameter(Mandatory)] [string] $Imagem,
    [Parameter(Mandatory)] [string] $Pasta,
    [Parameter(Mandatory)] [string] $Prefixo,
    [Parameter(Mandatory)] [object[]] $Faixas,
    [Parameter(Mandatory)] [int[]] $CortesX,
    [Parameter(Mandatory)] [string] $Html,
    [Parameter(Mandatory)] [string] $Titulo,
    [string] $Extensao = 'png',
    [string] $Fundo = '#ffffff'
  )

  New-Item -ItemType Directory -Force -Path $Pasta | Out-Null
  $origem = [System.Drawing.Bitmap]::new($Imagem)
  $larguraTotal = $origem.Width / 2
  if (($CortesX | Measure-Object -Sum).Sum -ne $origem.Width) { throw "CortesX deve somar $($origem.Width)" }
  if ((($Faixas | ForEach-Object { $_.Altura }) | Measure-Object -Sum).Sum -ne $origem.Height) { throw "As alturas das faixas devem somar $($origem.Height)" }

  $linhas = [System.Collections.Generic.List[string]]::new()
  $y = 0
  for ($i = 0; $i -lt $Faixas.Count; $i++) {
    $faixa = $Faixas[$i]
    $numero = $i + 1
    if ($faixa.Colunas) {
      $celulas = [System.Collections.Generic.List[string]]::new()
      $x = 0
      $nomes = @('esq', 'link', 'dir')
      for ($c = 0; $c -lt 3; $c++) {
        $arquivo = Join-Path $Pasta "$Prefixo-faixa$numero-$($nomes[$c]).$Extensao"
        Save-Recorte $origem ([System.Drawing.Rectangle]::new($x, $y, $CortesX[$c], $faixa.Altura)) $arquivo
        $largura = $CortesX[$c] / 2
        $porcentagem = [math]::Round($CortesX[$c] / $origem.Width * 100, 3).ToString([Globalization.CultureInfo]::InvariantCulture)
        $alt = if ($c -eq 1) { $faixa.Alt } else { '' }
        $conteudo = Get-TagImagem (Get-UrlPublica $arquivo) $largura $alt
        if ($c -eq 1) { $conteudo = Add-Link $conteudo $faixa.Link }
        $celulas.Add("<td width=""$largura"" valign=""top"" style=""width:$porcentagem%;padding:0;font-size:0;line-height:0;vertical-align:top;"">$conteudo</td>")
        $x += $CortesX[$c]
      }
      $linhas.Add("    <tr><td style=""padding:0;font-size:0;line-height:0;""><table role=""presentation"" width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0"" style=""width:100%;border:0;border-spacing:0;border-collapse:collapse;table-layout:fixed;""><tr>" + ($celulas -join '') + '</tr></table></td></tr>')
    } else {
      $arquivo = Join-Path $Pasta "$Prefixo-faixa$numero.$Extensao"
      Save-Recorte $origem ([System.Drawing.Rectangle]::new(0, $y, $origem.Width, $faixa.Altura)) $arquivo
      $conteudo = Add-Link (Get-TagImagem (Get-UrlPublica $arquivo) $larguraTotal $faixa.Alt) $faixa.Link
      $linhas.Add("    <tr><td style=""padding:0;font-size:0;line-height:0;"">$conteudo</td></tr>")
    }
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
  <table role="presentation" width="$larguraTotal" cellpadding="0" cellspacing="0" border="0" bgcolor="$Fundo" style="width:100%;max-width:${larguraTotal}px;background-color:$Fundo;border:0;border-spacing:0;border-collapse:collapse;mso-table-lspace:0pt;mso-table-rspace:0pt;">
$($linhas -join "`n")
  </table>
</body>
</html>
"@
  [IO.File]::WriteAllText($Html, $documento.Replace("`r`n", "`n"), [Text.UTF8Encoding]::new($false))
  Write-Output $Html
}
