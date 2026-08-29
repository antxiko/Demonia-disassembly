; ===== Reconstruccion de las subrutinas de 0xD200-0xD2FF del monitor =====
; Es la zona que el juego grabo encima. Cada rutina va en su direccion EXACTA
; porque el codigo superviviente la llama por direccion absoluta; los huecos
; entre una y otra se rellenan con 0. NO son los bytes de Sablatou: son
; equivalentes escritos a partir de lo que cada punto de llamada exige
; (el detalle de cada contrato, con su evidencia, esta en CONTRATOS.md).
;
; Pantalla: TEXTO 40 columnas (SCREEN 0). Deducido de monitor_casilla_de_la_ventana
; (0xCDCD): casilla = fila*40 + columna + 2, y de que escribe_en_vram saca UN
; byte (el codigo del caracter) a la tabla de nombres en 0x0000.

INITXT  equ 0006Ch          ; BIOS: modo texto 40 columnas
CHSNS   equ 0009Ch          ; BIOS: Z si no hay tecla en el tampon
CHGET   equ 0009Fh          ; BIOS: espera y devuelve una tecla en A
BEEP    equ 000C0h          ; BIOS: pitido
LINL40  equ 0F3AEh          ; ancho de linea para SCREEN 0

RANURAS_PROGRAMA equ 0C20Ch ; registro de ranuras (puerto 0xA8) del programa detenido
RANURAS_MONITOR  equ 0C20Dh ; el que habia al arrancar el monitor: la BIOS visible
ENTRA_EL_MONITOR equ 0C924h ; la entrada del monitor (la que planta el CALL de los puntos de parada)

        org 0D20Bh
d20b_modo_texto:            ; <- 0xC21D (arranque en frio), 0xC951 (entrada), 0xCC93 (vuelta del paso)
        ld a,40
        ld (LINL40),a       ; 40 columnas
        call INITXT         ; SCREEN 0
        ret

        org 0D21Fh
d21f_antes_de_volver:       ; <- Go 0xC63F, justo antes de reponer los diez registros y saltar
        ret                 ; nada que preparar: las ranuras ya son las del programa (0xD2D2)

        org 0D232h
d232_tecla_f1:              ; <- lee_una_tecla 0xCB20: la tecla F1 (0x85)
        jp 0CB98h           ; un paso ENTRANDO en las llamadas (lo mismo que CTRL+R, 0xCB52)

        org 0D23Ah
d23a_antes_de_borrar:       ; <- 0xC217 (arranque en frio) y 0xCBB0 (F3), antes de borrar la pantalla entera
        ret

        org 0D248h
d248_tecla_f2:              ; <- 0xCB25: la tecla F2 (0x86)
        jp 0CB94h           ; un paso SALTANDO las llamadas (lo mismo que DEL, 0xCB56)

        org 0D250h
d250_tecla_f3:              ; <- 0xCB2A: la tecla F3 (0x87)
        jp 0CBA9h           ; borra la pantalla (lo mismo que CTRL+L, 0xCB5A)

        org 0D258h
d258_tecla_f4:              ; <- 0xCB2F: la tecla F4 (0x88)
        jp 0C68Bh           ; vuelve a pintar los doce registros

        org 0D260h
d260_aviso:                 ; <- 0xC2AC, tras escribir "Commande illegale" o cualquier otro error
        call BEEP           ; un pitido, y 0xC2AF se queda esperando la tecla siguiente
        ret

        org 0D272h
d272_lee_una_tecla:         ; <- 0xCB16. Devuelve la tecla en A; si no hay ninguna, A=0 y Z. NO bloquea:
        ei                  ;    el teclado se lee en la interrupcion
        call CHSNS          ; hay algo en el tampon?
        jr z,d272_nada
        call CHGET          ; si: se recoge
        or a
        ret
d272_nada:
        xor a               ; no: A=0, Z
        ret

        org 0D296h
d296_limite_de_la_pila:     ; <- Go 0xC5E9: DE = limite inferior de la pila del programa (entra con DE=0)
        ret                 ; sin limite: solo se rechaza una pila metida dentro del monitor

        org 0D2C9h
d2c9_gancho_de_error:       ; <- el arranque en frio (0xC221) cuelga aqui el gancho de error de BASIC (0xFFB1)
        jp ENTRA_EL_MONITOR ; un error de BASIC entra en el monitor como si fuera un punto de parada

        org 0D2D2h
d2d2_ranuras_del_programa:  ; <- 9 sitios, siempre ANTES de leer o escribir la memoria del programa
        push af             ;    (desensamblar, volcar, buscar, plantar los CALL). Conserva A y las banderas:
        di                  ;    0xC83C lo llama con el digito tecleado en A
        ld a,(RANURAS_PROGRAMA)
        out (0A8h),a        ; el programa vuelve a ver su memoria; sin interrupciones, por si su pagina 0 es RAM
        pop af
        ret

        org 0D2DBh
d2db_ranuras_del_monitor:   ; <- 11 sitios, siempre ANTES de usar la BIOS (teclado, INITXT, RDVRM, impresora)
        push af             ;    Conserva A (0xCD21 lo llama con el caracter para la impresora) y HL (0xCA60)
        push bc
        in a,(0A8h)
        ld b,a              ; lo que hay puesto ahora
        ld a,(RANURAS_MONITOR)
        cp b
        jr z,d2db_ya        ; ya esta la BIOS visible: nada que hacer
        ld c,a
        ld a,b
        ld (RANURAS_PROGRAMA),a ; se apunta la configuracion del programa, para devolversela luego
        ld a,c
        out (0A8h),a        ; y se pone la del monitor
d2db_ya:
        pop bc
        pop af
        ret
