#!/usr/bin/env python3
"""Monta la imagen de 64K tal como queda la memoria una vez cargado el juego.

Demonia no cabe en la RAM visible. Lo que hace es buscar un slot con 64K de RAM
y meter mas de la mitad del juego DEBAJO de la ROM del BASIC, en las paginas 0 y
1 (0x0000-0x7FFF), que en un MSX arrancado desde BASIC estan tapadas por la ROM.
Los siete trozos que trae la cinta despues del cargador no se ejecutan donde se
cargan: cada uno lleva pegada una rutinilla de cuatro lineas que conmuta al slot
de RAM, hace un LDIR al sitio definitivo y devuelve el slot como estaba.

Asi que la direccion de carga que declara la cinta NO es la direccion donde el
codigo se ejecuta, y desensamblar por la de carga da un listado en el que ningun
CALL cae en su sitio. Esta herramienta aplica esas copias y deja la foto de la
memoria en el momento en que arranca el juego.

El reparto NO esta escrito a ojo: sale de src/reparto.txt, y cada linea de ese
fichero lleva la direccion de la instruccion del propio juego que lo demuestra.

Salida: work/imagen64k.bin y work/mapa.json (que tramos estan cargados y cuales
no, para que el trazador no se meta en memoria que nadie ha escrito).

Uso: imagen.py <src/reparto.txt> <dir_work>
"""
import json
import os
import sys


def lee_reparto(path):
    """origen_modulo desplazamiento_en_el_modulo destino longitud # prueba"""
    filas = []
    for n, raw in enumerate(open(path, encoding="utf-8"), 1):
        ln = raw.split("#")[0].strip()
        if not ln:
            continue
        p = ln.split()
        if len(p) != 4:
            sys.exit(f"{path}:{n}: esperaba 4 campos, hay {len(p)}")
        filas.append((p[0], int(p[1], 0), int(p[2], 0), int(p[3], 0),
                      raw.split("#", 1)[1].strip() if "#" in raw else ""))
    return filas


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    reparto, work = sys.argv[1], sys.argv[2]
    img = bytearray(0x10000)
    ocupado = bytearray(0x10000)
    tramos = []

    for mod, off, dst, n, prueba in lee_reparto(reparto):
        dat = open(os.path.join(work, f"{mod}.raw"), "rb").read()
        if off + n > len(dat):
            sys.exit(f"{mod}: se piden {n} bytes desde {off:#x} y solo hay {len(dat)}")
        for i in range(n):
            if ocupado[dst + i]:
                sys.exit(f"{mod}: {dst+i:#06x} ya estaba escrito por otro trozo")
        img[dst:dst + n] = dat[off:off + n]
        ocupado[dst:dst + n] = b"\x01" * n
        tramos.append({"modulo": mod, "off": off, "org": dst, "bytes": n,
                       "prueba": prueba})
        print(f"  {mod:9s} +{off:#06x} -> {dst:#06x}..{dst+n-1:#06x}  "
              f"{n:6d} bytes   {prueba}")

    # Lo que nadie ha cargado: ni codigo ni datos del juego. Se declara para que
    # el trazador no lo recorra (esta a cero y un mar de NOP traza de maravilla).
    vacios, ini = [], None
    for i in range(0x10000 + 1):
        v = ocupado[i] if i < 0x10000 else 1
        if not v and ini is None:
            ini = i
        elif v and ini is not None:
            vacios.append([ini, i])
            ini = None

    open(os.path.join(work, "imagen64k.bin"), "wb").write(bytes(img))
    json.dump({"tramos": tramos, "vacios": vacios},
              open(os.path.join(work, "mapa.json"), "w"), indent=1)
    tot = sum(t["bytes"] for t in tramos)
    print(f"\n  {tot} bytes cargados en la imagen de 64K "
          f"({100.0*tot/65536:.1f}% del mapa)")
    print("  sin cargar:")
    for a, b in vacios:
        print(f"    {a:#06x}..{b-1:#06x}  ({b-a} bytes)")
    print(f"\n  -> {os.path.join(work, 'imagen64k.bin')}")


if __name__ == "__main__":
    main()
