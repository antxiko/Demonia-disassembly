#!/usr/bin/env python3
"""Corta la cinta en listados y prepara el trazado de cada uno.

Lee src/piezas.txt (el reparto: que trozo de que bloque de cinta se desensambla
en que org) y hace tres cosas:

  1. escribe work/<listado>.bin, el binario que ese listado tiene que
     reproducir al ensamblarlo;
  2. comprueba que los renglones cubren cada bloque de cinta ENTERO y sin
     solaparse. Si sobra o falta un byte, aborta: el presupuesto no cuadraria y
     el verify tampoco;
  3. para los listados que caen dentro de la imagen de 64K, recorta su trozo del
     trazado global (work/imagen.trace.json) y lo deja como
     work/<listado>.trace.json, con las direcciones ya en su org de ejecucion.
     Los demas -las rutinillas copiadoras, que se ejecutan donde la cinta las
     deja- se trazan aparte, cada una desde su direccion de arranque.

Y escribe work/piezas.json, que es lo que usa el verify para volver a montar
cada bloque de cinta a partir de los listados ensamblados.

Uso: piezas.py <src/piezas.txt> <dir_work>
"""
import json
import os
import sys


def lee(path):
    filas = []
    for n, raw in enumerate(open(path, encoding="utf-8"), 1):
        ln = raw.split("#")[0].strip()
        if not ln:
            continue
        p = ln.split()
        if len(p) != 5:
            sys.exit(f"{path}:{n}: esperaba 5 campos, hay {len(p)}")
        filas.append(dict(listado=p[0], org=int(p[1], 0), modulo=p[2],
                          off=int(p[3], 0), n=int(p[4], 0)))
    return filas


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    filas = lee(sys.argv[1])
    work = sys.argv[2]

    # --- que cada bloque de cinta quede cubierto entero -------------------
    mods = {}
    for f in filas:
        mods.setdefault(f["modulo"], []).append(f)
    for m, fs in sorted(mods.items()):
        fs.sort(key=lambda x: x["off"])
        largo = os.path.getsize(os.path.join(work, f"{m}.raw"))
        pos = 0
        for f in fs:
            if f["off"] != pos:
                sys.exit(f"{m}: hueco o solape en {pos:#06x} "
                         f"(el siguiente renglon empieza en {f['off']:#06x})")
            pos += f["n"]
        if pos != largo:
            sys.exit(f"{m}: los renglones suman {pos} bytes y el bloque tiene {largo}")

    # --- el binario de cada listado ---------------------------------------
    lis = {}
    for f in filas:
        lis.setdefault(f["listado"], []).append(f)
    salida = {}
    for L, fs in sorted(lis.items()):
        fs.sort(key=lambda x: x["org"])
        dat = b""
        org = fs[0]["org"]
        pos = org
        for f in fs:
            if f["org"] != pos:
                sys.exit(f"{L}: el listado no es contiguo en {pos:#06x}")
            src = open(os.path.join(work, f"{f['modulo']}.raw"), "rb").read()
            dat += src[f["off"]:f["off"] + f["n"]]
            pos += f["n"]
        open(os.path.join(work, f"{L}.bin"), "wb").write(dat)
        salida[L] = dict(org=org, bytes=len(dat))
        print(f"  listado {L:11s} org={org:#06x}  {len(dat):6d} bytes")

    # --- como se rehace cada bloque de cinta ------------------------------
    bloques = {}
    for m, fs in sorted(mods.items()):
        trozos = []
        for f in fs:
            # desplazamiento del trozo DENTRO del binario del listado
            base = min(x["org"] for x in lis[f["listado"]])
            trozos.append([f["listado"], f["org"] - base, f["n"]])
        bloques[m] = trozos

    # --- recorte del trazado global ---------------------------------------
    tpath = os.path.join(work, "imagen.trace.json")
    recortados = []
    if os.path.exists(tpath):
        tr = json.load(open(tpath))
        # Solo se puede recortar el trazado global para los listados que estan
        # DE VERDAD en la imagen de 64K. Un listado como carga1 tiene org
        # 0xA000, pero en la imagen esa direccion la ocupa el bloque del juego:
        # recortarle el trazado seria darle el mapa de otro. La prueba de que un
        # listado esta en la imagen es que sus renglones coinciden con una copia
        # declarada en src/reparto.txt.
        mapa = json.load(open(os.path.join(work, "mapa.json")))
        copias = {(t["modulo"], t["off"], t["org"], t["bytes"]) for t in mapa["tramos"]}
        enimagen = {L for L, fs in lis.items()
                    if all((f["modulo"], f["off"], f["org"], f["n"]) in copias
                           for f in fs)}
        for L, d in salida.items():
            if L not in enimagen:
                continue
            a0, a1 = d["org"], d["org"] + d["bytes"]
            if a1 > 0x10000:
                continue
            bl = []
            for k, a, b in tr["blocks"]:
                a, b = max(a, a0), min(b, a1)
                if a < b:
                    if bl and bl[-1][0] == k and bl[-1][2] == a:
                        bl[-1][2] = b
                    else:
                        bl.append([k, a, b])
            # solo vale si el trazado global cubre de verdad este tramo
            if not bl or bl[0][1] != a0 or bl[-1][2] != a1:
                continue
            ent = [x for x in tr["entries"] if a0 <= x < a1]
            n = sum(b - a for k, a, b in bl if k == "c")
            json.dump(dict(report=dict(code_bytes=n), entries=ent, blind=[],
                           blocks=bl),
                      open(os.path.join(work, f"{L}.trace.json"), "w"), indent=1)
            recortados.append(L)
        print(f"\n  trazado recortado para: {', '.join(sorted(recortados))}")

    json.dump(dict(listados=salida, bloques=bloques, recortados=recortados),
              open(os.path.join(work, "piezas.json"), "w"), indent=1)
    print(f"  -> {os.path.join(work, 'piezas.json')}")


if __name__ == "__main__":
    main()
