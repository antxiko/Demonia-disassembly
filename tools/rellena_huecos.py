#!/usr/bin/env python3
"""Etiqueta los huecos PEQUENOS del trazado cuyo contenido se explica solo.

Entre rutina y rutina quedan restos de un byte o de tres. Escribirlos a mano,
uno a uno, en un listado con doscientos huecos, no aporta nada y ademas invita a
inventar: acabarias poniendo "tabla" encima de un cero. Aqui solo se etiqueta lo
que se puede DECIDIR MIRANDO EL CONTENIDO, y la etiqueta dice de que medida sale:

  relleno_cero      todo el hueco es 0x00
  relleno_ff        todo el hueco es 0xFF
  ret_suelto        el hueco es un unico 0xC9, un RET al que no llega nadie
  ret_y_relleno     un 0xC9 seguido de ceros
  bucle_muerto      0x18 0xFE, o sea "jr $", un cuelgue al que no llega nadie

Lo que no cae en ninguna de esas se deja SIN etiquetar y se lista al final: eso
hay que mirarlo a mano, que para eso es el trabajo.

Escribe las directivas D en una seccion delimitada del fichero de notas, que se
regenera entera en cada pasada; lo que haya fuera de esa seccion no se toca.

Uso: rellena_huecos.py <dir_work> <dir_src> <listado> <org> [tope_bytes]
"""
import json
import os
import sys

INI = "# >>> HUECOS ETIQUETADOS POR tools/rellena_huecos.py - NO EDITAR A MANO"
FIN = "# <<< fin de los huecos automaticos"


def clasifica(b):
    if not b:
        return None
    if all(x == 0 for x in b):
        return "relleno_cero", "todo el hueco es 0x00"
    if all(x == 0xFF for x in b):
        return "relleno_ff", "todo el hueco es 0xFF"
    if b == b"\xc9":
        return "ret_suelto", "un unico 0xC9 (RET) al que no llega ningun salto"
    if b[0] == 0xC9 and all(x == 0 for x in b[1:]):
        return "ret_y_relleno", "un 0xC9 (RET) y ceros detras"
    if b == b"\x18\xfe":
        return "bucle_muerto", "0x18 0xFE, o sea jr $: un cuelgue que nadie alcanza"
    return None


def main():
    if len(sys.argv) < 5:
        sys.exit(__doc__)
    work, src, L, org = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4], 0)
    tope = int(sys.argv[5]) if len(sys.argv) > 5 else 8
    dat = open(os.path.join(work, f"{L}.bin"), "rb").read()
    tr = json.load(open(os.path.join(work, f"{L}.trace.json")))

    lineas, sin = [], []
    for k, a, b in tr["blocks"]:
        if k != "d" or b - a > tope:
            continue
        r = clasifica(dat[a - org:b - org])
        if r:
            nom, como = r
            lineas.append(f"D {a:#06x} {b:#06x} {nom}  {como}")
        else:
            sin.append((a, b))

    path = os.path.join(src, f"{L}.notes")
    txt = open(path, encoding="utf-8").read() if os.path.exists(path) else ""
    if INI in txt:
        pre = txt.split(INI)[0]
        post = txt.split(FIN)[1] if FIN in txt else ""
    else:
        pre, post = txt, ""
    if pre and not pre.endswith("\n"):
        pre += "\n"
    cuerpo = "\n".join([INI] + lineas + [FIN])
    open(path, "w", encoding="utf-8", newline="\n").write(pre + cuerpo + post)

    n = sum(1 for ln in lineas)
    print(f"  {L}: {n} huecos etiquetados por su contenido")
    if sin:
        print(f"  {L}: {len(sin)} huecos de <= {tope} bytes SIN clasificar, a mano:")
        for a, b in sin:
            print(f"      0x{a:04X}..0x{b-1:04X}  ({b-a} bytes)  "
                  f"{dat[a-org:b-org].hex()}")


if __name__ == "__main__":
    main()
