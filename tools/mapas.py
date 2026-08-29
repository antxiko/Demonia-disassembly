#!/usr/bin/env python3
"""Dibuja las pantallas de Demonia desde los bytes de la cinta.

Nada de esto son capturas: aqui no hay emulador. La herramienta repite el
descompresor del propio juego sobre los mapas comprimidos y luego revela cada
baldosa como la revelaria el VDP, con los patrones y los colores que el
cartucho sube a la VRAM. Si las pantallas salen bien es que se han entendido
bien las rutinas; es la comprobacion mas honesta que hay de un desensamblado.

LAS TRES PIEZAS, tal como estan en el listado:

    EL DESCOMPRESOR   0x819D. Dos ordenes y nada mas:

                          0xFF <baldosa> <cuantas>   repite esa baldosa
                          cualquier otro byte        una baldosa suelta

                      con un detalle que importa: lleva la cuenta de 640
                      baldosas en el juego alternativo de registros y CORTA al
                      llegar a cero, aunque la ultima carrera no haya
                      terminado (el `jr z` de 0x81B6). Descomprimir sin ese
                      corte da 642 baldosas, dos de mas.

    LOS PATRONES      0x6000, 2048 bytes = 256 baldosas de 8 bytes.
    LOS COLORES       0x6800, otros 2048, con el mismo reparto.

                      Los sube 0x8150 con `sube_tres_tercios` (0x8164), que
                      manda LOS MISMOS 2048 bytes a los tres tercios de la
                      pantalla -guarda HL con un `push` y lo recupera en cada
                      vuelta-, asi que la baldosa N tiene el mismo dibujo
                      arriba, en medio y abajo. Por eso aqui basta una tabla.

En SCREEN 2 cada byte de color vale para una fila de ocho pixeles: el nibble
alto es la tinta -lo que se pinta donde el patron tiene un 1- y el bajo, el
fondo. El color 0 es transparente y se ve como el borde.

DE DONDE SALEN LAS DIRECCIONES. No estan escritas aqui: se leen de las
directivas `D` de `src/bajo4000.notes`, que es donde viven acotadas una por
una. Asi no hay dos listas que puedan discrepar.

Uso: mapas.py [work/imagen64k.bin] [docs/imagenes]
"""
import os
import re
import struct
import sys
import zlib

NOTAS = os.path.join("src", "bajo4000.notes")
PATRONES = 0x6000
COLORES = 0x6800
COLUMNAS = 32
BALDOSAS = 0x280        # 640: las que cuenta 0x81A2, y donde corta 0x81B6
ESCALA = 2
FILAS_DEL_ROTULO = 8    # las ocho primeras filas de la portada: las letras DEMONIA

# La paleta del TMS9918, en el orden en que la numera el VDP.
PAL = [(0, 0, 0), (0, 0, 0), (33, 200, 66), (94, 220, 120), (84, 85, 237),
       (125, 118, 252), (212, 82, 77), (66, 235, 245), (252, 85, 84),
       (255, 121, 120), (212, 193, 84), (230, 206, 128), (33, 176, 59),
       (201, 91, 186), (204, 204, 204), (255, 255, 255)]


def png(w, h, filas, fn):
    """Un PNG de color verdadero, sin dependencias."""
    raw = b"".join(b"\x00" + bytes(v for p in f for v in p) for f in filas)

    def chunk(t, d):
        return (struct.pack(">I", len(d)) + t + d
                + struct.pack(">I", zlib.crc32(t + d) & 0xffffffff))

    with open(fn, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n"
                + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0))
                + chunk(b"IDAT", zlib.compress(raw))
                + chunk(b"IEND", b""))


def descomprime(b, tope=BALDOSAS):
    """El descompresor de 0x819D, con su corte a las 640."""
    out = []
    i = 0
    while i < len(b) and len(out) < tope:
        if b[i] == 0xFF:
            for _ in range(b[i + 2]):
                if len(out) >= tope:
                    break           # el `jr z` de 0x81B6: corta a media racha
                out.append(b[i + 1])
            i += 3
        else:
            out.append(b[i])
            i += 1
    return out


def lee_los_mapas():
    """Las directivas D de bajo4000.notes: (inicio, fin, nombre)."""
    fuera = []
    for linea in open(NOTAS, encoding="utf-8"):
        m = re.match(r"D\s+(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)\s+(\S+)", linea)
        if m:
            fuera.append((int(m.group(1), 16), int(m.group(2), 16), m.group(3)))
    return fuera


