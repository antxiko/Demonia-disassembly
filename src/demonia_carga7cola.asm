; ==========================================================================
; DEMONIA - MSX - copia la musica a 0x7900
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x096e8


; ----------------------------------------------------------------------
; DATOS restos_no_copiados: Dieciseis bytes entre el final del cuerpo que se
;   copia (0x96E7) y el arranque de la rutina. Ni se copian a la RAM escondida
;   ni se ejecutan aqui
;   0x96e8..0x96f8  (16 bytes)

; ----------------------------------------------------------------------
; ====================================================================
; TROZO 7, LA COLA: LA MUSICA A 0x7900
; ====================================================================
; El ultimo trozo de la carga, y el mas pequeno: 1768 bytes que se
; esconden en 0x7900. Son la partitura y el reproductor, y se
; desensamblan en src/demonia_bajo7900.asm.
; Fijarse en lo que NO copia: el bloque de cinta llega hasta 0x971F
; pero el LDIR solo mueve hasta 0x96E7. Los 56 bytes de arriba son
; esta rutina y los dieciseis que la preceden, que se quedan atras.
; ----------------------------------------------------------------------
DATA_restos_no_copiados:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 96e8  ................

; ======================================================================
; CODIGO 0x96f8..0x9720  (40 bytes)
; ======================================================================


copia_la_musica:		; Direccion de ejecucion que pide la entrada 7 de la tabla de 0x8180
	di			;96f8   ; Sin interrupciones
	ld a,(0fd98h)		;96f9   ; El slot de RAM que apunto el trozo 3
	out (0a8h),a		;96fc
	ld a,(0fd99h)		;96fe   ; Y el de secundarios
	ld (0ffffh),a		;9701
	ld hl,09000h		;9704   ; Origen: el principio de este mismo bloque
	ld de,07900h		;9707   ; Destino: 0x7900, en la pagina 1 escondida
	ld bc,006e8h		;970a   ; 0x6E8 = 1768 bytes; el bloque de cinta trae 1824
	ldir		;970d
	ld a,(0fd96h)		;970f   ; Devuelve los slots
	out (0a8h),a		;9712
	ld a,(0fd97h)		;9714
	ld (0ffffh),a		;9717
	call 000c0h		;971a   ; BIOS BEEP - Generates beep | Dos pitidos, y con el jp del final se vuelve al cargador
	jp 000c0h		;971d   ; BIOS BEEP - Generates beep
