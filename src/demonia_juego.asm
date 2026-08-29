; ==========================================================================
; DEMONIA - MSX - el juego
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; Etiquetas que no caen en ninguna posicion emitida del listado
; (destinos fuera del binario o dentro de una instruccion).
; ----------------------------------------------------------------------
L_8BC0:	equ 0x08bc0
L_BC8A:	equ 0x0bc8a
L_C403:	equ 0x0c403

; ----------------------------------------------------------------------
; DATOS variables: Los 256 bytes de trabajo del juego. Comparando la cinta con
;   la RAM del emulador con el juego en marcha, 83 de estos bytes ya han
;   cambiado nada mas arrancar y ninguno de los 24320 restantes lo hace: aqui
;   viven TODAS las variables del bloque, salvo 0x8C5E
;   0x8000..0x8100  (256 bytes)

; ----------------------------------------------------------------------
; ======================================================================
; DEMONIA / L'INTRUSION - el bloque del juego
; ======================================================================
; Veinticuatro kilobytes que la cinta carga en 0x8000 y arranca en
; 0x8100. Es el ultimo fichero de la cinta y el unico que se ejecuta
; donde se carga.
;
; EL MAPA DE MEMORIA CON EL QUE TRABAJA. Los siete trozos anteriores han
; dejado 26 KB debajo de la ROM del BASIC:
; 0x0000-0x1F31  242 sprites de 16x16 (banco 1)
; 0x1F32-0x3AC7  214 sprites de 16x16 (banco 2)
; 0x4000-0x5467  26 mapas de pantalla comprimidos
; 0x5480-....    donde se descomprime el mapa en curso
; 0x6000-0x6FFF  patrones y colores de SCREEN 2
; 0x7900-0x7FE7  la musica
; Nada de eso se ve mientras la ROM esta puesta. Hay dos rutinas para
; conmutar y la diferencia entre ellas es la clave de todo el bloque:
; 0x8126  pone en RAM SOLO la pagina 1 (0x4000-0x7FFF) y deja la
; pagina 0 con la ROM, asi que la BIOS sigue estando.
; 0x8139  pone en RAM las paginas 0 y 1. Ahi no hay BIOS: cualquier
; CALL a una direccion baja seria un salto a un dibujo. Por
; eso todos los usos de 0x8139 son un LDIR corto y vuelta.
;
; EL VECTOR DE SONIDO. El juego se apropia de los cinco bytes del gancho
; H.KEYI (0xFD9A): 0x83D6 escribe alli un JP 0x838D y 0x8492 escribe un
; RET para apagarlo. Los mas de cuarenta CALL 0xFD9A repartidos por el
; codigo son llamadas a ese vector.
;
; EL POLIZON. Dentro de este bloque, de 0xC000 en adelante, viaja un
; MONITOR DE CODIGO MAQUINA entero: "MONITEUR MSX / Copyright (C) 1984
; LORICIELS / Auteur: Claude SABLATOU" (los textos, en 0xD948-0xD988).
; El mismo Claude Sablatou firma la portada del juego. Su punto de
; entrada, 0xC924, se sigue llamando desde 0x9C72; pero sus ordenes ya
; no funcionan, porque los datos del juego se han escrito encima de la
; tabla que las reconoce. Esta contado en docs/LO-QUE-SOBRA.md.
;
; --- las variables ---
; Lo que se ha podido atar a una variable concreta:
; 0x8049  palabra, la escribe 0x82F8
; 0x804B  contador del efecto de sonido (0x838D)
; 0x804C  cuenta atras del parpadeo del canal A (0x83AF/0x83C3)
; 0x804D  interruptor de ese parpadeo, y guardia del vector de 0x804E
; 0x804E  vector de rutina: lo carga 0x85CD y lo salta 0x85D8
; 0x804F  cuenta atras del cambio de tono del efecto
; 0x806C  contador que apaga la musica al llegar a 0x69 (0x7F90)
; 0x80C0  puntero del guion que esta interpretando 0xAA0D
; 0x80FB  cuenta atras del paso de la melodia, se recarga a 14
; 0x80FC  puntero de la melodia; arranca en 0x7900 y rebobina a 0x79C8
; ----------------------------------------------------------------------
DATA_variables:
	defb 0c3h,01dh,041h,004h,002h,002h,002h,002h,002h,006h,00ch,008h,014h,030h,010h,008h	; 8000  ..A..........0..
	defb 0c0h,0c0h,0d0h,020h,030h,030h,018h,008h,030h,020h,040h,060h,010h,000h,000h,000h	; 8010  ... 00..0 @`....
	defb 006h,00fh,00fh,007h,007h,003h,003h,003h,003h,003h,007h,00eh,00ch,01ch,038h,018h	; 8020  ..............8.
	defb 00eh,0c0h,0c0h,0c0h,090h,098h,0b8h,09ch,08ch,0b8h,020h,040h,060h,010h,000h,000h	; 8030  .......... @`...
	defb 000h,009h,000h,010h,072h,002h,009h,048h,006h,00fh,078h,0c2h,001h,000h,000h,000h	; 8040  ....r..H..x.....
	defb 000h,000h,0f5h,078h,0feh,019h,0e1h,019h,08ah,001h,000h,003h,001h,006h,001h,007h	; 8050  ...x............
	defb 030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,030h,0f0h,05dh,018h,068h	; 8060  000000000000.].h
	defb 068h,001h,002h,070h,00fh,001h,000h,070h,030h,09eh,005h,010h,010h,092h,002h,007h	; 8070  h..p...p0.......
	defb 01bh,0feh,002h,000h,000h,000h,000h,000h,028h,024h,074h,058h,090h,029h,012h,01eh	; 8080  ........($tX.)..
	defb 001h,002h,0a8h,056h,000h,088h,048h,030h,020h,022h,064h,001h,001h,096h,000h,000h	; 8090  ...V..H0 "d.....
	defb 000h,004h,009h,006h,00ah,074h,018h,000h,001h,001h,023h,002h,001h,004h,002h,040h	; 80a0  .....t....#....@
	defb 078h,001h,005h,06ch,001h,000h,000h,000h,004h,001h,000h,000h,004h,000h,0f5h,019h	; 80b0  x..l............
	defb 017h,0e0h,000h,000h,000h,051h,09bh,028h,001h,0ffh,002h,014h,016h,02bh,01ah,0ffh	; 80c0  .....Q.(.....+..
	defb 0ffh,05bh,001h,000h,000h,020h,001h,015h,016h,06dh,019h,0ffh,0ffh,05bh,001h,000h	; 80d0  .[... ...m...[..
	defb 000h,020h,001h,00dh,00eh,0f5h,019h,0ffh,0ffh,05bh,001h,000h,000h,020h,001h,014h	; 80e0  . .......[... ..
	defb 016h,09dh,018h,0ffh,0ffh,05bh,001h,000h,000h,020h,0ffh,009h,018h,079h,000h,000h	; 80f0  .....[... ...y..

; ======================================================================
; CODIGO 0x8100..0x8148  (72 bytes)
; ======================================================================


arranca:		; Punto de arranque que declara la cabecera BIN de la cinta
	call preparativos		;8100   ; Preparativos
	jp bucle_principal		;8103   ; Y al bucle principal, que ya no vuelve
pon_pantalla:		; Fondo y borde negros y la tabla de nombres a cero
	ld hl,00000h		;8106   ; HL = 0
	ld (0f3eah),hl		;8109   ; BAKCLR y BDRCLR: negro
	ld (0f3dbh),hl		;810c   ; CLIKSW = 0 (sin clic de tecla) y CSRY = 0
	call L_84D0		;810f
	call L_8117		;8112
	jr L_8121		;8115
L_8117:
	sub a			;8117   ; A = 0, la baldosa vacia
	ld hl,01800h		;8118   ; La tabla de nombres de SCREEN 2
	ld bc,00300h		;811b   ; Las 24x32 casillas
	jp 00056h		;811e   ; BIOS FILVRM - Fills VRAM with value | FILVRM: rellena la VRAM con A
L_8121:
	call pagina1_a_ram		;8121
	jr $+44		;8124
pagina1_a_ram:		; Conmuta SOLO la pagina 1 a RAM; la 0 se queda con la ROM, asi que la BIOS sigue disponible
	di			;8126   ; Nada de interrupciones con los slots a medias
	ex af,af'			;8127   ; A' guarda el A del que llama: esta rutina no puede tocar registros
	ld a,(0fd98h)		;8128   ; El registro de primarios con la RAM, que dejo el trozo 3 de la carga
	and 0fch		;812b   ; AND 0xFC deja la pagina 0 en el slot 0, o sea con la ROM
	out (0a8h),a		;812d
	ld a,(0fd99h)		;812f   ; Y el de secundarios, tambien con la pagina 0 sin tocar
	and 0fch		;8132
	ld (0ffffh),a		;8134
	ex af,af'			;8137   ; Devuelve el A original
	ret			;8138
todo_a_ram:		; Conmuta las paginas 0 y 1 a RAM. Aqui NO hay BIOS: todo uso de esta rutina es un LDIR corto y vuelta a 0x8126
	di			;8139   ; Sin interrupciones: el vector de 0x0038 tampoco esta
	ex af,af'			;813a   ; Guarda el A del que llama
	ld a,(0fd98h)		;813b   ; El registro de primarios completo, con la pagina 0 tambien en RAM
	out (0a8h),a		;813e
	ld a,(0fd99h)		;8140   ; Y el de secundarios completo
	ld (0ffffh),a		;8143
	ex af,af'			;8146
	ret			;8147

; ----------------------------------------------------------------------
; DATOS conmutadora_muerta: Ocho bytes huerfanos: "di / jp 0xA0F0" y la cola
;   de una restauracion de slot. Ninguna instruccion salta aqui
;   0x8148..0x8150  (8 bytes)

; ----------------------------------------------------------------------
; Ocho bytes que no alcanza nadie. Leidos como codigo son "di / jp 0xA0F0"
; y, detras, "ld (0xFFFF),a / ret", que son las dos ultimas instrucciones
; de una restauracion de slot como la de 0x8139 y 0x8126. O sea el cadaver
; de una tercera conmutadora a la que alguien le metio un salto por medio.
; ----------------------------------------------------------------------
DATA_conmutadora_muerta:
	defb 0f3h,0c3h,0f0h,0a0h,032h,0ffh,0ffh,0c9h	; 8148  ....2...

; ======================================================================
; CODIGO 0x8150..0x817e  (46 bytes)
; ======================================================================


sube_los_decorados:		; Sube patrones y colores de SCREEN 2 desde la RAM escondida
	ld hl,06000h		;8150   ; Origen: los patrones, en 0x6000
	ld de,00000h		;8153   ; Destino: la tabla de patrones de la VRAM
	call sube_tres_tercios		;8156
	ld hl,06800h		;8159   ; Origen: los colores, en 0x6800
	ld de,02000h		;815c   ; Destino: la tabla de color de la VRAM
	call sube_tres_tercios		;815f
	jr toca_el_sonido		;8162
sube_tres_tercios:		; Sube tres veces 2048 bytes, o sea el mismo dibujo a los tres tercios
	ld b,003h		;8164   ; Tres tercios
L_8166:
	push bc			;8166
	nop			;8167
	push hl			;8168
	ld bc,00800h		;8169   ; 2048 bytes por tercio
	call 0005ch		;816c   ; BIOS LDIRVM - Block transfers to VRAM from memory | LDIRVM
	ld de,00800h		;816f   ; Siguiente tercio en la VRAM
	add hl,de			;8172
	ex de,hl			;8173
	pop hl			;8174
	nop			;8175
	pop bc			;8176
	djnz L_8166		;8177   ; Otra vuelta
	ret			;8179
toca_el_sonido:		; Tres bytes: llama al vector de 0xFD9A y vuelve
	call 0fd9ah		;817a   ; BIOS HOOKS - System hooks | El vector conmutable: la rutina de sonido, o un RET si esta apagada
	ret			;817d

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET seguidos que nadie llama, justo antes de la
;   tabla del cargador de cinta
;   0x817e..0x8180  (2 bytes)
DATA_817E:
	defb 0c9h,0c9h	; 817e

; ======================================================================
; CODIGO 0x8180..0x8191  (17 bytes)
; ======================================================================


L_8180:
	call L_8278		;8180
	ld hl,04000h		;8183
	ld a,001h		;8186
	call pinta_el_mapa		;8188
	jp L_8288		;818b
L_818E:
	jp cambia_de_pantalla		;818e

; ----------------------------------------------------------------------
; DATOS salto_corto_huerfano: Los dos bytes 0x18 0x0A, un "jr +10" al que no
;   llega nadie
;   0x8191..0x8193  (2 bytes)
DATA_salto_corto_huerfano:
	defb 018h,00ah	; 8191

; ======================================================================
; CODIGO 0x8193..0x8277  (228 bytes)
; ======================================================================


L_8193:
	cp 001h		;8193
	jr z,L_819A		;8195
	ld a,001h		;8197
	ret			;8199
L_819A:
	ld a,0ffh		;819a
	ret			;819c
descomprime:		; El descompresor de mapas: 0xFF <baldosa> <cuantas>, y literal cualquier otro byte
	ex af,af'			;819d   ; Guarda A
	ld de,05480h		;819e   ; Destino: el tampon de la RAM escondida
	exx			;81a1
	ld bc,00280h		;81a2   ; 640 baldosas, o sea 32 columnas por 20 filas
	exx			;81a5
lee_un_codigo:
	ld a,(hl)			;81a6   ; El byte del mapa
	inc hl			;81a7
	inc a			;81a8   ; INC A pone Z si el byte era 0xFF
	jr nz,L_81BE		;81a9   ; No es 0xFF: es una baldosa suelta
	ld c,(hl)			;81ab   ; C = la baldosa que se repite
	inc hl			;81ac
	ld b,(hl)			;81ad   ; B = cuantas veces
	inc hl			;81ae
L_81AF:
	ex de,hl			;81af
escribe_baldosa:
	ld (hl),c			;81b0   ; Escribe una
	inc hl			;81b1
	exx			;81b2   ; El contador de 640 va en el juego alternativo
	dec bc			;81b3
	ld a,b			;81b4
	or c			;81b5
	jr z,L_81C4		;81b6   ; Se acabaron las 640: corta aunque la carrera no haya terminado
	exx			;81b8
	djnz escribe_baldosa		;81b9   ; Sigue la carrera
	ex de,hl			;81bb
	jr lee_un_codigo		;81bc
L_81BE:
	dec a			;81be
	ld c,a			;81bf
	ld b,001h		;81c0
	jr L_81AF		;81c2
L_81C4:
	exx			;81c4
	ex af,af'			;81c5
	inc a			;81c6
	jp L_A190		;81c7
L_81CA:
	ld de,05480h		;81ca
	ld b,020h		;81cd

; ----------------------------------------------------------------------
;
; --- el desplazamiento de pantalla ---
; Las cuatro rutinas de aqui abajo son las dos mitades del mismo truco,
; una version para cada sentido. El MSX1 no desplaza la pantalla por
; hardware, asi que hay que mover las 20 filas de la tabla de nombres a
; mano. Como la VRAM no se puede leer y escribir a la vez sin pasar por
; la memoria, el juego usa un tampon en 0x5700, en la RAM escondida:
; primero baja la columna que se pierde, despues escribe las filas
; corridas y por ultimo sube la columna nueva.
; El paso de 0x21 -33- en vez de 0x20 es lo que produce el corrimiento
; de una casilla.
; ----------------------------------------------------------------------
desplaza_a_la_derecha:		; Prepara el desplazamiento: origen la VRAM, destino el tampon de 0x5700
	push bc			;81cf
	push de			;81d0
	ld hl,01880h		;81d1   ; Origen: la tabla de nombres de la VRAM
	ld de,05700h		;81d4   ; Destino: el tampon de la RAM escondida
	exx			;81d7   ; Veinte filas
	ld b,014h		;81d8
baja_una_columna:		; Se trae 0x21 bytes por fila de la VRAM al tampon
	exx			;81da
	ld bc,00021h		;81db   ; 33 bytes: la fila y una casilla mas
	call 00059h		;81de   ; BIOS LDIRMV - Block transfers to memory from VRAM | LDIRMV: de la VRAM a la memoria
	ld bc,00020h		;81e1   ; Siguiente fila en la VRAM
	add hl,bc			;81e4
	exx			;81e5
	djnz baja_una_columna		;81e6
	exx			;81e8
	ld hl,05720h		;81e9   ; El tampon de la RAM escondida
	pop de			;81ec
	push de			;81ed
	ld b,014h		;81ee   ; Veinte filas
corre_las_filas:		; Escribe cada fila una casilla mas alla que la anterior
	push bc			;81f0
	ld a,(de)			;81f1
	ld (hl),a			;81f2
	ld bc,00021h		;81f3   ; 33: una casilla mas que la fila, y de ahi el corrimiento
	add hl,bc			;81f6
	ex de,hl			;81f7
	ld bc,00020h		;81f8   ; 32: la fila justa
	add hl,bc			;81fb
	ex de,hl			;81fc
	pop bc			;81fd
	djnz corre_las_filas		;81fe
	ld hl,05701h		;8200   ; El tampon
	ld de,01880h		;8203   ; La tabla de nombres de la VRAM
	ld b,014h		;8206   ; Veinte filas
sube_filas_hacia_abajo:		; Sube B filas de 32 casillas a la VRAM, avanzando
	push bc			;8208
	ld bc,00020h		;8209   ; 32 casillas, una fila entera
	push bc			;820c
	call 0005ch		;820d   ; BIOS LDIRVM - Block transfers to VRAM from memory | LDIRVM
	pop bc			;8210
	add hl,bc			;8211   ; Origen: la fila siguiente
	inc de			;8212   ; Destino: una casilla mas alla
	ex de,hl			;8213
	pop bc			;8214
	djnz sube_filas_hacia_abajo		;8215   ; Siguiente fila
	call L_9128		;8217   ; Retoque de la columna
	pop de			;821a
	inc de			;821b
	pop bc			;821c
	djnz desplaza_a_la_derecha		;821d   ; Y la siguiente pasada
	ret			;821f
L_8220:
	ld de,0549fh		;8220
	ld b,020h		;8223
desplaza_a_la_izquierda:		; Igual pero con el tampon corrido una casilla
	push bc			;8225
	push de			;8226
	ld hl,01880h		;8227   ; Origen: la tabla de nombres de la VRAM
	ld de,05701h		;822a   ; Destino: el tampon, una casilla mas alla
	exx			;822d   ; Veinte filas
	ld b,014h		;822e
baja_una_columna_2:		; Igual que 0x81DA pero para el otro sentido
	exx			;8230
	ld bc,00020h		;8231   ; 32 bytes: la fila justa
	call 00059h		;8234   ; BIOS LDIRMV - Block transfers to memory from VRAM | LDIRMV
	ld bc,00020h		;8237
	add hl,bc			;823a
	inc de			;823b   ; Y una casilla mas en el destino
	exx			;823c
	djnz baja_una_columna_2		;823d
	exx			;823f
	ld hl,05700h		;8240   ; El tampon
	pop de			;8243
	push de			;8244
	ld b,014h		;8245   ; Veinte filas
corre_las_filas_2:		; La mitad simetrica de 0x81F0
	push bc			;8247
	ld a,(de)			;8248
	ld (hl),a			;8249
	ld bc,00021h		;824a   ; 33: el corrimiento
	add hl,bc			;824d
	ex de,hl			;824e
	ld bc,00020h		;824f   ; 32: la fila justa
	add hl,bc			;8252
	ex de,hl			;8253
	pop bc			;8254
	djnz corre_las_filas_2		;8255
	ld hl,05700h		;8257   ; El tampon
	ld de,01880h		;825a   ; La tabla de nombres de la VRAM
	ld b,014h		;825d   ; Veinte filas
sube_filas_hacia_arriba:		; Igual que 0x8208 pero el destino va hacia atras
	push bc			;825f
	ld bc,00020h		;8260   ; 32 casillas, una fila entera
	push bc			;8263
	call 0005ch		;8264   ; BIOS LDIRVM - Block transfers to VRAM from memory | LDIRVM
	pop bc			;8267
	add hl,bc			;8268   ; Origen: la fila siguiente
	inc de			;8269
	ex de,hl			;826a   ; Destino
	pop bc			;826b
	djnz sube_filas_hacia_arriba		;826c   ; Siguiente fila
	call L_9118		;826e
	pop de			;8271
	dec de			;8272   ; Aqui el destino RETROCEDE: es la diferencia con 0x8208
	pop bc			;8273
	djnz desplaza_a_la_izquierda		;8274   ; Y la siguiente pasada
	ret			;8276

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8277..0x8278  (1 bytes)
DATA_8277:
	defb 0c9h	; 8277

; ======================================================================
; CODIGO 0x8278..0x8287  (15 bytes)
; ======================================================================


L_8278:
	call 00069h		;8278   ; BIOS CLRSPR - Initialises all sprites
	ld hl,01860h		;827b
	ld a,02ah		;827e
	ld bc,00020h		;8280
	call 00056h		;8283   ; BIOS FILVRM - Fills VRAM with value
	ret			;8286

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8287..0x8288  (1 bytes)
DATA_8287:
	defb 000h	; 8287

; ======================================================================
; CODIGO 0x8288..0x8337  (175 bytes)
; ======================================================================


L_8288:
	ld bc,0a601h		;8288
	ld a,010h		;828b
	call pinta_un_sprite		;828d
	jr L_82F2		;8290
pinta_un_sprite:		; Sube al VDP el sprite numero B del banco C y su color
	push bc			;8292   ; Esta rutina no ensucia nada de quien la llama
	push de			;8293
	push hl			;8294
	push af			;8295
	exx			;8296
	call 00084h		;8297   ; BIOS CALPAT - Returns the address of the sprite pattern table | CALPAT: donde vive el patron del sprite numero A
	push hl			;829a
	exx			;829b
	ld hl,00000h		;829c   ; Banco 1: los sprites empiezan en 0x0000
	dec c			;829f   ; El selector viene en C
	jr z,L_82A5		;82a0
	ld hl,01f32h		;82a2   ; Cualquier otro banco: empiezan en 0x1F32
L_82A5:
	dec b			;82a5   ; Si B es cero no hay que avanzar nada
	inc b			;82a6
	jr z,L_82AF		;82a7
	ld de,00021h		;82a9   ; 33 bytes por registro: 32 de patron y 1 de color
L_82AC:
	add hl,de			;82ac   ; Avanza B registros
	djnz L_82AC		;82ad
L_82AF:
	ld bc,00042h		;82af   ; Se leen DOS registros de golpe: el juego usa los sprites de dos en dos
	ld de,08000h		;82b2   ; Tampon en la RAM que siempre esta visible
	call todo_a_ram		;82b5   ; Conmuta las dos paginas: aqui ya no hay BIOS
	ldir		;82b8   ; Los 66 bytes al tampon
	call pagina1_a_ram		;82ba   ; Y vuelta a tener BIOS antes de llamar a nada
	ld hl,08000h		;82bd   ; Ahora si, desde el tampon
	pop de			;82c0
	ld bc,00020h		;82c1   ; Los 32 bytes del primer patron
	call 0005ch		;82c4   ; BIOS LDIRVM - Block transfers to VRAM from memory | LDIRVM al sitio que dijo CALPAT
	ld bc,00020h		;82c7   ; El segundo patron va 32 bytes mas alla
	add hl,bc			;82ca
	ld a,(de)			;82cb   ; El byte 33 del primer registro es su color
	ex de,hl			;82cc
	ex af,af'			;82cd
	inc hl			;82ce
	call 0005ch		;82cf   ; BIOS LDIRVM - Block transfers to VRAM from memory | El segundo patron
	ld a,(de)			;82d2   ; El byte 33 del segundo registro
	ex af,af'			;82d3
	ld b,a			;82d4
	pop af			;82d5
	push af			;82d6
	call 00087h		;82d7   ; BIOS CALATR - Returns the address of the sprite attribute table | CALATR: donde vive el atributo del sprite numero A
	inc hl			;82da   ; El color esta en el cuarto byte del atributo
	inc hl			;82db
	inc hl			;82dc
	ld a,b			;82dd
	call 0004dh		;82de   ; BIOS WRTVRM - Writes data in VRAM | Escribe el color del primer plano
	inc hl			;82e1   ; Cuatro bytes mas alla: el atributo del sprite siguiente
	inc hl			;82e2
	inc hl			;82e3
	inc hl			;82e4
	ex af,af'			;82e5
	call 0004dh		;82e6   ; BIOS WRTVRM - Writes data in VRAM | Y el color del segundo plano
	pop af			;82e9
	pop hl			;82ea
	pop de			;82eb
	pop bc			;82ec
	inc b			;82ed   ; Deja B y A apuntando al par siguiente
	inc b			;82ee
	inc a			;82ef
	inc a			;82f0
	ret			;82f1
L_82F2:
	call pinta_un_sprite		;82f2
	ld hl,08820h		;82f5
	ld (08049h),hl		;82f8
	call L_9DC0		;82fb
	jr $+58		;82fe
pinta_al_jugador:		; Sube los dos planos del sprite del jugador, el segundo diez pixeles mas abajo
	call baja_cuatro_si_toca		;8300
	ld a,010h		;8303   ; Numero de sprite en el VDP
	call L_8310		;8305
	ex af,af'			;8308
	ld a,010h		;8309   ; Diez pixeles de separacion entre los dos planos
	add a,h			;830b
	ld h,a			;830c
	ex af,af'			;830d
	nop			;830e   ; Dos NOP
	nop			;830f
L_8310:
	push hl			;8310
	call 00087h		;8311   ; BIOS CALATR - Returns the address of the sprite attribute table
	pop de			;8314
	ex af,af'			;8315
	ld a,d			;8316
	call 0004dh		;8317   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;831a
	ld a,e			;831b
	call 0004dh		;831c   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;831f
	inc hl			;8320
	inc hl			;8321
	ld a,d			;8322
	call 0004dh		;8323   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8326
	ld a,e			;8327
	call 0004dh		;8328   ; BIOS WRTVRM - Writes data in VRAM
	ex de,hl			;832b
	ex af,af'			;832c
	inc a			;832d
	inc a			;832e
	ret			;832f
pon_un_sprite:		; Coloca el sprite que dice DE
	ex af,af'			;8330
	ld a,d			;8331
	call 00093h		;8332   ; BIOS WRTPSG - Writes data to PSG-register
	ex af,af'			;8335
	ret			;8336

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8337..0x8338  (1 bytes)
DATA_8337:
	defb 000h	; 8337

; ======================================================================
; CODIGO 0x8338..0x83ee  (182 bytes)
; ======================================================================


pon_los_sprites_del_marcador:		; Once llamadas seguidas a 0x8330 con parejas fijas, y despues arma el sonido
	ld de,00300h		;8338   ; Cada DE es una pareja (numero de sprite, dato)
	call pon_un_sprite		;833b
	ld de,00200h		;833e
	call pon_un_sprite		;8341
	ld de,00100h		;8344
	call pon_un_sprite		;8347
	ld de,00020h		;834a
	call pon_un_sprite		;834d
	ld de,00906h		;8350
	call pon_un_sprite		;8353
	ld de,00800h		;8356
	call pon_un_sprite		;8359
	ld de,007ach		;835c
	call pon_un_sprite		;835f
	ld de,0060ch		;8362
	call pon_un_sprite		;8365
	ld de,00d08h		;8368
	call pon_un_sprite		;836b
	ld de,00c00h		;836e
	call pon_un_sprite		;8371
	ld de,00bffh		;8374
	call pon_un_sprite		;8377
	ld hl,0804bh		;837a   ; El bloque de cinco variables del efecto de sonido
	ld (hl),050h		;837d   ; 0x804B, el tono de partida
	inc hl			;837f
	ld (hl),001h		;8380   ; 0x804C, la cuenta atras del parpadeo
	inc hl			;8382
	ld (hl),000h		;8383   ; 0x804D, el interruptor del parpadeo
	inc hl			;8385
	ld (hl),001h		;8386   ; 0x804E, parte baja del vector de rutina
	inc hl			;8388
	ld (hl),001h		;8389   ; 0x804F, la cuenta atras del cambio de tono
	jr enciende_el_sonido		;838b   ; Y a instalar la rutina de sonido en 0xFD9A
suena_el_efecto:		; La rutina de sonido que 0x83D6 instala como JP en el gancho 0xFD9A
	ld hl,0804fh		;838d   ; Cuenta atras del cambio de tono
	dec (hl)			;8390
	ret nz			;8391   ; Todavia no toca
	ld (hl),003h		;8392   ; Se recarga a 3
	ld a,(0804bh)		;8394   ; El tono en curso
	ld e,a			;8397
	ld a,002h		;8398   ; Registro 2 del PSG: tono fino del canal B
	call 00093h		;839a   ; BIOS WRTPSG - Writes data to PSG-register
	ld hl,0804eh		;839d   ; Cuenta atras del barrido de tono
	dec (hl)			;83a0
	jr nz,L_83A9		;83a1   ; Todavia no
	ld (hl),008h		;83a3   ; Se recarga a 8
	ld hl,0804bh		;83a5   ; Y sube el tono un punto
	inc (hl)			;83a8
L_83A9:
	ld a,(0804dh)		;83a9   ; Interruptor del parpadeo del canal A
	or a			;83ac
	jr nz,L_83C3		;83ad   ; Si esta encendido, toca apagarlo
	ld hl,0804ch		;83af   ; Cuenta atras del parpadeo
	dec (hl)			;83b2
	ret nz			;83b3   ; Todavia no
	ld (hl),004h		;83b4   ; Se recarga a 4
	ld a,001h		;83b6
	ld (0804dh),a		;83b8   ; Enciende
	ld a,008h		;83bb   ; Registro 8 del PSG: volumen del canal A
	ld e,010h		;83bd   ; A 16, o sea con envolvente
	call 00093h		;83bf   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;83c2
L_83C3:
	ld hl,0804ch		;83c3
	dec (hl)			;83c6
	ret nz			;83c7
	ld (hl),004h		;83c8   ; Se recarga a 4
	sub a			;83ca   ; Apaga
	ld (0804dh),a		;83cb
	ld a,008h		;83ce   ; Registro 8 otra vez
	ld e,000h		;83d0   ; Volumen cero
	call 00093h		;83d2   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;83d5
enciende_el_sonido:		; Escribe JP 0x838D en el gancho H.KEYI (0xFD9A), que el juego usa de vector conmutable
	ld hl,suena_el_efecto		;83d6   ; La rutina de sonido
	ld (0fd9bh),hl		;83d9   ; Los dos bytes de direccion del JP
	ld a,0c3h		;83dc   ; El opcode del JP
	ld (0fd9ah),a		;83de   ; Y ya esta armado: los CALL 0xFD9A del resto del codigo iran a 0x838D
	ld a,0aah		;83e1
	ld (08050h),a		;83e3
	ld bc,04000h		;83e6   ; Una espera larga
	call espera		;83e9
	jr $+12		;83ec

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x83ee..0x83f0  (2 bytes)
DATA_83EE:
	defb 000h,000h	; 83ee

; ======================================================================
; CODIGO 0x83f0..0x8471  (129 bytes)
; ======================================================================


espera:		; Cuenta atras de BC llamando de paso al vector de sonido
	ex af,af'			;83f0
cuenta_atras:		; El cuerpo del bucle de espera: descuenta BC hasta cero
	dec bc			;83f1   ; Uno menos
	ld a,b			;83f2
	or c			;83f3
	jr nz,cuenta_atras		;83f4   ; Hasta agotar la cuenta
	ex af,af'			;83f6
	ret			;83f7
muestra_el_titulo:		; Pinta el sprite del titulo y espera
	ld bc,0d201h		;83f8   ; El sprite y el banco
	ld a,010h		;83fb   ; Numero de sprite en el VDP
	call pinta_un_sprite		;83fd   ; Los dos planos de color
	call pinta_un_sprite		;8400
	ld bc,03000h		;8403   ; Una espera larga
	call espera		;8406
	exx			;8409
	ld b,088h		;840a
	ld a,001h		;840c
	ld (08051h),a		;840e   ; Arranca la cuenta del dibujo
anima_la_espera:		; El bucle de la pantalla de espera: lee el mando, mueve el sprite y alterna su dibujo
	exx			;8411
	ld bc,00400h		;8412   ; Cuenta de la espera
	call espera		;8415   ; Espera contando y tocando el sonido
	call 000d5h		;8418   ; BIOS GTSTCK - Returns the joystick status | Lee el joystick / cursores
	ld hl,08049h		;841b   ; El contador de la animacion
	inc (hl)			;841e
	call pinta_al_jugador		;841f
	ld a,(08050h)		;8422   ; El sprite que toca ahora
	ld b,a			;8425
	ld c,001h		;8426   ; Banco 1 de sprites
	ld a,010h		;8428   ; Numero de sprite en el VDP
	call pinta_un_sprite		;842a   ; Los dos planos de color, uno detras de otro
	call pinta_un_sprite		;842d
	ld hl,08051h		;8430   ; Cuenta atras del cambio de dibujo
	dec (hl)			;8433
	jr nz,L_8442		;8434   ; Todavia no
	ld (hl),002h		;8436   ; Se recarga a 2
	ld a,b			;8438
	cp 0d2h		;8439   ; Al llegar al ultimo dibujo...
	jr nz,L_843F		;843b
	ld a,0aah		;843d   ; ...vuelve al primero
L_843F:
	ld (08050h),a		;843f
L_8442:
	exx			;8442
	djnz anima_la_espera		;8443
	ld hl,03a10h		;8445
L_8448:
	ld a,087h		;8448
	ld (08457h),a		;844a
L_844D:
	push hl			;844d
	ld b,004h		;844e
L_8450:
	push bc			;8450
	ld b,010h		;8451
L_8453:
	call 0004ah		;8453   ; BIOS RDVRM - Reads the content of VRAM
	res 7,a		;8456
	call 0004dh		;8458   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;845b
	djnz L_8453		;845c
	ld bc,00010h		;845e
	add hl,bc			;8461
	pop bc			;8462
	djnz L_8450		;8463
	ld a,(08457h)		;8465
	add a,008h		;8468
	cp 0c7h		;846a
	jr c,$+7		;846c
	jp mira_si_se_acabo		;846e

; ----------------------------------------------------------------------
; DATOS bucle_muerto: 0x18 0xFE, o sea jr $: un cuelgue que nadie alcanza
;   0x8471..0x8473  (2 bytes)
DATA_8471:
	defb 018h,0feh	; 8471

; ======================================================================
; CODIGO 0x8473..0x8487  (20 bytes)
; ======================================================================


avanza_y_espera:		; Guarda el dato, adelanta al jugador una posicion y espera
	ld (08457h),a		;8473   ; Se escribe ENCIMA de un operando de 0x8457
	ld hl,08049h		;8476   ; La posicion del jugador
	inc (hl)			;8479
	call pinta_al_jugador		;847a
	ld bc,00800h		;847d   ; Una espera corta
	call espera		;8480
	pop hl			;8483
	jp L_844D		;8484

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8487..0x8488  (1 bytes)
DATA_8487:
	defb 000h	; 8487

; ======================================================================
; CODIGO 0x8488..0x84ff  (119 bytes)
; ======================================================================


mira_si_se_acabo:		; Con L a cero, apaga el sonido; si no, vuelve a empezar
	pop hl			;8488
	ld a,l			;8489   ; El contador que trae la pila
	or a			;848a
	jr z,apaga_el_sonido		;848b   ; A cero: se acabo
	ld l,000h		;848d   ; Se reinicia
	jp L_8448		;848f
apaga_el_sonido:		; Escribe un RET en 0xFD9A: los CALL 0xFD9A dejan de hacer nada
	ld a,0c9h		;8492   ; El opcode de RET
	ld (0fd9ah),a		;8494   ; Encima del JP que puso 0x83D6
	jp monta_la_segunda_escena		;8497
suena_la_partitura:		; Cada cuatro pasos, saca la nota siguiente de la partitura de 0xFD95
	ld hl,0fd97h		;849a   ; Cuenta atras del paso
	dec (hl)			;849d
	ret nz			;849e   ; Todavia no
	ld (hl),004h		;849f   ; Se recarga a 4
	ld a,(0fd94h)		;84a1   ; El interruptor de la partitura
	or a			;84a4
	ret z			;84a5   ; Apagada: no suena nada
	ld hl,(0fd95h)		;84a6   ; El puntero de la partitura
	ld a,(hl)			;84a9
	inc hl			;84aa
	inc a			;84ab   ; 0xFF marca una cosa...
	jr z,apaga_la_partitura		;84ac
	inc a			;84ae   ; ...y 0xFE otra
	jr z,L_84C8		;84af
	dec a			;84b1   ; Ni una ni otra: es un numero de registro del PSG
	dec a			;84b2
	ld e,(hl)			;84b3   ; El valor que va en ese registro
	inc hl			;84b4
	call 00093h		;84b5   ; BIOS WRTPSG - Writes data to PSG-register | Y se escribe
L_84B8:
	ld (0fd95h),hl		;84b8
	ret			;84bb
apaga_la_partitura:		; Baja el interruptor y calla el canal C
	sub a			;84bc
	ld (0fd94h),a		;84bd   ; El interruptor de la partitura
	ld a,007h		;84c0   ; Registro 7 del PSG: el mezclador
	ld e,0bfh		;84c2   ; 0xBF cierra el canal C
	call L_9B00		;84c4
	ret			;84c7
L_84C8:
	ld a,004h		;84c8
	ld (0fd97h),a		;84ca
	jp L_84B8		;84cd
L_84D0:
	ld a,0f2h		;84d0
	ld (0f3e0h),a		;84d2
	jp 00072h		;84d5   ; BIOS INIGRP - Switches to SCREEN 2 (high resolution screen with 256*192 pixels)
L_84D8:
	ld (0fd95h),hl		;84d8
	ld a,001h		;84db
	ld (0fd94h),a		;84dd
	ld (0fd97h),a		;84e0
	ret			;84e3
monta_la_segunda_escena:		; Sube los graficos, pone al jugador y descomprime su mapa
	ld hl,0db00h		;84e4   ; La tabla de 0xDB00
	call L_84D8		;84e7
	call L_85B8		;84ea   ; Borra los sprites
	ld hl,08020h		;84ed   ; Posicion del jugador
	ld (08049h),hl		;84f0
	ld hl,0418ah		;84f3   ; El mapa de esta escena
	call pinta_el_mapa		;84f6
	ld bc,0aa01h		;84f9   ; El sprite y el banco
	jp pinta_la_escena		;84fc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x84ff..0x8500  (1 bytes)
DATA_84FF:
	defb 000h	; 84ff

; ======================================================================
; CODIGO 0x8500..0x859f  (159 bytes)
; ======================================================================


pinta_el_mapa:		; Descomprime el mapa de (HL) y lo sube a la pantalla
	ld de,05480h		;8500
	exx			;8503
	ld bc,00280h		;8504
	exx			;8507
lee_un_codigo_2:		; El otro descompresor, igual que el de 0x81A6
	ld a,(hl)			;8508   ; El byte del mapa
	inc hl			;8509
	inc a			;850a   ; INC A pone Z si el byte era 0xFF
	jr nz,L_8520		;850b   ; No es 0xFF: baldosa suelta
	ld c,(hl)			;850d   ; C = la baldosa que se repite
	inc hl			;850e
	ld b,(hl)			;850f   ; B = cuantas veces
	inc hl			;8510
L_8511:
	ex de,hl			;8511
escribe_carrera:		; El cuerpo del bucle del descompresor: escribe una baldosa y descuenta
	ld (hl),c			;8512   ; Una baldosa
	inc hl			;8513
	exx			;8514
	dec bc			;8515   ; La cuenta global de 640
	ld a,b			;8516
	or c			;8517
	jr z,L_8526		;8518   ; Se acabaron: corta la carrera a medias
	exx			;851a
	djnz escribe_carrera		;851b   ; Sigue la carrera
	ex de,hl			;851d
	jr lee_un_codigo_2		;851e
L_8520:
	dec a			;8520
	ld c,a			;8521
	ld b,001h		;8522
	jr L_8511		;8524
L_8526:
	ld hl,05480h		;8526
	ld de,01880h		;8529
	ld bc,00280h		;852c
	call 0005ch		;852f   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ret			;8532
pinta_la_escena:		; Pone al jugador, su sprite y la musica en marcha
	call pinta_al_jugador		;8533   ; Lo pinta
	ld a,010h		;8536   ; Numero de sprite
	call pinta_un_sprite		;8538
	call pinta_un_sprite		;853b
	call L_9B00		;853e   ; La musica
	sub a			;8541   ; Y la bandera de abandono a cero
	ld (0fd93h),a		;8542
	call L_85A0		;8545
bucle_de_la_presentacion:		; Espera, suena y cuenta hasta que toca cambiar de escena
	call L_85A8		;8548   ; Lo que haya que dibujar en este paso
	ld bc,00200h		;854b   ; Cuenta de la espera
	call espera		;854e   ; Espera
	call suena_la_partitura		;8551   ; Un paso de la partitura
	ld hl,08048h		;8554   ; Cuenta atras del paso de escena
	dec (hl)			;8557
	jp nz,bucle_de_la_presentacion		;8558   ; Todavia no
	ld (hl),002h		;855b   ; Se recarga a 2
	ld hl,08049h		;855d   ; El numero de escena
	inc (hl)			;8560
	ld a,(hl)			;8561
	cp 03eh		;8562   ; En la escena 0x3E se cambia de rutina...
	jp z,L_85C0		;8564
	cp 082h		;8567   ; ...en la 0x82, a otra...
	jp z,L_85C5		;8569
	cp 0e6h		;856c   ; ...y en la 0xE6 se acaba
	jp z,L_8668		;856e
paso_de_la_presentacion:		; Un paso: dibuja, mira el STOP y anima el sprite
	call pinta_al_jugador		;8571   ; Lo que toque dibujar
	ld a,(0fd93h)		;8574   ; Una bandera de la BIOS que el juego usa de aviso de abandono
	or a			;8577
	jp nz,L_DAD0		;8578   ; Si esta puesta, reinicia el juego
	ld hl,0804ch		;857b   ; Cuenta atras del cambio de dibujo
	dec (hl)			;857e
	jp nz,salta_al_vector		;857f   ; Todavia no: solo el vector de rutina
	ld (hl),003h		;8582   ; Se recarga a 3
	ld a,(0804bh)		;8584   ; El dibujo en curso
	ld b,a			;8587
	ld c,001h		;8588   ; Banco 1
	ld a,010h		;858a   ; Numero de sprite en el VDP
	call pinta_un_sprite		;858c   ; Los dos planos de color
	call pinta_un_sprite		;858f
	ld a,b			;8592
	cp 0d2h		;8593   ; Al llegar al ultimo...
	jr nz,L_8599		;8595
	ld a,0aah		;8597   ; ...vuelve al primero
L_8599:
	ld (0804bh),a		;8599
	jp salta_al_vector		;859c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x859f..0x85a0  (1 bytes)
DATA_859F:
	defb 000h	; 859f

; ======================================================================
; CODIGO 0x85a0..0x85a6  (6 bytes)
; ======================================================================


L_85A0:
	ld a,0aah		;85a0
	ld (0804bh),a		;85a2
	ret			;85a5

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET a los que no llega ningun salto
;   0x85a6..0x85a8  (2 bytes)
DATA_85A6:
	defb 0c9h,0c9h	; 85a6

; ======================================================================
; CODIGO 0x85a8..0x85b7  (15 bytes)
; ======================================================================


L_85A8:
	sub a			;85a8
	call 000d8h		;85a9   ; BIOS GTTRIG - Returns current trigger status
	call 0fd9ah		;85ac   ; BIOS HOOKS - System hooks
	inc a			;85af
	call 000d8h		;85b0   ; BIOS GTTRIG - Returns current trigger status
	call 0fd9ah		;85b3   ; BIOS HOOKS - System hooks
	ret			;85b6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x85b7..0x85b8  (1 bytes)
DATA_85B7:
	defb 000h	; 85b7

; ======================================================================
; CODIGO 0x85b8..0x85ca  (18 bytes)
; ======================================================================


L_85B8:
	call 00069h		;85b8   ; BIOS CLRSPR - Initialises all sprites
	sub a			;85bb
	ld (0804dh),a		;85bc
	ret			;85bf
L_85C0:
	ld hl,085e3h		;85c0
	jr $+10		;85c3
L_85C5:
	ld hl,08638h		;85c5
	jr $+5		;85c8

; ----------------------------------------------------------------------
; DATOS carga_vector_nulo: "ld hl,0x0000" y de ahi cae en 0x85CD, que guarda
;   el vector: es la tercera variante, la de "ninguna rutina". Nadie la llama
;   0x85ca..0x85cd  (3 bytes)
DATA_carga_vector_nulo:
	defb 021h,000h,000h	; 85ca

; ======================================================================
; CODIGO 0x85cd..0x8665  (152 bytes)
; ======================================================================


guarda_el_vector:		; Guarda HL en 0x804E y enciende el guardia de 0x804D
	ld (0804eh),hl		;85cd
	ld a,001h		;85d0
	ld (0804dh),a		;85d2
	jp paso_de_la_presentacion		;85d5
salta_al_vector:		; Salta a la rutina de 0x804E, si el guardia esta encendido
	ld a,(0804dh)		;85d8   ; El guardia
	or a			;85db
	jp z,bucle_de_la_presentacion		;85dc   ; Apagado: no hay rutina que llamar
	ld hl,(0804eh)		;85df   ; La rutina guardada
	jp (hl)			;85e2   ; Salto indirecto: los unicos valores posibles son 0x85E3 y 0x8638, que cargan 0x85C0 y 0x85C5
escena_uno:		; La primera escena: posicion, paso y estado 2 del parpadeo
	dec a			;85e3   ; Solo si el estado es 1
	jr nz,L_85F9		;85e4
	ld hl,019c3h		;85e6   ; La posicion de partida
	ld (08050h),hl		;85e9
	ld a,005h		;85ec   ; Y el paso
	ld (08052h),a		;85ee
	ld a,002h		;85f1   ; Estado 2 del parpadeo
	ld (0804dh),a		;85f3
	jp L_8658		;85f6
L_85F9:
	ld hl,(08050h)		;85f9
	ld a,(08052h)		;85fc
	ld c,a			;85ff
	ld b,000h		;8600
	ld a,00ah		;8602
sube_y_baja_una_banda:		; Copia una banda de la VRAM a 0x8058 y la vuelve a escribir una fila mas abajo
	push af			;8604
	ld de,08058h		;8605   ; Tampon en la pagina de variables
	push bc			;8608
	call 00059h		;8609   ; BIOS LDIRMV - Block transfers to memory from VRAM | LDIRMV: de la VRAM a la memoria
	ld bc,00020h		;860c   ; Una fila
	add hl,bc			;860f
	ex de,hl			;8610
	ld hl,08058h		;8611
	pop bc			;8614
	push bc			;8615
	call 0005ch		;8616   ; BIOS LDIRVM - Block transfers to VRAM from memory | Y de vuelta a la VRAM, en la fila de al lado
	ld bc,0ffc0h		;8619   ; Sube dos filas: 0xFFC0 es -64
	add hl,bc			;861c
	pop bc			;861d
	pop af			;861e
	dec a			;861f   ; Una banda menos
	jr nz,sube_y_baja_una_banda		;8620
	ld bc,00160h		;8622
	add hl,bc			;8625
	ld de,01a63h		;8626   ; El limite de la zona de juego en la VRAM
	rst 20h			;8629   ; RST 20h = DCOMPR, compara HL con DE
	jr nc,L_8632		;862a
	ld (08050h),hl		;862c
L_862F:
	jp bucle_de_la_presentacion		;862f
L_8632:
	sub a			;8632
	ld (0804dh),a		;8633
	jr L_862F		;8636
escena_dos:		; Coloca la segunda escena de la presentacion y parchea dos operandos
	dec a			;8638   ; Solo si el estado es 1
	jp nz,L_85F9		;8639
	ld a,002h		;863c
	ld (0804dh),a		;863e   ; Pone el estado 2
	ld hl,019abh		;8641   ; La posicion de partida
	ld (08050h),hl		;8644
	ld a,007h		;8647
	ld (08052h),a		;8649   ; Y el paso
	ld a,00ah		;864c
	ld (08603h),a		;864e   ; Escribe ENCIMA de un operando de 0x8603: codigo que se modifica solo
	ld a,060h		;8651
	ld (08623h),a		;8653   ; Y de otro de 0x8623
	jr L_8662		;8656
L_8658:
	ld a,00bh		;8658
	ld (08603h),a		;865a
	ld a,080h		;865d
	ld (08623h),a		;865f
L_8662:
	jp bucle_de_la_presentacion		;8662

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8665..0x8668  (3 bytes)
DATA_8665:
	defb 000h,000h,000h	; 8665

; ======================================================================
; CODIGO 0x8668..0x8694  (44 bytes)
; ======================================================================


L_8668:
	ld hl,03a10h		;8668
L_866B:
	ld a,087h		;866b
	ld (0867ah),a		;866d
L_8670:
	push hl			;8670
	ld b,004h		;8671
L_8673:
	push bc			;8673
	ld b,010h		;8674
L_8676:
	call 0004ah		;8676   ; BIOS RDVRM - Reads the content of VRAM
	res 7,a		;8679
	call 0004dh		;867b   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;867e
	djnz L_8676		;867f
	ld bc,00010h		;8681
	add hl,bc			;8684
	pop bc			;8685
	djnz L_8673		;8686
	ld a,(0867ah)		;8688
	add a,008h		;868b
	cp 0c7h		;868d
	jr c,$+7		;868f
	jp mira_si_se_acabo_2		;8691

; ----------------------------------------------------------------------
; DATOS bucle_muerto: 0x18 0xFE, o sea jr $: un cuelgue que nadie alcanza
;   0x8694..0x8696  (2 bytes)
DATA_8694:
	defb 018h,0feh	; 8694

; ======================================================================
; CODIGO 0x8696..0x86aa  (20 bytes)
; ======================================================================


avanza_y_espera_2:		; El gemelo de 0x8473 con otra espera
	ld (0867ah),a		;8696   ; Se escribe ENCIMA de un operando de 0x867A
	ld hl,08049h		;8699   ; La posicion del jugador
	inc (hl)			;869c
	call pinta_al_jugador		;869d
	ld bc,00400h		;86a0   ; Una espera mas corta
	call espera		;86a3
	pop hl			;86a6
	jp L_8670		;86a7

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x86aa..0x86ab  (1 bytes)
DATA_86AA:
	defb 000h	; 86aa

; ======================================================================
; CODIGO 0x86ab..0x872a  (127 bytes)
; ======================================================================


mira_si_se_acabo_2:		; El gemelo de 0x8488
	pop hl			;86ab
	ld a,l			;86ac   ; El contador que trae la pila
	or a			;86ad
	jr z,L_86B5		;86ae   ; A cero: se acabo
	ld l,000h		;86b0   ; Se reinicia
	jp L_866B		;86b2
L_86B5:
	ld hl,01a1ch		;86b5
	sub a			;86b8
	exx			;86b9
	ld b,004h		;86ba
L_86BC:
	exx			;86bc
	ld bc,00002h		;86bd
	call 00056h		;86c0   ; BIOS FILVRM - Fills VRAM with value
	ld bc,00020h		;86c3
	add hl,bc			;86c6
	exx			;86c7
	djnz L_86BC		;86c8
	exx			;86ca
	ld hl,01a1eh		;86cb
	ld a,0d0h		;86ce
	call 0004dh		;86d0   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;86d3
	inc a			;86d4
	call 0004dh		;86d5   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;86d8
	call 0004dh		;86d9   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;86dc
	call 0004dh		;86dd   ; BIOS WRTVRM - Writes data in VRAM
	ld b,030h		;86e0
espera_y_arranca:		; Espera B pasos con musica y monta la pantalla del juego
	push bc			;86e2
	ld bc,00200h		;86e3   ; Cuenta de la espera
	call espera		;86e6
	call suena_la_partitura		;86e9   ; Un paso de la partitura
	pop bc			;86ec
	djnz espera_y_arranca		;86ed   ; Otra vuelta
	call L_A108		;86ef
	call L_88E4		;86f2
	call pinta_el_mapa		;86f5   ; Descomprime y sube el mapa
	call 00044h		;86f8   ; BIOS ENASCR - Displays the screen | ENASCR: enciende la pantalla
	ld sp,0e1ach		;86fb   ; Y la pila del juego
L_86FE:
	ld de,01803h		;86fe
	ld hl,0872ah		;8701
	ld bc,00006h		;8704
	call 0005ch		;8707   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld de,08060h		;870a
	ld hl,01809h		;870d
	call L_8738		;8710
	ld de,01811h		;8713
	ld hl,08730h		;8716
	ld bc,00007h		;8719
	call 0005ch		;871c   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld hl,01818h		;871f
	ld de,08066h		;8722
	call L_8738		;8725
	jr $+86		;8728

; ----------------------------------------------------------------------
; DATOS rotulos_del_marcador: Los dos rotulos del marcador, uno detras de otro
;   y sin terminador: "SCORE=" en 0x872A (lo carga 0x8701) y "RECORD=" en
;   0x8730 (lo carga 0x8716)
;   0x872a..0x8738  (14 bytes)
DATA_rotulos_del_marcador:
	defb 053h,043h,04fh,052h,045h,03dh	; 872a
	defb 052h,045h,043h,04fh,052h,044h,03dh	; 8730
	defb 000h	; 8737

; ======================================================================
; CODIGO 0x8738..0x8778  (64 bytes)
; ======================================================================


L_8738:
	ld b,006h		;8738
L_873A:
	ld a,(de)			;873a
	inc de			;873b
	call 0004dh		;873c   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;873f
	call sale_si_esta_congelado		;8740
	djnz L_873A		;8743
	ret			;8745
L_8746:
	push af			;8746
	push de			;8747
	push bc			;8748
	sub a			;8749
	ld e,050h		;874a
	call 00093h		;874c   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,a			;874f
	inc a			;8750
	call 00093h		;8751   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,0b8h		;8754
	ld a,007h		;8756
	call 00093h		;8758   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;875b
	ld e,00ah		;875c
	call 00093h		;875e   ; BIOS WRTPSG - Writes data to PSG-register
	ld bc,02000h		;8761
	call espera		;8764
	ld a,008h		;8767
	ld e,000h		;8769
	call 00093h		;876b   ; BIOS WRTPSG - Writes data to PSG-register
	ld bc,02000h		;876e
	call espera		;8771
	pop bc			;8774
	pop de			;8775
	pop af			;8776
	ret			;8777

; ----------------------------------------------------------------------
; DATOS rotulo_force: El rotulo "FORCE=", que carga 0x8781
;   0x8778..0x877e  (6 bytes)
DATA_rotulo_force:
	defb 046h,04fh,052h,043h,045h,03dh	; 8778

; ======================================================================
; CODIGO 0x877e..0x892f  (433 bytes)
; ======================================================================


L_877E:
	ld de,01842h		;877e
	ld hl,08778h		;8781
	ld bc,00006h		;8784
	call 0005ch		;8787   ; BIOS LDIRVM - Block transfers to VRAM from memory
L_878A:
	call L_9B00		;878a
	call 0fd9ah		;878d   ; BIOS HOOKS - System hooks
	ld a,040h		;8790
	ld (0806ch),a		;8792
	ld hl,01b03h		;8795
	ld a,001h		;8798
	call 0004dh		;879a   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,03808h		;879d
	ld bc,00008h		;87a0
	ld a,0ffh		;87a3
	call 00056h		;87a5   ; BIOS FILVRM - Fills VRAM with value
	ld b,0b2h		;87a8
L_87AA:
	call L_87D2		;87aa
	djnz L_87AA		;87ad
	jp L_8840		;87af
L_87B2:
	ld hl,01b00h		;87b2
	ld a,008h		;87b5
	call 0004dh		;87b7   ; BIOS WRTVRM - Writes data in VRAM
	ld a,(0806ch)		;87ba
	inc hl			;87bd
	call 0004dh		;87be   ; BIOS WRTVRM - Writes data in VRAM
	ret			;87c1
elige_el_digito:		; Segun donde caiga la casilla, un ':' o el caracter siguiente
	call casilla_del_marcador		;87c2   ; La casilla del marcador
	ld de,0184dh		;87c5   ; El limite
	rst 20h			;87c8   ; RST 20h = DCOMPR
	ld a,03ah		;87c9   ; Los dos puntos
	jr c,L_87CE		;87cb
	inc a			;87cd   ; Y si esta por encima, el de al lado
L_87CE:
	call 0004dh		;87ce   ; BIOS WRTVRM - Writes data in VRAM
	ret			;87d1
L_87D2:
	call elige_el_digito		;87d2
	call L_A779		;87d5
	cp 0f8h		;87d8
	jp z,L_A780		;87da
	push bc			;87dd
	call L_87EC		;87de
	pop bc			;87e1
	ret c			;87e2
	call 0fd9ah		;87e3   ; BIOS HOOKS - System hooks
	call 0fd9ah		;87e6   ; BIOS HOOKS - System hooks
	nop			;87e9
	nop			;87ea
	ret			;87eb
L_87EC:
	call mira_si_esta_congelado		;87ec
divide_entre_ocho:		; Tres rotaciones a la derecha, saliendo si hay resto
	scf			;87ef   ; SCF + CCF pone el acarreo a cero
	ccf			;87f0
	rrca			;87f1   ; Por dos
	ret c			;87f2   ; Con resto, se acabo
	rrca			;87f3
	ret c			;87f4
	rrca			;87f5
	ret			;87f6   ; Y la tercera
L_87F7:
	push af			;87f7
	neg		;87f8
	ld e,a			;87fa
	sub a			;87fb
	call 00093h		;87fc   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,010h		;87ff
	add a,e			;8801
	ld e,a			;8802
	ld a,002h		;8803
	call 00093h		;8805   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,010h		;8808
	add a,e			;880a
	ld e,a			;880b
	ld a,004h		;880c
	call 00093h		;880e   ; BIOS WRTPSG - Writes data to PSG-register
	sub a			;8811
	ld e,a			;8812
	inc a			;8813
	call 00093h		;8814   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;8817
	inc a			;8818
	call 00093h		;8819   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;881c
	inc a			;881d
	call 00093h		;881e   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,007h		;8821
	ld e,0b8h		;8823
	call 00093h		;8825   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;8828
	ld e,00ah		;8829
	call 00093h		;882b   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;882e
	dec e			;882f
	call 00093h		;8830   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;8833
	dec e			;8834
	call 00093h		;8835   ; BIOS WRTPSG - Writes data to PSG-register
	ld bc,00200h		;8838
	call espera		;883b
	pop af			;883e
	ret			;883f
L_8840:
	ld hl,03820h		;8840
	sub a			;8843
	ld bc,00080h		;8844
	call 00056h		;8847   ; BIOS FILVRM - Fills VRAM with value
	ld hl,00cf8h		;884a
	ld a,000h		;884d
	call L_8310		;884f
	call L_8310		;8852
	call 0fd9ah		;8855   ; BIOS HOOKS - System hooks
	call 0fd9ah		;8858   ; BIOS HOOKS - System hooks
	call L_9B00		;885b
	call arranca_la_partida		;885e
	jp L_9CE0		;8861
arranca_la_partida:		; Pone a su valor inicial las veintitantas variables de la partida
	ld a,001h		;8864
	ld (08048h),a		;8866   ; 0x8048: cuenta de paso
	ld hl,07880h		;8869   ; 0x8049 y 0x804A: la posicion del jugador, X y Y
	ld (08049h),hl		;886c
	ld (0804ch),a		;886f   ; 0x804C: cuenta atras del cambio de dibujo
	ld a,0aah		;8872
	ld (0804bh),a		;8874   ; 0x804B: el primer dibujo del jugador
	sub a			;8877
	ld (0804dh),a		;8878   ; 0x804D a 0x8050 a cero
	ld (0804eh),a		;887b
	ld (0804fh),a		;887e
	ld (08050h),a		;8881
	inc a			;8884
	ld (08051h),a		;8885   ; 0x8051 a uno
	sub a			;8888
	ld (08052h),a		;8889   ; 0x8052 y 0x8053 a cero
	ld (08053h),a		;888c
	ld hl,00000h		;888f
	ld (08054h),hl		;8892   ; 0x8054 y 0x8056, dos palabras a cero
	ld (08056h),hl		;8895
	ld (08058h),a		;8898   ; 0x8058 a cero
	ld a,006h		;889b
	ld (0805dh),a		;889d   ; 0x805D: el paso base, seis
	call 0fd9ah		;88a0   ; BIOS HOOKS - System hooks | Vector de sonido
	call pinta_al_jugador		;88a3
	ld bc,0a601h		;88a6   ; El sprite del jugador, banco 1
	ld a,010h		;88a9
	call pinta_un_sprite		;88ab   ; Sus dos planos de color
	call pinta_un_sprite		;88ae
	call 0fd9ah		;88b1   ; BIOS HOOKS - System hooks
	call 0fd9ah		;88b4   ; BIOS HOOKS - System hooks
	ret			;88b7
L_88B8:
	call un_paso_del_juego		;88b8
tanda_del_bucle_principal:		; Las seis rutinas que se ejecutan en cada vuelta
	call L_BF88		;88bb   ; El marcador
	call L_9510		;88be   ; Los que aparecen
	call L_A0E0		;88c1   ; El jugador
	call L_91E8		;88c4   ; Los objetos
	call L_C000		;88c7   ; La musica
	call L_88D0		;88ca   ; Y el teclado
	jp L_88B8		;88cd
L_88D0:
	call L_DD91		;88d0
	call 0fd9ah		;88d3   ; BIOS HOOKS - System hooks
mira_el_abandono:		; Con las interrupciones puestas, mira si se ha pulsado STOP
	ei			;88d6   ; Vuelven las interrupciones
	ld a,(0fc9bh)		;88d7   ; INTFLG, la bandera de STOP de la BIOS
	cp 003h		;88da   ; El valor 3 es CTRL+STOP
	jp z,L_DAD0		;88dc   ; Reinicia el juego
	or a			;88df   ; Y cualquier otro valor tiene su rutina
	call nz,L_94C8		;88e0
	ret			;88e3
L_88E4:
	call 00041h		;88e4   ; BIOS DISSCR - Inhibits the screen display
	ld bc,00000h		;88e7
	call espera		;88ea
	call espera		;88ed
	sub a			;88f0
	ld (0fc9bh),a		;88f1
	call lee_la_entrada		;88f4
	ret			;88f7
un_paso_del_juego:		; El paso de partida: mira los tres avisos y, si no hay ninguno, hace todo lo demas
	ld hl,08048h		;88f8   ; Cuenta atras del paso
	dec (hl)			;88fb
	ret nz			;88fc   ; Todavia no toca
	ld a,(0805dh)		;88fd   ; El paso base
	ld (hl),a			;8900
	call mira_si_esta_ocupado		;8901   ; Coge la ficha de la pantalla en curso
	ld a,(de)			;8904   ; Primer aviso de la ficha
	inc de			;8905
	or a			;8906
	jp nz,L_8CB0		;8907   ; Si no es cero, se atiende y se sale
	ld a,(de)			;890a   ; Segundo aviso
	inc de			;890b
	or a			;890c
	jp nz,L_9B1E		;890d
	ld a,(de)			;8910   ; Tercer aviso
	inc de			;8911
	or a			;8912
	jp nz,tanda_del_bicho		;8913
	call L_8DF3		;8916   ; Y si no hay ninguno, el paso completo:
	call L_9238		;8919   ; ...
	call L_8978		;891c   ; ...
	call L_8990		;891f   ; ...
	call L_8A80		;8922   ; ...
	call mira_el_suelo		;8925   ; ...
	call 0fd9ah		;8928   ; BIOS HOOKS - System hooks | Vector de sonido
	call mira_la_tecla_de_saltar		;892b
	ret			;892e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x892f..0x8930  (1 bytes)
DATA_892F:
	defb 0c9h	; 892f

; ======================================================================
; CODIGO 0x8930..0x8977  (71 bytes)
; ======================================================================


L_8930:
	ld hl,00000h		;8930
	ld (08059h),hl		;8933
	ld hl,(08049h)		;8936
L_8939:
	ld a,l			;8939
	scf			;893a
	ccf			;893b
	ld b,003h		;893c
L_893E:
	rra			;893e
	jr c,L_894D		;893f
	djnz L_893E		;8941
	ld b,003h		;8943
L_8945:
	ld a,h			;8945
L_8946:
	rra			;8946
	jr c,L_8956		;8947
	djnz L_8946		;8949
	jr L_895B		;894b
L_894D:
	ld a,001h		;894d
	ld (08059h),a		;894f
	scf			;8952
	ccf			;8953
	jr L_8945		;8954
L_8956:
	ld a,001h		;8956
	ld (0805ah),a		;8958
L_895B:
	call alinea_la_casilla		;895b
	nop			;895e
	add hl,hl			;895f
	add hl,hl			;8960
	ld b,003h		;8961
casilla_a_direccion_vram:		; Divide A entre 2 elevado a B y suma la tabla de nombres
	scf			;8963   ; SCF + CCF pone el acarreo a cero antes de rotar
	ccf			;8964
	rra			;8965   ; Divide por dos, B veces
	djnz casilla_a_direccion_vram		;8966
	ld e,a			;8968
	ld d,000h		;8969
	add hl,de			;896b
	ld de,01800h		;896c   ; La tabla de nombres de la VRAM
	add hl,de			;896f
	ld (08056h),hl		;8970   ; Y se guarda para quien la pida
	call 0fd9ah		;8973   ; BIOS HOOKS - System hooks | Vector de sonido
	ret			;8976

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8977..0x8978  (1 bytes)
DATA_8977:
	defb 0c9h	; 8977

; ======================================================================
; CODIGO 0x8978..0x898f  (23 bytes)
; ======================================================================


L_8978:
	sub a			;8978
	ld (0805bh),a		;8979
L_897C:
	ld b,003h		;897c
L_897E:
	push bc			;897e
	dec b			;897f
	ld a,b			;8980
	call 000d5h		;8981   ; BIOS GTSTCK - Returns the joystick status
	or a			;8984
	pop bc			;8985
	jr nz,L_898B		;8986
	djnz L_897E		;8988
	ret			;898a
L_898B:
	ld (0805bh),a		;898b
	ret			;898e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x898f..0x8990  (1 bytes)
DATA_898F:
	defb 0c9h	; 898f

; ======================================================================
; CODIGO 0x8990..0x89f1  (97 bytes)
; ======================================================================


L_8990:
	ld a,(0805bh)		;8990
	or a			;8993
	ret z			;8994
	cp 001h		;8995
	jp L_A7D0		;8997
reparte_por_estado_2:		; Los estados 3, 5 y 7 tienen rutina propia
	cp 003h		;899a   ; Estado 3
	jp z,vuelve_al_otro_lado		;899c
	cp 005h		;899f   ; Estado 5
	jp z,L_8BD0		;89a1
	cp 007h		;89a4   ; Estado 7
	jr z,vuelve_a_un_lado		;89a6
	sub a			;89a8   ; Y cualquier otro no hace nada
	ret			;89a9
vuelve_a_un_lado:		; Cambia el sentido a -1 y pone el dibujo de ese lado
	ld a,(0805ch)		;89aa   ; El sentido
	inc a			;89ad   ; Si ya era -1, solo hay que animar
	jr z,anima_del_banco_dos		;89ae
	ld a,0ffh		;89b0   ; Sentido -1
	ld (0805ch),a		;89b2
	ld a,004h		;89b5   ; Y su dibujo de partida
	ld (0804bh),a		;89b7
anima_del_banco_dos:		; Cambia de dibujo cada dos pasos, con el banco 2
	call casilla_de_un_lado		;89ba
	dec (hl)			;89bd   ; Cuenta atras
	jr nz,L_89D6		;89be
	ld (hl),002h		;89c0   ; Se recarga a 2
	dec hl			;89c2
	ld b,(hl)			;89c3
	ld c,002h		;89c4   ; Banco 2
	ld a,010h		;89c6   ; Numero de sprite
	call pinta_un_sprite		;89c8
	call pinta_y_mira_los_cuatro_hitos		;89cb
	ld a,b			;89ce
	cp 02ch		;89cf   ; Final del ciclo
	jr nz,L_89D5		;89d1
	ld a,004h		;89d3   ; Rebobina
L_89D5:
	ld (hl),a			;89d5
L_89D6:
	call L_8CF0		;89d6
	ld a,(08059h)		;89d9
	or a			;89dc
	jr z,mira_la_casilla_de_atras		;89dd
L_89DF:
	dec (hl)			;89df
	call mira_el_estado_y_el_sentido		;89e0
	ret			;89e3
mira_la_casilla_de_atras:		; Prueba la casilla anterior y, si no vale, deja la X como esta
	call L_8930		;89e4   ; La casilla del jugador
	dec hl			;89e7   ; Una atras
	call L_8A1C		;89e8   ; La prueba
	ret z			;89eb   ; No vale: se queda
	ld hl,08049h		;89ec   ; La X del jugador
	jr L_89DF		;89ef

; ----------------------------------------------------------------------
; DATOS tabla_de_baldosas_1: 43 codigos de baldosa que recorre 0x8A2A
;   0x89f1..0x8a1c  (43 bytes)
DATA_tabla_de_baldosas_1:
	defb 001h,002h,003h,004h,005h,006h,007h,05bh,009h,018h,019h,05dh,0efh,05ch,05eh,01eh	; 89f1  .......[...].\^.
	defb 01fh,0ffh,0b6h,0c5h,06ah,06bh,06dh,0ffh,0ffh,070h,071h,072h,073h,074h,075h,076h	; 8a01  ....jkm..pqrstuv
	defb 077h,078h,079h,07ah,0a1h,0a2h,0a3h,0a4h,0a5h,0a6h,0a7h	; 8a11  wxyz.......

; ======================================================================
; CODIGO 0x8a1c..0x8a37  (27 bytes)
; ======================================================================


L_8A1C:
	ld de,0ffe0h		;8a1c
	add hl,de			;8a1f
	ld b,004h		;8a20
	ld de,00020h		;8a22
L_8A25:
	add hl,de			;8a25
L_8A26:
	call 0004ah		;8a26   ; BIOS RDVRM - Reads the content of VRAM
	exx			;8a29
	ld hl,089f1h		;8a2a
	ld bc,0002bh		;8a2d
	cpir		;8a30
	exx			;8a32
	ret z			;8a33
	djnz L_8A25		;8a34
	ret			;8a36

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8a37..0x8a38  (1 bytes)
DATA_8A37:
	defb 000h	; 8a37

; ======================================================================
; CODIGO 0x8a38..0x8b2d  (245 bytes)
; ======================================================================


vuelve_al_otro_lado:		; El gemelo de 0x89AA con sentido +1
	ld a,(0805ch)		;8a38   ; El sentido
	dec a			;8a3b   ; Si ya era 1, solo hay que animar
	jr z,anima_del_banco_uno		;8a3c
	ld a,001h		;8a3e   ; Sentido 1
	ld (0805ch),a		;8a40
	ld a,0aah		;8a43   ; Y su dibujo de partida
	ld (0804bh),a		;8a45
anima_del_banco_uno:		; Lo mismo con el banco 1 y otro ciclo
	call casilla_del_otro_lado		;8a48
	dec (hl)			;8a4b   ; Cuenta atras
	jr nz,L_8A64		;8a4c
	ld (hl),002h		;8a4e   ; Se recarga a 2
	dec hl			;8a50
	ld b,(hl)			;8a51
	ld c,001h		;8a52   ; Banco 1
	ld a,010h		;8a54   ; Numero de sprite
	call pinta_un_sprite		;8a56
	call pinta_y_mira_los_cuatro_hitos		;8a59
	ld a,b			;8a5c
	cp 0d2h		;8a5d   ; Final del ciclo
	jr nz,L_8A63		;8a5f
	ld a,0aah		;8a61   ; Rebobina
L_8A63:
	ld (hl),a			;8a63
L_8A64:
	call L_8CF0		;8a64
	ld a,(08059h)		;8a67
	or a			;8a6a
	jr z,mira_la_casilla_de_delante		;8a6b
L_8A6D:
	inc (hl)			;8a6d
	call mira_el_estado_y_el_sentido_2		;8a6e
	ret			;8a71
mira_la_casilla_de_delante:		; El gemelo de 0x89E4 hacia el otro lado
	call L_8930		;8a72   ; La casilla del jugador
	inc hl			;8a75   ; Dos adelante
	inc hl			;8a76   ; La prueba
	call L_8A1C		;8a77
	ret z			;8a7a   ; No vale: se queda
	ld hl,08049h		;8a7b
	jr L_8A6D		;8a7e
L_8A80:
	jr nz,L_8A96		;8a80
	jp L_8F03		;8a82
L_8A85:
	ld a,(0805ch)		;8a85
	dec a			;8a88
	jr z,L_8A8E		;8a89
	ld bc,00002h		;8a8b
L_8A8E:
	ld a,010h		;8a8e
	call pinta_un_sprite		;8a90
	call pinta_un_sprite		;8a93
L_8A96:
	call 0fd9ah		;8a96   ; BIOS HOOKS - System hooks
	ret			;8a99
mira_la_tecla_de_saltar:		; Con la tecla 6 pulsada, prepara el salto
	ld a,006h		;8a9a   ; La tecla 6
	call L_8DE0		;8a9c
	nop			;8a9f   ; Un NOP
	ret c			;8aa0   ; No esta pulsada
	call L_8978		;8aa1   ; Y ademas tiene que haber suelo
	jr z,prepara_el_salto		;8aa4
L_8AA6:
	cp 007h		;8aa6
	jr z,L_8AB1		;8aa8
	cp 003h		;8aaa
	ret nz			;8aac
L_8AAD:
	ld a,001h		;8aad
	jr prepara_el_salto		;8aaf
L_8AB1:
	ld a,0ffh		;8ab1
prepara_el_salto:		; Deja el subtipo, el paso y el sprite que toque segun el sentido
	ld (0805eh),a		;8ab3
	ld a,006h		;8ab6   ; Paso de seis
	ld (0805fh),a		;8ab8
	call traduce_el_estado		;8abb
	ld a,020h		;8abe   ; Treinta y dos pasos de cuenta
	ld (08048h),a		;8ac0
	ld bc,0d201h		;8ac3   ; Sprite y banco para un sentido...
	ld a,(0805ch)		;8ac6
	dec a			;8ac9
	jr z,salta		;8aca
	ld bc,02c02h		;8acc   ; ...y para el otro
salta:		; Pinta al jugador saltando y arranca la subida
	ld a,010h		;8acf   ; Numero de sprite
	call pinta_un_sprite		;8ad1   ; Los dos planos
	call pinta_un_sprite		;8ad4
	ld a,001h		;8ad7   ; Estado 1 del salto
	ld (0804eh),a		;8ad9
	call L_BEE6		;8adc
	ret			;8adf
reparte_por_tipo:		; Segun el tipo, a una rutina o a otra
	dec a			;8ae0
	jp nz,termina_el_salto		;8ae1   ; Si no es del tipo 1, a otro sitio
	call L_8930		;8ae4
	ld a,(0805eh)		;8ae7   ; El subtipo
	cp 001h		;8aea   ; Subtipo 1
	jp z,mira_la_casilla_de_abajo_2		;8aec
	cp 0ffh		;8aef   ; Subtipo 0xFF
	jp z,mira_la_casilla_de_abajo		;8af1
	ld de,00000h		;8af4
	add hl,de			;8af7
	call L_8B14		;8af8   ; Prueba tres posiciones seguidas
	jp z,cae		;8afb
	inc hl			;8afe
	call L_8B14		;8aff
	jp z,cae		;8b02
	ld a,(08059h)		;8b05   ; Y una bandera mas
	or a			;8b08
	jr z,L_8B12		;8b09
	nop			;8b0b
	call L_8B14		;8b0c
	jp z,cae		;8b0f
L_8B12:
	jr baja_un_paso		;8b12
L_8B14:
	ld b,001h		;8b14
	jp L_8A26		;8b16
baja_un_paso:		; Resta el paso a la Y y descuenta
	ld a,(0804ah)		;8b19   ; La Y del jugador
	ld hl,0805fh		;8b1c   ; El paso
	sub (hl)			;8b1f   ; Baja
	ld (0804ah),a		;8b20
	dec (hl)			;8b23   ; Un paso menos
	jr z,$+10		;8b24
	ret			;8b26
L_8B27:
	call pinta_al_jugador		;8b27
	jp L_8EF8		;8b2a

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8b2d..0x8b2e  (1 bytes)
DATA_8B2D:
	defb 0c9h	; 8b2d

; ======================================================================
; CODIGO 0x8b2e..0x8b63  (53 bytes)
; ======================================================================


cae:		; Estado 2 y paso de diez, con el sprite del lado que toque
	ld a,002h		;8b2e
	ld (0804eh),a		;8b30   ; Estado 2
	ld a,00ah		;8b33   ; Paso de caida, diez
	ld (0805fh),a		;8b35
	ld bc,0d601h		;8b38   ; Sprite y banco de un lado...
	ld a,(0805ch)		;8b3b
	dec a			;8b3e
	jr z,L_8B44		;8b3f   ; ...y del otro
	ld bc,03002h		;8b41
L_8B44:
	ld a,010h		;8b44
	call pinta_un_sprite		;8b46
	call pinta_un_sprite		;8b49
	call 0fd9ah		;8b4c   ; BIOS HOOKS - System hooks
	ret			;8b4f
termina_el_salto:		; Con el estado 2, descuenta el paso y pasa al estado 3
	dec a			;8b50   ; Solo si el estado es 2
	jp nz,prueba_dos_casillas_abajo		;8b51
	ld hl,0805fh		;8b54   ; El paso
	dec (hl)			;8b57
	jp nz,sigue_o_para		;8b58   ; Se recarga a uno
	ld (hl),001h		;8b5b
	ld a,003h		;8b5d   ; Estado 3
	ld (0804eh),a		;8b5f
	ret			;8b62

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8b63..0x8b64  (1 bytes)
DATA_8B63:
	defb 0c9h	; 8b63

; ======================================================================
; CODIGO 0x8b64..0x8b9d  (57 bytes)
; ======================================================================


prueba_dos_casillas_abajo:		; Mira las dos casillas que hay cuatro filas mas abajo
	call L_8930		;8b64
	ld de,00080h		;8b67   ; 0x80 = cuatro filas de 32
	add hl,de			;8b6a
	call L_8B14		;8b6b   ; La primera casilla
	jp z,aterriza		;8b6e
	inc hl			;8b71
	call L_8B14		;8b72   ; Y la de al lado
	jp z,aterriza		;8b75
	ld a,(0e03dh)		;8b78   ; Una bandera de la ficha
	or a			;8b7b
	jp nz,L_BBD8		;8b7c
	nop			;8b7f   ; Un NOP
cae_un_escalon:		; Baja al jugador el paso que diga 0x805F, hasta un maximo de ocho
	nop			;8b80
	call L_BBF2		;8b81
	nop			;8b84
	ld hl,0804ah		;8b85   ; La Y del jugador
	ld a,(0805fh)		;8b88   ; El paso de caida
	add a,(hl)			;8b8b
	ld (hl),a			;8b8c   ; Baja
	ld a,(0805fh)		;8b8d
	inc a			;8b90
	cp 009h		;8b91   ; El paso crece hasta nueve...
	jr nz,L_8B97		;8b93
	ld a,008h		;8b95   ; ...y se queda en ocho
L_8B97:
	ld (0805fh),a		;8b97
	jp sigue_o_para		;8b9a

; ----------------------------------------------------------------------
; DATOS ret_y_relleno: un 0xC9 (RET) y ceros detras
;   0x8b9d..0x8ba0  (3 bytes)
DATA_8B9D:
	defb 0c9h,000h,000h	; 8b9d

; ======================================================================
; CODIGO 0x8ba0..0x8bf7  (87 bytes)
; ======================================================================


alinea_la_casilla:		; Deja H a multiplo de ocho y devuelve la columna en A
	ld b,l			;8ba0   ; Guarda la columna
	ld a,h			;8ba1
	and 0f8h		;8ba2   ; Redondea la fila a multiplo de ocho
	ld l,a			;8ba4
	ld a,b			;8ba5   ; Y devuelve la columna
	ld h,000h		;8ba6
	ret			;8ba8
aterriza:		; Borra el vector, recarga la cuenta y elige el sprite segun el sentido
	sub a			;8ba9   ; Sin rutina en el vector
	ld (0804eh),a		;8baa
	ld a,020h		;8bad
	ld (08048h),a		;8baf   ; Treinta y dos pasos
	call L_C05D		;8bb2
	ld bc,0d201h		;8bb5   ; Sprite y banco para un sentido...
	ld a,(0805ch)		;8bb8
	dec a			;8bbb
	jr z,pinta_y_sigue		;8bbc
	ld bc,02c02h		;8bbe   ; ...y para el otro
pinta_y_sigue:		; Sube el sprite del jugador y hace la tanda de siempre
	ld a,010h		;8bc1   ; Numero de sprite
	call pinta_un_sprite		;8bc3   ; Los dos planos
	call pinta_un_sprite		;8bc6
	call L_9308		;8bc9   ; Lo que toque despues
	call L_8BEE		;8bcc
	ret			;8bcf
L_8BD0:
	call L_9358		;8bd0
	call 0fd9ah		;8bd3   ; BIOS HOOKS - System hooks
	ld bc,0d201h		;8bd6
	ld a,(0805ch)		;8bd9
	dec a			;8bdc
	jr z,L_8BE2		;8bdd
	ld bc,02c02h		;8bdf
L_8BE2:
	ld a,010h		;8be2
	call pinta_un_sprite		;8be4
	call pinta_un_sprite		;8be7
	call 0fd9ah		;8bea   ; BIOS HOOKS - System hooks
	ret			;8bed
L_8BEE:
	ld a,(0804ah)		;8bee
	and 0f8h		;8bf1
	ld (0804ah),a		;8bf3
	ret			;8bf6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8bf7..0x8bf8  (1 bytes)
DATA_8BF7:
	defb 000h	; 8bf7

; ======================================================================
; CODIGO 0x8bf8..0x8c58  (96 bytes)
; ======================================================================


mira_la_casilla_de_abajo:		; Con la bandera puesta va a subir; si no, prueba la casilla anterior
	ld de,00000h		;8bf8
	add hl,de			;8bfb   ; La bandera de sentido
	ld a,(08059h)		;8bfc
	or a			;8bff   ; Puesta: sube
	jr nz,sube_un_escalon		;8c00
	dec hl			;8c02   ; La prueba
	call L_8B14		;8c03
	jp z,cae		;8c06
	inc hl			;8c09
sube_un_escalon:		; Al reves que 0x8B80: resta el paso de la Y
	call L_8B14		;8c0a   ; Prueba una casilla
	jp z,cae		;8c0d
	inc hl			;8c10
	call L_8B14		;8c11   ; Y la de al lado
	jp z,cae		;8c14
	ld hl,0805fh		;8c17   ; El paso
	ld a,(0804ah)		;8c1a
	sub (hl)			;8c1d
	ld (0804ah),a		;8c1e   ; Sube
	dec (hl)			;8c21   ; Cuando el paso llega a cero, se acabo
	jp z,cae		;8c22
	jp L_89D6		;8c25
sigue_o_para:		; Si el subtipo es 0xFF se para; si no, sigue animando
	ld a,(0805eh)		;8c28   ; El subtipo
	or a			;8c2b   ; Cero: nada que hacer
	ret z			;8c2c
	inc a			;8c2d   ; 0xFF: a un lado
	jp z,L_89D6		;8c2e
	jp L_8A64		;8c31   ; Y si no, al otro
mira_el_suelo:		; Comprueba las dos casillas de cuatro filas mas abajo con la otra prueba
	call L_8930		;8c34
	ld de,00080h		;8c37   ; 0x80 = cuatro filas
	add hl,de			;8c3a
	call L_8CA0		;8c3b
	ret nz			;8c3e
	ret nz			;8c3f   ; Este segundo RET NZ no puede ejecutarse: el de arriba ya ha vuelto
	inc hl			;8c40
	call L_8CA0		;8c41
	ret nz			;8c44
	ret nz			;8c45   ; Y este tampoco
	ld a,(0e03dh)		;8c46   ; Una bandera de la ficha
	or a			;8c49
	jp nz,L_BBD0		;8c4a
	call L_BBF2		;8c4d
L_8C50:
	ld a,003h		;8c50
	ld (0804eh),a		;8c52
	jp deja_de_saltar		;8c55

; ----------------------------------------------------------------------
; DATOS tabla_de_animacion: 60 bytes que leen 0x91FB-0x9211; 0x8C5E es ademas
;   el UNICO byte de este bloque fuera de 0x8000-0x80FF que cambia mientras se
;   juega, o sea que es una variable metida dentro de la tabla
;   0x8c58..0x8c94  (60 bytes)
DATA_tabla_de_animacion:
	defb 0a9h,0a8h,0a6h,0a1h,0a6h,0a8h,059h,08ch,000h,000h,073h,000h	; 8c58  ......Y...s.
	defb 000h,072h,074h,000h,000h,071h,074h,000h,000h,071h,075h,000h	; 8c64  .rt..qt..qu.
	defb 000h,070h,076h,06fh,06eh,076h,075h,06fh,06eh,06dh,076h,06fh	; 8c70  .pvonvuonmvo
	defb 06eh,075h,076h,06fh,075h,076h,076h,06dh,070h,076h,075h,06dh	; 8c7c  nuvouvvmpvum
	defb 079h,076h,07ah,06dh,077h,075h,070h,076h,077h,075h,078h,076h	; 8c88  yvzmwupvwuxv

; ======================================================================
; CODIGO 0x8c94..0x8c9e  (10 bytes)
; ======================================================================


L_8C94:
	ld (080b5h),a		;8c94
	ld a,(080bch)		;8c97
	ld (080adh),a		;8c9a
	ret			;8c9d

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0x8c9e..0x8ca0  (2 bytes)
DATA_8C9E:
	defb 0ffh,0ffh	; 8c9e

; ======================================================================
; CODIGO 0x8ca0..0x8cae  (14 bytes)
; ======================================================================


L_8CA0:
	call 0004ah		;8ca0   ; BIOS RDVRM - Reads the content of VRAM
	exx			;8ca3
	ld hl,08d28h		;8ca4
	ld bc,00058h		;8ca7
	cpir		;8caa
	exx			;8cac
	ret			;8cad

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET huerfanos
;   0x8cae..0x8cb0  (2 bytes)
DATA_8CAE:
	defb 0c9h,0c9h	; 8cae

; ======================================================================
; CODIGO 0x8cb0..0x8cf7  (71 bytes)
; ======================================================================


L_8CB0:
	dec a			;8cb0
	jp z,reparte_por_lo_leido		;8cb1
	dec a			;8cb4
	jp z,reparte_por_lo_leido_2		;8cb5
deja_de_saltar:		; Pone a cero las tres variables del salto y el estado 3
	sub a			;8cb8
	ld (0805eh),a		;8cb9   ; Subtipo a cero
	ld (0805fh),a		;8cbc   ; Paso a cero
	ld (0804dh),a		;8cbf   ; Y el parpadeo tambien
	ld a,003h		;8cc2   ; Estado 3
	ld (0804eh),a		;8cc4
	ret			;8cc7
mira_el_estado_y_el_sentido:		; Sin estado no hace nada; con el, mira hacia donde va
	ex af,af'			;8cc8
	ld a,(0804eh)		;8cc9   ; El estado
	or a			;8ccc
	jp z,L_8CE8		;8ccd   ; Cero: nada
	call L_8930		;8cd0   ; La casilla
	ld a,(08059h)		;8cd3   ; El sentido
	or a			;8cd6
	jr z,L_8CE0		;8cd7
L_8CD9:
	ld hl,08049h		;8cd9
	dec (hl)			;8cdc
	jp L_8CE8		;8cdd
L_8CE0:
	dec hl			;8ce0
	call L_8A1C		;8ce1
	ret z			;8ce4
	jp L_8CD9		;8ce5
L_8CE8:
	ex af,af'			;8ce8
	call L_90E8		;8ce9
	call 0fd9ah		;8cec   ; BIOS HOOKS - System hooks
	ret			;8cef
L_8CF0:
	call L_8930		;8cf0
	ld hl,08049h		;8cf3
	ret			;8cf6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8cf7..0x8cf8  (1 bytes)
DATA_8CF7:
	defb 0c9h	; 8cf7

; ======================================================================
; CODIGO 0x8cf8..0x8d23  (43 bytes)
; ======================================================================


casilla_de_un_lado:		; Devuelve la casilla de la izquierda, si el sentido lo permite
	ld a,(08059h)		;8cf8   ; El sentido
	or a			;8cfb
	jr nz,L_8D07		;8cfc   ; No: se sale
	ld hl,(08056h)		;8cfe   ; La casilla en curso
	dec hl			;8d01   ; La prueba
	call L_8A1C		;8d02
	jr z,L_8D0B		;8d05
L_8D07:
	ld hl,0804ch		;8d07
	ret			;8d0a
L_8D0B:
	pop hl			;8d0b
	ret			;8d0c
casilla_del_otro_lado:		; Y la de la derecha
	ld a,(08059h)		;8d0d   ; El sentido
	or a			;8d10
	jr nz,L_8D1D		;8d11   ; No: se sale
	ld hl,(08056h)		;8d13   ; La casilla en curso
	inc hl			;8d16   ; Dos adelante
	inc hl			;8d17   ; La prueba
	call L_8A1C		;8d18
	jr z,L_8D21		;8d1b
L_8D1D:
	ld hl,0804ch		;8d1d
	ret			;8d20
L_8D21:
	pop hl			;8d21
	ret			;8d22

; ----------------------------------------------------------------------
; DATOS tabla_de_codigos_de_baldosa: Traduccion a codigos de baldosa; el
;   indice entra por 0x8D28 desde 0x8CA4. Los codigos son los de la fuente:
;   '"' '#' '$'... y luego las letras minusculas
;   0x8d23..0x8d80  (93 bytes)
DATA_tabla_de_codigos_de_baldosa:
	defb 000h,000h,000h,000h,000h,000h,00ah,00bh,00ch,00dh,01ah,01bh,022h,023h,024h,025h	; 8d23  ............"#$%
	defb 026h,027h,028h,029h,02ah,03ah,03bh,060h,061h,062h,063h,064h,065h,066h,067h,068h	; 8d33  &'()*:;`abcdefgh
	defb 069h,07bh,07ch,07dh,07eh,07fh,080h,081h,082h,083h,084h,085h,086h,087h,088h,089h	; 8d43  i{|}~...........
	defb 08ah,08bh,08ch,08dh,08eh,08fh,090h,091h,092h,093h,094h,095h,096h,097h,098h,099h	; 8d53  ................
	defb 09ah,09bh,09ch,09dh,09eh,09fh,0a0h,0b0h,0b1h,0b2h,0b3h,020h,021h,01ch,01dh,0a9h	; 8d63  ........... !...
	defb 0aah,0abh,0ach,0adh,0aeh,0afh,008h,06eh,06fh,02fh,008h,0ffh,0ffh	; 8d73  .......no/...

; ======================================================================
; CODIGO 0x8d80..0x8ddd  (93 bytes)
; ======================================================================


mira_la_casilla_de_abajo_2:		; El gemelo de 0x8BF8 en la otra fase
	ld de,00000h		;8d80
	add hl,de			;8d83   ; La bandera de sentido
	ld a,(08059h)		;8d84
	or a			;8d87   ; Puesta: sube
	jr nz,sube_un_escalon_2		;8d88
	nop			;8d8a   ; La prueba
	call L_8B14		;8d8b
	jp z,cae		;8d8e
	inc hl			;8d91
sube_un_escalon_2:		; El gemelo de 0x8C0A para la otra fase
	call L_8B14		;8d92
	jp z,cae		;8d95
	inc hl			;8d98
	call L_8B14		;8d99
	jp z,cae		;8d9c
	ld hl,0805fh		;8d9f   ; El paso
	ld a,(0804ah)		;8da2
	sub (hl)			;8da5
	ld (0804ah),a		;8da6   ; Sube
	dec (hl)			;8da9   ; Cuando llega a cero, se acabo
	jp z,cae		;8daa
	jp L_8A64		;8dad
mira_el_estado_y_el_sentido_2:		; El gemelo de 0x8CC8
	ex af,af'			;8db0
	ld a,(0804eh)		;8db1   ; El estado
	or a			;8db4
	jp z,L_8DD0		;8db5   ; Cero: nada
	call L_8DD8		;8db8   ; La casilla
	ld a,(08059h)		;8dbb   ; El sentido
	or a			;8dbe
	jr z,L_8DC8		;8dbf
L_8DC1:
	ld hl,08049h		;8dc1
	inc (hl)			;8dc4
	jp L_8DD0		;8dc5
L_8DC8:
	inc hl			;8dc8
	call L_8A1C		;8dc9
	ret z			;8dcc
	jp L_8DC1		;8dcd
L_8DD0:
	ex af,af'			;8dd0
	call L_90EF		;8dd1
	call 0fd9ah		;8dd4   ; BIOS HOOKS - System hooks
	ret			;8dd7
L_8DD8:
	call L_8930		;8dd8
	inc hl			;8ddb
	ret			;8ddc

; ----------------------------------------------------------------------
; DATOS tres_ret_sueltos: Tres RET huerfanos
;   0x8ddd..0x8de0  (3 bytes)
DATA_tres_ret_sueltos:
	defb 0c9h,0c9h,0c9h	; 8ddd

; ======================================================================
; CODIGO 0x8de0..0x8e0e  (46 bytes)
; ======================================================================


L_8DE0:
	call 00141h		;8de0   ; BIOS SNSMAT - Returns the value of the specified line from the keyboard matrix
	rra			;8de3
	ret nc			;8de4
	ld a,001h		;8de5
	call 000d8h		;8de7   ; BIOS GTTRIG - Returns current trigger status
	ccf			;8dea
	ret nc			;8deb
	ld a,003h		;8dec
	call 000d8h		;8dee   ; BIOS GTTRIG - Returns current trigger status
	ccf			;8df1
	ret			;8df2
L_8DF3:
	jp L_8EF0		;8df3
L_8DF6:
	sub a			;8df6
	call 000d8h		;8df7   ; BIOS GTTRIG - Returns current trigger status
	call c,L_8E10		;8dfa
	ld a,002h		;8dfd
	call 000d8h		;8dff   ; BIOS GTTRIG - Returns current trigger status
	call c,L_8E10		;8e02
	ld a,004h		;8e05
	call 000d8h		;8e07   ; BIOS GTTRIG - Returns current trigger status
	call c,L_8E10		;8e0a
	ret			;8e0d

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET huerfanos
;   0x8e0e..0x8e10  (2 bytes)
DATA_8E0E:
	defb 0c9h,0c9h	; 8e0e

; ======================================================================
; CODIGO 0x8e10..0x8e4f  (63 bytes)
; ======================================================================


L_8E10:
	call L_9178		;8e10
	cp 005h		;8e13
	jp z,L_8F10		;8e15
prepara_el_disparo:		; Estado 1 y posicion de partida segun el sentido
	ld a,001h		;8e18
	ld (08050h),a		;8e1a   ; Estado 1
	ld a,(0805ch)		;8e1d   ; El sentido
	dec a			;8e20
	ld hl,06860h		;8e21   ; Sale por un lado...
	jr z,empieza_a_caer		;8e24
	ld hl,07068h		;8e26   ; ...o por el otro
empieza_a_caer:		; Guarda la posicion, pone el estado 4 y elige el sprite
	ld (0806fh),hl		;8e29
	ld a,004h		;8e2c
	ld (08051h),a		;8e2e   ; Estado 4
	ld hl,(08049h)		;8e31   ; La posicion en curso
	ld (08052h),hl		;8e34
	ld bc,0a601h		;8e37   ; Sprite y banco para un sentido...
	ld a,(0805ch)		;8e3a
	dec a			;8e3d
	jr z,L_8E43		;8e3e
	ld bc,00002h		;8e40   ; ...y para el otro
L_8E43:
	ld a,010h		;8e43
	call pinta_un_sprite		;8e45
	call pinta_un_sprite		;8e48
	call 0fd9ah		;8e4b   ; BIOS HOOKS - System hooks
	ret			;8e4e

; ----------------------------------------------------------------------
; DATOS datos_8E4F: Nueve bytes entre dos rutinas de teclado. Ninguna
;   instruccion los apunta
;   0x8e4f..0x8e58  (9 bytes)
DATA_datos_8E4F:
	defb 0c9h,0c2h,0d0h,0dah,01ah,0b7h,0cah,016h,089h	; 8e4f  .........

; ======================================================================
; CODIGO 0x8e58..0x8e9f  (71 bytes)
; ======================================================================


mueve_el_disparo:		; Con el estado 1, avanza el disparo si no ha llegado al tope
	dec a			;8e58   ; Solo si el estado es 1
	jp nz,L_8EA0		;8e59
	ld a,(0806fh)		;8e5c   ; La posicion
	ld hl,08070h		;8e5f
	cp (hl)			;8e62   ; El tope
	jr z,L_8E71		;8e63   ; Ya esta: no se mueve mas
	ld b,a			;8e65
	ld c,002h		;8e66   ; Banco 2
	ld a,010h		;8e68   ; Numero de sprite
	call pinta_y_elige_el_par		;8e6a
	ld a,b			;8e6d
	dec hl			;8e6e
	ld (hl),a			;8e6f
	ret			;8e70
L_8E71:
	call L_A130		;8e71
	call L_8930		;8e74
	nop			;8e77
	ld (08054h),hl		;8e78
mira_dos_casillas:		; Prueba dos casillas seguidas y, si las dos valen, pone el estado 2
	ld a,(0805ch)		;8e7b
	ld (08071h),a		;8e7e   ; Guarda el sentido
	call L_A390		;8e81   ; Primera casilla
	nop			;8e84   ; Un NOP
	jr nz,L_8E97		;8e85
	inc hl			;8e87
	call L_A390		;8e88   ; Segunda casilla
	nop			;8e8b
	jr nz,L_8E97		;8e8c
	ld a,002h		;8e8e
	ld (08050h),a		;8e90   ; Las dos valen: estado 2
	call 0fd9ah		;8e93   ; BIOS HOOKS - System hooks | Vector de sonido
	ret			;8e96
L_8E97:
	sub a			;8e97
	ld (08050h),a		;8e98
	call 0fd9ah		;8e9b   ; BIOS HOOKS - System hooks
	ret			;8e9e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8e9f..0x8ea0  (1 bytes)
DATA_8E9F:
	defb 0c9h	; 8e9f

; ======================================================================
; CODIGO 0x8ea0..0x8ed5  (53 bytes)
; ======================================================================


L_8EA0:
	dec a			;8ea0
	jp nz,L_8F70		;8ea1
	jp avanza_el_disparo		;8ea4
mira_la_casilla_anterior:		; Retrocede una y hace las dos comprobaciones
	dec hl			;8ea7   ; Una casilla atras
	call L_A3A0		;8ea8   ; La primera prueba
	call L_A392		;8eab   ; La segunda
	nop			;8eae   ; Dos NOP
	nop			;8eaf
	jr z,L_8EB5		;8eb0
	jp L_A0DC		;8eb2
L_8EB5:
	ld a,07dh		;8eb5
	call 0004dh		;8eb7   ; BIOS WRTVRM - Writes data in VRAM
	ld (08054h),hl		;8eba
	inc hl			;8ebd
	inc a			;8ebe
	call 0004dh		;8ebf   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8ec2
	sub a			;8ec3
	call 0004dh		;8ec4   ; BIOS WRTVRM - Writes data in VRAM
	ld a,(08052h)		;8ec7
	sub 008h		;8eca
	ld (08052h),a		;8ecc
	cp 008h		;8ecf
	jp c,L_8ED8		;8ed1
	ret			;8ed4

; ----------------------------------------------------------------------
; DATOS datos_8ED5: Los tres bytes 16 89 00, iguales que los tres primeros de
;   0x8EEA
;   0x8ed5..0x8ed8  (3 bytes)
DATA_datos_8ED5:
	defb 016h,089h,000h	; 8ed5

; ======================================================================
; CODIGO 0x8ed8..0x8eea  (18 bytes)
; ======================================================================


L_8ED8:
	ld hl,(08054h)		;8ed8
	sub a			;8edb
	call 0004dh		;8edc   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8edf
	call 0004dh		;8ee0   ; BIOS WRTVRM - Writes data in VRAM
L_8EE3:
	ld (08050h),a		;8ee3
	call 0fd9ah		;8ee6   ; BIOS HOOKS - System hooks
	ret			;8ee9

; ----------------------------------------------------------------------
; DATOS datos_8EEA: Seis bytes, 16 89 00 00 00 00. Nadie los apunta
;   0x8eea..0x8ef0  (6 bytes)
DATA_datos_8EEA:
	defb 016h,089h,000h,000h,000h,000h	; 8eea

; ======================================================================
; CODIGO 0x8ef0..0x8f0b  (27 bytes)
; ======================================================================


L_8EF0:
	ld a,(08050h)		;8ef0
	or a			;8ef3
	ret nz			;8ef4
	jp L_8DF6		;8ef5
L_8EF8:
	ld a,(08050h)		;8ef8
	or a			;8efb
	call nz,mueve_el_disparo		;8efc
	ld de,0804dh		;8eff
	ret			;8f02
L_8F03:
	ld a,(08050h)		;8f03
	or a			;8f06
	ret nz			;8f07
	jp pinta_si_esta_libre		;8f08

; ----------------------------------------------------------------------
; DATOS salto_huerfano: "jp 0x8A85" y dos ceros. Ninguna instruccion llega a
;   estos cinco bytes
;   0x8f0b..0x8f10  (5 bytes)
DATA_8F0B:
	defb 0c3h,085h,08ah,000h,000h	; 8f0b

; ======================================================================
; CODIGO 0x8f10..0x8f4d  (61 bytes)
; ======================================================================


L_8F10:
	ld a,(0805ch)		;8f10
	dec a			;8f13
	ld b,0a2h		;8f14
	jr z,pinta_el_disparo		;8f16
	ld b,0a0h		;8f18
pinta_el_disparo:		; Sube el sprite del disparo con el par que toque
	ld c,002h		;8f1a   ; Banco 2
	ld a,012h		;8f1c   ; Numero del sprite del disparo
	call pinta_un_sprite		;8f1e
	ld a,010h		;8f21   ; Y ahora el del jugador
	ld bc,0d201h		;8f23
	ld a,(0805ch)		;8f26   ; Un par...
	dec a			;8f29
	jr z,dispara		;8f2a
	ld bc,02c02h		;8f2c   ; ...o el otro
dispara:		; Pinta el disparo, apunta su casilla y espera
	ld a,010h		;8f2f   ; Numero de sprite
	call pinta_un_sprite		;8f31
	ld hl,(08049h)		;8f34   ; La posicion del jugador
	call L_B2D0		;8f37
	call L_8930		;8f3a
	ld de,00040h		;8f3d   ; 0x40 = dos filas de 32
	add hl,de			;8f40
	ld (08054h),hl		;8f41   ; La casilla del disparo
	ld bc,01000h		;8f44   ; Una espera
	call espera		;8f47
	jp mira_dos_casillas		;8f4a

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8f4d..0x8f50  (3 bytes)
DATA_8F4D:
	defb 000h,000h,000h	; 8f4d

; ======================================================================
; CODIGO 0x8f50..0x8f87  (55 bytes)
; ======================================================================


L_8F50:
	ld a,003h		;8f50
	ld (08050h),a		;8f52
	ld a,004h		;8f55
	ld (08051h),a		;8f57
	ld hl,(08054h)		;8f5a
	ld a,07fh		;8f5d
	call 0004dh		;8f5f   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8f62
	inc a			;8f63
	call 0004dh		;8f64   ; BIOS WRTVRM - Writes data in VRAM
L_8F67:
	call L_91B1		;8f67
	call 0fd9ah		;8f6a   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;8f6d   ; BIOS HOOKS - System hooks
L_8F70:
	call L_A090		;8f70
	dec (hl)			;8f73
	ret nz			;8f74
L_8F75:
	ld hl,(08054h)		;8f75
	sub a			;8f78
	call 0004dh		;8f79   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8f7c
	call 0004dh		;8f7d   ; BIOS WRTVRM - Writes data in VRAM
	ld (08050h),a		;8f80
	call 0fd9ah		;8f83   ; BIOS HOOKS - System hooks
	ret			;8f86

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x8f87..0x8f88  (1 bytes)
DATA_8F87:
	defb 0c9h	; 8f87

; ======================================================================
; CODIGO 0x8f88..0x8fce  (70 bytes)
; ======================================================================


avanza_el_disparo:		; Adelanta dos casillas y mira si choca
	ld hl,(08054h)		;8f88   ; La casilla del disparo
	ld a,(08071h)		;8f8b   ; El sentido
	inc a			;8f8e
	jp z,mira_la_casilla_anterior		;8f8f   ; 0xFF quiere decir "ninguno"
	inc hl			;8f92   ; Dos casillas mas alla
	inc hl			;8f93
	call L_A3A0		;8f94
	call L_A392		;8f97
	nop			;8f9a   ; Dos NOP
	nop			;8f9b
	jr z,L_8FA1		;8f9c
	jp L_A0DC		;8f9e
L_8FA1:
	nop			;8fa1
	ld a,07ch		;8fa2
	call 0004dh		;8fa4   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;8fa7
	dec a			;8fa8
	call 0004dh		;8fa9   ; BIOS WRTVRM - Writes data in VRAM
	ld (08054h),hl		;8fac
	dec hl			;8faf
	sub a			;8fb0
	call 0004dh		;8fb1   ; BIOS WRTVRM - Writes data in VRAM
	ld a,(08052h)		;8fb4
	add a,008h		;8fb7
	ld (08052h),a		;8fb9
	cp 0f8h		;8fbc
	ret c			;8fbe
	ld hl,(08054h)		;8fbf
	nop			;8fc2
	sub a			;8fc3
	call 0004dh		;8fc4   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;8fc7
	call 0004dh		;8fc8   ; BIOS WRTVRM - Writes data in VRAM
	jp L_8EE3		;8fcb

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x8fce..0x8fd0  (2 bytes)
DATA_8FCE:
	defb 000h,000h	; 8fce

; ======================================================================
; CODIGO 0x8fd0..0x902d  (93 bytes)
; ======================================================================


L_8FD0:
	call L_8930		;8fd0
	call 0004ah		;8fd3   ; BIOS RDVRM - Reads the content of VRAM
	cp 00eh		;8fd6
	jp z,L_9390		;8fd8
	cp 010h		;8fdb
	jr z,L_8FF8		;8fdd
	cp 012h		;8fdf
	jr z,L_8FF8		;8fe1
	ld de,0ffe0h		;8fe3
	add hl,de			;8fe6
	call 0004ah		;8fe7   ; BIOS RDVRM - Reads the content of VRAM
	cp 00eh		;8fea
	jp z,L_9390		;8fec
	cp 010h		;8fef
	jr z,L_8FF8		;8ff1
	cp 012h		;8ff3
	ret nz			;8ff5
	ret nz			;8ff6
	ret nz			;8ff7
L_8FF8:
	ld a,001h		;8ff8
	ld (0804dh),a		;8ffa
	ld a,0e6h		;8ffd
	ld (0804bh),a		;8fff
	call 0fd9ah		;9002   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;9005   ; BIOS HOOKS - System hooks
reparte_por_lo_leido:		; Segun lo que devuelva 0x90A2, una animacion u otra
	call L_90A2		;9008   ; Lo que se ha pedido
	cp 005h		;900b   ; El valor 5
	jp z,anima_al_jugador_b		;900d
	cp 001h		;9010   ; Y el 1; cualquier otro, a la general
	jp nz,L_90C8		;9012
	call anima_al_jugador_a		;9015
	ld a,(0805ah)		;9018   ; La bandera de bloqueo
	or a			;901b
	jr z,L_9023		;901c
L_901E:
	ld hl,0804ah		;901e
	dec (hl)			;9021
	ret			;9022
L_9023:
	ld de,0ffe0h		;9023
	add hl,de			;9026
	call L_8A1C		;9027
	ret z			;902a
	jr L_901E		;902b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x902d..0x9030  (3 bytes)
DATA_902D:
	defb 000h,000h,000h	; 902d

; ======================================================================
; CODIGO 0x9030..0x90cd  (157 bytes)
; ======================================================================


anima_al_jugador_a:		; Cada tres pasos cambia el dibujo del jugador, ciclo 0xE6-0xF2
	ld hl,0804ch		;9030
	dec (hl)			;9033   ; Cuenta atras del cambio de dibujo
	jr nz,L_9050		;9034
	ld (hl),003h		;9036   ; Se recarga a 3
	ld a,(0804bh)		;9038   ; El dibujo en curso
	ld b,a			;903b
	ld c,001h		;903c   ; Banco 1
	ld a,010h		;903e   ; Numero de sprite
	call pinta_un_sprite		;9040   ; Los dos planos de color
	call pinta_un_sprite		;9043
	ld a,b			;9046
	cp 0f2h		;9047   ; Final del ciclo
	jr nz,L_904D		;9049
	ld a,0e6h		;904b   ; Rebobina
L_904D:
	ld (0804bh),a		;904d
L_9050:
	call L_8930		;9050
	ret			;9053
anima_al_jugador_b:		; Como 0x9030 pero el ciclo va hacia atras, de ocho en ocho
	ld hl,0804ch		;9054
	dec (hl)			;9057   ; Cuenta atras
	jr nz,L_9076		;9058
	ld (hl),003h		;905a   ; Se recarga a 3
	ld a,(0804bh)		;905c   ; El dibujo en curso
	ld b,a			;905f
	ld c,001h		;9060   ; Banco 1
	ld a,010h		;9062   ; Numero de sprite
	call pinta_un_sprite		;9064
	call pinta_un_sprite		;9067
	ld a,b			;906a
	sub 008h		;906b   ; Retrocede ocho, que es un dibujo
	cp 0e2h		;906d   ; Principio del ciclo
	jr nz,L_9073		;906f
	ld a,0eeh		;9071   ; Rebobina
L_9073:
	ld (0804bh),a		;9073
L_9076:
	call L_8930		;9076
	ld a,(0805ah)		;9079
	or a			;907c
	jr z,L_9084		;907d
L_907F:
	ld hl,0804ah		;907f
	inc (hl)			;9082
	ret			;9083
L_9084:
	ld de,00080h		;9084
	add hl,de			;9087
	call L_8A1C		;9088
	jr nz,L_907F		;908b
L_908D:
	sub a			;908d
	ld (0804dh),a		;908e
L_9091:
	ld a,(0805ch)		;9091
	dec a			;9094
	ld a,0aah		;9095
	jr z,L_909B		;9097
	ld a,004h		;9099
L_909B:
	ld (0804bh),a		;909b
	call 0fd9ah		;909e   ; BIOS HOOKS - System hooks
	ret			;90a1
L_90A2:
	ld a,(0804bh)		;90a2
	cp 0e6h		;90a5
	jr nc,L_90AB		;90a7
	ld a,0e6h		;90a9
L_90AB:
	ld (0804bh),a		;90ab
	call L_8978		;90ae
	ret			;90b1
L_90B2:
	call L_908D		;90b2
	jp L_8990		;90b5
pinta_si_esta_libre:		; Solo pinta si las dos banderas estan a cero
	ld a,(0804dh)		;90b8   ; La primera bandera
	or a			;90bb
	ret nz			;90bc   ; Puesta: no se pinta
	ld a,(0804fh)		;90bd   ; La segunda
	or a			;90c0
	ret nz			;90c1
	ld bc,0a601h		;90c2   ; El sprite y el banco
	jp L_8A85		;90c5
L_90C8:
	or a			;90c8
	ret z			;90c9
	jp L_90B2		;90ca

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x90cd..0x90d0  (3 bytes)
DATA_90CD:
	defb 000h,000h,000h	; 90cd

; ======================================================================
; CODIGO 0x90d0..0x90f7  (39 bytes)
; ======================================================================


L_90D0:
	call L_9B00		;90d0
	ld hl,07000h		;90d3
	ld (08072h),hl		;90d6
	call 0fd9ah		;90d9   ; BIOS HOOKS - System hooks
	call apunta_la_ficha		;90dc
	ret			;90df
lee_la_entrada:		; Saca de la tabla en curso la direccion que toca
	ld hl,(08072h)		;90e0   ; El puntero de la tabla
	ld e,(hl)			;90e3   ; La direccion que trae
	inc hl			;90e4
	ld d,(hl)			;90e5
	ex de,hl			;90e6
	ret			;90e7
L_90E8:
	ld a,(hl)			;90e8
	cp 008h		;90e9
	jp c,L_90FC		;90eb
	ret			;90ee
L_90EF:
	ld a,(08049h)		;90ef
	cp 0efh		;90f2
	jr nc,$+4		;90f4
	ret			;90f6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x90f7..0x90f8  (1 bytes)
DATA_90F7:
	defb 000h	; 90f7

; ======================================================================
; CODIGO 0x90f8..0x9117  (31 bytes)
; ======================================================================


L_90F8:
	ld a,001h		;90f8
	jr L_90FE		;90fa
L_90FC:
	ld a,0ffh		;90fc
L_90FE:
	call apunta_la_ficha_3		;90fe
	ld de,0fffeh		;9101
	cp 001h		;9104
	jr nz,avanza_en_la_tabla		;9106
	ld de,00002h		;9108
avanza_en_la_tabla:		; Suma DE al puntero y llama a la direccion nueva
	add hl,de			;910b   ; Avanza el puntero
	ld (08072h),hl		;910c   ; Se guarda
	ld e,(hl)			;910f   ; La direccion que trae
	inc hl			;9110
	ld d,(hl)			;9111
	ex de,hl			;9112   ; Y se llama
	call L_818E		;9113
	ret			;9116

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9117..0x9118  (1 bytes)
DATA_9117:
	defb 0c9h	; 9117

; ======================================================================
; CODIGO 0x9118..0x9124  (12 bytes)
; ======================================================================


L_9118:
	ld a,(08049h)		;9118
	add a,007h		;911b
	ld (08049h),a		;911d
	call pinta_al_jugador		;9120
	ret			;9123

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9124..0x9128  (4 bytes)
DATA_9124:
	defb 000h,000h,000h,000h	; 9124

; ======================================================================
; CODIGO 0x9128..0x9174  (76 bytes)
; ======================================================================


L_9128:
	ld a,(08049h)		;9128
	sub 007h		;912b
	ld (08049h),a		;912d
	call pinta_al_jugador		;9130
	ret			;9133
cuenta_del_marcador:		; Descuenta 0x8058 y, al llegar a cero, refresca el marcador
	ld hl,08058h		;9134   ; Este LD HL esta REPETIDO: el de abajo hace exactamente lo mismo
	ld hl,08058h		;9137   ; La cuenta
	dec (hl)			;913a   ; Todavia no
	ret nz			;913b   ; Refresca
	call L_9164		;913c
	ret			;913f
lee_el_mando:		; Lee el mando, guarda lo leido y calcula la casilla de delante
	call L_A772		;9140
	nop			;9143   ; Un NOP
	cp 03fh		;9144   ; Compara con 0x3F, y el resultado lo usa 0x916B
	call L_916B		;9146
	ld (0806ch),a		;9149   ; Guarda lo que se ha pedido
	push bc			;914c
	call L_87EC		;914d   ; Mira si se puede ir
	pop bc			;9150
	ret c			;9151   ; Con acarreo, no se puede
	call L_915C		;9152
	nop			;9155   ; Dos NOP
	nop			;9156
	dec hl			;9157
	ld (0806dh),hl		;9158   ; La casilla de delante
	ret			;915b
L_915C:
	call casilla_del_marcador		;915c
	nop			;915f
	call 0004dh		;9160   ; BIOS WRTVRM - Writes data in VRAM
	ret			;9163
L_9164:
	call lee_el_mando		;9164
	call L_C038		;9167
	ret			;916a
L_916B:
	jp z,L_DBE0		;916b
	cp 069h		;916e
	call z,L_C009		;9170
	ret			;9173

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0x9174..0x9178  (4 bytes)
DATA_9174:
	defb 0ffh,0ffh,0ffh,0ffh	; 9174

; ======================================================================
; CODIGO 0x9178..0x92ef  (375 bytes)
; ======================================================================


L_9178:
	call L_BED4		;9178
	jp nz,L_8978		;917b
	ld a,007h		;917e
	ld e,087h		;9180
	call 00093h		;9182   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;9185
	ld e,010h		;9187
	call 00093h		;9189   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;918c
	call 00093h		;918d   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;9190
	call 00093h		;9191   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;9194
	ld e,000h		;9196
	call 00093h		;9198   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00bh		;919b
	ld e,000h		;919d
	call 00093h		;919f   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91a2
	ld e,004h		;91a3
	call 00093h		;91a5   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91a8
	ld e,005h		;91a9
	call L_9B13		;91ab
	jp L_8978		;91ae
L_91B1:
	call L_C019		;91b1
	jp z,0fd9ah		;91b4   ; BIOS HOOKS - System hooks
	ld a,007h		;91b7
	ld e,087h		;91b9
	call 00093h		;91bb   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;91be
	ld e,010h		;91c0
	call 00093h		;91c2   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91c5
	call 00093h		;91c6   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91c9
	call 00093h		;91ca   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;91cd
	ld e,01fh		;91cf
	call 00093h		;91d1   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00bh		;91d4
	ld e,000h		;91d6
	call 00093h		;91d8   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91db
	ld e,008h		;91dc
	call 00093h		;91de   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;91e1
	ld e,001h		;91e2
	call L_9B13		;91e4
	ret			;91e7
L_91E8:
	call L_A6B8		;91e8
	ld hl,08074h		;91eb
	dec (hl)			;91ee
	ret nz			;91ef
	ld (hl),010h		;91f0
	call 0fd9ah		;91f2   ; BIOS HOOKS - System hooks
	call 0fd9ah		;91f5   ; BIOS HOOKS - System hooks
	ld hl,03050h		;91f8
	ld de,(08c5eh)		;91fb
	ld a,(de)			;91ff
	ld bc,00008h		;9200
	call 00056h		;9203   ; BIOS FILVRM - Fills VRAM with value
	ex de,hl			;9206
	inc hl			;9207
	ld de,08c5eh		;9208
	rst 20h			;920b
	jr nz,L_9211		;920c
	ld hl,08c58h		;920e
L_9211:
	ld (08c5eh),hl		;9211
	ld hl,01348h		;9214
	ld b,008h		;9217
	scf			;9219
	ccf			;921a
L_921B:
	call 0004ah		;921b   ; BIOS RDVRM - Reads the content of VRAM
	rrca			;921e
	call 0004dh		;921f   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9222
	djnz L_921B		;9223
	ld hl,01340h		;9225
	ld b,008h		;9228
L_922A:
	call 0004ah		;922a   ; BIOS RDVRM - Reads the content of VRAM
	cpl			;922d
	call 0004dh		;922e   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9231
	djnz L_922A		;9232
	call 0fd9ah		;9234   ; BIOS HOOKS - System hooks
	ret			;9237
L_9238:
	call 0fd9ah		;9238   ; BIOS HOOKS - System hooks
	ld a,(0804fh)		;923b
	or a			;923e
	ret nz			;923f
	ld a,(0804eh)		;9240
	or a			;9243
	ret nz			;9244
	call 0fd9ah		;9245   ; BIOS HOOKS - System hooks
	call L_8930		;9248
	ld de,00040h		;924b
	add hl,de			;924e
	call 0004ah		;924f   ; BIOS RDVRM - Reads the content of VRAM
	cp 068h		;9252
	jr z,pone_el_dibujo_del_lado		;9254
	inc hl			;9256
	call 0004ah		;9257   ; BIOS RDVRM - Reads the content of VRAM
	cp 068h		;925a
	ret nz			;925c
	ret nz			;925d
	ret nz			;925e
pone_el_dibujo_del_lado:		; Enciende una bandera y elige el dibujo segun el lado
	ld a,001h		;925f   ; La bandera
	ld (0804fh),a		;9261
	call lee_el_lado		;9264   ; De que lado
	dec a			;9267
	ld a,04ah		;9268   ; Un dibujo...
	jr nz,L_926E		;926a
	ld a,034h		;926c   ; ...o el otro
L_926E:
	ld (0804bh),a		;926e
	call L_B488		;9271
	pop hl			;9274
	jp 0fd9ah		;9275   ; BIOS HOOKS - System hooks
tanda_del_bicho:		; Las cinco rutinas del bicho en cada paso
	call L_B3E8		;9278   ; El estado
	call L_897C		;927b
	call reparte_por_estado		;927e   ; El reparto por estado
	call elige_el_par_del_lado		;9281
	call mira_la_tecla_de_saltar		;9284   ; Y la tecla de saltar
	ret			;9287
reparte_por_estado:		; Cero no hace nada; el 7 y el 3 tienen rutina propia
	ld a,(0805bh)		;9288   ; El estado
	or a			;928b
	ret z			;928c   ; Cero: nada que hacer
	cp 007h		;928d   ; Estado 7
	jp z,vuelve_al_lado_contrario		;928f
	cp 003h		;9292   ; Estado 3; cualquier otro, a la general
	jp nz,L_A7C8		;9294
	ld a,(0805ch)		;9297   ; El sentido
	inc a			;929a   ; 0xFF quiere decir "ninguno"
	jr nz,anima_estado_tres		;929b
	ld a,034h		;929d   ; Dibujo de partida
	ld (0804bh),a		;929f
	ld a,001h		;92a2
	ld (0805ch),a		;92a4   ; Y sentido 1
anima_estado_tres:		; Cambia de dibujo cada dos pasos, banco 2, ciclo hasta 0x4A
	call casilla_del_otro_lado		;92a7
	dec (hl)			;92aa   ; Cuenta atras
	jr nz,L_92C0		;92ab
	ld (hl),002h		;92ad   ; Se recarga a 2
	dec hl			;92af
	ld b,(hl)			;92b0
	ld c,002h		;92b1   ; Banco 2
	ld a,010h		;92b3   ; Numero de sprite
	call pinta_un_sprite		;92b5
	ld a,b			;92b8
	cp 04ah		;92b9   ; Final del ciclo
	jr nz,L_92BF		;92bb
	ld a,034h		;92bd   ; Rebobina
L_92BF:
	ld (hl),a			;92bf
L_92C0:
	jp L_8A64		;92c0
vuelve_al_lado_contrario:		; Sentido -1 y su dibujo de partida
	ld a,(0805ch)		;92c3   ; El sentido
	inc a			;92c6
	jr z,anima_estado_siete		;92c7   ; Si ya era -1, solo hay que animar
	ld a,04ah		;92c9   ; Dibujo de partida de ese lado
	ld (0804bh),a		;92cb
	ld a,0ffh		;92ce   ; Sentido -1
	ld (0805ch),a		;92d0
anima_estado_siete:		; Igual, con el ciclo hasta 0x60
	call casilla_de_un_lado		;92d3
	dec (hl)			;92d6   ; Cuenta atras
	jr nz,L_92EC		;92d7
	ld (hl),002h		;92d9   ; Se recarga a 2
	dec hl			;92db
	ld b,(hl)			;92dc
	ld c,002h		;92dd   ; Banco 2
	ld a,010h		;92df   ; Numero de sprite
	call pinta_un_sprite		;92e1
	ld a,b			;92e4
	cp 060h		;92e5   ; Final del ciclo
	jr nz,L_92EB		;92e7
	ld a,04ah		;92e9   ; Rebobina
L_92EB:
	ld (hl),a			;92eb
L_92EC:
	jp L_89D6		;92ec

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x92ef..0x92f0  (1 bytes)
DATA_92EF:
	defb 000h	; 92ef

; ======================================================================
; CODIGO 0x92f0..0x9307  (23 bytes)
; ======================================================================


elige_el_par_del_lado:		; Segun el sentido, un par de sprites u otro
	jr nz,L_9303		;92f0   ; Solo si hace falta
	ld a,(0805ch)		;92f2   ; El sentido
	ld bc,03402h		;92f5   ; Un par...
	dec a			;92f8
	jr z,L_92FE		;92f9
	ld bc,04a02h		;92fb   ; ...o el otro
L_92FE:
	ld a,010h		;92fe
	call pinta_un_sprite		;9300
L_9303:
	call baja_hasta_el_suelo		;9303
	ret			;9306

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9307..0x9308  (1 bytes)
DATA_9307:
	defb 0c9h	; 9307

; ======================================================================
; CODIGO 0x9308..0x9357  (79 bytes)
; ======================================================================


L_9308:
	call 0fd9ah		;9308   ; BIOS HOOKS - System hooks
	ld hl,(08056h)		;930b
	ld de,00040h		;930e
	add hl,de			;9311
	call 0004ah		;9312   ; BIOS RDVRM - Reads the content of VRAM
	or a			;9315
	ret nz			;9316
	ret nz			;9317
	sub a			;9318
	ld (0804fh),a		;9319
	call L_9091		;931c
	ret			;931f
baja_hasta_el_suelo:		; Suma el paso de caida y se para en la fila 0x9D
	ld a,(0804ah)		;9320   ; La Y del jugador
	ld hl,08075h		;9323   ; El paso de caida
	add a,(hl)			;9326
	ld (0804ah),a		;9327   ; Baja
	cp 09dh		;932a   ; El suelo
	jr c,L_9332		;932c
	ld (hl),0ffh		;932e   ; Y el paso se marca como terminado
	jr L_9338		;9330
L_9332:
	cp 096h		;9332
	jr nc,L_9338		;9334
	ld (hl),001h		;9336
L_9338:
	call 0fd9ah		;9338   ; BIOS HOOKS - System hooks
	ret			;933b
traduce_el_estado:		; De estado a numero de dibujo
	ld a,(0805bh)		;933c   ; El estado
	or a			;933f
	jr z,L_9353		;9340   ; Cero: el dibujo cero
	cp 003h		;9342   ; Estado 3
	jr nz,L_934A		;9344
	ld a,001h		;9346   ; Le toca el dibujo 1
	jr L_9350		;9348
L_934A:
	cp 007h		;934a
	jr nz,L_9353		;934c
	ld a,0ffh		;934e
L_9350:
	ld (0805ch),a		;9350
L_9353:
	call 0fd9ah		;9353   ; BIOS HOOKS - System hooks
	ret			;9356

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9357..0x9358  (1 bytes)
DATA_9357:
	defb 0c9h	; 9357

; ======================================================================
; CODIGO 0x9358..0x938f  (55 bytes)
; ======================================================================


L_9358:
	call L_8930		;9358
	call 0004ah		;935b   ; BIOS RDVRM - Reads the content of VRAM
	cp 00eh		;935e
	jp z,L_9390		;9360
	cp 010h		;9363
	jr z,L_9380		;9365
	cp 012h		;9367
	jr z,L_9380		;9369
	ld de,00080h		;936b
	add hl,de			;936e
	call 0004ah		;936f   ; BIOS RDVRM - Reads the content of VRAM
	cp 00eh		;9372
	jp z,L_9390		;9374
	cp 010h		;9377
	jr z,L_9380		;9379
	cp 012h		;937b
	ret nz			;937d
	ret nz			;937e
	ret nz			;937f
L_9380:
	ld a,001h		;9380
	ld (0804dh),a		;9382
	ld a,0e6h		;9385
	ld (0804bh),a		;9387
	call 0fd9ah		;938a   ; BIOS HOOKS - System hooks
	pop hl			;938d
	ret			;938e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x938f..0x9390  (1 bytes)
DATA_938F:
	defb 000h	; 938f

; ======================================================================
; CODIGO 0x9390..0x939f  (15 bytes)
; ======================================================================


L_9390:
	ld a,002h		;9390
	ld (0804dh),a		;9392
	ld a,0dah		;9395
	ld (0804bh),a		;9397
	call 0fd9ah		;939a   ; BIOS HOOKS - System hooks
	pop hl			;939d
	ret			;939e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x939f..0x93a0  (1 bytes)
DATA_939F:
	defb 000h	; 939f

; ======================================================================
; CODIGO 0x93a0..0x93c6  (38 bytes)
; ======================================================================


reparte_por_lo_leido_2:		; El gemelo de 0x9008 en la otra fase
	call L_943A		;93a0   ; Lo que se ha pedido
	cp 005h		;93a3   ; El valor 5
	jp z,anima_al_jugador_d		;93a5
	cp 001h		;93a8   ; Y el 1; cualquier otro, a la general
	jp nz,L_90C8		;93aa
	call anima_al_jugador_c		;93ad
	ld a,(0805ah)		;93b0   ; La bandera de bloqueo
	or a			;93b3
	jr z,L_93BB		;93b4
L_93B6:
	ld hl,0804ah		;93b6
	dec (hl)			;93b9
	ret			;93ba
L_93BB:
	ld de,00040h		;93bb
	add hl,de			;93be
	call 0004ah		;93bf   ; BIOS RDVRM - Reads the content of VRAM
	or a			;93c2
	ret z			;93c3
	jr L_93B6		;93c4

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x93c6..0x93c8  (2 bytes)
DATA_93C6:
	defb 000h,000h	; 93c6

; ======================================================================
; CODIGO 0x93c8..0x944a  (130 bytes)
; ======================================================================


anima_al_jugador_c:		; Otra pareja de ciclo, esta hasta 0xE6
	ld hl,0804ch		;93c8
	dec (hl)			;93cb   ; Cuenta atras
	jr nz,L_93E8		;93cc
	ld (hl),003h		;93ce   ; Se recarga a 3
	ld a,(0804bh)		;93d0
	ld b,a			;93d3
	ld c,001h		;93d4   ; Banco 1
	ld a,010h		;93d6   ; Numero de sprite
	call pinta_un_sprite		;93d8
	call pinta_un_sprite		;93db
	ld a,b			;93de
	cp 0e6h		;93df   ; Final del ciclo
	jr nz,L_93E5		;93e1
	ld a,0dah		;93e3   ; Rebobina
L_93E5:
	ld (0804bh),a		;93e5
L_93E8:
	call L_8930		;93e8
	ret			;93eb
anima_al_jugador_d:		; Y el gemelo que va hacia atras
	ld hl,0804ch		;93ec
	dec (hl)			;93ef   ; Cuenta atras
	jr nz,L_940E		;93f0
	ld (hl),003h		;93f2   ; Se recarga a 3
	ld a,(0804bh)		;93f4
	ld b,a			;93f7
	ld c,001h		;93f8   ; Banco 1
	ld a,010h		;93fa   ; Numero de sprite
	call pinta_un_sprite		;93fc
	call pinta_un_sprite		;93ff
	ld a,b			;9402
	sub 008h		;9403   ; Retrocede un dibujo
	cp 0d6h		;9405   ; Principio del ciclo
	jr nz,L_940B		;9407
	ld a,0e2h		;9409   ; Rebobina
L_940B:
	ld (0804bh),a		;940b
L_940E:
	call L_8930		;940e
	ld a,(0805ah)		;9411
	or a			;9414
	jr z,mira_y_para		;9415
L_9417:
	ld hl,0804ah		;9417
	inc (hl)			;941a
	ret			;941b
mira_y_para:		; Si la casilla no deja pasar, borra el vector y elige el sprite parado
	ld de,00000h		;941c
	add hl,de			;941f
	call L_8A1C		;9420   ; Prueba la casilla
	jr nz,L_9417		;9423   ; Deja pasar: sigue
	sub a			;9425
	ld (0804dh),a		;9426   ; Sin rutina en el vector
	ld a,(0805ch)		;9429   ; El sentido
	dec a			;942c
	ld a,0aah		;942d   ; Dibujo parado para un sentido...
	jr z,L_9433		;942f
	ld a,004h		;9431   ; ...y para el otro
L_9433:
	ld (0804bh),a		;9433
	call 0fd9ah		;9436   ; BIOS HOOKS - System hooks
	ret			;9439
L_943A:
	ld a,(0804bh)		;943a
	cp 0dah		;943d
	jr nc,L_9443		;943f
	ld a,0dah		;9441
L_9443:
	ld (0804bh),a		;9443
	call L_8978		;9446
	ret			;9449

; ----------------------------------------------------------------------
; DATOS datos_944A: Treinta bytes sueltos entre dos rutinas. Ninguna
;   instruccion los apunta
;   0x944a..0x9468  (30 bytes)
DATA_datos_944A:
	defb 0cdh,08dh,090h,0c3h,090h,089h,03ah,04dh,080h,0b7h,0c0h,03ah,04fh,080h,0b7h	; 944a  ......:M...:O..
	defb 0c0h,001h,001h,0a6h,0c3h,085h,08ah,0b7h,0c8h,0c3h,0b2h,090h,000h,000h,000h	; 9459  ...............

; ======================================================================
; CODIGO 0x9468..0x949f  (55 bytes)
; ======================================================================


cambia_de_pantalla:		; Prepara la pantalla nueva y descomprime su mapa
	push af			;9468
	push hl			;9469
	call L_C06F		;946a   ; Deja la pantalla lista
	pop hl			;946d
	pop af			;946e
	call L_8193		;946f   ; Coge el mapa que toca
	call descomprime		;9472   ; Y lo descomprime
	jp apunta_la_ficha		;9475
L_9478:
	ld hl,(08072h)		;9478
	call salta_por_la_tabla_de_7034		;947b
	jr L_949B		;947e
salta_por_la_tabla_de_7034:		; Coge de la tabla de 0x7034 la rutina que toque y salta con PUSH DE / RET
	push hl			;9480
	push af			;9481
	ld a,l			;9482   ; El indice, en L
	ld hl,07034h		;9483   ; La tabla, en la RAM escondida
	call L_9490		;9486   ; Deja HL en la entrada
	ld e,(hl)			;9489   ; La direccion de la rutina
	inc hl			;948a
	ld d,(hl)			;948b
	pop af			;948c
	pop hl			;948d
	push de			;948e   ; PUSH y RET: asi se salta sin tocar mas registros
	ret			;948f
L_9490:
	rrca			;9490
	or a			;9491
	ret z			;9492
	ld de,00006h		;9493
L_9496:
	add hl,de			;9496
	dec a			;9497
	jr nz,L_9496		;9498
	ret			;949a
L_949B:
	ld (08076h),hl		;949b
	ret			;949e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x949f..0x94a0  (1 bytes)
DATA_949F:
	defb 000h	; 949f

; ======================================================================
; CODIGO 0x94a0..0x94c7  (39 bytes)
; ======================================================================


apunta_la_ficha:		; De la entrada de 0x8072 saca la ficha de 0x70C0
	ld hl,(08072h)		;94a0   ; La entrada en curso
	ld a,l			;94a3
	ld hl,070c0h		;94a4   ; La tabla de fichas de la RAM escondida
	rrca			;94a7   ; El numero, dividido por dos
	or a			;94a8
	jr z,L_94B2		;94a9
	ld de,00058h		;94ab   ; 0x58 = 88 bytes, una ficha
L_94AE:
	add hl,de			;94ae
	dec a			;94af
	jr nz,L_94AE		;94b0
L_94B2:
	call 0fd9ah		;94b2   ; BIOS HOOKS - System hooks
	ld de,0dfffh		;94b5
	ld bc,00058h		;94b8
	ldir		;94bb
	call salta_por_la_tabla_de_7030		;94bd
	call 0fd9ah		;94c0   ; BIOS HOOKS - System hooks
	call 0fd9ah		;94c3   ; BIOS HOOKS - System hooks
	ret			;94c6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x94c7..0x94c8  (1 bytes)
DATA_94C7:
	defb 0c9h	; 94c7

; ======================================================================
; CODIGO 0x94c8..0x94dd  (21 bytes)
; ======================================================================


L_94C8:
	sub a			;94c8
	ld (0fc9bh),a		;94c9
espera_una_tecla_o_stop:		; Se queda esperando hasta que se pulse algo
	ei			;94cc   ; Con interrupciones, que si no el teclado no se lee
	ld a,(0fc9bh)		;94cd   ; INTFLG, la bandera de STOP
	cp 003h		;94d0   ; El valor 3 es CTRL+STOP
	jp z,L_DAD0		;94d2   ; Reinicia el juego
	or a			;94d5
	jr z,espera_una_tecla_o_stop		;94d6   ; Nada pulsado: otra vuelta
	sub a			;94d8
	ld (0fc9bh),a		;94d9   ; Y se limpia la bandera
	ret			;94dc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x94dd..0x94e0  (3 bytes)
DATA_94DD:
	defb 000h,000h,000h	; 94dd

; ======================================================================
; CODIGO 0x94e0..0x94f7  (23 bytes)
; ======================================================================


salta_por_la_tabla_de_7030:		; Igual, pero la entrada trae ademas un dato de dos bytes
	ld hl,(08072h)		;94e0   ; El indice
	ld a,l			;94e3
	ld hl,07030h		;94e4   ; La tabla, en la RAM escondida
	call L_9490		;94e7
	ld e,(hl)			;94ea   ; La direccion de la rutina
	inc hl			;94eb
	ld d,(hl)			;94ec
	inc hl			;94ed
	ld c,(hl)			;94ee   ; Y el dato que la acompana
	inc hl			;94ef
	ld b,(hl)			;94f0
	ld (08078h),bc		;94f1   ; Que se guarda para ella
	push de			;94f5   ; PUSH y RET
	ret			;94f6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x94f7..0x94f8  (1 bytes)
DATA_94F7:
	defb 000h	; 94f7

; ======================================================================
; CODIGO 0x94f8..0x950f  (23 bytes)
; ======================================================================


prepara_al_perseguidor:		; Lo apaga, coloca dos sprites y monta su tabla
	call L_AE4A		;94f8
	ld a,000h		;94fb   ; Estado cero
	ld (0807ah),a		;94fd
	ld a,004h		;9500   ; Numero de sprite
	ld hl,09800h		;9502   ; Su posicion
	call L_8310		;9505   ; Los dos planos
	call L_8310		;9508
	call L_97A8		;950b
	ret			;950e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x950f..0x9510  (1 bytes)
DATA_950F:
	defb 000h	; 950f

; ======================================================================
; CODIGO 0x9510..0x96bc  (428 bytes)
; ======================================================================


L_9510:
	call 0fd9ah		;9510   ; BIOS HOOKS - System hooks
	ld hl,(08078h)		;9513
	push hl			;9516
	ret			;9517
aparicion_por_un_lado:		; Cada tantos pasos saca uno nuevo por el lado que corresponda
	call L_9728		;9518
	dec (hl)			;951b   ; Cuenta atras
	ret nz			;951c   ; Todavia no
	ld a,(0807ch)		;951d   ; El periodo, que se recarga
	ld (hl),a			;9520
	ld a,(0807ah)		;9521   ; Si ya hay uno...
	or a			;9524
	jr nz,L_9553		;9525   ; ...se atiende al que hay
	ld a,001h		;9527   ; Marca que hay uno
	ld (0807eh),a		;9529
	call L_9747		;952c
	ld a,r		;952f   ; El registro de refresco de la CPU, que hace de dado
	add a,a			;9531   ; Se mira solo el bit de arriba
	jp m,L_9767		;9532
	ld a,(0805bh)		;9535   ; Segun el estado, sale por un lado o por otro
	cp 003h		;9538
	jr z,L_954D		;953a
	cp 007h		;953c
	jr z,L_9550		;953e
	ld a,(08049h)		;9540   ; Toma la X del jugador
	ld (0807fh),a		;9543
	ld a,098h		;9546   ; Y una Y fija
	ld (08080h),a		;9548
	jr L_9556		;954b
L_954D:
	jp L_9780		;954d
L_9550:
	jp L_9770		;9550
L_9553:
	jp L_9580		;9553
L_9556:
	call 0fd9ah		;9556   ; BIOS HOOKS - System hooks
	ld a,r		;9559
	add a,a			;955b
	jp m,L_9570		;955c
L_955F:
	ld a,0ffh		;955f
	ld (08081h),a		;9561
	ld a,09ah		;9564
	ld (0807dh),a		;9566
L_9569:
	ld a,002h		;9569
	ld (08082h),a		;956b
	jr L_957D		;956e
L_9570:
	ld a,001h		;9570
	ld (08081h),a		;9572
	ld a,092h		;9575
	ld (0807dh),a		;9577
	jp L_9569		;957a
L_957D:
	jp 0fd9ah		;957d   ; BIOS HOOKS - System hooks
L_9580:
	dec a			;9580
	jp nz,acerca_al_perseguidor		;9581
	call pinta_al_perseguidor_2		;9584
	jr cuenta_atras_larga		;9587
pinta_al_perseguidor_2:		; Sube sus dos planos, el segundo dieciseis pixeles mas abajo
	ld hl,(0807fh)		;9589   ; Su posicion
	ld a,00ch		;958c   ; Numero de sprite
	call L_8310		;958e
	ex af,af'			;9591
	ld a,010h		;9592   ; Dieciseis pixeles entre los dos planos
	add a,h			;9594
	call L_9630		;9595
	ld a,(08081h)		;9598   ; Segun el estado...
	dec a			;959b
	ld bc,09802h		;959c   ; ...un par de sprites...
	jr nz,pinta_al_que_persigue		;959f
	ld bc,09002h		;95a1   ; ...o el otro
pinta_al_que_persigue:		; Sube sus dos planos de sprite y avanza su animacion
	ld a,00ch		;95a4   ; Numero de sprite en el VDP
	call pinta_un_sprite		;95a6   ; Primer plano de color
	ex af,af'			;95a9
	ld a,(0807dh)		;95aa   ; El dibujo en curso
	ld b,a			;95ad
	ex af,af'			;95ae
	call pinta_un_sprite		;95af   ; Segundo plano
	ld hl,0807eh		;95b2   ; Cuenta atras del cambio de dibujo
	dec (hl)			;95b5
	ret nz			;95b6   ; Todavia no
	ld (hl),002h		;95b7   ; Se recarga a 2
	ld hl,08082h		;95b9
	ld a,(0807dh)		;95bc
	add a,(hl)			;95bf   ; Avanza el dibujo
	cp 092h		;95c0   ; Y si llega a uno de los cuatro finales de ciclo...
	jr z,da_la_vuelta		;95c2
	cp 096h		;95c4
	jr z,da_la_vuelta		;95c6
	cp 09ah		;95c8
	jr z,da_la_vuelta		;95ca
	cp 09eh		;95cc
	jr nz,L_95E0		;95ce   ; ...rebobina
da_la_vuelta:		; Guarda el dibujo y cambia el paso de signo
	ld (0807dh),a		;95d0   ; El dibujo nuevo
	ld a,(hl)			;95d3
	cp 0feh		;95d4   ; Si el paso era -2...
	ld a,002h		;95d6   ; ...pasa a +2...
	jr z,L_95DC		;95d8
	ld a,0feh		;95da   ; ...y al reves
L_95DC:
	ld (hl),a			;95dc
	jp 0fd9ah		;95dd   ; BIOS HOOKS - System hooks
L_95E0:
	nop			;95e0
	ld (0807dh),a		;95e1
	call 0fd9ah		;95e4   ; BIOS HOOKS - System hooks
	ret			;95e7
cuenta_atras_larga:		; Descuenta hasta 0x78 y entonces pasa al estado 2
	ld hl,08080h		;95e8
	dec (hl)			;95eb   ; Uno menos
	ld a,(hl)			;95ec
	cp 078h		;95ed   ; El limite
	ret nz			;95ef
	ld a,002h		;95f0   ; Estado 2
	ld (0807ah),a		;95f2
	call 0fd9ah		;95f5   ; BIOS HOOKS - System hooks | Vector de sonido
	ld a,078h		;95f8   ; Y se recarga la cuenta
	ld (08080h),a		;95fa
	jp L_9750		;95fd
acerca_al_perseguidor:		; Con el estado 1, lo trae hacia el jugador si esta en rango
	dec a			;9600   ; Solo si el estado es 1
	jp nz,L_9668		;9601
	call 0fd9ah		;9604   ; BIOS HOOKS - System hooks | Vector de sonido
	ld a,(08081h)		;9607   ; El sentido
	inc a			;960a
	jp z,mira_si_esta_a_tiro		;960b   ; 0xFF quiere decir "ninguno"
	ld a,(0807fh)		;960e   ; Su posicion
	ld hl,08049h		;9611   ; La del jugador
	cp 0f8h		;9614   ; Por encima de 0xF8 no vale
	jp nc,L_9790		;9616
	sub 050h		;9619   ; Ochenta pixeles de ventana
	cp (hl)			;961b
	jp nc,L_9790		;961c
	add a,051h		;961f
L_9621:
	ld (0807fh),a		;9621
	call pinta_al_perseguidor_2		;9624
	call L_96E8		;9627
	call 0fd9ah		;962a   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;962d   ; BIOS HOOKS - System hooks
L_9630:
	ld h,a			;9630
	ex af,af'			;9631
	call L_8310		;9632
	jp 0fd9ah		;9635   ; BIOS HOOKS - System hooks
mira_si_toca_al_perseguidor:		; Compara la posicion del jugador con la del perseguidor y, si coinciden, lo despierta
	call L_A120		;9638
	nop			;963b
	nop			;963c
	ld a,(08052h)		;963d   ; La X del jugador
	ld hl,0807fh		;9640   ; La X del perseguidor
	sub 010h		;9643   ; Dieciseis pixeles por delante
	cp (hl)			;9645
	ret nc			;9646   ; Mas a la derecha: no toca
	add a,020h		;9647   ; Treinta y dos de ventana
	cp (hl)			;9649
	ret c			;964a   ; Mas a la izquierda: tampoco
	inc hl			;964b
	ld a,(08053h)		;964c   ; La Y
	sub 020h		;964f
	cp (hl)			;9651   ; Misma comprobacion en vertical, con ventana de 48
	ret nc			;9652
	add a,030h		;9653
	cp (hl)			;9655
	ret c			;9656
	call L_A0D8		;9657
	ld a,004h		;965a   ; Estado 4: tocado
	ld (0807ah),a		;965c
	ld a,096h		;965f   ; Y el dibujo con el que empieza esa animacion
	ld (0807dh),a		;9661
	call L_A038		;9664
	ret			;9667
L_9668:
	dec a			;9668
	jp z,sube_hasta_el_tope		;9669
	dec a			;966c
	jp nz,L_96C0		;966d
	call 0fd9ah		;9670   ; BIOS HOOKS - System hooks
	ld a,(0807dh)		;9673
	ld b,a			;9676
	ld c,001h		;9677
	ld a,00ch		;9679
	call pinta_un_sprite		;967b
	dec b			;967e
	dec b			;967f
	call pinta_un_sprite		;9680
	ld a,b			;9683
	ld (0807dh),a		;9684
	cp 0a6h		;9687
	jp nz,0fd9ah		;9689   ; BIOS HOOKS - System hooks
	sub a			;968c
	ld (0807ah),a		;968d
	call 0fd9ah		;9690   ; BIOS HOOKS - System hooks
	ld hl,0807ch		;9693
	dec (hl)			;9696
	jr nz,L_969B		;9697
	ld (hl),002h		;9699
L_969B:
	call L_A880		;969b
	ld hl,(08080h)		;969e
	ld a,023h		;96a1
	call 0004dh		;96a3   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;96a6
	inc a			;96a7
	call 0004dh		;96a8   ; BIOS WRTVRM - Writes data in VRAM
	ld (08080h),hl		;96ab
	ld a,005h		;96ae
	ld (0807ah),a		;96b0
	ld a,020h		;96b3
	ld (08082h),a		;96b5
	call L_96D8		;96b8
	ret			;96bb

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x96bc..0x96c0  (4 bytes)
DATA_96BC:
	defb 000h,000h,000h,000h	; 96bc

; ======================================================================
; CODIGO 0x96c0..0x96d7  (23 bytes)
; ======================================================================


L_96C0:
	ld hl,08082h		;96c0
	dec (hl)			;96c3
	ret nz			;96c4
	sub a			;96c5
	ld (0807ah),a		;96c6
	ld hl,(08080h)		;96c9
	call 0004dh		;96cc   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;96cf
	call 0004dh		;96d0   ; BIOS WRTVRM - Writes data in VRAM
	call 0fd9ah		;96d3   ; BIOS HOOKS - System hooks
	ret			;96d6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x96d7..0x96d8  (1 bytes)
DATA_96D7:
	defb 000h	; 96d7

; ======================================================================
; CODIGO 0x96d8..0x96e7  (15 bytes)
; ======================================================================


L_96D8:
	ld hl,0c2c2h		;96d8
	ld a,00ch		;96db
	call L_8310		;96dd
	call L_8310		;96e0
	call 0fd9ah		;96e3   ; BIOS HOOKS - System hooks
	ret			;96e6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x96e7..0x96e8  (1 bytes)
DATA_96E7:
	defb 000h	; 96e7

; ======================================================================
; CODIGO 0x96e8..0x96ef  (7 bytes)
; ======================================================================


L_96E8:
	call L_96F0		;96e8
	call L_9F70		;96eb
	ret			;96ee

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x96ef..0x96f0  (1 bytes)
DATA_96EF:
	defb 000h	; 96ef

; ======================================================================
; CODIGO 0x96f0..0x972f  (63 bytes)
; ======================================================================


L_96F0:
	ld hl,(0807fh)		;96f0
	call mira_si_pisa_la_casilla		;96f3
	jr L_9718		;96f6
mira_si_pisa_la_casilla:		; Con la casilla en HL, mira si el jugador esta encima y sube su estado a 4
	ld a,(0804ah)		;96f8   ; La Y del jugador
	sub 010h		;96fb   ; Dieciseis pixeles de margen por arriba
	cp h			;96fd
	ret nc			;96fe   ; Por encima: no la pisa
	add a,020h		;96ff   ; Treinta y dos de ventana
	cp h			;9701
	ret c			;9702
	ld a,(08049h)		;9703   ; Y ahora la X
	sub 008h		;9706
	cp l			;9708
	ret nc			;9709
	add a,018h		;970a
	cp l			;970c
	ret c			;970d
	call L_BC08		;970e   ; La ficha de esa casilla
	ld a,(hl)			;9711
	cp 004h		;9712   ; Si ya iba por 4 o mas, se deja como esta
	ret c			;9714
	ld (hl),004h		;9715   ; Si no, a 4
	ret			;9717
L_9718:
	ld hl,(0807fh)		;9718
	ld a,h			;971b
	sub 010h		;971c
	ld h,a			;971e
	call mira_si_pisa_la_casilla		;971f
	call 0fd9ah		;9722   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;9725   ; BIOS HOOKS - System hooks
L_9728:
	call L_96E8		;9728
	ld hl,0807bh		;972b
	ret			;972e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x972f..0x9730  (1 bytes)
DATA_972F:
	defb 000h	; 972f

; ======================================================================
; CODIGO 0x9730..0x9746  (22 bytes)
; ======================================================================


mira_si_esta_a_tiro:		; Rango de 0x50 pixeles a un lado
	ld a,(0807fh)		;9730   ; Su posicion
	ld hl,08049h		;9733   ; La del jugador
	cp 008h		;9736   ; Por debajo de ocho, fuera
	jp c,L_9790		;9738
	add a,050h		;973b   ; Ochenta pixeles de rango
	cp (hl)			;973d
	jp c,L_9790		;973e
	sub 051h		;9741   ; Y se ajusta la posicion
	jp L_9621		;9743

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9746..0x9747  (1 bytes)
DATA_9746:
	defb 000h	; 9746

; ======================================================================
; CODIGO 0x9747..0x9763  (28 bytes)
; ======================================================================


L_9747:
	ld (0807ah),a		;9747
	ld a,098h		;974a
	ld (08080h),a		;974c
	ret			;974f
L_9750:
	ld a,r		;9750
	add a,a			;9752
	jp m,0fd9ah		;9753   ; BIOS HOOKS - System hooks
	ld a,(08049h)		;9756
	ld hl,0807fh		;9759
	cp (hl)			;975c
	jp c,L_9570		;975d
	jp L_955F		;9760

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9763..0x9767  (4 bytes)
DATA_9763:
	defb 000h,000h,000h,000h	; 9763

; ======================================================================
; CODIGO 0x9767..0x977e  (23 bytes)
; ======================================================================


L_9767:
	ld a,(0fca2h)		;9767
	ld (0807fh),a		;976a
	jp L_9556		;976d
L_9770:
	ld a,(08049h)		;9770
	call 0fd9ah		;9773   ; BIOS HOOKS - System hooks
	sub 018h		;9776
	ld (0807fh),a		;9778
	jp L_9570		;977b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x977e..0x9780  (2 bytes)
DATA_977E:
	defb 000h,000h	; 977e

; ======================================================================
; CODIGO 0x9780..0x978e  (14 bytes)
; ======================================================================


L_9780:
	ld a,(08049h)		;9780
	call 0fd9ah		;9783   ; BIOS HOOKS - System hooks
	add a,018h		;9786
	ld (0807fh),a		;9788
	jp L_955F		;978b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x978e..0x9790  (2 bytes)
DATA_978E:
	defb 000h,000h	; 978e

; ======================================================================
; CODIGO 0x9790..0x97b7  (39 bytes)
; ======================================================================


L_9790:
	ld a,003h		;9790
	ld (0807ah),a		;9792
	jp 0fd9ah		;9795   ; BIOS HOOKS - System hooks
sube_hasta_el_tope:		; Sube el contador y, al llegar a 0x98, apaga
	call pinta_al_perseguidor_2		;9798   ; Lo pinta
	ld hl,08080h		;979b
	inc (hl)			;979e   ; Uno mas
	ld a,(hl)			;979f
	cp 098h		;97a0   ; El tope
	ret nz			;97a2
	sub a			;97a3
	ld (0807ah),a		;97a4   ; Estado cero
	ret			;97a7
L_97A8:
	ld h,0a8h		;97a8
	call L_8310		;97aa
	call L_8310		;97ad
	call 0fd9ah		;97b0   ; BIOS HOOKS - System hooks
	call 0fd9ah		;97b3   ; BIOS HOOKS - System hooks
	ret			;97b6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x97b7..0x97b8  (1 bytes)
DATA_97B7:
	defb 0c9h	; 97b7

; ======================================================================
; CODIGO 0x97b8..0x98ff  (327 bytes)
; ======================================================================


L_97B8:
	ld a,004h		;97b8
	ld hl,0c1c1h		;97ba
	ld b,006h		;97bd
L_97BF:
	call L_8310		;97bf
	djnz L_97BF		;97c2
	add a,004h		;97c4
	ld b,006h		;97c6
L_97C8:
	call L_8310		;97c8
	djnz L_97C8		;97cb
	jp L_9CF8		;97cd
L_97D0:
	call L_A7B8		;97d0
	ld hl,01b43h		;97d3
	ld a,00eh		;97d6
	call 0004dh		;97d8   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00004h		;97db
	add hl,de			;97de
	ld a,00fh		;97df
	call 0004dh		;97e1   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;97e4
	ld a,00eh		;97e5
	call 0004dh		;97e7   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;97ea
	ld a,00fh		;97eb
	call 0004dh		;97ed   ; BIOS WRTVRM - Writes data in VRAM
	call L_9B00		;97f0
	call 0fd9ah		;97f3   ; BIOS HOOKS - System hooks
	ld a,(08049h)		;97f6
	cp 078h		;97f9
	ld d,001h		;97fb
	jr c,corre_hasta_el_borde		;97fd
	ld d,0ffh		;97ff
corre_hasta_el_borde:		; Avanza al jugador de golpe hasta la columna 0x78
	exx			;9801
	call pinta_al_jugador		;9802   ; Lo pinta donde este
	ld a,l			;9805
	cp 078h		;9806   ; El borde
	jr z,L_9818		;9808
	exx			;980a
	add a,d			;980b   ; Avanza el paso
	ld (08049h),a		;980c
	ld bc,00300h		;980f   ; Una espera corta
	call espera		;9812
	jp corre_hasta_el_borde		;9815   ; Y otra vuelta
L_9818:
	ld a,004h		;9818
	ld hl,00000h		;981a
	call L_8310		;981d
	call L_8310		;9820
	ld hl,(08049h)		;9823
	call L_8310		;9826
	ld a,010h		;9829
	add a,h			;982b
	ld h,a			;982c
	ld a,00ah		;982d
	call L_8310		;982f
	ld a,010h		;9832
	ld bc,03401h		;9834
	call pinta_un_sprite		;9837
	call pinta_un_sprite		;983a
	call 0fd9ah		;983d   ; BIOS HOOKS - System hooks
	call 0fd9ah		;9840   ; BIOS HOOKS - System hooks
	ld bc,09601h		;9843
anima_hasta_el_final:		; Repite el par de sprites hasta llegar al dibujo 0xA6
	ld a,008h		;9846   ; Numero de sprite
	call pinta_un_sprite		;9848   ; Primer plano
	dec b			;984b
	dec b			;984c
	call pinta_un_sprite		;984d   ; Segundo plano, dos registros mas atras
	ld a,b			;9850
	cp 0a6h		;9851   ; El dibujo final
	jr z,monta_la_escena_final		;9853
	exx			;9855
	ld bc,03000h		;9856   ; Espera entre dibujo y dibujo
	call espera		;9859
	exx			;985c
	jp anima_hasta_el_final		;985d
monta_la_escena_final:		; Espera, coloca dos sprites fijos y prepara los contadores
	ld bc,03000h		;9860   ; Una espera
	call espera		;9863
	ld a,008h		;9866   ; Numero de sprite
	ld hl,00074h		;9868   ; Uno en la fila 0x74...
	call L_8310		;986b
	ld l,084h		;986e   ; ...y otro en la 0x84
	call L_8310		;9870
	ld a,(0804ah)		;9873   ; La Y del jugador
	sub 012h		;9876   ; Dieciocho pixeles mas arriba
	ld d,a			;9878
	sub a			;9879
	ld (0807fh),a		;987a
	ld a,01eh		;987d   ; Treinta pasos de cuenta
	ld (08080h),a		;987f
	ld a,002h		;9882
	ld (08081h),a		;9884   ; Y estado 2
L_9887:
	call anima_lo_que_cae		;9887
	jr sube_una_fila_y_compara		;988a
anima_lo_que_cae:		; Espera, mueve el sprite que cae y le da la vuelta al llegar al final del ciclo
	push de			;988c
	ld bc,00800h		;988d   ; Cuenta de la espera
	call espera		;9890
	ld hl,08048h		;9893   ; Cuenta atras del cambio de dibujo
	dec (hl)			;9896
	jr nz,coloca_dos_sprites		;9897
	ld (hl),002h		;9899   ; Se recarga a 2
	ld a,(08080h)		;989b   ; El dibujo en curso
	ld b,a			;989e
	ld c,001h		;989f   ; Banco 1
	ld a,008h		;98a1   ; Numero de sprite en el VDP
	call pinta_un_sprite		;98a3   ; Primer plano de color
	dec b			;98a6
	dec b			;98a7
	call pinta_un_sprite		;98a8   ; Segundo plano, dos registros mas atras
	ld a,(08081h)		;98ab
	dec b			;98ae
	dec b			;98af
	add a,b			;98b0
	cp 01ch		;98b1   ; Los dos finales de ciclo
	jr z,L_98BE		;98b3
	cp 024h		;98b5
	jr nz,L_98C6		;98b7
	ld hl,0fe22h		;98b9   ; Al llegar, rebobina
	jr L_98C1		;98bc
L_98BE:
	ld hl,0021eh		;98be
L_98C1:
	ld (08080h),hl		;98c1
	jr coloca_dos_sprites		;98c4
L_98C6:
	ld (08080h),a		;98c6
coloca_dos_sprites:		; Deja dos sprites en la columna 0x70 y 0x82
	ld hl,(0807eh)		;98c9   ; La posicion
	ld l,070h		;98cc   ; Columna 0x70
	ld a,008h		;98ce   ; Numero de sprite
	call L_8310		;98d0
	ld l,082h		;98d3   ; Y columna 0x82
	call L_8310		;98d5
	pop de			;98d8
	ret			;98d9
L_98DA:
	call L_9AFD		;98da
	jp L_A785		;98dd
sube_una_fila_y_compara:		; Sube una fila y mira si ha llegado
	nop			;98e0
	inc h			;98e1   ; Una fila mas
	ld a,h			;98e2
	nop			;98e3
	cp d			;98e4   ; Contra el limite
	ld (0807fh),a		;98e5   ; Se guarda
	jp nz,L_9887		;98e8
baja_mientras_pueda:		; Va bajando y pintando hasta agotar la cuenta
	call anima_lo_que_cae		;98eb   ; Anima lo que cae
	dec h			;98ee   ; Una fila menos
	jr z,$+17		;98ef
	ld a,h			;98f1
	ld (0807fh),a		;98f2   ; Se guarda
	ld hl,0804ah		;98f5   ; La cuenta
	dec (hl)			;98f8
	call pinta_al_jugador		;98f9   ; Y se repinta al jugador
	jp baja_mientras_pueda		;98fc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x98ff..0x9900  (1 bytes)
DATA_98FF:
	defb 000h	; 98ff

; ======================================================================
; CODIGO 0x9900..0x990f  (15 bytes)
; ======================================================================


espera_animando:		; Repite la animacion hasta agotar la cuenta
	call anima_lo_que_cae		;9900   ; Anima lo que cae
	call pinta_al_jugador		;9903   ; Y al jugador
	ld hl,0804ah		;9906   ; La cuenta
	dec (hl)			;9909
	jr nz,espera_animando		;990a   ; Otra vuelta
	jp L_9BC0		;990c

; ----------------------------------------------------------------------
; DATOS rotulo_game_over: " GAME" en 0x9910 y "OVER " en 0x9916, las dos
;   mitades del cartel que escribe 0x9BFE
;   0x990f..0x991c  (13 bytes)
DATA_rotulo_game_over:
	defb 000h	; 990f
	defb 020h,047h,041h,04dh,045h	; 9910
	defb 000h,04fh,056h,045h,052h,020h	; 9915
	defb 0ffh	; 991b

; ======================================================================
; CODIGO 0x991c..0x9925  (9 bytes)
; ======================================================================


L_991C:
	ld (hl),000h		;991c
	ret			;991e
L_991F:
	dec hl			;991f
	dec hl			;9920
	dec hl			;9921
	ld (hl),000h		;9922
	ret			;9924

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9925..0x9928  (3 bytes)
DATA_9925:
	defb 000h,000h,000h	; 9925

; ======================================================================
; CODIGO 0x9928..0x9a3f  (279 bytes)
; ======================================================================


opcode_seis_del_guion:		; Mueve y comprueba, y si no esta ocupado lo arranca
	call copia_el_guion		;9928   ; Lo mueve
	call mira_si_lo_pisa		;992b   ; Mira si el jugador lo pisa
	ld hl,080aeh		;992e   ; El estado
	ld a,(hl)			;9931
	or a			;9932
	jr nz,anima_el_marcador		;9933   ; Ya esta en marcha
arranca_con_su_par:		; Estado 1 y el par de sprites del lado que toque
	ld (hl),001h		;9935   ; Estado 1
	ld a,(080b1h)		;9937   ; El lado
	dec a			;993a
	ld bc,04c01h		;993b   ; Un par...
	jr z,L_9943		;993e
	ld bc,05a01h		;9940   ; ...o el otro
L_9943:
	call elige_el_numero_de_sprite_2		;9943
	call pinta_un_sprite		;9946
	call L_AFDB		;9949
	jp L_AB3A		;994c
anima_el_marcador:		; Cuenta atras y alterna dos dibujos del marcador
	ld hl,080ach		;994f
	dec (hl)			;9952   ; Cuenta atras
	jp nz,L_AB3A		;9953
	ld a,(080adh)		;9956   ; El periodo, que se recarga
	ld (hl),a			;9959
	ld hl,080aeh		;995a   ; El interruptor del parpadeo
	ld a,(hl)			;995d
	dec a			;995e
	jr nz,estado_uno_del_bicho		;995f
	ld (hl),002h		;9961   ; Se recarga a 2
	dec hl			;9963
	dec hl			;9964
	ld (hl),040h		;9965   ; Y se pone el otro dibujo
	ld a,(080b1h)		;9967
	dec a			;996a
	ld bc,04e01h		;996b   ; Un par de sprites...
	jr z,L_9973		;996e
	ld bc,05c01h		;9970   ; ...o el otro
L_9973:
	jr L_9943		;9973
estado_uno_del_bicho:		; Si no esta ocupado, mira si el jugador esta a tiro
	dec a			;9975   ; Solo si el estado es 1
	jp nz,estado_dos_bis		;9976
	ld a,(080b5h)		;9979   ; Una bandera de ocupado
	or a			;997c
	jp nz,estado_uno_bis		;997d   ; Ocupado: a la otra rutina
	call mira_la_franja_y_arranca		;9980
	dec a			;9983   ; Si devuelve 1, se acabo
	jp z,mira_si_lo_alcanza		;9984
	ld a,(080afh)		;9987   ; Su posicion
	ld hl,08049h		;998a   ; La del jugador
	sub 018h		;998d   ; Veinticuatro pixeles de margen
	cp (hl)			;998f
	jp c,L_9A4B		;9990
	ld a,060h		;9993
pone_estado_uno:		; Guarda el dibujo y arranca los contadores
	ld (080b3h),a		;9995   ; El dibujo
	ld a,001h		;9998
	ld (080b5h),a		;999a   ; Estado 1
	ld (080b7h),a		;999d   ; Cuenta a uno
	ld a,006h		;99a0
	ld (080b6h),a		;99a2   ; Y seis pasos
	jp L_9A40		;99a5
estado_uno_bis:		; Tres dibujos y, si el contador esta a cero, pasa al estado 3
	dec a			;99a8   ; Solo si el estado es 1
	jp nz,estado_dos_del_bicho		;99a9
	call avanza_y_topa		;99ac   ; Tres pasos de dibujo
	call L_9B28		;99af
	call pinta_y_vuelve		;99b2
	ld a,(080b6h)		;99b5   ; El contador de fase
	or a			;99b8
	jp nz,pinta_y_vuelve		;99b9   ; Si no es cero, no cambia de estado
	ld a,003h		;99bc   ; Estado 3
	ld (080b5h),a		;99be
	ld a,010h		;99c1   ; Y dieciseis pasos de cuenta
	ld (080b7h),a		;99c3
	jp L_AB3A		;99c6
estado_dos_del_bicho:		; Tres rutinas de dibujo y, si el contador llega a 7, un salto de seis atras
	dec a			;99c9   ; Solo si el estado es 2
	dec a			;99ca
	jr nz,avanza_dos_y_cicla		;99cb
	call avanza_y_topa		;99cd   ; Tres pasos de dibujo seguidos
	call avanza_si_toca		;99d0
	call pinta_y_vuelve		;99d3
	ld a,(080b6h)		;99d6   ; El contador de fase
	cp 007h		;99d9   ; Solo el valor 7 sigue
	jp nz,pinta_y_vuelve		;99db
	ld hl,080b0h		;99de
	ld a,0fah		;99e1   ; Suma 0xFA, o sea resta seis
	add a,(hl)			;99e3
	ld (hl),a			;99e4
	call L_AFDB		;99e5
	ld a,004h		;99e8   ; Y pasa al estado 4
	ld (080b5h),a		;99ea
	jp L_AB3A		;99ed
avanza_dos_y_cicla:		; Sube el dibujo de dos en dos entre 0x5A y 0x68
	call pinta_y_vuelve		;99f0
	ld a,(080b3h)		;99f3   ; El dibujo en curso
	add a,002h		;99f6   ; Dos mas
	ld (080b3h),a		;99f8
	cp 05ah		;99fb   ; Un final de ciclo...
	jr z,para_y_retrocede		;99fd
	cp 068h		;99ff   ; ...y el otro
	jp nz,L_AB3A		;9a01
para_y_retrocede:		; Apaga la fase, retrocede ocho y da una cuenta larga
	ld a,000h		;9a04   ; Fase cero
	ld (080b5h),a		;9a06
	ld a,(080b3h)		;9a09   ; El dibujo en curso
	sub 008h		;9a0c   ; Ocho atras
	ld (080b3h),a		;9a0e
	ld a,040h		;9a11   ; Sesenta y cuatro pasos de cuenta
	ld (080ach),a		;9a13
	jp L_AB3A		;9a16
mira_si_lo_alcanza:		; Veinticuatro pixeles de margen sobre la X del jugador
	ld a,(080afh)		;9a19   ; Su posicion
	ld hl,08049h		;9a1c   ; La del jugador
	add a,018h		;9a1f   ; Veinticuatro de margen
	cp (hl)			;9a21
	jr nc,$+41		;9a22
	ld a,052h		;9a24   ; Dibujo de alcance
	jp pone_estado_uno		;9a26
elige_el_dibujo_del_tramo:		; Segun el tramo, 0x50 o 0x5E
	call en_que_tramo		;9a29   ; En que tramo esta
	ld (080b1h),a		;9a2c   ; Se guarda
	dec a			;9a2f
	ld a,050h		;9a30   ; Un dibujo...
	jr z,L_9A36		;9a32
	ld a,05eh		;9a34   ; ...o el otro
L_9A36:
	ld (080b3h),a		;9a36
	call avanza_y_topa		;9a39
	jp pinta_y_vuelve		;9a3c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9a3f..0x9a40  (1 bytes)
DATA_9A3F:
	defb 000h	; 9a3f

; ======================================================================
; CODIGO 0x9a40..0x9a56  (22 bytes)
; ======================================================================


L_9A40:
	ld a,(080adh)		;9a40
	ld a,003h		;9a43
	ld (080adh),a		;9a45
	jp elige_el_dibujo_del_tramo		;9a48
L_9A4B:
	ld a,(080adh)		;9a4b
	ld a,00ah		;9a4e
	ld (080adh),a		;9a50
	jp elige_el_dibujo_del_tramo		;9a53

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9a56..0x9a58  (2 bytes)
DATA_9A56:
	defb 000h,000h	; 9a56

; ======================================================================
; CODIGO 0x9a58..0x9add  (133 bytes)
; ======================================================================


mira_la_franja_y_arranca:		; Si esta en la franja arranca; si no, devuelve el tramo
	call esta_en_la_franja		;9a58   ; Mira la franja
	ld a,(080b1h)		;9a5b   ; El tramo
	ret z			;9a5e   ; Dentro: se devuelve el tramo
	pop hl			;9a5f   ; Se quita la vuelta de la pila
	ld hl,080ach		;9a60
	ld (hl),000h		;9a63   ; Cuenta a cero
	inc hl			;9a65
	inc hl			;9a66
	jp arranca_con_su_par		;9a67
mira_si_lo_pisa:		; Pinta y, si nada lo impide, comprueba que el jugador este encima
	call L_9AC2		;9a6a
	ld hl,(080afh)		;9a6d   ; Su posicion
	call L_ADB4		;9a70
	ld a,(080a9h)		;9a73   ; La bandera de ocupado
	or a			;9a76
	ret nz			;9a77   ; Ocupado: no se mira nada
	ld hl,(080afh)		;9a78
	call mira_si_pisa_la_casilla		;9a7b   ; Mira si el jugador lo pisa
	call L_BC10		;9a7e
	nop			;9a81   ; Un NOP
	ret nz			;9a82
mira_la_ficha_y_arranca:		; Solo con la ficha por debajo de 4
	ld a,(hl)			;9a83   ; La ficha de la casilla
	cp 004h		;9a84   ; De 4 para arriba no vale
	ret nc			;9a86
	call L_A8F8		;9a87
	ld a,(080b1h)		;9a8a   ; El tramo
	call L_8193		;9a8d
	ld (0805ch),a		;9a90   ; Se guarda como sentido
	call L_9ABA		;9a93
	jp L_AB3A		;9a96
estado_dos_bis:		; Con el estado 2 y la fase 5, pinta el sprite 0x92
	dec a			;9a99   ; Solo si el estado es 2
	dec a			;9a9a
	jr nz,L_9AB7		;9a9b
	call pinta_y_cicla_2		;9a9d
	ld a,(080aeh)		;9aa0   ; La fase
	cp 005h		;9aa3   ; Solo la 5 sigue
	jp nz,L_AB3A		;9aa5
	ld bc,09201h		;9aa8   ; El sprite y el banco
	call elige_el_numero_de_sprite_2		;9aab   ; Numero de sprite
	call pinta_un_sprite		;9aae
	call L_9ACA		;9ab1
	jp L_AB3A		;9ab4
L_9AB7:
	jp coloca_el_par_c2c2_2		;9ab7
L_9ABA:
	ld a,030h		;9aba
	ld (080aah),a		;9abc
	jp 0fd9ah		;9abf   ; BIOS HOOKS - System hooks
L_9AC2:
	ld a,(080aeh)		;9ac2
	cp 002h		;9ac5
	ret z			;9ac7
	pop hl			;9ac8
	ret			;9ac9
L_9ACA:
	ld bc,001f4h		;9aca
	jr espera_pintando		;9acd
L_9ACF:
	ld bc,003e8h		;9acf
espera_pintando:		; Repite hasta agotar BC
	call L_A861		;9ad2   ; Un paso
	dec bc			;9ad5   ; Uno menos
	ld a,b			;9ad6
	or c			;9ad7
	jr nz,espera_pintando		;9ad8   ; Hasta agotar la cuenta
	jp L_A870		;9ada

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9add..0x9ae0  (3 bytes)
DATA_9ADD:
	defb 000h,000h,000h	; 9add

; ======================================================================
; CODIGO 0x9ae0..0x9b26  (70 bytes)
; ======================================================================


L_9AE0:
	ld a,r		;9ae0
	cp 034h		;9ae2
	jp c,L_B219		;9ae4
	jp pasa_al_estado_tres		;9ae7
L_9AEA:
	ld hl,080b0h		;9aea
	ld a,(08053h)		;9aed
	cp (hl)			;9af0
	ret			;9af1
L_9AF2:
	ld a,006h		;9af2
	call L_8DE0		;9af4
	jp c,tanda_de_la_otra_fase		;9af7
	jp arranca		;9afa
L_9AFD:
	call L_B710		;9afd
L_9B00:
	ld a,000h		;9b00
	ld e,a			;9b02
L_9B03:
	call 00093h		;9b03   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;9b06
	cp 00eh		;9b07
	jr nz,L_9B03		;9b09
	ld a,007h		;9b0b
	ld e,0b8h		;9b0d
	call 00093h		;9b0f   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;9b12
L_9B13:
	call 00093h		;9b13   ; BIOS WRTPSG - Writes data to PSG-register
	sub a			;9b16
	ld (0809eh),a		;9b17
	call 0fd9ah		;9b1a   ; BIOS HOOKS - System hooks
	ret			;9b1d
L_9B1E:
	push af			;9b1e
	call L_8DF3		;9b1f
	pop af			;9b22
	jp reparte_por_tipo		;9b23

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9b26..0x9b28  (2 bytes)
DATA_9B26:
	defb 000h,000h	; 9b26

; ======================================================================
; CODIGO 0x9b28..0x9b3f  (23 bytes)
; ======================================================================


L_9B28:
	ld a,(080b1h)		;9b28
	dec a			;9b2b
	ld a,052h		;9b2c
	jr z,L_9B32		;9b2e
	ld a,060h		;9b30
L_9B32:
	ld (080b3h),a		;9b32
	jp avanza_si_toca		;9b35
L_9B38:
	ld a,(09c8fh)		;9b38
	or a			;9b3b
	ret z			;9b3c
	pop hl			;9b3d
	ret			;9b3e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9b3f..0x9b40  (1 bytes)
DATA_9B3F:
	defb 000h	; 9b3f

; ======================================================================
; CODIGO 0x9b40..0x9b47  (7 bytes)
; ======================================================================


L_9B40:
	ld hl,09b48h		;9b40
	ld (080c5h),hl		;9b43
	ret			;9b46

; ----------------------------------------------------------------------
; DATOS tabla_9B47: 121 bytes que recorre 0x9B40 (carga 0x9B48)
;   0x9b47..0x9bc0  (121 bytes)
DATA_tabla_9B47:
	defb 000h,003h,000h,018h,003h,001h,001h,003h,000h,058h,003h,001h,001h,003h,000h,048h	; 9b47  .........X.....H
	defb 003h,001h,001h,003h,000h,0c8h,003h,001h,001h,003h,000h,030h,005h,000h,030h,007h	; 9b57  ...........0..0.
	defb 000h,002h,005h,000h,030h,003h,000h,060h,007h,000h,050h,003h,000h,0c0h,003h,000h	; 9b67  ....0..`..P.....
	defb 010h,003h,001h,001h,003h,000h,010h,003h,001h,001h,003h,001h,001h,007h,001h,001h	; 9b77  ................
	defb 003h,001h,001h,003h,001h,060h,003h,001h,001h,003h,001h,001h,003h,001h,001h,003h	; 9b87  .....`..........
	defb 001h,001h,003h,001h,001h,003h,001h,001h,003h,001h,004h,003h,001h,001h,003h,000h	; 9b97  ................
	defb 004h,003h,001h,001h,003h,001h,001h,003h,001h,001h,003h,001h,001h,003h,001h,001h	; 9ba7  ................
	defb 003h,001h,001h,003h,000h,000h,000h,000h,000h	; 9bb7  .........

; ======================================================================
; CODIGO 0x9bc0..0x9c07  (71 bytes)
; ======================================================================


L_9BC0:
	call pinta_el_par_c1c1		;9bc0
	ld a,0f3h		;9bc3
L_9BC5:
	call 0004dh		;9bc5   ; BIOS WRTVRM - Writes data in VRAM
	inc a			;9bc8
	inc hl			;9bc9
	cp 0feh		;9bca
	jr nz,L_9BC5		;9bcc
	ld hl,00f70h		;9bce
	sub a			;9bd1
	ld bc,00080h		;9bd2
	call 00056h		;9bd5   ; BIOS FILVRM - Fills VRAM with value
	ld hl,02f70h		;9bd8
	ld b,010h		;9bdb
L_9BDD:
	ld a,0a1h		;9bdd
	call 0004dh		;9bdf   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9be2
	call 0004dh		;9be3   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9be6
	ld a,030h		;9be7
	call 0004dh		;9be9   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9bec
	call 0004dh		;9bed   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9bf0
	ld a,0c0h		;9bf1
	ld c,004h		;9bf3
L_9BF5:
	call 0004dh		;9bf5   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9bf8
	dec c			;9bf9
	jr nz,L_9BF5		;9bfa
	djnz L_9BDD		;9bfc
	ld hl,09910h		;9bfe
	call L_9C08		;9c01
	jp L_9C90		;9c04

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9c07..0x9c08  (1 bytes)
DATA_9C07:
	defb 000h	; 9c07

; ======================================================================
; CODIGO 0x9c08..0x9c8f  (135 bytes)
; ======================================================================


L_9C08:
	call 0fd9ah		;9c08   ; BIOS HOOKS - System hooks
	ld a,(hl)			;9c0b
	inc a			;9c0c
	ret z			;9c0d
	dec a			;9c0e
	cp 020h		;9c0f
	jr nz,copia_un_patron		;9c11
	sub a			;9c13
copia_un_patron:		; Se trae los ocho bytes del patron A desde 0x6000 a 0xE0F8
	ld b,008h		;9c14   ; Ocho filas
	exx			;9c16
	nop			;9c17
	ld de,06000h		;9c18   ; La tabla de patrones de la RAM escondida
	ld h,000h		;9c1b
	ld l,a			;9c1d
	add hl,hl			;9c1e   ; Por ocho: ocho bytes por patron
	add hl,hl			;9c1f
	add hl,hl			;9c20
	add hl,de			;9c21
	ld de,0e0f8h		;9c22   ; Destino: un tampon de la RAM alta
	ld bc,00008h		;9c25
	ldir		;9c28
L_9C2A:
	call L_9C2F		;9c2a
	jr L_9C48		;9c2d
L_9C2F:
	ld hl,0e0f8h		;9c2f
	ld c,008h		;9c32
L_9C34:
	ld b,011h		;9c34
	ld de,0fff8h		;9c36
rota_ocho_filas:		; Rota a la izquierda ocho bytes separados por DE
	rl (hl)		;9c39   ; Rota una fila, metiendo el acarreo
	ex af,af'			;9c3b
	add hl,de			;9c3c   ; Salta a la fila de abajo
	ex af,af'			;9c3d
	djnz rota_ocho_filas		;9c3e
	ld de,00089h		;9c40   ; 0x89 para pasar a la columna siguiente
	add hl,de			;9c43
	dec c			;9c44   ; Una columna menos
	jr nz,L_9C34		;9c45
	ret			;9c47
L_9C48:
	ld hl,0e078h		;9c48
	ld de,00f70h		;9c4b
	ld bc,00080h		;9c4e
	call 0005ch		;9c51   ; BIOS LDIRVM - Block transfers to VRAM from memory
	call L_9C62		;9c54
	exx			;9c57
	dec b			;9c58
	jr z,L_9C5E		;9c59
	exx			;9c5b
	jr L_9C2A		;9c5c
L_9C5E:
	inc hl			;9c5e
	jp L_9C08		;9c5f
L_9C62:
	push bc			;9c62
	ld bc,00a00h		;9c63
	call espera		;9c66
	pop bc			;9c69
	call 0fd9ah		;9c6a   ; BIOS HOOKS - System hooks
	ld a,(0fc9bh)		;9c6d
	cp 003h		;9c70
	call z,entra_el_monitor		;9c72
	jp 0fd9ah		;9c75   ; BIOS HOOKS - System hooks
L_9C78:
	call 0fd9ah		;9c78   ; BIOS HOOKS - System hooks
	ld hl,0e078h		;9c7b
	ld de,0e079h		;9c7e
	ld bc,00087h		;9c81
	ld (hl),000h		;9c84
	ldir		;9c86
	call 0fd9ah		;9c88   ; BIOS HOOKS - System hooks
	ld hl,0194ah		;9c8b
	ret			;9c8e

; ----------------------------------------------------------------------
; DATOS bandera_9C8F: Un byte de bandera; lo leen y escriben catorce
;   instrucciones (0x9B38, 0x9CBA, 0x9CE0...). Esta suelto en medio del
;   codigo, no en la pagina de variables
;   0x9c8f..0x9c90  (1 bytes)
DATA_bandera_9C8F:
	defb 001h	; 9c8f

; ======================================================================
; CODIGO 0x9c90..0x9cdf  (79 bytes)
; ======================================================================


L_9C90:
	ld hl,08080h		;9c90
	ld (hl),000h		;9c93
espera_una_tecla:		; Espera contando; si tocan la tecla 6 o se agota la cuenta, sale
	ld bc,00600h		;9c95   ; Cuenta de la espera
	call espera		;9c98
	ld a,006h		;9c9b   ; Tecla 6
	call L_8DE0		;9c9d
	jp nc,L_DD72		;9ca0   ; Pulsada: se acabo
	sub a			;9ca3
	ld (08050h),a		;9ca4
	call L_8DF6		;9ca7   ; Un paso mas
	ld a,(08050h)		;9caa
	dec a			;9cad   ; Y otra condicion de salida
	jp z,L_DD72		;9cae
	ld hl,08080h		;9cb1
	dec (hl)			;9cb4   ; La cuenta larga
	jp nz,espera_una_tecla		;9cb5
pone_al_jugador_al_principio:		; Coloca al jugador en 0x7860 y enciende la bandera de 0x9C8F
	ld a,001h		;9cb8
	ld (09c8fh),a		;9cba   ; La bandera que congela el juego
	call L_878A		;9cbd
	ld a,0aah		;9cc0   ; Dibujo de partida
	ld (0804bh),a		;9cc2
	ld hl,07860h		;9cc5   ; Posicion de partida
	ld bc,0a601h		;9cc8   ; El sprite y el banco
	ld a,010h		;9ccb   ; Numero de sprite
	call pinta_un_sprite		;9ccd   ; Los dos planos
	call pinta_un_sprite		;9cd0
	ld (08049h),hl		;9cd3   ; Guarda la posicion
	call pinta_al_jugador		;9cd6
	call 0fd9ah		;9cd9   ; BIOS HOOKS - System hooks | Vector de sonido
	jp monta_la_pantalla		;9cdc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9cdf..0x9ce0  (1 bytes)
DATA_9CDF:
	defb 000h	; 9cdf

; ======================================================================
; CODIGO 0x9ce0..0x9d2e  (78 bytes)
; ======================================================================


L_9CE0:
	ld a,(09c8fh)		;9ce0
	dec a			;9ce3
	jp nz,L_88B8		;9ce4
	ret			;9ce7
arranca_la_partida_2:		; Pone a cero las banderas del comienzo
	sub a			;9ce8
	ld (00000h),a		;9ce9   ; Escribe en 0x0000: con la pagina 0 en ROM esto no hace nada
	ld (0809fh),a		;9cec   ; La bandera de caida
	ld a,010h		;9cef
	ld (0807ch),a		;9cf1   ; Dieciseis pasos de cuenta
	call L_98DA		;9cf4
	ret			;9cf7
L_9CF8:
	sub a			;9cf8
	ld (08050h),a		;9cf9
	call 0fd9ah		;9cfc   ; BIOS HOOKS - System hooks
	ret			;9cff
monta_la_pantalla:		; Coge la ficha de 0x7000 y llama a lo que diga
	ld hl,07000h		;9d00   ; La tabla de la RAM escondida
	ld (08072h),hl		;9d03
	ld hl,00020h		;9d06
	call L_9B40		;9d09   ; Prepara la pantalla
	call L_DBB8		;9d0c
	ld hl,(08072h)		;9d0f   ; La entrada de la tabla
	ld e,(hl)			;9d12   ; La direccion que trae
	inc hl			;9d13
	ld d,(hl)			;9d14
	ex de,hl			;9d15
	ld a,001h		;9d16
	nop			;9d18   ; Un NOP
	call L_818E		;9d19
tanda_de_la_otra_fase:		; Las cinco rutinas del paso en la segunda fase
	call L_9510		;9d1c   ; El marcador
	call L_91E8		;9d1f
	call cuenta_del_marcador		;9d22   ; La cuenta del marcador
	call L_88D0		;9d25
	call un_paso_de_la_otra_fase		;9d28   ; Y el paso completo
	jp L_9AF2		;9d2b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9d2e..0x9d30  (2 bytes)
DATA_9D2E:
	defb 000h,000h	; 9d2e

; ======================================================================
; CODIGO 0x9d30..0x9d7f  (79 bytes)
; ======================================================================


un_paso_de_la_otra_fase:		; Igual que 0x88F8 pero con otra tabla de avisos
	ld hl,08048h		;9d30
	dec (hl)			;9d33   ; Cuenta atras del paso
	ret nz			;9d34
	ld a,(0805dh)		;9d35   ; El paso base
	ld (hl),a			;9d38
	call L_8B27		;9d39   ; Coge la ficha
	ld a,(de)			;9d3c   ; Primer aviso
	inc de			;9d3d
	or a			;9d3e
	jp nz,L_8BC0		;9d3f
	ld a,(de)			;9d42   ; Segundo aviso
	inc de			;9d43
	or a			;9d44
	jp nz,reparte_por_tipo		;9d45
	ld a,(de)			;9d48   ; Tercer aviso
	inc de			;9d49
	or a			;9d4a
	jp nz,tanda_del_bicho		;9d4b
	ld a,(08050h)		;9d4e   ; Si el jugador esta ocupado...
	or a			;9d51
	jr nz,lee_el_guion_de_la_fase		;9d52
	call L_9D78		;9d54   ; ...se mira que tecla hay
	cp 001h		;9d57   ; Solo la 1 hace algo aqui
	jr nz,lee_el_guion_de_la_fase		;9d59
	nop			;9d5b
	call prepara_el_disparo		;9d5c
lee_el_guion_de_la_fase:		; Cada tantos pasos coge del guion de 0x80C5 el estado siguiente
	call L_DF58		;9d5f
	ld hl,080c7h		;9d62   ; Cuenta atras del paso
	dec (hl)			;9d65
	ret nz			;9d66   ; Todavia no
	ld hl,(080c5h)		;9d67   ; El puntero del guion
	ld a,(hl)			;9d6a
	ld (0805bh),a		;9d6b   ; El estado nuevo
	inc hl			;9d6e
	ld a,(hl)			;9d6f   ; Y el byte que lo acompana
	or a			;9d70
	push hl			;9d71   ; Se guarda el puntero para el que siga
	ld a,(0805bh)		;9d72
	jp apunta_el_guion		;9d75
L_9D78:
	ld a,r		;9d78
	and 00fh		;9d7a
	cp 008h		;9d7c
	ret			;9d7e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9d7f..0x9d80  (1 bytes)
DATA_9D7F:
	defb 000h	; 9d7f

; ======================================================================
; CODIGO 0x9d80..0x9d95  (21 bytes)
; ======================================================================


apunta_el_guion:		; Guarda el periodo y el puntero del guion de la fase
	call nz,L_8AA6		;9d80
	pop hl			;9d83   ; Se recupera el puntero
	inc hl			;9d84
	ld a,(hl)			;9d85   ; El periodo
	ld (080c7h),a		;9d86
	inc hl			;9d89
	ld (080c5h),hl		;9d8a   ; Y donde sigue el guion
	ret			;9d8d
L_9D8E:
	ld a,(0804ah)		;9d8e
	cp b			;9d91
	ret nz			;9d92
	pop hl			;9d93
	ret			;9d94

; ----------------------------------------------------------------------
; DATOS datos_9D95: Veintisiete bytes entre dos rutinas. Ninguna instruccion
;   los apunta
;   0x9d95..0x9db0  (27 bytes)
DATA_datos_9D95:
	defb 000h,000h,000h,000h,0cdh,0a8h,09dh,03eh,001h,032h,062h,080h,0c9h,0cdh,0b3h,08ah	; 9d95  .......>.2b.....
	defb 0c3h,09ch,09dh,03ah,050h,080h,0b7h,0c0h,0c3h,010h,08eh	; 9da5  ...:P......

; ======================================================================
; CODIGO 0x9db0..0x9dbf  (15 bytes)
; ======================================================================


pinta_el_par_c1c1:		; Dos sprites en la misma posicion
	ld a,010h		;9db0   ; Numero de sprite
	ld hl,0c1c1h		;9db2   ; El par de dibujos
	call L_8310		;9db5
	call L_8310		;9db8   ; El segundo
	call L_9C78		;9dbb
	ret			;9dbe

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9dbf..0x9dc0  (1 bytes)
DATA_9DBF:
	defb 000h	; 9dbf

; ======================================================================
; CODIGO 0x9dc0..0x9dc7  (7 bytes)
; ======================================================================


L_9DC0:
	call L_9DC8		;9dc0
	call pinta_al_jugador		;9dc3
	ret			;9dc6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9dc7..0x9dc8  (1 bytes)
DATA_9DC7:
	defb 0c9h	; 9dc7

; ======================================================================
; CODIGO 0x9dc8..0x9de7  (31 bytes)
; ======================================================================


L_9DC8:
	ld hl,0c1c1h		;9dc8
	ld a,000h		;9dcb
	ld b,010h		;9dcd
L_9DCF:
	call L_8310		;9dcf
	djnz L_9DCF		;9dd2
	call 0fd9ah		;9dd4   ; BIOS HOOKS - System hooks
	ret			;9dd7
prepara_al_que_cae:		; Posicion de partida y dieciseis pasos de cuenta
	ld hl,0188eh		;9dd8   ; Su posicion en la VRAM
	ld (0807fh),hl		;9ddb
	ld a,010h		;9dde   ; Dieciseis pasos
	ld (0807bh),a		;9de0
	call coloca_el_aviso		;9de3
	ret			;9de6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9de7..0x9de8  (1 bytes)
DATA_9DE7:
	defb 0c9h	; 9de7

; ======================================================================
; CODIGO 0x9de8..0x9e2f  (71 bytes)
; ======================================================================


L_9DE8:
	ld a,(08087h)		;9de8
	or a			;9deb
	jp nz,cuenta_para_el_dibujo		;9dec
	ld hl,0807bh		;9def
	dec (hl)			;9df2
	ret nz			;9df3
	ld (hl),010h		;9df4
	call 0fd9ah		;9df6   ; BIOS HOOKS - System hooks
	ld hl,(0807fh)		;9df9
	ld a,0efh		;9dfc
	call 0004dh		;9dfe   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;9e01
	call 0004dh		;9e02   ; BIOS WRTVRM - Writes data in VRAM
	ld de,0001fh		;9e05
	add hl,de			;9e08
	ld (0807fh),hl		;9e09
	ld de,019eeh		;9e0c
	rst 20h			;9e0f
	ret nz			;9e10
	ld hl,0fd9ah		;9e11
	ld (08078h),hl		;9e14
	ret			;9e17
L_9E18:
	call 0fd9ah		;9e18   ; BIOS HOOKS - System hooks
	ld a,000h		;9e1b
	ld (08094h),a		;9e1d
	ld a,001h		;9e20
	ld (0808eh),a		;9e22
	ld (08090h),a		;9e25
	call 0fd9ah		;9e28   ; BIOS HOOKS - System hooks
	call 0fd9ah		;9e2b   ; BIOS HOOKS - System hooks
	ret			;9e2e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9e2f..0x9e30  (1 bytes)
DATA_9E2F:
	defb 0c9h	; 9e2f

; ======================================================================
; CODIGO 0x9e30..0x9eb5  (133 bytes)
; ======================================================================


sortea_una_aparicion:		; Cada 18 pasos, y si no hay ninguno ya en pantalla, saca uno nuevo
	call mira_el_estado_del_disparo		;9e30   ; Lo que toque hacer antes
	ld hl,0808eh		;9e33   ; Cuenta atras hasta el proximo sorteo
	dec (hl)			;9e36
	ret nz			;9e37   ; Todavia no
	ld (hl),012h		;9e38   ; Se recarga a 18
	ld a,(09c8fh)		;9e3a   ; La bandera que congela el juego
	or a			;9e3d
	ret nz			;9e3e   ; Con ella puesta no se sortea nada
	ld a,(08094h)		;9e3f   ; Si ya hay uno en pantalla...
	or a			;9e42
	jp nz,persigue_al_jugador		;9e43   ; ...se atiende al que hay
	ld a,r		;9e46   ; El registro de refresco de la CPU, que hace de dado
	cp 008h		;9e48   ; Solo sale uno de cada treinta y dos veces
	ret nc			;9e4a
	ld a,001h		;9e4b   ; Marca que ya hay uno
	ld (08094h),a		;9e4d
	ld a,01eh		;9e50   ; Y le da 30 pasos de vida
	ld (0808fh),a		;9e52
	ld a,002h		;9e55
	call L_9FE0		;9e57
	ld a,010h		;9e5a
	ld (08093h),a		;9e5c
	ld a,001h		;9e5f
	ld (0809bh),a		;9e61
	call 0fd9ah		;9e64   ; BIOS HOOKS - System hooks | Vector de sonido
	call L_8978		;9e67
	cp 003h		;9e6a   ; Segun donde este el jugador, aparece a un lado o al otro
	jr z,L_9E78		;9e6c
	cp 007h		;9e6e
	ld a,0d0h		;9e70
	jr z,L_9E7A		;9e72
	ld a,000h		;9e74
	jr L_9E7A		;9e76
L_9E78:
	ld a,030h		;9e78
L_9E7A:
	ld hl,08049h		;9e7a
	add a,(hl)			;9e7d
	ld (08092h),a		;9e7e
	call L_BF90		;9e81
	call 0fd9ah		;9e84   ; BIOS HOOKS - System hooks
	ret			;9e87
persigue_al_jugador:		; Mueve al perseguidor hacia el jugador y acelera cada cuatro pasos
	dec a			;9e88   ; Solo si el estado es 2
	jp nz,pinta_al_perseguidor		;9e89
	ld hl,08093h		;9e8c   ; La posicion en curso
	ld a,(0809bh)		;9e8f   ; El paso de avance
	add a,(hl)			;9e92
	ld (hl),a			;9e93   ; Avanza
	ld hl,(08092h)		;9e94   ; La posicion completa
	ld a,018h		;9e97   ; Numero de sprite en el VDP
	call L_9EC8		;9e99
	ld hl,08090h		;9e9c   ; Cuenta atras de la aceleracion
	dec (hl)			;9e9f
	ret nz			;9ea0
	ld (hl),004h		;9ea1   ; Se recarga a 4
	ld hl,0809bh		;9ea3
	inc (hl)			;9ea6   ; Y el paso sube de dos en dos
	inc (hl)			;9ea7
	ld a,(08093h)		;9ea8
	add a,020h		;9eab   ; Treinta y dos pixeles por delante
	ld hl,0804ah		;9ead
	cp (hl)			;9eb0   ; Comparado con la Y del jugador
	ret c			;9eb1
	jp L_9ED8		;9eb2

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9eb5..0x9eb8  (3 bytes)
DATA_9EB5:
	defb 000h,000h,000h	; 9eb5

; ======================================================================
; CODIGO 0x9eb8..0x9ebf  (7 bytes)
; ======================================================================


L_9EB8:
	call prepara_al_perseguidor		;9eb8
	call L_9E18		;9ebb
	ret			;9ebe

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9ebf..0x9ec0  (1 bytes)
DATA_9EBF:
	defb 0c9h	; 9ebf

; ======================================================================
; CODIGO 0x9ec0..0x9ec7  (7 bytes)
; ======================================================================


L_9EC0:
	call aparicion_por_un_lado		;9ec0
	call sortea_una_aparicion		;9ec3
	ret			;9ec6

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9ec7..0x9ec8  (1 bytes)
DATA_9EC7:
	defb 0c9h	; 9ec7

; ======================================================================
; CODIGO 0x9ec8..0x9ed7  (15 bytes)
; ======================================================================


L_9EC8:
	call L_8310		;9ec8
	ld a,018h		;9ecb
	ld bc,02201h		;9ecd
	call pinta_un_sprite		;9ed0
	call 0fd9ah		;9ed3   ; BIOS HOOKS - System hooks
	ret			;9ed6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9ed7..0x9ed8  (1 bytes)
DATA_9ED7:
	defb 000h	; 9ed7

; ======================================================================
; CODIGO 0x9ed8..0x9f6f  (151 bytes)
; ======================================================================


L_9ED8:
	ld a,002h		;9ed8
	ld (08094h),a		;9eda
	ld a,0ffh		;9edd
	ld (0809bh),a		;9edf
	call 0fd9ah		;9ee2   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;9ee5   ; BIOS HOOKS - System hooks
pinta_al_perseguidor:		; Estado 3: solo animarlo, sin moverlo
	dec a			;9ee8   ; Solo si el estado es 3
	jp nz,L_9FE8		;9ee9
	ld hl,08090h		;9eec   ; Cuenta atras del cambio de dibujo
	dec (hl)			;9eef
	jr nz,L_9F20		;9ef0
	ld (hl),001h		;9ef2   ; Se recarga a 1
	ld a,(0808fh)		;9ef4   ; El dibujo en curso
	ld b,a			;9ef7
	ld c,001h		;9ef8   ; Banco 1
	ld a,018h		;9efa   ; Numero de sprite en el VDP
	call pinta_un_sprite		;9efc
	dec b			;9eff
	dec b			;9f00
	ld a,(08091h)		;9f01
	add a,b			;9f04
	cp 024h		;9f05   ; Los dos finales de ciclo
	jr z,L_9F0D		;9f07
	cp 01ch		;9f09
	jr nz,L_9F1D		;9f0b
L_9F0D:
	ld a,(08091h)		;9f0d
	cp 002h		;9f10
	ld a,0feh		;9f12
	jr z,L_9F18		;9f14
	ld a,002h		;9f16
L_9F18:
	ld (08091h),a		;9f18
	jr L_9F20		;9f1b
L_9F1D:
	ld (0808fh),a		;9f1d
L_9F20:
	call 0fd9ah		;9f20   ; BIOS HOOKS - System hooks
	ld hl,08092h		;9f23
	ld a,(08049h)		;9f26
	cp (hl)			;9f29
	ld a,0ffh		;9f2a
	jr c,acerca_por_arriba		;9f2c
	ld a,001h		;9f2e
acerca_por_arriba:		; Sube el paso y, si el jugador queda por debajo, cambia de sentido
	add a,(hl)			;9f30
	ld (hl),a			;9f31   ; Guarda la posicion nueva
	ld hl,08093h		;9f32
	ld a,(0809bh)		;9f35   ; El paso
	inc a			;9f38   ; 0xFF quiere decir "hacia arriba"
	jr nz,acerca_por_abajo		;9f39
	dec (hl)			;9f3b
	ld a,(0804ah)		;9f3c   ; La Y del jugador
	sub 020h		;9f3f   ; Treinta y dos pixeles de margen
	cp (hl)			;9f41
	jr c,L_9F59		;9f42
	ld a,001h		;9f44   ; Y a partir de aqui, hacia abajo
	ld (0809bh),a		;9f46
	jr L_9F59		;9f49
acerca_por_abajo:		; Sube el paso y, si el jugador queda por encima, cambia de sentido
	inc (hl)			;9f4b   ; Uno mas
	ld a,(0804ah)		;9f4c   ; La Y del jugador
	sub 00ch		;9f4f   ; Doce pixeles de margen
	cp (hl)			;9f51
	jr nc,L_9F59		;9f52
	ld a,0ffh		;9f54   ; Y a partir de aqui, hacia arriba
	ld (0809bh),a		;9f56
L_9F59:
	ld hl,(08092h)		;9f59
	ld a,018h		;9f5c
	call L_8310		;9f5e
	call 0fd9ah		;9f61   ; BIOS HOOKS - System hooks
	call 0fd9ah		;9f64   ; BIOS HOOKS - System hooks
	ret			;9f67
L_9F68:
	ld hl,(08092h)		;9f68
	call mira_si_pisa_la_casilla		;9f6b
	ret			;9f6e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9f6f..0x9f70  (1 bytes)
DATA_9F6F:
	defb 0c9h	; 9f6f

; ======================================================================
; CODIGO 0x9f70..0x9f93  (35 bytes)
; ======================================================================


L_9F70:
	ld a,(08050h)		;9f70
	cp 002h		;9f73
	ret nz			;9f75
	jp mira_si_toca_al_perseguidor		;9f76
mira_el_estado_del_disparo:		; Con el estado 3 no hace nada
	call L_BF9A		;9f79
	ld a,(08050h)		;9f7c   ; El estado
	cp 003h		;9f7f   ; Solo el 3 se salta el resto
	ret z			;9f81
	call L_A117		;9f82   ; Y si no, se sigue
	jp L_9F88		;9f85
L_9F88:
	ld hl,(08092h)		;9f88
	call L_9F90		;9f8b
	jr $+34		;9f8e
L_9F90:
	jp L_9FD0		;9f90

; ----------------------------------------------------------------------
; DATOS or_a_ret_z_huerfano: Los dos bytes B7 C8, "or a / ret z", a los que no
;   llega nadie
;   0x9f93..0x9f95  (2 bytes)
DATA_or_a_ret_z_huerfano:
	defb 0b7h,0c8h	; 9f93

; ======================================================================
; CODIGO 0x9f95..0x9faf  (26 bytes)
; ======================================================================


esta_a_tiro:		; Devuelve Z si HL cae dentro de la ventana del jugador
	ld a,(08052h)		;9f95   ; La X guardada
	sub 008h		;9f98   ; Ocho pixeles por delante
	cp l			;9f9a
	jr nc,$+61		;9f9b
	add a,010h		;9f9d   ; Dieciseis de ventana
	cp l			;9f9f
	ret c			;9fa0
	ld a,(08053h)		;9fa1   ; La Y guardada
	sub 010h		;9fa4   ; Dieciseis por arriba
	cp h			;9fa6
	jr nc,$+49		;9fa7
	add a,018h		;9fa9   ; Veinticuatro de ventana
	cp h			;9fab
	ret c			;9fac
	sub a			;9fad   ; Todo dentro: Z
	ret			;9fae

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0x9faf..0x9fb0  (1 bytes)
DATA_9FAF:
	defb 0c9h	; 9faf

; ======================================================================
; CODIGO 0x9fb0..0x9fdb  (43 bytes)
; ======================================================================


L_9FB0:
	ret nz			;9fb0
	call L_A890		;9fb1
	call 0fd9ah		;9fb4   ; BIOS HOOKS - System hooks
	ld hl,0809ch		;9fb7
	dec (hl)			;9fba
	ret nz			;9fbb
	ld a,003h		;9fbc
	ld (08094h),a		;9fbe
	ld a,096h		;9fc1
	ld (0808fh),a		;9fc3
	call 0fd9ah		;9fc6   ; BIOS HOOKS - System hooks
	ld hl,(08054h)		;9fc9
	ld (08092h),hl		;9fcc
	ret			;9fcf
L_9FD0:
	ld a,(08050h)		;9fd0
	cp 002h		;9fd3
	jp z,esta_a_tiro		;9fd5
L_9FD8:
	sub a			;9fd8
	inc a			;9fd9
	ret			;9fda

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9fdb..0x9fe0  (5 bytes)
DATA_9FDB:
	defb 000h,000h,000h,000h,000h	; 9fdb

; ======================================================================
; CODIGO 0x9fe0..0x9fe7  (7 bytes)
; ======================================================================


L_9FE0:
	ld (08091h),a		;9fe0
	ld (0809ch),a		;9fe3
	ret			;9fe6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x9fe7..0x9fe8  (1 bytes)
DATA_9FE7:
	defb 000h	; 9fe7

; ======================================================================
; CODIGO 0x9fe8..0xa03f  (87 bytes)
; ======================================================================


L_9FE8:
	dec a			;9fe8
	jp nz,L_A025		;9fe9
	ld a,(0808fh)		;9fec
	ld b,a			;9fef
	ld c,001h		;9ff0
	ld a,018h		;9ff2
	call pinta_un_sprite		;9ff4
	ld a,b			;9ff7
	ld (0808fh),a		;9ff8
	cp 0a6h		;9ffb
	ret nz			;9ffd
	ld a,018h		;9ffe
	ld hl,0c1c1h		;a000
	call L_8310		;a003
	ld hl,(08092h)		;a006
	ld a,027h		;a009
	call 0004dh		;a00b   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a00e
	ld a,024h		;a00f
	call 0004dh		;a011   ; BIOS WRTVRM - Writes data in VRAM
	call L_A89A		;a014
	ld a,004h		;a017
	ld (08094h),a		;a019
	ld a,000h		;a01c
	ld (0808eh),a		;a01e
	call 0fd9ah		;a021   ; BIOS HOOKS - System hooks
	ret			;a024
L_A025:
	ld hl,(08092h)		;a025
	sub a			;a028
	call 0004dh		;a029   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a02c
	call 0004dh		;a02d   ; BIOS WRTVRM - Writes data in VRAM
	sub a			;a030
	ld (08094h),a		;a031
	call 0fd9ah		;a034   ; BIOS HOOKS - System hooks
	ret			;a037
L_A038:
	ld hl,(08054h)		;a038
	ld (08080h),hl		;a03b
	ret			;a03e

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xa03f..0xa040  (1 bytes)
DATA_A03F:
	defb 0c9h	; a03f

; ======================================================================
; CODIGO 0xa040..0xa09e  (94 bytes)
; ======================================================================


L_A040:
	call 0fd9ah		;a040   ; BIOS HOOKS - System hooks
	ld a,(0809dh)		;a043
	ld e,a			;a046
	ld a,000h		;a047
	call 00093h		;a049   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,002h		;a04c
	add a,e			;a04e
	ld e,a			;a04f
	ld a,002h		;a050
	call 00093h		;a052   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,002h		;a055
	add a,e			;a057
	ld e,a			;a058
	ld a,004h		;a059
	call 00093h		;a05b   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,000h		;a05e
	ld a,001h		;a060
	call 0fd9ah		;a062   ; BIOS HOOKS - System hooks
	ld a,003h		;a065
	call 00093h		;a067   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,005h		;a06a
	call 00093h		;a06c   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,007h		;a06f
	ld e,0b8h		;a071
	call 00093h		;a073   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a076
	ld e,010h		;a077
	call 00093h		;a079   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a07c
	call 00093h		;a07d   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a080
	call 00093h		;a081   ; BIOS WRTPSG - Writes data to PSG-register
	ld hl,0809dh		;a084
	inc (hl)			;a087
	inc (hl)			;a088
	call z,L_A938		;a089
	call 0fd9ah		;a08c   ; BIOS HOOKS - System hooks
	ret			;a08f
L_A090:
	ld a,(0809eh)		;a090
	or a			;a093
	call nz,L_A040		;a094
	call 0fd9ah		;a097   ; BIOS HOOKS - System hooks
	ld hl,08051h		;a09a
	ret			;a09d

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET huerfanos
;   0xa09e..0xa0a0  (2 bytes)
DATA_A09E:
	defb 0c9h,0c9h	; a09e

; ======================================================================
; CODIGO 0xa0a0..0xa0a6  (6 bytes)
; ======================================================================


L_A0A0:
	call L_A8AC		;a0a0
	jp pasa_al_estado_tres_2		;a0a3

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa0a6..0xa0a8  (2 bytes)
DATA_A0A6:
	defb 000h,000h	; a0a6

; ======================================================================
; CODIGO 0xa0a8..0xa0d6  (46 bytes)
; ======================================================================


L_A0A8:
	ld a,(09c8fh)		;a0a8
	or a			;a0ab
	jr z,invierte_la_bandera		;a0ac
	sub a			;a0ae
	ret			;a0af
invierte_la_bandera:		; Devuelve 1 si 0x809E vale cero
	ld a,(0809eh)		;a0b0   ; La bandera
	or a			;a0b3
	jr nz,L_A0B9		;a0b4   ; Puesta: por otro lado
	sub a			;a0b6
	inc a			;a0b7   ; Devuelve uno
	ret			;a0b8
L_A0B9:
	ld a,00bh		;a0b9
	ld e,0f0h		;a0bb
	call 00093h		;a0bd   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a0c0
	ld e,008h		;a0c1
	call 00093h		;a0c3   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a0c6
	ld e,001h		;a0c7
	call 00093h		;a0c9   ; BIOS WRTPSG - Writes data to PSG-register
	call 0fd9ah		;a0cc   ; BIOS HOOKS - System hooks
	ld a,010h		;a0cf
	ld (0809dh),a		;a0d1
	sub a			;a0d4
	ret			;a0d5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa0d6..0xa0d8  (2 bytes)
DATA_A0D6:
	defb 000h,000h	; a0d6

; ======================================================================
; CODIGO 0xa0d8..0xa0ef  (23 bytes)
; ======================================================================


L_A0D8:
	ld a,001h		;a0d8
L_A0DA:
	jr $-58		;a0da
L_A0DC:
	ld a,000h		;a0dc
	jr L_A0DA		;a0de
L_A0E0:
	call L_C02D		;a0e0
	cp 001h		;a0e3
	call L_BEF0		;a0e5
L_A0E8:
	call L_A138		;a0e8
	call L_A468		;a0eb
	ret			;a0ee

; ----------------------------------------------------------------------
; DATOS datos_A0EF: Diecisiete bytes justo delante de 0xA100, que es lo
;   primero que llama el arranque. Ninguna instruccion los apunta
;   0xa0ef..0xa100  (17 bytes)
DATA_datos_A0EF:
	defb 0c9h,03ah,098h,0fdh,0e6h,0f0h,0d3h,0a8h,03ah,099h,0fdh,0e6h,0f0h,032h,0ffh,0ffh,0c9h	; a0ef  .:......:....2...

; ======================================================================
; CODIGO 0xa100..0xa107  (7 bytes)
; ======================================================================


preparativos:		; Lo primero que hace 0x8100
	call L_A110		;a100   ; Monta la pantalla y las tablas
	call arranca_la_partida_2		;a103   ; Y el estado inicial de la partida
	ret			;a106

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0xa107..0xa108  (1 bytes)
DATA_A107:
	defb 0ffh	; a107

; ======================================================================
; CODIGO 0xa108..0xa10f  (7 bytes)
; ======================================================================


L_A108:
	call L_A110		;a108
	call L_A370		;a10b
	ret			;a10e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa10f..0xa110  (1 bytes)
DATA_A10F:
	defb 000h	; a10f

; ======================================================================
; CODIGO 0xa110..0xa137  (39 bytes)
; ======================================================================


L_A110:
	call pagina1_a_ram		;a110
	call copia_las_tablas_de_pantalla		;a113
	ret			;a116
L_A117:
	ld a,002h		;a117
	ld (080aeh),a		;a119
	ld (080abh),a		;a11c
	ret			;a11f
L_A120:
	ld a,(08050h)		;a120
	cp 002h		;a123
	jr nz,L_A128		;a125
	ret			;a127
L_A128:
	pop hl			;a128
	ret			;a129
L_A12A:
	call L_8F75		;a12a
	jp L_8F67		;a12d
L_A130:
	ld hl,(08049h)		;a130
	ld (08052h),hl		;a133
	ret			;a136

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa137..0xa138  (1 bytes)
DATA_A137:
	defb 000h	; a137

; ======================================================================
; CODIGO 0xa138..0xa19e  (102 bytes)
; ======================================================================


L_A138:
	ld a,(0804ah)		;a138
	cp 0a0h		;a13b
	ret c			;a13d
	ld a,(0804dh)		;a13e
	or a			;a141
	jp nz,L_A510		;a142
	ld hl,01b43h		;a145
	ld a,00eh		;a148
	ld bc,00004h		;a14a
	call 0004dh		;a14d   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;a150
	ld a,00fh		;a151
	call 0004dh		;a153   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;a156
	ld a,00eh		;a157
	call 0004dh		;a159   ; BIOS WRTVRM - Writes data in VRAM
	add hl,bc			;a15c
	ld a,00fh		;a15d
	call 0004dh		;a15f   ; BIOS WRTVRM - Writes data in VRAM
	ld a,001h		;a162
	ld (0809fh),a		;a164
	call L_9B00		;a167
	call 0fd9ah		;a16a   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;a16d   ; BIOS HOOKS - System hooks
baja_al_jugador:		; Si la bandera esta puesta, baja una fila hasta la 0xC1
	ld a,(0809fh)		;a170   ; La bandera
	or a			;a173
	jp z,L_A811		;a174   ; Sin ella no hay caida
	call pinta_al_jugador		;a177   ; Lo pinta
	ld hl,0804ah		;a17a   ; La Y
	inc (hl)			;a17d   ; Una fila mas abajo
	ld a,(hl)			;a17e
	cp 0c1h		;a17f   ; El suelo
	jr z,L_A185		;a181
	pop hl			;a183   ; Todavia no ha llegado: se quita la vuelta de la pila
	ret			;a184
L_A185:
	pop hl			;a185
	pop hl			;a186
	call 0fd9ah		;a187   ; BIOS HOOKS - System hooks
	call 0fd9ah		;a18a   ; BIOS HOOKS - System hooks
	jp L_9BC0		;a18d
L_A190:
	push af			;a190
	call apunta_la_ficha_2		;a191
	call 0fd9ah		;a194   ; BIOS HOOKS - System hooks
	pop af			;a197
	jp nz,L_8220		;a198
	jp L_81CA		;a19b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa19e..0xa1a0  (2 bytes)
DATA_A19E:
	defb 000h,000h	; a19e

; ======================================================================
; CODIGO 0xa1a0..0xa229  (137 bytes)
; ======================================================================


apunta_la_ficha_2:		; El gemelo de 0x94A0
	ld hl,(08072h)		;a1a0   ; La entrada en curso
	ld a,l			;a1a3
	ld hl,070c0h		;a1a4   ; La tabla de fichas de la RAM escondida
	rrca			;a1a7   ; El numero, dividido por dos
	or a			;a1a8
	jr z,monta_la_ficha_de_pantalla		;a1a9
	ld de,00058h		;a1ab   ; 0x58 = 88 bytes, una ficha
L_A1AE:
	add hl,de			;a1ae
	dec a			;a1af
	jr nz,L_A1AE		;a1b0
monta_la_ficha_de_pantalla:		; Copia los 88 bytes de la ficha a 0xDFFF y dibuja lo que declara
	call 0fd9ah		;a1b2   ; BIOS HOOKS - System hooks | Vector de sonido
	ld de,0dfffh		;a1b5   ; Destino: el tampon del final del bloque
	ld bc,00058h		;a1b8   ; 0x58 = 88 bytes, una ficha entera
	ldir		;a1bb
	call L_9B38		;a1bd
	ld a,(0dfffh)		;a1c0   ; El primer campo de la ficha
	or a			;a1c3
	jr z,dibuja_el_otro_objeto		;a1c4   ; A cero: no hay nada que dibujar

; ----------------------------------------------------------------------
;
; --- el modo de calcular una casilla ---
; De aqui en adelante aparece muchas veces el mismo bloque de doce
; instrucciones, y conviene leerlo una vez:
;
; ld a,h / exx / ld l,a / ld h,0 / add hl,hl x5 / exx
; ld a,l / exx / ld e,a / ld d,0 / add hl,de
; ld de,0x5480 / add hl,de
;
; Con una posicion empaquetada en HL -H la fila, L la columna- calcula
; la direccion de esa casilla en el mapa descomprimido:
; 0x5480 + fila*32 + columna
; Los cinco ADD HL,HL son el por 32, y el juego alternativo se usa solo
; para no perder el HL de partida. 0x5480 es donde 0x819E deja el mapa.
; ----------------------------------------------------------------------
	ld hl,(0e000h)		;a1c6   ; La posicion, empaquetada
	ld a,h			;a1c9
	exx			;a1ca
	ld l,a			;a1cb
	ld h,000h		;a1cc
	add hl,hl			;a1ce
	add hl,hl			;a1cf
	add hl,hl			;a1d0
	add hl,hl			;a1d1
	add hl,hl			;a1d2
	exx			;a1d3
	ld a,l			;a1d4
	exx			;a1d5
	ld e,a			;a1d6
	ld d,000h		;a1d7
	add hl,de			;a1d9
	ex de,hl			;a1da
	ld hl,05480h		;a1db   ; El mapa descomprimido
	add hl,de			;a1de
	ld de,0001fh		;a1df   ; 31, para bajar de fila al escribir la segunda pareja
	ld a,091h		;a1e2   ; La baldosa 0x91, la primera de las cuatro
	ld (hl),a			;a1e4
	inc hl			;a1e5
	inc a			;a1e6   ; Y las otras tres, de dos en dos
	inc a			;a1e7
	ld (hl),a			;a1e8
	add hl,de			;a1e9
	dec a			;a1ea
	ld (hl),a			;a1eb
	inc hl			;a1ec
	inc a			;a1ed
	inc a			;a1ee
	ld (hl),a			;a1ef
dibuja_el_otro_objeto:		; Igual, con el campo de 0xE02C de la ficha
	ld a,(0e02ch)		;a1f0   ; El campo que dice si hay objeto
	or a			;a1f3
	jp z,L_A498		;a1f4   ; A cero: nada
	ld hl,(0e032h)		;a1f7   ; Su posicion, empaquetada
	ld a,h			;a1fa
	exx			;a1fb
	ld l,a			;a1fc
	ld h,000h		;a1fd
	add hl,hl			;a1ff
	add hl,hl			;a200
	add hl,hl			;a201
	add hl,hl			;a202
	add hl,hl			;a203
	exx			;a204
	ld a,l			;a205
	exx			;a206
	ld e,a			;a207
	ld d,000h		;a208
	add hl,de			;a20a
	ex de,hl			;a20b
	ld hl,05480h		;a20c   ; El mapa descomprimido
	add hl,de			;a20f
	ex de,hl			;a210
	ld hl,08c60h		;a211   ; Los dibujos que le tocan
	exx			;a214
	ld b,008h		;a215   ; Ocho filas
copia_de_cuatro_en_cuatro:		; Copia B grupos de cuatro bytes, saltando 0x1C entre grupo y grupo
	exx			;a217
	ld bc,00004h		;a218   ; Cuatro bytes
	ldir		;a21b
	ex de,hl			;a21d
	ld bc,0001ch		;a21e   ; 0x1C: lo que hay hasta el grupo siguiente
	add hl,bc			;a221
	ex de,hl			;a222
	exx			;a223
	djnz copia_de_cuatro_en_cuatro		;a224   ; Otro grupo
	jp L_A498		;a226

; ----------------------------------------------------------------------
; DATOS ret_y_relleno_ff: Un RET y cuatro 0xFF de relleno hasta 0xA22E
;   0xa229..0xa22e  (5 bytes)
DATA_ret_y_relleno_ff:
	defb 0c9h,0ffh,0ffh,0ffh,0ffh	; a229

; ======================================================================
; CODIGO 0xa22e..0xa36e  (320 bytes)
; ======================================================================


anima_al_bicho:		; Cuenta atras, sortea si se mueve y actualiza su posicion
	ld hl,0aa00h		;a22e   ; La pareja de guiones de despues
	push hl			;a231   ; Se mete en la pila para volver ahi al terminar
	ld a,(0e02ch)		;a232   ; El campo que dice si el bicho existe
	or a			;a235
	ret z			;a236   ; No existe: nada que hacer
	call L_A8BB		;a237   ; Su cuenta atras
	dec (hl)			;a23a
	ret nz			;a23b   ; Todavia no
	ld a,(0e02eh)		;a23c   ; El periodo, que se recarga
	ld (hl),a			;a23f
	ld a,(0e036h)		;a240   ; Si ya esta en movimiento...
	or a			;a243
	jp nz,estado_dos_del_bicho_2		;a244   ; ...se sigue moviendo
	ld a,(0e02fh)		;a247   ; Y si no, se sortea
	or a			;a24a
	jr nz,L_A28A		;a24b
	call L_9D78		;a24d   ; El dado
	cp 004h		;a250   ; Una de cada sesenta y cuatro veces
	ret nc			;a252
	ld a,001h		;a253   ; Marca que arranca
	ld (0e02fh),a		;a255
	ld a,r		;a258   ; El registro de refresco, otra vez de dado
	and 07fh		;a25a   ; De 0 a 127
	ld (0e02dh),a		;a25c
sigue_al_bicho:		; Calcula su casilla y prueba las de al lado
	ld hl,(0e030h)		;a25f   ; Su posicion
	ld de,000a0h		;a262   ; 0xA0 = cinco filas de 32
	add hl,de			;a265
	ld a,(0e034h)		;a266   ; El sentido
	inc a			;a269
	call prepara_el_dibujo		;a26a
	jr z,L_A273		;a26d
	inc hl			;a26f   ; Una casilla mas alla
	call prepara_el_dibujo_2		;a270
L_A273:
	ld a,c			;a273
	call 0004dh		;a274   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00020h		;a277
	add hl,de			;a27a
	ld a,b			;a27b
	call 0004dh		;a27c   ; BIOS WRTVRM - Writes data in VRAM
	ld a,r		;a27f
	and 07fh		;a281
	ld (0e02dh),a		;a283
	call 0fd9ah		;a286   ; BIOS HOOKS - System hooks
	ret			;a289
L_A28A:
	dec a			;a28a
	jr nz,arranca_el_bicho		;a28b
arranca_el_bicho:		; Marca que se mueve y elige el par de dibujos segun el sentido
	ld a,001h		;a28d
	ld (0e036h),a		;a28f   ; La bandera de "en marcha"
	ld hl,(0e030h)		;a292   ; Su posicion
	ld de,000a0h		;a295   ; 0xA0 = cinco filas de 32
	add hl,de			;a298
	ld a,(0e034h)		;a299   ; El sentido
	inc a			;a29c   ; 0xFF quiere decir "hacia un lado"
	ld bc,07a79h		;a29d   ; Un par de dibujos...
	jr z,sigue_el_bicho		;a2a0
	ld bc,07877h		;a2a2   ; ...o el otro
	inc hl			;a2a5
sigue_el_bicho:		; Recarga su cuenta y calcula la casilla de delante
	call L_A273		;a2a6
	ld a,(0e02eh)		;a2a9   ; El periodo
	ld (0e02dh),a		;a2ac   ; Se recarga
	call 0fd9ah		;a2af   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,(0e030h)		;a2b2   ; Su posicion
	ld de,000bfh		;a2b5   ; 0xBF: casi seis filas
	add hl,de			;a2b8
	dec hl			;a2b9
	ld a,(0e034h)		;a2ba   ; El sentido
	inc a			;a2bd
	jr z,L_A2C4		;a2be
	ld de,00006h		;a2c0   ; Seis casillas mas si va hacia el otro lado
	add hl,de			;a2c3
L_A2C4:
	call L_A34C		;a2c4
	ret			;a2c7
estado_dos_del_bicho_2:		; Con el estado 2, sigue por donde iba
	dec a			;a2c8   ; Solo si el estado es 2
	jp nz,L_A31A		;a2c9
	ld hl,(0e037h)		;a2cc   ; Su posicion guardada
	ld a,(0e034h)		;a2cf   ; El sentido
	inc a			;a2d2
	jp L_A378		;a2d3
L_A2D6:
	call L_A392		;a2d6
	jr nz,L_A2FC		;a2d9
	ld (0e037h),hl		;a2db
	ld a,0b2h		;a2de
	call 0004dh		;a2e0   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a2e3
	inc a			;a2e4
	call 0004dh		;a2e5   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a2e8
	sub a			;a2e9
	call 0004dh		;a2ea   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,0e039h		;a2ed
	ld a,(hl)			;a2f0
	sub 008h		;a2f1
	ld (hl),a			;a2f3
	cp 000h		;a2f4
	jr z,L_A2FC		;a2f6
	call 0fd9ah		;a2f8   ; BIOS HOOKS - System hooks
	ret			;a2fb
L_A2FC:
	call 0fd9ah		;a2fc   ; BIOS HOOKS - System hooks
	ld a,002h		;a2ff
	ld (0e036h),a		;a301
	call sigue_al_bicho		;a304
	ld hl,(0e037h)		;a307
	ld a,07fh		;a30a
	call 0004dh		;a30c   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a30f
	inc a			;a310
	call 0004dh		;a311   ; BIOS WRTVRM - Writes data in VRAM
	ld a,040h		;a314
	ld (0e02dh),a		;a316
	ret			;a319
L_A31A:
	ld hl,(0e037h)		;a31a
	sub a			;a31d
	call 0004dh		;a31e   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a321
	call 0004dh		;a322   ; BIOS WRTVRM - Writes data in VRAM
	ld a,000h		;a325
	ld (0e02fh),a		;a327
	ld (0e036h),a		;a32a
	ld hl,(0e030h)		;a32d
	ld de,000a0h		;a330
	add hl,de			;a333
	ld a,(0e034h)		;a334
	inc a			;a337
	ld bc,06d76h		;a338
	jr z,L_A341		;a33b
	inc hl			;a33d
	ld bc,07675h		;a33e
L_A341:
	call L_A273		;a341
	sub a			;a344
	ld (0e02dh),a		;a345
	call 0fd9ah		;a348   ; BIOS HOOKS - System hooks
	ret			;a34b
L_A34C:
	ld a,(0e034h)		;a34c
	inc a			;a34f
	jr z,L_A360		;a350
	ld a,0b1h		;a352
	call 0004dh		;a354   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;a357
	ld (0e037h),hl		;a358
	dec a			;a35b
	call 0004dh		;a35c   ; BIOS WRTVRM - Writes data in VRAM
	ret			;a35f
L_A360:
	ld a,0b3h		;a360
	call 0004dh		;a362   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;a365
	dec a			;a366
	call 0004dh		;a367   ; BIOS WRTVRM - Writes data in VRAM
	ld (0e037h),hl		;a36a
	ret			;a36d

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa36e..0xa370  (2 bytes)
DATA_A36E:
	defb 000h,000h	; a36e

; ======================================================================
; CODIGO 0xa370..0xa37f  (15 bytes)
; ======================================================================


L_A370:
	sub a			;a370
	ld (08087h),a		;a371
	call L_90D0		;a374
	ret			;a377
L_A378:
	jp nz,L_A560		;a378
	dec hl			;a37b
	jp L_A2D6		;a37c

; ----------------------------------------------------------------------
; DATOS tabla_A37F: Diecisiete bytes con los codigos de baldosa '+', '{', '|',
;   '}', '~' seguidos de ceros
;   0xa37f..0xa390  (17 bytes)
DATA_tabla_A37F:
	defb 000h,000h,02bh,07bh,07ch,07dh,07eh,07fh,080h,095h,096h,097h,098h,0b0h,0b1h,0b2h,0b3h	; a37f  ..+{|}~..........

; ======================================================================
; CODIGO 0xa390..0xa462  (210 bytes)
; ======================================================================


L_A390:
	xor 0ffh		;a390
L_A392:
	call 0004ah		;a392   ; BIOS RDVRM - Reads the content of VRAM
	exx			;a395
	ld hl,0dab2h		;a396
	ld bc,00016h		;a399
	cpir		;a39c
	exx			;a39e
	ret			;a39f
L_A3A0:
	call 0004ah		;a3a0   ; BIOS RDVRM - Reads the content of VRAM
	cp 06eh		;a3a3
	jr z,L_A3AA		;a3a5
	cp 06fh		;a3a7
	ret nz			;a3a9
L_A3AA:
	ld a,(0e02fh)		;a3aa
	or a			;a3ad
	jp z,0004ah		;a3ae   ; BIOS RDVRM - Reads the content of VRAM
	call L_A0D8		;a3b1
	ld hl,0e035h		;a3b4
	dec (hl)			;a3b7
	jr z,L_A3BF		;a3b8
	call 0fd9ah		;a3ba   ; BIOS HOOKS - System hooks
	pop hl			;a3bd
	ret			;a3be
L_A3BF:
	call L_A31A		;a3bf
	call 0fd9ah		;a3c2   ; BIOS HOOKS - System hooks
	call alterna_el_color		;a3c5
	jr L_A3E0		;a3c8
alterna_el_color:		; Cambia 0xA7BF de valor y devuelve 15 o 1
	ld a,(0a7bfh)		;a3ca   ; La bandera, que vive suelta en medio del codigo
	xor 001h		;a3cd   ; La cambia de valor
	ld (0a7bfh),a		;a3cf
	dec a			;a3d2
	ld a,00fh		;a3d3   ; Un color...
	jr z,L_A3D9		;a3d5
	ld a,001h		;a3d7   ; ...o el otro
L_A3D9:
	call L_DF76		;a3d9
	call 0fd9ah		;a3dc   ; BIOS HOOKS - System hooks
	ret			;a3df
L_A3E0:
	ld a,007h		;a3e0
	ld e,087h		;a3e2
	call 00093h		;a3e4   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;a3e7
	ld e,010h		;a3e9
	call 00093h		;a3eb   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;a3ee
	ld e,01fh		;a3f0
	call 00093h		;a3f2   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00ch		;a3f5
	ld e,020h		;a3f7
	call 00093h		;a3f9   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a3fc
	ld e,001h		;a3fd
	call 00093h		;a3ff   ; BIOS WRTPSG - Writes data to PSG-register
	nop			;a402
	nop			;a403
	nop			;a404
	ld hl,(0e030h)		;a405
	dec hl			;a408
	nop			;a409
	nop			;a40a
	sub a			;a40b
	ld de,00020h		;a40c
	exx			;a40f
	ld b,008h		;a410
L_A412:
	exx			;a412
	ld bc,00004h		;a413
	call 00056h		;a416   ; BIOS FILVRM - Fills VRAM with value
	add hl,de			;a419
	exx			;a41a
	djnz L_A412		;a41b
	nop			;a41d
	ld hl,(0e030h)		;a41e
	ld de,000a0h		;a421
	add hl,de			;a424
	ld a,025h		;a425
	call 0004dh		;a427   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a42a
	ld a,023h		;a42b
	call 0004dh		;a42d   ; BIOS WRTVRM - Writes data in VRAM
	ld b,004h		;a430
L_A432:
	call alterna_el_color		;a432
	push bc			;a435
	ld bc,02000h		;a436
	call espera		;a439
	pop bc			;a43c
	djnz L_A432		;a43d
	ld hl,(0e030h)		;a43f
	sub a			;a442
	ld de,000a0h		;a443
	add hl,de			;a446
	call 0004dh		;a447   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a44a
	call 0004dh		;a44b   ; BIOS WRTVRM - Writes data in VRAM
	call L_A8B5		;a44e
	call 0fd9ah		;a451   ; BIOS HOOKS - System hooks
	sub a			;a454
	ld (0e02ch),a		;a455
	ld a,001h		;a458
	call L_DF76		;a45a
	call 0fd9ah		;a45d   ; BIOS HOOKS - System hooks
	pop hl			;a460
	ret			;a461

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa462..0xa468  (6 bytes)
DATA_A462:
	defb 000h,000h,000h,000h,000h,000h	; a462

; ======================================================================
; CODIGO 0xa468..0xa47e  (22 bytes)
; ======================================================================


L_A468:
	call L_8930		;a468
	ld de,0001fh		;a46b
	ld b,004h		;a46e
L_A470:
	call L_A480		;a470
	inc hl			;a473
	call L_A480		;a474
	add hl,de			;a477
	djnz L_A470		;a478
	call 0fd9ah		;a47a   ; BIOS HOOKS - System hooks
	ret			;a47d

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa47e..0xa480  (2 bytes)
DATA_A47E:
	defb 000h,000h	; a47e

; ======================================================================
; CODIGO 0xa480..0xa497  (23 bytes)
; ======================================================================


L_A480:
	call 0004ah		;a480   ; BIOS RDVRM - Reads the content of VRAM
	cp 091h		;a483
	ret c			;a485
	cp 095h		;a486
	ret nc			;a488
	call L_A9E1		;a489
	ld a,001h		;a48c
	ld (08087h),a		;a48e
	call 0fd9ah		;a491   ; BIOS HOOKS - System hooks
	jp L_A558		;a494

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa497..0xa498  (1 bytes)
DATA_A497:
	defb 000h	; a497

; ======================================================================
; CODIGO 0xa498..0xa4c6  (46 bytes)
; ======================================================================


L_A498:
	ld a,(0e045h)		;a498
	or a			;a49b
	jp L_A4C8		;a49c
borra_cuatro_casillas:		; Pone a cero las cuatro casillas de la posicion de 0xE03B
	ld hl,(0e03bh)		;a49f   ; La posicion, empaquetada
	ld a,h			;a4a2
	exx			;a4a3
	ld l,a			;a4a4
	ld h,000h		;a4a5
	add hl,hl			;a4a7
	add hl,hl			;a4a8
	add hl,hl			;a4a9
	add hl,hl			;a4aa
	add hl,hl			;a4ab
	exx			;a4ac
	ld a,l			;a4ad
	exx			;a4ae
	ld e,a			;a4af
	ld d,000h		;a4b0
	add hl,de			;a4b2
	ld de,05480h		;a4b3   ; El mapa descomprimido
	add hl,de			;a4b6
	ld b,004h		;a4b7   ; Cuatro casillas
	sub a			;a4b9   ; La baldosa vacia
	ld de,0001fh		;a4ba   ; 31, para bajar de fila
escribe_dos_por_fila_2:		; Dos baldosas iguales por fila, B filas
	ld (hl),a			;a4bd   ; La primera
	inc hl			;a4be
	ld (hl),a			;a4bf   ; Y la de al lado
	add hl,de			;a4c0   ; Salta a la fila de abajo
	djnz escribe_dos_por_fila_2		;a4c1   ; Otra fila
	jp dibuja_el_objeto_tres		;a4c3

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa4c6..0xa4c8  (2 bytes)
DATA_A4C6:
	defb 000h,000h	; a4c6

; ======================================================================
; CODIGO 0xa4c8..0xa4d5  (13 bytes)
; ======================================================================


L_A4C8:
	jp z,dibuja_el_objeto_tres		;a4c8
	ld a,(08087h)		;a4cb
	or a			;a4ce
	jp z,dibuja_el_objeto_tres		;a4cf
	jp borra_cuatro_casillas		;a4d2

; ----------------------------------------------------------------------
; DATOS datos_A4D5: Tres bytes, 00 46 1A. Nadie los apunta
;   0xa4d5..0xa4d8  (3 bytes)
DATA_datos_A4D5:
	defb 000h,046h,01ah	; a4d5

; ======================================================================
; CODIGO 0xa4d8..0xa4ff  (39 bytes)
; ======================================================================


cuenta_para_el_dibujo:		; Cada dieciseis pasos, escribe el dibujo 0x0E
	ld hl,0807bh		;a4d8
	dec (hl)			;a4db   ; Cuenta atras
	ret nz			;a4dc   ; Todavia no
	ld (hl),010h		;a4dd   ; Se recarga a 16
	ld hl,(0807fh)		;a4df   ; La posicion
	ld a,00eh		;a4e2
L_A4E4:
	call 0004dh		;a4e4   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a4e7
	inc a			;a4e8
	call 0004dh		;a4e9   ; BIOS WRTVRM - Writes data in VRAM
	ld de,0001fh		;a4ec
	add hl,de			;a4ef
	ld (0807fh),hl		;a4f0
	ld de,01b00h		;a4f3
	rst 20h			;a4f6
	ret c			;a4f7
	ld hl,0fd9ah		;a4f8
	ld (08078h),hl		;a4fb
	ret			;a4fe

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa4ff..0xa500  (1 bytes)
DATA_A4FF:
	defb 000h	; a4ff

; ======================================================================
; CODIGO 0xa500..0xa50c  (12 bytes)
; ======================================================================


coloca_el_aviso:		; Con la bandera puesta, deja el aviso en 0x1A67
	ld a,(08087h)		;a500   ; La bandera
	or a			;a503
	ret z			;a504   ; Sin ella, nada
	ld hl,01a67h		;a505   ; La casilla del aviso
	ld (0807fh),hl		;a508
	ret			;a50b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa50c..0xa510  (4 bytes)
DATA_A50C:
	defb 000h,000h,000h,000h	; a50c

; ======================================================================
; CODIGO 0xa510..0xa58f  (127 bytes)
; ======================================================================


L_A510:
	call 0fd9ah		;a510   ; BIOS HOOKS - System hooks
	call L_97B8		;a513
	call 00041h		;a516   ; BIOS DISSCR - Inhibits the screen display
	ld hl,(08072h)		;a519
	ld a,l			;a51c
	cp 000h		;a51d
	jr z,L_A524		;a51f
	jp L_B88A		;a521
L_A524:
	ld hl,0700eh		;a524
	ld (08072h),hl		;a527
	ld hl,08048h		;a52a
L_A52D:
	ld (08049h),hl		;a52d
	sub a			;a530
	ld (08087h),a		;a531
	call 0fd9ah		;a534   ; BIOS HOOKS - System hooks
	call L_90F8		;a537
	call L_A110		;a53a
	nop			;a53d
	call 0fd9ah		;a53e   ; BIOS HOOKS - System hooks
	call pinta_al_jugador		;a541
	sub a			;a544
	ld (0804dh),a		;a545
	ld (0804eh),a		;a548
	ld (0804fh),a		;a54b
	ld (08050h),a		;a54e
	call 0fd9ah		;a551   ; BIOS HOOKS - System hooks
	call 00044h		;a554   ; BIOS ENASCR - Displays the screen
	ret			;a557
L_A558:
	sub a			;a558
	ld (0dfffh),a		;a559
	call L_A590		;a55c
	ret			;a55f
L_A560:
	inc hl			;a560
	inc hl			;a561
	call L_A392		;a562
	jr nz,L_A588		;a565
	ld a,0b1h		;a567
	call 0004dh		;a569   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;a56c
	ld (0e037h),hl		;a56d
	dec a			;a570
	call 0004dh		;a571   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;a574
	sub a			;a575
	call 0004dh		;a576   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,0e039h		;a579
	ld a,(hl)			;a57c
	add a,008h		;a57d
	ld (hl),a			;a57f
	cp 0efh		;a580
	jr nc,L_A588		;a582
	call 0fd9ah		;a584   ; BIOS HOOKS - System hooks
	ret			;a587
L_A588:
	ld hl,0e037h		;a588
	nop			;a58b
	jp L_A2FC		;a58c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa58f..0xa590  (1 bytes)
DATA_A58F:
	defb 000h	; a58f

; ======================================================================
; CODIGO 0xa590..0xa5cd  (61 bytes)
; ======================================================================


L_A590:
	ld hl,(0e000h)		;a590
	ld a,h			;a593
	add a,004h		;a594
	exx			;a596
	ld l,a			;a597
	ld h,000h		;a598
	add hl,hl			;a59a
	add hl,hl			;a59b
	add hl,hl			;a59c
	add hl,hl			;a59d
	add hl,hl			;a59e
	exx			;a59f
	ld a,l			;a5a0
	exx			;a5a1
	ld e,a			;a5a2
	ld d,000h		;a5a3
	add hl,de			;a5a5
	ld de,01800h		;a5a6
	add hl,de			;a5a9
	sub a			;a5aa
	call 0004dh		;a5ab   ; BIOS WRTVRM - Writes data in VRAM
	ld de,0001fh		;a5ae
	inc hl			;a5b1
	call 0004dh		;a5b2   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;a5b5
	call 0004dh		;a5b6   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a5b9
	call 0004dh		;a5ba   ; BIOS WRTVRM - Writes data in VRAM
	jp 0fd9ah		;a5bd   ; BIOS HOOKS - System hooks
mira_si_esta_congelado:		; Con 0x9C8F puesto no hace nada
	push af			;a5c0
	ld a,(09c8fh)		;a5c1   ; La bandera que congela el juego
	or a			;a5c4
	jr nz,L_A5CB		;a5c5   ; Puesta: por otro lado
	pop af			;a5c7
	jp L_C025		;a5c8   ; Y si no, la musica
L_A5CB:
	pop af			;a5cb
	ret			;a5cc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa5cd..0xa5d0  (3 bytes)
DATA_A5CD:
	defb 000h,000h,000h	; a5cd

; ======================================================================
; CODIGO 0xa5d0..0xa5e4  (20 bytes)
; ======================================================================


dibuja_el_objeto_tres:		; Si 0xE046 no es cero, saca su dibujo de la tabla de 0xA5E4
	ld a,(0e046h)		;a5d0   ; El numero de dibujo
	or a			;a5d3
	jp z,dibuja_el_objeto_uno		;a5d4   ; Cero: no hay objeto
	nop			;a5d7   ; Un NOP
	dec a			;a5d8   ; De numero a indice
	rlca			;a5d9   ; Por cuatro: cuatro baldosas por dibujo
	rlca			;a5da
	ld c,a			;a5db
	ld b,000h		;a5dc
	ld hl,0a5e4h		;a5de   ; La tabla de dibujos
	add hl,bc			;a5e1
	jr $+30		;a5e2

; ----------------------------------------------------------------------
; DATOS tabla_A5E4: Veintiocho bytes que cargan cuatro sitios distintos
;   (0xA5DE, 0xA64B, 0xA669 y 0xA687), siempre con LD HL,0xA5E4
;   0xa5e4..0xa600  (28 bytes)
DATA_tabla_A5E4:
	defb 014h,016h,015h,017h,081h,083h,082h,084h,085h,087h,086h,088h,089h,08bh	; a5e4  ..............
	defb 08ah,08ch,08dh,08fh,08eh,090h,099h,09bh,09ah,09ch,09dh,09fh,09eh,0a0h	; a5f2  ..............

; ======================================================================
; CODIGO 0xa600..0xa634  (52 bytes)
; ======================================================================


L_A600:
	ex de,hl			;a600
	ld hl,(0e047h)		;a601
	call dibuja_dos_por_dos		;a604
	jp dibuja_el_objeto_uno		;a607
dibuja_dos_por_dos:		; Escribe en el mapa el dibujo de (DE) en la casilla de HL
	push de			;a60a
	ld a,h			;a60b   ; La posicion, empaquetada
	exx			;a60c
	ld l,a			;a60d
	ld h,000h		;a60e
	add hl,hl			;a610
	add hl,hl			;a611
	add hl,hl			;a612
	add hl,hl			;a613
	add hl,hl			;a614
	exx			;a615
	ld a,l			;a616
	exx			;a617
	ld e,a			;a618
	ld d,000h		;a619
	add hl,de			;a61b
	ld de,05480h		;a61c   ; El mapa descomprimido
	add hl,de			;a61f
	pop de			;a620
	exx			;a621
	ld b,002h		;a622   ; Dos filas de dos
escribe_dos_por_fila:		; Escribe dos baldosas por fila, B filas, en el mapa
	exx			;a624
	ld a,(de)			;a625   ; Primera baldosa
	ld (hl),a			;a626
	inc hl			;a627
	inc de			;a628
	ld a,(de)			;a629   ; Segunda
	ld (hl),a			;a62a
	inc de			;a62b
	ld bc,0001fh		;a62c   ; 0x1F: lo que falta para la fila de abajo
	add hl,bc			;a62f
	exx			;a630
	djnz escribe_dos_por_fila		;a631   ; Otra fila
	ret			;a633

; ----------------------------------------------------------------------
; DATOS salto_huerfano: "jp 0xDAD0" y un cero. Ninguna instruccion llega aqui,
;   y 0xDAD0 cae dentro de los textos del monitor
;   0xa634..0xa638  (4 bytes)
DATA_A634:
	defb 0c3h,0d0h,0dah,000h	; a634

; ======================================================================
; CODIGO 0xa638..0xa7bf  (391 bytes)
; ======================================================================


dibuja_el_objeto_uno:		; Si 0xE049 no es cero, dibuja lo que diga en la posicion de 0xE04A
	ld a,(0e049h)		;a638   ; El numero de dibujo
	or a			;a63b
	jp z,dibuja_el_objeto_dos		;a63c   ; Cero: no hay objeto
	cp 000h		;a63f   ; Un "cp 0" detras de un "or a" que ya lo ha decidido, y cuatro NOP: aqui habia algo mas
	nop			;a641
	nop			;a642
	nop			;a643
	nop			;a644
	dec a			;a645   ; De numero a indice
	rlca			;a646   ; Por cuatro: las fichas son de cuatro baldosas
	rlca			;a647
	ld c,a			;a648
	ld b,000h		;a649
	ld hl,0a5e4h		;a64b   ; La tabla de dibujos
	add hl,bc			;a64e
	ex de,hl			;a64f
	ld hl,(0e04ah)		;a650   ; La posicion
	call dibuja_dos_por_dos		;a653
dibuja_el_objeto_dos:		; Lo mismo con 0xE04C y 0xE04D
	ld a,(0e04ch)		;a656   ; El numero de dibujo
	or a			;a659
	jp z,L_A674		;a65a   ; Cero: no hay objeto
	nop			;a65d   ; Seis NOP seguidos: la comprobacion que habia aqui se quito
	nop			;a65e
	nop			;a65f
	nop			;a660
	nop			;a661
	nop			;a662
	dec a			;a663   ; De numero a indice
	rlca			;a664   ; Por cuatro
	rlca			;a665
	ld c,a			;a666
	ld b,000h		;a667
	ld hl,0a5e4h		;a669   ; La tabla de dibujos
	add hl,bc			;a66c
	ex de,hl			;a66d
	ld hl,(0e04dh)		;a66e   ; La posicion
	call dibuja_dos_por_dos		;a671
L_A674:
	ld a,(0e04fh)		;a674
	or a			;a677
	jp z,0fd9ah		;a678   ; BIOS HOOKS - System hooks
	nop			;a67b
	nop			;a67c
	nop			;a67d
	nop			;a67e
	nop			;a67f
	nop			;a680
	dec a			;a681
	rlca			;a682
	rlca			;a683
	ld c,a			;a684
	ld b,000h		;a685
	ld hl,0a5e4h		;a687
	add hl,bc			;a68a
	ex de,hl			;a68b
	ld hl,(0e050h)		;a68c
	call dibuja_dos_por_dos		;a68f
	call 0fd9ah		;a692   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;a695   ; BIOS HOOKS - System hooks
apunta_la_ficha_3:		; El tercer gemelo de 0x94A0
	ld hl,(08072h)		;a698   ; La entrada en curso
	push af			;a69b
	ld a,l			;a69c   ; El numero, dividido por dos
	rrca			;a69d
	ld hl,070c0h		;a69e   ; La tabla de fichas de la RAM escondida
	or a			;a6a1
	jr z,copia_la_ficha		;a6a2
	ld de,00058h		;a6a4   ; 0x58 = 88 bytes, una ficha
L_A6A7:
	add hl,de			;a6a7
	dec a			;a6a8
	jr nz,L_A6A7		;a6a9
copia_la_ficha:		; Se trae los 88 bytes de la ficha al tampon
	ex de,hl			;a6ab
	call mira_los_dos_campos		;a6ac   ; Lo que haya que hacer antes
	ld bc,00058h		;a6af   ; 0x58 = 88 bytes
	ldir		;a6b2   ; Se copia
	pop af			;a6b4
	jp L_9478		;a6b5
L_A6B8:
	call 0fd9ah		;a6b8   ; BIOS HOOKS - System hooks
	ld hl,0e046h		;a6bb
	call mira_si_hay_algo_cerca		;a6be
	ld hl,0e049h		;a6c1
	call mira_si_hay_algo_cerca		;a6c4
	ld hl,0e04ch		;a6c7
	call mira_si_hay_algo_cerca		;a6ca
	ld hl,0e04fh		;a6cd
mira_si_hay_algo_cerca:		; Recorre una lista y, si el jugador esta a tiro, la borra de la pantalla
	ld a,(hl)			;a6d0   ; Primer byte de la ficha: cero significa "no hay nada"
	or a			;a6d1
	ret z			;a6d2
	nop			;a6d3
	inc hl			;a6d4   ; Segundo byte: la coordenada X, en octavos
	ld a,(hl)			;a6d5
	rlca			;a6d6   ; Por ocho: de casillas a pixeles
	rlca			;a6d7
	rlca			;a6d8
	ld e,a			;a6d9
	inc hl			;a6da   ; Tercer byte: la Y, igual
	ld a,(hl)			;a6db
	rlca			;a6dc
	rlca			;a6dd
	rlca			;a6de
	ld d,a			;a6df
	ld a,(08049h)		;a6e0   ; La X del jugador
	sub 00eh		;a6e3   ; Catorce pixeles por delante
	cp e			;a6e5   ; Si el objeto queda mas a la derecha, no toca
	ret nc			;a6e6
	add a,01eh		;a6e7   ; Treinta pixeles de ventana
	cp e			;a6e9   ; Si queda mas a la izquierda, tampoco
	ret c			;a6ea
	ld a,(0804ah)		;a6eb   ; La Y del jugador
	sub 020h		;a6ee
	add a,018h		;a6f0
	cp d			;a6f2   ; Misma comprobacion en vertical
	ret c			;a6f3
	sub 028h		;a6f4
	cp d			;a6f6
	ret nc			;a6f7
	call 0fd9ah		;a6f8   ; BIOS HOOKS - System hooks | Vector de sonido
	nop			;a6fb
	ld d,(hl)			;a6fc
	dec hl			;a6fd
	ld e,(hl)			;a6fe
	dec hl			;a6ff
	ld a,(hl)			;a700
	nop			;a701
	nop			;a702
	nop			;a703
	nop			;a704
	nop			;a705
	ld (hl),000h		;a706   ; Borra la ficha: ya no hay nada aqui
	ld a,d			;a708   ; D era la fila; +4 por el marco de arriba
	add a,004h		;a709
	ld l,a			;a70b
	ld h,000h		;a70c
	add hl,hl			;a70e   ; Por 32: cinco desplazamientos a la izquierda son las 32 columnas
	add hl,hl			;a70f
	add hl,hl			;a710
	add hl,hl			;a711
	add hl,hl			;a712
	ld d,000h		;a713
	add hl,de			;a715
	ld de,01800h		;a716   ; Y el origen de la tabla de nombres de la VRAM
	add hl,de			;a719
	sub a			;a71a   ; La baldosa vacia
	call 0004dh		;a71b   ; BIOS WRTVRM - Writes data in VRAM | Borra las cuatro casillas del objeto: dos arriba...
	inc hl			;a71e
	call 0004dh		;a71f   ; BIOS WRTVRM - Writes data in VRAM
	ld de,0001fh		;a722   ; ...y las dos de la fila de abajo, 0x20 casillas mas alla
	add hl,de			;a725
	call 0004dh		;a726   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;a729
	call 0004dh		;a72a   ; BIOS WRTVRM - Writes data in VRAM
	ld b,00fh		;a72d   ; Quince pasos de la animacion de recogida
	call L_A882		;a72f
	call 0fd9ah		;a732   ; BIOS HOOKS - System hooks
	call L_A750		;a735
	ld a,r		;a738   ; El registro de refresco vale de dado
	and 01fh		;a73a   ; Un numero de 0 a 31
	add a,004h		;a73c   ; Y nunca menos de cuatro
	ld b,a			;a73e
L_A73F:
	call L_87D2		;a73f
	djnz L_A73F		;a742
	call 0003bh		;a744   ; BIOS INITIO - Initialises the device
	nop			;a747
	nop			;a748
	call 0fd9ah		;a749   ; BIOS HOOKS - System hooks
	call 0fd9ah		;a74c   ; BIOS HOOKS - System hooks
	ret			;a74f
L_A750:
	call 0fd9ah		;a750   ; BIOS HOOKS - System hooks
	ld hl,0806ch		;a753
	nop			;a756
	ret			;a757
casilla_del_marcador:		; Convierte la posicion de 0x806C en una casilla de la fila 0x1840
	ld a,(0806ch)		;a758   ; La posicion
	call divide_entre_ocho		;a75b
	ex af,af'			;a75e
	ld a,(0806ch)		;a75f
	and 0f8h		;a762   ; Se queda con los multiplos de ocho
	rrca			;a764   ; Y divide por ocho
	rrca			;a765
	rrca			;a766
	ld hl,01840h		;a767   ; La fila del marcador en la VRAM
	add a,l			;a76a
	ld l,a			;a76b
	ex af,af'			;a76c
	jr nc,L_A770		;a76d
	nop			;a76f   ; Un NOP
L_A770:
	sub a			;a770
	ret			;a771
L_A772:
	ld hl,0806ch		;a772
	dec (hl)			;a775
	jp L_87B2		;a776
L_A779:
	ld hl,0806ch		;a779
	inc (hl)			;a77c
	jp L_87B2		;a77d
L_A780:
	ld hl,0806ch		;a780
	dec (hl)			;a783
	ret			;a784
L_A785:
	call L_A9C0		;a785
	ld hl,07000h		;a788
	ld (08072h),hl		;a78b
	call 0fd9ah		;a78e   ; BIOS HOOKS - System hooks
	ld hl,08060h		;a791
	ld b,006h		;a794
L_A796:
	ld (hl),030h		;a796
	inc hl			;a798
	djnz L_A796		;a799
	call pon_pantalla		;a79b
	ret			;a79e
L_A79F:
	ld hl,08066h		;a79f
	ld de,08060h		;a7a2
compara_y_guarda:		; Compara dos cadenas y, si la primera no es menor, copia seis bytes
	ld a,(de)			;a7a5   ; Byte a byte
	cp (hl)			;a7a6
	inc hl			;a7a7
	inc de			;a7a8
	ret c			;a7a9   ; Con acarreo, la primera es menor
	jr z,compara_y_guarda		;a7aa   ; Iguales: sigue comparando
	ld hl,08060h		;a7ac   ; Origen
	ld de,08066h		;a7af   ; Destino
	ld bc,00006h		;a7b2   ; Seis bytes
	ldir		;a7b5
	ret			;a7b7
L_A7B8:
	call L_A79F		;a7b8
	call L_97B8		;a7bb
	ret			;a7be

; ----------------------------------------------------------------------
; DATOS bandera_A7BF: Un byte de bandera que leen y escriben 0xA3CA y 0xA3CF
;   0xa7bf..0xa7c0  (1 bytes)
DATA_bandera_A7BF:
	defb 001h	; a7bf

; ======================================================================
; CODIGO 0xa7c0..0xa7ce  (14 bytes)
; ======================================================================


L_A7C0:
	ld b,030h		;a7c0
L_A7C2:
	call L_87D2		;a7c2
	djnz L_A7C2		;a7c5
	ret			;a7c7
L_A7C8:
	call reparte_por_lo_pedido		;a7c8
	jp L_A7E8		;a7cb

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa7ce..0xa7d0  (2 bytes)
DATA_A7CE:
	defb 000h,000h	; a7ce

; ======================================================================
; CODIGO 0xa7d0..0xa7e5  (21 bytes)
; ======================================================================


L_A7D0:
	call reparte_por_lo_pedido		;a7d0
	ld a,(0804eh)		;a7d3
	or a			;a7d6
	jr z,L_A7DB		;a7d7
	jr L_A7E1		;a7d9
L_A7DB:
	ld a,(0805bh)		;a7db
	jp reparte_por_estado_2		;a7de
L_A7E1:
	ld sp,0e1aah		;a7e1
	ret			;a7e4

; ----------------------------------------------------------------------
; DATOS datos_A7E5: Tres bytes, BB 88 00. Nadie los apunta
;   0xa7e5..0xa7e8  (3 bytes)
DATA_datos_A7E5:
	defb 0bbh,088h,000h	; a7e5

; ======================================================================
; CODIGO 0xa7e8..0xa7ff  (23 bytes)
; ======================================================================


L_A7E8:
	sub a			;a7e8
	ld (0805bh),a		;a7e9
	ld sp,0e1ach		;a7ec
	jp tanda_del_bucle_principal		;a7ef
L_A7F2:
	ld b,003h		;a7f2
	ld a,008h		;a7f4
	ld e,000h		;a7f6
L_A7F8:
	call 00093h		;a7f8   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a7fb
	djnz L_A7F8		;a7fc
	ret			;a7fe

; ----------------------------------------------------------------------
; DATOS tabla_A7FF: Dieciocho bytes; 0xA9D1 carga 0xA801 en BC
;   0xa7ff..0xa811  (18 bytes)
DATA_tabla_A7FF:
	defb 000h,0cdh,026h,081h,0cdh,000h,0dch,0c3h,0b8h,088h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a7ff  ..&...............

; ======================================================================
; CODIGO 0xa811..0xa830  (31 bytes)
; ======================================================================


L_A811:
	call L_A81A		;a811
	call 0fd9ah		;a814   ; BIOS HOOKS - System hooks
	jp L_8B27		;a817
L_A81A:
	call L_8930		;a81a
	ld b,004h		;a81d
	ld de,0001fh		;a81f
L_A822:
	call L_A850		;a822
	inc hl			;a825
	call L_A850		;a826
	add hl,de			;a829
	djnz L_A822		;a82a
	call 0fd9ah		;a82c   ; BIOS HOOKS - System hooks
	ret			;a82f

; ----------------------------------------------------------------------
; DATOS tabla_de_baldosas_2: Treinta y dos codigos de baldosa que recorre
;   0xA854
;   0xa830..0xa850  (32 bytes)
DATA_tabla_de_baldosas_2:
	defb 0ffh,0ffh,062h,00ah,00bh,00ch,00dh,06eh,06fh,095h,096h,097h,098h,0a8h,0a9h,0aah	; a830  ..b....no.......
	defb 0abh,0ach,0adh,0aeh,0afh,0b0h,0b1h,0b2h,0b3h,05bh,05ch,05dh,05eh,05fh,060h,061h	; a840  .........[\]^_`a

; ======================================================================
; CODIGO 0xa850..0xa89f  (79 bytes)
; ======================================================================


L_A850:
	call 0004ah		;a850   ; BIOS RDVRM - Reads the content of VRAM
	exx			;a853
	ld hl,0a830h		;a854
	ld bc,00020h		;a857
	cpir		;a85a
	call z,L_DF6C		;a85c
	exx			;a85f
	ret			;a860
L_A861:
	call sale_si_esta_congelado_2		;a861
L_A864:
	ld a,(hl)			;a864
	cp 039h		;a865
	jr z,L_A86B		;a867
	inc (hl)			;a869
	ret			;a86a
L_A86B:
	ld (hl),030h		;a86b
	jp compara_con_el_limite		;a86d
L_A870:
	ld hl,08060h		;a870
	ld de,01809h		;a873
	ld bc,00006h		;a876
	call 0005ch		;a879   ; BIOS LDIRVM - Block transfers to VRAM from memory
	call 0fd9ah		;a87c   ; BIOS HOOKS - System hooks
	ret			;a87f
L_A880:
	ld b,00ah		;a880
L_A882:
	ld a,(09c8fh)		;a882
	or a			;a885
	ret nz			;a886
L_A887:
	call L_A861		;a887
	djnz L_A887		;a88a
	call L_A870		;a88c
	ret			;a88f
L_A890:
	ld a,(080aeh)		;a890
	cp 003h		;a893
	jp c,L_A0D8		;a895
	pop hl			;a898
	ret			;a899
L_A89A:
	ld b,019h		;a89a
	jp L_A882		;a89c

; ----------------------------------------------------------------------
; DATOS datos_A89F: Trece bytes entre dos rutinas. Ninguna instruccion los
;   apunta
;   0xa89f..0xa8ac  (13 bytes)
DATA_datos_A89F:
	defb 000h,03ah,08fh,09ch,0b7h,028h,002h,0e1h,0c9h,021h,064h,080h,0c9h	; a89f  .:...(...!d..

; ======================================================================
; CODIGO 0xa8ac..0xa8f6  (74 bytes)
; ======================================================================


L_A8AC:
	ld (0809eh),a		;a8ac
	ld a,000h		;a8af
	call L_BEBB		;a8b1
	ret			;a8b4
L_A8B5:
	ld b,097h		;a8b5
	call L_A882		;a8b7
	ret			;a8ba
L_A8BB:
	ld a,(0e036h)		;a8bb
	cp 001h		;a8be
	jr z,L_A8C6		;a8c0
	ld hl,0e02dh		;a8c2
	ret			;a8c5
L_A8C6:
	call L_8930		;a8c6
	ld de,0001fh		;a8c9
	ld b,004h		;a8cc
L_A8CE:
	call mira_la_baldosa		;a8ce
	inc hl			;a8d1
	call mira_la_baldosa		;a8d2
	add hl,de			;a8d5
	jr L_A8F0		;a8d6
mira_la_baldosa:		; Lee la baldosa de la VRAM y solo actua con las de 0xB0 a 0xB3
	call 0004ah		;a8d8   ; BIOS RDVRM - Reads the content of VRAM | Lee la casilla
	cp 0b0h		;a8db   ; Por debajo de 0xB0 no vale
	ret c			;a8dd
	cp 0b4h		;a8de   ; Y de 0xB4 para arriba tampoco
	ret nc			;a8e0
	push hl			;a8e1
	push de			;a8e2
	push bc			;a8e3
	call L_A2FC		;a8e4   ; Lo que toque hacer con ella
	pop bc			;a8e7
	pop de			;a8e8
	pop hl			;a8e9
	call L_A8F8		;a8ea
	jp L_A959		;a8ed
L_A8F0:
	djnz L_A8CE		;a8f0
	ld hl,0e02dh		;a8f2
	ret			;a8f5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa8f6..0xa8f8  (2 bytes)
DATA_A8F6:
	defb 000h,000h	; a8f6

; ======================================================================
; CODIGO 0xa8f8..0xa937  (63 bytes)
; ======================================================================


L_A8F8:
	call sale_si_esta_ocupado		;a8f8
	ld a,00eh		;a8fb
	call 0004dh		;a8fd   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00004h		;a900
	add hl,de			;a903
	ld a,00fh		;a904
	call 0004dh		;a906   ; BIOS WRTVRM - Writes data in VRAM
	ld a,002h		;a909
	ld (0805dh),a		;a90b
	add hl,de			;a90e
	ld a,00eh		;a90f
	call 0004dh		;a911   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;a914
	ld a,00fh		;a915
	call 0004dh		;a917   ; BIOS WRTVRM - Writes data in VRAM
	call L_B2E0		;a91a
	ld a,001h		;a91d
	ld (0809eh),a		;a91f
	call L_91B1		;a922
	ld a,001h		;a925
	ld e,004h		;a927
	call 00093h		;a929   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00dh		;a92c
	ld e,005h		;a92e
	call 00093h		;a930   ; BIOS WRTPSG - Writes data to PSG-register
	call arranca_la_pausa		;a933
	ret			;a936

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa937..0xa938  (1 bytes)
DATA_A937:
	defb 000h	; a937

; ======================================================================
; CODIGO 0xa938..0xaa20  (232 bytes)
; ======================================================================


L_A938:
	sub a			;a938
	ld (0809eh),a		;a939
	call 0fd9ah		;a93c   ; BIOS HOOKS - System hooks
	ret			;a93f
L_A940:
	call L_A882		;a940
	ld e,a			;a943
	inc a			;a944
	jp 00093h		;a945   ; BIOS WRTPSG - Writes data to PSG-register
arranca_la_pausa:		; Enciende la bandera y sortea cuanto dura
	nop			;a948   ; Dos NOP
	nop			;a949
	ld a,001h		;a94a   ; La bandera de ocupado
	ld (080a9h),a		;a94c
	ld a,r		;a94f   ; El registro de refresco hace de dado
	and 01fh		;a951   ; De 0 a 31
	add a,008h		;a953   ; Y nunca menos de ocho
	ld (080aah),a		;a955
	ret			;a958
L_A959:
	ld a,(0e034h)		;a959
	ld (0805ch),a		;a95c
	ret			;a95f
mira_si_esta_ocupado:		; Con la bandera puesta, atiende la pausa
	ld a,(080a9h)		;a960   ; La bandera de ocupado
	or a			;a963
	jp z,baja_al_jugador		;a964   ; Libre: a lo suyo
	pop hl			;a967   ; Se quita la vuelta de la pila
	ld a,(0805ch)		;a968   ; El sentido
	inc a			;a96b
	jr z,L_A973		;a96c
	call L_8A64		;a96e
	jr acaba_la_pausa		;a971   ; Y a ver si la pausa se acaba
L_A973:
	call L_89D6		;a973
acaba_la_pausa:		; Cuando la cuenta llega a cero, quita la bandera y repone el paso
	call refresca_con_la_bandera		;a976
	ld hl,080aah		;a979   ; Cuenta atras
	dec (hl)			;a97c
	ret nz			;a97d   ; Todavia no
	sub a			;a97e
	ld (080a9h),a		;a97f   ; Quita la bandera de ocupado
	ld a,006h		;a982
	ld (0805dh),a		;a984   ; Paso base, seis
	ld a,(080fah)		;a987
	ld (0805ch),a		;a98a   ; Y repone el sentido guardado
	jp L_AF44		;a98d
prepara_el_dibujo:		; Calcula un desplazamiento por ocho y deja un par de dibujos en BC
	ex af,af'			;a990
	ld a,(0e032h)		;a991   ; El indice
	dec a			;a994
	dec a			;a995
	rlca			;a996   ; Por ocho
	rlca			;a997
	rlca			;a998
	ld (0e039h),a		;a999   ; Se guarda
	ex af,af'			;a99c
	ld bc,07579h		;a99d   ; El par de dibujos
	ret			;a9a0
prepara_el_dibujo_2:		; Suma cuatro, multiplica por ocho y devuelve un par
	ld a,(0e032h)		;a9a1   ; El indice
	add a,004h		;a9a4   ; Cuatro mas
	rlca			;a9a6   ; Por ocho
	rlca			;a9a7
	rlca			;a9a8
	ld (0e039h),a		;a9a9   ; Se guarda
	ld bc,07077h		;a9ac   ; El par de dibujos
	ret			;a9af
refresca_con_la_bandera:		; Pinta con 0x0000 a uno y lo vuelve a dejar a cero
	call pinta_al_jugador		;a9b0   ; Lo pinta
	ld a,001h		;a9b3
	ld (00000h),a		;a9b5   ; Escribe en 0x0000: con la pagina 0 en ROM esto no hace nada
	call L_9164		;a9b8   ; Refresca el marcador
	sub a			;a9bb
	ld (00000h),a		;a9bc   ; Y lo deshace
	ret			;a9bf
L_A9C0:
	sub a			;a9c0
	ld (080a9h),a		;a9c1
	call 0fd9ah		;a9c4   ; BIOS HOOKS - System hooks
	ret			;a9c7
pinta_y_elige_el_par:		; Pinta y deja preparado el par del lado que toque
	call pinta_un_sprite		;a9c8   ; Lo pinta
	push af			;a9cb
	push bc			;a9cc
	ld a,(0805ch)		;a9cd   ; El sentido
	dec a			;a9d0
	ld bc,0a801h		;a9d1   ; Un par...
	jr z,L_A9D9		;a9d4
	ld bc,00202h		;a9d6   ; ...o el otro
L_A9D9:
	ld a,012h		;a9d9
	call pinta_un_sprite		;a9db
	pop bc			;a9de
	pop af			;a9df
	ret			;a9e0
L_A9E1:
	ld e,055h		;a9e1
	sub a			;a9e3
	call 00093h		;a9e4   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,a			;a9e7
	inc a			;a9e8
	call 00093h		;a9e9   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;a9ec
	ld e,010h		;a9ee
	call 00093h		;a9f0   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00ch		;a9f3
	ld e,010h		;a9f5
	call 00093h		;a9f7   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;a9fa
	ld e,001h		;a9fb
	jp 00093h		;a9fd   ; BIOS WRTPSG - Writes data to PSG-register
L_AA00:
	ld hl,0e002h		;aa00
	call interpreta_un_guion		;aa03
	ld hl,0e017h		;aa06
	call interpreta_un_guion		;aa09
	ret			;aa0c
interpreta_un_guion:		; Interprete de guiones: lee el opcode de (HL) y salta por la tabla de 0xAA20
	ld (080c0h),hl		;aa0d   ; Guarda el puntero del guion donde lo puedan ver los manejadores
	ld a,(hl)			;aa10   ; El opcode
	or a			;aa11
	ret z			;aa12   ; El cero termina el guion
	rlca			;aa13   ; Por dos, que la tabla es de palabras
	ld c,a			;aa14
	ld b,000h		;aa15
	ld hl,0aa20h		;aa17   ; La tabla de saltos
	add hl,bc			;aa1a
	ld e,(hl)			;aa1b   ; El manejador
	inc hl			;aa1c
	ld d,(hl)			;aa1d
	push de			;aa1e   ; PUSH y RET: asi el manejador vuelve directamente a quien llamo aqui
	ret			;aa1f

; ----------------------------------------------------------------------
; DATOS tabla_de_opcodes: La tabla de saltos del interprete de guiones: doce
;   punteros, uno por opcode, que lee 0xAA17. Los opcodes 0, 1, 2 y 11 apuntan
;   a 0xFD9A, o sea al vector de sonido
;   0xaa20..0xaa38  (24 bytes)
DATA_tabla_de_opcodes:
	defw 0fd9ah	; aa20
	defw 0fd9ah	; aa22
	defw 0fd9ah	; aa24
	defw 0afb8h	; aa26  -> arranca_si_esta_parado
	defw 0ac18h	; aa28  -> L_AC18
	defw 0bc30h	; aa2a  -> opcode_cinco_del_guion
	defw 09928h	; aa2c  -> opcode_seis_del_guion
	defw 0b774h	; aa2e  -> opcode_siete_del_guion
	defw 0ae60h	; aa30  -> L_AE60
	defw 0aa48h	; aa32  -> L_AA48
	defw 0b898h	; aa34  -> opcode_diez_del_guion
	defw 0fd9ah	; aa36

; ======================================================================
; CODIGO 0xaa38..0xaa47  (15 bytes)
; ======================================================================


copia_el_guion:		; Se trae los 19 bytes del guion en curso a 0x80AB
	ld hl,(080c0h)		;aa38   ; El puntero del guion
	ld bc,00013h		;aa3b   ; 0x13 = 19 bytes
	ld de,080abh		;aa3e   ; El area de trabajo
	ldir		;aa41
	ld hl,080ach		;aa43   ; Y devuelve donde empieza
	ret			;aa46

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xaa47..0xaa48  (1 bytes)
DATA_AA47:
	defb 000h	; aa47

; ======================================================================
; CODIGO 0xaa48..0xaa87  (63 bytes)
; ======================================================================


L_AA48:
	call L_AB60		;aa48
	nop			;aa4b
	jp L_AB48		;aa4c
apunta_la_casilla:		; Guarda la casilla de delante y prueba las dos de al lado
	nop			;aa4f   ; Un NOP
	ld (hl),a			;aa50
	ld hl,(080afh)		;aa51   ; La posicion
	call L_8939		;aa54   ; A casilla del mapa
	ld (080beh),hl		;aa57   ; Se guarda
	call L_8930		;aa5a
	ld hl,(080beh)		;aa5d
	ld a,(080b1h)		;aa60   ; El sentido
	inc a			;aa63   ; 0xFF quiere decir "hacia atras"
	jr z,$+62		;aa64
	inc hl			;aa66   ; Dos casillas mas alla
	inc hl			;aa67
	call L_AA6D		;aa68
	jr $+29		;aa6b
L_AA6D:
	call 0004ah		;aa6d   ; BIOS RDVRM - Reads the content of VRAM
	cp 001h		;aa70
	ret z			;aa72
	cp 002h		;aa73
	nop			;aa75
	cp 0b4h		;aa76
	ret z			;aa78
	cp 0b5h		;aa79
	ret z			;aa7b
	cp 003h		;aa7c
	ret c			;aa7e
	cp 00ah		;aa7f
	ret nc			;aa81
	sub a			;aa82
	call 0fd9ah		;aa83   ; BIOS HOOKS - System hooks
	ret			;aa86

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xaa87..0xaa88  (1 bytes)
DATA_AA87:
	defb 000h	; aa87

; ======================================================================
; CODIGO 0xaa88..0xaa95  (13 bytes)
; ======================================================================


prueba_la_de_abajo:		; Baja una fila y prueba la casilla
	jr z,$+16		;aa88
	ld de,00020h		;aa8a   ; Una fila
	add hl,de			;aa8d
	call L_AA6D		;aa8e   ; La prueba
	jr z,$+7		;aa91
	jr $+8		;aa93

; ----------------------------------------------------------------------
; DATOS llamada_al_monitor_huerfana: Tres bytes: "call 0xC924", o sea una
;   llamada al monitor de Loriciels, a la que no llega ningun salto. Es la
;   segunda que aparece en el bloque; la otra, en 0x9C72, si esta viva
;   0xaa95..0xaa98  (3 bytes)
DATA_llamada_al_monitor_huerfana:
	defb 0cdh,024h,0c9h	; aa95

; ======================================================================
; CODIGO 0xaa98..0xaaa1  (9 bytes)
; ======================================================================


L_AA98:
	jp L_AB50		;aa98
L_AA9B:
	ld hl,080afh		;aa9b
	inc (hl)			;aa9e
	jr $+22		;aa9f

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xaaa1..0xaaa2  (1 bytes)
DATA_AAA1:
	defb 000h	; aaa1

; ======================================================================
; CODIGO 0xaaa2..0xab47  (165 bytes)
; ======================================================================


prueba_las_de_alrededor:		; Prueba la anterior y la de una fila mas abajo
	dec hl			;aaa2   ; Una atras
	call L_AA6D		;aaa3   ; La prueba
	jr z,$-14		;aaa6
	ld de,00020h		;aaa8   ; Una fila
	add hl,de			;aaab
	call L_AA6D		;aaac   ; La prueba
	jr z,$-23		;aaaf
	ld hl,080afh		;aab1   ; Y retrocede la posicion
	dec (hl)			;aab4
comprueba_el_camino:		; Rechaza la casilla si esta fuera de rango y prueba las dos de debajo
	ld a,(hl)			;aab5   ; La baldosa de la casilla
	cp 0f0h		;aab6   ; De 0xF0 para arriba no vale
	jp nc,L_AB50		;aab8
	cp 001h		;aabb   ; Y la 0 tampoco
	jp c,L_AB50		;aabd
	ld hl,(080beh)		;aac0   ; La casilla en curso del mapa
	ld a,(080b2h)		;aac3   ; El sentido de la marcha
	inc a			;aac6
	jr z,prueba_las_de_arriba		;aac7   ; 0xFF, o sea -1: hacia el otro lado
	ld de,00040h		;aac9   ; 0x40 = dos filas de 32
	add hl,de			;aacc
	call L_AA6D		;aacd   ; Prueba la primera casilla
	jp z,L_AB5B		;aad0
	inc hl			;aad3   ; Y la de al lado
	call L_AA6D		;aad4
	jp z,L_AB5B		;aad7
	ld hl,080b0h		;aada   ; Avanza la posicion
	inc (hl)			;aadd
	jr L_AAF5		;aade
prueba_las_de_arriba:		; 0xFFE0 es -32: una fila mas arriba
	ld de,0ffe0h		;aae0   ; Una fila hacia arriba
	add hl,de			;aae3
	call L_AA6D		;aae4   ; La prueba
	jp z,L_AB5B		;aae7
	inc hl			;aaea
	call L_AA6D		;aaeb   ; Y la de al lado
	jp z,L_AB5B		;aaee
	ld hl,080b0h		;aaf1   ; Retrocede la posicion
	dec (hl)			;aaf4
L_AAF5:
	ld a,(hl)			;aaf5
	cp 01ch		;aaf6
	jp c,L_AB5B		;aaf8
	cp 0b8h		;aafb
	jp nc,L_AB5B		;aafd
elige_el_numero_de_sprite:		; Segun el guion, el sprite 8 o el 0x0C
	ld hl,(080c0h)		;ab00   ; El puntero del guion
	ld a,l			;ab03
	cp 002h		;ab04   ; El primer byte
	ld a,008h		;ab06   ; Sprite 8...
	jr z,pinta_al_bicho		;ab08
	ld a,00ch		;ab0a   ; ...o el 0x0C
pinta_al_bicho:		; Sube los dos planos del sprite del bicho y avanza su dibujo
	ex af,af'			;ab0c
	ld hl,080b4h		;ab0d   ; Cuenta atras del cambio de dibujo
	dec (hl)			;ab10
	jr nz,L_AB2C		;ab11   ; Todavia no
	ld (hl),002h		;ab13   ; Se recarga a 2
	ld a,(080b3h)		;ab15   ; El dibujo en curso
	ld b,a			;ab18
	ld c,002h		;ab19   ; El banco de sprites: este byte lo REESCRIBE 0xABB3 en marcha
	ex af,af'			;ab1b
	call pinta_un_sprite		;ab1c   ; Primer plano de color
	dec a			;ab1f   ; Dos registros mas atras: el segundo plano
	dec a			;ab20
	ex af,af'			;ab21
	ld a,b			;ab22
	cp 0c0h		;ab23   ; Al llegar al final del ciclo...
	jr nz,L_AB29		;ab25
	ld a,0a4h		;ab27   ; ...rebobina
L_AB29:
	ld (080b3h),a		;ab29
L_AB2C:
	ld hl,(080afh)		;ab2c
	ex af,af'			;ab2f
	call L_8310		;ab30
	call 0fd9ah		;ab33   ; BIOS HOOKS - System hooks
	call L_AB3A		;ab36
	ret			;ab39
L_AB3A:
	ld bc,00015h		;ab3a
	ld de,(080c0h)		;ab3d
	ld hl,080abh		;ab41
	ldir		;ab44
	ret			;ab46

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xab47..0xab48  (1 bytes)
DATA_AB47:
	defb 000h	; ab47

; ======================================================================
; CODIGO 0xab48..0xab67  (31 bytes)
; ======================================================================


L_AB48:
	nop			;ab48
	nop			;ab49
	ld a,(080adh)		;ab4a
	jp apunta_la_casilla		;ab4d
L_AB50:
	ld hl,080b1h		;ab50
L_AB53:
	ld a,(hl)			;ab53
	call L_8193		;ab54
	ld (hl),a			;ab57
	jp elige_el_numero_de_sprite		;ab58
L_AB5B:
	ld hl,080b2h		;ab5b
	jr L_AB53		;ab5e
L_AB60:
	call copia_el_guion		;ab60
	call L_AC0C		;ab63
	ret			;ab66

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xab67..0xab68  (1 bytes)
DATA_AB67:
	defb 000h	; ab67

; ======================================================================
; CODIGO 0xab68..0xac15  (173 bytes)
; ======================================================================


L_AB68:
	ld a,(080aeh)		;ab68
	cp 004h		;ab6b
	jp L_AB9E		;ab6d
L_AB70:
	ld hl,(080afh)		;ab70
	call L_AE38		;ab73
	jr z,L_AB7C		;ab76
	ld hl,080ach		;ab78
	ret			;ab7b
L_AB7C:
	call L_A890		;ab7c
	call 0fd9ah		;ab7f   ; BIOS HOOKS - System hooks
	ld hl,080b9h		;ab82
	dec (hl)			;ab85
	jr z,pasa_al_estado_cuatro		;ab86
	ld hl,080ach		;ab88
	ret			;ab8b
pasa_al_estado_cuatro:		; Estado 4, dibujo 0x80 y salida por dos niveles
	ld a,004h		;ab8c   ; Estado 4
	ld (080aeh),a		;ab8e
	ld a,080h		;ab91   ; Dibujo de partida
	ld (080b3h),a		;ab93
	call L_AC03		;ab96
	pop hl			;ab99   ; Dos POP: no se vuelve a quien llamo
	pop hl			;ab9a
	jp L_AB3A		;ab9b
L_AB9E:
	ex af,af'			;ab9e
	ld hl,080ach		;ab9f
	dec (hl)			;aba2
	jr z,cambia_de_banco_de_sprites		;aba3
L_ABA5:
	pop hl			;aba5
	pop hl			;aba6
	jp L_AB3A		;aba7
cambia_de_banco_de_sprites:		; Reescribe el operando de 0xAB1A para pintar del banco 1 o del 2
	ld a,(080adh)		;abaa   ; El periodo, que se recarga
	ld (hl),a			;abad
	ex af,af'			;abae
	jr nz,cierra_el_estado_cinco		;abaf
	ld a,001h		;abb1   ; Banco 1...
	ld (0ab1ah),a		;abb3   ; ...escrito ENCIMA del "ld c,n" de 0xAB19: codigo que se modifica solo
	call elige_el_numero_de_sprite		;abb6   ; Pinta con el banco 1
	ld a,002h		;abb9   ; Y ahora el banco 2
	ld (0ab1ah),a		;abbb
	ld a,(080b3h)		;abbe   ; El dibujo en curso
	cp 090h		;abc1   ; Si ha llegado a 0x90...
	jr nz,L_ABA5		;abc3
	ld a,005h		;abc5   ; ...cinco pasos de la fase siguiente
	ld (080aeh),a		;abc7
	ld a,080h		;abca   ; ...y una cuenta larga
	ld (080ach),a		;abcc
	call L_BCF5		;abcf
	ld a,001h		;abd2
	ld (0ab1ah),a		;abd4   ; Vuelve al banco 1
	ld (080b4h),a		;abd7
	ld a,08eh		;abda
	ld (080b3h),a		;abdc   ; El dibujo con el que empieza
	call elige_el_numero_de_sprite		;abdf
	call 0fd9ah		;abe2   ; BIOS HOOKS - System hooks | Vector de sonido
	ld a,002h		;abe5
	ld (0ab1ah),a		;abe7
	jp L_ABA5		;abea
cierra_el_estado_cinco:		; Con el estado 5, borra el guion y coloca el par 0xC2C2
	cp 005h		;abed   ; Solo el estado 5
	jp nz,L_AB70		;abef
	sub a			;abf2
	ld (080abh),a		;abf3   ; Borra el primer byte del guion
	ld hl,0c2c2h		;abf6   ; El par de dibujos
	ld (080afh),hl		;abf9
	nop			;abfc   ; Un NOP
	call elige_el_numero_de_sprite		;abfd
	jp L_ABA5		;ac00
L_AC03:
	ld a,010h		;ac03
	ld (080adh),a		;ac05
	call 0fd9ah		;ac08   ; BIOS HOOKS - System hooks
	ret			;ac0b
L_AC0C:
	ld hl,(080afh)		;ac0c
	call L_AE41		;ac0f
	jp L_AB68		;ac12

; ----------------------------------------------------------------------
; DATOS ret_y_relleno: un 0xC9 (RET) y ceros detras
;   0xac15..0xac18  (3 bytes)
DATA_AC15:
	defb 0c9h,000h,000h	; ac15

; ======================================================================
; CODIGO 0xac18..0xac37  (31 bytes)
; ======================================================================


L_AC18:
	call copia_el_guion		;ac18
	call L_AD72		;ac1b
	ld a,(080aeh)		;ac1e
	or a			;ac21
	jp nz,arranca_el_movimiento		;ac22
L_AC25:
	ld bc,0c002h		;ac25
L_AC28:
	call elige_el_numero_de_sprite_2		;ac28
	call pinta_un_sprite		;ac2b
	call pinta_un_sprite		;ac2e
	call L_AC63		;ac31
	jp L_AC76		;ac34

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xac37..0xac38  (1 bytes)
DATA_AC37:
	defb 000h	; ac37

; ======================================================================
; CODIGO 0xac38..0xac47  (15 bytes)
; ======================================================================


elige_el_numero_de_sprite_2:		; El gemelo de 0xAB00, con el juego alternativo
	exx			;ac38
	ld hl,(080c0h)		;ac39   ; El puntero del guion
	ld a,l			;ac3c
	cp 002h		;ac3d   ; El primer byte
	ld a,008h		;ac3f   ; Sprite 8...
	jr z,L_AC45		;ac41
	ld a,00ch		;ac43   ; ...o el 0x0C
L_AC45:
	exx			;ac45
	ret			;ac46

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xac47..0xac48  (1 bytes)
DATA_AC47:
	defb 000h	; ac47

; ======================================================================
; CODIGO 0xac48..0xac57  (15 bytes)
; ======================================================================


esta_en_la_franja:		; Devuelve sin acarreo si B cae en la franja de 0x30 a 0x50
	di			;ac48   ; Sin interrupciones
	call L_AF8C		;ac49
	add a,030h		;ac4c   ; Cuarenta y ocho por delante
	cp b			;ac4e
	ret c			;ac4f   ; Por encima: fuera
	sub 050h		;ac50   ; Ochenta de ventana
	cp b			;ac52
	ret nc			;ac53   ; Por debajo: fuera
	sub a			;ac54
	ld a,b			;ac55
	ret			;ac56

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xac57..0xac58  (1 bytes)
DATA_AC57:
	defb 000h	; ac57

; ======================================================================
; CODIGO 0xac58..0xac7f  (39 bytes)
; ======================================================================


en_que_tramo:		; Devuelve -1 o 1 segun a que lado del limite caiga
	di			;ac58   ; Sin interrupciones
	call L_AF3C		;ac59   ; El limite
	cp b			;ac5c
	ld a,0ffh		;ac5d   ; Un lado...
	ret c			;ac5f
	ld a,001h		;ac60   ; ...o el otro
	ret			;ac62
L_AC63:
	ld hl,(080afh)		;ac63
	call elige_el_numero_de_sprite_2		;ac66
pinta_dos_planos:		; Dos sprites, el segundo dieciseis pixeles mas abajo
	call L_8310		;ac69   ; El primero
	ex af,af'			;ac6c
	ld a,010h		;ac6d   ; Dieciseis pixeles de separacion
	add a,h			;ac6f
	ld h,a			;ac70
	ex af,af'			;ac71
	call L_8310		;ac72   ; Y el segundo
	ret			;ac75
L_AC76:
	ld a,001h		;ac76
	ld (080aeh),a		;ac78
	call L_AB3A		;ac7b
	ret			;ac7e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xac7f..0xac80  (1 bytes)
DATA_AC7F:
	defb 000h	; ac7f

; ======================================================================
; CODIGO 0xac80..0xada7  (295 bytes)
; ======================================================================


arranca_el_movimiento:		; Cada tantos pasos, si esta en el estado 1, elige el dibujo del tramo
	ld hl,080ach		;ac80
	dec (hl)			;ac83   ; Cuenta atras
	jp nz,L_AB3A		;ac84   ; Todavia no
	ld a,(080adh)		;ac87   ; El periodo, que se recarga
	ld (hl),a			;ac8a
	ld a,(080aeh)		;ac8b   ; El estado
	dec a			;ac8e   ; Solo el 1
	jr nz,mira_la_franja_y_para		;ac8f
	ld a,(080afh)		;ac91   ; La posicion
	call en_que_tramo		;ac94   ; En que tramo cae
	ld (080b1h),a		;ac97
	dec a			;ac9a
	ld a,0c6h		;ac9b   ; Un dibujo para un tramo...
	jr z,arranca_el_estado_dos		;ac9d
	ld a,0ceh		;ac9f   ; ...y otro para el otro
arranca_el_estado_dos:		; Guarda el dibujo, la cuenta y el estado
	ld (080b3h),a		;aca1   ; El dibujo
	ld a,001h		;aca4
	ld (080b4h),a		;aca6   ; Cuenta a uno
	ld a,002h		;aca9
	ld (080aeh),a		;acab   ; Estado 2
	jp L_AB3A		;acae
mira_la_franja_y_para:		; Con el estado 2, se para si el jugador esta en la franja
	dec a			;acb1   ; Solo si el estado es 2
	jp nz,pinta_estado_tres		;acb2
	ld a,(080b0h)		;acb5   ; La posicion
	call esta_en_la_franja		;acb8   ; Mira la franja
	jr z,elige_el_par_del_tramo		;acbb   ; Dentro: se queda
	sub a			;acbd
	ld (080aeh),a		;acbe   ; Estado cero
	jp L_AE58		;acc1
elige_el_par_del_tramo:		; Cada cuatro pasos, un par u otro segun el tramo
	ld hl,080b4h		;acc4
	dec (hl)			;acc7   ; Cuenta atras
	jr nz,avanza_y_mira_los_topes		;acc8
	ld (hl),004h		;acca   ; Se recarga a 4
	ld a,(080b1h)		;accc   ; El tramo
	dec a			;accf
	ld bc,0c402h		;acd0   ; Un par...
	jr z,pinta_y_avanza		;acd3
	ld bc,0cc02h		;acd5   ; ...o el otro
pinta_y_avanza:		; Sube los dos planos y avanza el dibujo hasta uno de los cuatro finales de ciclo
	call elige_el_numero_de_sprite_2		;acd8   ; Calcula el numero de sprite
	call pinta_un_sprite		;acdb   ; Primer plano
	ex af,af'			;acde
	ld a,(080b3h)		;acdf   ; El dibujo en curso
	ld b,a			;ace2
	ex af,af'			;ace3
	call pinta_un_sprite		;ace4   ; Segundo plano
	dec b			;ace7
	dec b			;ace8
	ld a,(080b2h)		;ace9   ; El paso de la animacion
	add a,b			;acec
	nop			;aced   ; Dos NOP: aqui habia algo
	nop			;acee
	cp 0c6h		;acef   ; Los cuatro finales de ciclo
	jr z,invierte_el_paso		;acf1
	cp 0cah		;acf3
	jr z,invierte_el_paso		;acf5
	cp 0ceh		;acf7
	jr z,invierte_el_paso		;acf9
	cp 0d2h		;acfb
	jr nz,L_AD0F		;acfd
invierte_el_paso:		; Cambia el paso entre +2 y -2
	ex af,af'			;acff
	ld a,(080b2h)		;ad00   ; El paso
	cp 002h		;ad03   ; Si era 2...
	ld a,0feh		;ad05   ; ...pasa a -2...
	jr z,L_AD0B		;ad07
	ld a,002h		;ad09   ; ...y al reves
L_AD0B:
	ld (080b2h),a		;ad0b
	ex af,af'			;ad0e
L_AD0F:
	ld (080b3h),a		;ad0f
avanza_y_mira_los_topes:		; Suma el paso y comprueba los dos extremos
	ld hl,080afh		;ad12   ; La posicion
	ld a,(080b1h)		;ad15   ; El paso
	add a,(hl)			;ad18
	ld (hl),a			;ad19   ; Avanza
	call L_AC63		;ad1a
	ld a,(080afh)		;ad1d
	cp 0f0h		;ad20   ; Tope de arriba
	jr nc,L_AD28		;ad22
	cp 001h		;ad24   ; Y tope de abajo
	jr nc,sortea_el_giro		;ad26
L_AD28:
	ld a,(080b1h)		;ad28
	call L_8193		;ad2b
	ld (080b1h),a		;ad2e
	jp L_B840		;ad31
sortea_el_giro:		; Una de cada dos veces mira si hay que dar la vuelta
	call L_9D78		;ad34   ; El dado
	cp 002h		;ad37   ; Solo 0 y 1 siguen
	jp nc,L_AB3A		;ad39
	ld a,(080afh)		;ad3c   ; La posicion
	call en_que_tramo		;ad3f   ; En que tramo cae
	inc a			;ad42   ; 0xFF: no hay tramo
	jr nz,da_la_vuelta_2		;ad43
	ld a,(080b1h)		;ad45   ; El sentido
	inc a			;ad48
	jp z,L_AB3A		;ad49
	ld a,0ffh		;ad4c   ; Da la vuelta
	ld (080b1h),a		;ad4e
	ld a,0ceh		;ad51   ; Y el dibujo que le toca
	ld (080b3h),a		;ad53
	jp L_AD6A		;ad56
da_la_vuelta_2:		; Si el sentido no es 1, lo pone a 1 y cambia el dibujo
	ld a,(080b1h)		;ad59   ; El sentido
	dec a			;ad5c
	jp z,L_AB3A		;ad5d   ; Ya era 1: nada
	ld a,001h		;ad60   ; Sentido 1
	ld (080b1h),a		;ad62
	ld a,0c6h		;ad65   ; Y su dibujo
	ld (080b3h),a		;ad67
L_AD6A:
	ld a,002h		;ad6a
	ld (080b2h),a		;ad6c
	jp L_AB3A		;ad6f
L_AD72:
	call L_ADA8		;ad72
L_AD75:
	ld a,(080aeh)		;ad75
	cp 004h		;ad78
	ret nc			;ad7a
	ld hl,(080afh)		;ad7b
prueba_dos_alturas:		; La casilla y la de quince pixeles mas abajo
	push hl			;ad7e
	call L_AE41		;ad7f   ; La primera
	pop hl			;ad82
	ld a,00fh		;ad83   ; Quince pixeles
	add a,h			;ad85
	ld h,a			;ad86
	call L_AE41		;ad87   ; Y la segunda
	ret			;ad8a
mira_los_dos_campos:		; Mira los campos de 0xE005 y 0xE01A de la ficha
	ld hl,0e005h		;ad8b   ; El primero
	call reparte_por_el_campo		;ad8e
	ld hl,0e01ah		;ad91   ; El segundo
	call reparte_por_el_campo		;ad94
	ld hl,0dfffh		;ad97   ; Y devuelve el tampon
	ret			;ad9a
reparte_por_el_campo:		; Solo los valores 1 y de 4 en adelante hacen algo
	ld a,(hl)			;ad9b   ; El campo
	cp 001h		;ad9c   ; El valor 1
	jp z,L_991C		;ad9e
	cp 004h		;ada1   ; Por debajo de 4, nada
	ret c			;ada3
	jp L_991F		;ada4

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xada7..0xada8  (1 bytes)
DATA_ADA7:
	defb 0c9h	; ada7

; ======================================================================
; CODIGO 0xada8..0xaf0f  (359 bytes)
; ======================================================================


L_ADA8:
	ld hl,(080afh)		;ada8
L_ADAB:
	call L_AE38		;adab
	jr z,L_ADB8		;adae
	ld a,010h		;adb0
	add a,h			;adb2
	ld h,a			;adb3
L_ADB4:
	call L_AE38		;adb4
	ret nz			;adb7
L_ADB8:
	call L_A890		;adb8
	ld hl,080b9h		;adbb
	dec (hl)			;adbe
	ret nz			;adbf
estado_cuatro_al_azar:		; Estado 4 y, a suertes, uno de dos dibujos
	ld a,004h		;adc0   ; Estado 4
	ld (080aeh),a		;adc2
	call L_9D78		;adc5   ; El dado
	cp 008h		;adc8
	ld a,080h		;adca   ; Un dibujo...
	jr c,L_ADD0		;adcc
	ld a,096h		;adce   ; ...o el otro
L_ADD0:
	ld (080b3h),a		;add0
	pop hl			;add3
	pop hl			;add4
	jp L_AE33		;add5
pinta_estado_tres:		; Igual, con el ciclo entre 0x8E y 0xA6
	dec a			;add8   ; Solo si el estado es 3
	dec a			;add9
	jr nz,coloca_el_par_c2c2		;adda
	ld a,(080b3h)		;addc
	ld b,a			;addf
	ld c,001h		;ade0   ; Banco 1
	call elige_el_numero_de_sprite_2		;ade2   ; Numero de sprite
	call pinta_un_sprite		;ade5   ; Primer plano
	dec b			;ade8
	dec b			;ade9
	call pinta_un_sprite		;adea   ; Segundo plano
	call 0fd9ah		;aded   ; BIOS HOOKS - System hooks | Vector de sonido
	ld a,b			;adf0
	ld (080b3h),a		;adf1   ; Guarda el dibujo nuevo
	cp 08eh		;adf4   ; Principio del ciclo
	jr z,monta_la_caida		;adf6
	cp 0a6h		;adf8   ; Y final
	jp nz,L_AB3A		;adfa
monta_la_caida:		; Coloca el par 0xC2C2 y pasa al estado 5
	ld hl,0c2c2h		;adfd   ; El par de dibujos
	call elige_el_numero_de_sprite_2		;ae00
	inc a			;ae03
	inc a			;ae04
	call L_AF94		;ae05
	sub 002h		;ae08
	ld bc,08e01h		;ae0a   ; El sprite y el banco
	call pinta_un_sprite		;ae0d   ; Lo pinta
	call L_BCF5		;ae10
	ld a,005h		;ae13   ; Estado 5
	ld (080aeh),a		;ae15
	jp L_AE2B		;ae18
coloca_el_par_c2c2:		; Pinta el par fijo y borra el guion
	ld hl,0c2c2h		;ae1b   ; El par de dibujos
	call elige_el_numero_de_sprite_2		;ae1e   ; Numero de sprite
	call L_8310		;ae21
	sub a			;ae24   ; Borra el primer byte del guion
	ld (080abh),a		;ae25
	jp L_AB3A		;ae28
L_AE2B:
	ld a,080h		;ae2b
	ld (080ach),a		;ae2d
L_AE30:
	jp L_AB3A		;ae30
L_AE33:
	call L_AC03		;ae33
	jr L_AE30		;ae36
L_AE38:
	ld a,(080aeh)		;ae38
	cp 002h		;ae3b
	ret nz			;ae3d
	jp L_9F90		;ae3e
L_AE41:
	ld a,(080aeh)		;ae41
	cp 002h		;ae44
	ret nz			;ae46
	jp mira_si_pisa_la_casilla		;ae47
L_AE4A:
	sub a			;ae4a
	ld hl,03880h		;ae4b
	ld bc,00100h		;ae4e
	call 00056h		;ae51   ; BIOS FILVRM - Fills VRAM with value
	call 0fd9ah		;ae54   ; BIOS HOOKS - System hooks
	ret			;ae57
L_AE58:
	ld a,080h		;ae58
	ld (080ach),a		;ae5a
	jp L_AC25		;ae5d
L_AE60:
	call avanza_dentro_de_los_topes		;ae60
	call mira_si_lo_coge		;ae63
	ld a,(080aeh)		;ae66
	or a			;ae69
	jr nz,cuenta_y_sigue		;ae6a
elige_el_par_del_tramo_2:		; Pinta y, segun el tramo, prepara un par u otro
	call elige_el_numero_de_sprite_2		;ae6c   ; Numero de sprite
	ex af,af'			;ae6f
	call en_que_tramo		;ae70   ; En que tramo esta
	ld (080b1h),a		;ae73   ; Se guarda
	dec a			;ae76
	ld bc,03801h		;ae77   ; Un par...
	jr z,L_AE7F		;ae7a
	ld bc,04201h		;ae7c   ; ...o el otro
L_AE7F:
	ex af,af'			;ae7f
	call pinta_un_sprite		;ae80
	call pinta_un_sprite		;ae83
	call L_AC63		;ae86
	jp L_AC76		;ae89
cuenta_y_sigue:		; Cuenta atras y, al llegar a cero, recarga y sigue
	ld hl,080ach		;ae8c
	dec (hl)			;ae8f   ; Cuenta atras
	jp nz,L_AB3A		;ae90   ; Todavia no
	ld a,(080adh)		;ae93   ; El periodo, que se recarga
	ld (hl),a			;ae96
	jp L_AF81		;ae97
L_AE9A:
	call esta_en_la_franja		;ae9a
	jr z,elige_el_sprite_del_tramo		;ae9d
	sub a			;ae9f
	ld (080aeh),a		;aea0
	jp L_AEFC		;aea3
elige_el_sprite_del_tramo:		; Cada tres pasos, un numero de sprite u otro segun el tramo
	ld hl,080b4h		;aea6
	dec (hl)			;aea9   ; Cuenta atras
	jr nz,avanza_y_mira_el_tramo		;aeaa
	ld (hl),003h		;aeac   ; Se recarga a 3
	call elige_el_numero_de_sprite_2		;aeae
	ex af,af'			;aeb1
	ld a,(080b1h)		;aeb2   ; El tramo
	dec a			;aeb5
	ld bc,03c01h		;aeb6   ; Sprite y banco de un tramo...
	jr z,pinta_los_dos_planos		;aeb9
	ld b,046h		;aebb   ; ...y del otro
pinta_los_dos_planos:		; Sube los dos planos y avanza el dibujo
	ex af,af'			;aebd
	call pinta_un_sprite		;aebe   ; Primer plano
	ex af,af'			;aec1
	ld a,(080b3h)		;aec2   ; El dibujo en curso
	ld b,a			;aec5
	ex af,af'			;aec6
	call pinta_un_sprite		;aec7   ; Segundo plano
	dec b			;aeca   ; Dos registros mas atras
	dec b			;aecb
	call L_AF04		;aecc
	ld (080b3h),a		;aecf   ; Guarda el dibujo nuevo
avanza_y_mira_el_tramo:		; Suma el paso, mira en que tramo cae y cambia el dibujo si ha cambiado
	ld hl,080afh		;aed2   ; La posicion
	ld a,(080b1h)		;aed5   ; El paso
	add a,(hl)			;aed8
	ld (hl),a			;aed9   ; Avanza
	call L_AC63		;aeda
	ld a,(080afh)		;aedd   ; La posicion nueva
	call en_que_tramo		;aee0   ; En que tramo cae
	ld b,a			;aee3
	ld a,(080b1h)		;aee4
	cp b			;aee7   ; Si es el mismo de antes, nada que hacer
	jp z,L_AB3A		;aee8
	ld a,b			;aeeb
	ld (080b1h),a		;aeec   ; Guarda el tramo nuevo
	dec a			;aeef
	ld a,03eh		;aef0   ; Un dibujo para un tramo...
	jr z,L_AEF6		;aef2
	ld a,04ah		;aef4   ; ...y otro para el otro
L_AEF6:
	ld (080b3h),a		;aef6
	jp L_AB3A		;aef9
L_AEFC:
	ld a,010h		;aefc
	ld (080ach),a		;aefe
	jp elige_el_par_del_tramo_2		;af01
L_AF04:
	ld a,b			;af04
	cp 042h		;af05
	jr c,L_AF0C		;af07
	xor 002h		;af09
	ret			;af0b
L_AF0C:
	xor 07eh		;af0c
	ret			;af0e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xaf0f..0xaf10  (1 bytes)
DATA_AF0F:
	defb 000h	; af0f

; ======================================================================
; CODIGO 0xaf10..0xaf80  (112 bytes)
; ======================================================================


avanza_dentro_de_los_topes:		; Cada seis pasos avanza, y comprueba los dos topes
	call copia_el_guion		;af10
	ld hl,080bah		;af13   ; Cuenta atras
	dec (hl)			;af16
	ret nz			;af17   ; Todavia no
	ld (hl),006h		;af18   ; Se recarga a 6
	ld hl,080b0h		;af1a
	ld a,(080b2h)		;af1d   ; El paso
	add a,(hl)			;af20
	ld (hl),a			;af21   ; Avanza
	push af			;af22
	call L_AC63		;af23
	pop bc			;af26
	ld a,(080bch)		;af27   ; Tope de un lado
	cp b			;af2a
	jr nc,L_AF32		;af2b
	ld a,(080bdh)		;af2d   ; Tope del otro
	cp b			;af30
	ret nc			;af31
L_AF32:
	ld a,(080b2h)		;af32
	call L_8193		;af35
	ld (080b2h),a		;af38
	ret			;af3b
L_AF3C:
	ld a,(080afh)		;af3c
	ld b,a			;af3f
	ld a,(08049h)		;af40
	ret			;af43
L_AF44:
	ld a,001h		;af44
	ld (08048h),a		;af46
	jp 0fd9ah		;af49   ; BIOS HOOKS - System hooks
mira_si_lo_coge:		; Con el estado 2 y sin nada pendiente, mira si el jugador pisa la casilla
	call L_ADA8		;af4c
	ld a,(080aeh)		;af4f   ; El estado
	cp 002h		;af52   ; Solo el 2
	ret nz			;af54
	ld a,(080a9h)		;af55   ; Y solo si no hay nada pendiente
	or a			;af58
	ret nz			;af59
	nop			;af5a   ; Un NOP suelto
	ld hl,(080afh)		;af5b   ; La posicion
	call mira_si_pisa_la_casilla		;af5e   ; Mira si el jugador la pisa
	call L_BC10		;af61
	nop			;af64   ; Otro NOP
	ret nz			;af65
	ld a,(hl)			;af66   ; La ficha de la casilla
	or a			;af67
	nop			;af68   ; Y otro
	cp 005h		;af69   ; De 5 para arriba no vale
	ret nc			;af6b
	call L_A8F8		;af6c
	sub a			;af6f
	ld (080ach),a		;af70   ; Reinicia la cuenta
	call L_AFAA		;af73
	ld hl,080b9h		;af76
	dec (hl)			;af79   ; Cuenta atras de las que quedan
	jp nz,L_AB3A		;af7a
	jp L_AFA1		;af7d

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xaf80..0xaf81  (1 bytes)
DATA_AF80:
	defb 0c9h	; af80

; ======================================================================
; CODIGO 0xaf81..0xaf88  (7 bytes)
; ======================================================================


L_AF81:
	ld a,(080aeh)		;af81
	dec a			;af84
	jp pasa_al_estado_dos_2		;af85

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xaf88..0xaf89  (1 bytes)
DATA_AF88:
	defb 000h	; af88

; ======================================================================
; CODIGO 0xaf89..0xaf93  (10 bytes)
; ======================================================================


L_AF89:
	jp pinta_estado_tres		;af89
L_AF8C:
	ld a,(080b0h)		;af8c
	ld b,a			;af8f
	jp L_9D8E		;af90

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xaf93..0xaf94  (1 bytes)
DATA_AF93:
	defb 0c9h	; af93

; ======================================================================
; CODIGO 0xaf94..0xafb7  (35 bytes)
; ======================================================================


L_AF94:
	push af			;af94
	call 00084h		;af95   ; BIOS CALPAT - Returns the address of the sprite pattern table
	sub a			;af98
	ld bc,00040h		;af99
	call 00056h		;af9c   ; BIOS FILVRM - Fills VRAM with value
	pop af			;af9f
	ret			;afa0
L_AFA1:
	ld a,001h		;afa1
	ld (080ach),a		;afa3
	call estado_cuatro_al_azar		;afa6
	ret			;afa9
L_AFAA:
	ld (080aeh),a		;afaa
	ld a,(080b1h)		;afad
	ld (0805ch),a		;afb0
	call 0fd9ah		;afb3   ; BIOS HOOKS - System hooks
	ret			;afb6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xafb7..0xafb8  (1 bytes)
DATA_AFB7:
	defb 000h	; afb7

; ======================================================================
; CODIGO 0xafb8..0xb0e0  (296 bytes)
; ======================================================================


arranca_si_esta_parado:		; Con el estado 0, pinta y pasa al estado 1
	call copia_el_guion		;afb8
	call L_B22D		;afbb
	ld a,(080aeh)		;afbe   ; El estado
	or a			;afc1
	jr nz,arranca_la_animacion		;afc2   ; Si no es cero, ya esta en marcha
	ld a,(080b3h)		;afc4   ; El dibujo en curso
	ld b,a			;afc7
	ld c,001h		;afc8   ; Banco 1
	call elige_el_numero_de_sprite_2		;afca   ; Numero de sprite
	call pinta_un_sprite		;afcd   ; Lo pinta
	call L_AFDB		;afd0
	ld a,001h		;afd3
	ld (080aeh),a		;afd5   ; Estado 1
	jp L_AB3A		;afd8
L_AFDB:
	call elige_el_numero_de_sprite_2		;afdb
	ld hl,(080afh)		;afde
	jp L_8310		;afe1
arranca_la_animacion:		; Cada tantos pasos pinta el sprite siguiente y prepara el tramo
	ld hl,080ach		;afe4   ; Cuenta atras
	dec (hl)			;afe7
	jp nz,L_AB3A		;afe8   ; Todavia no
	ld a,(080adh)		;afeb   ; El periodo, que se recarga
	ld (hl),a			;afee
	ld a,(080aeh)		;afef   ; El estado
	dec a			;aff2   ; Solo el 1
	jr nz,estado_dos_del_movil		;aff3
	ld a,(080b3h)		;aff5   ; El dibujo en curso
	add a,002h		;aff8   ; El siguiente par
	ld b,a			;affa
	ld c,001h		;affb   ; Banco 1
	call elige_el_numero_de_sprite_2		;affd   ; Numero de sprite
	call pinta_un_sprite		;b000   ; Lo pinta
	ld a,010h		;b003   ; Y le da dieciseis pasos
	ld (080ach),a		;b005
	ld a,002h		;b008
	ld (080aeh),a		;b00a   ; Pasa al estado 2
	call en_que_tramo		;b00d   ; En que tramo esta
	ld (080b1h),a		;b010
	dec a			;b013
	ld a,004h		;b014
	jr z,L_B01A		;b016
	ld a,012h		;b018
L_B01A:
	ld (080b3h),a		;b01a
	jp L_AB3A		;b01d
estado_dos_del_movil:		; Si esta en la franja, se para; si no, elige el paso
	dec a			;b020   ; Solo si el estado es 2
	jp nz,L_B189		;b021
	ld a,(080b5h)		;b024   ; La bandera de fase
	or a			;b027
	jp nz,anima_entre_diez_y_veinticuatro		;b028
	call esta_en_la_franja		;b02b   ; Mira si el jugador esta en la franja
	jr z,mira_la_distancia		;b02e   ; Lo esta: se queda
	sub a			;b030
	ld (080aeh),a		;b031   ; Estado 0
	ld a,000h		;b034
	ld (080ach),a		;b036
	ld a,(080b1h)		;b039   ; El tramo
	dec a			;b03c
	ld a,000h		;b03d   ; Un paso para un tramo...
	jr z,L_B043		;b03f
	ld a,00eh		;b041   ; ...y otro para el otro
L_B043:
	ld (080b3h),a		;b043
	jp L_AB3A		;b046
mira_la_distancia:		; Segun el tramo, compara con la X del jugador
	ld a,(080b1h)		;b049   ; El tramo
	ld hl,08049h		;b04c   ; La X del jugador
	dec a			;b04f
	ld a,(080afh)		;b050   ; Su posicion
	jp nz,L_B1D8		;b053
	add a,040h		;b056   ; Sesenta y cuatro pixeles por delante
	cp (hl)			;b058
	jp nc,L_B140		;b059
	ld a,006h		;b05c   ; El paso
L_B05E:
	ld (080b3h),a		;b05e
L_B061:
	ld a,001h		;b061
	ld (080b5h),a		;b063
	ld a,005h		;b066
	ld (080b6h),a		;b068
pinta_y_vuelve:		; Sube el sprite y devuelve el mando al bucle
	ld a,(080b3h)		;b06b   ; El dibujo en curso
	ld b,a			;b06e
	ld c,001h		;b06f   ; Banco 1
	call elige_el_numero_de_sprite_2		;b071   ; Numero de sprite
	call pinta_un_sprite		;b074   ; Lo pinta
	call L_AFDB		;b077
	jp L_AB3A		;b07a
anima_entre_diez_y_veinticuatro:		; Cada dos pasos avanza el dibujo dentro de su ciclo
	dec a			;b07d   ; Solo si el estado es 1
	jp nz,retrocede_el_dibujo		;b07e
	ld hl,080b4h		;b081   ; Cuenta atras
	dec (hl)			;b084
	jr nz,L_B099		;b085
	ld (hl),002h		;b087   ; Se recarga a 2
	ld a,(080b3h)		;b089
	cp 00ah		;b08c   ; Principio del ciclo
	jr z,L_B099		;b08e
	cp 018h		;b090   ; Final del ciclo
	jr z,L_B099		;b092
	inc a			;b094   ; Y avanza de dos en dos
	inc a			;b095
	ld (080b3h),a		;b096
L_B099:
	call avanza_y_topa		;b099
	jr L_B0B9		;b09c
avanza_y_topa:		; Suma el paso y comprueba los dos extremos
	ld hl,080afh		;b09e   ; La posicion
	ld a,(080b1h)		;b0a1   ; El paso
	add a,(hl)			;b0a4
	ld (hl),a			;b0a5   ; Avanza
	cp 0efh		;b0a6   ; Tope de arriba
	jr nc,L_B0AF		;b0a8
	cp 002h		;b0aa   ; Y tope de abajo
	jr c,L_B0AF		;b0ac
	ret			;b0ae
L_B0AF:
	ld a,(080b1h)		;b0af
	call L_8193		;b0b2
	ld (080b1h),a		;b0b5
	ret			;b0b8
L_B0B9:
	call avanza_si_toca		;b0b9
	jr $+54		;b0bc
avanza_si_toca:		; Suma el paso solo en los estados 1 y 3, y cada dos pasos sube el contador
	ld hl,080b0h		;b0be   ; La posicion
	ld a,(080b6h)		;b0c1   ; El paso
	ld b,a			;b0c4
	ld a,(080b5h)		;b0c5   ; El estado
	cp 001h		;b0c8   ; Estado 1
	jr z,$+23		;b0ca
	cp 003h		;b0cc   ; Estado 3; cualquier otro se va
	ret nz			;b0ce
	ld a,b			;b0cf
	add a,(hl)			;b0d0   ; Avanza
	ld (hl),a			;b0d1
	ld a,(080b6h)		;b0d2
	ld hl,080b7h		;b0d5   ; Cuenta atras del contador
	dec (hl)			;b0d8
	ret nz			;b0d9
	ld (hl),002h		;b0da   ; Se recarga a 2
	dec hl			;b0dc
	inc (hl)			;b0dd   ; Y sube el contador
	ld a,(hl)			;b0de
	ret			;b0df

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb0e0..0xb0e1  (1 bytes)
DATA_B0E0:
	defb 000h	; b0e0

; ======================================================================
; CODIGO 0xb0e1..0xb0ff  (30 bytes)
; ======================================================================


retrocede_y_cuenta:		; Resta el paso y, cada dos veces, baja el contador
	ld a,(hl)			;b0e1
	sub b			;b0e2   ; Retrocede
	ld (hl),a			;b0e3
	ld a,(080b6h)		;b0e4
	ld hl,080b7h		;b0e7   ; Cuenta atras
	dec (hl)			;b0ea
	ret nz			;b0eb   ; Todavia no
	ld (hl),002h		;b0ec   ; Se recarga a 2
	dec hl			;b0ee
	dec (hl)			;b0ef   ; Y baja el contador
	ld a,(hl)			;b0f0
	ret			;b0f1
L_B0F2:
	cp 0ffh		;b0f2
	jp z,arranca_el_estado_tres		;b0f4
	cp 006h		;b0f7
	jp z,L_B132		;b0f9
	jp pinta_y_vuelve		;b0fc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb0ff..0xb100  (1 bytes)
DATA_B0FF:
	defb 000h	; b0ff

; ======================================================================
; CODIGO 0xb100..0xb13d  (61 bytes)
; ======================================================================


arranca_el_estado_tres:		; Contadores a cero, ocho pasos y estado 3
	ld a,000h		;b100   ; Contador a cero
	ld (080b6h),a		;b102
	ld a,008h		;b105   ; Ocho pasos
	ld (080b7h),a		;b107
	ld a,003h		;b10a   ; Estado 3
	ld (080b5h),a		;b10c
	jp pinta_y_vuelve		;b10f
retrocede_el_dibujo:		; Con el estado 2, baja el dibujo de dos en dos hasta 4 o 0x0C
	dec a			;b112   ; Solo si el estado es 2
	dec a			;b113
	jp z,L_B099		;b114
	call pinta_y_vuelve		;b117   ; Pinta lo que haya
	ld a,(080b3h)		;b11a   ; El dibujo en curso
	dec a			;b11d
	dec a			;b11e   ; Dos menos
	ld (080b3h),a		;b11f
	cp 004h		;b122   ; Un final de ciclo...
	jr z,L_B12B		;b124
	cp 00ch		;b126   ; ...y el otro
	jp nz,pinta_y_vuelve		;b128
L_B12B:
	sub a			;b12b
	ld (080b5h),a		;b12c
	jp mira_si_choca		;b12f
L_B132:
	ld a,004h		;b132
	ld (080b5h),a		;b134
	call 0fd9ah		;b137   ; BIOS HOOKS - System hooks
	jp pinta_y_vuelve		;b13a

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb13d..0xb140  (3 bytes)
DATA_B13D:
	defb 000h,000h,000h	; b13d

; ======================================================================
; CODIGO 0xb140..0xb237  (247 bytes)
; ======================================================================


L_B140:
	ld a,004h		;b140
L_B142:
	ld (080b3h),a		;b142
	call pinta_y_vuelve		;b145
mira_si_choca:		; Dos comprobaciones seguidas; si las dos fallan, sigue como estaba
	call L_B210		;b148
	call es_uno_de_los_cuatro		;b14b   ; La primera
	nop			;b14e   ; Tres NOP
	nop			;b14f
	nop			;b150
	jr z,pasa_al_estado_tres		;b151
	ld a,(08050h)		;b153   ; La bandera de estado
	or a			;b156
	jp z,pinta_y_vuelve		;b157
	call L_9AEA		;b15a   ; La segunda
	nop			;b15d   ; Dos NOP
	nop			;b15e
	jp z,L_9AE0		;b15f
	jp pinta_y_vuelve		;b162
pasa_al_estado_tres:		; Guarda la casilla y elige el dibujo segun el tramo
	call L_BF6B		;b165
	ld a,003h		;b168
	ld (080aeh),a		;b16a   ; Estado 3
	ld hl,(080afh)		;b16d   ; La posicion
	call L_B2D8		;b170
	call L_8939		;b173   ; A casilla del mapa
	ld (080beh),hl		;b176   ; Se guarda
	ld a,(080b1h)		;b179   ; El tramo
	dec a			;b17c
	ld a,00ch		;b17d   ; Un dibujo para un tramo...
	jr z,L_B183		;b17f
	ld a,01ah		;b181   ; ...y otro para el otro
L_B183:
	ld (080b3h),a		;b183
	jp pinta_y_vuelve		;b186
L_B189:
	dec a			;b189
	jp nz,L_B28A		;b18a
	ld hl,(080beh)		;b18d
	ld a,(080b1h)		;b190
	dec a			;b193
	jp nz,L_B1E8		;b194
	inc hl			;b197
	inc hl			;b198
	call L_A392		;b199
	jp nz,L_B1BD		;b19c
	ld a,098h		;b19f
	call 0004dh		;b1a1   ; BIOS WRTVRM - Writes data in VRAM
	dec hl			;b1a4
	dec a			;b1a5
	call 0004dh		;b1a6   ; BIOS WRTVRM - Writes data in VRAM
	ld (080beh),hl		;b1a9
	dec hl			;b1ac
	sub a			;b1ad
	call 0004dh		;b1ae   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,080bch		;b1b1
	ld a,008h		;b1b4
	add a,(hl)			;b1b6
	ld (hl),a			;b1b7
	cp 0efh		;b1b8
	jp c,pinta_y_vuelve		;b1ba
L_B1BD:
	ld hl,(080beh)		;b1bd
	sub a			;b1c0
	call 0004dh		;b1c1   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b1c4
	call 0004dh		;b1c5   ; BIOS WRTVRM - Writes data in VRAM
	ld a,002h		;b1c8
	ld (080aeh),a		;b1ca
	ld a,001h		;b1cd
	ld (080ach),a		;b1cf
	call 0fd9ah		;b1d2   ; BIOS HOOKS - System hooks
	jp pinta_y_vuelve		;b1d5
L_B1D8:
	sub 040h		;b1d8
	cp (hl)			;b1da
	jp c,L_B1E3		;b1db
	ld a,014h		;b1de
	jp L_B05E		;b1e0
L_B1E3:
	ld a,012h		;b1e3
	jp L_B142		;b1e5
L_B1E8:
	dec hl			;b1e8
	call L_A392		;b1e9
	jp nz,L_B1BD		;b1ec
	ld a,095h		;b1ef
	call 0004dh		;b1f1   ; BIOS WRTVRM - Writes data in VRAM
	ld (080beh),hl		;b1f4
	inc hl			;b1f7
	inc a			;b1f8
	call 0004dh		;b1f9   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b1fc
	sub a			;b1fd
	call 0004dh		;b1fe   ; BIOS WRTVRM - Writes data in VRAM
	ld hl,080bch		;b201
	ld a,(hl)			;b204
	sub 008h		;b205
	ld (hl),a			;b207
	cp 008h		;b208
	jp c,L_B1BD		;b20a
	jp pinta_y_vuelve		;b20d
L_B210:
	call en_que_tramo		;b210
	ld (080b1h),a		;b213
	jp L_8978		;b216
L_B219:
	ld a,(080b1h)		;b219
	dec a			;b21c
	ld a,006h		;b21d
	jr z,L_B223		;b21f
	ld a,014h		;b221
L_B223:
	ld (080b3h),a		;b223
	sub a			;b226
	ld (080b1h),a		;b227
	jp L_B061		;b22a
L_B22D:
	call borra_cuatro_casillas_2		;b22d
	ld hl,(080afh)		;b230
	call L_ADB4		;b233
	ret			;b236

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb237..0xb238  (1 bytes)
DATA_B237:
	defb 000h	; b237

; ======================================================================
; CODIGO 0xb238..0xb26f  (55 bytes)
; ======================================================================


borra_cuatro_casillas_2:		; Con el estado por debajo de 4, borra el bloque de dos por dos
	ld a,(080aeh)		;b238   ; El estado
	cp 004h		;b23b   ; De 4 para arriba no vale
	ret nc			;b23d
	ld hl,(080afh)		;b23e   ; La posicion
	call mira_si_pisa_la_casilla		;b241   ; Mira si el jugador la pisa
	call L_8930		;b244
	ld de,0001fh		;b247   ; 0x1F: hasta la fila de abajo
	ld b,004h		;b24a   ; Cuatro casillas
L_B24C:
	call mira_la_baldosa_2		;b24c
	inc hl			;b24f
	call mira_la_baldosa_2		;b250
	add hl,de			;b253
	jr L_B26C		;b254
mira_la_baldosa_2:		; Como 0xA8D8 pero con la franja de baldosas 0x95 a 0x98
	call 0004ah		;b256   ; BIOS RDVRM - Reads the content of VRAM | Lee la casilla
	cp 095h		;b259   ; Por debajo de 0x95 no vale
	ret c			;b25b
	cp 099h		;b25c   ; Y de 0x99 para arriba tampoco
	ret nc			;b25e
	push hl			;b25f
	push de			;b260
	push bc			;b261
	call L_A8F8		;b262   ; Lo que toque hacer con ella
	call L_B270		;b265
	pop bc			;b268
	pop de			;b269
	pop hl			;b26a
	ret			;b26b
L_B26C:
	djnz L_B24C		;b26c
	ret			;b26e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb26f..0xb270  (1 bytes)
DATA_B26F:
	defb 000h	; b26f

; ======================================================================
; CODIGO 0xb270..0xb2cf  (95 bytes)
; ======================================================================


L_B270:
	ld a,(080b1h)		;b270
	ld (0805ch),a		;b273
	ld a,002h		;b276
	ld (080aeh),a		;b278
	ld hl,(080beh)		;b27b
	sub a			;b27e
	call 0004dh		;b27f   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b282
	call 0004dh		;b283   ; BIOS WRTVRM - Writes data in VRAM
	call 0fd9ah		;b286   ; BIOS HOOKS - System hooks
	ret			;b289
L_B28A:
	dec a			;b28a
	jr nz,coloca_el_par_c2c2_2		;b28b
pinta_y_cicla_2:		; Sube el sprite y rebobina entre 0x8E y 0xA6
	ld a,(080b3h)		;b28d   ; El dibujo en curso
	ld b,a			;b290
	ld c,001h		;b291   ; Banco 1
	call elige_el_numero_de_sprite_2		;b293   ; Numero de sprite
	call pinta_un_sprite		;b296   ; Lo pinta
	ld a,b			;b299
	ld (080b3h),a		;b29a   ; Guarda el dibujo nuevo
	cp 08eh		;b29d   ; Principio del ciclo
	jr z,pasa_al_estado_cinco		;b29f
	cp 0a6h		;b2a1   ; Y final
	jp nz,pinta_y_vuelve		;b2a3
pasa_al_estado_cinco:		; Estado 5, cuenta larga y el sprite 0x90
	ld a,005h		;b2a6   ; Estado 5
	ld (080aeh),a		;b2a8
	ld a,080h		;b2ab   ; Ciento veintiocho pasos
	ld (080ach),a		;b2ad
	ld bc,09001h		;b2b0   ; El sprite y el banco
	call elige_el_numero_de_sprite_2		;b2b3
	call pinta_un_sprite		;b2b6   ; Lo pinta
	call L_BCF1		;b2b9
	jp L_AB3A		;b2bc
coloca_el_par_c2c2_2:		; El gemelo de 0xAE1B
	call elige_el_numero_de_sprite_2		;b2bf   ; Numero de sprite
	ld hl,0c2c2h		;b2c2   ; El par de dibujos
	call L_8310		;b2c5
	sub a			;b2c8
	ld (080abh),a		;b2c9   ; Borra el primer byte del guion
	jp L_AB3A		;b2cc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb2cf..0xb2d0  (1 bytes)
DATA_B2CF:
	defb 000h	; b2cf

; ======================================================================
; CODIGO 0xb2d0..0xb3f6  (294 bytes)
; ======================================================================


L_B2D0:
	ld a,010h		;b2d0
	add a,h			;b2d2
	ld h,a			;b2d3
	ld (08052h),hl		;b2d4
	ret			;b2d7
L_B2D8:
	ld a,008h		;b2d8
	add a,h			;b2da
	ld h,a			;b2db
	ld (080bch),hl		;b2dc
	ret			;b2df
L_B2E0:
	ld a,001h		;b2e0
	ld (080ach),a		;b2e2
	jp L_BFF8		;b2e5
prepara_una_ficha:		; Con el jugador por debajo de la fila 0x60, rellena a mano los diez campos de 0x80A0
	ld a,(0804ah)		;b2e8   ; La Y del jugador
	cp 060h		;b2eb   ; Por encima de 0x60 no se hace nada
	ret c			;b2ed
	call L_B401		;b2ee
	ld hl,080a0h		;b2f1   ; Los diez bytes de la ficha, uno a uno
	ld (hl),002h		;b2f4
	inc hl			;b2f6
	ld (hl),001h		;b2f7
	inc hl			;b2f9
	ld (hl),000h		;b2fa
	inc hl			;b2fc
	ld (hl),006h		;b2fd
	inc hl			;b2ff
	ld (hl),001h		;b300
	inc hl			;b302
	ld (hl),060h		;b303
	inc hl			;b305
	ld (hl),0d0h		;b306
	inc hl			;b308
	ld (hl),000h		;b309
	inc hl			;b30b
	ld (hl),001h		;b30c
	call L_B4D0		;b30e   ; Y se pone en marcha
	ret			;b311
reparte_la_ficha:		; Cada cuatro pasos mira el tipo de la ficha de 0x80A0
	ld hl,080a1h		;b312
	dec (hl)			;b315   ; Cuenta atras
	ret nz			;b316   ; Todavia no
	ld (hl),004h		;b317   ; Se recarga a 4
	ld a,(080a0h)		;b319   ; El tipo
	or a			;b31c
	jp z,parpadea_el_par		;b31d   ; Cero: la rutina general
	dec a			;b320
	jp z,L_DAD0		;b321   ; Tipo 1: reinicia el juego
	dec a			;b324
	jp nz,L_DAD0		;b325   ; Y cualquiera que no sea el 2, tambien
	call L_B331		;b328
	call L_B349		;b32b
	jp avanza_la_ficha		;b32e
L_B331:
	ld e,004h		;b331
	ld bc,07002h		;b333
	ld a,008h		;b336
L_B338:
	call pinta_un_sprite		;b338
	dec e			;b33b
	jr nz,L_B338		;b33c
	ld a,014h		;b33e
	ld e,004h		;b340
L_B342:
	call pinta_un_sprite		;b342
	dec e			;b345
	jr nz,L_B342		;b346
	ret			;b348
L_B349:
	ld hl,(080a5h)		;b349
	ld a,008h		;b34c
	ld b,004h		;b34e
pinta_una_columna:		; Sube B sprites, cada uno dieciseis pixeles por debajo del anterior
	call L_8310		;b350
	ex af,af'			;b353
	ld a,010h		;b354   ; Dieciseis pixeles de separacion
	add a,h			;b356
	ld h,a			;b357
	ex af,af'			;b358
	djnz pinta_una_columna		;b359   ; Otro sprite
	ld a,h			;b35b
	sub 040h		;b35c   ; Sube 0x40, o sea cuatro sprites
	ld h,a			;b35e
	ld a,010h		;b35f   ; Y se corre dieciseis a la derecha
	add a,l			;b361
	ld l,a			;b362
	ld a,014h		;b363
	ld b,004h		;b365   ; Cuatro mas
pinta_una_columna_2:		; B sprites, cada uno dieciseis pixeles mas abajo
	call L_8310		;b367   ; Uno
	ex af,af'			;b36a
	ld a,010h		;b36b   ; Dieciseis pixeles de separacion
	add a,h			;b36d
	ld h,a			;b36e
	ex af,af'			;b36f
	djnz pinta_una_columna_2		;b370   ; El siguiente
	ret			;b372
avanza_la_ficha:		; Suma el paso y, cada dos pasos, sube el numero de dibujo hasta nueve
	ld hl,080a6h		;b373
	ld a,(080a2h)		;b376   ; El paso
	add a,(hl)			;b379
	ld (hl),a			;b37a   ; Avanza
	ld hl,080a4h		;b37b
	dec (hl)			;b37e   ; Cuenta atras
	jr nz,L_B390		;b37f
	ld (hl),002h		;b381   ; Se recarga a 2
	ld hl,080a2h		;b383
	inc (hl)			;b386   ; Sube el dibujo
	ld a,(hl)			;b387
	cp 009h		;b388   ; Al llegar a nueve...
	jr nz,L_B390		;b38a
	sub a			;b38c
	ld (080a0h),a		;b38d   ; ...la ficha se apaga
L_B390:
	jp L_B440		;b390
parpadea_el_par:		; Cada dieciseis pasos alterna entre dos parejas de sprites
	call L_B3E1		;b393
	dec (hl)			;b396   ; Cuenta atras
	jr nz,avanza_dentro_de_la_pista		;b397
	ld (hl),010h		;b399   ; Se recarga a 16
	ld a,(080c2h)		;b39b   ; El interruptor
	xor 001h		;b39e   ; Lo cambia de valor
	ld (080c2h),a		;b3a0
	dec a			;b3a3
	ld bc,07e82h		;b3a4   ; Una pareja...
	jr z,pinta_el_par		;b3a7
	ld bc,08676h		;b3a9   ; ...o la otra
pinta_el_par:		; Sube los dos sprites de la pareja, cada uno con su numero
	push bc			;b3ac
	ld a,01ah		;b3ad   ; Numero del primero
	ld c,002h		;b3af   ; Banco 2
	call pinta_un_sprite		;b3b1
	pop bc			;b3b4
	ld b,c			;b3b5
	ld c,002h		;b3b6
	ld a,00eh		;b3b8   ; Numero del segundo
	call pinta_un_sprite		;b3ba   ; Lo pinta
	call L_B410		;b3bd
avanza_dentro_de_la_pista:		; Suma el paso y comprueba los dos bordes de la pista
	ld hl,080a5h		;b3c0
	ld a,(080a8h)		;b3c3   ; El paso
	add a,(hl)			;b3c6
	ld (hl),a			;b3c7   ; Avanza
	ld a,(hl)			;b3c8
	cp 0b8h		;b3c9   ; Borde de abajo
	jr nc,L_B3D7		;b3cb
	cp 008h		;b3cd   ; Y borde de arriba
	jr c,L_B3D7		;b3cf
	call L_9D78		;b3d1   ; El dado
	cp 001h		;b3d4   ; Solo el 0 sigue
	ret nc			;b3d6
L_B3D7:
	ld a,(080a8h)		;b3d7
	call L_8193		;b3da
	ld (080a8h),a		;b3dd
	ret			;b3e0
L_B3E1:
	call L_B349		;b3e1
	ld hl,080a4h		;b3e4
	ret			;b3e7
L_B3E8:
	ld hl,03a40h		;b3e8
	sub a			;b3eb
	ld bc,00040h		;b3ec
	call 00056h		;b3ef   ; BIOS FILVRM - Fills VRAM with value
	call 0fd9ah		;b3f2   ; BIOS HOOKS - System hooks
	ret			;b3f5

; ----------------------------------------------------------------------
; DATOS dos_ret_sueltos: Dos RET huerfanos
;   0xb3f6..0xb3f8  (2 bytes)
DATA_B3F6:
	defb 0c9h,0c9h	; b3f6

; ======================================================================
; CODIGO 0xb3f8..0xb487  (143 bytes)
; ======================================================================


L_B3F8:
	ld a,(0804ah)		;b3f8
	cp 060h		;b3fb
	ret c			;b3fd
	jp L_B68A		;b3fe
L_B401:
	ld a,001h		;b401
	ld hl,0c2c2h		;b403
	call L_8310		;b406
	call L_8310		;b409
	call 0fd9ah		;b40c   ; BIOS HOOKS - System hooks
	ret			;b40f
L_B410:
	call L_C01F		;b410
	nop			;b413
	call 00093h		;b414   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b417
	ld e,080h		;b418
	call 00093h		;b41a   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b41d
	ld e,010h		;b41e
	call 00093h		;b420   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b423
	call 00093h		;b424   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b427
	call 00093h		;b428   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b42b
	ld e,000h		;b42c
	call 00093h		;b42e   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b431
	ld e,012h		;b432
	call 00093h		;b434   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b437
	ld e,001h		;b438
	call 00093h		;b43a   ; BIOS WRTPSG - Writes data to PSG-register
	jp 0fd9ah		;b43d   ; BIOS HOOKS - System hooks
L_B440:
	ld a,007h		;b440
	ld e,0b8h		;b442
	call 00093h		;b444   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b447
	ld e,00ah		;b448
	call 00093h		;b44a   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b44d
	ld e,009h		;b44e
	call 00093h		;b450   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b453
	ld e,008h		;b454
	call 00093h		;b456   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(080a6h)		;b459
	add a,040h		;b45c
	ld e,a			;b45e
	sub a			;b45f
	call 00093h		;b460   ; BIOS WRTPSG - Writes data to PSG-register
	push de			;b463
	ld e,a			;b464
	inc a			;b465
	call 00093h		;b466   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,003h		;b469
	call 00093h		;b46b   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,005h		;b46e
	call 00093h		;b470   ; BIOS WRTPSG - Writes data to PSG-register
	pop de			;b473
	ld a,020h		;b474
	add a,e			;b476
	ld e,a			;b477
	ld a,002h		;b478
	call 00093h		;b47a   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,020h		;b47d
	add a,e			;b47f
	ld e,a			;b480
	ld a,004h		;b481
	call 00093h		;b483   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;b486

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb487..0xb488  (1 bytes)
DATA_B487:
	defb 000h	; b487

; ======================================================================
; CODIGO 0xb488..0xb49d  (21 bytes)
; ======================================================================


L_B488:
	call L_B410		;b488
	ld a,007h		;b48b
	ld e,087h		;b48d
	call 00093h		;b48f   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;b492
	ld e,000h		;b494
	call 00093h		;b496   ; BIOS WRTPSG - Writes data to PSG-register
	call 0fd9ah		;b499   ; BIOS HOOKS - System hooks
	ret			;b49c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb49d..0xb4a0  (3 bytes)
DATA_B49D:
	defb 000h,000h,000h	; b49d

; ======================================================================
; CODIGO 0xb4a0..0xb4f0  (80 bytes)
; ======================================================================


lee_el_lado:		; Devuelve -1, 0 o 1 segun lo que se este pidiendo
	call L_8978		;b4a0   ; Lo que se pide
	or a			;b4a3
	jr z,L_B4B0		;b4a4   ; Nada: cero
	cp 003h		;b4a6   ; Un lado...
	ld a,001h		;b4a8
	ret z			;b4aa
	cp 007h		;b4ab   ; ...y el otro
	ld a,0ffh		;b4ad
	ret z			;b4af
L_B4B0:
	ld a,(0805ch)		;b4b0
	ret			;b4b3
L_B4B4:
	exx			;b4b4
	push af			;b4b5
	ld a,008h		;b4b6
	ld e,000h		;b4b8
	ld b,003h		;b4ba
L_B4BC:
	call 00093h		;b4bc   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;b4bf
	djnz L_B4BC		;b4c0
	ld hl,00c00h		;b4c2
	ld a,000h		;b4c5
	call L_8310		;b4c7
	call L_B720		;b4ca
	pop af			;b4cd
	exx			;b4ce
	ret			;b4cf
L_B4D0:
	ld hl,00e80h		;b4d0
	sub a			;b4d3
	ld bc,00080h		;b4d4
	call 00056h		;b4d7   ; BIOS FILVRM - Fills VRAM with value
	ld hl,01680h		;b4da
	ld bc,00080h		;b4dd
	call 00056h		;b4e0   ; BIOS FILVRM - Fills VRAM with value
	ld hl,0b4f0h		;b4e3
	ld de,0f430h		;b4e6
	ld bc,00050h		;b4e9
	ldir		;b4ec
	jr $+98		;b4ee

; ----------------------------------------------------------------------
; DATOS tabla_de_siete_partes: Siete registros de diez bytes que recorre
;   0xB4E3 (carga 0xB4F0), mas dos ceros de cola. Los campos avanzan a paso
;   fijo de un registro al siguiente: +0x18 en el tercer byte, +0x300 en la
;   pareja siguiente y +1 en el octavo
;   0xb4f0..0xb538  (72 bytes)
DATA_tabla_de_siete_partes:
	defb 001h,040h,050h,086h,019h,086h,019h,002h,008h,0d0h	; b4f0  .@P.......
	defb 001h,040h,068h,089h,019h,089h,019h,003h,008h,0d2h	; b4fa  .@h.......
	defb 001h,040h,080h,08ch,019h,08ch,019h,004h,008h,0d4h	; b504  .@........
	defb 001h,040h,098h,08fh,019h,08fh,019h,005h,008h,0d6h	; b50e  .@........
	defb 001h,040h,0b0h,092h,019h,092h,019h,006h,008h,0d8h	; b518  .@........
	defb 001h,040h,0c8h,095h,019h,095h,019h,007h,008h,0dah	; b522  .@........
	defb 001h,040h,0e0h,098h,019h,098h,019h,008h,008h,0dch	; b52c  .@........
	defb 000h,000h	; b536

; ======================================================================
; CODIGO 0xb538..0xb540  (8 bytes)
; ======================================================================


L_B538:
	ld a,004h		;b538
	ld (0805dh),a		;b53a
	jp L_B704		;b53d

; ----------------------------------------------------------------------
; DATOS tabla_B540: Dieciseis bytes que cargan 0xB604 y 0xB635 en DE
;   0xb540..0xb550  (16 bytes)
DATA_tabla_B540:
	defb 010h,010h,038h,038h,05ch,05ch,04ch,038h,051h,051h,051h,051h,041h,041h,041h,051h	; b540  ..88\\L8QQQQAAAQ

; ======================================================================
; CODIGO 0xb550..0xb556  (6 bytes)
; ======================================================================


L_B550:
	call L_B5F1		;b550
	jp L_B538		;b553

; ----------------------------------------------------------------------
; DATOS ret_y_relleno: un 0xC9 (RET) y ceros detras
;   0xb556..0xb558  (2 bytes)
DATA_B556:
	defb 0c9h,000h	; b556

; ======================================================================
; CODIGO 0xb558..0xb5cf  (119 bytes)
; ======================================================================


L_B558:
	ld hl,0f430h		;b558
	ld b,007h		;b55b
recorre_diez_en_diez:		; Llama B veces a 0xB56E, avanzando de diez en diez
	push bc			;b55d
	push hl			;b55e
	call L_B56E		;b55f   ; Una vuelta
	pop hl			;b562
	pop bc			;b563
	ld de,0000ah		;b564   ; Diez bytes por elemento
	add hl,de			;b567
	djnz recorre_diez_en_diez		;b568   ; El siguiente
	call escribe_cuatro_casillas		;b56a
	ret			;b56d
L_B56E:
	ld de,0f420h		;b56e
	ld bc,0000ah		;b571
	ldir		;b574
	ld hl,0f420h		;b576
	dec (hl)			;b579
	jp nz,recupera_los_diez		;b57a
	ld a,(0f427h)		;b57d
	ld (hl),a			;b580
	ld hl,(0f423h)		;b581
	call 0004ah		;b584   ; BIOS RDVRM - Reads the content of VRAM
	or a			;b587
	ld a,(0f429h)		;b588
	jr nz,escribe_y_apunta_el_patron		;b58b
	call 0004dh		;b58d   ; BIOS WRTVRM - Writes data in VRAM
escribe_y_apunta_el_patron:		; Escribe la casilla de abajo y calcula donde vive su patron
	ld de,00020h		;b590   ; Una fila mas abajo
	add hl,de			;b593
	inc a			;b594
	call 0004dh		;b595   ; BIOS WRTVRM - Writes data in VRAM | WRTVRM
	dec a			;b598
	ld l,a			;b599
	ld h,000h		;b59a
	add hl,hl			;b59c   ; Por ocho: ocho bytes por patron
	add hl,hl			;b59d
	add hl,hl			;b59e
	ld de,00800h		;b59f   ; La tabla de patrones del segundo tercio
	ld a,(0f428h)		;b5a2   ; La fila por la que va
	ld e,a			;b5a5
	add hl,de			;b5a6
	ld b,008h		;b5a7   ; Ocho filas
desplaza_el_patron:		; Rota las ocho filas del patron una posicion
	dec hl			;b5a9
	call 0004ah		;b5aa   ; BIOS RDVRM - Reads the content of VRAM | Lee la fila
	inc hl			;b5ad
	call L_B5D0		;b5ae   ; La escribe corrida
	dec hl			;b5b1
	djnz desplaza_el_patron		;b5b2   ; Otra fila
	sub a			;b5b4   ; La ultima queda a cero
	call L_B5D0		;b5b5
	ld hl,0f428h		;b5b8   ; El contador de filas
	inc (hl)			;b5bb
	ld a,(hl)			;b5bc
	cp 010h		;b5bd   ; Al llegar a dieciseis, se acabo
	jp z,un_paso_de_lo_que_cae		;b5bf
recupera_los_diez:		; Se trae diez bytes de la pila a 0xF420
	pop hl			;b5c2
	pop de			;b5c3
	push de			;b5c4
	push hl			;b5c5
	ld hl,0f420h		;b5c6   ; El area de trabajo de 0xF420
	ld bc,0000ah		;b5c9   ; Diez bytes
	ldir		;b5cc   ; Se copian
	ret			;b5ce

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xb5cf..0xb5d0  (1 bytes)
DATA_B5CF:
	defb 0c9h	; b5cf

; ======================================================================
; CODIGO 0xb5d0..0xb6a6  (214 bytes)
; ======================================================================


L_B5D0:
	call 0004dh		;b5d0   ; BIOS WRTVRM - Writes data in VRAM
	push hl			;b5d3
	ld de,00800h		;b5d4
	add hl,de			;b5d7
	call 0004dh		;b5d8   ; BIOS WRTVRM - Writes data in VRAM
	pop hl			;b5db
	push hl			;b5dc
	ld de,01fffh		;b5dd
	add hl,de			;b5e0
	call 0004ah		;b5e1   ; BIOS RDVRM - Reads the content of VRAM
	inc hl			;b5e4
	call 0004dh		;b5e5   ; BIOS WRTVRM - Writes data in VRAM
	ld de,00800h		;b5e8
	add hl,de			;b5eb
	call 0004dh		;b5ec   ; BIOS WRTVRM - Writes data in VRAM
	pop hl			;b5ef
	ret			;b5f0
L_B5F1:
	ld hl,00f78h		;b5f1
	ld b,008h		;b5f4
recorre_de_dieciseis_en_dieciseis:		; B vueltas, avanzando 0x10 cada vez
	push bc			;b5f6
	push hl			;b5f7
	call L_B604		;b5f8   ; Una vuelta
	pop hl			;b5fb
	pop bc			;b5fc
	ld de,00010h		;b5fd   ; Dieciseis bytes por elemento
	add hl,de			;b600
	djnz recorre_de_dieciseis_en_dieciseis		;b601   ; El siguiente
	ret			;b603
L_B604:
	ld de,0b540h		;b604
	ld bc,00008h		;b607
	ex de,hl			;b60a
	call 0005ch		;b60b   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld bc,02000h		;b60e
	add hl,bc			;b611
	ld bc,00008h		;b612
	ex de,hl			;b615
	call 0005ch		;b616   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ret			;b619
un_paso_de_lo_que_cae:		; Mueve el objeto que cae, le cambia el dibujo y, al llegar abajo, lo vuelve a sacar arriba
	ld hl,(0f423h)		;b61a   ; Su posicion en la VRAM; el juego usa 0xF420-0xF429 de area de trabajo
	nop			;b61d
	call L_B698		;b61e
	ld de,00020h		;b621   ; Una fila mas abajo
	add hl,de			;b624
	call L_B6BC		;b625
	ld a,(0f429h)		;b628   ; El dibujo que le toca
	ld l,a			;b62b
	ld h,000h		;b62c
	add hl,hl			;b62e   ; Por ocho: ocho bytes por patron
	add hl,hl			;b62f
	add hl,hl			;b630
	ld de,00800h		;b631   ; La tabla de patrones del segundo tercio
	add hl,de			;b634
	ld de,0b540h		;b635   ; Los ocho bytes del dibujo
	ex de,hl			;b638
	ld bc,00008h		;b639
	call copia_ocho_y_ocho		;b63c
	ld bc,02000h		;b63f   ; 0x2000: la tabla de color, misma posicion
	add hl,bc			;b642
	ex de,hl			;b643
	ld bc,00008h		;b644
	call L_B6F3		;b647
	call L_B690		;b64a
	ld hl,(0f423h)		;b64d   ; Su posicion otra vez
	ld de,00020h		;b650
	add hl,de			;b653
	call L_A392		;b654
	nop			;b657
	jp z,recupera_los_diez		;b658   ; Si el sitio no esta libre, se queda
	call 0fd9ah		;b65b   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,(0f423h)		;b65e
	sub a			;b661   ; Borra la casilla que ocupaba
	call 0004dh		;b662   ; BIOS WRTVRM - Writes data in VRAM
	call 0fd9ah		;b665   ; BIOS HOOKS - System hooks
	ld a,068h		;b668   ; El dibujo de partida
	ld (0f422h),a		;b66a
	ld hl,(0f423h)		;b66d
	ld de,0ff20h		;b670   ; 0xFF20 = -0x E0, o sea siete filas mas arriba
	add hl,de			;b673
	ld (0f423h),hl		;b674
	ld a,r		;b677   ; El registro de refresco hace de dado: de 1 a 8
	and 007h		;b679
	inc a			;b67b
	ld (0f427h),a		;b67c
	ld a,r		;b67f   ; Y otro de 1 a 128
	and 07fh		;b681
	inc a			;b683
	ld (0f420h),a		;b684
	jp recupera_los_diez		;b687
L_B68A:
	call L_B558		;b68a
	jp reparte_la_ficha		;b68d
L_B690:
	ld a,008h		;b690
	ld (0f428h),a		;b692
	jp 0fd9ah		;b695   ; BIOS HOOKS - System hooks
L_B698:
	call 0004ah		;b698   ; BIOS RDVRM - Reads the content of VRAM
	cp 001h		;b69b
	ret z			;b69d
	cp 002h		;b69e
	ret z			;b6a0
	sub a			;b6a1
	call 0004dh		;b6a2   ; BIOS WRTVRM - Writes data in VRAM
	ret			;b6a5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb6a6..0xb6a8  (2 bytes)
DATA_B6A6:
	defb 000h,000h	; b6a6

; ======================================================================
; CODIGO 0xb6a8..0xb6bb  (19 bytes)
; ======================================================================


copia_ocho_y_ocho:		; Copia dos grupos de ocho bytes
	call L_B6C8		;b6a8   ; El primer grupo
	push de			;b6ab
	push hl			;b6ac
	ex de,hl			;b6ad
	ld de,00008h		;b6ae   ; Ocho bytes mas alla
	add hl,de			;b6b1
	ld bc,00008h		;b6b2   ; Ocho bytes
	call L_B6DD		;b6b5   ; El segundo grupo
	jp avanza_ocho		;b6b8

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xb6bb..0xb6bc  (1 bytes)
DATA_B6BB:
	defb 0c9h	; b6bb

; ======================================================================
; CODIGO 0xb6bc..0xb6c6  (10 bytes)
; ======================================================================


L_B6BC:
	ld (0f423h),hl		;b6bc
	ld a,(0f429h)		;b6bf
	call 0004dh		;b6c2   ; BIOS WRTVRM - Writes data in VRAM
	ret			;b6c5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb6c6..0xb6c8  (2 bytes)
DATA_B6C6:
	defb 000h,000h	; b6c6

; ======================================================================
; CODIGO 0xb6c8..0xb726  (94 bytes)
; ======================================================================


L_B6C8:
	push de			;b6c8
	push hl			;b6c9
	call 0005ch		;b6ca   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld de,00800h		;b6cd
	add hl,de			;b6d0
	ld bc,00008h		;b6d1
	ex de,hl			;b6d4
	pop hl			;b6d5
	push hl			;b6d6
	call 0005ch		;b6d7   ; BIOS LDIRVM - Block transfers to VRAM from memory
	pop hl			;b6da
	pop de			;b6db
	ret			;b6dc
L_B6DD:
	call 00056h		;b6dd   ; BIOS FILVRM - Fills VRAM with value
	ld de,00800h		;b6e0
	add hl,de			;b6e3
	ld bc,00008h		;b6e4
	call 00056h		;b6e7   ; BIOS FILVRM - Fills VRAM with value
	ret			;b6ea
avanza_ocho:		; Suma ocho al puntero y devuelve
	pop hl			;b6eb
	pop de			;b6ec
	ld bc,00008h		;b6ed   ; Ocho bytes
	add hl,bc			;b6f0   ; Avanza
	ex de,hl			;b6f1
	ret			;b6f2
L_B6F3:
	push hl			;b6f3
	call 0005ch		;b6f4   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld bc,00008h		;b6f7
	ld de,00800h		;b6fa
	add hl,de			;b6fd
	ex de,hl			;b6fe
	pop hl			;b6ff
	call 0005ch		;b700   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ret			;b703
L_B704:
	ld a,00ah		;b704
	ld (08abfh),a		;b706
	ld (08baeh),a		;b709
	call 0fd9ah		;b70c   ; BIOS HOOKS - System hooks
	ret			;b70f
L_B710:
	ld a,006h		;b710
	ld (0805dh),a		;b712
	ld a,020h		;b715
	ld (08abfh),a		;b717
	ld (08baeh),a		;b71a
	jp 0fd9ah		;b71d   ; BIOS HOOKS - System hooks
L_B720:
	call L_8310		;b720
	jp L_B710		;b723

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb726..0xb728  (2 bytes)
DATA_B726:
	defb 000h,000h	; b726

; ======================================================================
; CODIGO 0xb728..0xb73e  (22 bytes)
; ======================================================================


escribe_cuatro_casillas:		; Escribe las cuatro casillas del bloque de dos por dos
	call L_8930		;b728   ; La casilla de arriba a la izquierda
	call L_B740		;b72b
	inc hl			;b72e
	call L_B740		;b72f   ; La de al lado
	ld de,0001fh		;b732   ; 0x1F: hasta la fila de abajo
	add hl,de			;b735
	call L_B740		;b736
	inc hl			;b739
	call L_B740		;b73a   ; Y la ultima
	ret			;b73d

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb73e..0xb740  (2 bytes)
DATA_B73E:
	defb 000h,000h	; b73e

; ======================================================================
; CODIGO 0xb740..0xb78d  (77 bytes)
; ======================================================================


L_B740:
	call 0004ah		;b740   ; BIOS RDVRM - Reads the content of VRAM
	cp 0d0h		;b743
	ret c			;b745
	push hl			;b746
	call L_A8F8		;b747
	ld a,(0805ch)		;b74a
	call L_8193		;b74d
	ld (0805ch),a		;b750
	call 0fd9ah		;b753   ; BIOS HOOKS - System hooks
	pop hl			;b756
	ret			;b757
L_B758:
	ld hl,019a8h		;b758
	ld (0807fh),hl		;b75b
	ret			;b75e
cuenta_para_el_aviso:		; Con la bandera puesta, cada dieciseis pasos escribe el aviso
	ld a,(08087h)		;b75f   ; La bandera
	or a			;b762
	ret z			;b763   ; Sin ella no hay aviso
	ld hl,0807bh		;b764
	dec (hl)			;b767   ; Cuenta atras
	ret nz			;b768
	ld (hl),010h		;b769   ; Se recarga a 16
	ld hl,(0807fh)		;b76b   ; La posicion
	ld a,012h		;b76e   ; El dibujo del aviso
	call L_A4E4		;b770
	ret			;b773
opcode_siete_del_guion:		; Copia el guion, prueba las alturas y arranca si esta parado
	call copia_el_guion		;b774   ; El guion
	call L_AD75		;b777   ; La prueba
	ld a,(080aeh)		;b77a   ; El estado
	or a			;b77d
	jr nz,L_B786		;b77e   ; Ya esta en marcha
	ld bc,03401h		;b780   ; El par de partida
	jp L_AC28		;b783
L_B786:
	ld hl,080ach		;b786
	dec (hl)			;b789
	jp L_B81E		;b78a

; ----------------------------------------------------------------------
; DATOS byte_B78D: Un 0x80 suelto entre dos rutinas
;   0xb78d..0xb78e  (1 bytes)
DATA_byte_B78D:
	defb 080h	; b78d

; ======================================================================
; CODIGO 0xb78e..0xb827  (153 bytes)
; ======================================================================


para_si_esta_en_la_franja:		; Con el estado 1, se para si el jugador esta en la franja
	ld (hl),a			;b78e
	ld a,(080aeh)		;b78f   ; El estado
	dec a			;b792   ; Solo el 1
	jr nz,anima_cada_seis		;b793
	call esta_en_la_franja		;b795   ; Mira la franja
	jr z,dibujo_segun_el_tramo		;b798   ; Esta dentro: no se para
	ld a,000h		;b79a
	ld (080aeh),a		;b79c   ; Estado 0
	ld (080ach),a		;b79f   ; Y la cuenta a cero
	jp L_AB3A		;b7a2
dibujo_segun_el_tramo:		; Un dibujo para cada lado
	call en_que_tramo		;b7a5   ; En que tramo esta
	ld (080b1h),a		;b7a8   ; Se guarda
	dec a			;b7ab
	ld a,026h		;b7ac   ; Un dibujo...
	jr z,L_B7B2		;b7ae
	ld a,02eh		;b7b0   ; ...o el otro
L_B7B2:
	ld (080b3h),a		;b7b2
	ld a,002h		;b7b5
	ld (080b2h),a		;b7b7
	ld (080aeh),a		;b7ba
	jp L_AB3A		;b7bd
anima_cada_seis:		; Con el estado 2, cambia de dibujo cada seis pasos
	dec a			;b7c0   ; Solo si el estado es 2
	jp nz,L_DAD0		;b7c1
	ld hl,080b4h		;b7c4   ; Cuenta atras
	dec (hl)			;b7c7
	jr nz,L_B805		;b7c8
	ld (hl),006h		;b7ca   ; Se recarga a 6
	ld a,(080b1h)		;b7cc   ; El tramo
	dec a			;b7cf
	ld bc,02401h		;b7d0   ; Sprite y banco de un tramo...
	jr z,pinta_y_cicla		;b7d3
	ld bc,02c01h		;b7d5   ; ...y del otro
pinta_y_cicla:		; Sube los dos planos y rebobina en uno de los cuatro finales de ciclo
	call elige_el_numero_de_sprite_2		;b7d8   ; Numero de sprite
	call pinta_un_sprite		;b7db   ; Primer plano
	ex af,af'			;b7de
	ld a,(080b3h)		;b7df   ; El dibujo en curso
	ld b,a			;b7e2
	ex af,af'			;b7e3
	call pinta_un_sprite		;b7e4   ; Segundo plano
	dec b			;b7e7
	dec b			;b7e8
	ld a,(080b2h)		;b7e9   ; El paso
	add a,b			;b7ec
	ld (080b3h),a		;b7ed   ; Guarda el dibujo nuevo
	cp 026h		;b7f0   ; Los cuatro finales de ciclo
	jr z,L_B800		;b7f2
	cp 02ah		;b7f4
	jr z,L_B800		;b7f6
	cp 02eh		;b7f8
	jr z,L_B800		;b7fa
	cp 032h		;b7fc
	jr nz,L_B805		;b7fe
L_B800:
	call invierte_el_paso		;b800
	jr mira_la_bandera_de_8050		;b803
L_B805:
	call avanza_y_mira_los_topes		;b805
mira_la_bandera_de_8050:		; A cero, sigue; si no, cuenta larga
	ld a,(08050h)		;b808   ; La bandera
	or a			;b80b
	jr z,L_B81B		;b80c   ; A cero: por el otro lado
	ld a,000h		;b80e
	call compara_el_tramo		;b810
	ld a,080h		;b813   ; Ciento veintiocho pasos
	ld (080ach),a		;b815
	jp L_AB3A		;b818
L_B81B:
	jp mira_el_dibujo_minimo		;b81b
L_B81E:
	jp nz,L_AB3A		;b81e
	ld a,(080adh)		;b821
	jp para_si_esta_en_la_franja		;b824

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb827..0xb828  (1 bytes)
DATA_B827:
	defb 000h	; b827

; ======================================================================
; CODIGO 0xb828..0xb896  (110 bytes)
; ======================================================================


mira_el_dibujo_minimo:		; Por debajo de 0x36 no se hace nada
	ld a,(080b3h)		;b828   ; El dibujo en curso
	cp 036h		;b82b   ; El minimo
	jp c,L_AB3A		;b82d
	ld a,(080b1h)		;b830   ; El tramo
	dec a			;b833
	ld a,026h		;b834   ; Un dibujo...
	jr z,L_B83A		;b836
	ld a,02eh		;b838   ; ...o el otro
L_B83A:
	ld (080b3h),a		;b83a
	jp L_AB3A		;b83d
L_B840:
	dec a			;b840
	ld a,0c6h		;b841
	jr z,L_B847		;b843
	ld a,0ceh		;b845
L_B847:
	ld (080b3h),a		;b847
	ld a,002h		;b84a
	ld (080b2h),a		;b84c
	jp L_AB3A		;b84f
pasa_al_estado_dos_2:		; Estado 2 y el dibujo del tramo
	jr nz,L_B86C		;b852
	ld a,002h		;b854   ; Estado 2
	ld (080aeh),a		;b856
	call en_que_tramo		;b859   ; En que tramo esta
	ld (080b1h),a		;b85c
	dec a			;b85f
	ld a,03eh		;b860   ; Un dibujo...
	jr z,L_B866		;b862
	ld a,048h		;b864   ; ...o el otro
L_B866:
	ld (080b3h),a		;b866
	jp L_AB3A		;b869
L_B86C:
	dec a			;b86c
	jp z,L_AE9A		;b86d
	jp L_AF89		;b870
compara_el_tramo:		; Si el tramo no coincide con lo pedido, se sale por dos niveles
	call en_que_tramo		;b873   ; En que tramo esta
	ld b,a			;b876
	ld a,(08071h)		;b877   ; Lo que se pide
	call L_8193		;b87a
	cp b			;b87d   ; Si no coinciden...
	jr z,L_B884		;b87e
	pop hl			;b880   ; ...se quita la vuelta de la pila
	jp L_AB3A		;b881
L_B884:
	ld a,000h		;b884
	ld (080aeh),a		;b886
	ret			;b889
L_B88A:
	ld hl,07024h		;b88a
	ld (08072h),hl		;b88d
	ld hl,01078h		;b890
	jp L_A52D		;b893

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb896..0xb898  (2 bytes)
DATA_B896:
	defb 000h,000h	; b896

; ======================================================================
; CODIGO 0xb898..0xb9a7  (271 bytes)
; ======================================================================


opcode_diez_del_guion:		; Copia el guion y, si esta parado, lo arranca
	call copia_el_guion		;b898   ; El guion
	call mira_las_dos_alturas		;b89b   ; La prueba
	ld hl,080aeh		;b89e   ; El estado
	ld a,(hl)			;b8a1
	or a			;b8a2
	jr nz,arranca_el_movil_2		;b8a3   ; Ya esta en marcha
	ld (hl),001h		;b8a5   ; Estado 1
pinta_dos_y_prueba:		; Sube dos sprites y comprueba dos casillas
	ld a,(080b3h)		;b8a7   ; El dibujo en curso
	ld b,a			;b8aa
	ld c,001h		;b8ab   ; Banco 1
	ld a,014h		;b8ad   ; Numero de sprite
	call pinta_un_sprite		;b8af
	call pinta_un_sprite		;b8b2
	ld hl,01b50h		;b8b5   ; La casilla que se prueba
	ld de,(080afh)		;b8b8
	ld b,002h		;b8bc   ; Dos veces
L_B8BE:
	ld a,d			;b8be
	call 0004dh		;b8bf   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b8c2
	ld a,e			;b8c3
	call 0004dh		;b8c4   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b8c7
	inc hl			;b8c8
	inc hl			;b8c9
	ld a,010h		;b8ca
	add a,d			;b8cc
	ld d,a			;b8cd
	call 0004dh		;b8ce   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b8d1
	ld a,e			;b8d2
	call 0004dh		;b8d3   ; BIOS WRTVRM - Writes data in VRAM
	inc hl			;b8d6
	inc hl			;b8d7
	inc hl			;b8d8
	ld a,d			;b8d9
	sub 010h		;b8da
	ld d,a			;b8dc
	ld a,010h		;b8dd
	add a,e			;b8df
	ld e,a			;b8e0
	djnz L_B8BE		;b8e1
	jp L_AB3A		;b8e3
arranca_el_movil_2:		; Cada tantos pasos pasa del estado 1 al 2 y elige el dibujo del tramo
	ld hl,080ach		;b8e6
	dec (hl)			;b8e9   ; Cuenta atras
	jp nz,L_AB3A		;b8ea   ; Todavia no
	ld a,(080adh)		;b8ed   ; El periodo, que se recarga
	ld (hl),a			;b8f0
	ld a,(080aeh)		;b8f1   ; El estado
	dec a			;b8f4   ; Solo el 1
	jr nz,estado_dos_del_movil_2		;b8f5
	ld a,002h		;b8f7
	ld (080aeh),a		;b8f9   ; Estado 2
	call en_que_tramo		;b8fc   ; En que tramo esta
	ld (080b1h),a		;b8ff
	dec a			;b902
	ld a,06ch		;b903   ; Un dibujo para un tramo...
	jr z,L_B909		;b905
	ld a,078h		;b907   ; ...y otro para el otro
L_B909:
	ld (080b3h),a		;b909
	sub a			;b90c
	ld (080b7h),a		;b90d
	jp pinta_dos_y_prueba		;b910
estado_dos_del_movil_2:		; Cada seis pasos avanza el dibujo dentro de su ciclo
	dec a			;b913   ; Solo si el estado es 2
	jp nz,anima_tres_sprites		;b914
	ld a,(080b5h)		;b917   ; La bandera de fase
	or a			;b91a
	jp nz,retrocede_y_cuenta_2		;b91b
	ld hl,080b4h		;b91e   ; Cuenta atras
	dec (hl)			;b921
	jr nz,avanza_y_elige		;b922
	ld (hl),006h		;b924   ; Se recarga a 6
	call L_BC22		;b926   ; El dibujo en curso
	cp 06ch		;b929   ; Final del ciclo
	jr nz,L_B931		;b92b
	ld a,070h		;b92d   ; Rebobina
	jr L_B947		;b92f
L_B931:
	cp 070h		;b931
	jr nz,L_B939		;b933
	ld a,06ch		;b935
	jr L_B947		;b937
L_B939:
	cp 078h		;b939
	jr nz,L_B941		;b93b
	ld a,07ch		;b93d
	jr L_B947		;b93f
L_B941:
	cp 07ch		;b941
	jr nz,avanza_y_elige		;b943
	ld a,078h		;b945
L_B947:
	ld (080b3h),a		;b947
avanza_y_elige:		; Suma el paso y elige el dibujo segun donde quede
	ld hl,080afh		;b94a   ; La posicion
	ld a,(080b1h)		;b94d   ; El paso
	add a,(hl)			;b950
	ld (hl),a			;b951   ; Avanza
	cp 008h		;b952   ; Por debajo de ocho...
	jr nc,L_B95C		;b954
	ld a,001h		;b956
	ld b,06ch		;b958   ; ...el dibujo 0x6C
	jr L_B964		;b95a
L_B95C:
	cp 0e0h		;b95c
	jr c,sortea_si_cambia		;b95e
	ld a,0ffh		;b960
	ld b,078h		;b962
L_B964:
	ld (080b1h),a		;b964
	ld a,b			;b967
	ld (080b3h),a		;b968
	jp pinta_dos_y_prueba		;b96b
sortea_si_cambia:		; Solo cambia cinco de cada ocho veces
	ld a,r		;b96e   ; El dado
	cp 060h		;b970   ; Por debajo de 0x60, nada
	jp c,pinta_dos_y_prueba		;b972
	ld a,(080b5h)		;b975   ; Y solo si la fase esta a cero
	or a			;b978
	jp nz,pinta_dos_y_prueba		;b979
	jp mira_si_ha_cambiado_de_tramo		;b97c
L_B97F:
	cp 001h		;b97f
	ld b,06ch		;b981
	jr z,L_B987		;b983
	ld b,078h		;b985
L_B987:
	call L_B964		;b987
reparte_por_la_fase:		; Las fases 1 y 2 tienen camino propio
	ld a,(080b5h)		;b98a   ; La fase
	dec a			;b98d
	jp z,pinta_dos_y_prueba		;b98e   ; Fase 1: nada
	dec a			;b991
	jr nz,L_B99B		;b992   ; Fase 2
	ld a,(080bbh)		;b994   ; La bandera de sentido
	or a			;b997
	jp nz,pinta_dos_y_prueba		;b998
L_B99B:
	ld a,(08050h)		;b99b
	cp 002h		;b99e
	jp nz,pinta_dos_y_prueba		;b9a0
	ld a,001h		;b9a3
	jr $+19		;b9a5

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb9a7..0xb9a8  (1 bytes)
DATA_B9A7:
	defb 000h	; b9a7

; ======================================================================
; CODIGO 0xb9a8..0xb9b7  (15 bytes)
; ======================================================================


mira_si_ha_cambiado_de_tramo:		; Si el tramo es el mismo, no hace nada
	call en_que_tramo		;b9a8   ; En que tramo esta
	ld b,a			;b9ab
	ld a,(080b1h)		;b9ac   ; El tramo guardado
	cp b			;b9af
	jp z,reparte_por_la_fase		;b9b0   ; El mismo: nada que hacer
	ld a,b			;b9b3   ; Y si no, el nuevo
	jp L_B97F		;b9b4

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xb9b7..0xb9b8  (1 bytes)
DATA_B9B7:
	defb 000h	; b9b7

; ======================================================================
; CODIGO 0xb9b8..0xba36  (126 bytes)
; ======================================================================


monta_el_recorrido:		; Guarda el periodo viejo y pone los contadores del recorrido
	ld (080b5h),a		;b9b8
	ld a,(080adh)		;b9bb   ; El periodo en curso
	ld (080bch),a		;b9be   ; Se guarda para luego
	sub a			;b9c1
	ld (080bbh),a		;b9c2   ; Y la bandera de sentido a cero
	ld a,002h		;b9c5
	ld (080adh),a		;b9c7   ; Periodo nuevo, dos
	ld a,001h		;b9ca
	ld (080ach),a		;b9cc   ; Cuenta a uno
	ld (080b8h),a		;b9cf
	ld a,009h		;b9d2
	ld (080b6h),a		;b9d4   ; Y nueve pasos
	jp pinta_dos_y_prueba		;b9d7
retrocede_y_cuenta_2:		; Resta el paso y, cuando las dos cuentas se agotan, sortea
	dec a			;b9da   ; Solo si el estado es 1
	jr nz,avanza_si_cabe		;b9db
	ld hl,080b6h		;b9dd
	ld a,(080b0h)		;b9e0
	sub (hl)			;b9e3   ; Retrocede
	ld (080b0h),a		;b9e4
	ld hl,080b8h		;b9e7
	dec (hl)			;b9ea   ; Cuenta atras
	jp nz,pinta_dos_y_prueba		;b9eb
	ld (hl),002h		;b9ee   ; Se recarga a 2
	dec hl			;b9f0
	dec hl			;b9f1
	dec (hl)			;b9f2   ; Y la cuenta larga
	jp nz,pinta_dos_y_prueba		;b9f3
	ld a,002h		;b9f6
	call L_8C94		;b9f8
	ld a,r		;b9fb   ; El dado
	cp 030h		;b9fd   ; Solo de 0x30 para arriba sigue
	jp c,pinta_dos_y_prueba		;b9ff
	jp L_BA38		;ba02
avanza_si_cabe:		; Prueba la posicion siguiente y, si no cabe, cambia de cuenta
	ld a,(080bbh)		;ba05   ; La bandera de sentido
	or a			;ba08
	jp nz,vuelve_al_periodo_viejo		;ba09
	ld hl,080b0h		;ba0c   ; La posicion
	ld a,(080b6h)		;ba0f   ; El paso
	add a,(hl)			;ba12
	call L_BC14		;ba13   ; Mira si cabe
	jr nc,L_BA27		;ba16   ; No cabe
	ld hl,080b8h		;ba18
	dec (hl)			;ba1b   ; Cuenta atras
	jp nz,pinta_dos_y_prueba		;ba1c
	ld (hl),002h		;ba1f   ; Se recarga a 2
	dec hl			;ba21
	dec hl			;ba22
	inc (hl)			;ba23
	jp pinta_dos_y_prueba		;ba24
L_BA27:
	ld a,070h		;ba27
	call L_BC1B		;ba29
	sub a			;ba2c
	ld (080b5h),a		;ba2d
	call 0fd9ah		;ba30   ; BIOS HOOKS - System hooks
	jp pinta_dos_y_prueba		;ba33

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xba36..0xba38  (2 bytes)
DATA_BA36:
	defb 000h,000h	; ba36

; ======================================================================
; CODIGO 0xba38..0xba64  (44 bytes)
; ======================================================================


L_BA38:
	call en_que_tramo		;ba38
	dec a			;ba3b
	jp z,L_BA98		;ba3c
	ld hl,0ba64h		;ba3f
	ld b,007h		;ba42
busca_el_tramo_por_debajo:		; Recorre la tabla hasta encontrar el tramo que queda por debajo de la X del jugador
	ld a,(08049h)		;ba44   ; La X del jugador
	ld c,a			;ba47
	ld a,(080afh)		;ba48   ; La posicion
	sub (hl)			;ba4b   ; Menos el limite del tramo
	cp c			;ba4c
	jr c,L_BA57		;ba4d   ; Con acarreo: este es el tramo
	inc hl			;ba4f   ; Dos bytes por entrada
	inc hl			;ba50
	djnz busca_el_tramo_por_debajo		;ba51
	ld a,001h		;ba53   ; Ninguno vale: devuelve 1
	jr L_BA59		;ba55
L_BA57:
	inc hl			;ba57
	ld a,(hl)			;ba58
L_BA59:
	ld (080b2h),a		;ba59
	ld a,001h		;ba5c
	ld (080bbh),a		;ba5e
	jp L_BA90		;ba61

; ----------------------------------------------------------------------
; DATOS tabla_BA64: Catorce bytes, una serie que baja de 0x60 a 0x30 de ocho
;   en ocho; la cargan 0xBA3F y 0xBA98
;   0xba64..0xba72  (14 bytes)
DATA_tabla_BA64:
	defw 00260h	; ba64
	defw 00358h	; ba66
	defw 00450h	; ba68
	defw 00548h	; ba6a
	defw 00640h	; ba6c
	defw 00738h	; ba6e
	defw 00830h	; ba70

; ======================================================================
; CODIGO 0xba72..0xba8f  (29 bytes)
; ======================================================================


vuelve_al_periodo_viejo:		; Si cabe, repone el periodo que 0xB9B8 habia guardado
	ld hl,080b0h		;ba72
	ld a,(080b2h)		;ba75   ; El paso
	add a,(hl)			;ba78
	call L_BC14		;ba79   ; Mira si cabe
	jp c,avanza_y_elige		;ba7c   ; No cabe
	sub a			;ba7f
	ld (080bbh),a		;ba80   ; Bandera de sentido a cero
	ld a,(080bch)		;ba83   ; El periodo guardado
	ld (080b8h),a		;ba86
	ld (080adh),a		;ba89   ; Y se repone
	jp L_BA27		;ba8c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xba8f..0xba90  (1 bytes)
DATA_BA8F:
	defb 000h	; ba8f

; ======================================================================
; CODIGO 0xba90..0xbb5f  (207 bytes)
; ======================================================================


L_BA90:
	ld a,002h		;ba90
	ld (080adh),a		;ba92
	jp pinta_dos_y_prueba		;ba95
L_BA98:
	ld hl,0ba64h		;ba98
	ld b,007h		;ba9b
busca_el_tramo_por_encima:		; El gemelo de 0xBA44 para el otro sentido
	ld a,(08049h)		;ba9d   ; La X del jugador
	ld c,a			;baa0
	ld a,(080afh)		;baa1   ; La posicion
	add a,(hl)			;baa4   ; Mas el limite del tramo
	cp c			;baa5
	jr nc,L_BAB0		;baa6   ; Sin acarreo: este es el tramo
	inc hl			;baa8   ; Dos bytes por entrada
	inc hl			;baa9
	djnz busca_el_tramo_por_encima		;baaa
	ld a,008h		;baac   ; Ninguno vale: devuelve 8
	jr L_BAB2		;baae
L_BAB0:
	inc hl			;bab0
	ld a,(hl)			;bab1
L_BAB2:
	jp L_BA59		;bab2
mira_las_dos_alturas:		; Con el estado 2, prueba la casilla y la de dieciseis pixeles mas alla
	ld a,(080aeh)		;bab5
	cp 002h		;bab8   ; Solo el estado 2
	ret nz			;baba
	call L_AD75		;babb
	call L_BC10		;babe   ; La primera prueba
	nop			;bac1   ; Un NOP
	jr z,L_BAD4		;bac2
	ld hl,(080afh)		;bac4   ; La posicion
	ld a,010h		;bac7   ; Dieciseis pixeles mas alla
	add a,l			;bac9
	ld l,a			;baca
	call prueba_dos_alturas		;bacb
	call L_BC10		;bace
	nop			;bad1   ; Otro NOP
	jr nz,mira_las_dos_alturas_2		;bad2
L_BAD4:
	ld a,(080a9h)		;bad4
	or a			;bad7
	ret nz			;bad8
	call mira_la_ficha_y_arranca		;bad9
	ret			;badc
mira_las_dos_alturas_2:		; Lo mismo con la bandera de 0x8050
	ld a,(08050h)		;badd   ; La bandera
	cp 002h		;bae0   ; Solo el valor 2
	ret nz			;bae2
	call L_ADA8		;bae3
	ld hl,(080afh)		;bae6   ; La posicion
	ld a,010h		;bae9   ; Dieciseis pixeles mas alla
	add a,l			;baeb
	ld l,a			;baec
	call L_ADAB		;baed
	ret			;baf0
anima_tres_sprites:		; Con el estado 2, mueve tres sprites a la vez y cicla entre 0x8E y 0xA6
	dec a			;baf1   ; Solo si el estado es 2
	dec a			;baf2
	jr nz,coloca_el_par_c2c2_3		;baf3
	ld hl,(080afh)		;baf5   ; La posicion
	ld a,008h		;baf8   ; Ocho pixeles a un lado
	add a,l			;bafa
	ld l,a			;bafb
	ld a,014h		;bafc   ; Numero del primer sprite
	call pinta_dos_planos		;bafe
	ld a,(080b3h)		;bb01
	ld b,a			;bb04
	ld c,001h		;bb05   ; Banco 1
	ld a,014h		;bb07
	call pinta_un_sprite		;bb09   ; Lo pinta
	dec b			;bb0c
	dec b			;bb0d
	ld a,016h		;bb0e   ; El segundo, dos registros mas alla
	call pinta_un_sprite		;bb10
	ld a,b			;bb13
	ld (080b3h),a		;bb14   ; Guarda el dibujo nuevo
	cp 0a6h		;bb17   ; Final del ciclo
	jr z,monta_la_caida_2		;bb19
	cp 08eh		;bb1b   ; Y principio
	jp nz,L_AB3A		;bb1d
monta_la_caida_2:		; Coloca los tres sprites de la caida y pasa al estado 5
	ld a,005h		;bb20   ; Estado 5
	ld (080aeh),a		;bb22
	ld a,000h		;bb25
	ld (080ach),a		;bb27   ; Cuenta a cero
	ld a,016h		;bb2a
	ld hl,0c2c2h		;bb2c   ; El par de dibujos
	call L_8310		;bb2f
	ld hl,(080afh)		;bb32   ; La posicion
	ld a,008h		;bb35   ; Ocho pixeles abajo...
	add a,h			;bb37
	ld h,a			;bb38
	ld a,008h		;bb39   ; ...y ocho a un lado
	add a,l			;bb3b
	ld l,a			;bb3c
	ld a,014h		;bb3d
	call L_8310		;bb3f
	ld a,014h		;bb42
	ld bc,09401h		;bb44   ; El sprite y el banco
	call pinta_un_sprite		;bb47   ; Lo pinta
	call L_9ACF		;bb4a
	jp L_AB3A		;bb4d
coloca_el_par_c2c2_3:		; El tercer gemelo de 0xAE1B
	ld a,014h		;bb50   ; Numero de sprite
	ld hl,0c2c2h		;bb52   ; El par de dibujos
	call L_8310		;bb55
	sub a			;bb58
	ld (080abh),a		;bb59   ; Borra el primer byte del guion
	jp L_AB3A		;bb5c

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbb5f..0xbb60  (1 bytes)
DATA_BB5F:
	defb 000h	; bb5f

; ======================================================================
; CODIGO 0xbb60..0xbbce  (110 bytes)
; ======================================================================


mueve_al_bicho_de_la_ficha:		; Anima al bicho y, si la ficha lo pide, lo desplaza
	call anima_al_bicho		;bb60   ; Primero el bicho de siempre
	ld a,(0e03dh)		;bb63   ; El campo de la ficha que enciende esto
	or a			;bb66
	ret z			;bb67   ; Apagado: nada
	call 0fd9ah		;bb68   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,0e03eh		;bb6b
	dec (hl)			;bb6e   ; Cuenta atras
	ret nz			;bb6f
	ld a,(0e03fh)		;bb70   ; El periodo, que se recarga
	ld (hl),a			;bb73
	ld hl,0e040h		;bb74
	ld a,(0e042h)		;bb77   ; El paso
	add a,(hl)			;bb7a
	ld (hl),a			;bb7b   ; Avanza
	ld a,(0e043h)		;bb7c   ; Un tope...
	cp (hl)			;bb7f
	jr z,L_BB88		;bb80
	ld a,(0e044h)		;bb82   ; ...y el otro
	cp (hl)			;bb85
	jr nz,pinta_al_de_la_ficha		;bb86
L_BB88:
	ld a,(0e042h)		;bb88
	call L_8193		;bb8b
	ld (0e042h),a		;bb8e
pinta_al_de_la_ficha:		; Sube el sprite del bicho de la ficha
	ld hl,(0e040h)		;bb91   ; Su posicion
	ld a,014h		;bb94   ; Numero de sprite
	call L_8310		;bb96
	ld a,014h		;bb99
	ld bc,01c01h		;bb9b   ; El par de dibujos
	call pinta_un_sprite		;bb9e
	ret			;bba1
mira_si_toca_al_de_la_ficha:		; Ventana de 16x8 alrededor del jugador
	ld hl,08049h		;bba2   ; La X del jugador
	ld a,(0e040h)		;bba5   ; La del bicho
	sub 008h		;bba8   ; Ocho pixeles por delante
	cp (hl)			;bbaa
	ret nc			;bbab
	nop			;bbac   ; Dos NOP
	nop			;bbad
	add a,010h		;bbae   ; Dieciseis de ventana
	cp (hl)			;bbb0
	ret c			;bbb1
	inc hl			;bbb2
	ld a,(0e041h)		;bbb3   ; Y ahora la Y
	sub 028h		;bbb6   ; Cuarenta por arriba
	cp (hl)			;bbb8
	ret nc			;bbb9
	add a,008h		;bbba   ; Ocho de ventana
	cp (hl)			;bbbc
	ret c			;bbbd
	pop hl			;bbbe   ; Se quita la vuelta de la pila: no se vuelve a quien llamo
	ld a,006h		;bbbf
	call L_BBF8		;bbc1
	ld a,(0e042h)		;bbc4   ; El sentido decide con que sprite se pinta
	dec a			;bbc7
	jp nz,L_89D6		;bbc8
	jp L_8A64		;bbcb

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbbce..0xbbd0  (2 bytes)
DATA_BBCE:
	defb 000h,000h	; bbce

; ======================================================================
; CODIGO 0xbbd0..0xbbd6  (6 bytes)
; ======================================================================


L_BBD0:
	call mira_si_toca_al_de_la_ficha		;bbd0
	jp L_8C50		;bbd3

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbbd6..0xbbd8  (2 bytes)
DATA_BBD6:
	defb 000h,000h	; bbd6

; ======================================================================
; CODIGO 0xbbd8..0xbbde  (6 bytes)
; ======================================================================


L_BBD8:
	call mira_si_toca_al_de_la_ficha		;bbd8
	jp cae_un_escalon		;bbdb

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbbde..0xbbdf  (1 bytes)
DATA_BBDE:
	defb 000h	; bbde

; ======================================================================
; CODIGO 0xbbdf..0xbbf7  (24 bytes)
; ======================================================================


baja_cuatro_si_toca:		; Con 0x80C4 a 0x12, baja cuatro pixeles la posicion
	ld hl,(08049h)		;bbdf   ; La posicion del jugador
	ld a,(080c4h)		;bbe2   ; La bandera
	cp 012h		;bbe5   ; Solo el valor 0x12
	ret nz			;bbe7
	ld a,004h		;bbe8   ; Cuatro pixeles mas abajo
	add a,h			;bbea
	ld h,a			;bbeb
	jr L_BBF3		;bbec
L_BBEE:
	ld a,012h		;bbee
	jr L_BBF3		;bbf0
L_BBF2:
	sub a			;bbf2
L_BBF3:
	ld (080c4h),a		;bbf3
	ret			;bbf6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbbf7..0xbbf8  (1 bytes)
DATA_BBF7:
	defb 000h	; bbf7

; ======================================================================
; CODIGO 0xbbf8..0xbbfe  (6 bytes)
; ======================================================================


L_BBF8:
	ld (08048h),a		;bbf8
	jp L_BBEE		;bbfb

; ----------------------------------------------------------------------
; DATOS datos_BBFE: Diez bytes entre dos rutinas. Ninguna instruccion los
;   apunta
;   0xbbfe..0xbc08  (10 bytes)
DATA_datos_BBFE:
	defb 000h,000h,0cdh,0d0h,088h,0cdh,0f2h,0bbh,0c9h,000h	; bbfe  ..........

; ======================================================================
; CODIGO 0xbc08..0xbc0f  (7 bytes)
; ======================================================================


L_BC08:
	ld bc,00101h		;bc08
	ld hl,08058h		;bc0b
	ret			;bc0e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbc0f..0xbc10  (1 bytes)
DATA_BC0F:
	defb 000h	; bc0f

; ======================================================================
; CODIGO 0xbc10..0xbcff  (239 bytes)
; ======================================================================


L_BC10:
	dec b			;bc10
	ret nz			;bc11
	dec c			;bc12
	ret			;bc13
L_BC14:
	ld (hl),a			;bc14
	ld a,(0804ah)		;bc15
	cp (hl)			;bc18
	ccf			;bc19
	ret			;bc1a
L_BC1B:
	ld a,(0804ah)		;bc1b
	ld (080b0h),a		;bc1e
	ret			;bc21
L_BC22:
	call L_B410		;bc22
	ld a,00ch		;bc25
	ld e,004h		;bc27
	call 00093h		;bc29   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(080b3h)		;bc2c
	ret			;bc2f
opcode_cinco_del_guion:		; Copia el guion y, si esta parado, lo pone en el estado 2
	call copia_el_guion		;bc30   ; El guion
	call mira_si_esta_delante		;bc33   ; La prueba
	ld hl,080aeh		;bc36   ; El estado
	ld a,(hl)			;bc39
	or a			;bc3a
	jr nz,cuenta_y_alterna		;bc3b   ; Ya esta en marcha
	ld (hl),002h		;bc3d   ; Estado 2
pinta_cuatro_sprites:		; Sube cuatro sprites seguidos con la misma pareja
	ld a,014h		;bc3f   ; Numero del primero
	ld bc,08802h		;bc41   ; El par de dibujos, banco 2
	call pinta_un_sprite		;bc44
	call pinta_un_sprite		;bc47
	call pinta_un_sprite		;bc4a
	ex af,af'			;bc4d
	ld a,(080b3h)		;bc4e   ; El dibujo en curso
	ld b,a			;bc51
	ex af,af'			;bc52
	call pinta_un_sprite		;bc53
	ld hl,(080afh)		;bc56
	ld a,014h		;bc59
	ld b,004h		;bc5b   ; Cuatro sprites
pinta_una_columna_3:		; B sprites, cada uno dieciseis pixeles mas abajo
	call L_8310		;bc5d   ; Uno
	ex af,af'			;bc60
	ld a,010h		;bc61   ; Dieciseis pixeles de separacion
	add a,h			;bc63
	ld h,a			;bc64
	ex af,af'			;bc65
	djnz pinta_una_columna_3		;bc66   ; El siguiente
	jp L_AB3A		;bc68
cuenta_y_alterna:		; Cada diez pasos y cada tres, alterna entre 0x8E y 0xD4
	dec hl			;bc6b
	dec hl			;bc6c
	dec (hl)			;bc6d   ; Cuenta atras larga
	jp nz,L_AB3A		;bc6e
	ld (hl),00ah		;bc71   ; Se recarga a 10
	ld hl,080b4h		;bc73
	dec (hl)			;bc76   ; Cuenta atras corta
	jr nz,$+19		;bc77
	ld (hl),003h		;bc79   ; Se recarga a 3
	call L_BCD9		;bc7b
	ld a,(080b3h)		;bc7e   ; El dibujo en curso
	cp 08eh		;bc81   ; Si es 0x8E...
	ld a,0d4h		;bc83   ; ...pasa a 0xD4...
	jr z,avanza_y_tope		;bc85
	ld a,08eh		;bc87   ; ...y si no, al reves
avanza_y_tope:		; Guarda el dibujo, avanza y no deja pasar de 0xEA
	ld (080b3h),a		;bc89   ; El dibujo
	ld hl,080afh		;bc8c
	inc (hl)			;bc8f   ; Una posicion mas
	ld a,(08049h)		;bc90   ; La X del jugador
	cp 0eah		;bc93   ; El tope
	jp c,pinta_cuatro_sprites		;bc95
	ld a,0e8h		;bc98   ; Se queda en 0xE8
	ld (08049h),a		;bc9a
	jp pinta_cuatro_sprites		;bc9d
mira_si_esta_delante:		; Ocho pixeles de margen sobre la X del jugador
	ld a,(080afh)		;bca0   ; La posicion
	ld hl,08049h		;bca3   ; La X del jugador
	add a,008h		;bca6   ; Ocho de margen
	cp (hl)			;bca8
	jr c,mira_si_esta_debajo		;bca9
	ld b,0b2h		;bcab   ; El dibujo que le toca
L_BCAD:
	call lee_el_mando		;bcad
	djnz L_BCAD		;bcb0
	call 0003bh		;bcb2   ; BIOS INITIO - Initialises the device
	ret			;bcb5
mira_si_esta_debajo:		; Con la bandera a 2, compara la posicion con la del jugador
	ld a,(08050h)		;bcb6   ; La bandera
	cp 002h		;bcb9   ; Solo el valor 2
	ret nz			;bcbb
	ld a,(080afh)		;bcbc   ; La posicion
	ld hl,08052h		;bcbf
	add a,008h		;bcc2   ; Ocho pixeles de margen
	cp (hl)			;bcc4
	ret c			;bcc5
	ld a,(08053h)		;bcc6   ; La otra coordenada
	cp 088h		;bcc9   ; El limite
	jp nc,L_A0DC		;bccb
	call L_A0D8		;bcce
	ld hl,080b9h		;bcd1
	dec (hl)			;bcd4   ; Cuenta atras
	ret nz			;bcd5
	jp L_BD00		;bcd6
L_BCD9:
	call L_BFBB		;bcd9
	ld a,00ch		;bcdc
	ld e,002h		;bcde
	call 00093h		;bce0   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;bce3
	ld e,00ah		;bce5
	call 00093h		;bce7   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,007h		;bcea
	ld e,087h		;bcec
	jp 00093h		;bcee   ; BIOS WRTPSG - Writes data to PSG-register
L_BCF1:
	ld b,064h		;bcf1
	jr L_BCF7		;bcf3
L_BCF5:
	ld b,032h		;bcf5
L_BCF7:
	call L_A861		;bcf7
	djnz L_BCF7		;bcfa
	jp L_A870		;bcfc

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbcff..0xbd00  (1 bytes)
DATA_BCFF:
	defb 000h	; bcff

; ======================================================================
; CODIGO 0xbd00..0xbdb1  (177 bytes)
; ======================================================================


L_BD00:
	call L_BCD9		;bd00
	ld a,00ch		;bd03
	ld e,020h		;bd05
	call 00093h		;bd07   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;bd0a
	ld e,01fh		;bd0c
	call 00093h		;bd0e   ; BIOS WRTPSG - Writes data to PSG-register
	ld b,004h		;bd11
L_BD13:
	call alterna_el_color		;bd13
	push bc			;bd16
	ld bc,02000h		;bd17
	call espera		;bd1a
	pop bc			;bd1d
	djnz L_BD13		;bd1e
	call L_BCD9		;bd20
	ld a,00ch		;bd23
	ld e,020h		;bd25
	call 00093h		;bd27   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;bd2a
	ld e,01fh		;bd2c
	call 00093h		;bd2e   ; BIOS WRTPSG - Writes data to PSG-register
	ld b,010h		;bd31
pinta_cuatro_filas:		; Escribe cuatro filas del mapa, la de arriba, la de en medio y la de abajo
	push bc			;bd33
	ld hl,05460h		;bd34   ; Una fila por encima del mapa
	call L_BD51		;bd37
	ld hl,05480h		;bd3a   ; El principio del mapa
	call L_BD51		;bd3d
	ld hl,054a0h		;bd40   ; Una fila por debajo
	call L_BD51		;bd43
	ld hl,05480h		;bd46   ; Y otra vez la de en medio
	call L_BD51		;bd49
	pop bc			;bd4c
	djnz pinta_cuatro_filas		;bd4d   ; Otra vuelta
	jr L_BD64		;bd4f
L_BD51:
	ld de,01880h		;bd51
	ld bc,00280h		;bd54
	call 0005ch		;bd57   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ld bc,00100h		;bd5a
	call espera		;bd5d
	call alterna_el_color		;bd60
	ret			;bd63
L_BD64:
	ld hl,05480h		;bd64
	call L_BD51		;bd67
	call 0fd9ah		;bd6a   ; BIOS HOOKS - System hooks
	ld a,080h		;bd6d
	ld (080b3h),a		;bd6f
	ld c,001h		;bd72
L_BD74:
	ld a,(080b3h)		;bd74
	ld b,a			;bd77
	ld e,004h		;bd78
	ld a,014h		;bd7a
L_BD7C:
	call pinta_un_sprite		;bd7c
	dec b			;bd7f
	dec b			;bd80
	dec e			;bd81
	jr nz,L_BD7C		;bd82
	push bc			;bd84
	ld bc,00800h		;bd85
	call espera		;bd88
	pop bc			;bd8b
	ld a,b			;bd8c
	inc a			;bd8d
	inc a			;bd8e
	ld (080b3h),a		;bd8f
	cp 08eh		;bd92
	jp nz,L_BD74		;bd94
	call 0fd9ah		;bd97   ; BIOS HOOKS - System hooks
	ld a,001h		;bd9a
	call L_DF76		;bd9c
	call 0fd9ah		;bd9f   ; BIOS HOOKS - System hooks
L_BDA2:
	call L_A861		;bda2
	call L_A870		;bda5
	call lee_el_mando		;bda8
	call mira_el_abandono		;bdab
	jp L_BDA2		;bdae

; ----------------------------------------------------------------------
; DATOS tabla_BDB1: Dieciocho bytes que carga 0xD9ED en DE
;   0xbdb1..0xbdc3  (18 bytes)
DATA_tabla_BDB1:
	defw 00a23h	; bdb1
	defw 00f25h	; bdb3
	defw 01426h	; bdb5
	defw 01927h	; bdb7
	defw 00528h	; bdb9
	defw 00129h	; bdbb
	defw 0ffffh	; bdbd
	defw 0ffffh	; bdbf
	defw 0ffffh	; bdc1

; ======================================================================
; CODIGO 0xbdc3..0xbdff  (60 bytes)
; ======================================================================


L_BDC3:
	exx			;bdc3
	ld b,a			;bdc4
	inc b			;bdc5
pinta_al_azar:		; Sortea una casilla y escribe en ella una pareja de la tabla de DE
	call L_9D78		;bdc6   ; El dado
	cp b			;bdc9   ; Repite hasta sacar uno menor que B
	jr nc,pinta_al_azar		;bdca
	ccf			;bdcc   ; CCF + RLCA: por dos, con el bit de abajo a cero
	rlca			;bdcd
	exx			;bdce
	push hl			;bdcf
	ld l,a			;bdd0
	ld h,000h		;bdd1
	add hl,de			;bdd3   ; La entrada de la tabla
	ld a,(hl)			;bdd4   ; La baldosa
	inc hl			;bdd5
	ld c,(hl)			;bdd6   ; Y su acompanante
	pop hl			;bdd7
	call 0004dh		;bdd8   ; BIOS WRTVRM - Writes data in VRAM | WRTVRM
	push hl			;bddb
	ld a,b			;bddc
	jp L_BDF0		;bddd
L_BDE0:
	push bc			;bde0
	ld b,001h		;bde1
pinta_en_dos_bucles:		; Bucle doble: B por C llamadas
	push bc			;bde3
	call L_A861		;bde4   ; Una vuelta
	pop bc			;bde7
	djnz pinta_en_dos_bucles		;bde8   ; Las B
	pop bc			;bdea
	dec c			;bdeb   ; Y las C
	jr nz,L_BDE0		;bdec
L_BDEE:
	jr L_BDFA		;bdee
L_BDF0:
	ld (0bde2h),a		;bdf0
	ld a,c			;bdf3
	or a			;bdf4
	jr z,L_BDEE		;bdf5
	jp L_BDE0		;bdf7
L_BDFA:
	call L_A870		;bdfa
	pop hl			;bdfd
	ret			;bdfe

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbdff..0xbe00  (1 bytes)
DATA_BDFF:
	defb 000h	; bdff

; ======================================================================
; CODIGO 0xbe00..0xbeef  (239 bytes)
; ======================================================================


bucle_principal:		; A donde salta 0x8103. Pinta la portada y se queda con el juego
	call L_DBC6		;be00   ; Preparativos de la pantalla
	ld hl,04281h		;be03   ; El mapa comprimido de la portada, el que lleva el titulo
	call pinta_el_mapa		;be06   ; Lo descomprime y lo sube
	call 0fd9ah		;be09   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,01880h		;be0c
	ld de,0e000h		;be0f
	exx			;be12
	ld b,008h		;be13
monta_el_final:		; Se trae una banda de la VRAM y escribe las tres franjas del cierre
	exx			;be15
	ld bc,00020h		;be16   ; Una fila
	call 00059h		;be19   ; BIOS LDIRMV - Block transfers to memory from VRAM | LDIRMV: de la VRAM a la memoria
	ld bc,00020h		;be1c   ; Siguiente fila
	add hl,bc			;be1f
	exx			;be20
	djnz monta_el_final		;be21   ; Otra vuelta
	call L_DBD8		;be23
	ld hl,01700h		;be26   ; La posicion de partida del cierre
	ld (0f420h),hl		;be29
	ld b,018h		;be2c   ; Veinticuatro filas hacia un lado...
	ld a,001h		;be2e
	call L_BE50		;be30
	ld b,007h		;be33   ; ...siete hacia el otro...
	ld a,0ffh		;be35
	call L_BE50		;be37
	ld b,007h		;be3a   ; ...y siete de vuelta
	ld a,001h		;be3c
	call L_BE50		;be3e
	ld bc,00000h		;be41
	call espera		;be44   ; Una espera
	ld a,0ffh		;be47
	ld b,00eh		;be49   ; Y catorce mas
	call L_BE50		;be4b
	jr L_BE9C		;be4e
L_BE50:
	ld (0f422h),a		;be50
L_BE53:
	push bc			;be53
	ld de,(0f420h)		;be54
	call 0fd9ah		;be58   ; BIOS HOOKS - System hooks
	ld hl,0dfe0h		;be5b
	ld b,00ah		;be5e
sube_una_fila_si_cabe:		; Sube una fila a la VRAM solo si la direccion esta por debajo de 0x1800
	push bc			;be60
	push de			;be61
	push hl			;be62
	ex de,hl			;be63
	push de			;be64
	ld de,01800h		;be65   ; El limite de la tabla de nombres
	rst 20h			;be68   ; RST 20h = DCOMPR: compara HL con DE
	pop de			;be69
	jr c,avanza_la_fila		;be6a   ; Por encima: no se sube
	ex de,hl			;be6c
	ld bc,00020h		;be6d   ; Una fila
	call 0005ch		;be70   ; BIOS LDIRVM - Block transfers to VRAM from memory | LDIRVM
avanza_la_fila:		; Suma 32 al origen y al destino y repite
	pop hl			;be73
	ld bc,00020h		;be74   ; Una fila
	add hl,bc			;be77
	ex de,hl			;be78
	pop hl			;be79
	add hl,bc			;be7a
	ex de,hl			;be7b
	pop bc			;be7c
	djnz sube_una_fila_si_cabe		;be7d   ; Otra vuelta
	ld bc,00800h		;be7f   ; Una espera
	call espera		;be82
	ld hl,(0f420h)		;be85   ; La posicion
	ld a,(0f422h)		;be88   ; El sentido
	ld bc,00020h		;be8b   ; Hacia abajo...
	dec a			;be8e
	jr z,L_BE94		;be8f
	ld bc,0ffe0h		;be91   ; ...o hacia arriba (0xFFE0 es -32)
L_BE94:
	add hl,bc			;be94
	ld (0f420h),hl		;be95
	pop bc			;be98
	djnz L_BE53		;be99
	ret			;be9b
L_BE9C:
	ld hl,04281h		;be9c
	call pinta_el_mapa		;be9f
	call 0fd9ah		;bea2   ; BIOS HOOKS - System hooks
	jp monta_la_pantalla_final		;bea5
compara_con_el_limite:		; Si no coincide con 0x8061, se va
	dec hl			;bea8
	ld de,08061h		;bea9   ; El limite guardado
	rst 20h			;beac   ; RST 20h = DCOMPR
	jp nz,L_A864		;bead   ; No coincide
	push hl			;beb0
	call L_A7C0		;beb1   ; Lo que toque hacer
	call L_9B00		;beb4   ; Y la musica
	pop hl			;beb7
	jp L_A864		;beb8
L_BEBB:
	dec a			;bebb
	jp z,L_A940		;bebc
	ret			;bebf
pasa_al_estado_tres_2:		; Con la bandera a 1, pone dos estados a 3
	ld a,(0809eh)		;bec0   ; La bandera
	dec a			;bec3
	jp nz,L_8F50		;bec4   ; Solo el valor 1
	ld a,003h		;bec7
	ld (08050h),a		;bec9   ; Estado 3
	ld a,003h		;becc
	ld (08051h),a		;bece   ; Y el otro tambien
	jp L_A12A		;bed1
L_BED4:
	call sale_si_la_musica_acabo_2		;bed4
	nop			;bed7
	call 0fd9ah		;bed8   ; BIOS HOOKS - System hooks
	ret z			;bedb
	ld a,(0809eh)		;bedc
	or a			;bedf
	ret nz			;bee0
	ld a,(080a9h)		;bee1
	or a			;bee4
	ret			;bee5
L_BEE6:
	ld (080c8h),a		;bee6
	ld hl,080c9h		;bee9
	ld (hl),0ffh		;beec
	ret			;beee

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbeef..0xbef0  (1 bytes)
DATA_BEEF:
	defb 000h	; beef

; ======================================================================
; CODIGO 0xbef0..0xbf1e  (46 bytes)
; ======================================================================


L_BEF0:
	jp z,L_A090		;bef0
	ld a,(080c8h)		;bef3
	or a			;bef6
	ret z			;bef7
	ld hl,080c9h		;bef8
	ld e,(hl)			;befb
	ld a,000h		;befc
	call 00093h		;befe   ; BIOS WRTPSG - Writes data to PSG-register
	ld e,a			;bf01
	inc a			;bf02
	call 00093h		;bf03   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;bf06
	ld e,00ah		;bf08
	call L_BF7C		;bf0a
	ld a,(hl)			;bf0d
	sub 008h		;bf0e
	ld (hl),a			;bf10
	ret nc			;bf11
	ld a,008h		;bf12
	ld e,000h		;bf14
	call 00093h		;bf16   ; BIOS WRTPSG - Writes data to PSG-register
	sub a			;bf19
	ld (080c8h),a		;bf1a
	ret			;bf1d

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbf1e..0xbf20  (2 bytes)
DATA_BF1E:
	defb 000h,000h	; bf1e

; ======================================================================
; CODIGO 0xbf20..0xbf3f  (31 bytes)
; ======================================================================


pinta_y_mira_los_cuatro_hitos:		; Pinta y, en cuatro dibujos concretos, llama a 0xBF40
	call pinta_un_sprite		;bf20   ; Lo pinta
	push bc			;bf23
	push hl			;bf24
	push af			;bf25
	ld a,b			;bf26
	cp 014h		;bf27   ; Primer hito
	call z,llama_si_suena		;bf29
	cp 028h		;bf2c   ; Segundo
	call z,llama_si_suena		;bf2e
	cp 0bah		;bf31   ; Tercero
	call z,llama_si_suena		;bf33
	cp 0ceh		;bf36   ; Y cuarto
	call z,llama_si_suena		;bf38
	pop af			;bf3b
	pop hl			;bf3c
	pop bc			;bf3d
	ret			;bf3e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbf3f..0xbf40  (1 bytes)
DATA_BF3F:
	defb 000h	; bf3f

; ======================================================================
; CODIGO 0xbf40..0xbf87  (71 bytes)
; ======================================================================


llama_si_suena:		; Solo llama si la musica esta encendida
	push af			;bf40
	call suena_la_musica		;bf41   ; Mira si la musica suena
	or a			;bf44
	jr z,L_BF49		;bf45   ; No suena: se sale
	pop af			;bf47
	ret			;bf48
L_BF49:
	call L_B410		;bf49
	ld a,007h		;bf4c
	ld e,087h		;bf4e
	call 00093h		;bf50   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,(0e052h)		;bf53
	or a			;bf56
	ld e,010h		;bf57
	jr z,L_BF5D		;bf59
	ld e,00ah		;bf5b
L_BF5D:
	ld a,006h		;bf5d
	call 00093h		;bf5f   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,00ch		;bf62
	ld e,005h		;bf64
	call 00093h		;bf66   ; BIOS WRTPSG - Writes data to PSG-register
	pop af			;bf69
	ret			;bf6a
L_BF6B:
	ld a,(080a9h)		;bf6b
	or a			;bf6e
	ret z			;bf6f
	pop hl			;bf70
	ret			;bf71
sale_si_esta_ocupado:		; Con la bandera puesta, se quita la vuelta de la pila
	ld hl,01b43h		;bf72   ; La casilla
	ld a,(080a9h)		;bf75   ; La bandera de ocupado
	or a			;bf78
	ret z			;bf79   ; Libre: devuelve normal
	pop hl			;bf7a   ; Ocupado: se sale por dos niveles
	ret			;bf7b
L_BF7C:
	call 00093h		;bf7c   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,007h		;bf7f
	ld e,0b8h		;bf81
	call 00093h		;bf83   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;bf86

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbf87..0xbf88  (1 bytes)
DATA_BF87:
	defb 000h	; bf87

; ======================================================================
; CODIGO 0xbf88..0xbfff  (119 bytes)
; ======================================================================


L_BF88:
	ld a,(09c8fh)		;bf88
	or a			;bf8b
	nop			;bf8c
	jp mueve_al_bicho_de_la_ficha		;bf8d
L_BF90:
	ld a,r		;bf90
	and 00fh		;bf92
	add a,004h		;bf94
	ld (09e39h),a		;bf96
	ret			;bf99
L_BF9A:
	ld a,(08094h)		;bf9a
	or a			;bf9d
	ret z			;bf9e
	jp L_9F68		;bf9f
mira_tres_banderas:		; Solo sigue si las tres estan a cero
	ld a,(080a9h)		;bfa2   ; La primera
	or a			;bfa5
	jr nz,L_BFB9		;bfa6
	ld a,(080c8h)		;bfa8   ; La segunda
	or a			;bfab
	jr nz,L_BFB9		;bfac
	ld a,(0809eh)		;bfae   ; Y la tercera
	or a			;bfb1
	jr nz,L_BFB9		;bfb2
L_BFB4:
	ld a,006h		;bfb4
	ld e,01fh		;bfb6
	ret			;bfb8
L_BFB9:
	pop hl			;bfb9
	ret			;bfba
L_BFBB:
	call L_BFB4		;bfbb
	jp L_B410		;bfbe
reparte_por_lo_pedido:		; El valor 1 tiene rutina propia
	push af			;bfc1
	cp 001h		;bfc2   ; Lo que se pide
	jr nz,L_BFD6		;bfc4   ; No es el 1
	call L_8FD0		;bfc6
	ld a,(0804dh)		;bfc9   ; La bandera de parpadeo
	or a			;bfcc
	jr z,L_BFD1		;bfcd
	pop af			;bfcf   ; Puesta: se sale
	ret			;bfd0
L_BFD1:
	pop af			;bfd1
	sub a			;bfd2
	jp prepara_el_salto		;bfd3
L_BFD6:
	pop af			;bfd6
	cp 002h		;bfd7
	jr nz,solo_el_ocho		;bfd9
	call vuelve_al_otro_lado		;bfdb
	jp L_8AAD		;bfde
solo_el_ocho:		; Solo el valor 8 sigue
	cp 008h		;bfe1   ; El valor 8
	ret nz			;bfe3
	ret nz			;bfe4   ; Este RET NZ no puede ejecutarse: el de arriba ya ha vuelto
	ret nz			;bfe5   ; Y este tampoco
	call vuelve_a_un_lado		;bfe6
	jp L_8AB1		;bfe9
es_uno_de_los_cuatro:		; Devuelve Z si A es 3, 7, 2 u 8
	cp 003h		;bfec   ; El 3
	ret z			;bfee
	cp 007h		;bfef   ; El 7
	ret z			;bff1
	cp 002h		;bff2   ; El 2
	ret z			;bff4
	cp 008h		;bff5   ; Y el 8
	ret			;bff7
L_BFF8:
	ld a,(0805ch)		;bff8
	ld (080fah),a		;bffb
	ret			;bffe

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xbfff..0xc000  (1 bytes)
DATA_BFFF:
	defb 000h	; bfff

; ======================================================================
; CODIGO 0xc000..0xc076  (118 bytes)
; ======================================================================


L_C000:
	call cuenta_del_marcador		;c000
	call pagina1_a_ram		;c003
	jp 07f90h		;c006
L_C009:
	ld hl,07900h		;c009
	ld (080fch),hl		;c00c
	ret			;c00f
sale_si_la_musica_acabo:		; De 0x69 en adelante, se sale por dos niveles
	ld a,(0806ch)		;c010   ; El contador de la musica
	cp 069h		;c013   ; El limite
	ret nc			;c015
	pop hl			;c016   ; Dos POP: no se vuelve a quien llamo
	pop hl			;c017
	ret			;c018
L_C019:
	call sale_si_la_musica_acabo		;c019
	jp L_A0A8		;c01c
L_C01F:
	call sale_si_la_musica_acabo		;c01f
	jp mira_tres_banderas		;c022
L_C025:
	cp 069h		;c025
	jr nc,L_C02A		;c027
	ret			;c029
L_C02A:
	jp L_87F7		;c02a
L_C02D:
	ld a,(0806ch)		;c02d
	cp 068h		;c030
	ld a,(0809eh)		;c032
	ret nc			;c035
	jr L_C059		;c036
L_C038:
	ld a,(0806ch)		;c038
	cp 068h		;c03b
	jp nc,L_A7F2		;c03d
	ret			;c040
suena_la_musica:		; Devuelve cero si el juego esta congelado o la musica acabo
	ld a,(09c8fh)		;c041   ; La bandera que congela el juego
	or a			;c044
	ret nz			;c045   ; Puesta: se devuelve tal cual
	ld a,(0806ch)		;c046   ; El contador de la musica
	cp 069h		;c049   ; El limite
	ret c			;c04b
	sub a			;c04c
	ret			;c04d
sale_si_la_musica_acabo_2:		; El gemelo de 0xC010
	ld a,(0806ch)		;c04e   ; El contador de la musica
	cp 069h		;c051   ; El limite
	ret nc			;c053
	pop hl			;c054   ; Dos POP: no se vuelve a quien llamo
	pop hl			;c055
	jp L_8978		;c056
L_C059:
	pop hl			;c059
	jp L_A0E8		;c05a
L_C05D:
	call llama_si_suena		;c05d
	ld a,00ch		;c060
	ld e,00ah		;c062
	call 00093h		;c064   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,006h		;c067
	ld e,010h		;c069
	call 00093h		;c06b   ; BIOS WRTPSG - Writes data to PSG-register
	ret			;c06e
L_C06F:
	call L_9B00		;c06f
	call L_97B8		;c072
	ret			;c075

; ----------------------------------------------------------------------
; DATOS variables_del_monitor: El area de trabajo del monitor de Loriciels: su
;   pila termina en 0xC0FF (0xC254 y 0xC94B hacen LD SP,0xC0FF), la copia de
;   los registros del programa detenido esta por 0xC144 y sus banderas en
;   0xC1B9-0xC1E3. Dentro quedan dos textos que el juego no usa: "Press any
;   key for retry" en 0xC085 y "MSXDOS  SYS" en 0xC0A0
;   0xc076..0xc24d  (471 bytes)
DATA_variables_del_monitor:
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,072h,06fh,072h,00dh,00ah,050h	; c076  ..........ror..P
	defb 072h,065h,073h,073h,020h,061h,06eh,079h,020h,06bh,065h,079h,020h,066h,06fh,072h	; c086  ress any key for
	defb 020h,072h,065h,074h,072h,079h,00dh,00ah,024h,000h,04dh,053h,058h,044h,04fh,053h	; c096   retry..$.MSXDOS
	defb 020h,020h,053h,059h,053h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c0a6    SYS...........
	defb 000h,000h,000h,000h,000h,000h,000h,05ch,00fh,0e0h,00eh,09dh,00dh,0e5h,05fh,0e5h	; c0b6  .......\......_.
	defb 05fh,0e5h,05fh,0b1h,05fh,0e5h,05fh,0e5h,05fh,0e5h,05fh,0b1h,05fh,05ch,00fh,09dh	; c0c6  _._._._._._._\..
	defb 00dh,001h,000h,03fh,001h,07fh,004h,0ech,0fbh,0e1h,0fbh,05eh,00dh,0e8h,00ch,000h	; c0d6  ...?.......^....
	defb 000h,000h,000h,010h,020h,0f3h,000h,001h,010h,0e0h,07fh,04ah,0c1h,0ceh,0c3h,02bh	; c0e6  .... ......J...+
	defb 001h,0adh,0d2h,02dh,0c6h,026h,0d2h,042h,0c6h,000h,0d0h,000h,000h,000h,000h,000h	; c0f6  ...-.&.B........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c106  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c116  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c126  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,047h,037h	; c136  ..............G7
	defb 046h,045h,030h,048h,00dh,020h,020h,04eh,054h,00dh,037h,048h,00dh,048h,02ch,045h	; c146  FE0H.  NT.7H.H,E
	defb 037h,048h,00dh,030h,00dh,030h,048h,00dh,04ch,020h,043h,04fh,04ch,04fh,052h,043h	; c156  7H.0.0H.L COLORC
	defb 04fh,04ch,04fh,052h,00dh,04fh,04ch,04fh,052h,020h,043h,04fh,04ch,04fh,052h,020h	; c166  OLOR.OLOR COLOR 
	defb 00dh,034h,02ch,037h,00dh,000h,000h,000h,000h,000h,0ffh,0ffh,0ffh,0ffh,000h,000h	; c176  .4,7............
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c186  ................
	defb 000h,000h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h	; c196  ................
	defb 0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h,0f3h,0c3h,0d7h	; c1a6  ................
	defb 0b1h,05fh,043h,000h,098h,002h,001h,001h,001h,000h,0aah,0e1h,013h,095h,000h,009h	; c1b6  ._C.............
	defb 000h,0b7h,01bh,0e7h,000h,000h,000h,000h,010h,040h,001h,000h,000h,000h,007h,015h	; c1c6  .........@......
	defb 0fbh,0c0h,0ffh,0ffh,04ah,0c1h,07fh,0f3h,000h,000h,000h,000h,000h,001h,044h,049h	; c1d6  ....J.........DI
	defb 020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,020h,0e0h,07fh	; c1e6                ..
	defb 0ach,0e1h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; c1f6  ................
	defb 000h,000h,000h,000h,000h,000h,008h,000h,031h,0ffh,0c0h,0fbh,0dbh,0a8h,032h,00dh	; c206  ........1.....2.
	defb 0c2h,0cdh,03ah,0d2h,0cdh,0b8h,0cdh,0cdh,00bh,0d2h,0f3h,03eh,0c3h,032h,0b1h,0ffh	; c216  ..:........>.2..
	defb 021h,0c9h,0d2h,022h,0b2h,0ffh,03eh,085h,032h,07fh,0f8h,03ch,032h,08fh,0f8h,03ch	; c226  !.."..>.2..<2..<
	defb 032h,09fh,0f8h,03ch,032h,0afh,0f8h,0afh,032h,080h,0f8h,032h,090h,0f8h,032h,0a0h	; c236  2..<2...2..2..2.
	defb 0f8h,032h,0b0h,0f8h,0cdh,0a9h,0c4h	; c246

; ======================================================================
; CODIGO 0xc24d..0xc748  (1275 bytes)
; ======================================================================


L_C24D:
	call 0d2dbh		;c24d
	xor a			;c250
monitor_prepara_la_pantalla:		; Limpia, escribe el titulo y se pone a pedir ordenes
	ld (0c1b9h),a		;c251   ; Bandera de estado a cero
	ld sp,0c0ffh		;c254   ; La pila del monitor
	ld a,002h		;c257
	ld (0c1d3h),a		;c259   ; Bandera de modo, 2
	ld hl,01500h		;c25c   ; Posicion de partida en la VRAM
	ld (0c1d4h),hl		;c25f
	ld hl,00348h		;c262   ; El numero de casillas que va a limpiar
	di			;c265   ; Sin interrupciones para escribir en el VDP
	call monitor_direccion_de_vram		;c266   ; Pone la direccion en el VDP
	ld b,078h		;c269   ; 0x78 = 120 casillas
	ld a,020h		;c26b   ; El espacio
monitor_borra_la_linea:		; Escribe 120 espacios seguidos por el puerto de datos del VDP
	out (098h),a		;c26d   ; Puerto de datos del VDP
	djnz monitor_borra_la_linea		;c26f   ; Ciento veinte veces
	ei			;c271   ; Y vuelven las interrupciones
	call L_C568		;c272
	ld a,03eh		;c275   ; El caracter de aviso
	call monitor_imprime_o_borra		;c277   ; Lo imprime
	call monitor_prepara_el_teclado		;c27a   ; Lee la linea que se teclee
	ld a,(0c1d3h)		;c27d
	res 1,a		;c280   ; Baja la bandera de eco
	ld (0c1d3h),a		;c282
	call L_C30A		;c285
	ld c,(hl)			;c288   ; El caracter tecleado
	res 5,c		;c289   ; RES 5 lo pasa a mayusculas
	inc hl			;c28b
	ex de,hl			;c28c
	ld hl,0d5c6h		;c28d   ; La tabla de ordenes... que en esta cinta esta a ceros
	ld b,00fh		;c290   ; Quince ordenes
monitor_busca_la_orden:		; Recorre las quince entradas de tres bytes de 0xD5C6
	ld a,(hl)			;c292   ; La clave de esta entrada
	cp c			;c293   ; Contra la inicial tecleada
	jr z,monitor_salta_al_manejador		;c294   ; Encontrada
	inc hl			;c296   ; Tres bytes por entrada
	inc hl			;c297
	inc hl			;c298
	djnz monitor_busca_la_orden		;c299   ; La siguiente
	ld hl,0d98dh		;c29b   ; Ninguna: "Commande illegale"
monitor_escribe_el_error:		; Saca el mensaje por la linea de aviso
	ld de,01700h		;c29e   ; La linea de aviso
	ld (0c1d4h),de		;c2a1
	xor a			;c2a5   ; Sin eco
	ld (0c1d3h),a		;c2a6
	call monitor_escribe_hasta_el_cero		;c2a9   ; Lo imprime
	call 0d260h		;c2ac
L_C2AF:
	ld a,002h		;c2af
	ld (0c1d3h),a		;c2b1
L_C2B4:
	call monitor_lee_una_tecla		;c2b4
	jr z,L_C2B4		;c2b7
	jr monitor_prepara_la_pantalla		;c2b9
monitor_salta_al_manejador:		; Lee el puntero de la entrada y salta
	inc hl			;c2bb   ; Los dos bytes de despues de la clave
	ld a,(hl)			;c2bc
	inc hl			;c2bd
	ld h,(hl)			;c2be
	ld l,a			;c2bf
	jp (hl)			;c2c0   ; Y salta. Con la tabla a ceros, esto no llega a pasar nunca
monitor_prepara_el_teclado:		; Deja HL en el tampon de la linea y C a cero
	ld hl,0c144h		;c2c1   ; El tampon de la linea
	ld b,03fh		;c2c4   ; 0x3F caracteres de sitio
	ld c,000h		;c2c6   ; Ninguno escrito todavia
	ld a,(0c1b9h)		;c2c8   ; La bandera de estado
	or a			;c2cb
	jr monitor_recoge_la_linea		;c2cc
L_C2CE:
	call monitor_lee_una_tecla		;c2ce
monitor_recoge_la_linea:		; Va guardando lo tecleado hasta el retorno de carro
	jr z,L_C2CE		;c2d1
	cp 00dh		;c2d3   ; Retorno de carro: linea terminada
	jr z,monitor_cierra_la_linea		;c2d5
	cp 008h		;c2d7   ; Borrado
	jr z,monitor_borra_un_caracter		;c2d9
	cp 01dh		;c2db   ; Otro borrado
	jr z,monitor_borra_un_caracter		;c2dd
	inc b			;c2df
	dec b			;c2e0   ; Si no cabe mas, no se guarda
	jr z,L_C2CE		;c2e1
	ld (hl),a			;c2e3   ; Guarda el caracter
	inc hl			;c2e4
	inc c			;c2e5
	dec b			;c2e6
	call monitor_imprime_o_borra		;c2e7   ; Y lo imprime
	jr L_C2CE		;c2ea
monitor_cierra_la_linea:		; Guarda el retorno de carro y deja el cursor listo
	ld (hl),a			;c2ec   ; El caracter en el tampon
	ld a,020h		;c2ed   ; Un espacio para borrar el cursor
	ld de,(0c1d4h)		;c2ef   ; La posicion de la ventana
	call monitor_escribe_en_la_ventana		;c2f3
	ld b,000h		;c2f6
	inc c			;c2f8
	ld hl,0c144h		;c2f9   ; Y devuelve el tampon de la linea
	ret			;c2fc
monitor_borra_un_caracter:		; Retrocede uno y lo borra de la pantalla
	inc c			;c2fd
	dec c			;c2fe   ; Si no hay nada escrito, nada que borrar
	jr z,L_C2CE		;c2ff
	dec hl			;c301   ; Una posicion atras
	dec c			;c302
	inc b			;c303
	ld a,(hl)			;c304   ; El caracter que habia
	call L_CAEF		;c305   ; Se borra
	jr L_C2CE		;c308
L_C30A:
	push hl			;c30a
	ld d,h			;c30b
	ld e,l			;c30c
monitor_copia_hasta_el_final:		; Copia la linea hasta el retorno de carro
	ld a,(hl)			;c30d   ; Un caracter
	ld (de),a			;c30e
	inc hl			;c30f
	cp 00dh		;c310   ; Retorno de carro: se acabo
	jr z,L_C31B		;c312
	cp 021h		;c314   ; Los de control no se copian
	jr c,monitor_copia_hasta_el_final		;c316
	inc de			;c318
	jr monitor_copia_hasta_el_final		;c319
L_C31B:
	pop hl			;c31b
	ret			;c31c
monitor_byte_en_hexadecimal_2:		; Los dos digitos de un byte
	push bc			;c31d
	ld b,a			;c31e   ; Se guarda el byte
	rrca			;c31f   ; Cuatro rotaciones: el digito de arriba
	rrca			;c320
	rrca			;c321
	rrca			;c322
	call L_C328		;c323   ; Lo escribe
	ld a,b			;c326   ; Y se recupera el byte
	pop bc			;c327
L_C328:
	and 00fh		;c328
	add a,030h		;c32a
	cp 03ah		;c32c
	jr c,L_C332		;c32e
	add a,007h		;c330
L_C332:
	call monitor_imprime_un_caracter		;c332
	ret			;c335
L_C336:
	ld a,h			;c336
	call monitor_byte_en_hexadecimal_2		;c337
	ld a,l			;c33a
	call monitor_byte_en_hexadecimal_2		;c33b
	ret			;c33e
L_C33F:
	cp 030h		;c33f
	ret c			;c341
	cp 03ah		;c342
	ccf			;c344
	ret			;c345
L_C346:
	push hl			;c346
	ld c,000h		;c347
monitor_cuenta_los_digitos:		; Avanza mientras haya digitos
	ld a,(hl)			;c349   ; El caracter
	cp 030h		;c34a   ; Por debajo del '0' ya no
	jr c,monitor_elige_la_base		;c34c
	inc hl			;c34e
	inc c			;c34f   ; Uno mas
	jr monitor_cuenta_los_digitos		;c350
monitor_elige_la_base:		; Segun la letra final, la base es 10, 16 u 8
	dec hl			;c352
	ld a,(hl)			;c353   ; El caracter
	inc hl			;c354
	ex (sp),hl			;c355
	ld de,00000h		;c356
	push de			;c359
	ld b,00ah		;c35a   ; Base diez por defecto
	cp 041h		;c35c   ; Por debajo de la 'A' es un digito
	jr c,L_C374		;c35e
	dec c			;c360
	cp 044h		;c361   ; 'D': decimal
	jr z,L_C374		;c363
	ld b,010h		;c365   ; Base dieciseis
	cp 048h		;c367   ; 'H': hexadecimal
	jr z,L_C374		;c369
	ld b,008h		;c36b   ; Base ocho
	cp 04fh		;c36d   ; 'O': octal
	jr z,L_C374		;c36f
L_C371:
	scf			;c371
	jr L_C398		;c372
L_C374:
	ld a,(hl)			;c374
	call L_C33F		;c375
	jr nc,monitor_acumula_el_digito		;c378
	sub 007h		;c37a
monitor_acumula_el_digito:		; Convierte y comprueba que cabe en la base
	sub 030h		;c37c   ; De ASCII a numero
	cp b			;c37e   ; Tiene que ser menor que la base
	jr nc,L_C371		;c37f
	ex (sp),hl			;c381   ; El acumulador
	push bc			;c382
	ld d,h			;c383
	ld e,l			;c384
	dec b			;c385   ; Una vuelta menos
monitor_multiplica_por_la_base:		; Suma B veces y anade el digito
	add hl,de			;c386   ; Suma la base
	jr c,monitor_desbordamiento		;c387   ; Desbordamiento
	djnz monitor_multiplica_por_la_base		;c389   ; B veces
	ld e,a			;c38b   ; El digito
	ld d,000h		;c38c
	add hl,de			;c38e
	jr c,monitor_desbordamiento		;c38f   ; Desbordamiento
	pop bc			;c391
	ex (sp),hl			;c392
	inc hl			;c393
	dec c			;c394
	jr nz,L_C374		;c395
	xor a			;c397
L_C398:
	pop de			;c398
	pop hl			;c399
	ret			;c39a
monitor_desbordamiento:		; Apunta el mensaje "Debordement" y devuelve 0xFFFF
	pop bc			;c39b
	pop hl			;c39c
	ld hl,0d9c9h		;c39d   ; El mensaje de desbordamiento
	ld (0c1deh),hl		;c3a0   ; Se apunta para que lo saque el que llamo
	ld de,0ffffh		;c3a3   ; Y el resultado invalido
	pop hl			;c3a6
	ret			;c3a7
monitor_lee_un_numero:		; Prepara el acumulador y mira si el numero lleva signo
	ld (0c1d6h),sp		;c3a8   ; Guarda la pila
	ld de,00000h		;c3ac   ; Acumulador a cero
	ld (0c1deh),de		;c3af
	push de			;c3b3
	push de			;c3b4
	ld de,0012bh		;c3b5   ; El signo, por defecto '+'
	ld a,(hl)			;c3b8
	cp 02bh		;c3b9   ; Un '+'
	jr z,L_C3C4		;c3bb
	cp 02dh		;c3bd   ; Un '-'
	jr nz,monitor_lee_el_termino		;c3bf
	ld de,0012dh		;c3c1   ; Y se apunta
L_C3C4:
	inc hl			;c3c4
monitor_lee_el_termino:		; Cuenta los digitos y convierte el numero
	push de			;c3c5
	call L_C346		;c3c6   ; Cuantos digitos hay
	jr c,monitor_expresion_mal		;c3c9   ; Ninguno
	call monitor_lee_el_operador		;c3cb   ; El valor
	jr c,$+53		;c3ce
	ld (0c1dah),hl		;c3d0   ; Se guarda
monitor_cierra_el_numero:		; Devuelve el numero si no habia signo ni digitos pendientes
	pop af			;c3d3
	push af			;c3d4
	or a			;c3d5   ; El signo
	jr nz,monitor_aplica_el_operador		;c3d6
	ld a,c			;c3d8
	or a			;c3d9   ; Los digitos
	jr nz,monitor_siguiente_termino		;c3da
	pop bc			;c3dc
	ld hl,(0c1dah)		;c3dd   ; El resultado
	ret			;c3e0
monitor_aplica_el_operador:		; Con el operador guardado, opera los dos terminos
	cp c			;c3e1   ; Contra la cuenta de digitos
	jr c,monitor_siguiente_termino		;c3e2
	pop hl			;c3e4   ; El operador
	ld a,l			;c3e5
	pop hl			;c3e6
	call L_C42D		;c3e7   ; Se aplica
	ex de,hl			;c3ea
	jr c,monitor_desbordamiento_2		;c3eb   ; Con acarreo, desbordamiento
	jr monitor_cierra_el_numero		;c3ed
monitor_siguiente_termino:		; Coge el operador siguiente y vuelve a leer
	ld hl,(0c1dah)		;c3ef   ; El acumulador
	push de			;c3f2
	ld d,c			;c3f3
	ld e,(hl)			;c3f4   ; El operador
	inc hl			;c3f5
	jr monitor_lee_el_termino		;c3f6
monitor_desbordamiento_2:		; El otro camino al mensaje "Debordement"
	ld hl,0d9c9h		;c3f8   ; El mensaje de desbordamiento
	ld (0c1deh),hl		;c3fb   ; Se apunta
	ld hl,(0d3dah)		;c3fe   ; Estos tres bytes y los dos NOP no llegan a ejecutarse con sentido
	ld hl,(01103h)		;c401
	nop			;c404   ; Dos NOP
	nop			;c405
monitor_expresion_mal:		; Repone la pila y apunta "Expression illegale"
	ld sp,(0c1d6h)		;c406   ; La pila del monitor
	push hl			;c40a
	ld hl,0d9b5h		;c40b   ; El mensaje
	ld a,(0c1dfh)		;c40e   ; Si ya habia otro error, se respeta
	or a			;c411
	jr nz,L_C417		;c412
	ld (0c1deh),hl		;c414
L_C417:
	pop hl			;c417
monitor_salta_hasta_el_separador:		; Avanza hasta el ';', el ')' o la coma
	ld a,(hl)			;c418   ; El caracter
	cp 021h		;c419   ; Por debajo del espacio, se acabo
	ret c			;c41b
	cp 03bh		;c41c   ; Punto y coma
	jr z,L_C42B		;c41e
	cp 029h		;c420   ; Parentesis
	jr z,L_C42B		;c422
	cp 02ch		;c424   ; Coma
	jr z,L_C42B		;c426
	inc hl			;c428   ; Sigue buscando
	jr monitor_salta_hasta_el_separador		;c429
L_C42B:
	scf			;c42b
	ret			;c42c
L_C42D:
	cp 02bh		;c42d
	jr nz,monitor_resta		;c42f
	add hl,de			;c431
	or a			;c432
	ret			;c433
monitor_resta:		; El operador '-'
	cp 02dh		;c434   ; Un '-'
	jr nz,monitor_multiplica		;c436
	or a			;c438
	sbc hl,de		;c439   ; Resta
	or a			;c43b
	ret			;c43c
monitor_multiplica:		; El operador '*', por sumas y desplazamientos
	cp 02ah		;c43d   ; Un '*'
	jr nz,L_C462		;c43f
	ld a,h			;c441   ; Si el primero cabe en un byte...
	or a			;c442
	jr z,L_C44A		;c443
	ld a,d			;c445   ; ...y el segundo tambien
	or a			;c446
	jr nz,L_C45D		;c447
	ex de,hl			;c449   ; Se ponen en el orden que conviene
L_C44A:
	ld a,l			;c44a
	ld hl,00000h		;c44b
	ld b,008h		;c44e
monitor_bucle_de_multiplicar:		; Desplaza y suma
	add hl,hl			;c450   ; Por dos
	jr c,L_C45D		;c451   ; Desbordamiento
	sla a		;c453   ; El bit siguiente
	jr nc,L_C45A		;c455
	add hl,de			;c457   ; Si esta puesto, suma
	jr c,L_C45D		;c458
L_C45A:
	djnz monitor_bucle_de_multiplicar		;c45a
	ret			;c45c
L_C45D:
	scf			;c45d
	ld de,0ffffh		;c45e
	ret			;c461
L_C462:
	cp 02fh		;c462
	jr nz,L_C45D		;c464
	push de			;c466
	ld de,00000h		;c467
	ld b,010h		;c46a
monitor_divide:		; Desplaza el dividendo y resta si cabe
	add hl,hl			;c46c   ; Por dos
	ex de,hl			;c46d
	adc hl,hl		;c46e   ; Con el acarreo de arriba
	ex de,hl			;c470
	ex (sp),hl			;c471
	jr c,monitor_resta_el_divisor		;c472
	call monitor_compara_hl_y_de		;c474   ; Compara con el divisor
	jr z,monitor_resta_el_divisor		;c477
	jr nc,L_C483		;c479   ; No cabe
monitor_resta_el_divisor:		; Cabe: resta y sube el cociente
	ex de,hl			;c47b
	or a			;c47c
	sbc hl,de		;c47d   ; Resta
	ex de,hl			;c47f
	ex (sp),hl			;c480
	inc l			;c481   ; Un bit mas de cociente
	ex (sp),hl			;c482
L_C483:
	ex (sp),hl			;c483
	djnz monitor_divide		;c484
	pop de			;c486
	or a			;c487
	ret			;c488
monitor_lee_el_operador:		; Busca el caracter en la tabla de cinco operadores
	ld a,(hl)			;c489   ; El caracter
	cp 021h		;c48a   ; Por debajo del espacio no hay operador
	jr c,L_C4A5		;c48c
	push hl			;c48e
	ld hl,0d8fbh		;c48f   ; La tabla de operadores
	ld b,005h		;c492   ; Cinco
monitor_compara_el_operador:		; Si coincide, devuelve su codigo
	cp (hl)			;c494   ; Contra la tabla
	jr nz,monitor_siguiente_operador		;c495
	inc hl			;c497
	ld c,(hl)			;c498   ; Su codigo
	pop hl			;c499
	ret			;c49a
monitor_siguiente_operador:		; Dos bytes por entrada
	inc hl			;c49b   ; Dos bytes por entrada
	inc hl			;c49c
	djnz monitor_compara_el_operador		;c49d   ; El siguiente
	pop hl			;c49f
	ld de,00000h		;c4a0   ; Ninguno vale
	scf			;c4a3   ; Y se avisa con el acarreo
	ret			;c4a4
L_C4A5:
	ld c,000h		;c4a5
	or a			;c4a7
	ret			;c4a8
monitor_arranca:		; Pone a cero sus banderas y su area de trabajo
	ld hl,00000h		;c4a9
	ld (0c1d4h),hl		;c4ac   ; Posicion de la ventana
	ld (0c1d1h),hl		;c4af
	xor a			;c4b2   ; Banderas a cero
	ld (0c1d3h),a		;c4b3
	ld (0c1c6h),a		;c4b6
	inc a			;c4b9
	ld (0c1d0h),a		;c4ba   ; Y la de eco a uno
	ld hl,0c184h		;c4bd   ; El area de registros
	ld b,014h		;c4c0   ; Veinte bytes
monitor_escribe_la_cabecera:		; Borra el area y escribe "MONITEUR MSX" y los creditos
	ld (hl),000h		;c4c2   ; Un byte a cero
	inc hl			;c4c4
	djnz monitor_escribe_la_cabecera		;c4c5   ; Los veinte
	ld hl,0d95fh		;c4c7   ; "MONITEUR MSX"
	call monitor_escribe_hasta_el_cero		;c4ca
	ld a,020h		;c4cd   ; Un espacio
	call monitor_imprime_un_caracter		;c4cf
	ld hl,0c000h		;c4d2   ; La direccion de su propio principio, en hexadecimal
	call L_C336		;c4d5
	ld hl,0d989h		;c4d8   ; El siguiente texto
	call monitor_escribe_hasta_el_cero		;c4db
	ld hl,0dab3h		;c4de
	call L_C336		;c4e1
	ld a,00dh		;c4e4   ; Retorno de carro
	call monitor_imprime_un_caracter		;c4e6
	ld hl,0d948h		;c4e9   ; "Auteur:Claude SABLATOU"
	call monitor_escribe_hasta_el_retorno		;c4ec
	ld hl,0d96ch		;c4ef   ; "Copyright (C) 1984 LORICIELS"
	call monitor_escribe_hasta_el_retorno		;c4f2
	ld a,020h		;c4f5
	call monitor_imprime_un_caracter		;c4f7
	ld hl,0f37fh		;c4fa   ; El limite de memoria
	ld (0c1dch),hl		;c4fd
	ld b,018h		;c500   ; Veinticuatro registros
	ld hl,0c1f4h		;c502
monitor_limpia_y_arranca:		; Pone a cero el area y deja la pila en 0xE1AC
	ld (hl),000h		;c505   ; Un byte a cero
	inc hl			;c507
	djnz monitor_limpia_y_arranca		;c508   ; Todos
	ld hl,0e1ach		;c50a   ; La pila del programa
	ld (0c1f6h),hl		;c50d
	ld a,(0c20dh)		;c510   ; Y un byte que se copia sobre otro
	ld (0c20ch),a		;c513
	ret			;c516
monitor_lee_dos_parametros:		; Lee un parametro y, si hay coma, el segundo
	call L_CAB0		;c517   ; El sufijo del primero
	call monitor_lee_o_falla		;c51a   ; Su valor
	push hl			;c51d
	ld hl,0ffffh		;c51e   ; Por defecto, 0xFFFF
	ld a,(de)			;c521
	cp 00dh		;c522   ; Retorno de carro: solo habia uno
	jr z,L_C52F		;c524
	cp 02ch		;c526   ; Y si no hay coma, la orden esta mal
	jp nz,L_C661		;c528
	inc de			;c52b
	call monitor_lee_o_falla		;c52c   ; El segundo valor
L_C52F:
	ld (0c1d8h),hl		;c52f
	pop ix		;c532
	ret			;c534
L_C535:
	call monitor_lee_dos_parametros		;c535
L_C538:
	call monitor_limpia_la_pantalla		;c538
	ld b,011h		;c53b
monitor_desensambla_una_linea:		; Desensambla y comprueba si ha llegado al limite
	push bc			;c53d
	call monitor_escribe_la_direccion		;c53e   ; Una linea
	call L_CB10		;c541   ; Mira si se ha pulsado algo
	ld de,(0c1d8h)		;c544   ; El limite
	call monitor_compara_hl_y_de		;c548   ; Se compara
	jr z,monitor_avanza_por_la_lista		;c54b
	jp nc,L_C24D		;c54d
monitor_avanza_por_la_lista:		; Suma el tamano leido a IX y sigue con el siguiente
	ld a,(0c1e3h)		;c550   ; El tamano de lo ultimo leido
	ld c,a			;c553
	ld b,000h		;c554
	add ix,bc		;c556   ; Avanza IX
	jp c,L_C24D		;c558   ; Al desbordar, se vuelve al aviso
	pop bc			;c55b
	djnz monitor_desensambla_una_linea		;c55c   ; Los que queden
	ld a,(0c1d3h)		;c55e   ; La bandera de eco
	bit 3,a		;c561   ; El bit 3 decide si se hace una pausa
	call z,L_CAF5		;c563
	jr L_C538		;c566
L_C568:
	ld ix,(0c1f4h)		;c568
	ld hl,01400h		;c56c
	ld (0c1d4h),hl		;c56f
monitor_escribe_la_direccion:		; Pinta la direccion y prepara los bytes
	call 0d2d2h		;c572   ; Prepara la pantalla
	call L_CE27		;c575   ; Desensambla la instruccion
	push ix		;c578   ; La direccion
	pop hl			;c57a
	call L_C336		;c57b   ; En hexadecimal
	ld a,(0c1e3h)		;c57e   ; Cuantos bytes ocupa
	ld b,a			;c581
monitor_escribe_los_bytes:		; Escribe B bytes en hexadecimal separados por espacios
	ld a,020h		;c582   ; Un espacio
	call monitor_imprime_un_caracter		;c584
	ld a,(hl)			;c587   ; El byte
	call monitor_byte_en_hexadecimal_2		;c588   ; En hexadecimal
	inc hl			;c58b
	djnz monitor_escribe_los_bytes		;c58c   ; Los que queden
	ld a,(0c1e3h)		;c58e   ; El tamano
	sub 004h		;c591   ; Cuatro menos, cambiado de signo
	neg		;c593
	ld b,a			;c595
	add a,a			;c596   ; Por tres: tres columnas por byte
	add a,b			;c597
	inc a			;c598
	ld b,a			;c599
L_C59A:
	ld a,020h		;c59a
	call monitor_imprime_un_caracter		;c59c
	djnz L_C59A		;c59f
	ld b,010h		;c5a1
	ld de,0c1e4h		;c5a3
monitor_escribe_la_cadena:		; Saca B caracteres y un retorno de carro
	ld a,(de)			;c5a6   ; Un caracter
	call monitor_imprime_un_caracter		;c5a7
	inc de			;c5aa
	djnz monitor_escribe_la_cadena		;c5ab   ; Los que queden
	ld a,00dh		;c5ad   ; Retorno de carro
	call monitor_imprime_un_caracter		;c5af
	call 0d2dbh		;c5b2
	ret			;c5b5
monitor_imprime_el_resultado:		; Escribe "Resultat= " y el valor calculado
	call monitor_lee_o_falla		;c5b6   ; El valor tecleado
	ld a,(de)			;c5b9
	cp 00dh		;c5ba   ; Detras tiene que ir un retorno de carro
	jp nz,L_C661		;c5bc   ; Si no, la orden esta mal
	push hl			;c5bf
	ld hl,01700h		;c5c0   ; La ventana de resultados
	ld (0c1d4h),hl		;c5c3
	ld hl,0da39h		;c5c6   ; El texto "Resultat= "
	call monitor_escribe_hasta_el_cero		;c5c9
	pop hl			;c5cc
	call L_C336		;c5cd   ; Y el valor, en hexadecimal
	jp L_C2AF		;c5d0
L_C5D3:
	ld a,(de)			;c5d3
	cp 00dh		;c5d4
	jr z,monitor_prueba_varias_direcciones		;c5d6
	call monitor_lee_o_falla		;c5d8
	ld (0c1f4h),hl		;c5db
monitor_prueba_varias_direcciones:		; Cuatro comprobaciones seguidas sobre la pila guardada
	ld hl,(0c1f6h)		;c5de   ; La pila del programa detenido
	ld de,00000h		;c5e1
	call monitor_compara_hl_y_de		;c5e4   ; La primera
	jr z,L_C60C		;c5e7
	call 0d296h		;c5e9
	inc de			;c5ec
	inc de			;c5ed
	inc de			;c5ee
	call monitor_compara_hl_y_de		;c5ef   ; La segunda
	jr c,L_C606		;c5f2
	ld de,0c001h		;c5f4   ; La tercera
	call monitor_compara_hl_y_de		;c5f7
	jr c,L_C60C		;c5fa
	ld de,0dab4h		;c5fc
	inc de			;c5ff
	inc de			;c600
	call monitor_compara_hl_y_de		;c601   ; Y la cuarta
	jr nc,L_C60C		;c604
L_C606:
	ld hl,0da00h		;c606
	jp monitor_escribe_el_error		;c609
L_C60C:
	ld b,00ah		;c60c
	call 0d2d2h		;c60e
	ld hl,0c184h		;c611
	ld de,0c198h		;c614
monitor_pone_un_punto_de_parada:		; Guarda los tres bytes originales y escribe encima un CALL 0xC924
	ld a,(hl)			;c617   ; La direccion del punto de parada
	inc hl			;c618
	push hl			;c619
	ld h,(hl)			;c61a
	ld l,a			;c61b
	push hl			;c61c
	push bc			;c61d
	ld bc,00003h		;c61e   ; Tres bytes: los que ocupa un CALL
	ldir		;c621   ; Se guardan para poder deshacerlo
	pop bc			;c623
	pop hl			;c624
	push de			;c625
	ld de,(0c1f4h)		;c626   ; La direccion en curso
	call monitor_compara_hl_y_de		;c62a
	pop de			;c62d
	jr z,L_C63B		;c62e
	push de			;c630
	ld de,0c924h		;c631   ; La entrada del monitor
	ld (hl),0cdh		;c634   ; El opcode de CALL
	inc hl			;c636
	ld (hl),e			;c637   ; Y su direccion, byte a byte
	inc hl			;c638
	ld (hl),d			;c639
	pop de			;c63a
L_C63B:
	pop hl			;c63b
	inc hl			;c63c
	djnz monitor_pone_un_punto_de_parada		;c63d
monitor_devuelve_el_mando:		; Repone los diez registros del programa detenido y se va
	call 0d21fh		;c63f
	ld hl,(0c1f4h)		;c642   ; La direccion de vuelta
	ld (0c65fh),hl		;c645   ; Se escribe ENCIMA del operando del JP de 0xC65E: codigo que se modifica solo
	ld sp,0c1f8h		;c648   ; La pila donde estan los registros guardados
	pop iy		;c64b   ; Los diez, en orden inverso al que los metio 0xC924
	pop ix		;c64d
	pop hl			;c64f
	pop de			;c650
	pop bc			;c651
	pop af			;c652
	exx			;c653
	ex af,af'			;c654
	pop hl			;c655
	pop de			;c656
	pop bc			;c657
	pop af			;c658
	ld sp,(0c1f6h)		;c659   ; Y la pila del programa
	nop			;c65d
	jp 07fe0h		;c65e   ; Salta a donde se quedo. El operando lo acaba de escribir 0xC645
L_C661:
	ld hl,0d99fh		;c661
	jp monitor_escribe_el_error		;c664
L_C667:
	ld b,00ch		;c667
	ld hl,0d905h		;c669
monitor_compara_el_nombre:		; Compara el nombre tecleado con la entrada de la tabla
	push hl			;c66c
	push de			;c66d
	ld a,(hl)			;c66e   ; El primer caracter de la tabla
	cp 020h		;c66f   ; Un espacio quiere decir "nombre de una letra"
	jr z,monitor_compara_dos_mas		;c671
	ld a,(de)			;c673   ; El tecleado
	cp (hl)			;c674
	jr nz,monitor_siguiente_nombre		;c675   ; No coincide
	inc de			;c677
monitor_compara_dos_mas:		; Los dos caracteres siguientes
	inc hl			;c678
	ld a,(de)			;c679   ; El segundo
	cp (hl)			;c67a
	jr nz,monitor_siguiente_nombre		;c67b   ; No coincide
	inc de			;c67d
	inc hl			;c67e
	ld a,(de)			;c67f   ; El tercero
	cp (hl)			;c680
	jr z,monitor_busca_el_igual		;c681   ; Coinciden los tres
monitor_siguiente_nombre:		; Cuatro bytes por entrada
	pop de			;c683
	pop hl			;c684
	inc hl			;c685   ; Cuatro bytes por entrada
	inc hl			;c686
	inc hl			;c687
	inc hl			;c688
	djnz monitor_compara_el_nombre		;c689   ; La siguiente
L_C68B:
	call monitor_volcado_de_registros		;c68b
	jp L_C24D		;c68e
monitor_busca_el_igual:		; Avanza hasta el '=', contando de cuatro en cuatro
	inc de			;c691
	ld a,(de)			;c692   ; El caracter
	cp 03dh		;c693   ; Un '='
	jr z,monitor_apunta_al_registro		;c695
	inc de			;c697
	ld a,b			;c698
	add a,004h		;c699   ; Cuatro por nombre de registro
	ld b,a			;c69b
	ld a,(de)			;c69c
	cp 03dh		;c69d   ; Si aqui tampoco hay '=', la orden esta mal
	jp nz,L_C661		;c69f
monitor_apunta_al_registro:		; Calcula donde vive el registro y le escribe el valor
	inc de			;c6a2
	ld a,00ch		;c6a3   ; Doce registros
	sub b			;c6a5
	add a,a			;c6a6   ; Por dos: son palabras
	ld b,000h		;c6a7
	ld c,a			;c6a9
	ld ix,0c1f4h		;c6aa   ; El area de registros guardados
	add ix,bc		;c6ae   ; Y el que toca
	call monitor_lee_o_falla		;c6b0   ; El valor tecleado
	ld (ix+000h),l		;c6b3   ; Se escribe, byte bajo...
	inc ix		;c6b6
	ld (ix+000h),h		;c6b8   ; ...y byte alto
	jr L_C68B		;c6bb
L_C6BD:
	ld a,(de)			;c6bd
	cp 00dh		;c6be
	jr nz,monitor_lee_hasta_diez		;c6c0
	ld de,(0c1d1h)		;c6c2
	jr monitor_cambia_de_signo		;c6c6
monitor_lee_hasta_diez:		; Lee hasta diez valores separados por comas
	call monitor_lee_o_falla		;c6c8   ; El primero
	push hl			;c6cb
	ld ix,0c1c6h		;c6cc   ; El area donde se guardan
	ld b,00ah		;c6d0   ; Diez como mucho
	ld a,(de)			;c6d2
	cp 00dh		;c6d3   ; Retorno de carro: solo habia uno
	jr z,L_C702		;c6d5
monitor_lee_una_lista:		; Lee valores separados por comas y los va escribiendo
	ld a,(de)			;c6d7
	cp 00dh		;c6d8   ; Retorno de carro: se acabo la lista
	jr z,L_C6F9		;c6da
	push bc			;c6dc
	cp 02ch		;c6dd   ; Coma
	jp nz,L_C661		;c6df   ; Sin coma, la orden esta mal
	inc de			;c6e2
	call monitor_lee_o_falla		;c6e3   ; El valor
	ld a,h			;c6e6
	or a			;c6e7   ; Tiene que caber en un byte
	jp nz,L_C661		;c6e8
	ld (ix+000h),l		;c6eb   ; Se escribe
	inc ix		;c6ee
	pop bc			;c6f0
	djnz monitor_lee_una_lista		;c6f1   ; El siguiente
	ld a,(de)			;c6f3
	cp 00dh		;c6f4   ; Y al final, retorno de carro
	jp nz,L_C661		;c6f6
L_C6F9:
	ld a,00ah		;c6f9
	sub b			;c6fb
	jp z,L_C661		;c6fc
	ld (0c1d0h),a		;c6ff
L_C702:
	pop de			;c702
	call 0d2d2h		;c703
monitor_cambia_de_signo:		; BC = -DE, para recorrer hacia atras
	push de			;c706
	ld hl,00000h		;c707   ; Cero
	or a			;c70a
	sbc hl,de		;c70b   ; Menos DE
	ld b,h			;c70d   ; En BC
	ld c,l			;c70e
	pop hl			;c70f
monitor_busca_el_byte:		; Recorre la memoria con CPIR buscando el patron
	ld a,(0c1c6h)		;c710   ; El byte que se busca
	cpir		;c713   ; CPIR: busca hasta encontrarlo o agotar BC
	jr nz,L_C742		;c715   ; No esta
	ld a,(0c1d0h)		;c717   ; Cuantos bytes tiene el patron
	dec a			;c71a
	jr z,monitor_apunta_lo_encontrado		;c71b   ; Uno solo: ya esta
	push bc			;c71d
	ld b,a			;c71e
	push hl			;c71f
	ld de,0c1c7h		;c720   ; El resto del patron
monitor_compara_el_patron:		; Compara byte a byte lo que queda del patron
	ld a,(de)			;c723   ; Un byte del patron
	cp (hl)			;c724
	jr nz,L_C73C		;c725   ; No coincide
	inc de			;c727
	inc hl			;c728
	djnz monitor_compara_el_patron		;c729   ; Los que queden
	pop hl			;c72b
	pop bc			;c72c
monitor_apunta_lo_encontrado:		; Guarda la direccion y enciende el bit 2
	ld (0c1d1h),hl		;c72d   ; La direccion
	dec hl			;c730
	ld a,(0c1d3h)		;c731   ; La bandera de estado
	set 2,a		;c734   ; Bit 2: encontrado
	ld (0c1d3h),a		;c736
	jp L_C897		;c739
L_C73C:
	pop hl			;c73c
	pop bc			;c73d
	ld a,b			;c73e
	or c			;c73f
	jr nz,monitor_busca_el_byte		;c740
L_C742:
	ld hl,0d9d5h		;c742
	jp monitor_escribe_el_error		;c745

; ----------------------------------------------------------------------
; DATOS datos_C748: Catorce bytes dentro del monitor. Ninguna instruccion los
;   apunta
;   0xc748..0xc756  (14 bytes)
DATA_datos_C748:
	defb 0cdh,017h,0c5h,03ah,0d3h,0c1h,0cbh,0d7h,032h,0d3h,0c1h,0ddh,0e5h,0e1h	; c748  ...:....2.....

; ======================================================================
; CODIGO 0xc756..0xcb7d  (1063 bytes)
; ======================================================================


L_C756:
	ld a,l			;c756
	and 080h		;c757
	ld l,a			;c759
monitor_recorre_paginas:		; Avanza de 128 en 128 hasta el limite
	call monitor_cabecera_del_volcado		;c75a
	ld a,(0c1d3h)		;c75d   ; La bandera de eco
	bit 3,a		;c760   ; El bit 3 dice si se sigue
	jr z,L_C779		;c762
	ld de,00080h		;c764   ; 0x80 = 128 bytes
	add hl,de			;c767
	jp c,L_C24D		;c768   ; Al desbordar, se vuelve al aviso
	ld de,(0c1d8h)		;c76b   ; El limite
	call monitor_compara_hl_y_de		;c76f   ; Se compara
	jr z,monitor_recorre_paginas		;c772
	jp nc,L_C24D		;c774
	jr monitor_recorre_paginas		;c777
L_C779:
	ld a,001h		;c779
	ld (0c1bfh),a		;c77b
L_C77E:
	call L_C8AA		;c77e
monitor_coloca_el_cursor:		; De la direccion en IX saca fila y columna de la pantalla
	push ix		;c781
	pop de			;c783
	ld a,e			;c784   ; Los bits 3 a 6 dan la fila
	and 078h		;c785
	rrca			;c787   ; Divididos por ocho
	rrca			;c788
	rrca			;c789
	inc a			;c78a
	ld h,a			;c78b
	ld a,e			;c78c
	and 007h		;c78d   ; Los tres de abajo, la columna
	ld b,a			;c78f
	add a,a			;c790   ; Por tres: tres columnas por byte
	add a,b			;c791
	add a,006h		;c792   ; Y seis de margen
	ld l,a			;c794
	ld a,(0c1bfh)		;c795   ; El desplazamiento de la ventana
	add a,l			;c798
	ld l,a			;c799
monitor_pinta_el_cursor:		; Si la casilla vale 0xC8, escribe el caracter guardado
	push hl			;c79a
	ex de,hl			;c79b
	call L_CE0B		;c79c   ; Lee la casilla
	cp 0c8h		;c79f   ; El codigo del cursor
	jr nz,L_C7AB		;c7a1
	ld a,(0c1b8h)		;c7a3   ; El caracter que habia debajo
	call monitor_escribe_en_la_ventana		;c7a6
	jr L_C7B3		;c7a9
L_C7AB:
	ld (0c1b8h),a		;c7ab
	ld a,0c8h		;c7ae
	call monitor_escribe_en_la_ventana		;c7b0
L_C7B3:
	pop hl			;c7b3
	ld bc,00400h		;c7b4
monitor_espera_con_parpadeo:		; Cuenta mientras espera una tecla
	call monitor_lee_una_tecla		;c7b7   ; Mira el teclado
	jr nz,monitor_mueve_el_cursor_a_la_izquierda		;c7ba   ; Hay tecla
	dec bc			;c7bc   ; Uno menos
	ld a,b			;c7bd
	or c			;c7be
	jr nz,monitor_espera_con_parpadeo		;c7bf   ; Sigue esperando
	jr monitor_pinta_el_cursor		;c7c1
monitor_mueve_el_cursor_a_la_izquierda:		; Con la tecla 0x1D, retrocede una posicion
	push hl			;c7c3
	ex de,hl			;c7c4
	push af			;c7c5
	ld a,(0c1b8h)		;c7c6   ; El caracter que habia debajo
	call monitor_escribe_en_la_ventana		;c7c9
	pop af			;c7cc
	pop hl			;c7cd
	push ix		;c7ce
	pop de			;c7d0
	res 7,e		;c7d1   ; Quita el bit alto de la direccion
	cp 01dh		;c7d3   ; 0x1D es la flecha a la izquierda
	jr nz,L_C7E4		;c7d5
	call L_C8AA		;c7d7   ; Mira si se puede
	jr z,monitor_coloca_el_cursor		;c7da
	ld a,e			;c7dc   ; Ya esta en el principio
	or a			;c7dd
	jr z,L_C77E		;c7de
	dec ix		;c7e0   ; Una posicion atras
	jr monitor_coloca_el_cursor		;c7e2
L_C7E4:
	cp 01ch		;c7e4
	jr nz,monitor_sube_una_linea		;c7e6
monitor_mueve_el_cursor_a_la_derecha:		; Y con la otra flecha, avanza
	call L_C8AA		;c7e8   ; Mira si se puede
	jr nz,monitor_coloca_el_cursor		;c7eb
	push ix		;c7ed
	pop de			;c7ef
	res 7,e		;c7f0   ; Quita el bit alto
	ld a,e			;c7f2
	cp 07fh		;c7f3   ; El final de la linea
	jr z,L_C77E		;c7f5
	inc ix		;c7f7   ; Una posicion adelante
	jr monitor_coloca_el_cursor		;c7f9
monitor_sube_una_linea:		; Con la flecha arriba, ocho bytes atras
	cp 01eh		;c7fb   ; 0x1E es la flecha arriba
	jr nz,monitor_baja_una_linea		;c7fd
	ld a,e			;c7ff
	cp 008h		;c800   ; Si ya esta arriba, nada
	jp c,monitor_coloca_el_cursor		;c802
	ld b,008h		;c805   ; Ocho bytes
L_C807:
	dec ix		;c807
	djnz L_C807		;c809
	jp monitor_coloca_el_cursor		;c80b
monitor_baja_una_linea:		; Con la flecha abajo, ocho bytes adelante
	cp 01fh		;c80e   ; 0x1F es la flecha abajo
	jr nz,monitor_es_un_digito_hex		;c810
	ld a,e			;c812
	cp 078h		;c813   ; Si ya esta abajo, nada
	jp nc,monitor_coloca_el_cursor		;c815
	ld de,00008h		;c818   ; Ocho bytes
	add ix,de		;c81b   ; Avanza
	jp monitor_coloca_el_cursor		;c81d
monitor_es_un_digito_hex:		; Solo pasan los digitos y las letras de la A a la F
	cp 030h		;c820   ; Por debajo del '0' no
	jp c,monitor_teclas_de_pagina		;c822
	cp 03ah		;c825   ; Hasta el '9'
	jr c,L_C833		;c827
	cp 041h		;c829   ; Por debajo de la 'A' tampoco
	jp c,monitor_coloca_el_cursor		;c82b
	cp 047h		;c82e   ; Y de la 'G' para arriba, no
	jp nc,monitor_coloca_el_cursor		;c830
L_C833:
	ex de,hl			;c833
	sub 030h		;c834
	cp 00ah		;c836
	jr c,monitor_mezcla_el_nibble		;c838
	sub 007h		;c83a
monitor_mezcla_el_nibble:		; Segun la mitad que se este editando, combina el digito con el byte
	call 0d2d2h		;c83c
	ld b,(ix+000h)		;c83f   ; El byte que hay
	ld c,a			;c842
	ld a,(0c1bfh)		;c843   ; Que mitad se edita
	or a			;c846
	ld a,c			;c847
	jr nz,L_C854		;c848
	add a,a			;c84a   ; Por dieciseis: el digito va arriba
	add a,a			;c84b
	add a,a			;c84c
	add a,a			;c84d
	ld c,a			;c84e
	ld a,b			;c84f
	and 00fh		;c850   ; Y se conserva la mitad baja
	jr monitor_guarda_el_byte		;c852
L_C854:
	ld a,b			;c854
	and 0f0h		;c855
monitor_guarda_el_byte:		; Escribe el byte y pasa a la otra mitad
	or c			;c857
	ld (ix+000h),a		;c858   ; El byte editado
	ld a,(0c1bfh)		;c85b   ; Que mitad se editaba
	or a			;c85e
	jr z,monitor_escribe_el_byte_y_su_ascii		;c85f
	dec e			;c861   ; Una columna atras
monitor_escribe_el_byte_y_su_ascii:		; Imprime el byte y, al lado, su caracter
	ld (0c1d4h),de		;c862   ; Donde escribir
	ld a,(ix+000h)		;c866   ; El byte
	call monitor_byte_en_hexadecimal_2		;c869   ; En hexadecimal
	push ix		;c86c
	pop hl			;c86e
	ld a,l			;c86f
	and 007h		;c870   ; Los tres bits de abajo, la columna
	add a,01eh		;c872   ; Mas 0x1E: la columna del ASCII
	ld e,a			;c874
	ld a,(ix+000h)		;c875
	cp 020h		;c878   ; Por debajo del espacio no es imprimible
	jr nc,L_C87E		;c87a
	ld a,02eh		;c87c   ; Se pone un punto
L_C87E:
	call monitor_escribe_en_la_ventana		;c87e
	call 0d2dbh		;c881
	jp monitor_mueve_el_cursor_a_la_derecha		;c884
monitor_teclas_de_pagina:		; El retorno sale, y el '+' y el '-' cambian de pagina
	cp 00dh		;c887   ; Retorno de carro: se acabo
	jp z,L_C24D		;c889
	cp 02bh		;c88c   ; Un '+'
	jr nz,monitor_pagina_atras		;c88e
	push ix		;c890
	pop hl			;c892
	ld de,00080h		;c893   ; 0x80 = 128 bytes adelante
L_C896:
	add hl,de			;c896
L_C897:
	push hl			;c897
	pop ix		;c898
	jp L_C756		;c89a
monitor_pagina_atras:		; Y el '-' retrocede 128
	cp 02dh		;c89d   ; Un '-'
	jp nz,monitor_coloca_el_cursor		;c89f   ; Otra tecla: no hace nada
	push ix		;c8a2
	pop hl			;c8a4
	ld de,0ff80h		;c8a5   ; 0xFF80 = -128
	jr L_C896		;c8a8
L_C8AA:
	ld a,(0c1bfh)		;c8aa
	xor 001h		;c8ad
	ld (0c1bfh),a		;c8af
	ret			;c8b2
L_C8B3:
	ld hl,01101h		;c8b3
	ld (0c1d4h),hl		;c8b6
	ld b,00ah		;c8b9
	ld de,0c184h		;c8bb
monitor_escribe_un_registro:		; Pinta el nombre, los dos puntos y el valor
	ld a,03ah		;c8be   ; El caracter del nombre
	sub b			;c8c0
	call monitor_imprime_un_caracter		;c8c1
	ld a,03ah		;c8c4   ; Los dos puntos
	call monitor_imprime_un_caracter		;c8c6
	ld a,(de)			;c8c9   ; El valor, byte bajo...
	ld l,a			;c8ca
	inc de			;c8cb
	ld a,(de)			;c8cc   ; ...y byte alto
	ld h,a			;c8cd
	inc de			;c8ce
	call L_C336		;c8cf   ; En hexadecimal
	ld c,004h		;c8d2   ; Cuatro digitos
monitor_rellena_con_espacios:		; Escribe espacios hasta el final de la fila
	ld a,020h		;c8d4   ; Un espacio
	call monitor_imprime_un_caracter		;c8d6
	ld a,(0c1d4h)		;c8d9   ; La posicion de la ventana
	cp 001h		;c8dc   ; Al llegar a la primera columna, se acabo
	jr z,L_C8E3		;c8de
	dec c			;c8e0   ; Uno menos
	jr nz,monitor_rellena_con_espacios		;c8e1
L_C8E3:
	djnz monitor_escribe_un_registro		;c8e3
	ld b,011h		;c8e5
L_C8E7:
	ld a,020h		;c8e7
	call monitor_imprime_un_caracter		;c8e9
	djnz L_C8E7		;c8ec
	jp L_C24D		;c8ee
monitor_lee_registro_igual_valor:		; Lee "N=valor" y lo escribe en el registro N
	ld a,(de)			;c8f1   ; El caracter
	cp 00dh		;c8f2   ; Retorno de carro: se acabo
	jr z,L_C8B3		;c8f4
	sub 030h		;c8f6   ; De ASCII a numero
	jp c,L_C661		;c8f8   ; No es un digito
	cp 00ah		;c8fb   ; Y tiene que ser menor que diez
	jp nc,L_C661		;c8fd
	add a,a			;c900   ; Por dos: son palabras
	ld c,a			;c901
	inc de			;c902
	ld a,(de)			;c903
	cp 03dh		;c904   ; Detras tiene que ir un '='
	jp nz,L_C661		;c906
	inc de			;c909
	ld b,000h		;c90a
	ld hl,0c184h		;c90c   ; El area de registros
	add hl,bc			;c90f   ; El que toca
	ld a,(de)			;c910
	ld bc,00000h		;c911
	cp 00dh		;c914   ; Sin valor detras, se pone cero
	jr z,L_C91F		;c916
	push hl			;c918
	call monitor_lee_o_falla		;c919   ; El valor tecleado
	ld b,h			;c91c
	ld c,l			;c91d
	pop hl			;c91e
L_C91F:
	ld (hl),c			;c91f
	inc hl			;c920
	ld (hl),b			;c921
	jr L_C8B3		;c922
entra_el_monitor:		; Punto de entrada del monitor de Loriciels. Guarda los diez registros del programa detenido y le pasa el mando al interprete de ordenes
	ld (0c1f6h),sp		;c924   ; La pila del programa detenido
	im 1		;c928   ; Modo de interrupcion 1
	di			;c92a
	ld sp,0c20ch		;c92b   ; Pila propia del monitor
	push af			;c92e   ; Los diez registros, en el orden en que los pinta el volcado
	push bc			;c92f
	push de			;c930
	push hl			;c931
	ex af,af'			;c932
	push af			;c933
	exx			;c934
	push bc			;c935
	push de			;c936
	push hl			;c937
	push ix		;c938
	push iy		;c93a
	ld sp,(0c1f6h)		;c93c   ; Recupera la pila del programa para sacar la direccion de vuelta
	pop hl			;c940
	ld (0c1f6h),sp		;c941
	dec hl			;c945   ; Tres atras: la del CALL que trajo aqui
	dec hl			;c946
	dec hl			;c947
	ld (0c1f4h),hl		;c948   ; Ese es el PC que se ensena
	ld sp,0c0ffh		;c94b   ; Y ahora si, la pila del monitor
	call 0d2dbh		;c94e
	call 0d20bh		;c951
	call 0d2d2h		;c954
	ld hl,0c198h		;c957
	ld de,0c184h		;c95a
	ld b,00ah		;c95d
monitor_quita_los_puntos_de_parada:		; Repone los tres bytes que guardo 0xC617
	ld a,(de)			;c95f   ; La direccion, byte bajo...
	inc de			;c960
	ld c,a			;c961
	ld a,(de)			;c962   ; ...y byte alto
	inc de			;c963
	push de			;c964
	ld e,c			;c965
	ld d,a			;c966
	push bc			;c967
	ld bc,00003h		;c968   ; Tres bytes
	ldir		;c96b   ; Se reponen
	pop bc			;c96d
	pop de			;c96e
	djnz monitor_quita_los_puntos_de_parada		;c96f   ; El siguiente punto
	call 0d2dbh		;c971
	call monitor_volcado_de_registros		;c974
	jp L_C24D		;c977
L_C97A:
	call L_CAB0		;c97a
	xor a			;c97d
	ld (0c1bch),a		;c97e
L_C981:
	call monitor_prepara_el_paso_a_paso		;c981
	call 0d2dbh		;c984
	call monitor_lee_una_tecla		;c987
	call L_CB10		;c98a
	jr L_C981		;c98d
monitor_escribe_los_indicadores:		; Pinta "Indicateur= " y las ocho banderas
	ld hl,01700h		;c98f   ; La linea de resultados
	ld (0c1d4h),hl		;c992
	ld hl,0da44h		;c995   ; El texto "Indicateur= "
	call monitor_escribe_hasta_el_cero		;c998
	ld a,(0c20ah)		;c99b   ; El registro F guardado
	ld b,008h		;c99e   ; Ocho banderas
	ld hl,0d935h		;c9a0   ; La cadena "SZ1H1PNC"
	ld c,a			;c9a3
L_C9A4:
	sla c		;c9a4
	jr c,L_C9AC		;c9a6
	ld a,02dh		;c9a8
	jr L_C9AD		;c9aa
L_C9AC:
	ld a,(hl)			;c9ac
L_C9AD:
	call monitor_imprime_un_caracter		;c9ad
	inc hl			;c9b0
	djnz L_C9A4		;c9b1
	jp L_C2AF		;c9b3
monitor_conmuta_las_interrupciones:		; Escribe "Interruptions" y alterna entre las dos palabras
	ld hl,01700h		;c9b6   ; Donde escribir
	ld (0c1d4h),hl		;c9b9
	ld hl,0da51h		;c9bc   ; "Interruptions "
	call monitor_escribe_hasta_el_cero		;c9bf
	ld a,(0c65dh)		;c9c2   ; El byte que guarda el estado; esta DENTRO del codigo de 0xC65D
	xor 0fbh		;c9c5   ; Lo cambia de valor
	ld (0c65dh),a		;c9c7
	ld hl,0da6bh		;c9ca   ; "interdites"...
	jr z,L_C9D2		;c9cd
	ld hl,0da60h		;c9cf   ; ...o "autorisees"
L_C9D2:
	call monitor_escribe_hasta_el_cero		;c9d2
	jp L_C2AF		;c9d5
monitor_cabecera_del_volcado:		; Escribe "ADRESSES" y la direccion de la linea
	push hl			;c9d8
	call 0d2d2h		;c9d9
	ld hl,00000h		;c9dc   ; Al principio de la linea
	ld (0c1d4h),hl		;c9df
	ld hl,0da76h		;c9e2   ; "ADRESSES "
	call monitor_escribe_hasta_el_cero		;c9e5
	pop hl			;c9e8
	push hl			;c9e9
	call L_C336		;c9ea   ; La direccion, en hexadecimal
	ld hl,0da80h		;c9ed   ; " A "
	call monitor_escribe_hasta_el_cero		;c9f0
	pop hl			;c9f3
	push hl			;c9f4
	ld a,l			;c9f5
	add a,07fh		;c9f6   ; Mas 0x7F: la ultima de la linea
	ld l,a			;c9f8
	call L_C336		;c9f9
	ld b,00bh		;c9fc   ; Once espacios
monitor_espacios:		; Escribe B espacios y despues la cabecera del ASCII
	ld a,020h		;c9fe   ; Un espacio
	call monitor_imprime_un_caracter		;ca00
	djnz monitor_espacios		;ca03   ; Los que queden
	ld hl,0da84h		;ca05   ; "ASCII  "
	call monitor_escribe_hasta_el_cero		;ca08
	ld a,(0c1d3h)		;ca0b   ; La bandera de eco
	bit 3,a		;ca0e   ; El bit 3 decide si hay salto de linea
	ld a,00dh		;ca10
	call nz,monitor_imprime_un_caracter		;ca12
	pop hl			;ca15
	push hl			;ca16
	ld b,010h		;ca17   ; Dieciseis lineas
monitor_separa_con_espacios:		; La direccion y dos espacios de separacion
	call L_C336		;ca19   ; La direccion, en hexadecimal
	ld a,020h		;ca1c   ; Un espacio
	call monitor_imprime_un_caracter		;ca1e
	ld a,020h		;ca21   ; Y otro
	call monitor_imprime_un_caracter		;ca23
	ld c,008h		;ca26   ; Ocho bytes por linea
monitor_volcado_en_hexadecimal:		; Ocho bytes en hexadecimal, separados por espacios
	ld a,(hl)			;ca28   ; El byte
	call monitor_byte_en_hexadecimal_2		;ca29   ; En hexadecimal
	inc l			;ca2c
	ld a,020h		;ca2d   ; Un espacio
	call monitor_imprime_un_caracter		;ca2f
	dec c			;ca32
	jr nz,monitor_volcado_en_hexadecimal		;ca33   ; Los que queden
	ld a,l			;ca35
	sub 008h		;ca36   ; Vuelve ocho atras: ahora toca el ASCII
	ld l,a			;ca38
	ld c,008h		;ca39   ; Ocho otra vez
L_CA3B:
	ld a,(hl)			;ca3b
	cp 020h		;ca3c
	jr nc,monitor_volcado_en_ascii		;ca3e
	ld a,02eh		;ca40
monitor_volcado_en_ascii:		; Los mismos ocho bytes, como caracteres
	call monitor_imprime_un_caracter		;ca42   ; Lo imprime
	inc l			;ca45
	dec c			;ca46
	jr nz,L_CA3B		;ca47   ; Los que queden
	ld a,(0c1d3h)		;ca49   ; La bandera de eco
	bit 3,a		;ca4c   ; El bit 3 decide si hay salto de linea
	ld a,00dh		;ca4e
	call nz,monitor_imprime_un_caracter		;ca50
	djnz monitor_separa_con_espacios		;ca53   ; La linea siguiente
	ld a,(0c1d3h)		;ca55
	bit 3,a		;ca58
	ld a,00dh		;ca5a
	call nz,monitor_imprime_un_caracter		;ca5c
	pop hl			;ca5f
	call 0d2dbh		;ca60
	ret			;ca63
monitor_volcado_de_registros:		; Prepara la ventana y recorre los doce registros
	ld hl,01100h		;ca64   ; La ventana de registros
	ld (0c1d4h),hl		;ca67
	ld a,(0c1d3h)		;ca6a   ; La bandera de eco
	push af			;ca6d
	res 3,a		;ca6e   ; Bit 3 abajo: sale por la ventana propia
	ld (0c1d3h),a		;ca70
	ld b,00ch		;ca73   ; Doce registros
monitor_apunta_al_nombre:		; Cada nombre ocupa cuatro caracteres en 0xD901
	ld a,b			;ca75   ; El numero de registro
	add a,a			;ca76   ; Por cuatro
	add a,a			;ca77
	ld e,a			;ca78
	ld d,000h		;ca79
	ld hl,0d901h		;ca7b   ; La tabla de nombres
	add hl,de			;ca7e
	ld c,004h		;ca7f   ; Cuatro caracteres
monitor_escribe_nombre_y_valor:		; Imprime C caracteres del nombre y el valor del registro
	ld a,(hl)			;ca81   ; Un caracter del nombre
	call monitor_imprime_un_caracter		;ca82
	inc hl			;ca85
	dec c			;ca86
	jr nz,monitor_escribe_nombre_y_valor		;ca87   ; Los que queden
	ld a,b			;ca89
	add a,a			;ca8a   ; Por dos: son palabras
	ld d,000h		;ca8b
	ld e,a			;ca8d
	ld hl,0c1f2h		;ca8e   ; El area de registros
	add hl,de			;ca91
	ld a,(hl)			;ca92   ; El valor
	inc hl			;ca93
	ld h,(hl)			;ca94
	ld l,a			;ca95
	call L_C336		;ca96   ; En hexadecimal
	ld a,(0c1d4h)		;ca99   ; Si hay ventana, dos espacios de separacion
	or a			;ca9c
	jr z,L_CAA9		;ca9d
	ld a,020h		;ca9f
	call monitor_imprime_un_caracter		;caa1
	ld a,020h		;caa4
	call monitor_imprime_un_caracter		;caa6
L_CAA9:
	djnz monitor_apunta_al_nombre		;caa9
	pop af			;caab
	ld (0c1d3h),a		;caac
	ret			;caaf
L_CAB0:
	ld a,(de)			;cab0
	cp 070h		;cab1
	jr z,L_CAB8		;cab3
	cp 050h		;cab5
	ret nz			;cab7
L_CAB8:
	inc de			;cab8
	ld a,(0c1d3h)		;cab9
	set 3,a		;cabc
	ld (0c1d3h),a		;cabe
	ret			;cac1
monitor_lee_o_falla:		; Lee un numero y, si no vale, saca el mensaje de error
	ex de,hl			;cac2
	call monitor_lee_un_numero		;cac3   ; El numero
	ex de,hl			;cac6
	ret nc			;cac7   ; Sin acarreo: bien leido
	ld hl,(0c1deh)		;cac8   ; El mensaje que se apunto
	jp monitor_escribe_el_error		;cacb   ; Y se saca
monitor_limpia_la_pantalla:		; Con el eco por la ventana, borra los 0x2A8 caracteres
	ld a,(0c1d3h)		;cace   ; La bandera de eco
	bit 3,a		;cad1
	ret nz			;cad3   ; Con el bit 3, no hay ventana que limpiar
	ld hl,00000h		;cad4   ; Desde el principio de la VRAM
	di			;cad7   ; Sin interrupciones
	call monitor_direccion_de_vram		;cad8
	ld bc,002a8h		;cadb   ; 0x2A8 = 680 casillas
monitor_borra_con_espacios:		; Escribe espacios por el puerto del VDP hasta agotar BC
	ld a,020h		;cade   ; El espacio
	out (098h),a		;cae0   ; Puerto de datos del VDP
	dec bc			;cae2   ; Uno menos
	ld a,b			;cae3
	or c			;cae4
	jr nz,monitor_borra_con_espacios		;cae5   ; Hasta acabar
	ei			;cae7   ; Y vuelven las interrupciones
	ld hl,00000h		;cae8
	ld (0c1d4h),hl		;caeb
	ret			;caee
L_CAEF:
	ld a,008h		;caef
	call monitor_imprime_o_borra		;caf1
	ret			;caf4
L_CAF5:
	call monitor_lee_una_tecla		;caf5
	jr z,L_CAF5		;caf8
	ret			;cafa
monitor_escribe_hasta_el_retorno:		; Saca caracteres hasta el 0x0D, incluido
	ld a,(hl)			;cafb   ; Un caracter
	inc hl			;cafc
	push af			;cafd
	call monitor_imprime_o_borra		;cafe   ; Lo imprime
	pop af			;cb01
	cp 00dh		;cb02   ; Retorno de carro: se acabo
	ret z			;cb04
	jr monitor_escribe_hasta_el_retorno		;cb05
monitor_escribe_hasta_el_cero:		; Saca caracteres hasta el 0x00
	ld a,(hl)			;cb07   ; Un caracter
	or a			;cb08
	ret z			;cb09   ; El cero termina
	call monitor_imprime_un_caracter		;cb0a   ; Lo imprime
	inc hl			;cb0d
	jr monitor_escribe_hasta_el_cero		;cb0e
L_CB10:
	ld a,(0c1d3h)		;cb10
	bit 3,a		;cb13
	ret z			;cb15
monitor_lee_una_tecla:		; Lee del teclado y traduce las teclas de control del monitor
	call 0d272h		;cb16   ; Espera una tecla
	ei			;cb19   ; Y devuelve las interrupciones
	cp 003h		;cb1a   ; 3 es CTRL+C: cancelar
	jr z,monitor_orden_de_busqueda		;cb1c
	cp 085h		;cb1e   ; De 0x85 a 0x88, las cuatro flechas
	jp z,0d232h		;cb20
	cp 086h		;cb23
	jp z,0d248h		;cb25
	cp 087h		;cb28
	jp z,0d250h		;cb2a
	cp 088h		;cb2d
	jp z,0d258h		;cb2f
	bit 7,a		;cb32   ; Los codigos con el bit 7 puesto no valen
	jr nz,L_CB69		;cb34
	cp 00dh		;cb36   ; Retorno de carro
	jr z,monitor_a_mayusculas		;cb38
	cp 008h		;cb3a   ; Borrado
	jr z,monitor_a_mayusculas		;cb3c
	cp 01dh		;cb3e   ; Inicio de linea
	jp z,monitor_a_mayusculas		;cb40
	cp 01ch		;cb43   ; Tabulador
	jp z,monitor_tabulador		;cb45
	cp 01fh		;cb48
	jr z,$+59		;cb4a
	cp 01eh		;cb4c
	jr z,$+55		;cb4e
	cp 012h		;cb50
	jr z,$+70		;cb52
	cp 07fh		;cb54   ; 0x7F, la tecla de borrar
	jr z,$+62		;cb56
	cp 00ch		;cb58   ; 0x0C, limpiar pantalla
	jr z,$+79		;cb5a
	cp 010h		;cb5c   ; Por debajo de 0x10 no hay nada imprimible
	jr c,L_CB69		;cb5e
monitor_a_mayusculas:		; Pasa una minuscula a mayuscula
	cp 061h		;cb60   ; Por debajo de la 'a', nada
	ret c			;cb62
	cp 07bh		;cb63   ; De la '{' para arriba, tampoco
	ret nc			;cb65
	xor 020h		;cb66   ; El bit 5 es el que las separa
	ret			;cb68
L_CB69:
	xor a			;cb69
	ret			;cb6a
monitor_orden_de_busqueda:		; Con el bit 2 puesto, escribe donde se encontro
	ld a,(0c1d3h)		;cb6b   ; La bandera de estado
	bit 2,a		;cb6e   ; Bit 2: se encontro algo
	jp z,L_C24D		;cb70   ; No hay nada que ensenar
	ex de,hl			;cb73
	ld a,(0c1b8h)		;cb74   ; El caracter guardado
	call monitor_escribe_en_la_ventana		;cb77
	jp L_C24D		;cb7a

; ----------------------------------------------------------------------
; DATOS monitor_cr_y_prompt: Ocho bytes del monitor: "ld a,0x0D / call 0xCD16
;   / jp 0xC24D", o sea imprime un retorno de carro y vuelve al interprete de
;   ordenes. Nadie salta aqui
;   0xcb7d..0xcb85  (8 bytes)
DATA_monitor_cr_y_prompt:
	defb 03eh,00dh,0cdh,016h,0cdh,0c3h,04dh,0c2h	; cb7d  >.....M.

; ======================================================================
; CODIGO 0xcb85..0xcc5f  (218 bytes)
; ======================================================================


monitor_tabulador:		; Con el bit 2 puesto, pasa a mayusculas
	push af			;cb85
	ld a,(0c1d3h)		;cb86   ; La bandera de estado
	bit 2,a		;cb89   ; Bit 2
	jr z,L_CB91		;cb8b
	pop af			;cb8d   ; Y se convierte
	jp monitor_a_mayusculas		;cb8e
L_CB91:
	pop af			;cb91
	jr $-41		;cb92
L_CB94:
	ld a,001h		;cb94
	jr monitor_paso_a_paso		;cb96
L_CB98:
	xor a			;cb98
monitor_paso_a_paso:		; Con el bit 1 puesto, ejecuta una instruccion
	ld (0c1bch),a		;cb99   ; El subtipo
	ld a,(0c1d3h)		;cb9c   ; La bandera de estado
	bit 1,a		;cb9f   ; Bit 1: se puede
	jr z,$-56		;cba1
	call monitor_prepara_el_paso_a_paso		;cba3   ; Un paso
	jp L_C24D		;cba6
monitor_ejecuta_hasta:		; Con el bit 1 puesto, corre hasta el punto de parada
	ld a,(0c1d3h)		;cba9   ; La bandera de estado
	bit 1,a		;cbac   ; Bit 1: se puede
	jr z,$-69		;cbae
	call 0d23ah		;cbb0
	call L_CDB8		;cbb3   ; Y se lanza
	jp L_C24D		;cbb6
monitor_prepara_el_paso_a_paso:		; Limpia el tampon y copia en el la instruccion que toca ejecutar
	ld hl,00000h		;cbb9   ; Cuatro bytes a cero...
	ld (0cc5fh),hl		;cbbc
	ld (0cc61h),hl		;cbbf
	ld (0c1d6h),sp		;cbc2   ; La pila del monitor
	xor a			;cbc6
	ld (0c1bbh),a		;cbc7   ; Banderas a cero
	ld (0c1bdh),a		;cbca
	ld ix,(0c1f4h)		;cbcd   ; La direccion del programa detenido
	call 0d2d2h		;cbd1
	call L_CE27		;cbd4
	ld a,(0c1e3h)		;cbd7   ; Cuantos bytes ocupa la instruccion
	ld b,a			;cbda
	ld hl,0cc5fh		;cbdb   ; El tampon donde se va a ejecutar
monitor_copia_la_instruccion:		; Mete los bytes de la instruccion en el tampon
	ld a,(ix+000h)		;cbde   ; Un byte del programa
	ld (hl),a			;cbe1   ; Al tampon
	inc hl			;cbe2
	inc ix		;cbe3
	djnz monitor_copia_la_instruccion		;cbe5   ; Los que queden
	ld a,(0c1bbh)		;cbe7   ; El tipo de instruccion
	or a			;cbea
	jr z,L_CC50		;cbeb
	cp 001h		;cbed   ; Tipo 1
	jr nz,L_CBF9		;cbef
L_CBF1:
	ld hl,0cc74h		;cbf1
	ld (0cc60h),hl		;cbf4
	jr L_CC50		;cbf7
L_CBF9:
	cp 002h		;cbf9
	jr nz,monitor_arregla_un_call		;cbfb
	ld a,013h		;cbfd
	ld (0cc60h),a		;cbff
	jr L_CC50		;cc02
monitor_arregla_un_call:		; Si la instruccion era un RST, lo cambia por un CALL
	cp 003h		;cc04   ; Tipo 3
	jr nz,monitor_prepara_el_call		;cc06
	ld a,(0c1bch)		;cc08   ; La bandera
	or a			;cc0b
	jr nz,L_CC50		;cc0c
	ld a,(0cc5fh)		;cc0e   ; El primer byte del tampon
	and 0c7h		;cc11   ; Los bits que distinguen un RST
	cp 0c7h		;cc13
	jr nz,L_CBF1		;cc15
	ld a,0cdh		;cc17   ; El opcode de CALL
	ld (0cc5fh),a		;cc19   ; Y se pone en su lugar
	jr L_CBF1		;cc1c
monitor_prepara_el_call:		; Con el tipo 4, mete la vuelta a 0xCC74 en la pila
	cp 004h		;cc1e   ; Tipo 4
	jr nz,monitor_elige_el_registro_indice		;cc20
	ld hl,(0c1f6h)		;cc22   ; La pila del programa
	ld (0c1c0h),hl		;cc25
	ld hl,0cc74h		;cc28   ; La direccion de vuelta al monitor
	push hl			;cc2b
	ld (0c1f6h),sp		;cc2c   ; Y se guarda la pila
	jr L_CC50		;cc30
monitor_elige_el_registro_indice:		; Segun el prefijo, IX, IY o HL
	ld hl,(0c1fah)		;cc32   ; IY guardado
	ld a,(0cc5fh)		;cc35   ; El primer byte de la instruccion
	cp 0ddh		;cc38   ; Prefijo DD: es IX
	jr z,L_CC46		;cc3a
	ld hl,(0c1f8h)		;cc3c   ; IX guardado
	cp 0fdh		;cc3f   ; Prefijo FD: es IY
	jr z,L_CC46		;cc41
	ld hl,(0c204h)		;cc43   ; Y si no, HL
L_CC46:
	ld (0c1c4h),hl		;cc46
	ld a,0c3h		;cc49
	ld (0cc5fh),a		;cc4b
	jr L_CBF1		;cc4e
L_CC50:
	ld hl,(0c1f4h)		;cc50
	ld (0c1c2h),hl		;cc53
	ld hl,0cc5fh		;cc56
	ld (0c1f4h),hl		;cc59
	jp monitor_devuelve_el_mando		;cc5c

; ----------------------------------------------------------------------
; DATOS tampon_del_paso_a_paso: Cuatro bytes donde el monitor copia la
;   instruccion del programa detenido para ejecutarla (0xCBB9 los pone a cero,
;   0xCBDB los llena). En la cinta han quedado con "2A 78 80 00", que es LD
;   HL,(0x8078): la ultima instruccion que el monitor ejecuto paso a paso
;   antes de grabar, y 0x8078 esta dentro de las variables de este mismo juego
;   0xcc5f..0xcc63  (4 bytes)
DATA_tampon_del_paso_a_paso:
	defb 02ah,078h,080h,000h	; cc5f

; ======================================================================
; CODIGO 0xcc63..0xcc74  (17 bytes)
; ======================================================================


monitor_vuelve_del_tampon:		; Lo que se ejecuta justo despues del tampon de cuatro bytes
	ld (0c1f6h),sp		;cc63   ; La pila del programa
	ld sp,(0c1d6h)		;cc67   ; Y la del monitor
	push af			;cc6b
	ld a,001h		;cc6c   ; La bandera del paso a paso
	ld (0c1bdh),a		;cc6e
	pop af			;cc71
	jr $+6		;cc72

; ----------------------------------------------------------------------
; DATOS vuelta_del_paso_a_paso: Los cuatro bytes de LD (0xC1F6),SP con los que
;   el monitor recupera el control despues del tampon; los apuntan 0xCBF1 y
;   0xCC28
;   0xcc74..0xcc78  (4 bytes)
DATA_vuelta_del_paso_a_paso:
	defb 0edh,073h,0f6h,0c1h	; cc74

; ======================================================================
; CODIGO 0xcc78..0xcde2  (362 bytes)
; ======================================================================


monitor_recupera_el_mando:		; Igual que 0xC924: guarda los diez registros del programa
	im 1		;cc78   ; Modo de interrupcion 1
	di			;cc7a
	ld sp,0c20ch		;cc7b   ; La pila del monitor
	push af			;cc7e   ; Los diez registros
	push bc			;cc7f
	push de			;cc80
	push hl			;cc81
	ex af,af'			;cc82
	push af			;cc83
	exx			;cc84
	push bc			;cc85
	push de			;cc86
	push hl			;cc87
	push ix		;cc88
	push iy		;cc8a
	ld sp,(0c1d6h)		;cc8c   ; Y se vuelve a la del monitor
	call 0d2dbh		;cc90
	call 0d20bh		;cc93
	call 0d2d2h		;cc96
	ld a,(0c1bdh)		;cc99   ; La bandera del paso a paso
	or a			;cc9c
	jr z,monitor_cierra_el_paso		;cc9d
	ld b,000h		;cc9f
	ld a,(0c1e3h)		;cca1   ; Cuantos bytes ocupaba la instruccion
	ld c,a			;cca4
	ld hl,(0c1c2h)		;cca5   ; La direccion de partida
	add hl,bc			;cca8
	ld (0c1f4h),hl		;cca9   ; Y la de despues
	jr monitor_deshace_el_paso		;ccac
monitor_cierra_el_paso:		; Deja el PC nuevo y, si era un CALL, arregla la direccion de vuelta
	ld hl,(0c1c4h)		;ccae   ; La direccion siguiente
	ld (0c1f4h),hl		;ccb1
	ld a,(0c1bbh)		;ccb4   ; El tipo de instruccion
	cp 003h		;ccb7   ; Solo el 3 sigue
	jr nz,monitor_deshace_el_paso		;ccb9
	ld hl,(0c1f6h)		;ccbb   ; La pila del programa
	ld de,(0c1c2h)		;ccbe   ; La direccion de partida
	inc de			;ccc2   ; Mas tres, que es lo que ocupa el CALL
	inc de			;ccc3
	inc de			;ccc4
	ld (hl),e			;ccc5   ; Y se escribe como vuelta
	inc hl			;ccc6
	ld (hl),d			;ccc7
monitor_deshace_el_paso:		; Con el tipo 4, recupera la pila y la direccion de vuelta
	ld a,(0c1bbh)		;ccc8   ; El tipo de instruccion
	cp 004h		;cccb   ; Solo el 4
	jr nz,L_CCE9		;cccd
	di			;cccf   ; Sin interrupciones para tocar la pila
	ld sp,(0c1c0h)		;ccd0   ; La pila guardada
	ld a,(0c1bdh)		;ccd4   ; La bandera del paso
	or a			;ccd7
	jr nz,L_CCDE		;ccd8
	pop hl			;ccda   ; La direccion de vuelta que dejo la instruccion
	ld (0c1f4h),hl		;ccdb
L_CCDE:
	ld (0c1f6h),sp		;ccde
	ld sp,(0c1d6h)		;cce2
	call 0d2dbh		;cce6
L_CCE9:
	call L_C568		;cce9
	call monitor_volcado_de_registros		;ccec
	ret			;ccef
monitor_imprime_un_caracter:		; Lo saca por la ventana propia o por la pantalla del BASIC
	push bc			;ccf0
	ld b,a			;ccf1
	ld a,(0c1d3h)		;ccf2   ; La bandera de eco
	bit 3,a		;ccf5   ; El bit 3 elige el destino
	ld a,b			;ccf7
	pop bc			;ccf8
	jr nz,L_CD21		;ccf9   ; Puesto: por la pantalla del BASIC
	push de			;ccfb
	ld de,(0c1d4h)		;ccfc   ; La posicion de la ventana
	cp 00dh		;cd00   ; Retorno de carro
	jr z,L_CD0D		;cd02
	call monitor_escribe_en_la_ventana		;cd04   ; Lo escribe en la VRAM
	inc e			;cd07   ; Una columna mas
	ld a,e			;cd08
	cp 026h		;cd09   ; Ancho de la ventana, 38
	jr c,L_CD10		;cd0b
L_CD0D:
	ld e,000h		;cd0d
	inc d			;cd0f
L_CD10:
	ld (0c1d4h),de		;cd10
	pop de			;cd14
	ret			;cd15
monitor_imprime_o_borra:		; Segun el bit 3, imprime en la ventana o borra
	push bc			;cd16
	ld b,a			;cd17   ; Guarda el caracter
	ld a,(0c1d3h)		;cd18   ; La bandera de eco
	bit 3,a		;cd1b   ; Bit 3
	ld a,b			;cd1d
	pop bc			;cd1e
	jr z,monitor_borra_hacia_atras		;cd1f
L_CD21:
	call 0d2dbh		;cd21
	cp 00dh		;cd24
	jr nz,L_CD2D		;cd26
	call 000a5h		;cd28   ; BIOS LPTOUT - Sends one character to printer
	ld a,00ah		;cd2b
L_CD2D:
	cp 080h		;cd2d
	jr c,L_CD33		;cd2f
	ld a,020h		;cd31
L_CD33:
	call 000a5h		;cd33   ; BIOS LPTOUT - Sends one character to printer
	jp c,L_C24D		;cd36
	call 0d2d2h		;cd39
	ret			;cd3c
monitor_borra_hacia_atras:		; Escribe un espacio y retrocede una posicion, con vuelta de linea
	push de			;cd3d
	ld de,(0c1d4h)		;cd3e   ; La posicion de la ventana
	cp 008h		;cd42   ; El codigo de borrado
	jr nz,L_CD62		;cd44
	ld a,020h		;cd46   ; Un espacio
	call monitor_escribe_en_la_ventana		;cd48   ; Lo escribe
	dec e			;cd4b   ; Una columna atras
	jp p,L_CD57		;cd4c
	ld e,025h		;cd4f   ; Al pasarse, a la ultima columna...
	dec d			;cd51   ; ...y una fila arriba
	jp p,L_CD57		;cd52
	ld d,000h		;cd55   ; Y si tampoco cabe, a la primera
L_CD57:
	ld (0c1d4h),de		;cd57
	ld a,0c8h		;cd5b
	call monitor_escribe_en_la_ventana		;cd5d
	pop de			;cd60
	ret			;cd61
L_CD62:
	cp 00dh		;cd62
	jr nz,L_CD6D		;cd64
	ld a,020h		;cd66
	call monitor_escribe_en_la_ventana		;cd68
	jr L_CD76		;cd6b
L_CD6D:
	call monitor_escribe_en_la_ventana		;cd6d
	inc e			;cd70
	ld a,e			;cd71
	cp 026h		;cd72
	jr c,L_CD79		;cd74
L_CD76:
	ld e,000h		;cd76
	inc d			;cd78
L_CD79:
	ld (0c1d4h),de		;cd79
	ld a,0c8h		;cd7d
	call monitor_escribe_en_la_ventana		;cd7f
	pop de			;cd82
	ret			;cd83
monitor_imprime_en_decimal:		; Divide por 10000, 1000, 100 y 10 y escribe cada digito
	ld de,02710h		;cd84   ; Diez mil
	call L_CDA8		;cd87
	ld de,003e8h		;cd8a   ; Mil
	call L_CDA8		;cd8d
	ld de,00064h		;cd90   ; Cien
	call L_CDA8		;cd93
	ld de,0000ah		;cd96   ; Diez
	call L_CDA8		;cd99
	ld a,l			;cd9c   ; Y lo que queda son las unidades
	add a,030h		;cd9d   ; De numero a ASCII
	call monitor_imprime_un_caracter		;cd9f
	ld a,020h		;cda2   ; Un espacio detras
	call monitor_imprime_un_caracter		;cda4
	ret			;cda7
L_CDA8:
	or a			;cda8
	ld b,0ffh		;cda9
monitor_divide_y_escribe:		; Resta DE hasta que no cabe y escribe el digito
	sbc hl,de		;cdab   ; Resta
	inc b			;cdad   ; Un digito mas
	jr nc,monitor_divide_y_escribe		;cdae   ; Hasta que no cabe
	add hl,de			;cdb0   ; Se devuelve lo restado de mas
	ld a,b			;cdb1
	add a,030h		;cdb2   ; De numero a ASCII
	call monitor_imprime_un_caracter		;cdb4
	ret			;cdb7
L_CDB8:
	ld hl,00000h		;cdb8
	di			;cdbb
	call monitor_direccion_de_vram		;cdbc
	ld bc,00400h		;cdbf
monitor_llena_de_espacios:		; Escribe espacios por el puerto del VDP
	ld a,020h		;cdc2   ; El espacio
	out (098h),a		;cdc4   ; Puerto de datos del VDP
	dec bc			;cdc6   ; Uno menos
	ld a,b			;cdc7
	or c			;cdc8
	jr nz,monitor_llena_de_espacios		;cdc9
	ei			;cdcb   ; Y vuelven las interrupciones
	ret			;cdcc
monitor_casilla_de_la_ventana:		; De fila y columna saca la direccion de la VRAM
	push de			;cdcd
	ld l,d			;cdce   ; La fila
	ld h,000h		;cdcf
	add hl,hl			;cdd1   ; Por ocho...
	add hl,hl			;cdd2
	add hl,hl			;cdd3
	ld d,h			;cdd4
	ld e,l			;cdd5
	add hl,hl			;cdd6   ; ...y por cuatro mas, o sea por 40 en total
	add hl,hl			;cdd7
	add hl,de			;cdd8
	inc hl			;cdd9   ; Dos de margen
	inc hl			;cdda
	pop de			;cddb
	push de			;cddc
	ld d,000h		;cddd
	add hl,de			;cddf   ; Mas la columna
	pop de			;cde0
	ret			;cde1

; ----------------------------------------------------------------------
; DATOS monitor_cola_de_espera: Seis bytes del monitor: "dec bc / ld a,b / or
;   c / jr nz,-5 / ret", la cola de un bucle de espera cuya cabeza ya no esta
;   0xcde2..0xcde8  (6 bytes)
DATA_monitor_cola_de_espera:
	defb 00bh,078h,0b1h,020h,0fbh,0c9h	; cde2

; ======================================================================
; CODIGO 0xcde8..0xce1f  (55 bytes)
; ======================================================================


monitor_compara_hl_y_de:		; Devuelve Z si son iguales, sin tocar los registros
	ld a,h			;cde8   ; Los bytes altos
	sub d			;cde9
	ret nz			;cdea   ; Distintos: se acabo
	ld a,l			;cdeb   ; Y los bajos
	sub e			;cdec
	ret			;cded
monitor_escribe_en_la_ventana:		; Calcula la casilla y escribe el caracter, con el slot bien puesto
	push hl			;cdee
	push af			;cdef
	call monitor_casilla_de_la_ventana		;cdf0   ; La casilla
	pop af			;cdf3
	di			;cdf4   ; Sin interrupciones
	call monitor_escribe_en_vram		;cdf5   ; Escribe
	in a,(0a8h)		;cdf8   ; El registro de slots
	and 00fh		;cdfa   ; Solo se devuelven las interrupciones si la pagina 0 es la ROM
	jr nz,L_CDFF		;cdfc
	ei			;cdfe
L_CDFF:
	pop hl			;cdff
	ret			;ce00
monitor_escribe_en_vram:		; Pone la direccion y saca el byte
	push af			;ce01
	call monitor_direccion_de_vram		;ce02   ; La direccion
	ex (sp),hl			;ce05   ; Dos EX (SP),HL seguidos: no hacen nada, son la pausa que pide el VDP
	ex (sp),hl			;ce06
	pop af			;ce07
	out (098h),a		;ce08   ; Puerto de datos del VDP
	ret			;ce0a
L_CE0B:
	push hl			;ce0b
	call monitor_casilla_de_la_ventana		;ce0c
	di			;ce0f
	call 0004ah		;ce10   ; BIOS RDVRM - Reads the content of VRAM
	ei			;ce13
	pop hl			;ce14
	ret			;ce15
monitor_direccion_de_vram:		; Pone HL en el VDP en modo escritura
	ld a,l			;ce16   ; Byte bajo
	out (099h),a		;ce17   ; Puerto de control del VDP
	ld a,h			;ce19
	or 040h		;ce1a   ; El bit 6 pide escritura
	out (099h),a		;ce1c
	ret			;ce1e

; ----------------------------------------------------------------------
; DATOS monitor_pon_direccion_vdp: Ocho bytes del monitor: "ld a,l / out
;   (0x99),a / ld a,h / nop / out (0x99),a / ret", que es poner una direccion
;   en el VDP. Nadie la llama
;   0xce1f..0xce27  (8 bytes)
DATA_monitor_pon_direccion_vdp:
	defb 07dh,0d3h,099h,07ch,000h,0d3h,099h,0c9h	; ce1f  }..|....

; ======================================================================
; CODIGO 0xce27..0xcf8e  (359 bytes)
; ======================================================================


L_CE27:
	push ix		;ce27
	call L_CE2F		;ce29
	pop ix		;ce2c
	ret			;ce2e
L_CE2F:
	ld hl,0c1e4h		;ce2f
	ld b,010h		;ce32
monitor_prepara_el_desensamblado:		; Limpia la linea y mira el prefijo de la instruccion
	ld (hl),020h		;ce34   ; Un espacio
	inc hl			;ce36
	djnz monitor_prepara_el_desensamblado		;ce37   ; Toda la linea
	xor a			;ce39
	ld (0c1e2h),a		;ce3a
	ld (0c1e0h),ix		;ce3d   ; La direccion que se desensambla
	ld a,002h		;ce41   ; Dos bytes por defecto
	ld (0c1e3h),a		;ce43
	ld hl,04c48h		;ce46   ; El nemonico por defecto; se escribe en 0xD64E, que en esta cinta son datos del juego
	ld (0d64eh),hl		;ce49
	ld a,(ix+000h)		;ce4c   ; El primer byte
	cp 0cbh		;ce4f   ; Prefijo CB
	jr z,L_CE80		;ce51
	cp 0edh		;ce53   ; Prefijo ED
	jp z,monitor_prefijo_ed		;ce55
	cp 0ddh		;ce58   ; Prefijo DD
	jr z,L_CE8A		;ce5a
	cp 0fdh		;ce5c   ; Prefijo FD
	jr z,L_CE8F		;ce5e
	ld a,001h		;ce60   ; Sin prefijo: un byte
	ld (0c1e3h),a		;ce62
L_CE65:
	ld hl,0d826h		;ce65
	call monitor_busca_con_mascara		;ce68
	ld hl,0d88bh		;ce6b
	call monitor_busca_exacto		;ce6e
monitor_instruccion_desconocida:		; Deja "??" de nemonico y un byte de tamano
	ld hl,03f3fh		;ce71   ; Los dos interrogantes
	ld (0c1e4h),hl		;ce74
	ld (0c1e6h),hl		;ce77
	ld a,001h		;ce7a   ; Un byte
	ld (0c1e3h),a		;ce7c
	ret			;ce7f
L_CE80:
	ld hl,0d7edh		;ce80
	inc ix		;ce83
	call monitor_busca_con_mascara		;ce85
	jr monitor_instruccion_desconocida		;ce88
L_CE8A:
	ld hl,05849h		;ce8a
	jr monitor_prefijo_dd_o_fd		;ce8d
L_CE8F:
	ld hl,05949h		;ce8f
monitor_prefijo_dd_o_fd:		; Guarda el nemonico y mira si detras viene un CB
	ld (0d64eh),hl		;ce92   ; El nemonico; se escribe en 0xD64E, que aqui son datos del juego
	inc ix		;ce95   ; El byte siguiente
	ld a,(ix+000h)		;ce97
	cp 0cbh		;ce9a   ; Otro prefijo CB
	jr z,monitor_prefijo_dd_cb		;ce9c
	ld hl,0d816h		;ce9e   ; La tabla de opcodes con indice
	ld b,010h		;cea1   ; Dieciseis entradas
monitor_busca_el_opcode:		; Recorre la tabla y decide cuantos operandos lleva
	cp (hl)			;cea3   ; Compara con la tabla
	jr z,L_CE65		;cea4
	inc hl			;cea6   ; Siguiente entrada
	djnz monitor_busca_el_opcode		;cea7
	cp 07eh		;cea9   ; Por encima de 0x7E ya no hay tabla
	jr nc,monitor_mira_el_operando		;ceab
	xor a			;cead
	call monitor_copia_el_nemonico		;ceae
	ld a,(ix+000h)		;ceb1
	cp 076h		;ceb4   ; 0x76 es HALT
	jr z,monitor_instruccion_desconocida		;ceb6
	cp 036h		;ceb8   ; 0x36 es LD (HL),n
	jr z,L_CE65		;ceba
	cp 040h		;cebc   ; De 0x40 a 0x77 son los LD r,r'
	jr c,monitor_instruccion_desconocida		;cebe
	cp 078h		;cec0
	jr nc,monitor_instruccion_desconocida		;cec2
	cp 070h		;cec4
	jr nc,L_CE65		;cec6
	and 007h		;cec8   ; Los tres bits de abajo dicen el origen
	cp 006h		;ceca   ; El 6 es (HL)
	jr nz,monitor_instruccion_desconocida		;cecc
	jr L_CE65		;cece
monitor_mira_el_operando:		; De 0xBF en adelante no hay tabla; el 6 es (HL)
	cp 0bfh		;ced0   ; El limite de la tabla
	jr nc,monitor_instruccion_desconocida		;ced2
	and 007h		;ced4   ; Los tres bits de abajo
	cp 006h		;ced6   ; El 6 es (HL)
	jr nz,monitor_instruccion_desconocida		;ced8
	jr L_CE65		;ceda
monitor_prefijo_dd_cb:		; Las de DD CB llevan tres bytes y desplazamiento
	ld a,(ix+002h)		;cedc   ; El tercer byte
	and 007h		;cedf   ; Los tres bits de abajo
	cp 006h		;cee1   ; Tiene que ser un 6
	jr nz,monitor_instruccion_desconocida		;cee3
	ld a,003h		;cee5   ; Tres bytes
	inc ix		;cee7
	ld (0c1e3h),a		;cee9
	ld (0c1e2h),a		;ceec   ; Y se apunta que hay desplazamiento
	jr L_CE80		;ceef
monitor_prefijo_ed:		; Busca en las dos tablas de las instrucciones ED
	inc ix		;cef1   ; El byte de despues del prefijo
	ld hl,0d788h		;cef3   ; Primera tabla, con mascara
	call monitor_busca_con_mascara		;cef6
	ld hl,0d7adh		;cef9   ; Segunda tabla, exacta
	call monitor_busca_exacto		;cefc
	jp monitor_instruccion_desconocida		;ceff   ; Y si no esta en ninguna, desconocida
monitor_busca_exacto:		; Recorre la tabla de tres en tres buscando el opcode
	ld a,(hl)			;cf02   ; La entrada
	cp 0ffh		;cf03   ; 0xFF termina la tabla
	ret z			;cf05
	cp (ix+000h)		;cf06   ; Contra el opcode
	jr z,monitor_salta_por_la_tabla_de_formatos		;cf09
	inc hl			;cf0b   ; Tres bytes por entrada
	inc hl			;cf0c
	inc hl			;cf0d
	jr monitor_busca_exacto		;cf0e
monitor_busca_con_mascara:		; Aplica la mascara y compara con el valor
	ld a,(hl)			;cf10   ; La mascara
	or a			;cf11
	ret z			;cf12   ; El cero termina la tabla
	and (ix+000h)		;cf13   ; Se aplica
	inc hl			;cf16
	cp (hl)			;cf17   ; Y se compara
	jr nz,L_CF32		;cf18
monitor_salta_por_la_tabla_de_formatos:		; Elige como imprimir los operandos
	inc hl			;cf1a
	ld a,(hl)			;cf1b   ; El codigo de formato
	call monitor_copia_el_nemonico		;cf1c   ; Copia el nemonico
	inc hl			;cf1f
	ld c,(hl)			;cf20
	sla c		;cf21   ; Por dos: son punteros
	ld hl,0d5f3h		;cf23   ; La tabla de formatos, que en esta cinta la tapan datos del juego
	ld b,000h		;cf26
	add hl,bc			;cf28
	ld b,(hl)			;cf29   ; El puntero
	inc hl			;cf2a
	ld h,(hl)			;cf2b
	ld l,b			;cf2c
	pop de			;cf2d
	ld de,0c1eah		;cf2e   ; El tampon donde se escribe
	jp (hl)			;cf31   ; Y salta. Con la tabla borrada, este salto va donde diga la ficha de pantalla
L_CF32:
	inc hl			;cf32
	inc hl			;cf33
	inc hl			;cf34
	jr monitor_busca_con_mascara		;cf35
monitor_copia_el_nemonico:		; Se trae los cuatro caracteres del nemonico
	push hl			;cf37
	push bc			;cf38
	ld hl,0d67ch		;cf39   ; La tabla de nemonicos
	add a,a			;cf3c   ; Por cuatro: cuatro letras cada uno
	add a,a			;cf3d
	ld b,000h		;cf3e
	rl b		;cf40
	ld c,a			;cf42
	add hl,bc			;cf43
	push de			;cf44
	ld de,0c1e4h		;cf45   ; El tampon del nemonico
	ld bc,00004h		;cf48   ; Cuatro letras
	ldir		;cf4b
	pop de			;cf4d
	pop bc			;cf4e
	pop hl			;cf4f
	ret			;cf50
monitor_escribe_el_operando:		; Copia el nombre del registro y, si es un salto, la direccion
	ld b,000h		;cf51
	ld c,a			;cf53
	ld hl,0d662h		;cf54   ; La tabla de nombres de registro
	add hl,bc			;cf57
	ldi		;cf58   ; Copia una letra
	cp 006h		;cf5a   ; El codigo 6 lleva mas
	ret nz			;cf5c
	ld hl,0d64eh		;cf5d   ; El nemonico en curso
	ld a,(hl)			;cf60
	ldi		;cf61
	ldi		;cf63
	cp 048h		;cf65   ; 0x48 es 'H': una direccion
	jr z,L_CF89		;cf67
	ld a,(0c1e2h)		;cf69   ; La bandera de prefijo
	or a			;cf6c
	ld a,(ix+001h)		;cf6d   ; El byte siguiente...
	jr z,monitor_signo_del_desplazamiento		;cf70
	ld a,(ix-001h)		;cf72   ; ...o el anterior, si habia prefijo
monitor_signo_del_desplazamiento:		; Elige el '+' o el '-' del (IX+d)
	or a			;cf75   ; El desplazamiento
	jp p,L_CF80		;cf76   ; Positivo: signo '+'
	neg		;cf79   ; Negativo: se cambia de signo
	ld b,a			;cf7b
	ld a,02dh		;cf7c   ; Y el '-'
	jr L_CF83		;cf7e
L_CF80:
	ld b,a			;cf80
	ld a,02bh		;cf81
L_CF83:
	ld (de),a			;cf83
	inc de			;cf84
	ld a,b			;cf85
	call monitor_byte_en_hexadecimal		;cf86
L_CF89:
	ld a,029h		;cf89
	ld (de),a			;cf8b
	inc de			;cf8c
	ret			;cf8d

; ----------------------------------------------------------------------
; DATOS monitor_imprime_coma: Cinco bytes del monitor: "ld a,',' / ld (de),a /
;   inc de / ret". Nadie la llama
;   0xcf8e..0xcf93  (5 bytes)
DATA_monitor_imprime_coma:
	defb 03eh,02ch,012h,013h,0c9h	; cf8e

; ======================================================================
; CODIGO 0xcf93..0xcf9b  (8 bytes)
; ======================================================================


L_CF93:
	ld a,(0c1e3h)		;cf93
	inc a			;cf96
	ld (0c1e3h),a		;cf97
	ret			;cf9a

; ----------------------------------------------------------------------
; DATOS monitor_lee_bandera: Ocho bytes del monitor: lee 0xC1E3, lo incrementa
;   y lo vuelve a guardar. Nadie la llama
;   0xcf9b..0xcfa3  (8 bytes)
DATA_monitor_lee_bandera:
	defb 022h,0c4h,0c1h,07ch,0cdh,0a3h,0cfh,07dh	; cf9b  "..|...}

; ======================================================================
; CODIGO 0xcfa3..0xcfd4  (49 bytes)
; ======================================================================


monitor_byte_en_hexadecimal:		; Escribe los dos digitos de un byte
	push bc			;cfa3
	push af			;cfa4
	call L_CF93		;cfa5   ; El digito de abajo
	pop af			;cfa8
	ld b,a			;cfa9
	rrca			;cfaa   ; Y por cuatro rotaciones, el de arriba
	rrca			;cfab
	rrca			;cfac
	rrca			;cfad
	call L_CFB3		;cfae   ; Lo escribe
	ld a,b			;cfb1
	pop bc			;cfb2
L_CFB3:
	and 00fh		;cfb3
	add a,030h		;cfb5
	cp 03ah		;cfb7
	jr c,L_CFBD		;cfb9
	add a,007h		;cfbb
L_CFBD:
	ld (de),a			;cfbd
	inc de			;cfbe
	ret			;cfbf
monitor_nombre_del_par:		; Saca del opcode el par de registros y copia su nombre
	ld a,(ix+000h)		;cfc0   ; El opcode
	and 030h		;cfc3   ; Los bits 4 y 5 dicen el par
	rrca			;cfc5   ; Divididos por ocho
	rrca			;cfc6
	rrca			;cfc7
	ld b,000h		;cfc8
	ld c,a			;cfca
	ld hl,0d64ah		;cfcb   ; La tabla de nombres de par, tapada tambien por datos del juego
	add hl,bc			;cfce
	ldi		;cfcf   ; Dos letras
	ldi		;cfd1
	ret			;cfd3

; ----------------------------------------------------------------------
; DATOS tablas_del_desensamblador: Lo que queda del desensamblador del monitor
;   entre 0xCFD4 y 0xD000
;   0xcfd4..0xd000  (44 bytes)
DATA_tablas_del_desensamblador:
	defb 0ddh,07eh,000h,0e6h,038h,00fh,00fh,006h,000h,04fh,021h,052h,0d6h,009h,0edh,0a0h	; cfd4  .~..8....O!R....
	defb 07eh,0feh,020h,0c8h,0edh,0a0h,0c9h,0ddh,07eh,000h,0feh,076h,0cah,06bh,0ceh,0e6h	; cfe4  ~. .....~..v.k..
	defb 038h,00fh,00fh,00fh,0cdh,051h,0cfh,0cdh,08eh,0cfh,0ddh,07eh	; cff4  8....Q.....~

; ----------------------------------------------------------------------
; DATOS punteros_de_pantalla: Veinticuatro punteros, uno por pantalla, a su
;   mapa comprimido en la RAM escondida (todos caen entre 0x43DE y 0x53C7).
;   Las entradas 13 y 14 apuntan las dos a 0x4D44
;   0xd000..0xd030  (48 bytes)
DATA_punteros_de_pantalla:
	defw 043deh,044aah,0451dh,0456eh	; d000
	defw 04604h,046afh,0475ch,04846h	; d008
	defw 048fah,04a48h,04b2ch,04bf1h	; d010
	defw 04c74h,04d44h,04d44h,04e54h	; d018
	defw 05298h,05346h,053c7h,04fafh	; d020
	defw 0500eh,05076h,05183h,0520bh	; d028

; ----------------------------------------------------------------------
; DATOS tabla_de_conducta: Veinticuatro filas de CUATRO punteros a rutina, una
;   fila por pantalla. Los huecos se rellenan con 0xFD9A, o sea con el vector
;   de sonido: "aqui no hay nada que hacer"
;   0xd030..0xd0c0  (144 bytes)
DATA_tabla_de_conducta:
	defw 0ddbah,09de8h,0fd9ah,0df28h	; d030  -> L_DDBA L_9DE8 0xfd9a L_DF28
	defw 0dbf0h,0fd9ah,0df18h,0ddc8h	; d038  -> L_DBF0 0xfd9a L_DF18 L_DDC8
	defw 0fd9ah,094f8h,09518h,0fd9ah	; d040  -> 0xfd9a prepara_al_perseguidor aparicion_por_un_lado 0xfd9a
	defw 09eb8h,09ec0h,0fd9ah,09e18h	; d048  -> L_9EB8 L_9EC0 0xfd9a L_9E18
	defw 09e30h,0fd9ah,0df18h,0ddc8h	; d050  -> sortea_una_aparicion 0xfd9a L_DF18 L_DDC8
	defw 0fd9ah,0ddc0h,09e30h,0fd9ah	; d058  -> 0xfd9a L_DDC0 sortea_una_aparicion 0xfd9a
	defw 0b758h,0b75fh,0fd9ah,0df18h	; d060  -> L_B758 cuenta_para_el_aviso 0xfd9a L_DF18
	defw 0ddc8h,0fd9ah,0fd9ah,0fd9ah	; d068  -> L_DDC8 0xfd9a 0xfd9a 0xfd9a
	defw 0fd9ah,0df30h,0df38h,0b4b4h	; d070  -> 0xfd9a L_DF30 L_DF38 L_B4B4
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d078
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d080
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d088
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d090
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d098
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d0a0
	defw 0fd9ah,0fd9ah,0fd9ah,09e18h	; d0a8  -> 0xfd9a 0xfd9a 0xfd9a L_9E18
	defw 09e30h,0fd9ah,0fd9ah,0fd9ah	; d0b0  -> sortea_una_aparicion 0xfd9a 0xfd9a 0xfd9a
	defw 0fd9ah,0fd9ah,0fd9ah,0fd9ah	; d0b8

; ----------------------------------------------------------------------
; DATOS fichas_de_pantalla: Veinticuatro fichas de 88 bytes, una por pantalla.
;   Se reconocen porque todas llevan en el byte 84 la marca FF <numero de
;   pantalla en ASCII> FF: 0xD114 la primera y 0xD8FC la ultima, siempre a 88
;   bytes de distancia. Encima de estas fichas han quedado enterradas la tabla
;   de ordenes del monitor (0xD5C6) y sus tablas de nemonicos (0xD64A en
;   adelante), que por eso estan a ceros
;   0xd0c0..0xd900  (2112 bytes)
DATA_fichas_de_pantalla:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,00eh,00bh,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,030h,031h,0ffh	; d0c0  .....................................................................................01.
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,03eh,000h,001h,00bh,00dh,002h,00bh,00bh,003h,018h,00dh,007h,018h,00bh,0ffh,000h,030h,032h,0ffh	; d118  .................................................................... >...............02.
	defb 000h,000h,000h,00ah,000h,004h,000h,0c0h,078h,0ffh,000h,074h,001h,000h,000h,000h,000h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,03fh,000h,002h,013h,00dh,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,030h,033h,0ffh	; d170  ........x..t........................................................ ?...............03.
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,030h,034h,0ffh	; d1c8  .....................................................................................04.
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,0ffh,030h,035h,0ffh	; d220  .....................................................................................05.
	defb 000h,000h,000h,004h,080h,006h,000h,0e8h,078h,000h,002h,0c6h,001h,000h,000h,000h,000h,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,004h,017h,00dh,005h,003h,00dh,000h,000h,000h,000h,000h,000h,0ffh,0ffh,030h,036h,0ffh	; d278  ........x............................................................................06.
	defb 000h,000h,000h,006h,000h,004h,000h,0b8h,088h,0ffh,000h,05eh,001h,000h,000h,001h,000h,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,03fh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,000h,030h,037h,0ffh	; d2d0  ...........^........................................................ ?...............07.
	defb 001h,017h,00dh,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,00ah,000h,073h,019h,012h,007h,0ffh,003h,000h,000h,000h,000h,000h,000h,000h,001h,001h,006h,0c8h,098h,001h,0c8h,0ffh,000h,001h,01bh,007h,002h,01bh,009h,003h,01dh,007h,007h,01dh,009h,0ffh,0ffh,030h,038h,0ffh	; d328  .................................................s...................................08.
	defb 001h,010h,005h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,004h,000h,088h,018h,007h,000h,001h,008h,000h,000h,000h,000h,000h,00bh,00ch,000h,000h,000h,000h,000h,000h,000h,000h,001h,001h,014h,005h,002h,016h,00eh,000h,000h,000h,000h,000h,000h,000h,0ffh,030h,039h,0ffh	; d380  .....................................................................................09.
	defb 000h,000h,000h,009h,001h,006h,002h,080h,020h,001h,001h,0a4h,001h,000h,000h,000h,000h,004h,000h,000h,000h,000h,000h,000h,004h,080h,004h,000h,0a0h,080h,001h,002h,0c6h,001h,000h,000h,000h,000h,00ah,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,03fh,000h,006h,00ah,005h,004h,01ah,005h,003h,012h,00eh,000h,000h,000h,000h,000h,031h,030h,0ffh	; d3d8  ........ ........................................................... ?...............10.
	defb 000h,000h,000h,008h,000h,003h,000h,030h,030h,001h,001h,03eh,001h,000h,000h,000h,000h,00ah,001h,000h,02ch,034h,000h,000h,008h,000h,006h,000h,060h,070h,0ffh,001h,03eh,001h,000h,000h,000h,000h,00ah,001h,000h,068h,074h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,002h,011h,007h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,031h,031h,0ffh	; d430  .......00..>........,4......`p..>........ht..........................................11.
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,020h,03fh,000h,001h,006h,005h,002h,010h,005h,003h,01ah,005h,000h,000h,000h,000h,0ffh,031h,032h,0ffh	; d488  .................................................................... ?...............12.
	defb 000h,000h,000h,003h,000h,004h,000h,030h,048h,001h,000h,000h,001h,000h,000h,002h,000h,006h,000h,000h,000h,000h,000h,000h,006h,080h,006h,000h,0b0h,090h,0ffh,000h,05eh,001h,000h,000h,001h,000h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,031h,033h,0ffh	; d4e0  .......0H.......................^....................................................13.
	defb 000h,000h,000h,003h,000h,005h,000h,080h,090h,001h,000h,000h,001h,000h,000h,002h,000h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,004h,000h,087h,018h,006h,000h,001h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,002h,006h,00ah,003h,00eh,00ah,001h,015h,00ah,005h,01bh,00ah,000h,0ffh,031h,034h,0ffh	; d538  .....................................................................................14.
	defb 000h,000h,000h,006h,000h,004h,000h,040h,048h,001h,000h,05eh,001h,000h,000h,001h,000h,005h,000h,000h,000h,000h,000h,000h,007h,000h,003h,000h,0a0h,080h,0ffh,000h,02eh,001h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,007h,006h,00ah,006h,00eh,00ah,007h,015h,00ah,002h,01bh,00ah,000h,0ffh,031h,035h,0ffh	; d590  .......@H..^.........................................................................15.
	defb 000h,000h,000h,009h,001h,002h,002h,050h,020h,001h,001h,0a4h,001h,000h,000h,000h,000h,008h,000h,000h,000h,000h,000h,000h,004h,080h,004h,000h,0a0h,080h,001h,002h,0c6h,001h,000h,000h,000h,000h,006h,000h,000h,000h,000h,000h,000h,001h,000h,006h,000h,08bh,018h,00ah,000h,001h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,005h,006h,00ah,007h,00eh,00ah,002h,015h,00ah,000h,000h,000h,000h,0ffh,031h,036h,0ffh	; d5e8  .......P ............................................................................16.
	defb 000h,000h,000h,005h,001h,010h,000h,030h,078h,000h,000h,08eh,001h,000h,000h,000h,000h,006h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,031h,037h,0ffh	; d640  .......0x............................................................................17.
	defb 000h,000h,000h,00ah,000h,004h,000h,050h,098h,001h,000h,068h,001h,000h,000h,000h,000h,005h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,008h,00ah,003h,00ch,00ah,005h,010h,00ah,007h,014h,00ah,000h,0ffh,031h,038h,0ffh	; d698  .......P...h.........................................................................18.
	defb 000h,000h,000h,00ah,000h,004h,000h,010h,098h,001h,000h,068h,001h,000h,000h,000h,000h,005h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,006h,011h,002h,010h,011h,004h,018h,011h,000h,000h,000h,000h,0ffh,031h,039h,0ffh	; d6f0  ...........h.........................................................................19.
	defb 000h,000h,000h,006h,000h,004h,000h,0b8h,0a8h,0ffh,000h,05eh,001h,000h,000h,001h,000h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,004h,00fh,000h,000h,000h,000h,000h,000h,000h,000h,001h,001h,008h,011h,002h,00dh,011h,003h,013h,011h,004h,018h,011h,0ffh,0ffh,032h,030h,0ffh	; d748  ...........^.........................................................................20.
	defb 000h,000h,000h,009h,001h,002h,002h,050h,050h,001h,001h,0a4h,001h,000h,000h,000h,000h,010h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,002h,000h,0cdh,019h,00ch,00ah,0ffh,004h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,008h,011h,000h,000h,000h,000h,000h,000h,000h,000h,011h,0ffh,0ffh,032h,031h,0ffh	; d7a0  .......PP............................................................................21.
	defb 000h,000h,000h,008h,000h,008h,000h,060h,070h,001h,001h,03eh,001h,000h,000h,000h,000h,00ah,001h,000h,068h,074h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,000h,004h,000h,05bh,019h,01ah,006h,0ffh,005h,000h,000h,000h,000h,000h,000h,000h,001h,001h,006h,0bbh,090h,001h,034h,0bch,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,0ffh,032h,032h,0ffh	; d7f8  .......`p..>........ht...........................[..................4................22.
	defb 000h,000h,000h,00ah,000h,004h,000h,0b0h,070h,0ffh,000h,074h,001h,000h,000h,000h,000h,003h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,005h,006h,00ch,007h,012h,00ch,000h,000h,000h,000h,000h,000h,0ffh,0ffh,032h,033h,0ffh	; d850  ........p..t.........................................................................23.
	defb 001h,01bh,00ch,008h,000h,002h,000h,0b0h,070h,0ffh,001h,03eh,001h,000h,000h,000h,000h,00ah,001h,000h,068h,074h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,001h,001h,006h,0bbh,090h,001h,034h,0bch,000h,001h,01eh,002h,002h,01eh,004h,005h,01eh,006h,003h,01eh,008h,0ffh,0ffh,032h,034h,0ffh	; d8a8  ........p..>........ht..............................................4................24.

; ----------------------------------------------------------------------
; DATOS textos_del_monitor: Los textos del monitor de Loriciels: la cabecera
;   del volcado de registros en 0xD905, "Auteur:Claude SABLATOU" en 0xD948,
;   "MONITEUR MSX" en 0xD95F, "Copyright (C) 1984 LORICIELS" en 0xD96C y los
;   mensajes de error a partir de 0xD98D
;   0xd900..0xda37  (311 bytes)
DATA_textos_del_monitor:
	defb 002h,02fh,002h,02ch,000h,020h,050h,043h,03dh,020h,053h,050h,03dh,020h,049h,059h	; d900  ./.,. PC= SP= IY
	defb 03dh,020h,049h,058h,03dh,048h,04ch,027h,03dh,044h,045h,027h,03dh,042h,043h,027h	; d910  = IX=HL'=DE'=BC'
	defb 03dh,041h,046h,027h,03dh,020h,048h,04ch,03dh,020h,044h,045h,03dh,020h,042h,043h	; d920  =AF'= HL= DE= BC
	defb 03dh,020h,041h,046h,03dh,053h,05ah,031h,048h,031h,050h,04eh,043h,050h,06fh,072h	; d930  = AF=SZ1H1PNCPor
	defb 074h,020h,041h,038h,020h,03dh,020h,000h,041h,075h,074h,065h,075h,072h,03ah,043h	; d940  t A8 = .Auteur:C
	defb 06ch,061h,075h,064h,065h,020h,053h,041h,042h,04ch,041h,054h,04fh,055h,00dh,04dh	; d950  laude SABLATOU.M
	defb 04fh,04eh,049h,054h,045h,055h,052h,020h,04dh,053h,058h,000h,043h,06fh,070h,079h	; d960  ONITEUR MSX.Copy
	defb 072h,069h,067h,068h,074h,020h,028h,043h,029h,020h,031h,039h,038h,034h,020h,04ch	; d970  right (C) 1984 L
	defb 04fh,052h,049h,043h,049h,045h,04ch,053h,00dh,020h,02dh,020h,000h,043h,06fh,06dh	; d980  ORICIELS. - .Com
	defb 06dh,061h,06eh,064h,065h,020h,069h,06ch,06ch,065h,067h,061h,06ch,065h,000h,050h	; d990  mande illegale.P
	defb 061h,072h,061h,06dh,065h,074h,072h,065h,073h,020h,069h,06eh,063h,06fh,072h,072h	; d9a0  arametres incorr
	defb 065h,063h,074h,073h,000h,045h,078h,070h,072h,065h,073h,073h,069h,06fh,06eh,020h	; d9b0  ects.Expression 
	defb 069h,06ch,06ch,065h,067h,061h,06ch,065h,000h,044h,065h,062h,06fh,072h,064h,065h	; d9c0  illegale.Deborde
	defb 06dh,065h,06eh,074h,000h,043h,068h,061h,069h,06eh,065h,020h,06eh,06fh,06eh,020h	; d9d0  ment.Chaine non 
	defb 074h,072h,06fh,075h,076h,065h,065h,000h,02ah,033h,0f4h,03eh,005h,011h,0b1h,0bdh	; d9e0  trouvee.*3.>....
	defb 006h,001h,0cdh,0c3h,0bdh,023h,03eh,024h,0cdh,04dh,000h,03eh,004h,0c3h,00ch,0dah	; d9f0  .....#>$.M.>....
	defb 045h,072h,072h,065h,075h,072h,020h,050h,069h,06ch,065h,000h,032h,030h,0f4h,03eh	; da00  Erreur Pile.20.>
	defb 060h,032h,031h,0f4h,0c3h,059h,0deh,0cdh,075h,08fh,018h,0deh,02ah,033h,0f4h,097h	; da10  `21..Y..u...*3..
	defb 0cdh,04dh,000h,023h,0cdh,04dh,000h,097h,032h,030h,0f4h,0c3h,059h,0deh,02ah,054h	; da20  .M.#.M..20..Y.*T
	defb 080h,022h,033h,0f4h,0c3h,059h,0deh	; da30

; ----------------------------------------------------------------------
; DATOS textos_del_monitor_2: El resto de los textos del monitor: "Resultat= "
;   en 0xDA39 (lo carga 0xC5C6), "Indicateur= " en 0xDA44 (lo carga 0xC995),
;   "Interruptions " / "autorisees" / "interdites", "ADRESSES ", " A ", "ASCII
;   ", "Chargement" y "Verification"
;   0xda37..0xdaa3  (108 bytes)
DATA_textos_del_monitor_2:
	defb 0ffh,000h,052h,065h,073h,075h,06ch,074h,061h,074h,03dh,020h,000h,049h,06eh,064h	; da37  ..Resultat= .Ind
	defb 069h,063h,061h,074h,065h,075h,072h,03dh,020h,000h,049h,06eh,074h,065h,072h,072h	; da47  icateur= .Interr
	defb 075h,070h,074h,069h,06fh,06eh,073h,020h,000h,061h,075h,074h,06fh,072h,069h,073h	; da57  uptions .autoris
	defb 065h,065h,073h,000h,069h,06eh,074h,065h,072h,064h,069h,074h,065h,073h,000h,041h	; da67  ees.interdites.A
	defb 044h,052h,045h,053h,053h,045h,053h,020h,000h,020h,041h,020h,000h,041h,053h,043h	; da77  DRESSES . A .ASC
	defb 049h,049h,020h,020h,000h,043h,068h,061h,072h,067h,065h,06dh,065h,06eh,074h,000h	; da87  II  .Chargement.
	defb 056h,065h,072h,069h,066h,069h,063h,061h,074h,069h,06fh,06eh	; da97  Verification

; ----------------------------------------------------------------------
; DATOS tabla_de_baldosas_3: Treinta y siete bytes detras de los textos del
;   monitor: codigos de baldosa (0x5B-0x5E, 0x2B, 0x7B-0x80, 0x95-0x98,
;   0xB0-0xB3), los mismos rangos que la tabla de 0xA830. Ninguna instruccion
;   los apunta
;   0xdaa3..0xdac8  (37 bytes)
DATA_tabla_de_baldosas_3:
	defb 000h,000h,0b0h,0d7h,0d5h,0c0h,000h,000h,000h,000h,000h,000h,008h,000h,000h,0eeh	; daa3  ................
	defb 0ffh,05bh,05ch,05dh,05eh,000h,02bh,07bh,07ch,07dh,07eh,07fh,080h,095h,096h,097h	; dab3  .[\]^.+{|}~.....
	defb 098h,0b0h,0b1h,0b2h,0b3h	; dac3

; ======================================================================
; CODIGO 0xdac8..0xdace  (6 bytes)
; ======================================================================


L_DAC8:
	call 00072h		;dac8   ; BIOS INIGRP - Switches to SCREEN 2 (high resolution screen with 256*192 pixels)
	jp L_DAD0		;dacb

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0xdace..0xdad0  (2 bytes)
DATA_DACE:
	defb 0ffh,0ffh	; dace

; ======================================================================
; CODIGO 0xdad0..0xdad7  (7 bytes)
; ======================================================================


L_DAD0:
	sub a			;dad0
	ld (09c8fh),a		;dad1
	jp arranca		;dad4

; ----------------------------------------------------------------------
; DATOS tabla_DAD7: 225 bytes; 0x84E4 carga 0xDB00. El principio,
;   0xDAD7-0xDAFF, no lo apunta nadie
;   0xdad7..0xdbb8  (225 bytes)
DATA_tabla_DAD7:
	defb 090h,000h,0cdh,06ch,000h,0c3h,0f0h,0dah,0ffh,0f3h,03eh,000h,0d3h,0a8h,021h,000h	; dad7  ...l......>...!.
	defb 0a0h,011h,032h,09fh,001h,0a0h,014h,0edh,0b0h,097h,032h,09bh,0fch,0c3h,00eh,0c2h	; dae7  ..2.......2.....
	defb 0ffh,0cdh,04dh,000h,03ch,018h,0fah,0ffh,0ffh,00bh,000h,00ch,000h,003h,00ch,002h	; daf7  ..M.<...........
	defb 0c8h,001h,000h,000h,000h,007h,030h,006h,01fh,00ah,000h,009h,010h,008h,010h,00bh	; db07  ......0.........
	defb 000h,00ch,014h,00dh,001h,001h,00fh,000h,0ffh,0feh,0feh,0feh,0feh,006h,018h,0feh	; db17  ................
	defb 0feh,006h,012h,0feh,0feh,0feh,0feh,0feh,0feh,0feh,008h,000h,0feh,0feh,0feh,0feh	; db27  ................
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh,007h,030h,001h,000h,000h,014h,008h,00ah	; db37  .........0......
	defb 006h,018h,0feh,0feh,006h,00ch,0feh,0feh,008h,006h,006h,018h,0feh,0feh,006h,00ch	; db47  ................
	defb 0feh,008h,000h,006h,008h,001h,000h,000h,01eh,007h,030h,00ch,000h,00bh,00ah,009h	; db57  ..........0.....
	defb 010h,003h,000h,002h,0d6h,00dh,00ch,0feh,0feh,0feh,0feh,009h,000h,008h,001h,0feh	; db67  ................
	defb 008h,002h,0feh,008h,003h,0feh,008h,004h,0feh,002h,0b3h,009h,010h,008h,006h,0feh	; db77  ................
	defb 008h,007h,0feh,008h,008h,0feh,002h,0d6h,0feh,008h,009h,0feh,008h,00ah,0feh,0feh	; db87  ................
	defb 0feh,0feh,0feh,0feh,007h,03eh,001h,00fh,000h,0ffh,008h,010h,00ch,001h,00dh,008h	; db97  .....>..........
	defb 0feh,0feh,0feh,0feh,007h,006h,006h,00ch,0feh,009h,000h,00ah,000h,008h,000h,0ffh	; dba7  ................
	defb 0ffh	; dbb7

; ======================================================================
; CODIGO 0xdbb8..0xdbc5  (13 bytes)
; ======================================================================


L_DBB8:
	ld a,010h		;dbb8
	ld (0807ch),a		;dbba
	ld a,001h		;dbbd
	ld (080c7h),a		;dbbf
	jp L_DF48		;dbc2

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xdbc5..0xdbc6  (1 bytes)
DATA_DBC5:
	defb 0c9h	; dbc5

; ======================================================================
; CODIGO 0xdbc6..0xdbdf  (25 bytes)
; ======================================================================


L_DBC6:
	ld hl,0dfe0h		;dbc6
	push hl			;dbc9
	pop de			;dbca
	inc de			;dbcb
	ld bc,00140h		;dbcc
	ldir		;dbcf
	call 0fd9ah		;dbd1   ; BIOS HOOKS - System hooks
	call 00041h		;dbd4   ; BIOS DISSCR - Inhibits the screen display
	ret			;dbd7
L_DBD8:
	call L_8117		;dbd8
	call 00044h		;dbdb   ; BIOS ENASCR - Displays the screen
	ret			;dbde

; ----------------------------------------------------------------------
; DATOS ret_suelto: un unico 0xC9 (RET) al que no llega ningun salto
;   0xdbdf..0xdbe0  (1 bytes)
DATA_DBDF:
	defb 0c9h	; dbdf

; ======================================================================
; CODIGO 0xdbe0..0xdbea  (10 bytes)
; ======================================================================


L_DBE0:
	ld a,(09c8fh)		;dbe0
	or a			;dbe3
	jp z,L_97D0		;dbe4
	jp arranca		;dbe7

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdbea..0xdbf0  (6 bytes)
DATA_DBEA:
	defb 000h,000h,000h,000h,000h,000h	; dbea

; ======================================================================
; CODIGO 0xdbf0..0xdd2e  (318 bytes)
; ======================================================================


L_DBF0:
	call sortea_una_aparicion		;dbf0
	call L_DDC8		;dbf3
	ret			;dbf6
L_DBF7:
	jp nz,L_DE59		;dbf7
	ld a,(0f432h)		;dbfa
	jp baja_una_fila		;dbfd
copia_las_tablas_de_pantalla:		; Se lleva las dos tablas de 0xD000 a la RAM escondida
	di			;dc00   ; Sin interrupciones
	nop			;dc01   ; Seis NOP: aqui habia una conmutacion de slot
	nop			;dc02
	nop			;dc03
	nop			;dc04
	nop			;dc05
	nop			;dc06
	ld hl,0d000h		;dc07   ; Las tablas de pantalla
	ld de,07000h		;dc0a   ; Destino: 0x7000, en la pagina 1 escondida
	ld bc,00900h		;dc0d   ; 0x900 = 2304 bytes: las dos tablas y las fichas
	ldir		;dc10
	nop			;dc12   ; Y otros seis NOP donde estaba la vuelta
	nop			;dc13
	nop			;dc14
	nop			;dc15
	nop			;dc16
	nop			;dc17
	ret			;dc18
monta_la_pantalla_final:		; Rellena a mano un guion de doce bytes en 0xE002 y lo ejecuta
	call 00069h		;dc19   ; BIOS CLRSPR - Initialises all sprites | CLRSPR: borra todos los sprites
	call 0fd9ah		;dc1c   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,0807bh		;dc1f   ; El area de trabajo
	ld (hl),001h		;dc22
	inc hl			;dc24
	inc hl			;dc25
	ld (hl),092h		;dc26
	inc hl			;dc28
	inc hl			;dc29
	nop			;dc2a   ; Un NOP en medio del relleno
	inc hl			;dc2b
	inc hl			;dc2c
	inc hl			;dc2d
	ld (hl),002h		;dc2e
	ld hl,0e002h		;dc30   ; El guion, en la RAM alta
	ld (hl),004h		;dc33
	inc hl			;dc35
	ld (hl),001h		;dc36
	inc hl			;dc38
	ld (hl),005h		;dc39
	inc hl			;dc3b
	ld (hl),000h		;dc3c
	inc hl			;dc3e
	ld (hl),01eh		;dc3f
	inc hl			;dc41
	ld (hl),0ffh		;dc42
	inc hl			;dc44
	ld (hl),001h		;dc45
	inc hl			;dc47
	ld (hl),002h		;dc48
	inc hl			;dc4a
	ld (hl),0c4h		;dc4b
	inc hl			;dc4d
	ld (hl),001h		;dc4e
	ld hl,0e002h		;dc50   ; Y se interpreta
	call interpreta_un_guion		;dc53   ; El interprete de guiones
	ld a,014h		;dc56   ; Numero de sprite
	ld bc,09002h		;dc58
	call pinta_un_sprite		;dc5b
	call pinta_un_sprite		;dc5e
	ld bc,09802h		;dc61
	call pinta_un_sprite		;dc64
	call pinta_un_sprite		;dc67
	ld hl,07020h		;dc6a   ; Dos sprites mas, con sus dos planos
	ld a,014h		;dc6d
	call pinta_dos_planos		;dc6f
	ld hl,070d0h		;dc72
	call pinta_dos_planos		;dc75
	call 0fd9ah		;dc78   ; BIOS HOOKS - System hooks
	ld a,010h		;dc7b   ; El sprite del jugador
	ld bc,0aa01h		;dc7d
	call pinta_un_sprite		;dc80
	call pinta_un_sprite		;dc83
	ld hl,0c156h		;dc86   ; Y su posicion
	ld (08049h),hl		;dc89
	call pinta_al_jugador		;dc8c
	call 0fd9ah		;dc8f   ; BIOS HOOKS - System hooks | Vector de sonido
L_DC92:
	call anima_dos_sprites		;dc92
	call sube_al_jugador		;dc95
	call L_DD30		;dc98
	call L_88D0		;dc9b
	jr L_DC92		;dc9e
anima_dos_sprites:		; Cada 32 pasos mueve dos sprites separados seis pixeles
	ld hl,0807bh		;dca0
	dec (hl)			;dca3   ; Cuenta atras
	ret nz			;dca4
	ld (hl),020h		;dca5   ; Se recarga a 32
	ld a,(0807dh)		;dca7   ; El dibujo en curso
	ld b,a			;dcaa
	ld c,002h		;dcab   ; Banco 2
	ld a,016h		;dcad   ; Numero del primero
	call pinta_un_sprite		;dcaf
	ld a,006h		;dcb2   ; Seis mas para el segundo
	add a,b			;dcb4
	ld b,a			;dcb5
	ld a,01ah		;dcb6   ; Su numero
	call pinta_un_sprite		;dcb8
	ld a,b			;dcbb
	sub 00ah		;dcbc   ; Diez atras
	ld c,a			;dcbe
	ld a,(08082h)		;dcbf   ; El paso
	ld b,a			;dcc2
	ld a,c			;dcc3
	add a,b			;dcc4
	ld (0807dh),a		;dcc5   ; Guarda el dibujo nuevo
	cp 092h		;dcc8   ; Un final de ciclo...
	jr z,L_DCD3		;dcca
	cp 096h		;dccc   ; ...y el otro
	ret nz			;dcce
	ld a,0feh		;dccf
	jr L_DCD5		;dcd1
L_DCD3:
	ld a,002h		;dcd3
L_DCD5:
	ld (08082h),a		;dcd5
	ret			;dcd8
sube_al_jugador:		; Cada seis pasos lo sube una fila hasta 0xFF
	ld hl,08048h		;dcd9
	dec (hl)			;dcdc   ; Cuenta atras
	ret nz			;dcdd
	ld (hl),006h		;dcde   ; Se recarga a 6
	call pinta_al_jugador		;dce0   ; Lo pinta
	ld a,(0804ah)		;dce3   ; La Y
	cp 0ffh		;dce6   ; Ya esta arriba del todo
	jr z,anima_al_jugador_arriba		;dce8
	inc a			;dcea   ; Una fila mas
	ld (0804ah),a		;dceb
	cp 0ffh		;dcee
	ret nz			;dcf0
	ld a,040h		;dcf1   ; Sesenta y cuatro pasos de pausa
	ld (08048h),a		;dcf3
	ld a,010h		;dcf6
	ld bc,0d201h		;dcf8   ; El sprite y el banco
	call pinta_un_sprite		;dcfb
	call pinta_un_sprite		;dcfe
	ld a,0aah		;dd01
	ld (0804bh),a		;dd03   ; Dibujo de partida
	call 0fd9ah		;dd06   ; BIOS HOOKS - System hooks | Vector de sonido
	ret			;dd09
anima_al_jugador_arriba:		; Cambia de dibujo cada dos pasos, ciclo hasta 0xD2
	ld hl,0804ch		;dd0a
	dec (hl)			;dd0d   ; Cuenta atras
	jr nz,L_DD26		;dd0e
	ld (hl),002h		;dd10   ; Se recarga a 2
	dec hl			;dd12
	ld b,(hl)			;dd13
	ld c,001h		;dd14   ; Banco 1
	ld a,010h		;dd16   ; Numero de sprite
	call pinta_un_sprite		;dd18
	call pinta_un_sprite		;dd1b
	ld a,b			;dd1e
	cp 0d2h		;dd1f   ; Final del ciclo
	jr nz,L_DD25		;dd21
	ld a,0aah		;dd23   ; Rebobina
L_DD25:
	ld (hl),a			;dd25
L_DD26:
	ld hl,08049h		;dd26
	inc (hl)			;dd29
	ret nz			;dd2a
	jp L_DD38		;dd2b

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdd2e..0xdd30  (2 bytes)
DATA_DD2E:
	defb 000h,000h	; dd2e

; ======================================================================
; CODIGO 0xdd30..0xdd37  (7 bytes)
; ======================================================================


L_DD30:
	ld hl,0e002h		;dd30
	call interpreta_un_guion		;dd33
	ret			;dd36

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdd37..0xdd38  (1 bytes)
DATA_DD37:
	defb 000h	; dd37

; ======================================================================
; CODIGO 0xdd38..0xdd66  (46 bytes)
; ======================================================================


L_DD38:
	call 00041h		;dd38   ; BIOS DISSCR - Inhibits the screen display
	call 00069h		;dd3b   ; BIOS CLRSPR - Initialises all sprites
	call L_8117		;dd3e
	ld bc,00000h		;dd41
	call espera		;dd44
	call espera		;dd47
	call espera		;dd4a
	call L_8278		;dd4d
	call 00044h		;dd50   ; BIOS ENASCR - Displays the screen
	call L_86FE		;dd53
	jp pone_al_jugador_al_principio		;dd56
sale_si_esta_congelado:		; Con 0x9C8F puesto, se vuelve sin hacer nada
	ex af,af'			;dd59
	ld a,(09c8fh)		;dd5a   ; La bandera que congela el juego
	or a			;dd5d
	jr z,L_DD62		;dd5e   ; A cero: se sigue
	ex af,af'			;dd60   ; Puesta: se vuelve
	ret			;dd61
L_DD62:
	ex af,af'			;dd62
	jp L_8746		;dd63

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdd66..0xdd68  (2 bytes)
DATA_DD66:
	defb 000h,000h	; dd66

; ======================================================================
; CODIGO 0xdd68..0xdd9b  (51 bytes)
; ======================================================================


L_DD68:
	sub a			;dd68
	call 000d8h		;dd69   ; BIOS GTTRIG - Returns current trigger status
	ret nc			;dd6c
	ld a,(09c8fh)		;dd6d
	or a			;dd70
	ret z			;dd71
L_DD72:
	call 00041h		;dd72   ; BIOS DISSCR - Inhibits the screen display
	sub a			;dd75
	ld (09c8fh),a		;dd76
	ld (0809fh),a		;dd79
	call preparativos		;dd7c
	ld bc,00000h		;dd7f
	call espera		;dd82
	call espera		;dd85
	ld sp,0e1ach		;dd88
	call 00044h		;dd8b   ; BIOS ENASCR - Displays the screen
	jp L_8180		;dd8e
L_DD91:
	ld bc,00100h		;dd91
	call espera		;dd94
	call L_DD68		;dd97
	ret			;dd9a

; ----------------------------------------------------------------------
; DATOS datos_DD9B: Nueve bytes entre dos rutinas. Ninguna instruccion los
;   apunta
;   0xdd9b..0xdda4  (9 bytes)
DATA_datos_DD9B:
	defb 03ah,08fh,09ch,0b7h,0c8h,0e1h,0c3h,006h,081h	; dd9b  :........

; ======================================================================
; CODIGO 0xdda4..0xddc6  (34 bytes)
; ======================================================================


L_DDA4:
	ld hl,018a0h		;dda4
	jr L_DDAC		;dda7
L_DDA9:
	ld hl,018bfh		;dda9
L_DDAC:
	ld b,014h		;ddac
	ld de,00020h		;ddae
	ld a,0efh		;ddb1
L_DDB3:
	call 0004dh		;ddb3   ; BIOS WRTVRM - Writes data in VRAM
	add hl,de			;ddb6
	djnz L_DDB3		;ddb7
	ret			;ddb9
L_DDBA:
	call prepara_al_que_cae		;ddba
	jp L_DDA4		;ddbd
L_DDC0:
	call L_9E18		;ddc0
	jp L_DDA9		;ddc3

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0xddc6..0xddc8  (2 bytes)
DATA_DDC6:
	defb 0ffh,0ffh	; ddc6

; ======================================================================
; CODIGO 0xddc8..0xddee  (38 bytes)
; ======================================================================


L_DDC8:
	ld a,(09c8fh)		;ddc8
	or a			;ddcb
	ret nz			;ddcc
	ld a,(0e053h)		;ddcd
	ld hl,08087h		;ddd0
	cp (hl)			;ddd3
	ret z			;ddd4
	call 0fd9ah		;ddd5   ; BIOS HOOKS - System hooks
	ld hl,080cah		;ddd8
	ld b,004h		;dddb
L_DDDD:
	push bc			;dddd
	push hl			;ddde
	call monta_al_que_baja		;dddf
	pop hl			;dde2
	ld bc,0000ch		;dde3
	add hl,bc			;dde6
	pop bc			;dde7
	djnz L_DDDD		;dde8
	call 0fd9ah		;ddea   ; BIOS HOOKS - System hooks
	ret			;dded

; ----------------------------------------------------------------------
; DATOS relleno_ff: todo el hueco es 0xFF
;   0xddee..0xddf0  (2 bytes)
DATA_DDEE:
	defb 0ffh,0ffh	; ddee

; ======================================================================
; CODIGO 0xddf0..0xdf26  (310 bytes)
; ======================================================================


monta_al_que_baja:		; Copia doce bytes de ficha y sortea donde aparece
	ld (0f42eh),hl		;ddf0   ; La posicion
	ld de,0f430h		;ddf3   ; El area de trabajo de 0xF430
	ld bc,0000ch		;ddf6   ; Doce bytes
	ldir		;ddf9
	call L_DF87		;ddfb
	ld a,(hl)			;ddfe   ; El primer campo
	or a			;ddff
	jp nz,L_DE73		;de00   ; Si ya esta en marcha, nada
	ld (hl),001h		;de03   ; Estado 1
	inc hl			;de05
	ld (hl),001h		;de06
	inc hl			;de08
	call L_9D78		;de09   ; El dado
	add a,008h		;de0c   ; Ocho de base
	ld (hl),a			;de0e
	inc hl			;de0f
	inc hl			;de10
	inc hl			;de11
	inc hl			;de12
	inc hl			;de13
	ld (hl),05bh		;de14   ; El dibujo
	inc hl			;de16
	ld (hl),001h		;de17
	inc hl			;de19
	inc hl			;de1a
	inc hl			;de1b
	ld (hl),020h		;de1c
	call 0fd9ah		;de1e   ; BIOS HOOKS - System hooks | Vector de sonido
	ld hl,01860h		;de21   ; La fila de partida
	ld (0f433h),hl		;de24
	call L_9D78		;de27   ; Otro dado
	cp 004h		;de2a
	nop			;de2c   ; Tres NOP: aqui habia una comprobacion
	nop			;de2d
	nop			;de2e
	ld a,r		;de2f   ; El registro de refresco, de dado
	and 01ch		;de31   ; De 0 a 28
	inc a			;de33
	add a,l			;de34
	ld l,a			;de35
	ld (0f433h),hl		;de36
	call 0fd9ah		;de39   ; BIOS HOOKS - System hooks | Vector de sonido
dibuja_dos_por_dos_en_vram:		; Escribe las cuatro casillas del bloque directamente en la VRAM
	ld hl,(0f433h)		;de3c   ; La posicion
	ld a,(0f437h)		;de3f   ; La primera baldosa
	ld de,0001fh		;de42   ; 0x1F: hasta la fila de abajo
	call L_DE68		;de45
	inc hl			;de48
	inc a			;de49   ; La siguiente, de dos en dos
	inc a			;de4a
	call L_DE68		;de4b
	add hl,de			;de4e
	dec a			;de4f   ; Y la de la fila de abajo
	call L_DE68		;de50
	inc hl			;de53
	inc a			;de54
	inc a			;de55
	call L_DE68		;de56
L_DE59:
	ld de,(0f42eh)		;de59
	ld hl,0f430h		;de5d
	ld bc,0000ch		;de60
	ldir		;de63
	jp 0fd9ah		;de65   ; BIOS HOOKS - System hooks
L_DE68:
	ld b,a			;de68
	call 0004ah		;de69   ; BIOS RDVRM - Reads the content of VRAM
	or a			;de6c
	ld a,b			;de6d
	ret nz			;de6e
	call 0004dh		;de6f   ; BIOS WRTVRM - Writes data in VRAM
	ret			;de72
L_DE73:
	ld hl,0f431h		;de73
	dec (hl)			;de76
	nop			;de77
	jp L_DBF7		;de78
baja_una_fila:		; Con el estado 1, baja una fila y mira que hay dos filas mas abajo
	ld (hl),a			;de7b
	ld a,(0f430h)		;de7c   ; El estado
	dec a			;de7f   ; Solo el 1
	jr nz,avanza_de_lado		;de80
	call borra_las_cuatro		;de82
	ld hl,(0f433h)		;de85
	ld de,00020h		;de88   ; Una fila
	add hl,de			;de8b
	ld (0f433h),hl		;de8c
	call dibuja_dos_por_dos_en_vram		;de8f   ; Se redibuja
	ld hl,(0f433h)		;de92
	ld de,00040h		;de95   ; 0x40 = dos filas
	add hl,de			;de98
	call 0004ah		;de99   ; BIOS RDVRM - Reads the content of VRAM | Lee la casilla
	cp 00ah		;de9c   ; Por debajo de 0x0A esta libre
	jp nc,L_DE59		;de9e
	jr elige_el_lado		;dea1
borra_las_cuatro:		; Borra las cuatro casillas de la posicion de 0xF433
	ld hl,(0f433h)		;dea3   ; La posicion
	ld de,0001fh		;dea6   ; 0x1F: hasta la fila de abajo
	call L_DEB5		;dea9   ; La primera
	inc hl			;deac
	call L_DEB5		;dead   ; La de al lado
	add hl,de			;deb0
	call L_DEB5		;deb1   ; Y las dos de abajo
	inc hl			;deb4
L_DEB5:
	nop			;deb5
	call 0004ah		;deb6   ; BIOS RDVRM - Reads the content of VRAM
	cp 05bh		;deb9
	ret c			;debb
	cp 067h		;debc
	ret nc			;debe
	sub a			;debf
	call 0004dh		;dec0   ; BIOS WRTVRM - Writes data in VRAM
	ret			;dec3
elige_el_lado:		; Al chocar, sortea si sigue por la izquierda o por la derecha
	or a			;dec4   ; Casilla vacia: sigue
	jp z,L_DE59		;dec5
	call L_B410		;dec8
	call 0fd9ah		;decb   ; BIOS HOOKS - System hooks | Vector de sonido
	ld a,002h		;dece
	ld (0f430h),a		;ded0   ; Estado 2
	call L_9D78		;ded3   ; El dado
	cp 008h		;ded6   ; Mitad y mitad
	ld hl,00001h		;ded8   ; A la derecha...
	jr nc,L_DEE0		;dedb
	ld hl,0ffffh		;dedd   ; ...o a la izquierda
L_DEE0:
	ld (0f435h),hl		;dee0
	call L_DE59		;dee3
	ret			;dee6
avanza_de_lado:		; Con el estado 2, se mueve el paso guardado y mira los dos topes
	dec a			;dee7   ; Solo si el estado es 2
	jp nz,0dfd2h		;dee8
	call borra_las_cuatro		;deeb
	ld hl,(0f433h)		;deee
	ld de,(0f435h)		;def1   ; El paso
	add hl,de			;def5
	ld (0f433h),hl		;def6   ; Guarda la posicion
	call dibuja_dos_por_dos_en_vram		;def9   ; Se redibuja
	ld hl,(0f433h)		;defc
	ld a,l			;deff
	ld hl,0e043h		;df00   ; El primer tope...
	cp (hl)			;df03
	jr z,L_DF0B		;df04
	inc hl			;df06   ; ...y el segundo
	cp (hl)			;df07
	jp nz,L_DE59		;df08
L_DF0B:
	call 0fd9ah		;df0b   ; BIOS HOOKS - System hooks
	call borra_las_cuatro		;df0e
	sub a			;df11
	ld (0f430h),a		;df12
	jp L_DE59		;df15
L_DF18:
	ld hl,080cah		;df18
	ld b,030h		;df1b
L_DF1D:
	ld (hl),000h		;df1d
	inc hl			;df1f
	djnz L_DF1D		;df20
	call 0fd9ah		;df22   ; BIOS HOOKS - System hooks
	ret			;df25

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdf26..0xdf28  (2 bytes)
DATA_DF26:
	defb 000h,000h	; df26

; ======================================================================
; CODIGO 0xdf28..0xdf2f  (7 bytes)
; ======================================================================


L_DF28:
	call L_9E18		;df28
	call L_DF18		;df2b
	ret			;df2e

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdf2f..0xdf30  (1 bytes)
DATA_DF2F:
	defb 000h	; df2f

; ======================================================================
; CODIGO 0xdf30..0xdf46  (22 bytes)
; ======================================================================


L_DF30:
	call prepara_una_ficha		;df30
	ld hl,0df18h		;df33
	jr L_DF3E		;df36
L_DF38:
	call L_B3F8		;df38
	ld hl,0ddc8h		;df3b
L_DF3E:
	ld a,(0804ah)		;df3e
	cp 060h		;df41
	ret nc			;df43
	push hl			;df44
	ret			;df45

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xdf46..0xdf48  (2 bytes)
DATA_DF46:
	defb 000h,000h	; df46

; ======================================================================
; CODIGO 0xdf48..0xdfc1  (121 bytes)
; ======================================================================


L_DF48:
	ld a,007h		;df48
	ld (0805bh),a		;df4a
	ld a,000h		;df4d
	ld (080c8h),a		;df4f
	call 0fd9ah		;df52   ; BIOS HOOKS - System hooks
	jp 0fd9ah		;df55   ; BIOS HOOKS - System hooks
L_DF58:
	call L_8990		;df58
	call mira_el_suelo		;df5b
	call L_BF88		;df5e
	ret			;df61
sale_si_esta_congelado_2:		; El gemelo de 0xDD59, que ademas devuelve 0x8064
	ld a,(09c8fh)		;df62   ; La bandera que congela el juego
	or a			;df65
	ld hl,08064h		;df66   ; El tampon que se devuelve
	ret z			;df69   ; A cero: se devuelve normal
	pop hl			;df6a   ; Puesta: se sale por dos niveles
	ret			;df6b
L_DF6C:
	ld b,002h		;df6c
L_DF6E:
	push bc			;df6e
	call L_9164		;df6f
	pop bc			;df72
	djnz L_DF6E		;df73
	ret			;df75
L_DF76:
	out (099h),a		;df76
	push af			;df78
	ld a,087h		;df79
	out (099h),a		;df7b
	pop af			;df7d
	push hl			;df7e
	ld hl,01b03h		;df7f
	call 0004dh		;df82   ; BIOS WRTVRM - Writes data in VRAM
	pop hl			;df85
	ret			;df86
L_DF87:
	ld hl,(0f433h)		;df87
	ld b,002h		;df8a
	ld de,0001fh		;df8c
prueba_las_cuatro:		; Mira las cuatro casillas del bloque de dos por dos
	call mira_si_esta_en_la_trampa		;df8f   ; La primera
	inc hl			;df92
	call mira_si_esta_en_la_trampa		;df93   ; La de al lado
	add hl,de			;df96   ; La fila de abajo
	djnz prueba_las_cuatro		;df97
	ld hl,0f430h		;df99   ; Y devuelve el area de trabajo
	ret			;df9c
mira_si_esta_en_la_trampa:		; Solo las baldosas de 0x7B a 0x7E cuentan
	call 0004ah		;df9d   ; BIOS RDVRM - Reads the content of VRAM | Lee la casilla
	cp 07bh		;dfa0   ; Por debajo de 0x7B no vale
	ret c			;dfa2
	cp 07fh		;dfa3   ; Y de 0x7F para arriba tampoco
	ret nc			;dfa5
	call L_A0D8		;dfa6
	ld a,003h		;dfa9   ; Estado 3
	ld (0f430h),a		;dfab
	ld a,020h		;dfae   ; Treinta y dos pasos de cuenta
	ld (0f431h),a		;dfb0
	call borra_las_cuatro		;dfb3
	ld a,063h		;dfb6   ; El dibujo de la trampa
	ld (0f437h),a		;dfb8
	call dibuja_dos_por_dos_en_vram		;dfbb
	pop hl			;dfbe   ; Dos POP: no se vuelve a quien llamo, sino dos niveles mas arriba
	pop hl			;dfbf
	ret			;dfc0

; ----------------------------------------------------------------------
; DATOS datos_DFC1: Diecisiete bytes de cola del bloque. Ninguna instruccion
;   los apunta
;   0xdfc1..0xdfd2  (17 bytes)
DATA_datos_DFC1:
	defb 0cdh,04dh,000h,019h,03dh,0cdh,04dh,000h,03ch,03ch,023h,0cdh,04dh,000h,0e1h,0e1h,0c9h	; dfc1  .M..=.M.<<#.M....

; ----------------------------------------------------------------------
; DATOS relleno_cero: Catorce ceros hasta el tampon del final
;   0xdfd2..0xdfe0  (14 bytes)
DATA_DFD2:
	defb 03dh,0c2h,01ch,0dah,0cdh,0a3h,0deh,0cdh,02eh,0dah,000h,0c3h,0e8h,0d9h	; dfd2  =.............

; ----------------------------------------------------------------------
; DATOS tampon_final: Los ultimos 32 bytes del bloque, a cero en la cinta. Se
;   usan de tampon: 0xBE5B y 0xDBC6 cargan 0xDFE0 en HL y 0x94B5 y 0xA1B5
;   cargan 0xDFFF en DE
;   0xdfe0..0xe000  (32 bytes)
DATA_tampon_final:
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; dfe0  ................
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; dff0  ................
