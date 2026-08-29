; ==========================================================================
; DEMONIA - MSX - la musica: partitura y reproductor
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x07900


; ----------------------------------------------------------------------
; DATOS melodia_entradilla: 50 pasos de 4 bytes que solo suenan la primera
;   vez: el puntero arranca aqui (0xC009) pero el bucle de rebobinado de
;   0x7FA5 ya no vuelve. Los 50 son el mismo compas de 4 pasos repetido doce
;   veces y medio
;   0x7900..0x79c8  (200 bytes)

; ----------------------------------------------------------------------
; ====================================================================
; LA MUSICA: PARTITURA Y REPRODUCTOR
; ====================================================================
; Mil setecientos sesenta y ocho bytes en la pagina 1 escondida, y los
; unicos de toda la RAM de debajo de la ROM que son CODIGO: el resto de
; los 26 KB escondidos son dibujos y mapas.
;
; La partitura es una lista de pasos de cuatro bytes. El reproductor
; los escribe en los registros 3, 2, 5 y 4 del PSG, que son el tono de
; los canales B y C: primero la parte gruesa y luego la fina de cada
; uno. Asi que cada paso es "canal B en este periodo, canal C en este
; otro". El primer paso, 02 A7 01 53, da periodo 679 en B y 339 en C,
; que con el reloj del PSG del MSX (3.579.545/16 Hz) son 329,5 Hz y
; 659,1 Hz: la misma nota con una octava de diferencia.
;
; El puntero arranca en 0x7900 (lo pone 0xC009) pero al llegar al 0xFF
; vuelve a 0x79C8, no a 0x7900. O sea que los primeros 200 bytes son
; una entradilla que solo suena una vez y el bucle es lo de despues.
; ----------------------------------------------------------------------
DATA_melodia_entradilla:
	defb 002h,0a7h,001h,053h	; 7900
	defb 002h,081h,001h,040h	; 7904
	defb 002h,0a7h,001h,053h	; 7908
	defb 002h,0fah,001h,07dh	; 790c
	defb 002h,0a7h,001h,053h	; 7910
	defb 002h,081h,001h,040h	; 7914
	defb 002h,0a7h,001h,053h	; 7918
	defb 002h,0fah,001h,07dh	; 791c
	defb 002h,0a7h,001h,053h	; 7920
	defb 002h,081h,001h,040h	; 7924
	defb 002h,0a7h,001h,053h	; 7928
	defb 002h,0fah,001h,07dh	; 792c
	defb 002h,0a7h,001h,053h	; 7930
	defb 002h,081h,001h,040h	; 7934
	defb 002h,0a7h,001h,053h	; 7938
	defb 002h,0fah,001h,07dh	; 793c
	defb 002h,0a7h,001h,053h	; 7940
	defb 002h,081h,001h,040h	; 7944
	defb 002h,0a7h,001h,053h	; 7948
	defb 002h,0fah,001h,07dh	; 794c
	defb 002h,0a7h,001h,053h	; 7950
	defb 002h,081h,001h,040h	; 7954
	defb 002h,0a7h,001h,053h	; 7958
	defb 002h,0fah,001h,07dh	; 795c
	defb 002h,0a7h,001h,053h	; 7960
	defb 002h,081h,001h,040h	; 7964
	defb 002h,0a7h,001h,053h	; 7968
	defb 002h,0fah,001h,07dh	; 796c
	defb 002h,0a7h,001h,053h	; 7970
	defb 002h,081h,001h,040h	; 7974
	defb 002h,0a7h,001h,053h	; 7978
	defb 002h,0fah,001h,07dh	; 797c
	defb 002h,0a7h,001h,053h	; 7980
	defb 002h,081h,001h,040h	; 7984
	defb 002h,0a7h,001h,053h	; 7988
	defb 002h,0fah,001h,07dh	; 798c
	defb 002h,0a7h,001h,053h	; 7990
	defb 002h,081h,001h,040h	; 7994
	defb 002h,0a7h,001h,053h	; 7998
	defb 002h,0fah,001h,07dh	; 799c
	defb 002h,0a7h,001h,053h	; 79a0
	defb 002h,081h,001h,040h	; 79a4
	defb 002h,0a7h,001h,053h	; 79a8
	defb 002h,0fah,001h,07dh	; 79ac
	defb 002h,0a7h,001h,053h	; 79b0
	defb 002h,081h,001h,040h	; 79b4
	defb 002h,0a7h,001h,053h	; 79b8
	defb 002h,0fah,001h,07dh	; 79bc
	defb 002h,0a7h,001h,053h	; 79c0
	defb 000h,000h,000h,000h	; 79c4

