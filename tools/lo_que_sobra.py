#!/usr/bin/env python3
"""Cuenta lo que sobra en la cinta, separando lo medido de lo supuesto.

Cuatro cuentas, cada una con su metodo, porque no se miden igual:

1. CODIGO HUERFANO. Se traza dos veces: con todos los puntos de entrada y sin
   los marcados "[HUERFANO]" en el fichero de entradas. La diferencia es el
   codigo al que no se llega desde el arranque del juego. Es una medida, no una
   opinion: si manana aparece el salto que faltaba, se quita la marca y la
   cuenta baja sola.

2. RELLENO Y RESTOS. Los rangos de datos cuyo nombre dice que son relleno, un
   RET suelto o un salto huerfano. El nombre lo puso tools/rellena_huecos.py
   mirando el contenido, no adivinandolo.

3. DATOS QUE NADIE APUNTA. Rangos de datos declarados a los que no llega
   ninguna instruccion de las trazadas. CANDIDATOS, no muertos: un HL puede
   llegar ahi por aritmetica y eso no se ve desde aqui.

4. LO QUE NO SE EJECUTA. Si hay un muestreo del contador de programa
   (work/omsx/pc.txt), se resta del codigo alcanzable. Tambien CANDIDATOS: una
   pantalla a la que la partida no llego no esta muerta, solo sin visitar.

Uso: lo_que_sobra.py <dir_work> <dir_src>
"""
import json
import os
import re
import subprocess
import sys


def entradas(path):
    todas, huerf = [], []
    for ln in open(path, encoding="utf-8"):
        s = ln.split("#")[0].strip()
        if not s:
            continue
        a = int(s.split()[0], 0)
        todas.append(a)
        if "[HUERFANO]" in ln:
            huerf.append(a)
    return todas, huerf


def traza(work, binario, org, entradas_lista, nocode, pref):
    tmp = os.path.join(work, pref + ".entries.tmp")
    with open(tmp, "w", newline="\n") as f:
        for a in entradas_lista:
            f.write(f"{a:#06x}\n")
    subprocess.run(["python3", os.path.join("tools", "z80trace.py"), binario,
                    hex(org), tmp, os.path.join(work, pref), nocode],
                   capture_output=True, text=True, check=True)
    tr = json.load(open(os.path.join(work, pref + ".trace.json")))
    m = bytearray(0x10000)
    for k, a, b in tr["blocks"]:
        if k == "c":
            m[a:b] = b"\x01" * (b - a)
    os.unlink(tmp)
    return m


def rangos_de_notas(src):
    out = []
    for fn in sorted(os.listdir(src)):
        if not fn.endswith(".notes"):
            continue
        L = fn[:-6]
        for ln in open(os.path.join(src, fn), encoding="utf-8"):
            ln = ln.strip()
            if not ln.startswith("D "):
                continue
            p = ln.split(None, 3)
            out.append((L, int(p[1], 0), int(p[2], 0),
                        p[3].split(None, 1)[0] if len(p) > 3 else "",
                        p[3] if len(p) > 3 else ""))
    return out


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    work, src = sys.argv[1], sys.argv[2]
    todas, huerf = entradas(os.path.join(src, "imagen.entries"))
    nocode = os.path.join(src, "imagen.nocode")
    binario = os.path.join(work, "imagen64k.bin")

    con = traza(work, binario, 0, todas, nocode, "_sobra_con")
    sin = traza(work, binario, 0, [a for a in todas if a not in huerf],
                nocode, "_sobra_sin")
    ncon, nsin = sum(con), sum(sin)
    print("1) CODIGO HUERFANO")
    print(f"   codigo alcanzable con TODAS las entradas : {ncon} bytes")
    print(f"   codigo alcanzable sin las [HUERFANO]     : {nsin} bytes")
    print(f"   codigo al que no se llega                : {ncon - nsin} bytes")
    tramos, ini = [], None
    for i in range(0x10001):
        v = con[i] and not sin[i] if i < 0x10000 else False
        if v and ini is None:
            ini = i
        elif not v and ini is not None:
            tramos.append((ini, i))
            ini = None
    for a, b in tramos:
        print(f"      0x{a:04X}..0x{b-1:04X}  ({b-a} bytes)")

    print()
    print("2) RELLENO Y RESTOS ETIQUETADOS POR SU CONTENIDO")
    clases = {}
    for L, a, b, nom, desc in rangos_de_notas(src):
        if re.match(r"(relleno|ret_suelto|ret_y_relleno|dos_ret|tres_ret|"
                    r"bucle_muerto|salto_.*huerfano|.*_huerfana|"
                    r"conmutadora_muerta|or_a_ret_z_huerfano)", nom):
            clases.setdefault(nom.split("_")[0], [0, 0])
            clases[nom.split("_")[0]][0] += 1
            clases[nom.split("_")[0]][1] += b - a
    tot2 = 0
    for k, (n, by) in sorted(clases.items(), key=lambda x: -x[1][1]):
        print(f"   {k:22s} {n:4d} tramos {by:6d} bytes")
        tot2 += by
    print(f"   {'TOTAL':22s}      {'':10s}{tot2:6d} bytes")

    print()
    print("3) DATOS QUE NINGUNA INSTRUCCION APUNTA (candidatos)")
    sys.path.insert(0, "tools")
    from quien_apunta import refs
    dat = open(binario, "rb").read()
    tr = json.load(open(os.path.join(work, "imagen.trace.json")))
    apuntados = {v for v, pc, t in refs(dat, 0, tr)}
    # y los punteros que viven DENTRO de una tabla de punteros declarada: si no
    # se cuentan, los 26 mapas de pantalla salen como "no los apunta nadie"
    # cuando en realidad los indexa la tabla de 0xD000.
    for L, a, b, nom, desc in rangos_de_notas(src):
        if not re.match(r"(punteros_|tabla_de_conducta|tabla_de_opcodes)", nom):
            continue
        for x in range(a, b - 1, 2):
            apuntados.add(dat[x] | (dat[x + 1] << 8))
    tot3 = 0
    filas = []
    for L, a, b, nom, desc in rangos_de_notas(src):
        if b - a < 16 or L.startswith("carga") or L == "arranque":
            continue
        if not any(a <= v < b for v in apuntados):
            filas.append((b - a, L, a, b, nom))
            tot3 += b - a
    for n, L, a, b, nom in sorted(filas, reverse=True)[:20]:
        print(f"   {L:10s} 0x{a:04X}..0x{b-1:04X} {n:6d}  {nom}")
    print(f"   {len(filas)} tramos, {tot3} bytes en total")

    print()
    print("4) CODIGO ALCANZABLE QUE NO SE EJECUTO EN LA MEDIDA (candidatos)")
    pc = os.path.join(work, "omsx", "pc.txt")
    if not os.path.exists(pc):
        print("   (sin muestreo del PC: no se ha medido)")
        return
    vistos = {int(l.split()[0], 16) for l in open(pc)}
    alc = sum(sin)
    ej = sum(1 for i in range(0x10000) if sin[i] and i in vistos)
    print(f"   codigo alcanzable (sin los huerfanos): {alc} bytes")
    print(f"   de esos, vistos ejecutandose         : {ej} bytes "
          f"({100.0*ej/alc:.1f}%)")
    print("   OJO: el muestreo coge el PC cada 0,5 ms, asi que ve una fraccion")
    print("   de lo que corre. Este numero NO mide codigo muerto.")


if __name__ == "__main__":
    main()
