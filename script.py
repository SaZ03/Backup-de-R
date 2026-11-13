"""
Mantenimiento de notas de japones en Anki.

Uso:
  1. En Anki, ventana principal: Ctrl+Shift+;
  2. Pegar este script y ejecutar con Ctrl+Enter.
  3. Revisar la muestra y los conteos que imprime.
  4. Si todo se ve bien: cambiar DRY_RUN a False, RESPALDAR, y volver a ejecutar.

Hace cuatro cosas:
  - TARJETA 3 (ver el kana y escribir el kanji a mano): se SUSPENDE en las notas
    que no tengan tag de kanji, y se reactiva en las que si lo tengan. No se
    borra nada, asi que el historial se conserva y todo es reversible.
  - HasKanji: se mantiene actualizado por si algun dia quieres volver a usarlo
    como condicional en una plantilla. Hoy ninguna plantilla lo necesita.
  - Vacia el campo Tags (basura de JMdict: ichi, v5s, news11k...).
  - Separa el Meaning conservando TODAS las acepciones (numeradas) y manda la
    primera oracion de ejemplo a ExampleJP / ExampleTranslation.

IMPORTANTE: las plantillas de las Tarjetas 2 y 3 NO deben llevar el condicional
{{#HasKanji}}. Si lo llevan, las tarjetas quedan con anverso vacio y Anki las
marca como vacias para borrarlas, que es justo lo que este script evita.

Entiende los dos formatos que usa Jitendex:
  - Formato simple (una sola acepcion): ul[data-sc-content="glossary"] mas
    ul[data-sc-content="examples"].
  - Formato con sense-groups (varias acepciones): un glossary por acepcion y
    los ejemplos en div[data-sc-content="example-sentence-a" / "-b"], con
    furigana dentro de <ruby><rt>, que se elimina.

Solo toca lo que hace falta, asi que es seguro correrlo cuantas veces quieras.
"""

import re
from anki.utils import strip_html

DRY_RUN = True

# Que tags habilitan la Tarjeta 3 (escribir el kanji a mano).
# Por defecto: cualquier tag que contenga "kanji" (curso::L22::kanji, etc.)
TAGS_KANJI = re.compile(r"kanji", re.I)

# Indice de la Tarjeta 3. Es 0-based: 0 = Tarjeta 1, 1 = Tarjeta 2, 2 = Tarjeta 3.
ORD_TARJETA3 = 2

# Si es True, reactiva la Tarjeta 3 cuando la nota SI tiene tag de kanji.
REACTIVAR = True

QUEUE_SUSPENDIDA = -1

KANJI = re.compile(r"[\u4e00-\u9fff\u3400-\u4dbf]")

RE_GLOS = re.compile(r'<ul[^>]*data-sc-content="glossary"[^>]*>(.*?)</ul>', re.S | re.I)
RE_LI = re.compile(r"<li([^>]*)>(.*?)</li>", re.S | re.I)
RE_EJEM_UL = re.compile(r'<ul[^>]*data-sc-content="examples"[^>]*>(.*?)</ul>', re.S | re.I)
RE_EJ_A = re.compile(r'<div[^>]*data-sc-content="example-sentence-a"[^>]*>(.*?)</div>', re.S | re.I)
RE_EJ_B = re.compile(r'<div[^>]*data-sc-content="example-sentence-b"[^>]*>(.*?)</div>', re.S | re.I)


def limpiar_base(html):
    """Quita CSS, furigana, notas al pie y la linea de atribucion."""
    h = re.sub(r"(?is)<style[^>]*>.*?</style>", "", html)
    h = re.sub(r"(?is)<rt[^>]*>.*?</rt>", "", h)
    h = re.sub(r"(?is)<rp[^>]*>.*?</rp>", "", h)
    h = re.sub(
        r'(?is)<span[^>]*data-sc-content="attribution-footnote"[^>]*>.*?</span>', "", h
    )
    h = re.sub(r'(?is)<div[^>]*data-sc-content="attribution"[^>]*>.*?</div>', "", h)
    return h


