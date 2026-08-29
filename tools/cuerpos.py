#!/usr/bin/env python3
"""Reparte los bloques de la cinta en modulos, cada uno con el org donde se ejecuta.

De donde sale el reparto: NO de adivinarlo. El bloque binario pequeno de la
cinta (`DEMON`, carga en 0x8180) lleva en su cabeza una TABLA DE SIETE ENTRADAS
de ocho bytes -carga, fin, ejecucion y dos bytes de relleno- y su propio bucle
la recorre hasta 0x81B8. Esta herramienta lee esa tabla del binario y comprueba
que cada entrada cuadra con el tamano de uno de los bloques sin cabecera de la
cinta, en orden. Si no cuadrara, aborta: seria senal de que el reparto esta mal
entendido y no de que "casi" encaja.

El redondeo: un bloque de .cas ocupa un multiplo de 8 bytes porque el centinela
del siguiente va alineado, asi que el bloque puede traer hasta 7 bytes de
relleno detras del cuerpo util. La comprobacion es
    longitud_declarada <= bytes_del_bloque < longitud_declarada + 8

Salida en el directorio work/:
    arranque.raw  cargaN.raw (1..7)  juego.raw   y  modulos.json con los orgs.

Uso: cuerpos.py <directorio_extracted> <directorio_work>
"""
import json
import os
import struct
import sys

TABLA = 0x8180          # donde vive la tabla de descriptores
FIN_TABLA = 0x81B8      # limite que usa el propio bucle del cargador (0x8236)
ANCHO = 8               # bytes por entrada


def u16(b, o):
    return struct.unpack_from("<H", b, o)[0]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    ext, work = sys.argv[1], sys.argv[2]
    os.makedirs(work, exist_ok=True)
    inv = json.load(open(os.path.join(ext, "inventario.json")))

    bins = [e for e in inv if e.get("clase") == "BIN"]
    sincab = [e for e in inv if e.get("clase") == "SINCAB"]
    if len(bins) != 2:
        sys.exit(f"esperaba dos ficheros BIN en la cinta, hay {len(bins)}")
    arranque, juego = bins
    if arranque["load"] != TABLA:
        sys.exit(f"el primer BIN carga en {arranque['load']:#06x}, no en {TABLA:#06x}")

    raw = open(os.path.join(ext, arranque["fichero"]), "rb").read()
    mods = []

    def add(nombre, org, exe, datos, origen):
        open(os.path.join(work, f"{nombre}.raw"), "wb").write(datos)
        mods.append({"nombre": nombre, "org": org, "exec": exe,
                     "bytes": len(datos), "origen": origen})
        print(f"  {nombre:9s} org={org:#06x} exec={exe:#06x} "
              f"{len(datos):6d} bytes   <- {origen}")

    print("modulos:")
    add("arranque", arranque["load"], arranque["exec"], raw, arranque["fichero"])

    n = (FIN_TABLA - TABLA) // ANCHO
    if len(sincab) != n:
        sys.exit(f"la tabla declara {n} trozos y en la cinta hay "
                 f"{len(sincab)} bloques sin cabecera")

    for i, e in enumerate(sincab):
        o = i * ANCHO
        ld, end, exe = u16(raw, o), u16(raw, o + 2), u16(raw, o + 4)
        cola = u16(raw, o + 6)
        largo = end - ld + 1
        dat = open(os.path.join(ext, e["fichero"]), "rb").read()
        if not (largo <= len(dat) < largo + 8):
            sys.exit(f"entrada {i}: la tabla pide {largo} bytes "
                     f"({ld:#06x}-{end:#06x}) y el bloque {e['idx']} trae {len(dat)}")
        if cola != 0xFFFF:
            print(f"  aviso: la entrada {i} no acaba en FFFF sino en {cola:#06x}")
        add(f"carga{i+1}", ld, exe, dat[:largo], e["fichero"])

    add("juego", juego["load"], juego["exec"],
        open(os.path.join(ext, juego["fichero"]), "rb").read(), juego["fichero"])

    json.dump(mods, open(os.path.join(work, "modulos.json"), "w"), indent=1)
    print(f"\n{len(mods)} modulos en {work}/  (modulos.json)")


if __name__ == "__main__":
    main()
