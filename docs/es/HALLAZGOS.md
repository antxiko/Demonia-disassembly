# Hallazgos: lo que sobra en Demonia

Un desensamblado completo no solo dice lo que un juego hace: tambien deja a la
vista lo que lleva dentro y no usa. En esta cinta hay bastante, y una cosa que
no es un resto cualquiera.

Las otras paginas: [Empezar](EMPEZAR.html) · [El juego](EL-JUEGO.html) ·
[La cinta](LA-CINTA.html) · [El codigo](EL-CODIGO.html) ·
[Preguntas abiertas](PREGUNTAS-ABIERTAS.html)

Las cifras salen de `make sobra` (`tools/lo_que_sobra.py`), y cada una dice de
que medida viene. Lo MEDIDO y lo SUPUESTO van separados y etiquetados.

## La cuenta, de arriba abajo

| que | bytes | % de la cinta |
|---|---:|---:|
| **el monitor de Loriciels**, entero | **4.377** | **7,5 %** |
| ...de los cuales, codigo al que no se llega | 2.094 | 3,6 % |
| relleno y restos de un byte o tres | 455 | 0,8 % |
| NOP, instrucciones repetidas y RET que no corren | 61 | 0,1 % |
| datos declarados a los que nadie apunta | 314 | 0,5 % |
| relleno de alineacion de la cinta | 18 | 0,03 % |

Cinta entera: 58.334 bytes.

---

## 1. El polizon: un monitor de codigo maquina de 1984

Dentro del bloque del juego, de 0xC000 en adelante, viaja **un monitor de
codigo maquina completo**. No es un resto de dos rutinas: es un programa con
su interprete de ordenes, su desensamblador, su paso a paso, su volcado de
registros y sus mensajes de error en frances.

Lo firma el, en los textos de 0xD948-0xD988:

```
D948  Auteur:Claude SABLATOU
D95F  MONITEUR MSX
D96C  Copyright (C) 1984 LORICIELS
```

Y la portada del juego, que esta en el mapa comprimido de 0x4281 y se lee
descomprimiendola, dice:

```
fila 17            L'INTRUSION
fila 19   (C) 1986 PAR SABLATOU CLAUDE
```

O sea que **el autor del juego metio dentro su propia herramienta de trabajo**.
Un monitor de Loriciels de 1984 viajando dentro de un juego de Microids de
1986, porque el mismo hombre escribio los dos.

Ojo con esas dos filas: son lo unico que se lee si el mapa se vuelca como
texto, porque el titulo de la portada esta hecho de baldosas graficas y no de
ASCII. Dibujada con sus patrones, la pantalla pone **DEMONIA** en letras
enormes en las ocho primeras filas y `L'INTRUSION` debajo, pequeno, de
subtitulo.

### Que queda de el, medido

| tramo | bytes | que es |
|---|---:|---|
| 0xC076-0xC24C | 471 | sus variables y su pila (acaba en 0xC0FF) |
| 0xC24D-0xCFD3 | 3.406 | su codigo: interprete de ordenes, desensamblador, paso a paso |
| 0xCFD4-0xCFFF | 44 | lo que queda de las tablas del desensamblador |
| 0xD900-0xDAC7 | 456 | sus textos |

Dentro de sus variables han quedado dos textos que el juego no usa para nada:
`Press any key for retry` en 0xC085 y `MSXDOS  SYS` en 0xC0A0.

### Y sigue enchufado

El punto de entrada del monitor, **0xC924**, se llama de verdad desde el codigo
del juego. En 0x9C6D:

```
9C6D  3A 9B FC    ld a,(0xFC9B)     ; INTFLG
9C70  FE 03       cp 3
9C72  CC 24 C9    call z,0xC924     ; y al monitor
```

0xFC9B es INTFLG, la variable donde la BIOS deja constancia de que se ha
pulsado STOP; el valor 3 es el de CTRL+STOP segun la documentacion del MSX.
**Es la puerta trasera del programador**: parar el juego y caer en el monitor.

*(MEDIDO: los bytes y el significado de 0xFC9B. SUPOSICION: que la intencion
fuera esa y no otra; el binario dice que hace el codigo, no por que.)*

