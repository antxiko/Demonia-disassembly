#!/usr/bin/env python3
"""Descomprime la portada y saca el texto que lleva escrito.

POR QUE EXISTE. La portada del juego lleva, ademas del logotipo, dos lineas de
texto que no estan literales en ningun sitio del fichero: salen de descomprimir
el mapa de 0x4281. Son el subtitulo, `L'INTRUSION`, y la firma,
`(C) 1986 PAR SABLATOU CLAUDE`. Publicar eso obliga a que cualquiera pueda
repetirlo, y esto es lo que lo repite.

AVISO, Y ES IMPORTANTE. Esto vuelca el mapa como TEXTO, y por eso solo ve las
baldosas cuyo codigo es ASCII imprimible. **Todo lo demas sale como un punto,
igual que el fondo.** El logotipo **DEMONIA** ocupa las ocho primeras filas y
esta hecho de baldosas graficas, asi que aqui NO SE VE: el rectangulo de puntos
de arriba es el titulo.

Eso ya engano una vez. De este volcado se llego a concluir que "el juego se
titula L'INTRUSION y no DEMONIA", cuando la portada pone DEMONIA en letras
enormes y `L'INTRUSION` debajo en pequeno, de subtitulo. **El juego se llama
Demonia.** Para VER la portada de verdad esta `tools/mapas.py`, que la dibuja
con sus patrones y sus colores en vez de leerla como texto.

EL DESCOMPRESOR es el de 0x819D, traducido instruccion a instruccion:

    0xFF <baldosa> <cuantas>   repite esa baldosa esas veces
    cualquier otro byte        una baldosa suelta

y con un detalle que importa: el bucle lleva la cuenta de 640 baldosas en el
juego alternativo de registros y CORTA al llegar a cero, aunque la ultima
carrera no haya terminado (el `jr z` de 0x81B6). Descomprimir sin ese corte da
642 baldosas, dos de mas. Aqui se corta, como el cartucho.

Uso: portada.py [work/imagen64k.bin]
"""
import os
import sys

MAPA = 0x4281       # portada_titulo, el mapa comprimido
FIN = 0x43DE
COLUMNAS = 32       # la pantalla del juego
BALDOSAS = 0x280    # 640: las que cuenta 0x81A2, y donde corta 0x81B6


def descomprime(b, tope=BALDOSAS):
    """El descompresor de 0x819D, con su corte."""
    out = []
    i = 0
    while i < len(b) and len(out) < tope:
        if b[i] == 0xFF:
            for _ in range(b[i + 2]):
                if len(out) >= tope:
                    break               # el `jr z` de 0x81B6: corta a media racha
                out.append(b[i + 1])
            i += 3
        else:
            out.append(b[i])
            i += 1
    return out


def main(argv):
    ruta = argv[1] if len(argv) > 1 else os.path.join("work", "imagen64k.bin")
    if not os.path.exists(ruta):
        print("falta %s: hazlo antes con tools/imagen.py" % ruta)
        return 2
    img = open(ruta, "rb").read()
    baldosas = descomprime(img[MAPA:FIN])
    print("  mapa 0x%04X-0x%04X: %d bytes comprimidos -> %d baldosas"
          % (MAPA, FIN, FIN - MAPA, len(baldosas)))
    print("  (%d columnas x %d filas)" % (COLUMNAS, len(baldosas) // COLUMNAS))
    print("  ojo: solo se ve lo que es ASCII; el logotipo son baldosas graficas")
    print()
    subtitulo = firma = False
    for f in range(len(baldosas) // COLUMNAS):
        fila = baldosas[f * COLUMNAS:(f + 1) * COLUMNAS]
        txt = "".join(chr(c) if 32 <= c < 127 else "." for c in fila)
        if not txt.strip("."):
            continue
        marca = ""
        if "INTRUSION" in txt:
            marca = "   <- el subtitulo"
            subtitulo = True
        if "SABLATOU" in txt:
            marca = "   <- la firma"
            firma = True
        print("  fila %2d  %s%s" % (f, txt, marca))
    print()
    if subtitulo and firma:
        print("  OK: la portada lleva el subtitulo L'INTRUSION y la firma de 1986")
        print("      (el logotipo DEMONIA no se ve aqui: dibujalo con tools/mapas.py)")
        return 0
    if not subtitulo:
        print("  FALLO: no aparece el subtitulo donde deberia")
    if not firma:
        print("  FALLO: no aparece la firma donde deberia")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
