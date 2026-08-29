; ==========================================================================
; DEMONIA - MSX - copia patrones y colores a 0x6000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0afd0


; ======================================================================
; CODIGO 0xafd0..0xafdd  (13 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ====================================================================
; TROZO 6, LA CABEZA: PATRONES Y COLORES A 0x6000
; ====================================================================
; Este trozo lleva la rutinilla DELANTE del cuerpo, al reves que los
; demas, porque su cuerpo tenia que quedar alineado en 0xB000 para
; poder copiarlo a 0x6000 de una pieza.
; El cuerpo -los 4096 bytes de patrones y colores de SCREEN 2 del
; juego- se desensambla en src/demonia_bajo6000.asm.
; ----------------------------------------------------------------------
devuelve_el_slot:		; Repone los secundarios y avisa con dos pitidos
	ld a,(0fd97h)		;afd0   ; El registro de secundarios original
	ld (0ffffh),a		;afd3
	call 000c0h		;afd6   ; BIOS BEEP - Generates beep | Dos pitidos
	call 000c0h		;afd9   ; BIOS BEEP - Generates beep
	ret			;afdc   ; Vuelta al cargador

; ----------------------------------------------------------------------
; DATOS tres_ret_sueltos: Tres RET seguidos que rellenan hasta 0xAFE0, que es
;   donde la tabla de 0x8180 manda arrancar
;   0xafdd..0xafe0  (3 bytes)
DATA_tres_ret_sueltos:
	defb 0c9h,0c9h,0c9h	; afdd

; ======================================================================
; CODIGO 0xafe0..0xafff  (31 bytes)
; ======================================================================


copia_a_6000:		; Direccion de ejecucion que pide la entrada 6 de la tabla de 0x8180
	di			;afe0   ; Sin interrupciones mientras la ROM no este
	ld a,(0fd98h)		;afe1   ; El slot de RAM que apunto el trozo 3
	out (0a8h),a		;afe4
	ld a,(0fd99h)		;afe6   ; Y el registro de secundarios
	ld (0ffffh),a		;afe9
	ld hl,0b000h		;afec   ; Origen: el cuerpo, que empieza en 0xB000
	ld de,06000h		;afef   ; Destino: 0x6000, dentro de la pagina 1 escondida
	ld bc,01000h		;aff2   ; 4096 bytes: 2048 de patrones y 2048 de color
	ldir		;aff5
	ld a,(0fd96h)		;aff7   ; Devuelve los primarios
	out (0a8h),a		;affa
	jp devuelve_el_slot		;affc   ; La cola de la restauracion esta en 0xAFD0, delante

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xafff..0xb000  (1 bytes)
DATA_relleno_cero:
	defb 000h	; afff