### Pero sus ordenes ya no responden

Y aqui esta lo bueno. El monitor reconoce sus ordenes buscando la inicial
tecleada en una tabla de 15 entradas de tres bytes. El bucle esta en
0xC28D-0xC299 y no deja lugar a dudas:

```
C288  4E          ld c,(hl)        ; el caracter tecleado
C289  CB A9       res 5,c          ; a mayusculas
C28D  21 C6 D5    ld hl,0xD5C6     ; la tabla de ordenes
C290  06 0F       ld b,15          ; quince ordenes
C292  7E          ld a,(hl)        ; la inicial de esta orden
C293  B9          cp c
C294  28 25       jr z,0xC2BB      ; encontrada: salta a su manejador
C296  23 23 23    inc hl x3        ; tres bytes por entrada
C299  10 F7       djnz 0xC292
```

**En 0xD5C6 no hay ninguna tabla.** Las 24 fichas de pantalla del juego ocupan
de 0xD0C0 a 0xD8FF, 88 bytes cada una, y 0xD5C6 cae en el byte 54 de la ficha
numero 14 (0xD590-0xD5E7). Los 45 bytes que el bucle recorre, de 0xD5C6 a
0xD5F2, son el final de esa ficha y el principio de la siguiente: diecisiete
ceros y luego datos de pantalla. Los datos del juego se han escrito encima de
la tabla de ordenes del monitor.

Y no solo de esa: el desensamblador del monitor lee sus nemonicos de 0xD64A,
0xD652 y 0xD662 (instrucciones de 0xCFC0-0xCFE0), y esos tres sitios estan
tambien a cero, tapados por las fichas de pantalla 16 y 17.

**Consecuencia medida:** con las quince claves a cero, el `cp c` de 0xC293 solo
puede casar si el caracter tecleado, con el bit 5 borrado, vale 0 — y entonces
salta a un manejador cuyo puntero es 0x0000. Cualquier otra tecla recorre las
quince entradas sin exito, imprime `Commande illegale` (0xD98D) y vuelve a
pedir. **El monitor arranca, pinta los registros y no obedece a nada.**

De ahi los **2.094 bytes de codigo al que no llega nadie**, que son casi todos
sus manejadores de orden. Estos son los tramos, tal como los da `make sobra`
restando el trazado sin las entradas marcadas `[HUERFANO]`:

```
0xBDC3..0xBDFE    60      0xCAB0..0xCAEE    63      0xCDE8..0xCDED     6
0xC33F..0xC567   553      0xCAF5..0xCB06    18      0xCE0B..0xCE15    11
0xC5B6..0xC63E   137      0xCB10..0xCB15     6      0xCF51..0xCF8D    61
0xC661..0xC747   231      0xCC63..0xCC73    17      0xCF93..0xCF9A     8
0xC756..0xC923   462      0xCC78..0xCCEF   120      0xCFA3..0xCFD3    49
0xC97A..0xCA63   234      0xCD84..0xCDB7    52      0xDAC8..0xDACD     6
```

Son rutinas enteras y bien formadas. 0xC33F pregunta si un caracter es un
digito; 0xCD84 imprime un numero en decimal restando 10000, 1000, 100 y 10;
0xC5B6 escribe `Resultat= `. Ninguna ha corrido desde que se grabo la cinta.

### El fosil

El monitor ejecuta el paso a paso copiando la instruccion del programa detenido
a un tampon de cuatro bytes en 0xCC5F y ejecutandola alli. 0xCBB9 pone esos
cuatro bytes a cero antes de cada paso, asi que lo que hay grabado en la cinta
es **la ultima instruccion que ese monitor ejecuto paso a paso antes de que
alguien hiciera el BSAVE**:

```
CC5F  2A 78 80 00      ld hl,(0x8078)
```

Y 0x8078 esta dentro de la pagina de variables de este mismo juego.

*(MEDIDO: los cuatro bytes, que 0xCBB9 los borra y 0xCBDB los rellena, y que
0x8078 cae en 0x8000-0x80FF. SUPOSICION: que la sesion fuera de depuracion de
este juego. Encaja, pero el binario no lo dice.)*

