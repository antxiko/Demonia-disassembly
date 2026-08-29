#!/usr/bin/env python3
"""Genera la portada de la web, en los dos idiomas.

El diseno es el compartido por la serie (tools/estilo_web.py) y la pagina sale
autocontenida, con las imagenes embebidas como data URI.

AQUI NO HAY NI UNA CAPTURA. Todas las imagenes de la galeria las dibuja
tools/mapas.py desde los bytes de la cinta: repite el descompresor de 0x819D
sobre los mapas comprimidos y luego revela cada baldosa como la revelaria el
VDP, con los patrones de 0x6000 y los colores de 0x6800. Si un rango estuviera
mal etiquetado, saldria ruido.

El rotulo de la cabecera tampoco es un montaje: son las ocho primeras filas de
la propia portada del juego, recortadas por la misma herramienta.

Uso: make_web.py <docs/imagenes> <salida.html> <idioma>
"""
import base64
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from estilo_web import ESTILO                                   # noqa: E402

# Las cifras salen de las herramientas, no de escribirlas aqui a ojo:
# tools/presupuesto.py (make verify) da el reparto de la cinta, y
# tools/densidad_total.py (make densidad) las rutinas y la densidad.
CINTA = 58334
CODIGO = 20299
DATOS = 37597
LISTADOS = 13
RUTINAS = 1308
ENTRADAS = 55                       # puntos de entrada, todos justificados
MAPAS = 26
MONITOR = 4377                      # los bytes del monitor de Loriciels
DENSIDAD_ES = "33,0 %"
DENSIDAD_EN = "33.0%"


def mil(n, idioma):
    return f"{n:,}".replace(",", "." if idioma == "es" else ",")


TXT = {
    "es": dict(
        titulo="Demonia — desensamblado comentado",
        aviso="<b>Aquí no hay ni una captura de pantalla.</b> Todas las "
              "imágenes están <b>dibujadas desde la cinta</b>: una herramienta "
              "repite el descompresor del propio juego sobre los mapas "
              "comprimidos y luego revela cada baldosa como la revelaría el "
              "VDP, con sus patrones y sus colores. Que las pantallas salgan "
              "bien es la prueba de que las rutinas se han entendido bien. El "
              "listado y las cifras salen del binario y se reproducen con "
              "<code>make</code>.",
        claim="Un juego que no cabe en la RAM visible de un MSX y esconde "
              "veintiséis kilobytes <b>debajo de la ROM del BASIC</b>. Y "
              "dentro, de polizón, un monitor de código máquina de 1984 del "
              "mismo autor: con su puerta trasera todavía enchufada, sus "
              "órdenes tapadas por los datos del juego, y en el buffer del "
              "paso a paso la última instrucción que ejecutó antes de que "
              "alguien grabara la cinta.",
        ficha=["Microids · <b>1986</b>",
               "Cinta, <b>58.334 bytes</b>",
               "MSX1 · <b>64 KB</b>",
               "Firma: <b>(C) 1986 PAR SABLATOU CLAUDE</b>"],
        nav=[("#numbers", "Las cifras"), ("#findings", "Hallazgos"),
             ("#screens", "Lo que dibuja")],
        docnav=[("EMPEZAR.html", "Empezar"), ("EL-JUEGO.html", "El juego"),
                ("LA-CINTA.html", "La cinta"),
                ("EL-CODIGO.html", "El código"),
                ("HALLAZGOS.html", "Hallazgos"),
                ("PREGUNTAS-ABIERTAS.html", "Preguntas abiertas")],
        otro=("../", "In English"),
        h_num="La cinta en cifras", h_find="Lo que apareció al desmontarla",
        h_scr="Lo que la cinta dibuja",
        cifras=[("100 %", "de la cinta explicada"),
                (str(LISTADOS), "listados"),
                (mil(RUTINAS, "es"), "rutinas identificadas"),
                (mil(CODIGO, "es"), "bytes de código"),
                (mil(DATOS, "es"), "bytes de datos"),
                ("0", "bytes sin identificar"),
                (DENSIDAD_ES, "de densidad de comentarios"),
                (str(MAPAS), "mapas de pantalla dibujados")],
        nota_scr="Debajo de cada pie está la dirección de donde sale. Todas "
                 "se rehacen con <code>make imagenes</code> y no hace falta "
                 "emulador.",
        pie_leg="Esto es trabajo de documentación y preservación: el código y "
                "los gráficos siguen siendo de sus autores, y la cinta no se "
                "distribuye.",
    ),
    "en": dict(
        titulo="Demonia — a commented disassembly",
        aviso="<b>There is not a single screenshot here.</b> Every picture is "
              "<b>drawn from the tape</b>: a tool replays the game's own "
              "decompressor over the compressed maps and then develops each "
              "tile the way the VDP would, with its patterns and its colours. "
              "The screens coming out right is the proof that the routines "
              "have been understood. The listing and the numbers come from "
              "the binary and are reproduced with <code>make</code>.",
        claim="A game that does not fit in the visible RAM of an MSX and "
              "hides twenty-six kilobytes <b>underneath the BASIC ROM</b>. "
              "And inside, stowing away, a 1984 machine code monitor by the "
              "same author: its back door still wired up, its command table "
              "buried under the game's own data, and in the single-step "
              "buffer the last instruction it ever ran before someone saved "
              "the tape.",
        ficha=["Microids · <b>1986</b>",
               "Tape, <b>58,334 bytes</b>",
               "MSX1 · <b>64 KB</b>",
               "Signed: <b>(C) 1986 PAR SABLATOU CLAUDE</b>"],
        nav=[("#numbers", "The numbers"), ("#findings", "What turned up"),
             ("#screens", "What it draws")],
        docnav=[("GETTING-STARTED.html", "Getting started"),
                ("THE-GAME.html", "The game"),
                ("THE-TAPE.html", "The tape"),
                ("THE-CODE.html", "The code"),
                ("FINDINGS.html", "Findings"),
                ("OPEN-QUESTIONS.html", "Open questions")],
        otro=("es/", "En castellano"),
        h_num="The tape in numbers",
        h_find="What turned up when we took it apart",
        h_scr="What the tape draws",
        cifras=[("100%", "of the tape explained"),
                (str(LISTADOS), "listings"),
                (mil(RUTINAS, "en"), "routines identified"),
                (mil(CODIGO, "en"), "bytes of code"),
                (mil(DATOS, "en"), "bytes of data"),
                ("0", "bytes unidentified"),
                (DENSIDAD_EN, "comment density"),
                (str(MAPAS), "screen maps drawn")],
        nota_scr="Under each caption is the address it comes from. They are "
                 "all rebuilt by <code>make imagenes</code> and no emulator "
                 "is needed.",
        pie_leg="This is documentation and preservation work: the code and "
                "artwork still belong to their authors, and the tape is not "
                "distributed.",
    ),
}