; ----------------------------------------------------------------------
; DATOS melodia_bucle: La melodia que se repite, en pasos de 4 bytes (tono
;   grueso y fino del canal B, y del canal C). Termina con un 0xFF que hace
;   rebobinar a 0x79C8
;   0x79c8..0x7f90  (1480 bytes)
DATA_melodia_bucle:
	defb 002h,0a7h,000h,000h	; 79c8
	defb 002h,05dh,000h,000h	; 79cc
	defb 002h,03bh,000h,000h	; 79d0
	defb 002h,01bh,000h,000h	; 79d4
	defb 001h,0fdh,000h,000h	; 79d8
	defb 001h,0e0h,000h,000h	; 79dc
	defb 001h,0c5h,000h,000h	; 79e0
	defb 001h,0ach,000h,000h	; 79e4
	defb 001h,094h,000h,000h	; 79e8
	defb 001h,07dh,000h,000h	; 79ec
	defb 001h,068h,000h,000h	; 79f0
	defb 001h,053h,001h,094h	; 79f4
	defb 001h,053h,001h,094h	; 79f8
	defb 001h,068h,001h,094h	; 79fc
	defb 001h,068h,001h,094h	; 7a00
	defb 001h,053h,001h,094h	; 7a04
	defb 001h,053h,001h,094h	; 7a08
	defb 001h,068h,001h,094h	; 7a0c
	defb 001h,068h,001h,094h	; 7a10
	defb 001h,053h,001h,094h	; 7a14
	defb 001h,053h,001h,094h	; 7a18
	defb 001h,0ach,001h,094h	; 7a1c
	defb 001h,0ach,001h,094h	; 7a20
	defb 001h,07dh,001h,094h	; 7a24
	defb 001h,07dh,001h,094h	; 7a28
	defb 001h,053h,001h,094h	; 7a2c
	defb 001h,053h,000h,000h	; 7a30
	defb 001h,040h,001h,068h	; 7a34
	defb 001h,040h,001h,068h	; 7a38
	defb 001h,053h,001h,0e0h	; 7a3c
	defb 001h,053h,001h,0e0h	; 7a40
	defb 001h,040h,000h,000h	; 7a44
	defb 001h,040h,000h,000h	; 7a48
	defb 001h,053h,000h,000h	; 7a4c
	defb 001h,053h,000h,000h	; 7a50
	defb 001h,040h,000h,000h	; 7a54
	defb 001h,040h,000h,000h	; 7a58
	defb 001h,00dh,000h,000h	; 7a5c
	defb 001h,00dh,000h,000h	; 7a60
	defb 000h,0feh,000h,000h	; 7a64
	defb 000h,0feh,000h,000h	; 7a68
	defb 001h,040h,000h,000h	; 7a6c
	defb 001h,040h,000h,000h	; 7a70
	defb 001h,053h,001h,094h	; 7a74
	defb 001h,053h,001h,094h	; 7a78
	defb 001h,068h,001h,094h	; 7a7c
	defb 001h,068h,001h,094h	; 7a80
	defb 001h,053h,001h,094h	; 7a84
	defb 001h,053h,001h,094h	; 7a88
	defb 001h,068h,001h,094h	; 7a8c
	defb 001h,068h,001h,094h	; 7a90
	defb 001h,053h,001h,094h	; 7a94
	defb 001h,053h,001h,094h	; 7a98
	defb 001h,0ach,001h,094h	; 7a9c
	defb 001h,0ach,001h,094h	; 7aa0
	defb 001h,07dh,001h,094h	; 7aa4
	defb 001h,07dh,001h,094h	; 7aa8
	defb 001h,053h,001h,094h	; 7aac
	defb 001h,053h,000h,000h	; 7ab0
	defb 001h,040h,001h,0ach	; 7ab4
	defb 001h,040h,001h,0ach	; 7ab8
	defb 001h,053h,001h,0e0h	; 7abc
	defb 001h,053h,001h,0e0h	; 7ac0
	defb 001h,040h,000h,000h	; 7ac4
	defb 001h,040h,000h,000h	; 7ac8
	defb 001h,053h,000h,000h	; 7acc
	defb 001h,053h,000h,000h	; 7ad0
	defb 001h,040h,000h,000h	; 7ad4
	defb 001h,040h,000h,000h	; 7ad8
	defb 001h,00dh,000h,000h	; 7adc
	defb 001h,00dh,000h,000h	; 7ae0
	defb 000h,0feh,000h,000h	; 7ae4
	defb 000h,0feh,000h,000h	; 7ae8
	defb 001h,040h,000h,000h	; 7aec
	defb 001h,040h,000h,000h	; 7af0
	defb 001h,053h,001h,094h	; 7af4
	defb 001h,068h,001h,094h	; 7af8
	defb 001h,07dh,001h,094h	; 7afc
	defb 001h,094h,001h,094h	; 7b00
	defb 001h,0ach,001h,094h	; 7b04
	defb 001h,0ach,001h,094h	; 7b08
	defb 001h,053h,001h,094h	; 7b0c
	defb 001h,068h,001h,094h	; 7b10
	defb 001h,053h,001h,094h	; 7b14
	defb 001h,068h,001h,094h	; 7b18
	defb 001h,07dh,001h,094h	; 7b1c
	defb 001h,094h,001h,094h	; 7b20
	defb 001h,0c5h,001h,094h	; 7b24
	defb 001h,0ach,001h,094h	; 7b28
	defb 001h,094h,001h,094h	; 7b2c
	defb 001h,07dh,001h,094h	; 7b30
	defb 001h,053h,000h,000h	; 7b34
	defb 001h,068h,001h,068h	; 7b38
	defb 001h,07dh,001h,068h	; 7b3c
	defb 001h,094h,001h,0e0h	; 7b40
	defb 001h,0ach,001h,0e0h	; 7b44
	defb 001h,0ach,000h,000h	; 7b48
	defb 001h,053h,000h,000h	; 7b4c
	defb 001h,068h,000h,000h	; 7b50
	defb 001h,053h,000h,000h	; 7b54
	defb 001h,068h,000h,000h	; 7b58
	defb 001h,07dh,000h,000h	; 7b5c
	defb 001h,0ach,000h,000h	; 7b60
	defb 001h,0c5h,000h,000h	; 7b64
	defb 001h,0ach,000h,000h	; 7b68
	defb 001h,094h,000h,000h	; 7b6c
	defb 001h,07dh,000h,000h	; 7b70
	defb 001h,053h,001h,094h	; 7b74
	defb 001h,068h,001h,094h	; 7b78
	defb 001h,07dh,001h,094h	; 7b7c
	defb 001h,094h,001h,094h	; 7b80
	defb 001h,0ach,001h,094h	; 7b84
	defb 001h,0ach,001h,094h	; 7b88
	defb 001h,053h,001h,094h	; 7b8c
	defb 001h,068h,001h,094h	; 7b90
	defb 001h,053h,001h,094h	; 7b94
	defb 001h,068h,001h,0ach	; 7b98
	defb 001h,094h,001h,0ach	; 7b9c
	defb 001h,0ach,001h,0e0h	; 7ba0
	defb 001h,0c5h,001h,0e0h	; 7ba4
	defb 001h,0ach,001h,0ach	; 7ba8
	defb 001h,094h,001h,0ach	; 7bac
	defb 001h,07dh,001h,0e0h	; 7bb0
	defb 001h,053h,001h,0e0h	; 7bb4
	defb 000h,000h,000h,000h	; 7bb8
	defb 000h,000h,000h,000h	; 7bbc
	defb 001h,0e0h,001h,0fdh	; 7bc0
	defb 001h,0e0h,001h,0fdh	; 7bc4
	defb 001h,094h,001h,0ach	; 7bc8
	defb 001h,094h,001h,0ach	; 7bcc
	defb 001h,068h,001h,07dh	; 7bd0
	defb 001h,068h,001h,07dh	; 7bd4
	defb 001h,053h,001h,068h	; 7bd8
	defb 001h,053h,001h,068h	; 7bdc
	defb 001h,068h,001h,068h	; 7be0
	defb 001h,068h,001h,068h	; 7be4
	defb 001h,094h,001h,094h	; 7be8
	defb 001h,094h,001h,094h	; 7bec
	defb 001h,0e0h,001h,0fdh	; 7bf0
	defb 001h,0e0h,001h,0fdh	; 7bf4
	defb 000h,0f0h,001h,02eh	; 7bf8
	defb 000h,0f0h,001h,02eh	; 7bfc
	defb 000h,0feh,001h,02eh	; 7c00
	defb 000h,0feh,001h,02eh	; 7c04
	defb 000h,0f0h,001h,02eh	; 7c08
	defb 000h,0f0h,001h,02eh	; 7c0c
	defb 000h,0feh,001h,02eh	; 7c10
	defb 000h,0feh,001h,02eh	; 7c14
	defb 000h,0f0h,001h,02eh	; 7c18
	defb 000h,0f0h,001h,02eh	; 7c1c
	defb 001h,02eh,001h,02eh	; 7c20
	defb 001h,02eh,001h,02eh	; 7c24
	defb 001h,00dh,001h,02eh	; 7c28
	defb 001h,00dh,001h,02eh	; 7c2c
	defb 000h,0f0h,001h,02eh	; 7c30
	defb 000h,0f0h,000h,000h	; 7c34
	defb 000h,0e3h,001h,00dh	; 7c38
	defb 000h,0e3h,001h,00dh	; 7c3c
	defb 000h,0f0h,001h,068h	; 7c40
	defb 000h,0f0h,001h,068h	; 7c44
	defb 000h,0e3h,000h,000h	; 7c48
	defb 000h,0e3h,000h,000h	; 7c4c
	defb 000h,0f0h,000h,000h	; 7c50
	defb 000h,0f0h,000h,000h	; 7c54
	defb 000h,0e3h,000h,000h	; 7c58
	defb 000h,0e3h,000h,000h	; 7c5c
	defb 001h,00dh,000h,000h	; 7c60
	defb 001h,00dh,000h,000h	; 7c64
	defb 000h,0f0h,000h,000h	; 7c68
	defb 000h,0f0h,000h,000h	; 7c6c
	defb 000h,0e3h,000h,000h	; 7c70
	defb 000h,0e3h,000h,000h	; 7c74
	defb 000h,0f0h,001h,02eh	; 7c78
	defb 000h,0f0h,001h,02eh	; 7c7c
	defb 000h,0feh,001h,02eh	; 7c80
	defb 000h,0feh,001h,02eh	; 7c84
	defb 000h,0f0h,001h,02eh	; 7c88
	defb 000h,0f0h,001h,02eh	; 7c8c
	defb 000h,0feh,001h,02eh	; 7c90
	defb 000h,0feh,001h,02eh	; 7c94
	defb 000h,0f0h,001h,02eh	; 7c98
	defb 000h,0f0h,001h,02eh	; 7c9c
	defb 001h,02eh,001h,02eh	; 7ca0
	defb 001h,02eh,001h,02eh	; 7ca4
	defb 001h,00dh,001h,02eh	; 7ca8
	defb 001h,00dh,001h,02eh	; 7cac
	defb 000h,0f0h,001h,02eh	; 7cb0
	defb 000h,0f0h,000h,000h	; 7cb4
	defb 000h,0e3h,001h,040h	; 7cb8
	defb 000h,0e3h,001h,040h	; 7cbc
	defb 000h,0f0h,001h,068h	; 7cc0
	defb 000h,0f0h,001h,068h	; 7cc4
	defb 000h,0e3h,000h,000h	; 7cc8
	defb 000h,0e3h,000h,000h	; 7ccc
	defb 000h,0f0h,000h,000h	; 7cd0
	defb 000h,0f0h,000h,000h	; 7cd4
	defb 000h,0e3h,000h,000h	; 7cd8
	defb 000h,0e3h,000h,000h	; 7cdc
	defb 001h,00dh,000h,000h	; 7ce0
	defb 001h,00dh,000h,000h	; 7ce4
	defb 000h,0f0h,000h,000h	; 7ce8
	defb 000h,0f0h,000h,000h	; 7cec
	defb 000h,0e3h,000h,000h	; 7cf0
	defb 000h,0e3h,000h,000h	; 7cf4
	defb 000h,0f0h,001h,02eh	; 7cf8
	defb 000h,0feh,001h,02eh	; 7cfc
	defb 001h,00dh,001h,02eh	; 7d00
	defb 001h,01dh,001h,02eh	; 7d04
	defb 001h,02eh,001h,02eh	; 7d08
	defb 001h,02eh,001h,02eh	; 7d0c
	defb 000h,0f0h,001h,02eh	; 7d10
	defb 000h,0feh,001h,02eh	; 7d14
	defb 000h,0f0h,001h,02eh	; 7d18
	defb 000h,0feh,001h,02eh	; 7d1c
	defb 001h,00dh,001h,02eh	; 7d20
	defb 001h,01dh,001h,02eh	; 7d24
	defb 001h,02eh,001h,02eh	; 7d28
	defb 001h,01dh,001h,02eh	; 7d2c
	defb 001h,00dh,001h,02eh	; 7d30
	defb 000h,0feh,000h,000h	; 7d34
	defb 000h,0f0h,001h,00dh	; 7d38
	defb 000h,0feh,001h,00dh	; 7d3c
	defb 001h,00dh,001h,068h	; 7d40
	defb 001h,01dh,001h,068h	; 7d44
	defb 001h,02eh,000h,000h	; 7d48
	defb 001h,02eh,000h,000h	; 7d4c
	defb 000h,0f0h,000h,000h	; 7d50
	defb 000h,0feh,000h,000h	; 7d54
	defb 000h,0f0h,000h,000h	; 7d58
	defb 000h,0feh,000h,000h	; 7d5c
	defb 001h,00dh,000h,000h	; 7d60
	defb 001h,01dh,000h,000h	; 7d64
	defb 001h,02eh,000h,000h	; 7d68
	defb 001h,01dh,000h,000h	; 7d6c
	defb 001h,00dh,000h,000h	; 7d70
	defb 000h,0feh,000h,000h	; 7d74
	defb 000h,0f0h,001h,02eh	; 7d78
	defb 000h,0feh,001h,02eh	; 7d7c
	defb 001h,00dh,001h,02eh	; 7d80
	defb 001h,01dh,001h,02eh	; 7d84
	defb 001h,02eh,001h,02eh	; 7d88
	defb 001h,02eh,001h,02eh	; 7d8c
	defb 000h,0f0h,001h,02eh	; 7d90
	defb 000h,0feh,001h,02eh	; 7d94
	defb 000h,0f0h,000h,000h	; 7d98
	defb 000h,0feh,001h,040h	; 7d9c
	defb 001h,00dh,001h,040h	; 7da0
	defb 001h,01dh,001h,068h	; 7da4
	defb 001h,02eh,001h,068h	; 7da8
	defb 001h,01dh,001h,040h	; 7dac
	defb 001h,00dh,001h,040h	; 7db0
	defb 000h,0feh,001h,068h	; 7db4
	defb 000h,0f0h,001h,068h	; 7db8
	defb 000h,000h,000h,000h	; 7dbc
	defb 001h,068h,001h,07dh	; 7dc0
	defb 001h,068h,001h,07dh	; 7dc4
	defb 001h,02eh,001h,040h	; 7dc8
	defb 001h,02eh,001h,02eh	; 7dcc
	defb 001h,00dh,001h,01dh	; 7dd0
	defb 001h,00dh,001h,01dh	; 7dd4
	defb 000h,0feh,001h,01dh	; 7dd8
	defb 000h,0feh,001h,01dh	; 7ddc
	defb 001h,00dh,001h,00dh	; 7de0
	defb 001h,00dh,001h,01dh	; 7de4
	defb 001h,02eh,001h,040h	; 7de8
	defb 001h,02eh,001h,040h	; 7dec
	defb 001h,068h,001h,07dh	; 7df0
	defb 001h,068h,001h,07dh	; 7df4
	defb 001h,040h,000h,0d6h	; 7df8
	defb 001h,040h,000h,0d6h	; 7dfc
	defb 001h,02eh,000h,0d6h	; 7e00
	defb 001h,02eh,000h,0d6h	; 7e04
	defb 001h,040h,000h,0d6h	; 7e08
	defb 001h,040h,000h,0d6h	; 7e0c
	defb 001h,068h,000h,0d6h	; 7e10
	defb 001h,068h,000h,0d6h	; 7e14
	defb 001h,040h,000h,0d6h	; 7e18
	defb 001h,040h,000h,0d6h	; 7e1c
	defb 001h,02eh,000h,0d6h	; 7e20
	defb 001h,02eh,000h,0d6h	; 7e24
	defb 001h,040h,000h,0d6h	; 7e28
	defb 001h,040h,000h,0d6h	; 7e2c
	defb 001h,068h,000h,0d6h	; 7e30
	defb 001h,068h,000h,0d6h	; 7e34
	defb 001h,040h,000h,0e3h	; 7e38
	defb 001h,040h,000h,0e3h	; 7e3c
	defb 000h,000h,000h,0d6h	; 7e40
	defb 000h,000h,000h,0d6h	; 7e44
	defb 001h,040h,000h,000h	; 7e48
	defb 001h,02eh,000h,000h	; 7e4c
	defb 001h,040h,000h,000h	; 7e50
	defb 001h,068h,000h,000h	; 7e54
	defb 001h,040h,000h,000h	; 7e58
	defb 001h,02eh,000h,000h	; 7e5c
	defb 001h,040h,000h,000h	; 7e60
	defb 001h,068h,000h,000h	; 7e64
	defb 001h,040h,000h,000h	; 7e68
	defb 001h,02eh,000h,000h	; 7e6c
	defb 001h,040h,000h,000h	; 7e70
	defb 001h,068h,000h,000h	; 7e74
	defb 001h,040h,000h,0d6h	; 7e78
	defb 001h,040h,000h,0d6h	; 7e7c
	defb 001h,02eh,000h,0d6h	; 7e80
	defb 001h,02eh,000h,0d6h	; 7e84
	defb 001h,040h,000h,0d6h	; 7e88
	defb 001h,040h,000h,0d6h	; 7e8c
	defb 001h,068h,000h,000h	; 7e90
	defb 001h,068h,000h,000h	; 7e94
	defb 001h,040h,000h,0d6h	; 7e98
	defb 001h,040h,000h,0d6h	; 7e9c
	defb 001h,02eh,000h,0d6h	; 7ea0
	defb 001h,02eh,000h,0d6h	; 7ea4
	defb 001h,040h,000h,0d6h	; 7ea8
	defb 001h,040h,000h,0d6h	; 7eac
	defb 001h,068h,000h,000h	; 7eb0
	defb 001h,068h,000h,000h	; 7eb4
	defb 001h,040h,000h,0e3h	; 7eb8
	defb 001h,040h,000h,0e3h	; 7ebc
	defb 001h,02eh,000h,0d6h	; 7ec0
	defb 001h,02eh,000h,0d6h	; 7ec4
	defb 001h,040h,000h,000h	; 7ec8
	defb 001h,02eh,000h,000h	; 7ecc
	defb 001h,040h,000h,000h	; 7ed0
	defb 001h,068h,000h,000h	; 7ed4
	defb 001h,040h,000h,000h	; 7ed8
	defb 001h,02eh,000h,000h	; 7edc
	defb 001h,040h,000h,000h	; 7ee0
	defb 001h,068h,000h,000h	; 7ee4
	defb 001h,040h,000h,000h	; 7ee8
	defb 001h,02eh,000h,000h	; 7eec
	defb 001h,040h,000h,000h	; 7ef0
	defb 001h,068h,000h,000h	; 7ef4
	defb 001h,02eh,000h,000h	; 7ef8
	defb 001h,01dh,000h,0cah	; 7efc
	defb 001h,02eh,000h,0cah	; 7f00
	defb 001h,053h,000h,0cah	; 7f04
	defb 001h,02eh,000h,0cah	; 7f08
	defb 001h,01dh,000h,0cah	; 7f0c
	defb 001h,02eh,000h,0cah	; 7f10
	defb 001h,053h,000h,0cah	; 7f14
	defb 001h,02eh,000h,0cah	; 7f18
	defb 001h,01dh,000h,0cah	; 7f1c
	defb 001h,02eh,000h,0cah	; 7f20
	defb 001h,053h,000h,0cah	; 7f24
	defb 001h,02eh,000h,0cah	; 7f28
	defb 001h,01dh,000h,0cah	; 7f2c
	defb 001h,02eh,000h,0cah	; 7f30
	defb 001h,053h,000h,0cah	; 7f34
	defb 001h,02eh,000h,000h	; 7f38
	defb 001h,02eh,000h,0cah	; 7f3c
	defb 000h,000h,000h,0cah	; 7f40
	defb 001h,040h,001h,02eh	; 7f44
	defb 001h,040h,001h,02eh	; 7f48
	defb 000h,0f0h,000h,0feh	; 7f4c
	defb 000h,0f0h,000h,0feh	; 7f50
	defb 000h,0d6h,000h,0d6h	; 7f54
	defb 000h,0d6h,000h,0d6h	; 7f58
	defb 000h,0cah,000h,0cah	; 7f5c
	defb 000h,0cah,000h,0cah	; 7f60
	defb 000h,0d6h,000h,0d6h	; 7f64
	defb 000h,0d6h,000h,0d6h	; 7f68
	defb 000h,0f0h,000h,0f0h	; 7f6c
	defb 000h,0f0h,000h,0f0h	; 7f70
	defb 000h,0feh,000h,0f0h	; 7f74
	defb 000h,0feh,000h,0feh	; 7f78
	defb 000h,0f0h,000h,0f0h	; 7f7c
	defb 000h,0f0h,000h,0f0h	; 7f80
	defb 000h,0f0h,000h,0f0h	; 7f84
	defb 0ffh,0ffh,0ffh,0ffh	; 7f88
	defb 0ffh,0ffh,0ffh,0ffh	; 7f8c

