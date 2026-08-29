#!/usr/bin/env python3
# Desensamblador Z80 (equivalente funcional) para el monitor de Demonia.
# Contrato: IX=direccion -> 0xC1E4 (texto) + 0xC1E3 (longitud).
# Comodines de plantilla:  #=byte n   @=word nn   $=salto relativo
# Cubre: sin prefijo, CB, ED, DD/FD y DDCB/FDCB. Ademas deja el tipo de
# instruccion en 0xC1BB y el destino del salto en 0xC1C4 (para el paso a paso).
import sys

# Marcadores de TIPO (primer byte de la plantilla) para el paso a paso del
# monitor: 0xCBE7-0xCC4E decide como ejecutar la instruccion segun 0xC1BB y
# 0xC1C4 (deducido de ese codigo superviviente):
#   1 = JP nn / JP cc,nn     -> se le cambia el operando por 0xCC74
#   2 = JR / JR cc / DJNZ    -> se le cambia el desplazamiento por 0x13
#   3 = CALL / CALL cc / RST -> idem que 1, y ademas arregla la vuelta
#   4 = RET / RET cc / RETI / RETN -> mete 0xCC74 en la pila
#   5 = JP (HL)/(IX)/(IY)    -> lo convierte en JP nn con el registro
#   6 = RST (marcador propio: tipo 3 con destino = opcode & 0x38)
# El destino del salto va a 0xC1C4 (lo escribe la rutina del operando).
TJP=''; TJR=''; TCALL=''; TRET=''; TJPR=''; TRST=''

r  = ['B','C','D','E','H','L','(HL)','A']
rp = ['BC','DE','HL','SP']
rp2= ['BC','DE','HL','AF']
cc = ['NZ','Z','NC','C','PO','PE','P','M']
alu= ['ADD A,','ADC A,','SUB ','SBC A,','AND ','XOR ','OR ','CP ']
rot= ['RLC','RRC','RL ','RR ','SLA','SRA','SLL','SRL']

# ---------------- SIN PREFIJO ----------------
T=[None]*256
def s(o,t): T[o]=t
s(0x00,'NOP'); s(0x08,"EX AF,AF'"); s(0x10,TJR+'DJNZ $'); s(0x18,TJR+'JR $')
for i,c in enumerate(['NZ','Z','NC','C']): s(0x20+i*8,TJR+'JR '+c+',$')
for i,p in enumerate(rp):
    s(0x01+i*0x10,'LD '+p+',@'); s(0x09+i*0x10,'ADD HL,'+p)
    s(0x03+i*0x10,'INC '+p);     s(0x0B+i*0x10,'DEC '+p)
s(0x02,'LD (BC),A'); s(0x12,'LD (DE),A'); s(0x22,'LD (@),HL'); s(0x32,'LD (@),A')
s(0x0A,'LD A,(BC)'); s(0x1A,'LD A,(DE)'); s(0x2A,'LD HL,(@)'); s(0x3A,'LD A,(@)')
for i in range(8):
    s(0x04+i*8,'INC '+r[i]); s(0x05+i*8,'DEC '+r[i]); s(0x06+i*8,'LD '+r[i]+',#')
for o,m in [(0x07,'RLCA'),(0x0F,'RRCA'),(0x17,'RLA'),(0x1F,'RRA'),(0x27,'DAA'),(0x2F,'CPL'),(0x37,'SCF'),(0x3F,'CCF')]: s(o,m)
for d in range(8):
    for ss in range(8):
        o=0x40+d*8+ss
        s(o,'HALT' if o==0x76 else 'LD '+r[d]+','+r[ss])
for a in range(8):
    for ss in range(8): s(0x80+a*8+ss, alu[a]+r[ss])
for i,c in enumerate(cc):
    s(0xC0+i*8,TRET+'RET '+c); s(0xC2+i*8,TJP+'JP '+c+',@'); s(0xC4+i*8,TCALL+'CALL '+c+',@')
