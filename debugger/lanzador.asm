; Lanzador de pruebas: hace lo que haria un programa detenido en un punto de
; parada. Deja los registros con valores reconocibles y entra en el monitor
; por su entrada de siempre (0xC924, la que planta el CALL de los puntos de
; parada). Antes repite dos cosas que el arranque en frio del monitor (0xC20E)
; hace por su cuenta y que aqui hacen falta porque no pasamos por el:
;  - apuntar el registro de ranuras (0xC20C/0xC20D), que usan 0xD2D2 y 0xD2DB;
;  - definir F1..F4 como 0x85..0x88 (0xC22C-0xC249), que es como el monitor
;    distingue sus teclas de funcion al leer con CHGET.
FNKSTR  equ 0F87Fh          ; las diez cadenas de las teclas de funcion, 16 bytes cada una

        org 0E000h
        di
        ld sp,0EFF0h
        in a,(0A8h)
        ld (0C20Ch),a       ; ranuras del programa: las de ahora
        ld (0C20Dh),a       ; ranuras del monitor: las mismas (la BIOS esta visible)
        ld hl,FNKSTR
        ld a,085h
        ld b,4
fkeys:  ld (hl),a           ; F1="\x85", F2="\x86", F3="\x87", F4="\x88"
        inc hl
        ld (hl),0
        ld de,15
        add hl,de
        inc a
        djnz fkeys
        ld hl,01234h
        ld de,05678h
        ld bc,09ABCh
        ld ix,0AAAAh
        ld iy,0BBBBh
        ei
        call 0C924h        ; entra en el monitor por CALL, con pila limpia
        di
bucle:  halt
        jr bucle
