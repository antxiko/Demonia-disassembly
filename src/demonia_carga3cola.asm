; ==========================================================================
; DEMONIA - MSX - busca el slot de 64K y copia a 0x4000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0b468


; ======================================================================
; CODIGO 0xb468..0xb487  (31 bytes)
; ======================================================================



; ----------------------------------------------------------------------
; ====================================================================
; TROZO 3, LA COLA: BUSCA UN SLOT CON 64 KB DE RAM
; ====================================================================
; Aqui esta la maniobra que hace posible el juego. Demonia ocupa mas de
; lo que cabe en la RAM visible de un MSX arrancado desde BASIC, donde
; las paginas 0 y 1 (0x0000-0x7FFF) las tapa la ROM. Asi que busca un
; slot que tenga RAM DEBAJO de esa ROM y esconde ahi 26 KB.
;
; La busqueda es a la brava: recorre los cuatro slots primarios y, en
; cada uno, los cuatro secundarios; en cada combinacion escribe 0x55 y
; 0xAA en 0x0000 y en 0x4000 y comprueba que se leen de vuelta. El
; primero que pasa la prueba se guarda en 0xFD98 (primarios) y 0xFD99
; (secundarios), y todo el juego usara esos dos bytes a partir de aqui.
;
; Si no hay 64 KB, escribe un mensaje y devuelve la maquina al BASIC.
; ----------------------------------------------------------------------
busca_64k:		; Direccion de ejecucion que pide la entrada 3 de la tabla de 0x8180
	di			;b468   ; Nada de interrupciones mientras se toquetean los slots
	in a,(0a8h)		;b469   ; Lee el registro de slots primarios
	ld (0fd96h),a		;b46b   ; Lo guarda para dejarlo luego como estaba
	and 0f0h		;b46e   ; Se queda con las paginas 2 y 3, que no se tocan
	ld d,a			;b470   ; D = valor de primarios que se va probando
	ld a,(0ffffh)		;b471   ; El registro de secundarios se lee de 0xFFFF, e invertido
	cpl			;b474   ; Deshace la inversion
	ld (0fd97h),a		;b475   ; Y se guarda
	and 0f0h		;b478
	ld e,a			;b47a
	ld b,004h		;b47b   ; Cuatro slots primarios
bucle_primarios:
	call prueba_cuatro_secundarios		;b47d   ; Prueba los cuatro secundarios de este primario
	jr c,$+88		;b480   ; Con acarreo: encontrado, a 0xB4D8 a copiar
	djnz bucle_primarios		;b482   ; Siguiente primario
	jp sin_64k		;b484   ; Se acabaron los slots y no hay 64 KB

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb487..0xb488  (1 bytes)
DATA_B487:
	defb 000h	; b487

; ======================================================================
; CODIGO 0xb488..0xb4b6  (46 bytes)
; ======================================================================


prueba_cuatro_secundarios:		; Devuelve acarreo si alguno tiene RAM en las paginas 0 y 1
	exx			;b488
	ld b,004h		;b489   ; Cuatro secundarios
bucle_secundarios:
	exx			;b48b
	ld a,d			;b48c   ; Pone el primario que toca en las paginas 0 y 1
	out (0a8h),a		;b48d
	ld a,e			;b48f   ; Y el secundario
	ld (0ffffh),a		;b490
	call hay_ram_aqui		;b493   ; Hay RAM de verdad ahi?
	jr z,apunta_el_slot		;b496   ; Si: con este ya vale
	ld a,005h		;b498   ; Suma 1 a los campos de pagina 0 y 1 a la vez (0b0000_0101)
	add a,e			;b49a
	ld e,a			;b49b
	exx			;b49c
	djnz bucle_secundarios		;b49d   ; Siguiente secundario
	ld a,(0fd97h)		;b49f   ; Vuelve al valor original de secundarios
	and 0f0h		;b4a2
	exx			;b4a4
	ld e,a			;b4a5
	ld a,005h		;b4a6   ; Suma 1 al campo de primarios de las paginas 0 y 1
	add a,d			;b4a8
	ld d,a			;b4a9
	sub a			;b4aa   ; Sin acarreo: en este primario no habia
	ret			;b4ab
