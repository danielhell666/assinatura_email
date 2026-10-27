# Prepara as camadas fixas da arte a partir da referencia em fontes/:
# - modelos/base.png: lado direito (servicos, losangos) e rodape da referencia,
#   sem logo, nome, cargo e contatos (arte.html redesenha). A esquerda de x=626
#   fica transparente, exceto a faixa escura do rodape.
# - modelos/moldura.json: moldura da foto redesenhada em vetor (formas cinza,
#   faixas verdes, sombra, filete branco e janela da foto). A referencia foi
#   gerada e ampliada por IA; recortar dela deixava as curvas imperfeitas.
#   Os pontos abaixo foram medidos na referencia (1816 x 866).
# - modelos/moldura.svg: so a moldura, para conferir o desenho.
# Uso, na raiz do repositorio: python -I ecovolt/scripts/preparar-base.py
import json
from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter

empresa = Path(__file__).resolve().parent.parent
im = Image.open(empresa / 'fontes' / 'Cartão Corporativo Grupo Ecovolt.png').convert('RGB')
px = im.load()
W, H = im.size
LIMITE_X = 626  # a esquerda disso, tudo e vetor (menos o rodape)


# ---------------------------------------------------------------- moldura ----

def suave(pontos, inicio='M'):
    """Curva Catmull-Rom pelos pontos, em segmentos cubicos do SVG."""
    p = [pontos[0]] + list(pontos) + [pontos[-1]]
    d = f'{inicio}{p[1][0]:g} {p[1][1]:g}'
    for i in range(1, len(p) - 2):
        (x0, y0), (x1, y1), (x2, y2), (x3, y3) = p[i - 1], p[i], p[i + 1], p[i + 2]
        c1 = (x1 + (x2 - x0) / 6, y1 + (y2 - y0) / 6)
        c2 = (x2 - (x3 - x1) / 6, y2 - (y3 - y1) / 6)
        d += f' C{c1[0]:.1f} {c1[1]:.1f} {c2[0]:.1f} {c2[1]:.1f} {x2:g} {y2:g}'
    return d


# Centro do filete branco, do alto (onde some no fundo branco) ate o rodape.
FILETE = [(262, 46), (215, 55), (178, 72), (151, 100), (128, 140), (105, 180),
          (84, 220), (62, 260), (41, 300), (27, 335), (21, 370), (26, 405),
          (42, 440), (73, 480), (105, 520), (136, 560), (168, 600), (202, 640),
          (242, 680), (294, 720), (352, 750), (420, 768), (500, 772), (640, 772)]
# Borda interna da faixa verde entre o filete e a foto (afina ate sumir em y~600).
FAIXA_INTERNA = [(250, 48), (218, 60), (186, 80), (160, 110), (133, 160), (112, 220),
                 (98, 280), (93, 340), (96, 395), (106, 450), (121, 500), (140, 545),
                 (168, 600)]
# Contorno de cima e da direita da foto, ate encontrar o filete embaixo.
JANELA = [(250, 48), (329, 59), (429, 79), (500, 97), (560, 118), (592, 150),
          (606, 195), (607, 260), (603, 400), (597, 560), (590, 680), (580, 725),
          (560, 752), (525, 767), (480, 772)]
# Borda inferior esquerda da faixa verde, do rodape ate a margem esquerda:
# desce em curva e vira a diagonal que encosta na faixa cinza-clara.
VERDE_BORDA = [(400, 846), (343, 842), (300, 826), (272, 802), (254, 778), (242, 760),
               (229, 740), (216, 720), (176, 700), (96, 660), (18, 620), (0, 610)]
VERDE_DIAGONAL = VERDE_BORDA[VERDE_BORDA.index((216, 720)):]


def trecho_filete(y_min, y_max):
    return [p for p in FILETE if y_min <= p[1] <= y_max]


faixa_verde = ('M0 196 L139 119 ' + suave(trecho_filete(130, 772), 'L') +
               ' L640 846 ' + suave(VERDE_BORDA, 'L') + ' Z')
sombra = ('M0 452 ' + suave([(0, 452), (43, 500), (96, 560), (145, 620), (189, 680), (216, 720)], 'L') +
          ' ' + suave(VERDE_DIAGONAL, 'L') + ' Z')
faixa_interna = (suave(trecho_filete(46, 600)) + ' ' +
                 suave(list(reversed(FAIXA_INTERNA)), 'L') + ' Z')
janela = (suave(JANELA) + ' ' +
          suave(list(reversed(trecho_filete(46, 768))), 'L') + ' Z')