HALLAZGOS = {
    "es": [
        ("Dentro del juego viaja un monitor de código máquina de 1984",
         "<p>De 0xC000 en adelante, dentro del bloque del juego, hay un "
         "<b>programa entero que no es el juego</b>: un monitor de código "
         "máquina con su intérprete de órdenes, su desensamblador, su paso a "
         "paso, su volcado de registros y sus mensajes de error en francés. "
         "Son <b>4.377 bytes</b>, el 7,5 % de la cinta.</p>"
         "<p>Va firmado, en 0xD948: <code>Auteur:Claude SABLATOU</code>, "
         "<code>MONITEUR MSX</code>, <code>Copyright (C) 1984 LORICIELS</code>. "
         "Y la portada del juego, que se lee descomprimiendo el mapa de "
         "0x4281, dice <code>(C) 1986 PAR SABLATOU CLAUDE</code>. El autor del "
         "juego se dejó dentro su propia herramienta de trabajo: un monitor de "
         "Loriciels de 1984 viajando en un juego de Microids de 1986.</p>"),
        ("Y su puerta trasera sigue enchufada",
         "<p>El punto de entrada del monitor, 0xC924, se llama de verdad desde "
         "el código del juego, en 0x9C6D:</p>"
         "<pre>9C6D  3A 9B FC    ld a,(0xFC9B)   ; INTFLG\n"
         "9C70  FE 03       cp 3\n"
         "9C72  CC 24 C9    call z,0xC924   ; y al monitor</pre>"
         "<p>0xFC9B es INTFLG, la variable donde la BIOS anota que se ha "
         "pulsado STOP, y el valor 3 es el de CTRL+STOP. Hay una segunda "
         "llamada suelta, <code>call 0xC924</code> en 0xAA95, a la que ya no "
         "llega ningún salto.</p>"
         "<p><i>Medido: los bytes y qué es 0xFC9B. Que la intención fuera "
         "dejarse una puerta abierta es una lectura, no un dato.</i></p>"),
        ("Pero el monitor ya no obedece a nada",
         "<p>Reconoce sus órdenes buscando la inicial tecleada en una tabla de "
         "quince entradas de tres bytes que empieza en 0xD5C6 "
         "(<code>ld hl,0xD5C6</code> / <code>ld b,15</code>, en 0xC28D). "
         "<b>En 0xD5C6 no hay ninguna tabla.</b></p>"
         "<p>Las 24 fichas de pantalla del juego ocupan de 0xD0C0 a 0xD8FF, 88 "
         "bytes cada una, y 0xD5C6 cae en mitad de la ficha número 14. Los "
         "datos del juego se escribieron encima de la tabla de órdenes. Con "
         "las quince claves a cero, cualquier tecla recorre las quince "
         "entradas sin éxito, imprime <code>Commande illegale</code> y vuelve "
         "a pedir: <b>el monitor arranca, pinta los registros y no hace "
         "nada más</b>. De ahí salen 2.094 bytes de código al que no llega "
         "nadie.</p>"),
        ("El fósil: la última instrucción que ese monitor ejecutó",
         "<p>El paso a paso funciona copiando la instrucción del programa "
         "detenido a un buffer de cuatro bytes en 0xCC5F y ejecutándola allí. "
         "0xCBB9 pone esos cuatro bytes a cero antes de cada paso, así que lo "
         "que quedó grabado en la cinta es lo último que pasó por ahí:</p>"
         "<pre>CC5F  2A 78 80 00      ld hl,(0x8078)</pre>"
         "<p>Y 0x8078 cae dentro de la página de variables de este mismo "
         "juego.</p>"
         "<p><i>Medido: los cuatro bytes, que 0xCBB9 los borra y 0xCBDB los "
         "rellena, y dónde cae 0x8078. Que fuera una sesión de depuración de "
         "este juego encaja, pero el binario no lo dice.</i></p>"),
        ("Veintiséis kilobytes escondidos debajo de la ROM del BASIC",
         "<p>El juego no cabe en la RAM que ve un MSX arrancado desde BASIC. "
         "Lo que hace es buscar un slot con 64 KB y meter <b>26 KB en las "
         "páginas 0 y 1</b>, debajo de la ROM.</p>"
         "<p>Los siete bloques que la cinta trae detrás del cargador no se "
         "ejecutan donde se cargan: cada uno lleva pegada una rutinilla que "
         "conmuta el slot, hace un <code>LDIR</code> y lo devuelve. Por eso "
         "aquí hay trece listados y no siete, y por eso el <code>verify</code> "
         "tiene dos pasos.</p>"
         "<p>Los cinco trozos escondidos coinciden <b>byte a byte</b> con la "
         "RAM de openMSX con el juego en marcha, y con las instantáneas de un "
         "replay grabado en otra máquina. Dos medidas independientes.</p>"),
        ("Dos ficheros que se llaman igual, y un <code>:RUN</code> que los separa",
         "<p>En la cinta hay tres ficheros con nombre y <b>los tres se llaman "
         "<code>DEMON</code></b>: el cargador BASIC, un BIN de 249 bytes que "
         "carga en 0x8180 y un BIN de 24.576 que carga en 0x8000.</p>"
         "<p>La línea 50 del cargador es <code>BLOAD\"CAS:DEMON\",R:RUN</code>. "
         "Como la cinta es secuencial, la primera vez encuentra el BIN "
         "pequeño —el cargador de los siete bloques— y, después del "
         "<code>RUN</code>, la segunda pasada encuentra el grande, que ya es "
         "el juego. Se llaman igual a propósito.</p>"),
        ("La portada pone DEMONIA, y hubo que dibujarla para verlo",
         "<p>Si el mapa de la portada se vuelca como <b>texto</b>, sólo se leen "
         "dos filas: <code>L'INTRUSION</code> en la 17 y <code>(C) 1986 PAR "
         "SABLATOU CLAUDE</code> en la 19. Lo demás sale como puntos.</p>"
         "<p>Y no es que no haya nada: es que <b>el título está hecho de "
         "baldosas gráficas, no de ASCII</b>. Dibujada con sus patrones, la "
         "pantalla pone DEMONIA en letras enormes ocupando las ocho primeras "
         "filas, con <code>L'INTRUSION</code> pequeño debajo, de subtítulo. "
         "Es el rótulo de la cabecera de esta página, recortado de ahí "
         "mismo.</p>"),
        ("Y cosas que llevan sin ejecutarse desde 1986",
         "<p><b>0x9134</b>: la misma instrucción escrita dos veces, "
         "<code>ld hl,0x8058</code> seguida de <code>ld hl,0x8058</code>. Tres "
         "bytes que no hacen nada.</p>"
         "<p><b>Ocho bytes de <code>ret</code> condicionales imposibles</b>: "
         "en 0x823A hay tres <code>ret nc</code> seguidos, y en 0x8C3E y "
         "0xBFE3 hay pares y ternas de <code>ret nz</code>. Cuando dos vuelven "
         "con la misma condición, el segundo no llega a correr nunca.</p>"
         "<p><b>Cincuenta bytes de NOP dentro de código vivo</b>, en once "
         "rachas. Las dos de seis de 0xDC01 y 0xDC12 están justo delante y "
         "justo detrás de un <code>LDIR</code> que copia tablas a la RAM "
         "escondida: exactamente donde iría una conmutación de slot que "
         "alguien quitó.</p>"),
    ],
    "en": [
        ("A 1984 machine code monitor stows away inside the game",
         "<p>From 0xC000 onwards, inside the game block, sits <b>a whole "
         "program that is not the game</b>: a machine code monitor with its "
         "command interpreter, its disassembler, its single-step, its register "
         "dump and its error messages in French. That is <b>4,377 bytes</b>, "
         "7.5% of the tape.</p>"
         "<p>It is signed, at 0xD948: <code>Auteur:Claude SABLATOU</code>, "
         "<code>MONITEUR MSX</code>, <code>Copyright (C) 1984 LORICIELS</code>. "
         "And the game's title screen, read by decompressing the map at "
         "0x4281, says <code>(C) 1986 PAR SABLATOU CLAUDE</code>. The author "
         "left his own working tool inside: a 1984 Loriciels monitor riding "
         "along in a 1986 Microids game.</p>"),
        ("And its back door is still wired up",
         "<p>The monitor's entry point, 0xC924, really is called from the "
         "game's own code, at 0x9C6D:</p>"
         "<pre>9C6D  3A 9B FC    ld a,(0xFC9B)   ; INTFLG\n"
         "9C70  FE 03       cp 3\n"
         "9C72  CC 24 C9    call z,0xC924   ; and into the monitor</pre>"
         "<p>0xFC9B is INTFLG, where the BIOS records that STOP was pressed, "
         "and 3 is the value for CTRL+STOP. There is a second, loose "
         "<code>call 0xC924</code> at 0xAA95 that no branch reaches any "
         "more.</p>"
         "<p><i>Measured: the bytes and what 0xFC9B is. That the intent was to "
         "leave a door open is a reading, not a fact.</i></p>"),
        ("But the monitor no longer obeys anything",
         "<p>It recognises its commands by looking the typed initial up in a "
         "table of fifteen three-byte entries starting at 0xD5C6 "
         "(<code>ld hl,0xD5C6</code> / <code>ld b,15</code>, at 0xC28D). "
         "<b>There is no table at 0xD5C6.</b></p>"
         "<p>The game's 24 screen records run from 0xD0C0 to 0xD8FF, 88 bytes "
         "each, and 0xD5C6 lands in the middle of record 14. The game's data "
         "was written straight over the command table. With all fifteen keys "
         "zero, any keypress walks the fifteen entries in vain, prints "
         "<code>Commande illegale</code> and asks again: <b>the monitor boots, "
         "paints the registers and does nothing else</b>. That accounts for "
         "2,094 bytes of code nobody can reach.</p>"),
        ("The fossil: the last instruction that monitor ever ran",
         "<p>Single-stepping works by copying the stopped program's "
         "instruction into a four-byte buffer at 0xCC5F and running it there. "
         "0xCBB9 clears those four bytes before every step, so what was left "
         "recorded on the tape is the last thing that went through it:</p>"
         "<pre>CC5F  2A 78 80 00      ld hl,(0x8078)</pre>"
         "<p>And 0x8078 falls inside this very game's variable page.</p>"
         "<p><i>Measured: the four bytes, that 0xCBB9 clears them and 0xCBDB "
         "fills them, and where 0x8078 lands. That it was a debugging session "
         "on this game fits, but the binary does not say so.</i></p>"),
        ("Twenty-six kilobytes hidden underneath the BASIC ROM",
         "<p>The game does not fit in the RAM an MSX booted into BASIC can "
         "see. What it does is look for a 64 KB slot and put <b>26 KB into "
         "pages 0 and 1</b>, underneath the ROM.</p>"
         "<p>The seven blocks the tape carries behind the loader are not run "
         "where they land: each one has a little routine glued to it that "
         "switches the slot, does an <code>LDIR</code> and switches it back. "
         "That is why there are thirteen listings here and not seven, and why "
         "<code>verify</code> takes two passes.</p>"
         "<p>The five hidden chunks match the RAM of a running openMSX "
         "<b>byte for byte</b>, and also the RAM snapshots inside a replay "
         "recorded on a different machine. Two independent measurements.</p>"),
        ("Two files with the same name, and a <code>:RUN</code> that tells them apart",
         "<p>The tape holds three named files and <b>all three are called "
         "<code>DEMON</code></b>: the BASIC loader, a 249-byte BIN loading at "
         "0x8180 and a 24,576-byte BIN loading at 0x8000.</p>"
         "<p>Line 50 of the loader is <code>BLOAD\"CAS:DEMON\",R:RUN</code>. "
         "Since tape is sequential, the first pass finds the small BIN — the "
         "loader for the seven blocks — and, after the <code>RUN</code>, the "
         "second pass finds the big one, which is the game. They share a name "
         "on purpose.</p>"),
        ("The title screen says DEMONIA, and it had to be drawn to see it",
         "<p>Dump the title map as <b>text</b> and only two rows read back: "
         "<code>L'INTRUSION</code> on row 17 and <code>(C) 1986 PAR SABLATOU "
         "CLAUDE</code> on row 19. Everything else comes out as dots.</p>"
         "<p>It is not that there is nothing there: <b>the title is made of "
         "graphic tiles, not ASCII</b>. Drawn with its patterns, the screen "
         "spells DEMONIA in huge letters across the first eight rows, with a "
         "small <code>L'INTRUSION</code> underneath as a subtitle. That is the "
         "wordmark at the top of this page, cropped straight out of it.</p>"),
        ("And things that have not run since 1986",
         "<p><b>0x9134</b>: the same instruction written twice, "
         "<code>ld hl,0x8058</code> followed by <code>ld hl,0x8058</code>. "
         "Three bytes that do nothing.</p>"
         "<p><b>Eight bytes of impossible conditional returns</b>: 0x823A has "
         "three <code>ret nc</code> in a row, and 0x8C3E and 0xBFE3 have pairs "
         "and triples of <code>ret nz</code>. When two return on the same "
         "condition, the second never gets to run.</p>"
         "<p><b>Fifty bytes of NOP inside live code</b>, in eleven runs. The "
         "two runs of six at 0xDC01 and 0xDC12 sit immediately before and "
         "after an <code>LDIR</code> that copies tables into the hidden RAM: "
         "exactly where a slot switch someone removed would have gone.</p>"),
    ],
}

