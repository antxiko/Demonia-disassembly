; ==========================================================================
; DEMONIA - MSX - el cargador de los siete trozos
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08180


; ----------------------------------------------------------------------
; DATOS tabla_de_trozos: Los siete trozos que hay que leer de la cinta: carga,
;   fin y ejecucion, mas dos bytes a 0xFFFF. El bucle de 0x8208 la recorre
;   hasta 0x81B8, que es donde se para (0x8236)
;   0x8180..0x81b8  (56 bytes)

; ----------------------------------------------------------------------
; ====================================================================
; EL CARGADOR DE LOS SIETE TROZOS
; ====================================================================
; Esto es lo unico que el BASIC carga por su cuenta: el cargador de la
; cinta hace BLOAD"CAS:DEMON",R y este bloque de 249 bytes entra en
; 0x8180 y arranca en 0x8200. Lo que hace es leer, uno detras de otro,
; los SIETE bloques sin cabecera que vienen despues en la cinta, y
; ejecutar cada uno nada mas leerlo.
;
; Cuando termina, RETORNA al BASIC. La linea 50 del cargador acaba en
; ":RUN", asi que el BASIC vuelve a empezar y hace otro
; BLOAD"CAS:DEMON",R. Pero la cinta ya esta pasada por delante de estos
; siete bloques, asi que esta segunda vez encuentra el OTRO fichero
; llamado DEMON, el de 24 KB, que es el juego.
; ----------------------------------------------------------------------
DATA_tabla_de_trozos:
	defw 0a000h,0a618h,0a600h,0ffffh	; 8180
	defw 0ad00h,0c07fh,0c050h,0ffffh	; 8188
	defw 0a000h,0b531h,0b468h,0ffffh	; 8190
	defw 0a000h,0bf57h,0bf32h,0ffffh	; 8198
	defw 0a000h,0bbbbh,0bb96h,0ffffh	; 81a0
	defw 0afd0h,0bfffh,0afe0h,0ffffh	; 81a8
	defw 09000h,0971fh,096f8h,0ffffh	; 81b0

; ----------------------------------------------------------------------
; DATOS relleno_ff: Sesenta y cuatro bytes a 0xFF entre la tabla y las dos
;   variables. Nadie los toca
;   0x81b8..0x81f8  (64 bytes)
DATA_81B8:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 81b8  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 81c8  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 81d8  ................
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; 81e8  ................

; ----------------------------------------------------------------------
; DATOS variables_del_cargador: 0x81F8 = puntero a la entrada que se esta
;   leyendo; 0x81FA = direccion de ejecucion del trozo. Los valores que trae
;   la cinta (0x8188 y 0xC050) dan igual porque el codigo escribe los dos
;   antes de leerlos, en 0x8203 y en 0x8225; son consistentes con una foto de
;   la memoria tomada mientras corria el trozo 2
;   0x81f8..0x81fc  (4 bytes)
DATA_variables_del_cargador:
	defw 08188h	; 81f8
	defw 0c050h	; 81fa

; ----------------------------------------------------------------------
; DATOS relleno_ff: Cuatro bytes a 0xFF hasta el punto de arranque
;   0x81fc..0x8200  (4 bytes)
DATA_81FC:
	defb 0ffh,0ffh,0ffh,0ffh	; 81fc

; ======================================================================
; CODIGO 0x8200..0x8259  (89 bytes)
; ======================================================================


arranca:		; Punto de arranque que declara la cabecera BIN de la cinta
	ld hl,08180h		;8200   ; Al principio de la tabla: 0x8180
	ld (081f8h),hl		;8203   ; Puntero de la entrada en curso
	jr lee_un_trozo		;8206   ; Un salto a la instruccion de al lado; no hace nada, pero deja sitio para parchear
lee_un_trozo:		; Lee y ejecuta el trozo al que apunta 0x81F8
	ld ix,(081f8h)		;8208   ; IX = la entrada de la tabla
	ld l,(ix+000h)		;820c   ; HL = direccion de carga (bytes 0 y 1)
	ld h,(ix+001h)		;820f
	ld e,(ix+002h)		;8212   ; DE = direccion final, inclusive (bytes 2 y 3)
	ld d,(ix+003h)		;8215
	sub a			;8218   ; Pone el acarreo a cero para el SBC de abajo
	ex de,hl			;8219   ; HL = fin, DE = carga
	sbc hl,de		;821a   ; HL = fin - carga
	inc hl			;821c   ; ...+1, que es la longitud
	push hl			;821d   ; BC = longitud, via la pila porque no hay LD BC,HL
	pop bc			;821e
	ld l,(ix+004h)		;821f   ; HL = direccion de ejecucion (bytes 4 y 5)
	ld h,(ix+005h)		;8222
	ld (081fah),hl		;8225   ; Guardada para el salto de despues de leer
	ex de,hl			;8228   ; HL = destino de la lectura
	call lee_y_ejecuta		;8229   ; Lee BC bytes en (HL) y salta a la direccion de ejecucion
	ld hl,(081f8h)		;822c   ; Avanza a la entrada siguiente
	ld de,00008h		;822f   ; Ocho bytes por entrada
	add hl,de			;8232
	ld (081f8h),hl		;8233
	ld de,081b8h		;8236   ; Fin de la tabla
	rst 20h			;8239   ; RST 20h = DCOMPR de la BIOS: compara HL con DE
	ret nc			;823a   ; Si HL >= 0x81B8 ya no quedan trozos: vuelve al BASIC
	ret nc			;823b   ; Este RET NC nunca se ejecuta: el de arriba ya ha vuelto
	ret nc			;823c   ; Y este tampoco. Tres RET NC seguidos donde bastaba uno
	jp lee_un_trozo		;823d   ; Otra vuelta
lee_y_ejecuta:		; Lee BC bytes de la cinta en (HL) y llama a la direccion de 0x81FA
	call 072e9h		;8240   ; Rutina INTERNA de la ROM del BASIC: TAPION con control de error. Espera la cabecera del bloque
lee_un_byte:
	call 072d4h		;8243   ; Rutina INTERNA de la ROM: TAPIN con control de error. Devuelve el byte en A
	ld (hl),a			;8246   ; Lo guarda
	inc hl			;8247
	dec bc			;8248   ; Uno menos
	ld a,b			;8249
	or c			;824a
	jp nz,lee_un_byte		;824b   ; Hasta agotar la cuenta
	call 000e7h		;824e   ; BIOS TAPIOF - Stops reading from the tape | Para el motor de la cinta
	ld ix,(081fah)		;8251   ; IX = direccion de ejecucion del trozo recien leido
	call 0f398h		;8255   ; 0xF398 son los dos bytes JP (IX) del final de CLPRIM, en el area de la BIOS en RAM: es un "llama a lo que apunte IX" de dos bytes
	ret			;8258   ; Y a por el trozo siguiente

; ----------------------------------------------------------------------
; DATOS relleno_cero: Treinta y dos ceros de cola. El fichero se grabo hasta
;   0x8278 y aqui ya no hay nada
;   0x8259..0x8279  (32 bytes)
DATA_relleno_cero:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8259  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; 8269  ................