fundo = f'''<rect width="{LIMITE_X}" height="{H}" fill="#fefefe"/>
<path d="M0 128 L92 64 C110 52 140 48 158 56 C172 64 172 80 165 95 L120 200 L0 300 Z" fill="#dcdcdc"/>
<path d="M0 598 L216 714 L236 750 L200 730 L0 640 Z" fill="#ececec"/>
<path d="M0 636 L180 718 Q206 730 206 760 L206 795 Q206 836 164 836 L0 836 Z" fill="#dedede"/>'''

frente = f'''<defs>
  <linearGradient id="mo-sombra" gradientUnits="userSpaceOnUse" x1="20" y1="600" x2="90" y2="543">
    <stop offset="0" stop-color="#678f1d"/><stop offset="1" stop-color="#4b6e23"/>
  </linearGradient>
  <linearGradient id="mo-interna" gradientUnits="userSpaceOnUse" x1="0" y1="50" x2="0" y2="600">
    <stop offset="0" stop-color="#88bb16"/><stop offset="0.13" stop-color="#7cb40e"/>
    <stop offset="0.24" stop-color="#6e9f18"/><stop offset="0.35" stop-color="#65931b"/>
    <stop offset="0.46" stop-color="#5a851f"/><stop offset="0.63" stop-color="#6e9c1a"/>
    <stop offset="0.8" stop-color="#8cbf12"/><stop offset="0.91" stop-color="#95c716"/>
    <stop offset="1" stop-color="#98c91a"/>
  </linearGradient>
</defs>
<path d="{faixa_verde}" fill="#99ca1e"/>
<path d="{sombra}" fill="url(#mo-sombra)"/>
<path d="{suave(VERDE_DIAGONAL)}" fill="none" stroke="#ffffff" stroke-width="3"/>
<path d="{faixa_interna}" fill="url(#mo-interna)"/>
<path d="{suave(FILETE)}" fill="none" stroke="#ffffff" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>'''

(empresa / 'modelos' / 'moldura.json').write_text(
    json.dumps({'fundo': fundo, 'janela': janela, 'frente': frente}, ensure_ascii=False, indent=1),
    encoding='utf-8')
(empresa / 'modelos' / 'moldura.svg').write_text(
    f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {LIMITE_X + 40} {H}" width="{LIMITE_X + 40}" height="{H}">\n'
    f'{fundo}\n<path d="{janela}" fill="#c9c9c9"/>\n{frente}\n</svg>\n', encoding='utf-8')

# ------------------------------------------------------------------- base ----

FUNDO = (254, 254, 254)
QUADROS_X = 1560  # a partir daqui o fundo tem os losangos cinza-claros


def apagar(caixa, folga=9):
    """Apaga o desenho da caixa. No fundo branco pinta branco; sobre os losangos
    repete a cor logo acima de cada trecho."""
    x0, y0, x1, y1 = caixa
    marca = Image.new('L', (W, H), 0)
    mp = marca.load()
    for y in range(y0, y1):
        for x in range(x0, x1):
            if min(px[x, y]) < (238 if x >= QUADROS_X else 250):
                mp[x, y] = 255
    mp = marca.filter(ImageFilter.MaxFilter(folga)).load()
    for x in range(x0, x1):
        for y in range(y0, y1):
            if mp[x, y]:
                px[x, y] = px[x, y - 1] if x >= QUADROS_X else FUNDO


apagar((640, 80, 1712, 320))   # logo
apagar((650, 370, 1340, 745))  # nome, cargo, traco verde e contatos com icones

# Opaco a direita de LIMITE_X e no rodape (borda esquerda inclinada medida na
# referencia); desenhado em 4x e reduzido para a borda inclinada ficar lisa.
ESCALA = 4
alfa = Image.new('L', (W * ESCALA, H * ESCALA), 0)
desenho = ImageDraw.Draw(alfa)
desenho.rectangle((LIMITE_X * ESCALA, 0, W * ESCALA, H * ESCALA), fill=255)
desenho.polygon([(x * ESCALA, y * ESCALA) for x, y in
                 [(420.3, 772.5), (LIMITE_X + 1, 772.5), (LIMITE_X + 1, 845.5), (598.5, 845.5)]], fill=255)
saida = im.convert('RGBA')
saida.putalpha(alfa.resize((W, H), Image.LANCZOS))
saida.save(empresa / 'modelos' / 'base.png', optimize=True)
print('Base criada:', empresa / 'modelos' / 'base.png')
print('Moldura criada:', empresa / 'modelos' / 'moldura.json')