GALERIA = [
    ("portada-titulo.png",
     "DIBUJADA de 0x4281 — la portada. DEMONIA en las ocho primeras filas, en "
     "baldosas graficas; debajo, pequenos, el subtitulo L'INTRUSION y la firma "
     "del autor",
     "DRAWN from 0x4281 — the title screen. DEMONIA across the first eight "
     "rows, in graphic tiles; underneath, small, the L'INTRUSION subtitle and "
     "the author's signature"),
    ("portada-fondo.png",
     "DIBUJADA de 0x4000 — el primer mapa de la portada, sin el titulo. No lo "
     "apunta la tabla de 0xD000: la portada se monta en tres pasadas",
     "DRAWN from 0x4000 — the first title-screen map, with no wordmark. The "
     "table at 0xD000 does not point at it: the title screen is built in three "
     "passes"),
    ("portada-vacia.png",
     "DIBUJADA de 0x418A — la portada casi entera a la baldosa 0. Es el paso "
     "intermedio con el que se borra la pantalla antes de poner el titulo",
     "DRAWN from 0x418A — the title screen almost entirely tile 0. This is the "
     "intermediate step that clears the screen before the wordmark goes on"),
    ("pantallas-todas.png",
     "Las pantallas del juego, dibujadas una a una desde los mapas comprimidos "
     "de 0x43DE a 0x5468 y puestas juntas. El cementerio de la superficie "
     "arriba, las cuevas debajo. Son 24 entradas en la tabla de 0xD000 pero "
     "23 mapas distintos: las pantallas 13 y 14 apuntan al mismo",
     "The game screens, drawn one by one from the compressed maps between "
     "0x43DE and 0x5468 and laid out together. The graveyard up top, the caves "
     "below. That is 24 entries in the table at 0xD000 but only 23 distinct "
     "maps: screens 13 and 14 point at the same one"),
    ("mapa-pantalla-00.png",
     "DIBUJADA de 0x43DE — la primera pantalla: la puerta, una lapida y la "
     "hierba sobre la tierra roja. 204 bytes comprimidos dan las 640 baldosas",
     "DRAWN from 0x43DE — the first screen: the door, a headstone and the "
     "grass over red earth. 204 compressed bytes yield all 640 tiles"),
    ("mapa-pantalla-08.png",
     "DIBUJADA de 0x48FA — 334 bytes comprimidos, de los mas caros de la "
     "cinta. Las galerias de ladrillo, con sus estalagmitas",
     "DRAWN from 0x48FA — 334 compressed bytes, one of the most expensive on "
     "the tape. The brick galleries, with their stalagmites"),
    ("mapa-pantalla-02.png",
     "DIBUJADA de 0x451D — el mapa mas barato de la cinta: 81 bytes. Cuanto "
     "mas se repite una baldosa, menos ocupa el mapa",
     "DRAWN from 0x451D — the cheapest map on the tape: 81 bytes. The more a "
     "tile repeats, the less the map costs"),
    ("mapa-pantalla-15.png",
     "DIBUJADA de 0x4E54 — 347 bytes, el mapa mas largo de los 26. La escalera "
     "roja y el agua son baldosas como las demas: no hay objetos, solo el mapa",
     "DRAWN from 0x4E54 — 347 bytes, the longest of the 26. The red ladder and "
     "the water are tiles like any other: there are no objects, only the map"),
]


