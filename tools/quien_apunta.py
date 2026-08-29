#!/usr/bin/env python3
"""Dice QUIEN apunta a cada tramo de datos, y cuales no los apunta nadie.

Sirve para dos cosas del proyecto:

  - poner nombre a los bloques de datos. Un rango al que solo llega un
    `ld hl,0xB2E8` desde la rutina que sube patrones a la VRAM se explica solo;
    adivinar la geometria antes de saber quien lo lee es como se fabrican
    texturas convincentes que no son nada.
  - la lista de lo que sobra. Un tramo de datos que NADIE apunta es candidato a
    material muerto. Candidato, no muerto: puede alcanzarse por aritmetica
    (`hl` que viene de una suma) y eso aqui no se ve. Se dice cual es cual.

Como lo mide: recorre las instrucciones que el trazador marco como CODIGO -solo
esas, nunca los datos- y se queda con todo valor de 16 bits que aparezca como
inmediato (`ld rr,nn`), como direccion absoluta (`ld (nn),a`, `ld hl,(nn)`) o
como destino de salto. Despues cruza esa lista con los tramos.

Un valor de 16 bits puede ser una longitud y no una direccion (`ld bc,0x0800`).
Por eso se informa de la INSTRUCCION que lo produce, y los `ld bc,` se marcan
aparte: en este juego bc casi siempre es un contador.

Uso: quien_apunta.py <binario> <org> <trace.json> [--rangos fichero.notes]
"""
import json
import re
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0] if "/" in __file__ else ".")
from z80trace import BASE_LEN, ED_LEN4, IDX_DISP, CODE  # noqa: E402

# Opcodes con un operando de 16 bits que puede ser una direccion.
INM16 = {0x01: "ld bc,", 0x11: "ld de,", 0x21: "ld hl,", 0x31: "ld sp,"}
ABS16 = {0x22: "ld (nn),hl", 0x2A: "ld hl,(nn)",
         0x32: "ld (nn),a", 0x3A: "ld a,(nn)"}
SALTO = ({0xC3: "jp", 0xCD: "call"}
         | {o: "jp cc" for o in (0xC2, 0xCA, 0xD2, 0xDA, 0xE2, 0xEA, 0xF2, 0xFA)}
         | {o: "call cc" for o in (0xC4, 0xCC, 0xD4, 0xDC, 0xE4, 0xEC, 0xF4, 0xFC)})
ED_ABS = {0x43: "ld (nn),bc", 0x53: "ld (nn),de", 0x63: "ld (nn),hl",
          0x73: "ld (nn),sp", 0x4B: "ld bc,(nn)", 0x5B: "ld de,(nn)",
          0x6B: "ld hl,(nn)", 0x7B: "ld sp,(nn)"}


def largo(d, i):
    op = d[i]
    if op in (0xDD, 0xFD):
        op2 = d[i + 1] if i + 1 < len(d) else 0
        if op2 == 0xCB:
            return 4
        n = BASE_LEN[op2] + 1
        if op2 in IDX_DISP:
            n += 1
        return n
    if op == 0xED:
        return 4 if (i + 1 < len(d) and d[i + 1] in ED_LEN4) else 2
    if op == 0xCB:
        return 2
    return BASE_LEN[op]


def refs(data, org, trace):
    """[(direccion_apuntada, direccion_de_la_instruccion, texto)]"""
    codigo = bytearray(len(data))
    for k, a, b in trace["blocks"]:
        if k == "c":
            codigo[a - org:b - org] = b"\x01" * (b - a)
    out = []
    i = 0
    while i < len(data):
        if not codigo[i]:
            i += 1
            continue
        n = largo(data, i)
        op = data[i]
        pc = org + i
        if n >= 3 and i + 2 < len(data):
            v = data[i + 1] | (data[i + 2] << 8)
            if op in INM16:
                out.append((v, pc, INM16[op]))
            elif op in ABS16:
                out.append((v, pc, ABS16[op]))
            elif op in SALTO:
                out.append((v, pc, SALTO[op]))
            elif op in (0xDD, 0xFD) and data[i + 1] == 0x21:
                v = data[i + 2] | (data[i + 3] << 8)
                out.append((v, pc, "ld ix/iy,"))
            elif op == 0xED and data[i + 1] in ED_ABS and n == 4:
                v = data[i + 2] | (data[i + 3] << 8)
                out.append((v, pc, ED_ABS[data[i + 1]]))
        i += max(1, n)
    return out


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    data = open(sys.argv[1], "rb").read()
    org = int(sys.argv[2], 0)
    tr = json.load(open(sys.argv[3]))
    rr = refs(data, org, tr)

    huecos = [(a, b) for k, a, b in tr["blocks"] if k == "d"]
    print(f"{len(rr)} valores de 16 bits en el codigo; "
          f"{len(huecos)} tramos de datos\n")
    print(f"  {'tramo':17s} {'bytes':>6s}  quien lo apunta")
    print("  " + "-" * 68)
    sin = []
    for a, b in huecos:
        dentro = sorted({(v, pc, t) for v, pc, t in rr if a <= v < b})
        if not dentro:
            sin.append((a, b))
            continue
        m = ", ".join(f"{t}{v:04X} desde {pc:04X}" for v, pc, t in dentro[:4])
        if len(dentro) > 4:
            m += f" (+{len(dentro)-4})"
        print(f"  0x{a:04X}..0x{b-1:04X}  {b-a:6d}  {m}")
    print()
    print(f"  SIN QUE NADIE LOS APUNTE: {len(sin)} tramos, "
          f"{sum(b-a for a, b in sin)} bytes")
    for a, b in sin:
        print(f"    0x{a:04X}..0x{b-1:04X}  ({b-a} bytes)")


if __name__ == "__main__":
    main()
