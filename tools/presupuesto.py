#!/usr/bin/env python3
"""Presupuesto de la cinta: ni un byte sin explicar, y la cuenta cierra en el .cas.

Por que este control y no el porcentaje de codigo trazado: mas de la mitad de
esta cinta son graficos, asi que un porcentaje de codigo bajo suena a trabajo a
medias cuando puede estar entero. Lo que mide el avance de verdad es que cada
byte sea una de estas cosas:

  - codigo que el trazador alcanza de verdad siguiendo el flujo;
  - un byte dentro de un rango de datos IDENTIFICADO con una directiva D en el
    fichero de notas de su listado;
  - envoltorio de la cinta: los centinelas de bloque, las cabeceras de fichero
    MSX, los tres words de un fichero BIN y el relleno de alineacion a 8.

Y es un control DISTINTO del de reproducibilidad. Un byte puede reensamblar
perfecto y estar sin explicar; o peor, estar mal explicado: si unos graficos se
marcan como codigo, el binario reensamblado sale identico -los bytes no cambian,
solo su lectura- y el listado miente igual. De eso se ocupan check_entradas.py
y check_datos_como_codigo.py.

La suma se hace sobre los LISTADOS, que es donde vive la explicacion, y luego se
cuadra contra el tamano del .cas sumando el envoltorio. Los listados no se
solapan entre si por construccion: tools/piezas.py aborta si lo hicieran.

Uso: presupuesto.py <dir_work> <dir_src> <cinta.cas>
"""
import json
import os
import sys


def rangos_de_notas(path):
    """Rangos de datos declarados con la directiva D del fichero .notes."""
    out = []
    if not os.path.exists(path):
        return out
    for ln in open(path, encoding="utf-8"):
        ln = ln.strip()
        if not ln.startswith("D "):
            continue
        p = ln.split(None, 3)
        out.append((int(p[1], 0), int(p[2], 0)))
    return out


def revisa(work, src, L, org, size):
    estado = bytearray(size)          # 0 sin explicar, 1 codigo, 2 datos con nombre
    tr = json.load(open(os.path.join(work, f"{L}.trace.json")))
    for kind, a, b in tr["blocks"]:
        if kind == "c":
            for i in range(max(0, a - org), min(size, b - org)):
                estado[i] = 1
    for a, b in rangos_de_notas(os.path.join(src, f"{L}.notes")):
        for i in range(max(0, a - org), min(size, b - org)):
            if estado[i] == 0:
                estado[i] = 2
    return estado


def huecos(estado, org):
    out, ini = [], None
    for i, v in enumerate(estado):
        if v == 0 and ini is None:
            ini = i
        elif v != 0 and ini is not None:
            out.append((org + ini, org + i))
            ini = None
    if ini is not None:
        out.append((org + ini, org + len(estado)))
    return out


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    work, src, cas = sys.argv[1], sys.argv[2], sys.argv[3]
    pz = json.load(open(os.path.join(work, "piezas.json")))
    inv = json.load(open(os.path.join(work, "..", "extracted", "inventario.json")))

    total = explicado = codigo = datos = 0
    pendientes = []
    print(f"  {'listado':12s} {'org':>7s} {'bytes':>7s} {'codigo':>7s} "
          f"{'datos':>7s} {'sin explicar':>13s}")
    print("  " + "-" * 60)
    for L in sorted(pz["listados"]):
        d = pz["listados"][L]
        est = revisa(work, src, L, d["org"], d["bytes"])
        c, dd, h = est.count(1), est.count(2), est.count(0)
        total += d["bytes"]
        explicado += c + dd
        codigo += c
        datos += dd
        print(f"  {L:12s} {d['org']:#07x} {d['bytes']:7d} {c:7d} {dd:7d} {h:13d}")
        for a, b in huecos(est, d["org"]):
            pendientes.append((L, a, b))

    # --- el envoltorio de la cinta ----------------------------------------
    print("  " + "-" * 60)
    marcas = len(inv) + sum(1 for e in inv if e["clase"] != "SINCAB")
    # (cada fichero con nombre lleva DOS bloques: cabecera y datos; el ASCII,
    #  uno por cada trozo de 256)
    ascii_trozos = sum(len(e["bloques"]) - 1 for e in inv if e["clase"] == "ASCII")
    marcas = sum(len(e.get("bloques", [e])) if e["clase"] != "SINCAB" else 1
                 for e in inv)
    env = []
    env.append(("centinelas de bloque", 8 * marcas,
                f"{marcas} bloques x 8 bytes (1F A6 DE BA CC 13 7D 74)"))
    ncab = sum(1 for e in inv if e["clase"] != "SINCAB")
    env.append(("cabeceras de fichero", 16 * ncab,
                f"{ncab} ficheros x (10 bytes de tipo + 6 de nombre)"))
    nbin = sum(1 for e in inv if e["clase"] == "BIN")
    env.append(("cabecera BIN", 6 * nbin,
                f"{nbin} ficheros x (carga, fin, ejecucion)"))
    rel = sum(e.get("relleno", 0) for e in inv)
    # relleno de los bloques sin cabecera: lo que sobra hasta el multiplo de 8
    for e in inv:
        if e["clase"] == "SINCAB":
            pass
    d = open(cas, "rb").read()
    cuerpo_ascii = sum(e["bytes"] for e in inv if e["clase"] == "ASCII")
    subtotal = total + sum(x[1] for x in env) + cuerpo_ascii
    rel_align = len(d) - subtotal
    env.append(("cargador BASIC", cuerpo_ascii,
                "el texto del cargador, en trozos de 256 con relleno 0x1A"))
    env.append(("relleno de alineacion", rel_align,
                "hasta el multiplo de 8 que exige el centinela siguiente"))
    for nombre, n, como in env:
        print(f"  {nombre:24s} {n:7d}   {como}")

    print("  " + "=" * 60)
    tot_cas = total + sum(x[1] for x in env)
    exp_cas = explicado + sum(x[1] for x in env)
    sin = tot_cas - exp_cas
    print(f"  cinta: {len(d)} bytes; contabilizados {tot_cas}; "
          f"explicados {exp_cas} ({100.0*exp_cas/tot_cas:.2f}%), {sin} sin explicar")
    print(f"  de los listados: {codigo} bytes de codigo, {datos} de datos con nombre")
    if tot_cas != len(d):
        print(f"  !! la cuenta NO cuadra con el .cas: sobran/faltan "
              f"{len(d) - tot_cas} bytes")
        return 1

    if pendientes:
        print()
        print("  Sin explicar:")
        for L, a, b in pendientes:
            print(f"    {L:11s} 0x{a:04X}..0x{b-1:04X}  ({b-a} bytes)")
        print()
        print("  Cada uno tiene que acabar dentro de una directiva D del fichero")
        print("  de notas de su listado, con que es y de que se deduce.")
        return 1

    print()
    print("  OK: ni un byte de la cinta sin asignar")
    return 0


if __name__ == "__main__":
    sys.exit(main())
