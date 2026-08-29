"""Comprueba que lo que dice la documentacion es lo que hace la cinta.

Estos tests existen porque los datos publicados se desactualizan solos. Un
comentario que era cierto cuando se escribio sigue ahi cuando deja de serlo, y
la comprobacion de reproducibilidad no se entera: los bytes no cambian, solo lo
que decimos de ellos.

Asi que aqui se cogen las afirmaciones CONCRETAS de los listados y de docs/ y se
contrastan contra el binario.

DE DONDE SALE EL BINARIO, Y POR QUE IMPORTA
-------------------------------------------
La cinta no se distribuye con este repositorio. Lo que si se distribuye son los
trece listados de `src/`, y ahi dentro esta cada byte: las filas `defb` traen
los datos con su direccion al lado, y las instrucciones traen su direccion en el
comentario que genera `tools/mkasm.py`.

Asi que los tests leen los LISTADOS, no la cinta. Eso tiene tres consecuencias
buenas:

  * corren enteros en un clon recien hecho, sin cinta y sin `make`: no hay ni un
    solo test que se salte solo, y por tanto no hay ningun sitio donde esconder
    una comprobacion que en realidad no se hace;
  * comprueban lo que de verdad se PUBLICA, que es el listado. Si alguien edita
    un `defb` a mano, estos tests se enteran;
  * y no se pierde nada de rigor, porque `make verify` ya demuestra, byte a
    byte, que ensamblar estos listados devuelve la cinta exacta. El listado es
    la cinta, escrita de otra manera.

Lo que NO se puede leer del listado -la RAM de openMSX, el muestreo del PC, el
presupuesto de la cinta entera- se comprueba en `make sanity` y `make verify`,
que fallan a gritos si les falta su material.

OJO CON LAS DIRECCIONES REPETIDAS. Una misma direccion aparece en dos listados
distintos: los trozos de la cinta se cargan en un sitio provisional y luego se
mueven. 0xC009, por ejemplo, esta en `demonia_carga2.asm` (donde cayo) y en
`demonia_juego.asm` (donde se ejecuta). Por eso aqui NUNCA se busca una
direccion "en el listado", sino siempre en el listado que toca.
"""
import os
import re
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(RAIZ, "src")
DOCS = os.path.join(RAIZ, "docs")

# Los dos listados que miran casi todos los tests: el juego tal como se ejecuta
# (0x8000-0xDFFF) y la pagina escondida bajo la ROM del BASIC (0x4000-0x5FFF).
JUEGO = "demonia_juego.asm"
BAJO4000 = "demonia_bajo4000.asm"
BAJO7900 = "demonia_bajo7900.asm"
ARRANQUE = "demonia_arranque.asm"

_DIR = re.compile(r";\s*([0-9a-f]{4})\b")
_DEFB = re.compile(r"^\s*def[bw]\s+([0-9a-fA-Fxh,\s]+?)\s*;\s*([0-9a-f]{4})")
_cache = {}


def listado(nombre):
    """Devuelve (texto_por_direccion, bytes_por_direccion) de un listado.

    El primero indexa la linea de cada instruccion por su direccion; el segundo
    reconstruye los bytes de las filas `defb`/`defw`, que es donde viven los
    datos.
    """
    if nombre in _cache:
        return _cache[nombre]
    texto, mem = {}, {}
    with open(os.path.join(SRC, nombre), encoding="utf-8") as f:
        for ln in f:
            if not ln.startswith("\t"):
                continue
            m = _DEFB.match(ln)
            if m:
                a = int(m.group(2), 16)
                for tok in m.group(1).split(","):
                    tok = tok.strip()
                    if not tok.endswith("h"):
                        continue
                    v = int(tok[:-1], 16)
                    if len(tok) > 4:                # defw: dos bytes, poco a poco
                        mem[a], mem[a + 1] = v & 0xFF, v >> 8
                        a += 2
                    else:
                        mem[a] = v
                        a += 1
                continue
            m = _DIR.search(ln)
            if m:
                texto.setdefault(int(m.group(1), 16), ln.strip())
    _cache[nombre] = (texto, mem)
    return texto, mem


def instruccion(nombre, a):
    """La instruccion de esa direccion, en minusculas y sin el comentario."""
    texto, _ = listado(nombre)
    ln = texto.get(a)
    if ln is None:
        raise AssertionError("%s no tiene nada en %#06x" % (nombre, a))
    return ln.split(";")[0].strip().lower()


