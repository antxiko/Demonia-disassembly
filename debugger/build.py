#!/usr/bin/env python3
"""Reconstruye la imagen arrancable del monitor desde work/imagen64k.bin.

Requiere (desde la raiz del proyecto):  make   -> work/imagen64k.bin
y, en esta carpeta:  pasmo helpers_arranque.asm helpers_arranque.bin
                     pasmo gen_disasm ... -> disasm.bin ; pasmo lanzador.asm lanzador.bin
Salida:  monitor_boot.bin (org 0xC000).  NO es 100% de Sablatou: ver README.
"""
import sys, os
root=os.path.join(os.path.dirname(__file__), "..")
img=bytearray(open(os.path.join(root,"work","imagen64k.bin"),"rb").read())
A=0xC000
mon=bytearray(img[A:0xDAC8])                         # el monitor superviviente
def put(a,b): mon[a-A:a-A+len(b)]=b
put(0xD20B, open("helpers_arranque.bin","rb").read())# helpers del arranque (0xD20B..0xD2E6)
put(0xD5C6, bytes([0x47,0xD3,0xC5]))                 # 'G' -> 0xC5D3 (Go)
put(0xD5C9, bytes([0x4C,0x35,0xC5]))                 # 'L' -> 0xC535 (listar)
put(0xD5CC, bytes(0xD5F3-0xD5CC))                    # resto de la tabla a cero
put(0xD64A, b"BCDEHLSP")                             # nombres de par (para el desensamblador)
put(0xC184, bytes(0xC198-0xC184))                    # tabla de breakpoints a cero (inocua)
mon[0xC576-A]=0x00; mon[0xC577-A]=0xA0               # call 0xC575: 0xCE27 -> 0xA000 (desensamblador nuevo)
open("monitor_boot.bin","wb").write(mon)
print("monitor_boot.bin: %d bytes (org 0xC000). Cargar ademas disasm.bin@0xA000 y lanzador.bin@0xE000."%len(mon))
