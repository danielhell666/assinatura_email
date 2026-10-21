# Assinatura — Pabline Cavalcante

Arquivos da assinatura infantil para Pabline Cavalcante.

- `assinatura-pabline.html`: prévia pronta para abrir e copiar.
- `fontes/assinatura-pabline.svg`: arquivo mestre editável.
- `assets/assinatura-pabline.png`: imagem final adequada para uso no HTML do e-mail.

Para refazer o PNG após uma edição no SVG, execute:

```powershell
.\pabline\scripts\gerar-preview.ps1
```

Execute o comando acima a partir da raiz do projeto. `assets/` contém a foto, a logo e a imagem final; `scripts/` contém o gerador; `fontes/` contém o SVG editável.

Os dados de contato foram mantidos conforme a referência visual. Antes do uso, substitua-os pelos dados definitivos em `fontes/assinatura-pabline.svg` e execute o script novamente.

O HTML desta marca usa uma imagem local. Para uso por URL pública no e-mail, publique o asset e ajuste o `src` do HTML para a URL correspondente.