---

## 2. Ramas que no pueden ejecutarse: no hay

Se busco el patron clasico -una comparacion que decide otra comparacion, el
caso del `cp 9` de Konami's Mahjong- con `tools/ramas_imposibles.py`, en sus
dos formas:

1. `cp N1` + `jr nz`, y despues `cp N2` con N2 distinto, sin que A cambie ni
   nadie salte en medio;
2. A cargada con una constante (`ld a,N` o `xor a`) y comparada con otra.

**Resultado: ninguna de las dos aparece en toda la cinta.** Es un resultado
negativo y se cuenta como tal. Lo unico de esa familia que hay aqui es de otro
tipo y esta arriba: no una comparacion mal escrita, sino una tabla de
comparacion borrada.

---

## 3. Restos de un byte y de tres: 455 bytes

Etiquetados por su CONTENIDO, no a ojo (`tools/rellena_huecos.py` mira los
bytes y la etiqueta dice de que medida sale):

| clase | tramos | bytes |
|---|---:|---:|
| relleno a 0x00 o a 0xFF | 137 | 367 |
| RET sueltos, solos o con ceros detras | 41 | 60 |
| saltos huerfanos | 3 | 11 |
| conmutadora de slot destripada | 1 | 8 |
| `jr $`, o sea un cuelgue, que nadie alcanza | 2 | 4 |
| llamada al monitor a la que no llega nadie | 1 | 3 |
| `or a / ret z` huerfano | 1 | 2 |

Los que tienen gracia:

- **0x8148, ocho bytes.** Leidos como codigo son `di / jp 0xA0F0` y, pegado
  detras, `ld (0xFFFF),a / ret`, que son las dos ultimas instrucciones de una
  restauracion de slot exactamente igual que la de 0x8139 y la de 0x8126. Es el
  cadaver de una tercera conmutadora a la que alguien le metio un salto por
  medio. No la llama nadie.

- **0xAA95, tres bytes: `call 0xC924`.** Otra llamada al monitor, esta sin
  ningun salto que llegue. Alguien tenia mas de una puerta trasera.

- **0x8F0B: `jp 0x8A85`** y **0xA634: `jp 0xDAD0`**, dos saltos sueltos entre
  rutinas. El segundo apunta a la rutina de reinicio del juego, que si esta
  viva y a la que llegan seis saltos condicionales de otros sitios.

- **0x85CA: `ld hl,0x0000`.** Es la tercera variante de la carga del vector de
  0x804E: las otras dos, 0x85C0 y 0x85C5, cargan 0x85E3 y 0x8638. Esta cargaria
  "ninguna rutina". Nadie la usa.

- **Cuarenta y un RET sueltos.** Rutinas reducidas a nada que siguen ocupando su
  byte.

---

## 3 bis. Lo que aparecio al comentar el listado

Estas no salen de ninguna herramienta: salieron de leer el codigo instruccion a
instruccion para escribir los comentarios. Van con su direccion, que es lo que
permite comprobarlas.

- **0x9134: la misma instruccion escrita dos veces.**

  ```
  9134  21 58 80    ld hl,0x8058
  9137  21 58 80    ld hl,0x8058
  913A  35          dec (hl)
  ```

  Tres bytes que no hacen nada. La segunda carga machaca la primera con el
  mismo valor.

- **Cinco `RET NC` y `RET NZ` que no pueden ejecutarse.** Cuando dos vuelven
  seguidos con la misma condicion, el primero ya se ha ido y el segundo no
  llega a correr nunca:

  ```
  823A  D0 D0 D0    ret nc / ret nc / ret nc   (en el cargador de cinta)
  8C3E  C0 C0       ret nz / ret nz
  BFE3  C0 C0 C0    ret nz / ret nz / ret nz
  ```

  Ocho bytes en total que llevan ahi desde 1986 sin ejecutarse una sola vez.

