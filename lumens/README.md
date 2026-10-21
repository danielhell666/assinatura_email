# Assinaturas — Lumens

## Versões prontas

- [Daniel Nobre](assinatura-lumens-daniel-nobre.html) e [Paulo Soares](assinatura-lumens-paulo-soares.html): versões atuais.
- [Daniel em recortes](legado/assinatura-daniel.html) e [Paulo em recortes](legado/assinatura-paulo.html): versões anteriores preservadas, com links independentes para telefone, e-mail, mapa e site.

As versões atuais são a imagem completa (`assets/lumens-*-assinatura.jpg`) cortada em faixas horizontais. A faixa do telefone e a do e-mail são divididas em três células, e a do meio tem o link `tel:` ou `mailto:`. As faixas de cima e de baixo levam ao site. As larguras em porcentagem fazem a assinatura encolher por inteiro no celular, como acontecia com a imagem única.

Para recortar de novo depois de alterar a imagem completa, execute na raiz do repositório:

```powershell
.\lumens\scripts\gerar-recortes.ps1
```

Os cortes usam as posições do telefone e do e-mail na arte atual. Se o layout da arte mudar, ajuste as alturas no script.

## Organização

- `assets/`: imagens das versões publicadas; os caminhos foram preservados.
- `assets/recortes/`: faixas usadas pelas versões atuais.
- `legado/`: HTMLs anteriores e seus respectivos assets locais.
- `fontes/`: logo mestre em SVG e arte de referência.
- `modelos/assinatura-modelo.html`: modelo em HTML para gerar outras assinaturas.
- `scripts/gerar-assinatura.ps1`: gerador baseado nesse modelo.
- `previews/`: capturas existentes e HTMLs locais gerados pelo utilitário comum.

## Gerar uma assinatura a partir do modelo

Execute na raiz do repositório. O destino é relativo à pasta `lumens/`, e os caminhos de imagem são relativos ao HTML gerado:

```powershell
.\lumens\scripts\gerar-assinatura.ps1 -Nome "Maria Silva" -Cargo "Gerente Comercial" -Email "maria.silva@lumens.pro.br" -Telefone "(61) 99999-9999" -FotoUrl "legado/assets/foto-daniel.jpg" -Destino "assinatura-exemplo.html"
```

Troque a foto do exemplo pela foto da pessoa. Esse gerador usa o modelo HTML e não recria as artes em imagem das versões prontas.

Para imagens públicas, informe `-FotoUrl` com a URL da foto e `-AssetBaseUrl` com a URL de `lumens/legado/assets/` publicada. A base local padrão é `legado/assets`.

Para conferir as versões atuais sem depender do GitHub, execute `./scripts/gerar-previas.ps1 -Empresa lumens` a partir da raiz e abra os HTMLs de `lumens/previews/`.