for i,p in enumerate(rp2): s(0xC1+i*0x10,'POP '+p); s(0xC5+i*0x10,'PUSH '+p)
s(0xC3,TJP+'JP @'); s(0xC9,TRET+'RET'); s(0xCD,TCALL+'CALL @')
for i in range(8): s(0xC7+i*8,TRST+'RST %02X'%(i*8))
for i,a in enumerate(alu): s(0xC6+i*8, a+'#')
s(0xD3,'OUT (#),A'); s(0xDB,'IN A,(#)')
s(0xE3,'EX (SP),HL'); s(0xEB,'EX DE,HL'); s(0xE9,TJPR+'JP (HL)'); s(0xF9,'LD SP,HL')
s(0xF3,'DI'); s(0xFB,'EI')
s(0xCB,'CB?'); s(0xDD,'DD?'); s(0xED,'ED?'); s(0xFD,'FD?')  # prefijos (dispatch aparte)
for o in range(256):
    if T[o] is None: T[o]='?'

# ---------------- CB ----------------
CB=[None]*256
for o in range(256):
    y=(o>>3)&7; z=o&7
    if o<0x40:   CB[o]=rot[y].strip()+' '+r[z]
    elif o<0x80: CB[o]='BIT %d,%s'%(y,r[z])
    elif o<0xC0: CB[o]='RES %d,%s'%(y,r[z])
    else:        CB[o]='SET %d,%s'%(y,r[z])

# ---------------- ED ----------------
ED=['?']*256
def e(o,t): ED[o]=t
for i,p in enumerate(rp):
    e(0x43+i*0x10,'LD (@),'+p); e(0x4B+i*0x10,'LD '+p+',(@)')
    e(0x42+i*0x10,'SBC HL,'+p); e(0x4A+i*0x10,'ADC HL,'+p)
for i,rg in enumerate(['B','C','D','E','H','L','?','A']):
    if rg!='?':
        e(0x40+i*8,'IN '+rg+',(C)'); e(0x41+i*8,'OUT (C),'+rg)
e(0x44,'NEG'); e(0x45,TRET+'RETN'); e(0x4D,TRET+'RETI'); e(0x46,'IM 0'); e(0x56,'IM 1'); e(0x5E,'IM 2')
e(0x47,'LD I,A'); e(0x4F,'LD R,A'); e(0x57,'LD A,I'); e(0x5F,'LD A,R'); e(0x67,'RRD'); e(0x6F,'RLD')
for o,m in [(0xA0,'LDI'),(0xA1,'CPI'),(0xA2,'INI'),(0xA3,'OUTI'),(0xA8,'LDD'),(0xA9,'CPD'),(0xAA,'IND'),(0xAB,'OUTD'),
            (0xB0,'LDIR'),(0xB1,'CPIR'),(0xB2,'INIR'),(0xB3,'OTIR'),(0xB8,'LDDR'),(0xB9,'CPDR'),(0xBA,'INDR'),(0xBB,'OTDR')]:
    e(o,m)

# ---------------- DD / FD (IX / IY) ----------------
# Se derivan de la tabla sin prefijo sustituyendo: (HL)->(~+%) , HL->~
# ~ = nombre del registro indice (IX o IY) ; % = desplazamiento con signo
DDFD=['?']*256
for o in range(256):
    t=T[o]
    if t in ('CB?','DD?','ED?','FD?','?'):
        DDFD[o]='?'; continue
    if '(HL)' in t: t=t.replace('(HL)','(~%)')
    elif 'HL' in t: t=t.replace('HL','~')
    else:
        # instruccion no afectada por el prefijo: el prefijo es "ignorado"
        pass
    DDFD[o]=t
DDFD[0xE9]=TJPR+'JP (~)'   # JP (IX), sin desplazamiento
DDFD[0xEB]='EX DE,HL'      # el prefijo se ignora aqui