- **Cincuenta bytes de NOP dentro de codigo vivo**, en once rachas de tres a
  seis:

  ```
  A401 (4)  A640 (5)  A65D (6)  A67B (6)  A701 (5)  A746 (3)
  A947 (3)  B14E (3)  DC01 (6)  DC12 (6)  DE2C (3)
  ```

  Las dos de seis de 0xDC01 y 0xDC12 estan justo delante y justo detras de un
  LDIR que copia las tablas de pantalla a la RAM escondida, o sea exactamente
  donde iria una conmutacion de slot: alguien la quito y dejo el hueco. Y la de
  0xA640 va detras de un `cp 0` que se ejecuta despues de un `or a` que ya ha
  decidido lo mismo.

- **0xC3FE, dentro del monitor**: en el camino de "Debordement" quedan dos
  cargas seguidas de HL, `ld hl,(0xD3DA)` y `ld hl,(0x1103)`, y dos NOP. La
  primera es inutil porque la segunda la pisa, y 0x1103 cae dentro de la ROM
  del BASIC.

- **Codigo que se escribe a si mismo**, que no sobra pero merece la pena verlo:
  0xABB3 escribe en 0xAB1A, que es el operando de un `ld c,n`, para cambiar de
  banco de sprites; 0x864E y 0x8653 parchean dos operandos de 0x8603 y 0x8623;
  y 0xC645, dentro del monitor, escribe la direccion de vuelta encima del
  operando del `jp` de 0xC65E.

---

## 4. Datos que nadie apunta: 314 bytes

CANDIDATOS, no muertos: el cruce solo ve las direcciones que aparecen como
inmediato en una instruccion trazada o dentro de una tabla de punteros
declarada. Un HL que llegue ahi sumando no se ve desde aqui.

| tramo | bytes | que parece |
|---|---:|---|
| 0xD030-0xD0BF | 144 | la tabla de conducta de las 24 pantallas. La lee 0xDC07 partiendo de 0xD000, sumando: por eso no aparece apuntada |
| 0xCFD4-0xCFFF | 44 | lo que sobrevive de las tablas del desensamblador del monitor |
| 0x944A, 0x9D95, 0xA0EF, 0xA37F, 0xBDB1, 0xDFC1 | 126 | seis tramos cortos entre rutinas |

---

## 5. Lo que la cinta gasta en ser cinta: 18 bytes

Sorprendentemente poco. Un bloque de `.cas` tiene que empezar en multiplo de
ocho, asi que detras de cada bloque puede haber hasta siete bytes de relleno.
En esta cinta solo cinco de los trece bloques lo necesitan y suman 18 bytes.
(Los 104 de centinela, los 48 de cabecera de fichero y los 12 de cabecera BIN
no son relleno: son el formato.)

Los 256 bytes del cargador BASIC, en cambio, van casi vacios: las dos lineas
ocupan 93 bytes y los otros 163 son el 0x1A de relleno que el MSX pone hasta
completar el trozo de 256. Un 64 % del primer fichero de la cinta es relleno.

---

## 6. Lo que no se ejecuto, y por que no cuenta

Se muestreo el contador de programa durante 200 segundos de juego en un Philips
VG-8020, con la cinta cargada de verdad: 398.593 muestras, 1.357 direcciones
distintas dentro del juego. De los 17.676 bytes de codigo alcanzable, se vieron
ejecutandose 1.357.

**Ese 7,7 % no mide codigo muerto y no se usa aqui como tal.** El muestreo coge
el PC cada 0,5 ms y ve una fraccion minima de lo que corre; y la ventana era la
pantalla de presentacion, no una partida entera.

Lo que si vale es al reves: **de las 1.357 direcciones que se vieron ejecutar,
las 1.357 caen dentro de lo que el trazador marca como codigo.** Ni una fuera.
Eso valida el trazado, que es para lo que se hizo la medida.

La partida buena, el replay `Demonia.omr`, no se pudo reproducir: pide la ROM
del Sony HB-20P con el que se grabo y esa ROM no esta en esta maquina. Lo que
si se saco de el, abriendolo sin emulador, esta en [Preguntas abiertas](PREGUNTAS-ABIERTAS.html).
