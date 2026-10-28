# Assinaturas de e-mail

O projeto está separado por empresa ou marca:

| Pasta | Conteúdo |
| --- | --- |
| [ecovolt/](ecovolt/README.md) | Grupo Ecovolt: modelo e gerador, com links de telefone, e-mail e mapa; Daniel em teste |
| [inovathings/](inovathings/README.md) | Charles (Gmail e institucional) e Daniel (institucional) |
| [lumens/](lumens/README.md) | Daniel e Paulo, versões atuais e legado |
| [pabline/](pabline/README.md) | Pabline Cavalcante |
| [scripts/](scripts/) | Ferramentas comuns de prévia, validação e recorte (`recortes.ps1`) |

Em cada empresa, os HTMLs prontos ficam no primeiro nível. `assets/` guarda as imagens usadas pelas assinaturas; `fontes/` e `modelos/` guardam materiais editáveis, quando existentes; `scripts/` guarda os geradores; `previews/` guarda as prévias. Versões anteriores ficam em `legado/`.

## Conferir antes de publicar

Execute a partir da raiz do projeto:

```powershell
.\scripts\gerar-previas.ps1
.\scripts\validar-projeto.ps1
```

Abra os HTMLs gerados em `<empresa>/previews/`. Eles usam imagens locais e funcionam sem enviar arquivos ao GitHub. Para gerar apenas uma empresa, use `-Empresa ecovolt`, `-Empresa inovathings`, `-Empresa lumens` ou `-Empresa pabline`.

As prévias HTML são geradas automaticamente e ignoradas pelo Git. Use os HTMLs principais para instalar as assinaturas que apontam para imagens públicas. Publique os assets correspondentes na branch `main` antes de copiar a assinatura para o e-mail. A validação confere os arquivos locais; ela não confirma que estão publicados nem substitui um teste no aplicativo de e-mail.

## Compatibilidade com assinaturas antigas

Sete imagens da InovaThings permanecem na raiz porque os HTMLs antigos e os e-mails já enviados usam suas URLs públicas:

- `charles-bird-quadrada.jpg` e `daniel-quadrada.jpg`;
- `ic-cnpj.png`, `ic-email.png` e `ic-tel.png`;
- `logo-inovathings-brasil-branco.png` e `separador-azul.png`.

Esses arquivos são cópias de compatibilidade. Os originais de trabalho estão em `inovathings/assets/originais/`. Não remova nem renomeie as cópias da raiz: isso quebraria as imagens de assinaturas já distribuídas. O HTML antigo do Charles foi transferido, sem alterar seu conteúdo, de `assinatura.html` para `inovathings/assinatura-charles-gmail.html`.

Os caminhos publicados em `lumens/assets/` também foram preservados. Os recortes e materiais antigos que estavam em `assets/` foram para `lumens/legado/assets/` junto dos HTMLs que os utilizam.
