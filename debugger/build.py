#!/usr/bin/env python3
"""Reconstruye la imagen arrancable del monitor desde work/imagen64k.bin.

Requiere (desde la raiz del proyecto):  make   -> work/imagen64k.bin
y, en esta carpeta:  pasmo helpers.asm helpers.bin
                     python gen_disasm.py disasm.asm && pasmo disasm.asm disasm.bin
                     pasmo lanzador.asm lanzador.bin
Salida:  monitor_boot.bin (org 0xC000).  NO es 100% de Sablatou: ver README.
"""
import sys, os
root=os.path.join(os.path.dirname(__file__), "..")
img=bytearray(open(os.path.join(root,"work","imagen64k.bin"),"rb").read())
A=0xC000
mon=bytearray(img[A:0xDAC8])                         # el monitor superviviente
def put(a,b): mon[a-A:a-A+len(b)]=b

# Las subrutinas de 0xD200-0xD2FF, rehechas por contrato (helpers.asm)
put(0xD20B, open(os.path.join(os.path.dirname(__file__),"helpers.bin"),"rb").read())

# La tabla de ordenes (0xD5C6): 15 entradas de [letra, puntero]. Los punteros son
# los manejadores que sobreviven en el codigo; las letras se han elegido por lo que
# hace cada uno (las historicas se perdieron con la tabla). El interprete pasa la
# letra tecleada por RES 5 (0xC289): por eso '=' (0x3D) se busca como 0x1D.
ORDENES=[
    (0x47,0xC5D3),  # G  Go: sigue en la direccion dada (o en el PC guardado)
    (0x4C,0xC535),  # L  Lista (desensambla) desde,hasta
    (0x44,0xC748),  # D  Dump: vuelca 128 bytes y deja editarlos (flechas, digitos, +/-, RETURN sale)
    (0x53,0xC6BD),  # S  Search: busca una cadena de bytes desde una direccion
    (0x52,0xC667),  # R  Registros: R los pinta, RHL=1234H cambia uno
    (0x42,0xC8F1),  # B  Breakpoints: B los lista, B3=7FE0H pone el 3
    (0x54,0xC97A),  # T  Trace: ejecuta paso a paso sin parar hasta CTRL+C
    (0x1D,0xC5B6),  # =  Evalua una expresion: =7FE0H+3
    (0x46,0xC98F),  # F  Flags: las ocho banderas del programa detenido
    (0x49,0xC9B6),  # I  Interrupciones: permitidas/prohibidas al devolver el mando
]
for i in range(15):
    letra,ptr = ORDENES[i] if i<len(ORDENES) else (0xFF,0xC661)   # sobrantes: nunca casan
    put(0xD5C6+3*i, bytes([letra, ptr&0xFF, ptr>>8]))
assert 0xD5C6+45==0xD5F3                            # la tabla acaba justo donde empezaba la de formatos

put(0xD64A, b"BCDEHLSP")                             # nombres de par (para el desensamblador viejo)
put(0xC184, bytes(0xC198-0xC184))                    # tabla de puntos de parada a cero (ninguno puesto)

# El desensamblador nuevo vive en 0xA000: se repuntan las DOS llamadas a 0xCE27
for call in (0xC575, 0xCBD4):                        # L/volcado del PC y el paso a paso
    assert mon[call-A]==0xCD and mon[call+1-A]==0x27 and mon[call+2-A]==0xCE, hex(call)
    mon[call+1-A]=0x00; mon[call+2-A]=0xA0
open(os.path.join(os.path.dirname(__file__),"monitor_boot.bin"),"wb").write(mon)
print("monitor_boot.bin: %d bytes (org 0xC000). Cargar ademas disasm.bin@0xA000 y lanzador.bin@0xE000."%len(mon))