; ======================================================================
; CODIGO 0x7f90..0x7fe7  (87 bytes)
; ======================================================================


suena_un_paso:		; El reproductor. Lo llama 0xC000, que antes conmuta la pagina 1 a RAM
	ld a,(0806ch)		;7f90   ; Un contador del juego que hace de interruptor de la musica
	cp 069h		;7f93   ; A partir de 0x69 la musica se calla y la rutina se va sin tocar el PSG
	ret nc			;7f95
	ld hl,080fbh		;7f96   ; Cuenta atras hasta el paso siguiente
	dec (hl)			;7f99
	ret nz			;7f9a   ; Si no ha llegado a cero, todavia no toca cambiar de nota
	ld (hl),00eh		;7f9b   ; Catorce llamadas por paso: eso es el tempo
	ld hl,(080fch)		;7f9d   ; El puntero de la partitura
	ld a,(hl)			;7fa0   ; El primer byte del paso
	cp 0ffh		;7fa1   ; 0xFF marca el final
	jr nz,escribe_el_paso		;7fa3
	ld hl,079c8h		;7fa5   ; Rebobina al BUCLE, no al principio: la entradilla de 0x7900 ya no suena mas
	ld (080fch),hl		;7fa8
escribe_el_paso:
	ld e,(hl)			;7fab   ; Byte 1 del paso
	ld a,003h		;7fac   ; Registro 3 del PSG: tono grueso del canal B
	call 00093h		;7fae   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;7fb1
	ld e,(hl)			;7fb2   ; Byte 2
	dec a			;7fb3   ; Registro 2: tono fino del canal B
	call 00093h		;7fb4   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;7fb7
	ld e,(hl)			;7fb8   ; Byte 3
	ld a,005h		;7fb9   ; Registro 5: tono grueso del canal C
	call 00093h		;7fbb   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;7fbe
	ld e,(hl)			;7fbf   ; Byte 4
	dec a			;7fc0   ; Registro 4: tono fino del canal C
	call 00093h		;7fc1   ; BIOS WRTPSG - Writes data to PSG-register
	inc hl			;7fc4
	ld (080fch),hl		;7fc5   ; Guarda el puntero ya avanzado
	ld a,007h		;7fc8   ; Registro 7, el mezclador
	ld e,0b8h		;7fca   ; 0xB8: los tres tonos abiertos, los tres ruidos cerrados
	call 00093h		;7fcc   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,009h		;7fcf   ; Registro 9: volumen del canal B
	ld e,00ch		;7fd1   ; Doce sobre quince
	call 00093h		;7fd3   ; BIOS WRTPSG - Writes data to PSG-register
	inc a			;7fd6   ; Registro 10: volumen del canal C
	ld e,00ah		;7fd7   ; Diez sobre quince, un poco por debajo del B
	call 00093h		;7fd9   ; BIOS WRTPSG - Writes data to PSG-register
	ld a,008h		;7fdc   ; Registro 8: volumen del canal A
	ld e,000h		;7fde   ; A cero: el canal A no lo usa la musica, lo usan los efectos
L_7FE0:
	call 00093h		;7fe0   ; BIOS WRTPSG - Writes data to PSG-register
	call 0fd9ah		;7fe3   ; BIOS HOOKS - System hooks | Y de paso llama al vector de sonido de 0xFD9A, que es donde el juego
	ret			;7fe6

; ----------------------------------------------------------------------
; DATOS relleno_cero: todo el hueco es 0x00
;   0x7fe7..0x7fe8  (1 bytes)
DATA_7FE7:
	defb 000h	; 7fe7