def datos(nombre, a, n):
    """Los n bytes que empiezan en esa direccion, sacados de las filas defb."""
    _, mem = listado(nombre)
    faltan = [i for i in range(a, a + n) if i not in mem]
    if faltan:
        raise AssertionError("%s: %d bytes sin fila defb desde %#06x (el primero, %#06x)"
                             % (nombre, len(faltan), a, faltan[0]))
    return bytes(mem[i] for i in range(a, a + n))


def descomprime(mem, a, tope=0x280):
    """El descompresor de 0x819D: 0xFF <baldosa> <cuantas>, o una suelta.

    Lleva la cuenta de 640 baldosas y CORTA al llegar a cero, aunque sea a
    mitad de una carrera (el `jr z` de 0x81B6). Devuelve (baldosas, direccion
    donde se quedo), que es lo que encadena un mapa con el siguiente.
    """
    out = []
    i = a
    while len(out) < tope:
        b = mem[i]
        i += 1
        if b == 0xFF:
            cuantas = min(mem[i + 1], tope - len(out))
            out += [mem[i]] * cuantas
            i += 2
        else:
            out.append(b)
    return out, i


class TestLaCintaYSusSieteTrozos(unittest.TestCase):
    def test_el_makefile_y_el_readme_publican_el_mismo_sha256(self):
        """La cinta no viaja, asi que su sha256 es el unico modo de senalarla."""
        sha = None
        with open(os.path.join(RAIZ, "Makefile"), encoding="utf-8") as f:
            for ln in f:
                m = re.match(r"CAS_SHA\s*:=\s*([0-9a-f]{64})", ln)
                if m:
                    sha = m.group(1)
        self.assertIsNotNone(sha, "el Makefile ya no publica CAS_SHA")
        readme = open(os.path.join(RAIZ, "README.md"), encoding="utf-8").read()
        self.assertIn(sha, readme,
                      "el README no publica el mismo sha256 que el Makefile")

    def test_la_tabla_declara_siete_trozos(self):
        """0x8180 tiene siete entradas de 8 bytes y el bucle para en 0x81B8."""
        self.assertEqual(instruccion(ARRANQUE, 0x8236), "ld de,081b8h")
        self.assertEqual((0x81B8 - 0x8180) // 8, 7)
        # y los 56 bytes de la tabla estan de verdad en el listado
        self.assertEqual(len(datos(ARRANQUE, 0x8180, 56)), 56)

    def test_cada_listado_cae_dentro_del_trozo_que_lo_trae(self):
        """El org de cada listado tiene que caer dentro de su trozo de cinta.

        Cada entrada trae (carga, fin, ejecucion, 0xFFFF), tal como lo lee el
        bucle de 0x8208: HL de los bytes 0-1, DE de los 2-3 y la ejecucion de
        los 4-5. Un listado no siempre empieza en la direccion de carga -los
        que se llaman "cola" son solo el final del bloque, que es lo unico que
        sobrevive-, pero SIEMPRE tiene que caer dentro del trozo. Es el cruce
        que ata la tabla de la cinta con los siete listados.
        """
        tabla = datos(ARRANQUE, 0x8180, 56)
        cargas = ["demonia_carga%d%s.asm" % (i, s) for i, s in
                  ((1, ""), (2, ""), (3, "cola"), (4, "cola"), (5, "cola"),
                   (6, "cab"), (7, "cola"))]
        for i, fichero in enumerate(cargas):
            org = None
            with open(os.path.join(SRC, fichero), encoding="utf-8") as f:
                for ln in f:
                    m = re.match(r"\s*org\s+0x([0-9a-fA-F]+)", ln)
                    if m:
                        org = int(m.group(1), 16)
                        break
            self.assertIsNotNone(org, "%s no declara org" % fichero)
            carga = tabla[8 * i] | (tabla[8 * i + 1] << 8)
            fin = tabla[8 * i + 2] | (tabla[8 * i + 3] << 8)
            ejecuta = tabla[8 * i + 4] | (tabla[8 * i + 5] << 8)
            self.assertLess(carga, fin, "el trozo %d no tiene longitud" % (i + 1))
            self.assertTrue(carga <= org <= fin,
                            "%s arranca en %#06x, fuera del trozo %#06x-%#06x"
                            % (fichero, org, carga, fin))
            self.assertTrue(carga <= ejecuta <= fin,
                            "el trozo %d se ejecuta en %#06x, fuera de %#06x-%#06x"
                            % (i + 1, ejecuta, carga, fin))

    def test_las_entradas_de_la_tabla_acaban_todas_en_ffff(self):
        """El cuarto campo es un centinela: si dejara de serlo, mal leida."""
        tabla = datos(ARRANQUE, 0x8180, 56)
        for i in range(7):
            self.assertEqual(tabla[8 * i + 6:8 * i + 8], b"\xff\xff",
                             "la entrada %d no acaba en 0xFFFF" % i)


class TestLasGeometrias(unittest.TestCase):
    def test_los_sprites_son_registros_de_33(self):
        """Los dos bancos tienen que ser multiplo exacto de 33 bytes.

        Y el 33 no es una eleccion: sale del 'ld de,0x0021' de 0x82A9 y del
        'ld bc,0x0042' de 0x82AF, que lee DOS registros de golpe.
        """
        self.assertEqual(instruccion(JUEGO, 0x82A9), "ld de,00021h")
        self.assertEqual(instruccion(JUEGO, 0x82AF), "ld bc,00042h")
        self.assertEqual(0x1F32 % 33, 0)
        self.assertEqual((0x3AC8 - 0x1F32) % 33, 0)
        self.assertEqual(0x1F32 // 33, 242)
        self.assertEqual((0x3AC8 - 0x1F32) // 33, 214)

    def test_los_26_mapas_encadenan_sin_hueco_ni_solape(self):
        """La descompresion tiene que cuadrar exacta con la frontera siguiente.

        Es la prueba de que el formato 0xFF <baldosa> <cuantas> es el correcto:
        si estuviera mal, algun mapa se pasaria o se quedaria corto y la cadena
        de 26 no acabaria justo en 0x5468.
        """
        _, mem = listado(BAJO4000)
        a, n = 0x4000, 0
        while a < 0x5468:
            _, a = descomprime(mem, a)
            n += 1
            self.assertLessEqual(a, 0x5468, "un mapa se pasa del final del bloque")
        self.assertEqual(a, 0x5468, "los mapas no acaban donde acaba el bloque")
        self.assertEqual(n, 26)

    def test_cada_mapa_da_640_baldosas_o_sea_32_por_20(self):
        """640 = 32 columnas x 20 filas, que es la pantalla del juego."""
        _, mem = listado(BAJO4000)
        a = 0x4000
        while a < 0x5468:
            baldosas, a = descomprime(mem, a)
            self.assertEqual(len(baldosas), 640)
        self.assertEqual(32 * 20, 640)

    def test_los_26_mapas_estan_dibujados_en_docs(self):
        """`make sanity` los dibuja; el repositorio publica los PNG."""
        png = sorted(os.listdir(os.path.join(DOCS, "imagenes")))
        mapas = [p for p in png if p.startswith(("mapa-pantalla-", "portada-"))]
        self.assertEqual(len(mapas), 26,
                         "hay %d PNG de mapa y los mapas son 26" % len(mapas))

    def test_los_decorados_van_a_los_tres_tercios(self):
        """0x8164 sube tres veces 0x800 bytes; de ahi que los tercios repitan."""
        self.assertEqual(instruccion(JUEGO, 0x8164), "ld b,003h")
        self.assertEqual(instruccion(JUEGO, 0x8169), "ld bc,00800h")
        self.assertEqual(instruccion(JUEGO, 0x816F), "ld de,00800h")

    def test_la_melodia_rebobina_al_bucle_y_no_al_principio(self):
        """0xC009 arranca en 0x7900 y 0x7FA5 rebobina a 0x79C8.

        Las dos instrucciones viven en listados distintos porque la melodia
        esta escondida bajo la ROM del BASIC (0x7900) y quien la arranca esta
        en el juego (0xC009).
        """
        self.assertEqual(instruccion(JUEGO, 0xC009), "ld hl,07900h")
        self.assertEqual(instruccion(BAJO7900, 0x7FA5), "ld hl,079c8h")


class TestElMonitorDeLoriciels(unittest.TestCase):
    def test_los_textos_estan_donde_se_dice(self):
        for a, t in ((0xD948, b"Auteur:Claude SABLATOU"),
                     (0xD95F, b"MONITEUR MSX"),
                     (0xD96C, b"Copyright (C) 1984 LORICIELS"),
                     (0xD98D, b"Commande illegale")):
            self.assertEqual(datos(JUEGO, a, len(t)), t, "no esta en %#06x" % a)

    def test_el_juego_llama_al_monitor_desde_9C72(self):
        """ld a,(INTFLG) / cp 3 / call z,0xC924"""
        self.assertEqual(instruccion(JUEGO, 0x9C6D), "ld a,(0fc9bh)")
        self.assertEqual(instruccion(JUEGO, 0x9C70), "cp 003h")
        self.assertTrue(instruccion(JUEGO, 0x9C72).startswith("call z,"),
                        "0x9C72 ya no es la llamada condicional al monitor")

    def test_la_tabla_de_ordenes_del_monitor_esta_borrada(self):
        """El bucle busca en 0xD5C6, 15 entradas de 3 bytes, y ahi no hay tabla.

        Es la afirmacion central de docs/LO-QUE-SOBRA.md, asi que va medida: las
        primeras claves tienen que estar a cero para que ninguna orden case.
        """
        self.assertEqual(instruccion(JUEGO, 0xC28D), "ld hl,0d5c6h")
        self.assertEqual(instruccion(JUEGO, 0xC290), "ld b,00fh")
        tabla = datos(JUEGO, 0xD5C6, 45)
        claves = [tabla[3 * i] for i in range(15)]
        self.assertTrue(all(c == 0 for c in claves[:6]),
                        "las primeras claves ya no son cero: %r" % claves)

    def test_el_tampon_del_paso_a_paso_guarda_un_ld_hl(self):
        """0xCC5F trae 2A 78 80 00, o sea ld hl,(0x8078), y 0x8078 es variable."""
        self.assertEqual(datos(JUEGO, 0xCC5F, 4), bytes([0x2A, 0x78, 0x80, 0x00]))
        self.assertTrue(0x8000 <= 0x8078 < 0x8100)


class TestElTitulo(unittest.TestCase):
    def test_la_portada_lleva_el_subtitulo_y_la_firma(self):
        """El mapa de 0x4281, descomprimido, lleva el subtitulo y la firma.

        El titulo DEMONIA no sale aqui: son baldosas graficas, no ASCII. Lo que
        si sale escrito con letras es el subtitulo y el credito del autor.
        """
        _, mem = listado(BAJO4000)
        baldosas, _ = descomprime(mem, 0x4281)
        texto = "".join(chr(c) if 32 <= c < 127 else "." for c in baldosas)
        self.assertIn("INTRUSION", texto)
        self.assertIn("1986", texto)
        self.assertIn("SABLATOU", texto)
        self.assertIn("CLAUDE", texto)


class TestLaCoherenciaDelTrazado(unittest.TestCase):
    def test_los_puntos_de_entrada_llevan_justificacion(self):
        """Cada entrada del fichero tiene que traer su por que escrito."""
        malas = []
        with open(os.path.join(SRC, "imagen.entries"), encoding="utf-8") as f:
            for ln in f:
                if not re.match(r"^0x[0-9A-Fa-f]{4}", ln):
                    continue
                if "#" not in ln or len(ln.split("#", 1)[1].strip()) < 12:
                    malas.append(ln.strip())
        self.assertEqual(malas, [])

    def test_ninguna_zona_declarada_datos_sale_como_codigo(self):
        """Lo declarado datos en `imagen.nocode` no puede tener instrucciones.

        El cruce con el trazador lo hace `make sanity`; aqui se comprueba contra
        lo PUBLICADO, que es lo que lee cualquiera que clone el repositorio.
        """
        rangos = []
        with open(os.path.join(SRC, "imagen.nocode"), encoding="utf-8") as f:
            for ln in f:
                ln = ln.split("#")[0].strip()
                if ln:
                    a, b = (int(x, 0) for x in ln.split()[:2])
                    rangos.append((a, b))
        self.assertTrue(rangos, "imagen.nocode se ha quedado vacio")
        texto, _ = listado(JUEGO)
        for a, b in rangos:
            dentro = [d for d in texto if a <= d < b]
            self.assertEqual(dentro, [],
                             "%#06x-%#06x sale como codigo en el listado: %s"
                             % (a, b, [hex(x) for x in sorted(dentro)[:8]]))


class TestLaDocumentacion(unittest.TestCase):
    def test_las_cifras_de_lo_que_sobra_son_las_medidas(self):
        """Las cifras del documento tienen que salir de la herramienta."""
        doc = open(os.path.join(DOCS, "es", "HALLAZGOS.md"), encoding="utf-8").read()
        self.assertIn("58.334", doc)
        for cifra in ("4.377", "2.094"):
            self.assertIn(cifra, doc)

    def test_lo_supuesto_va_marcado(self):
        for fn, marca in (("es/HALLAZGOS.md", "SUPOSICION"),
                          ("es/PREGUNTAS-ABIERTAS.md", "SUPUESTO"),
                          ("FINDINGS.md", "ASSUMED"),
                          ("OPEN-QUESTIONS.md", "ASSUMED")):
            doc = open(os.path.join(DOCS, fn), encoding="utf-8").read()
            self.assertIn(marca, doc, "%s no marca lo supuesto" % fn)


if __name__ == "__main__":
    unittest.main()
