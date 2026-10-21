# Assinaturas — Lumens

## Versões prontas

- [Daniel Nobre](assinatura-lumens-daniel-nobre.html): versão atual usando a imagem completa publicada.
- [Paulo Soares](assinatura-lumens-paulo-soares.html): versão atual usando a imagem completa publicada.
- [Daniel em recortes](legado/assinatura-daniel.html) e [Paulo em recortes](legado/assinatura-paulo.html): versões anteriores preservadas, com links independentes para telefone, e-mail, mapa e site.

As versões atuais possuem um link para o site na imagem completa. Os contatos clicáveis separadamente estão nas versões em recortes.

## Organização

- `assets/`: imagens das versões publicadas; os caminhos foram preservados.
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