def img64(ruta):
    with open(ruta, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main(argv):
    if len(argv) < 4:
        print(__doc__)
        return 2
    imgdir, salida, idioma = argv[1:4]
    t = TXT[idioma]

    # El rotulo del JUEGO: rotulo.png son las ocho primeras filas de la propia
    # portada, recortadas por tools/mapas.py. No es una captura ni un montaje.
    ruta_logo = os.path.join(imgdir, "rotulo.png")
    cabecera = (f'<img src="{img64(ruta_logo)}" alt="Demonia">'
                if os.path.exists(ruta_logo) else "<h1>Demonia</h1>")

    nav = "".join(f'<a href="{h}">{x}</a>' for h, x in t["nav"])
    nav += "".join(f'<a href="{h}">{x}</a>' for h, x in t["docnav"])
    nav += (f'<a href="{t["otro"][0]}" style="margin-left:auto;color:var(--oro)">'
            f'{t["otro"][1]}</a>')

    cifras = "".join(f'<div class="cifra"><b>{v}</b><span>{e}</span></div>'
                     for v, e in t["cifras"])
    halls = "".join(f'<div class="hall"><h3>{tit}</h3>{cuerpo}</div>'
                    for tit, cuerpo in HALLAZGOS[idioma])
    imgs = ""
    faltan = []
    for fich, es, en in GALERIA:
        ruta = os.path.join(imgdir, fich)
        if not os.path.exists(ruta):
            faltan.append(fich)
            continue
        pie = es if idioma == "es" else en
        imgs += (f'<figure><img src="{img64(ruta)}" alt="{pie}">'
                 f'<figcaption>{pie}</figcaption></figure>')
    if faltan:
        print("  (faltan %d imagenes: %s)" % (len(faltan), " ".join(faltan)))

    html = f"""<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>{t['titulo']}</title>
<style>{ESTILO}</style>
<header class="top">
  {cabecera}
  <p class="claim">{t['claim']}</p>
  <p class="ficha">{' · '.join(t['ficha'])}</p>
</header>
<p class="ficha" style="border:1px solid var(--oro);padding:.8em 1em;margin:1.5em 0">
{t['aviso']}</p>
<nav>{nav}</nav>
<section id="numbers">
  <h2>{t['h_num']}</h2>
  <div class="cifras">{cifras}</div>
</section>
<section id="findings"><h2>{t['h_find']}</h2>{halls}</section>
<section id="screens">
  <h2>{t['h_scr']}</h2>
  <p class="n">{t['nota_scr']}</p>
  <div class="galeria">{imgs}</div>
</section>
<footer><p>{t['pie_leg']}</p></footer>
"""
    with open(salida, "w", encoding="utf-8") as f:
        f.write(html)
    print("  %s: %d KB (%s)" % (salida, len(html) // 1024, idioma))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
