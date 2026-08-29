; ==========================================================================
; DEMONIA - MSX - copia los graficos a 0x1F32
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0bb96


; ======================================================================
; CODIGO 0xbb96..0xbbbc  (38 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ====================================================================
; LA RUTINILLA QUE ESCONDE LOS GRAFICOS EN 0x1f32
; ====================================================================
; Treinta y ocho bytes, iguales en los dos trozos salvo el destino y la
; longitud: conmuta las paginas 0 y 1 al slot de RAM que encontro el
; trozo 3, hace un LDIR y deja los slots como estaban.
; El cuerpo que copia -la segunda mitad de los sprites- se desensambla
; aparte, en src/demonia_bajo0000.asm, porque se lee en 0x1f32 y no aqui.
; ----------------------------------------------------------------------
copia_a_1f32:		; Direccion de ejecucion que pide su entrada en la tabla de 0x8180
	di			;bb96   ; Con las paginas conmutadas no hay BIOS: nada de interrupciones
	ld a,(0fd98h)		;bb97   ; El registro de primarios con la RAM, que apunto el trozo 3
	out (0a8h),a		;bb9a
	ld a,(0fd99h)		;bb9c   ; Y el de secundarios
	ld (0ffffh),a		;bb9f
	ld hl,0a000h		;bba2   ; Origen: el cuerpo de este bloque, donde la cinta lo dejo
	ld de,01f32h		;bba5   ; Destino: la RAM que hay debajo de la ROM
	ld bc,01b96h		;bba8   ; Cuantos bytes se mueven
	ldir		;bbab
	ld a,(0fd96h)		;bbad   ; Y de vuelta al mapa de siempre, con la ROM en su sitio
	out (0a8h),a		;bbb0
	ld a,(0fd97h)		;bbb2
	ld (0ffffh),a		;bbb5
	call 000c0h		;bbb8   ; BIOS BEEP - Generates beep | Un pitido: trozo colocado
	ret			;bbbb