# ---------------- emitir asm ----------------
INTERP = r'''
; ============ Desensamblador Z80 (equivalente funcional) ============
; Reconstruccion para el monitor de Loriciels de Demonia. IX=direccion.
; Rellena DBUF (16 char) y DLEN (longitud). Sin prefijo, CB, ED, DD/FD.
DBUF equ 0C1E4h
DLEN equ 0C1E3h
DTIPO equ 0C1BBh         ; tipo de instruccion para el paso a paso (0 = normal)
DDEST equ 0C1C4h         ; destino del salto, para el paso a paso
        org 0A000h
disasm:
        ld hl,DBUF
        ld b,010h
dclr:   ld (hl),020h
        inc hl
        djnz dclr
        xor a
        ld (DTIPO),a       ; tipo 0 (normal) por defecto; los marcadores 1..6 lo cambian
        ld de,DBUF
        ld a,(ix+000h)
        cp 0CBh
        jr z,dpcb
        cp 0EDh
        jr z,dped
        cp 0DDh
        jr z,dpdd
        cp 0FDh
        jr z,dpfd
        ld bc,DPTRS
        ld l,001h
        jr ddisp
dpcb:   ld a,(ix+001h)
        ld bc,DCBPTRS
        ld l,002h
        jr ddisp
dped:   ld a,(ix+001h)
        ld bc,DEDPTRS
        ld l,002h
        jr ddisp
dpdd:   ld hl,dixnam
        ld (hl),'I'
        inc hl
        ld (hl),'X'
        jr dprfx
dpfd:   ld hl,dixnam
        ld (hl),'I'
        inc hl
        ld (hl),'Y'
dprfx:  ld a,(ix+001h)
        cp 0CBh
        jp z,ddcb
        ld bc,DDFDPTRS
        ld l,002h
ddisp:  push af
        ld a,l
        ld (DLEN),a
        pop af
        ld l,a
        ld h,000h
        add hl,hl
        add hl,bc
        ld c,(hl)
        inc hl
        ld b,(hl)
drender:
        ld a,(bc)
        or a
        ret z
        cp 008h
        jp c,dtipo
        cp 023h
        jp z,ddn
        cp 040h
        jp z,ddnn
        cp 024h
        jp z,ddrel
        cp 07Eh
        jp z,ddidx
        cp 025h
        jp z,ddis8
        ld (de),a
        inc de
        inc bc
        jp drender
; --- marcador de tipo (1..6) al principio de la plantilla ---
dtipo:  cp 006h
        jr z,drst
        ld (DTIPO),a
        inc bc
        jp drender
drst:   ld a,003h            ; un RST es un CALL de un byte
        ld (DTIPO),a
        ld a,(ix+000h)
        and 038h
        ld l,a
        ld h,000h
        ld (DDEST),hl        ; destino: 0x00, 0x08 ... 0x38
        inc bc
        jp drender
ddidx:  ld a,(dixnam)
        ld (de),a
        inc de
        ld a,(dixnam+1)
        ld (de),a
        inc de
        inc bc
        jp drender
ddn:    push bc
        call ddsrc
        ld a,(hl)
        call ddhex2
        ld hl,DLEN
        inc (hl)
        pop bc
        inc bc
        jp drender
ddnn:   push bc
        call ddsrc
        ld a,(hl)
        inc hl
        ld h,(hl)
        ld l,a
        ld (DDEST),hl        ; el operando nn, por si es el destino de un salto
        ld a,h
        call ddhex2
        ld a,l
        call ddhex2
        ld hl,DLEN
        inc (hl)
        inc (hl)
        pop bc
        inc bc
        jp drender
ddrel:  push bc
        call ddsrc
        ld a,(hl)
        ld l,a
        ld h,000h
        bit 7,a
        jr z,ddrp
        ld h,0FFh
ddrp:   push de
        push ix
        pop de
        add hl,de
        pop de
        push hl
        ld a,(DLEN)
        ld l,a
        ld h,000h
        inc hl
        pop bc
        add hl,bc
        ld (DDEST),hl        ; el destino del salto relativo
        ld a,h
        call ddhex2
        ld a,l
        call ddhex2
        ld hl,DLEN
        inc (hl)
        pop bc
        inc bc
        jp drender
ddsrc:  ld a,(DLEN)
        ld c,a
        ld b,000h
        push ix
        pop hl
        add hl,bc
        ret
ddhex2: push af
        rrca
        rrca
        rrca
        rrca
        call ddhex1
        pop af
ddhex1: and 00Fh
        add a,090h
        daa
        adc a,040h
        daa
        ld (de),a
        inc de
        ret
; --- '%' desplazamiento con signo (IX+d) ---
ddis8:  push bc
        call ddsrc
        ld a,(hl)
        bit 7,a
        jr z,ddi8p
        neg
        ld c,a
        ld a,02Dh
        jr ddi8e
ddi8p:  ld c,a
        ld a,02Bh
ddi8e:  ld (de),a
        inc de
        ld a,c
        call ddhex2
        ld hl,DLEN
        inc (hl)
        pop bc
        inc bc
        jp drender
; --- DD/FD CB d op : operacion sobre (IX+d), 4 bytes ---
ddcb:   ld a,004h
        ld (DLEN),a
        ld a,(ix+003h)
        ld c,a
        and 0C0h
        rlca
        rlca
        or a
        jr nz,ddcbbrs
        ld a,c
        rrca
        rrca
        rrca
        and 007h
        add a,a
        add a,a
        ld l,a
        ld h,000h
        ld bc,DDCBROT
        add hl,bc
        ld b,004h
ddcbr:  ld a,(hl)
        ld (de),a
        inc de
        inc hl
        djnz ddcbr
        jr ddcbop
ddcbbrs:
        dec a
        add a,a
        add a,a
        ld l,a
        ld h,000h
        ld bc,DDCBWRD
        add hl,bc
        ld b,004h
ddcbw:  ld a,(hl)
        ld (de),a
        inc de
        inc hl
        djnz ddcbw
        ld a,(ix+003h)      ; el opcode otra vez: BC quedo pisado por DDCBWRD
        rrca
        rrca
        rrca
        and 007h
        add a,030h
        ld (de),a
        inc de
        ld a,02Ch
        ld (de),a
        inc de
ddcbop: ld a,028h
        ld (de),a
        inc de
        ld a,(dixnam)
        ld (de),a
        inc de
        ld a,(dixnam+1)
        ld (de),a
        inc de
        ld a,(ix+002h)
        bit 7,a
        jr z,ddcbp
        neg
        ld c,a
        ld a,02Dh
        jr ddcbe
ddcbp:  ld c,a
        ld a,02Bh
ddcbe:  ld (de),a
        inc de
        ld a,c
        call ddhex2
        ld a,029h
        ld (de),a
        inc de
        ret
dixnam: defb 020h,020h
DDCBROT: defb "RLC ","RRC ","RL  ","RR  ","SLA ","SRA ","SLL ","SRL "
DDCBWRD: defb "BIT ","RES ","SET "
'''
def emit_table(name, arr):
    L=[name+':']
    for o in range(256): L.append('    defw %s+%d'%(POOLNAME,intern(arr[o])))
    return L

pool={}; poolbytes=bytearray()
def intern(t):
    if t in pool: return pool[t]
    off=len(poolbytes); pool[t]=off
    poolbytes.extend(t.encode('ascii')); poolbytes.append(0)
    return off
POOLNAME='DPOOL'
lines=[INTERP]
lines+=emit_table('DPTRS',T)
lines+=emit_table('DCBPTRS',CB)
lines+=emit_table('DEDPTRS',ED)
lines+=emit_table('DDFDPTRS',DDFD)
lines.append(POOLNAME+':')
i=0
while i<len(poolbytes):
    lines.append('    defb '+','.join('0%02xh'%b for b in poolbytes[i:i+16])); i+=16
open(sys.argv[1],'w',newline='\n').write('\n'.join(lines)+'\n')
print('sin-prefijo:',sum(1 for o in range(256) if T[o]!='?'),' CB:256  ED:',sum(1 for o in range(256) if ED[o]!='?'))
print('pool:',len(poolbytes),'bytes')
