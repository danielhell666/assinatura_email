# Assinaturas — InovaThings

- `assinatura-charles-institucional.html`: Charles Altair, Diretor Comercial, para `comercial@inovathingsbrasil.com.br`.
- `assinatura-daniel-institucional.html`: Daniel Nobre, Diretor Técnico, para `solucoes@inovathingsbrasil.com.br`.
- `assinatura-charles-gmail.html`: assinatura original do Charles, Diretor Administrativo, para `inovathingsbrasil@gmail.com`.

A assinatura original do Charles foi movida da raiz para esta pasta com o conteúdo intacto. Ela continua usando fundo preto em HTML e as URLs antigas de imagem da raiz. Essas imagens foram preservadas para manter os e-mails existentes funcionando.

## Versões institucionais

As versões institucionais são imagens com o fundo preto embutido, cortadas em faixas. O app do Zoho Mail no celular descarta o fundo preto definido em HTML; com isso, o texto branco e o logo branco transparente ficavam invisíveis. Com o preto dentro das imagens, a aparência não depende do app.

As faixas de telefone e e-mail são divididas em três células, e a do meio tem o link `tel:` ou `mailto:`. As larguras em porcentagem fazem a assinatura encolher por inteiro em telas estreitas. As imagens são geradas em 2x para ficarem nítidas no celular.

- `assets/completas/`: assinatura inteira em 2x, base dos recortes.
- `assets/recortes/`: faixas usadas pelos HTMLs.
- `assets/originais/`: fotos, logo e ícones usados pelo gerador.
- `legado/`: versões institucionais anteriores em HTML com texto, que dependem do fundo preto em HTML.
- Os arquivos soltos em `assets/` são os recortes 1x de uma versão anterior, mantidos para preservar as URLs publicadas.

Para regenerar as imagens e os HTMLs, execute na raiz do projeto:

```powershell
.\inovathings\scripts\gerar-assets.ps1
```

Para conferir as assinaturas com imagens locais antes de publicar:

```powershell
.\scripts\gerar-previas.ps1 -Empresa inovathings
```

Abra os HTMLs de `inovathings/previews/`. Esses arquivos são só para conferência; use os HTMLs principais na instalação por URL pública.

Para instalar, publique as imagens na branch `main`, abra o HTML principal no navegador, selecione a assinatura inteira e substitua a assinatura nas configurações da conta. Envie uma mensagem de teste e confira no celular.