apunta_el_slot:		; Encontrado: guarda los dos registros de slot para todo el juego
	ld a,d			;b4ac
	ld (0fd98h),a		;b4ad   ; 0xFD98 = valor de primarios con la RAM puesta
	ld a,e			;b4b0
	ld (0fd99h),a		;b4b1   ; 0xFD99 = valor de secundarios
	scf			;b4b4   ; Acarreo = encontrado
	ret			;b4b5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb4b6..0xb4b8  (2 bytes)
DATA_B4B6:
	defb 000h,000h	; b4b6

; ======================================================================
; CODIGO 0xb4b8..0xb4d2  (26 bytes)
; ======================================================================


hay_ram_aqui:		; Escribe y relee 0x55 y 0xAA en 0x0000 y en 0x4000
	ld hl,00000h		;b4b8   ; Pagina 0
	ld a,055h		;b4bb
	ld (hl),a			;b4bd   ; Escribe 0x55...
	cp (hl)			;b4be   ; ...y comprueba que vuelve
	ret nz			;b4bf
	ld a,0aah		;b4c0   ; Ahora el complementario, por si hubiera lineas de datos pegadas
	ld (hl),a			;b4c2
	cp (hl)			;b4c3
	ret nz			;b4c4
	ld hl,04000h		;b4c5   ; Pagina 1
	ld a,055h		;b4c8
	ld (hl),a			;b4ca
	cp (hl)			;b4cb
	ret nz			;b4cc
	ld a,0aah		;b4cd
	ld (hl),a			;b4cf
	cp (hl)			;b4d0
	ret			;b4d1   ; Z si el ultimo valor volvio bien

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb4d2..0xb4d8  (6 bytes)
DATA_B4D2:
	defb 000h,000h,000h,000h,000h,000h	; b4d2

; ======================================================================
; CODIGO 0xb4d8..0xb4f2  (26 bytes)
; ======================================================================


esconde_bajo_la_rom:		; Copia los 5224 bytes del cuerpo a 0x4000, ya en RAM
	ld hl,0a000h		;b4d8   ; Origen: el cuerpo de este mismo trozo
	ld de,04000h		;b4db   ; Destino: pagina 1, que ahora es RAM
	ld bc,01468h		;b4de   ; 0x1468 = 5224 bytes, todo el cuerpo
	ldir		;b4e1
	ld a,(0fd96h)		;b4e3   ; Devuelve el registro de primarios como estaba
	out (0a8h),a		;b4e6
	ld a,(0fd97h)		;b4e8   ; Y el de secundarios
	ld (0ffffh),a		;b4eb
	call 000c0h		;b4ee   ; BIOS BEEP - Generates beep | Un pitido: trozo 3 colocado
	ret			;b4f1

; ----------------------------------------------------------------------
; DATOS mensaje_sin_64k: El texto que se imprime si ningun slot da 64 KB de
;   RAM, en el formato que espera la rutina 0x6678 de la ROM del BASIC
;   0xb4f2..0xb518  (38 bytes)
DATA_mensaje_sin_64k:
	defb 056h,06fh,075h,073h,020h,061h,076h,065h,07ah,020h,06dh,06fh,069h,06eh,073h,020h,064h,065h,020h,036h	; b4f2  Vous avez moins de 6
	defb 034h,04bh,06fh,020h,064h,065h,020h,052h,061h,06dh,021h,02eh,021h,02eh,02eh,000h,000h,000h	; b506  4Ko de Ram!.!.....

; ======================================================================
; CODIGO 0xb518..0xb532  (26 bytes)
; ======================================================================


sin_64k:		; No hay 64 KB: aviso y de vuelta al BASIC
	ld a,(0fd96h)		;b518   ; Deja los slots como estaban antes de tocar nada
	out (0a8h),a		;b51b
	ld a,(0fd97h)		;b51d
	ld (0ffffh),a		;b520
	call 000d2h		;b523   ; BIOS TOTEXT - Forces the screen to be in the text mode | Vuelve al modo texto
	ld hl,0b4f2h		;b526   ; El mensaje
	call 06678h		;b529   ; Rutina de la ROM del BASIC que lo imprime
	call 000c0h		;b52c   ; BIOS BEEP - Generates beep
	jp 0411dh		;b52f   ; Vuelta al BASIC. Se acabo