def pinta(img, baldosas, escala=ESCALA):
    """Revela las baldosas como lo haria el VDP: patron + color, fila a fila."""
    filas_baldosa = len(baldosas) // COLUMNAS
    ancho, alto = COLUMNAS * 8 * escala, filas_baldosa * 8 * escala
    lienzo = [[(0, 0, 0)] * ancho for _ in range(alto)]
    for f in range(filas_baldosa):
        for c in range(COLUMNAS):
            n = baldosas[f * COLUMNAS + c]
            for y in range(8):
                pat = img[PATRONES + n * 8 + y]
                col = img[COLORES + n * 8 + y]
                tinta, fondo = PAL[col >> 4], PAL[col & 0x0F]
                for x in range(8):
                    rgb = tinta if pat & (0x80 >> x) else fondo
                    px, py = (c * 8 + x) * escala, (f * 8 + y) * escala
                    for dy in range(escala):
                        for dx in range(escala):
                            lienzo[py + dy][px + dx] = rgb
    return ancho, alto, lienzo


def contacto(hojas, escala=1):
    """Todas las pantallas juntas, en rejilla de cuatro columnas."""
    if not hojas:
        return None
    cols = 4
    filas = (len(hojas) + cols - 1) // cols
    w1, h1 = COLUMNAS * 8 * escala, (BALDOSAS // COLUMNAS) * 8 * escala
    sep = 4
    ancho = cols * w1 + (cols + 1) * sep
    alto = filas * h1 + (filas + 1) * sep
    lienzo = [[(24, 24, 28)] * ancho for _ in range(alto)]
    for i, (_, _, uno) in enumerate(hojas):
        ox = sep + (i % cols) * (w1 + sep)
        oy = sep + (i // cols) * (h1 + sep)
        for y, fila in enumerate(uno):
            for x, p in enumerate(fila):
                lienzo[oy + y][ox + x] = p
    return ancho, alto, lienzo


def main(argv):
    ruta = argv[1] if len(argv) > 1 else os.path.join("work", "imagen64k.bin")
    salida = argv[2] if len(argv) > 2 else os.path.join("docs", "imagenes")
    if not os.path.exists(ruta):
        print("falta %s: hazlo antes con tools/imagen.py" % ruta)
        return 2
    if not os.path.exists(NOTAS):
        print("falta %s" % NOTAS)
        return 2
    img = open(ruta, "rb").read()
    os.makedirs(salida, exist_ok=True)

    mapas = lee_los_mapas()
    if not mapas:
        print("FALLO: no hay ni una directiva D en %s" % NOTAS)
        return 1

    pantallas, malos = [], []
    for ini, fin, nombre in mapas:
        baldosas = descomprime(img[ini:fin])
        if len(baldosas) != BALDOSAS:
            malos.append((nombre, ini, len(baldosas)))
            continue
        ancho, alto, lienzo = pinta(img, baldosas)
        fn = os.path.join(salida, "%s.png" % nombre.replace("_", "-"))
        png(ancho, alto, lienzo, fn)
        print("  %-22s 0x%04X-0x%04X  %4d bytes -> %d baldosas  %s"
              % (nombre, ini, fin, fin - ini, len(baldosas), fn))
        if nombre.startswith("mapa_pantalla"):
            _, _, chico = pinta(img, baldosas, escala=1)
            pantallas.append((ancho, alto, chico))

        # El rotulo del juego, recortado de su propia portada: las ocho
        # primeras filas de baldosas son las letras de DEMONIA. Se saca aqui
        # porque es el mismo dibujo, no una captura ni un montaje.
        if nombre == "portada_titulo":
            alto_rotulo = FILAS_DEL_ROTULO * 8 * ESCALA
            fn = os.path.join(salida, "rotulo.png")
            png(ancho, alto_rotulo, lienzo[:alto_rotulo], fn)
            print("  %-22s las %d primeras filas de la portada  %s"
                  % ("(rotulo DEMONIA)", FILAS_DEL_ROTULO, fn))

    hoja = contacto(pantallas)
    if hoja:
        fn = os.path.join(salida, "pantallas-todas.png")
        png(hoja[0], hoja[1], hoja[2], fn)
        print("  %-22s %d pantallas juntas  %s"
              % ("(hoja de contactos)", len(pantallas), fn))

    print()
    if malos:
        for nombre, ini, n in malos:
            print("  FALLO: %s (0x%04X) da %d baldosas y no %d"
                  % (nombre, ini, n, BALDOSAS))
        return 1
    print("  OK: los %d mapas descomprimen a %d baldosas exactas y estan dibujados"
          % (len(mapas), BALDOSAS))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
