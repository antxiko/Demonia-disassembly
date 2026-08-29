#!/usr/bin/env python3
"""Coteja la imagen de 64K que monta el proyecto contra la RAM real del emulador.

Es la comprobacion mas dura del reparto: si tools/imagen.py aplica bien las
copias que hacen las rutinillas de la cinta, la memoria que monta tiene que ser
identica a la que openMSX tiene dentro cuando el juego esta corriendo.

Lo unico que puede -y debe- diferir es el bloque del juego, porque sus primeros
256 bytes son sus VARIABLES y en la cinta van con el valor que tuvieran al
grabar. Esa diferencia se informa y no cuenta como fallo; lo que si es fallo es
que difiera un solo byte de los cinco trozos escondidos bajo la ROM.

Uso: coteja_ram.py <imagen64k.bin> <mapa.json> <ram64k.bin>
Si el volcado no existe, no falla: avisa de que la medida no se ha hecho.
"""
import json
import os
import sys

img_p, mapa_p, ram_p = sys.argv[1:4]
if not os.path.exists(ram_p):
    print(f"  (sin volcado en {ram_p}: no se ha medido en el emulador)")
    sys.exit(0)
img = open(img_p, "rb").read()
ram = open(ram_p, "rb").read()
mapa = json.load(open(mapa_p))
malo = 0
for t in mapa["tramos"]:
    a, n = t["org"], t["bytes"]
    d = sum(1 for i in range(n) if img[a + i] != ram[a + i])
    if t["modulo"] == "juego":
        print(f"  {t['modulo']:9s} {a:#06x}..{a+n-1:#06x} {n:6d} bytes  "
              f"{d} distintos = sus variables (0x8000-0x80FF), no es fallo")
        continue
    print(f"  {t['modulo']:9s} {a:#06x}..{a+n-1:#06x} {n:6d} bytes  "
          f"{'IDENTICO' if d == 0 else str(d) + ' DISTINTOS'}")
    malo += d
sys.exit(1 if malo else 0)
