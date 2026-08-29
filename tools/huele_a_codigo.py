#!/usr/bin/env python3
"""Puntua cada hueco del trazado: esto que hay aqui, ¿parece codigo Z80 o no?

Hace falta porque el trazador solo marca lo que ALCANZA. Todo lo demas cae en el
mismo saco, y ahi se mezclan dos cosas muy distintas: tablas y dibujos (datos de
verdad) y rutinas a las que no llega nadie (que son un hallazgo, no un hueco).
Distinguirlas a ojo en 160 tramos no es viable.

La puntuacion, desensamblando el tramo linealmente desde su primer byte:

  - `rst 38h` (0xFF) y `nop` (0x00) en racha: en codigo real casi no aparecen,
    en un dibujo son el pan de cada dia.
  - opcodes que z80dasm no sabe traducir (saca `defb`).
  - y la prueba mas dura: cuantos saltos y llamadas del tramo CAEN en un sitio
    razonable, es decir, dentro de la memoria cargada. Un dibujo leido como
    codigo genera `call` a direcciones al azar; una rutina de verdad, no.

No decide nada por si sola: marca CODIGO, DATOS o DUDOSO, y lo dudoso hay que
mirarlo a mano. El objetivo es que la lista de "mirar a mano" sea corta.

Uso: huele_a_codigo.py <binario> <org> <trace.json> [minimo_bytes]
"""
import json
import re
import subprocess
import sys
import os
import tempfile

TMP = tempfile.gettempdir()


def analiza(data, org, a, b):
    trozo = data[a - org:b - org]
    tmp = os.path.join(TMP, "_huele.bin")
    open(tmp, "wb").write(trozo)
    r = subprocess.run(["z80dasm", "-a", "-l", "-g", hex(a), tmp],
                       capture_output=True, text=True,
                       env=dict(os.environ, TMP=TMP, TEMP=TMP))
    os.unlink(tmp)
    lineas = [ln for ln in r.stdout.splitlines()
              if ln.startswith("\t") and not ln.startswith("\torg")]
    if not lineas:
        return None
    n = len(lineas)
    raros = sum(1 for ln in lineas
                if re.search(r"\b(rst 38h|defb|out \(0[0-9a-f]{2}h\),a\s*$)", ln)
                and "defb" in ln or "rst 38h" in ln)
    nops = sum(1 for ln in lineas if re.match(r"^\tnop\b", ln))
    dest, buenos = 0, 0
    for ln in lineas:
        m = re.search(r"\b(call|jp)\s+(?:\w{1,2},)?0([0-9a-f]{4})h\b", ln)
        if m:
            t = int(m.group(2), 16)
            dest += 1
            # razonable: BIOS baja, o memoria que el juego tiene cargada
            if t < 0x0200 or 0x4000 <= t < 0x7000 or 0x7900 <= t < 0xE000:
                buenos += 1
    pct_raro = 100.0 * (raros + nops) / n
    pct_dest = 100.0 * buenos / dest if dest else -1
    return n, pct_raro, pct_dest, dest


def main():
    if len(sys.argv) < 4:
        sys.exit(__doc__)
    data = open(sys.argv[1], "rb").read()
    org = int(sys.argv[2], 0)
    tr = json.load(open(sys.argv[3]))
    minimo = int(sys.argv[4]) if len(sys.argv) > 4 else 16

    print(f"  {'tramo':17s} {'bytes':>6s} {'instr':>6s} {'ff/nop':>7s} "
          f"{'destinos ok':>12s}  veredicto")
    print("  " + "-" * 74)
    tot = {"CODIGO": 0, "DATOS": 0, "DUDOSO": 0}
    for k, a, b in tr["blocks"]:
        if k != "d" or b - a < minimo:
            continue
        res = analiza(data, org, a, b)
        if not res:
            continue
        n, pr, pd, nd = res
        if pr < 12 and (pd >= 80 or (nd == 0 and pr < 5)):
            v = "CODIGO"
        elif pr > 25 or (nd >= 3 and pd < 40):
            v = "DATOS"
        else:
            v = "DUDOSO"
        tot[v] += b - a
        print(f"  0x{a:04X}..0x{b-1:04X}  {b-a:6d} {n:6d} {pr:6.1f}% "
              f"{(f'{pd:.0f}% de {nd}' if nd else '-'):>12s}  {v}")
    print("  " + "-" * 74)
    print("  " + "   ".join(f"{k}: {v} bytes" for k, v in tot.items()))


if __name__ == "__main__":
    main()
