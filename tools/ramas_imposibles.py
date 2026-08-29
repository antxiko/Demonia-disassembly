#!/usr/bin/env python3
"""Busca ramas que NO PUEDEN ejecutarse por una comparacion imposible.

El patron, que ya aparecio en Konami's Mahjong (0x595C) y es la clase de resto
mas divertida que hay en un desensamblado:

    cp  N1
    jr  nz,otra_cosa     ; si no salta, A vale N1 con seguridad
    ...                  ; instrucciones que NO tocan A
    cp  N2               ; con N2 distinto de N1
    jr  z,aqui           ; este salto no se toma JAMAS

Lo que hace este programa es exactamente eso y nada mas: recorre las
instrucciones que el trazador marco como codigo, y cada vez que ve un
`cp N1` seguido de un salto por NZ, sigue leyendo hacia delante mientras las
instrucciones no escriban en A, no salten y no sean un destino de salto de
otro sitio (eso ultimo es imprescindible: si alguien salta ahi en medio, A ya
no vale N1). Si en ese tramo aparece un segundo `cp N2` con N2 != N1, la rama
de igualdad esta muerta y se informa.

Las tres condiciones para no dar falsos positivos:
  - A no se toca entre las dos comparaciones;
  - el tramo no es destino de ningun salto ni llamada del propio modulo;
  - las dos constantes son distintas.

Devuelve pocos casos. Es lo que se pretende: cada uno tiene que aguantar que
se lea el listado al lado.

Uso: ramas_imposibles.py <binario> <org> <trace.json>
"""
import json
import sys

sys.path.insert(0, __file__.rsplit("/", 1)[0] if "/" in __file__ else ".")
from z80trace import BASE_LEN, ED_LEN4, IDX_DISP  # noqa: E402

# Opcodes de un byte que dejan A intacta (los que se usan de verdad entre dos
# comparaciones: comparar, mover otros registros, tocar la pila, contar...).
NO_TOCA_A = set()
for o in range(0x40, 0x80):
    if (o >> 3) & 7 != 7 and o != 0x76:      # ld r,r' con destino != A
        NO_TOCA_A.add(o)
NO_TOCA_A |= {0x00}                          # nop
NO_TOCA_A |= {0x03, 0x0B, 0x13, 0x1B, 0x23, 0x2B, 0x33, 0x3B}   # inc/dec rr
NO_TOCA_A |= {0x04, 0x05, 0x0C, 0x0D, 0x14, 0x15, 0x1C, 0x1D,
              0x24, 0x25, 0x2C, 0x2D, 0x34, 0x35}               # inc/dec r (no A)
NO_TOCA_A |= {0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE}         # cp r
NO_TOCA_A |= {0xC5, 0xD5, 0xE5, 0xF5, 0xC1, 0xD1, 0xE1}         # push/pop (no af)
NO_TOCA_A |= {0x08, 0xD9, 0xEB, 0xE3}                           # ex
NO_TOCA_A |= {0x06, 0x0E, 0x16, 0x1E, 0x26, 0x2E, 0x36}         # ld r,n (no A)
NO_TOCA_A |= {0x01, 0x11, 0x21, 0x31}                           # ld rr,nn
NO_TOCA_A |= {0x22, 0x2A}                                       # ld (nn),hl / hl,(nn)
NO_TOCA_A |= {0x09, 0x19, 0x29, 0x39}                           # add hl,rr
NO_TOCA_A |= {0x32}                                             # ld (nn),a
NO_TOCA_A |= {0x02, 0x12, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x77}


def largo(d, i):
    op = d[i]
    if op in (0xDD, 0xFD):
        o2 = d[i + 1]
        if o2 == 0xCB:
            return 4
        return BASE_LEN[o2] + 1 + (1 if o2 in IDX_DISP else 0)
    if op == 0xED:
        return 4 if d[i + 1] in ED_LEN4 else 2
    if op == 0xCB:
        return 2
    return BASE_LEN[op]


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    d = open(sys.argv[1], "rb").read()
    org = int(sys.argv[2], 0)
    tr = json.load(open(sys.argv[3]))
    cod = bytearray(len(d))
    for k, a, b in tr["blocks"]:
        if k == "c":
            cod[a - org:b - org] = b"\x01" * (b - a)
    destinos = set(tr["entries"])
    # y los destinos de salto relativo, que no salen en entries
    i = 0
    while i < len(d):
        if cod[i]:
            op = d[i]
            n = largo(d, i)
            if op in (0x18, 0x20, 0x28, 0x30, 0x38, 0x10):
                e = d[i + 1]
                destinos.add(org + i + 2 + (e - 256 if e > 127 else e))
            i += max(1, n)
        else:
            i += 1

    # --- segundo patron: A cargada con una constante y comparada con otra ---
    # "ld a,N1" (o "xor a", que es N1=0) y despues "cp N2" sin que A cambie por
    # el camino. El resultado de la comparacion esta decidido antes de hacerla,
    # asi que una de las dos ramas no se ejecuta nunca.
    fijos = []
    i = 0
    while i < len(d) - 3:
        if not cod[i] or d[i] not in (0x3E, 0xAF):
            i += 1
            continue
        n1 = d[i + 1] if d[i] == 0x3E else 0
        j = i + (2 if d[i] == 0x3E else 1)
        pasos = 0
        while pasos < 12 and j < len(d) - 2 and cod[j]:
            if org + j in destinos:
                break
            op = d[j]
            if op == 0xFE:
                n2 = d[j + 1]
                k = j + 2
                if k < len(d) and d[k] in (0x28, 0xCA, 0x20, 0xC2):
                    rama = "Z" if d[k] in (0x28, 0xCA) else "NZ"
                    muerta = rama if (n1 != n2) == (rama == "Z") else None
                    if muerta:
                        fijos.append((org + i, n1, org + j, n2, org + k, muerta))
                break
            if op not in NO_TOCA_A:
                break
            j += largo(d, j)
            pasos += 1
        i += 1

    hallazgos = []
    i = 0
    while i < len(d) - 4:
        if not cod[i] or d[i] != 0xFE:
            i += 1
            continue
        n1 = d[i + 1]
        j = i + 2
        # el salto por NZ inmediatamente despues
        if d[j] == 0x20:
            sal = 2
        elif d[j] == 0xC2:
            sal = 3
        else:
            i += 1
            continue
        j += sal
        pasos = 0
        while pasos < 12 and j < len(d) - 1 and cod[j]:
            if org + j in destinos:
                break
            op = d[j]
            if op == 0xFE:
                n2 = d[j + 1]
                k = j + 2
                if n2 != n1 and k < len(d) and d[k] in (0x28, 0xCA):
                    hallazgos.append((org + i, n1, org + j, n2, org + k))
                break
            if op not in NO_TOCA_A:
                break
            j += largo(d, j)
            pasos += 1
        i += 1

    print("  PATRON 1: cp N1 + jr nz, y despues cp N2 sobre la misma A")
    if not hallazgos:
        print("    ninguno")
    for a, n1, b, n2, c in hallazgos:
        print(f"    {a:#06x}  cp {n1:#04x} + jr nz  ->  {b:#06x} cp {n2:#04x}, "
              f"y el salto por Z de {c:#06x} nunca se toma")
    print()
    print("  PATRON 2: A cargada con una constante y comparada con otra")
    if not fijos:
        print("    ninguno")
    for a, n1, b, n2, c, rama in fijos:
        print(f"    {a:#06x}  A={n1:#04x}  ->  {b:#06x} cp {n2:#04x}: "
              f"el salto por {rama} de {c:#06x} nunca se toma")


if __name__ == "__main__":
    main()