def parsear(html_original):
    """Devuelve (meaning, oracion_jp, traduccion_en)."""
    html = limpiar_base(html_original)

    # --- Glosario: un bloque por acepcion ---
    grupos = []
    for m in RE_GLOS.finditer(html):
        items = [strip_html(c).strip() for _, c in RE_LI.findall(m.group(1))]
        items = [i for i in items if i]
        if items:
            grupos.append("; ".join(items))

    if len(grupos) > 1:
        meaning = "<br>".join(f"{i + 1}. {g}" for i, g in enumerate(grupos))
    elif grupos:
        meaning = grupos[0]
    else:
        meaning = None

    # --- Ejemplos, formato con sense-groups ---
    jp = en = None
    m = RE_EJ_A.search(html)
    if m:
        jp = strip_html(m.group(1)).strip() or None
        m2 = RE_EJ_B.search(html)
        if m2:
            en = strip_html(m2.group(1)).strip() or None

    # --- Ejemplos, formato simple ---
    if jp is None:
        m = RE_EJEM_UL.search(html)
        if m:
            for attrs, cuerpo in RE_LI.findall(m.group(1)):
                t = strip_html(cuerpo).strip()
                if not t:
                    continue
                if 'lang="en"' in attrs.lower():
                    if en is None:
                        en = t
                elif jp is None:
                    jp = t

    return meaning, jp, en


n_kanji = n_tags = n_lim = n_ej = 0
a_suspender, a_reactivar = [], []
muestra = []

for nid in mw.col.find_notes("deck:*"):
    nota = mw.col.get_note(nid)
    if "VocabKanji" not in nota.keys() or "HasKanji" not in nota.keys():
        continue

    toco = False
    palabra = strip_html(nota["VocabKanji"]).strip()

    # 1. Tarjeta 3: activa solo con tag de kanji Y palabra que tenga kanji
    activar = bool(any(TAGS_KANJI.search(t) for t in nota.tags) and KANJI.search(palabra))

    for c in nota.cards():
        if c.ord != ORD_TARJETA3:
            continue
        if activar:
            if REACTIVAR and c.queue == QUEUE_SUSPENDIDA:
                a_reactivar.append(c.id)
        elif c.queue != QUEUE_SUSPENDIDA:
            a_suspender.append(c.id)

    # 2. HasKanji (informativo)
    v = "1" if activar else ""
    if nota["HasKanji"] != v:
        if not DRY_RUN:
            nota["HasKanji"] = v
        n_kanji += 1
        toco = True

    # 3. Campo Tags basura
    if "Tags" in nota.keys() and nota["Tags"].strip():
        if not DRY_RUN:
            nota["Tags"] = ""
        n_tags += 1
        toco = True

    # 4. Meaning del diccionario
    if "Meaning" in nota.keys() and "data-sc-content" in nota["Meaning"]:
        meaning, jp, en = parsear(nota["Meaning"])

        if meaning:
            if not DRY_RUN:
                nota["Meaning"] = meaning
            n_lim += 1
            toco = True

        if jp and "ExampleJP" in nota.keys() and not strip_html(nota["ExampleJP"]).strip():
            if not DRY_RUN:
                nota["ExampleJP"] = jp
                if en and "ExampleTranslation" in nota.keys():
                    nota["ExampleTranslation"] = en
            n_ej += 1
            toco = True

        if len(muestra) < 12 and (meaning or jp):
            muestra.append((palabra, meaning, jp, en))

    if toco and not DRY_RUN:
        mw.col.update_note(nota)

if not DRY_RUN:
    if a_suspender:
        mw.col.sched.suspend_cards(a_suspender)
    if a_reactivar:
        mw.col.sched.unsuspend_cards(a_reactivar)

mw.reset()

for k, g, j, e in muestra:
    print(f"{k}\n   Meaning: {g}\n   JP: {j}\n   EN: {e}\n")

print("Modo:", "SIMULACION" if DRY_RUN else "APLICADO")
print(f"Tarjeta 3 a suspender: {len(a_suspender)} | a reactivar: {len(a_reactivar)}")
print(f"HasKanji: {n_kanji} | Tags vaciados: {n_tags} | Meaning: {n_lim} | Ejemplos: {n_ej}")