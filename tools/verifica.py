#!/usr/bin/env python3
"""Reproducibilidad: ensamblar los listados tiene que devolver la cinta exacta.

Es el criterio que decide si el desensamblado vale. Mientras esto no este en
verde, cualquier cosa que se afirme del juego se afirma a ciegas.

Aqui hay un paso mas que en los proyectos anteriores de la serie, porque un
bloque de cinta no es un listado: los trozos que el cargador recoloca se
desensamblan en la direccion donde se EJECUTAN, no donde se cargan. Asi que la
comprobacion es en dos tiempos:

  1. cada listado ensambla y da exactamente el binario que le toca
     (work/<listado>.bin, que lo preparo tools/piezas.py);
  2. pegando los trozos en el orden de la cinta se recupera cada bloque tal cual
     esta en el .cas, con su relleno de alineacion incluido, y al final el
     fichero .cas ENTERO, con su sha256.

El segundo paso es el que de verdad cierra el circulo: el primero solo dice que
los listados son consistentes con lo que les hemos dado de comer.

Uso: verifica.py <dir_src> <dir_work> <cinta.cas>
"""
import hashlib
import json
import os
import subprocess
import sys


def ensambla(asm, out):
    r = subprocess.run(["pasmo", "--bin", asm, out],
                       capture_output=True, text=True)
    return r.returncode, (r.stderr or r.stdout)


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__)
    src, work, cas = sys.argv[1], sys.argv[2], sys.argv[3]
    pz = json.load(open(os.path.join(work, "piezas.json")))
    fallos = 0

    print("=" * 70)
    print(" 1) cada listado ensambla y da su binario, byte a byte")
    print("=" * 70)
    hechos = {}
    for L in sorted(pz["listados"]):
        asm = os.path.join(src, f"demonia_{L}.asm")
        ref = open(os.path.join(work, f"{L}.bin"), "rb").read()
        out = os.path.join(work, f"{L}.pasmo.bin")
        rc, err = ensambla(asm, out)
        if rc:
            print(f"  {L:11s} FALLO: pasmo no ensambla")
            for ln in err.splitlines()[:6]:
                print(f"      {ln}")
            fallos += 1
            continue
        got = open(out, "rb").read()
        hechos[L] = got
        if got == ref:
            print(f"  {L:11s} OK   {len(got):6d} bytes  "
                  f"{hashlib.sha256(got).hexdigest()[:16]}")
        else:
            d = sum(1 for i in range(min(len(got), len(ref)))
                    if got[i] != ref[i]) + abs(len(got) - len(ref))
            print(f"  {L:11s} DIFIERE: {len(got)} bytes contra {len(ref)}, "
                  f"{d} distintos")
            prim = next((i for i in range(min(len(got), len(ref)))
                         if got[i] != ref[i]), None)
            if prim is not None:
                print(f"      primera diferencia en el byte {prim} "
                      f"({pz['listados'][L]['org'] + prim:#06x}): "
                      f"sale {got[prim]:#04x}, deberia ser {ref[prim]:#04x}")
            fallos += 1

    if fallos:
        print(f"\n{fallos} listados sin reproducir. No sigo.")
        return 1

    print()
    print("=" * 70)
    print(" 2) pegando los trozos sale la cinta entera")
    print("=" * 70)
    inv = json.load(open(os.path.join(work, "..", "extracted", "inventario.json")))
    d = open(cas, "rb").read()
    MARCA = bytes.fromhex("1FA6DEBACC137D74")

    for m, trozos in sorted(pz["bloques"].items()):
        dat = b"".join(hechos[L][o:o + n] for L, o, n in trozos)
        ref = open(os.path.join(work, f"{m}.raw"), "rb").read()
        est = "OK" if dat == ref else "DIFIERE"
        print(f"  bloque {m:9s} {len(dat):6d} bytes de "
              f"{len(trozos)} trozo(s)   {est}")
        if dat != ref:
            fallos += 1

    # --- y el fichero .cas completo ---------------------------------------
    print()
    rehecho = bytearray()
    porbloque = {}
    for m, trozos in pz["bloques"].items():
        porbloque[m] = b"".join(hechos[L][o:o + n] for L, o, n in trozos)
    # el orden y el envoltorio salen del inventario que dejo cas_parse.py
    orden = []
    for e in inv:
        if e["clase"] == "BIN":
            nombre = "arranque" if e["load"] == 0x8180 else "juego"
            orden.append(("bin", e, nombre))
        elif e["clase"] == "SINCAB":
            orden.append(("sincab", e, None))
        else:
            orden.append(("otro", e, None))
    icarga = 0
    for tipo, e, nombre in orden:
        if tipo == "otro":                      # el cargador BASIC en ASCII
            cuerpo = open(os.path.join(work, "..", "extracted",
                                       e["fichero"]), "rb").read()
            rehecho += MARCA + bytes([0xEA] * 10) + e["nombre"].ljust(6).encode()
            for k in range(0, len(cuerpo), 256):
                rehecho += MARCA + cuerpo[k:k + 256]
        elif tipo == "bin":
            cab = bytes([0xD0] * 10) + e["nombre"].ljust(6).encode()
            cuerpo = porbloque[nombre]
            tres = (e["load"].to_bytes(2, "little") + e["end"].to_bytes(2, "little")
                    + e["exec"].to_bytes(2, "little"))
            rehecho += MARCA + cab
            rehecho += MARCA + tres + cuerpo
            rehecho += bytes(e["relleno"])
        else:
            icarga += 1
            cuerpo = porbloque[f"carga{icarga}"]
            rehecho += MARCA + cuerpo
            falta = (-len(rehecho)) % 8
            rehecho += bytes(falta)
    rehecho = bytes(rehecho)
    ha = hashlib.sha256(rehecho).hexdigest()
    hb = hashlib.sha256(d).hexdigest()
    print(f"  .cas rehecho : {len(rehecho):6d} bytes  {ha}")
    print(f"  .cas original: {len(d):6d} bytes  {hb}")
    if rehecho == d:
        print("  OK: la cinta entera se reproduce byte a byte")
    else:
        prim = next((i for i in range(min(len(rehecho), len(d)))
                     if rehecho[i] != d[i]), None)
        print(f"  DIFIERE (primera diferencia en el offset {prim})")
        fallos += 1

    return 1 if fallos else 0


if __name__ == "__main__":
    sys.exit(main())
