; ===== Reconstruccion de las helpers del ARRANQUE del monitor =====
; Pantalla: TEXTO 40 columnas (SCREEN 0). Deducido de monitor_casilla_de_la_ventana
; (0xCDCD): direccion = fila*40 + columna + 2, y de que escribe_en_vram saca UN
; byte (codigo de caracter) a la tabla de nombres en 0x0000. 0xC1D4 = (fila<<8|col).
; Cada rutina va en su direccion EXACTA porque el codigo superviviente la llama por
; direccion absoluta. Los huecos se rellenan con 0.

INITXT  equ 0006Ch          ; BIOS: modo texto 40 columnas
FILVRM  equ 00056h          ; BIOS: rellena VRAM
CHGET   equ 0009Fh          ; BIOS: espera y devuelve una tecla en A
LINL40  equ 0F3AEh          ; ancho de linea para SCREEN 0

        org 0D20Bh
d20b_modo_texto:            ; <- llamada al entrar y desde 0xCC93
        ld a,40
        ld (LINL40),a       ; 40 columnas
        call INITXT         ; SCREEN 0
        ret

        org 0D260h
d260_pausa_aviso:          ; <- tras "Commande illegale"; no debe colgar
        ret

        org 0D272h
d272_espera_tecla:         ; <- monitor_lee_una_tecla; devuelve la tecla en A
        call CHGET
        ret

        org 0D2D2h
d2d2_salto_de_linea:       ; <- 9 sitios; placeholder seguro para el primer boot
        ret

        org 0D2DBh
d2db_limpia:               ; <- bucle de ordenes: NO debe borrar (limpia su propia linea)
        ret
