; ==========================================================================
; DEMONIA - MSX - pantalla de carga en SCREEN 3
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x0a000


; ----------------------------------------------------------------------
; DATOS pantalla_multicolor: La imagen de SCREEN 3 entera, 1536 bytes = 64x48
;   puntos de 4 bits. Se sube a la VRAM desde 0x0000 con el LDIRVM de 0xA60F
;   0xa000..0xa600  (1536 bytes)

; ----------------------------------------------------------------------
; ====================================================================
; TROZO 1 DE LA CARGA: LA PANTALLA EN SCREEN 3
; ====================================================================
; Lo primero que se ve. Son 1536 bytes que se vuelcan tal cual al
; principio de la VRAM despues de poner SCREEN 3, el modo multicolor
; de 64x48 puntos gordos. 0x600 bytes es exactamente lo que ocupa ese
; modo, asi que el bloque es la pantalla entera y no hay nada que
; interpretar: cada byte son dos puntos, el nibble alto a la izquierda.
; Este trozo no toca la RAM escondida: se queda donde la cinta lo deja.
; ----------------------------------------------------------------------
DATA_pantalla_multicolor:
	defb 011h,011h,011h,011h,011h,011h,01fh,011h,011h,011h,011h,011h,011h,011h,011h,011h,0bbh,06ah,01ah,01ah,01ah,01ah,0abh,066h,0bbh,066h,011h,011h,011h,011h,0bbh,066h	; a000  .................j.....f.f.....f
	defb 011h,0b1h,0b1h,0b1h,0b1h,0b1h,061h,011h,01bh,01bh,01bh,01bh,01bh,01bh,01bh,016h,0bbh,066h,011h,0aah,066h,011h,0bbh,066h,0a1h,061h,011h,011h,011h,011h,0a1h,061h	; a020  ......a..........f..f..f.a.....a
	defb 01bh,01bh,01bh,01bh,01ah,01ah,01ah,016h,011h,0b1h,06bh,016h,011h,011h,011h,011h,01ah,0aah,06ah,01ah,01ah,01ah,01ah,016h,011h,011h,011h,011h,011h,011h,011h,011h	; a040  ..........k.......j.............
	defb 01bh,0b6h,0b1h,0b1h,0b1h,0b1h,06bh,016h,0bah,066h,011h,011h,011h,011h,0bbh,066h,011h,0a1h,0a1h,0a1h,0a1h,0a1h,061h,011h,01bh,01bh,01bh,01bh,01bh,01bh,01bh,016h	; a060  ......k..f.....f......a.........
	defb 011h,0b1h,0b1h,06bh,016h,011h,011h,011h,01ah,01ah,01ah,01ah,0aah,0aah,06ah,016h,011h,011h,011h,011h,011h,011h,011h,011h,0bbh,06bh,01bh,01bh,01bh,01bh,0bbh,066h	; a080  ...k..........j..........k.....f
	defb 0a1h,061h,011h,011h,011h,011h,0a1h,061h,011h,01bh,01bh,01bh,01bh,01bh,01bh,016h,0bbh,066h,011h,0bbh,066h,011h,011h,011h,0b1h,06ah,01ah,0bah,06ah,01ah,01ah,016h	; a0a0  .a.....a.........f..f....j..j...
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,019h,099h,069h,019h,019h,099h,066h,011h,011h,011h,011h,011h,011h,091h,061h,011h	; a0c0  ..................i...f.......a.
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,01fh	; a0e0  ................................
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h	; a100  ................................
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,016h,066h,066h,066h,011h,011h,066h,066h,066h,066h,066h,066h	; a120  .....................fff..ffffff
	defb 011h,011h,011h,066h,066h,066h,066h,066h,011h,011h,011h,066h,066h,061h,069h,091h,011h,011h,011h,011h,061h,011h,011h,091h,01fh,011h,011h,011h,011h,011h,011h,011h	; a140  ...fffff...ffai.....a...........
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,01fh,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h	; a160  ................................
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,0f1h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,041h,044h	; a180  ..............................AD
	defb 011h,011h,011h,011h,011h,011h,044h,044h,011h,011h,011h,011h,011h,011h,041h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,0f1h,011h,011h,011h,011h,011h	; a1a0  ......DD......A.................
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,018h,011h,011h,01eh,01eh,0e8h,018h,088h,066h,011h,0feh,066h,086h,018h,088h,066h,011h,068h	; a1c0  ......................f..f...f.h
	defb 0e1h,0feh,06fh,0eeh,08eh,086h,086h,086h,011h,0e1h,0f1h,0efh,0eeh,0e1h,01fh,011h,011h,011h,011h,011h,0e1h,011h,0f1h,011h,011h,011h,011h,011h,011h,011h,011h,011h	; a1e0  ..o.............................
	defb 011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,0f1h,011h,011h,011h,011h,011h,011h,011h	; a200  ................................
	defb 011h,011h,011h,011h,011h,011h,011h,016h,011h,011h,016h,011h,016h,011h,011h,068h,066h,066h,066h,066h,016h,016h,066h,011h,066h,066h,066h,066h,066h,061h,066h,011h	; a220  ...............hffff..f.fffffaf.
	defb 066h,066h,066h,061h,061h,061h,016h,099h,069h,066h,066h,069h,066h,061h,011h,088h,091h,061h,061h,061h,061h,011h,011h,081h,011h,011h,011h,011h,011h,011h,011h,011h	; a240  fffaaa..iffifa...aaaa...........
	defb 011h,011h,011h,011h,091h,018h,011h,018h,011h,011h,081h,091h,098h,098h,089h,098h,011h,011h,011h,011h,061h,061h,061h,061h,011h,01fh,0f1h,011h,011h,01fh,0f1h,011h	; a260  ....................aaaa........
	defb 011h,011h,017h,01eh,011h,011h,011h,011h,011h,017h,075h,0e5h,0e1h,011h,011h,0f1h,017h,075h,051h,011h,011h,011h,011h,011h,075h,051h,011h,011h,011h,011h,011h,01fh	; a280  ..........u......uQ.....uQ......
	defb 041h,041h,011h,011h,011h,011h,011h,0eeh,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,018h,011h,011h,011h,011h,014h,077h,011h,088h	; a2a0  AA...........................w..
	defb 011h,011h,011h,047h,077h,074h,014h,011h,011h,011h,047h,074h,044h,044h,041h,044h,011h,041h,044h,041h,011h,014h,011h,011h,068h,016h,011h,014h,044h,044h,044h,011h	; a2c0  ...Gwt....GtDDAD.ADA....h...DDD.
	defb 061h,011h,014h,044h,044h,041h,017h,077h,011h,044h,041h,041h,017h,074h,074h,044h,011h,041h,044h,014h,044h,044h,041h,041h,011h,011h,011h,011h,011h,011h,033h,022h	; a2e0  a..DDA.w.DAA.ttD.AD.DDAA......3"
	defb 011h,011h,011h,011h,011h,011h,011h,011h,0f1h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,011h,016h,016h,061h,066h,066h	; a300  .............................aff
	defb 016h,016h,061h,061h,066h,011h,016h,066h,068h,068h,066h,016h,016h,016h,016h,016h,099h,099h,089h,089h,089h,089h,069h,099h,099h,099h,099h,098h,089h,069h,068h,068h	; a320  ..aaf..fhhf...........i......ihh
	defb 099h,099h,099h,099h,099h,099h,089h,099h,099h,099h,099h,098h,098h,098h,098h,098h,098h,099h,069h,069h,068h,066h,066h,066h,011h,061h,086h,098h,099h,089h,089h,068h	; a340  ..................iihfff.a.....h
	defb 018h,018h,011h,061h,061h,061h,098h,089h,096h,096h,096h,098h,098h,089h,069h,098h,011h,011h,011h,061h,061h,061h,061h,061h,011h,01fh,011h,011h,011h,011h,033h,022h	; a360  ...aaa........i....aaaaa......3"
	defb 0ffh,011h,011h,011h,011h,013h,032h,02ch,011h,011h,011h,011h,011h,033h,02ch,0cch,011h,01fh,01fh,01fh,0cfh,03fh,0cfh,0cch,0feh,0eeh,0e1h,0eeh,0eeh,0eeh,0eeh,0e2h	; a380  ......2,.....3,......?..........
	defb 01eh,011h,01eh,01eh,01eh,0eeh,0e2h,022h,0e1h,0e1h,0e1h,0e3h,0e2h,0e2h,02ch,022h,081h,018h,011h,032h,022h,02ch,0cch,022h,088h,011h,018h,021h,022h,0cch,022h,02ch	; a3a0  ......."......,"...2",."...!".",
	defb 081h,081h,011h,02ch,02ch,0cch,022h,0cch,041h,013h,022h,0cch,0cch,0c2h,022h,0cch,011h,031h,018h,011h,018h,011h,014h,014h,044h,018h,088h,081h,018h,014h,011h,044h	; a3c0  ...,,.".A."..."..1......D......D
	defb 011h,088h,088h,081h,011h,044h,011h,017h,044h,014h,014h,014h,041h,014h,075h,055h,011h,014h,014h,014h,044h,044h,054h,051h,0cch,012h,012h,012h,012h,012h,01ch,0cch	; a3e0  .....D..D...A.uU....DDTQ........
	defb 011h,011h,011h,011h,011h,033h,022h,0cch,011h,011h,011h,011h,011h,033h,022h,0cch,011h,011h,01fh,011h,033h,022h,022h,0cch,016h,011h,011h,011h,033h,022h,0cch,0cch	; a400  .....3"......3".....3"".....3"..
	defb 061h,011h,011h,031h,022h,022h,0c1h,016h,016h,068h,068h,068h,016h,016h,011h,066h,099h,099h,096h,099h,089h,066h,016h,061h,068h,068h,089h,099h,099h,099h,069h,011h	; a420  a..1""...hhh...f.....f.ahh....i.
	defb 099h,098h,098h,098h,098h,099h,099h,099h,088h,086h,086h,061h,081h,081h,081h,011h,061h,061h,012h,022h,0cch,0cch,0cch,033h,066h,011h,022h,022h,0cch,0cch,0cch,033h	; a440  ...........a....aa."...3f.""...3
	defb 068h,066h,011h,022h,0cch,0cch,0cch,022h,088h,066h,011h,022h,0cch,0cch,0cch,02ch,012h,012h,022h,022h,0cch,0cch,0cch,0cch,022h,022h,022h,02ch,0cch,0cch,0cch,0cch	; a460  hf."...".f."...,..""....""",....
	defb 0cch,022h,022h,0cch,0cch,0cch,0c3h,033h,0cch,022h,02ch,0cch,0cch,0c3h,033h,022h,022h,0cch,0cch,0c3h,0c3h,033h,033h,02ch,02ch,0cch,03ch,033h,033h,032h,02ch,02ch	; a480  .""....3.",...3""....33,,.<332,,
	defb 0cch,0cch,0cch,033h,033h,0cch,0cch,0cch,0cch,0cch,033h,03ch,03ch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0c2h,0cch,0cch,0cch,0cch	; a4a0  ...33.....3<<...................
	defb 0cch,022h,022h,02ch,0cch,0cch,0cch,0cch,0cch,022h,022h,0cch,0cch,0cch,0cch,0cch,014h,014h,014h,0c1h,0c2h,0c2h,0c1h,014h,041h,017h,017h,017h,017h,014h,044h,084h	; a4c0  ."",....."".............A.....D.
	defb 017h,075h,045h,055h,054h,054h,054h,041h,054h,054h,044h,041h,011h,011h,016h,016h,041h,01ch,01ch,01ch,061h,066h,061h,061h,0cch,0cch,0cch,0c2h,022h,01ch,0cch,0cch	; a4e0  .uEUTTTATTDA....A...afaa...."...
	defb 0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0c1h,0c1h,0c1h,0c1h,0c1h,0cch	; a500  ................................
	defb 016h,016h,016h,066h,066h,066h,011h,011h,066h,066h,066h,066h,066h,066h,066h,016h,066h,066h,086h,086h,089h,098h,068h,011h,061h,066h,066h,066h,066h,096h,086h,089h	; a520  ...fff..fffffff.ff....h.affff...
	defb 011h,066h,066h,066h,066h,066h,066h,066h,011h,011h,066h,066h,066h,061h,061h,061h,022h,01ch,01ch,01ch,01ch,01ch,0cch,0cch,022h,0cch,0cch,0cch,0cch,0cch,0cch,0cch	; a540  .fffffff..fffaaa".......".......
	defb 02ch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0c2h,0cch,0cch,0cch,0cch,0cch,0c2h,0c2h,022h,0cch,022h,0cch,0cch,0cch,022h,022h,022h	; a560  ,......................"."..."""
	defb 0c2h,02ch,0cch,0cch,0cch,022h,022h,022h,0cch,0cch,0cch,0cch,022h,022h,022h,022h,022h,0cch,0cch,0cch,022h,022h,022h,022h,0cch,0cch,0cch,0cch,022h,022h,022h,022h	; a580  .,..."""...."""""...""""....""""
	defb 0cch,0cch,0cch,0c2h,022h,022h,0cch,0cch,0cch,0cch,0cch,022h,022h,0cch,0cch,0cch,0cch,0cch,0cch,022h,022h,0cch,0cch,0cch,0cch,0cch,0cch,022h,022h,0c1h,0c1h,0cch	; a5a0  ...."".....""......""......""...
	defb 0cch,0cch,0cch,021h,016h,066h,011h,022h,0cch,0cch,011h,066h,088h,066h,011h,022h,018h,018h,088h,088h,086h,061h,012h,022h,088h,088h,081h,061h,066h,011h,022h,022h	; a5c0  ...!.f."...f.f.".....a."...af.""
	defb 041h,011h,021h,0cch,01ch,0cch,0cch,02ch,066h,066h,011h,022h,0c2h,0cch,0cch,0cch,061h,01ch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch,0cch	; a5e0  A.!....,ff."....a...............

; ======================================================================
; CODIGO 0xa600..0xa613  (19 bytes)
; ======================================================================


arranca_trozo1:		; Direccion de ejecucion que pide la entrada 1 de la tabla de 0x8180
	call 000c0h		;a600   ; BIOS BEEP - Generates beep | Un pitido para avisar de que este trozo ya esta
	call 00075h		;a603   ; BIOS INIMLT - Switches to SCREEN 3 (multi-color screen 64*48 pixels) | SCREEN 3, el modo multicolor de 64x48
	ld hl,0a000h		;a606   ; Origen: el propio bloque, que ya esta en su sitio
	ld de,00000h		;a609   ; Destino: el principio de la VRAM, donde SCREEN 3 tiene sus puntos
	ld bc,00600h		;a60c   ; 0x600 bytes, la pantalla completa
	call 0005ch		;a60f   ; BIOS LDIRVM - Block transfers to VRAM from memory
	ret			;a612   ; Y vuelve al cargador de 0x8208 a por el trozo siguiente

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0xa613..0xa619  (6 bytes)
DATA_A613:
	defb 000h,000h,000h,000h,000h,000h	; a613
