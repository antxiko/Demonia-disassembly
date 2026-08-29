; ==========================================================================
; DEMONIA - MSX - copia los graficos a 0x0000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0bf32


; ======================================================================
; CODIGO 0xbf32..0xbf58  (38 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ====================================================================
; LA RUTINILLA QUE ESCONDE LOS GRAFICOS EN 0x0000
; ====================================================================
; Treinta y ocho bytes, iguales en los dos trozos salvo el destino y la
; longitud: conmuta las paginas 0 y 1 al slot de RAM que encontro el
; trozo 3, hace un LDIR y deja los slots como estaban.
; El cuerpo que copia -la primera mitad de los sprites- se desensambla
; aparte, en src/demonia_bajo0000.asm, porque se lee en 0x0000 y no aqui.
; ----------------------------------------------------------------------
copia_a_0000:		; Direccion de ejecucion que pide su entrada en la tabla de 0x8180
	di			;bf32   ; Con las paginas conmutadas no hay BIOS: nada de interrupciones
	ld a,(0fd98h)		;bf33   ; El registro de primarios con la RAM, que apunto el trozo 3
	out (0a8h),a		;bf36
	ld a,(0fd99h)		;bf38   ; Y el de secundarios
	ld (0ffffh),a		;bf3b
	ld hl,0a000h		;bf3e   ; Origen: el cuerpo de este bloque, donde la cinta lo dejo
	ld de,00000h		;bf41   ; Destino: la RAM que hay debajo de la ROM
	ld bc,01f32h		;bf44   ; Cuantos bytes se mueven
	ldir		;bf47
	ld a,(0fd96h)		;bf49   ; Y de vuelta al mapa de siempre, con la ROM en su sitio
	out (0a8h),a		;bf4c
	ld a,(0fd97h)		;bf4e
	ld (0ffffh),a		;bf51
	call 000c0h		;bf54   ; BIOS BEEP - Generates beep | Un pitido: trozo colocado
	ret			;bf57
