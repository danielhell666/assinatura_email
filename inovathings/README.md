# Assinaturas — InovaThings

- `assinatura-charles-institucional.html`: Charles Altair, Diretor Comercial, para `comercial@inovathingsbrasil.com.br`.
- `assinatura-daniel-institucional.html`: Daniel Nobre, Diretor Técnico, para `solucoes@inovathingsbrasil.com.br`.
- `assinatura-charles-gmail.html`: assinatura original do Charles, Diretor Administrativo, para `inovathingsbrasil@gmail.com`.

A assinatura original do Charles foi movida da raiz para esta pasta com o conteúdo intacto. Ela continua usando fundo preto em HTML e as URLs antigas de imagem da raiz. Essas imagens foram preservadas para manter os e-mails existentes funcionando.

As duas versões institucionais usam blocos de imagem com fundo preto integrado. Os blocos de telefone e e-mail continuam clicáveis. Essa mudança preserva o preto nas próprias imagens, mas não comprova a causa do comportamento relatado no celular.

`assets/` contém os recortes das versões institucionais. `assets/originais/` contém fotos, logo e ícones usados pelo gerador, que não depende mais dos arquivos da raiz.

Para regenerar os recortes, execute na raiz do projeto:

```powershell
.\inovathings\scripts\gerar-assets.ps1
```

Para conferir as três assinaturas com imagens locais antes de publicar:

```powershell
.\scripts\gerar-previas.ps1 -Empresa inovathings
```

Abra os HTMLs de `inovathings/previews/`. Esses arquivos são só para conferência; use os HTMLs principais na instalação por URL pública.

Antes de instalar no e-mail, publique a pasta `inovathings/assets/` na branch `main` do repositório: os arquivos HTML usam as URLs públicas do GitHub para carregar essas imagens em qualquer dispositivo.
