# Assinaturas — Grupo Ecovolt

## Versões prontas

- [Charles Altair](assinatura-ecovolt-charles-altair.html)
- [Paulo Soares](assinatura-ecovolt-paulo-soares.html)
- [Rebeka Viana](assinatura-ecovolt-rebeka-viana.html)
- [Vladimir Nogueira, PhD](assinatura-ecovolt-vladimir-nogueira-phd.html)
- [Daniel Nobre](assinatura-ecovolt-daniel-nobre.html): **somente modelo de teste**, não é da equipe.

Ainda sem foto: Daniel Reis, Nathalia Chaves e Erick Luttiery (os dados já estão em `equipe.csv`).

Cada assinatura é uma imagem 2x com os dados embutidos, cortada em faixas de largura inteira empilhadas (mesma técnica da InovaThings, via `../scripts/recortes.ps1`). Cada faixa tem seu link:

| Faixa | Link |
| --- | --- |
| Logo, nome e cargo | site |
| Telefone | `tel:+556139633959` |
| E-mail | `mailto:` do e-mail da pessoa |
| Site | site |
| CNPJ | sem link |
| Endereço | Google Maps (busca pelo endereço completo) |
| Rodapé (Inovação, Eficiência, Tecnologia) | site |

O link vale pela faixa inteira, não só pelo texto: tocar na foto, ao lado do telefone, também liga. O bloco de contatos tem telefone, e-mail, site, CNPJ e endereço resumido. A arte segue o modelo `fontes/Cartão Corporativo Grupo Ecovolt.png`. Os dados comuns vêm de `DADOS EMAIL.docx` e são os valores padrão do gerador.

## Organização

- `equipe.csv`: nome, cargo, e-mail e foto de cada pessoa, com ajustes opcionais de enquadramento.
- `fontes/`: arte de referência, logos oficiais (transparente e símbolo) e, em `fotos/`, as fotos originais recebidas.
- `modelos/moldura.json`: moldura da foto redesenhada em vetor (formas cinza, faixas verdes, sombra, filete branco e janela da foto), com medidas tiradas da arte de referência. A referência foi gerada e ampliada por IA, e recortar dela deixava as curvas imperfeitas. `modelos/moldura.svg` mostra só a moldura, para conferir.
- `modelos/base.png`: lado direito (serviços e losangos) e rodapé da arte de referência, sem logo, nome, cargo e contatos; à esquerda é transparente, exceto o rodapé.
- `modelos/arte.html`: modelo que monta foto, base, logo oficial, textos e ícones; `modelos/tipos/` guarda as fontes Montserrat e Open Sans (licença OFL).
- `assets/`: logo recortada e imagens finais publicadas (a imagem inteira de cada pessoa e, em `recortes/`, as faixas usadas no HTML); `assets/originais/` guarda as fotos já recortadas na proporção da moldura (530 x 750).
- `scripts/gerar-equipe.ps1`: gera todas as pessoas de `equipe.csv` que têm foto.
- `scripts/gerar-assinatura.ps1`: gera a imagem de uma pessoa e o HTML da assinatura.
- `scripts/preparar-base.py`: refaz `modelos/base.png` e a moldura vetorial; só é necessário se o modelo ou a moldura mudarem (os pontos das curvas estão no próprio script).

## Gerar as assinaturas

Para incluir alguém, recorte a foto na proporção 530 x 750 (rosto centralizado, topo da cabeça perto do alto), salve em `assets/originais/` e preencha a coluna `Foto` em `equipe.csv`. Depois execute na raiz do repositório:

```powershell
.\ecovolt\scripts\gerar-equipe.ps1
```

Para uma pessoa avulsa:

```powershell
.\ecovolt\scripts\gerar-assinatura.ps1 -Nome "Daniel Nobre" -Cargo "Diretor Técnico" -Email "daniel.nobre@grupoecovolt.com.br" -Foto "ecovolt\assets\originais\daniel-nobre-foto.jpg" -FotoDeslocX 30 -FotoZoom 1.1
```

O script usa o Chrome (ou o Edge) sem janela para capturar a arte em 1520 x 724 e grava:

- `assets/ecovolt-<nome>-assinatura.jpg`: imagem 2x inteira (os e-mails antigos apontam para ela);
- `assets/recortes/ecovolt-<nome>-faixaN.jpg`: as faixas da assinatura;
- `assinatura-ecovolt-<nome>.html`: assinatura com as faixas publicadas e seus links;
- `previews/arte-<nome>.html` e `.png`: arte preenchida e captura bruta, para conferência (ignoradas pelo Git).

Parâmetros opcionais com os dados comuns como padrão: `-Telefone`, `-Cnpj`, `-SiteUrl`, `-Endereco` (versão curta mostrada na arte) e `-EnderecoMapa` (endereço completo do link do mapa). Se mudar a posição das linhas em `modelos/arte.html`, ajuste os cortes das faixas em `gerar-assinatura.ps1`. Os ajustes de enquadramento `-FotoZoom`, `-FotoDeslocX` e `-FotoDeslocY` usam pixels da arte de referência (1816 x 866). A foto é multiplicada sobre um cinza-claro para que fundos brancos não se confundam com o cartão. Textos longos têm a fonte reduzida automaticamente para não invadir a coluna de serviços.

Para conferir sem depender do GitHub, execute `.\scripts\gerar-previas.ps1 -Empresa ecovolt` e abra `ecovolt/previews/`. Publique as imagens de `ecovolt/assets/` (inclusive `recortes/`) na branch `main` antes de copiar a assinatura para o e-mail.
