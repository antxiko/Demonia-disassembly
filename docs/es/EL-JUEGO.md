# El juego

[Empezar](EMPEZAR.html) · [La cinta](LA-CINTA.html) · [El codigo](EL-CODIGO.html) · [Hallazgos](HALLAZGOS.html) · [Preguntas abiertas](PREGUNTAS-ABIERTAS.html)

Demonia es un juego de plataformas y exploración por pantallas fijas. Se
empieza en un cementerio, al aire libre —estrellas, hierba, lápidas y tierra
roja— y se baja a unas galerías de ladrillo con escaleras, agua y puertas.

Todo lo que sigue está **medido sobre el binario**. Lo que es una lectura y no
un dato va dicho como tal.

## Veinticuatro pantallas y veintitrés mapas

La tabla de `0xD000` tiene veinticuatro entradas, una por pantalla, y cada una
apunta a un mapa comprimido de la página escondida. Pero los mapas distintos
son **veintitrés**: las entradas 13 y 14 apuntan las dos al mismo, el de
`0x4D44`.

Cada mapa se guarda comprimido con una carrera de longitud muy corta de leer:

    0xFF <baldosa> <cuantas>   repite esa baldosa esas veces
    cualquier otro byte        una baldosa suelta

y descomprimido da **640 baldosas, o sea 32 columnas por 20 filas**, que es la
pantalla del juego. El descompresor es la rutina de `0x819D` y deja el mapa en
`0x5480`. A partir de ahí, calcular una casilla es siempre lo mismo:

    0x5480 + fila*32 + columna

Ese bloque de doce instrucciones aparece una y otra vez por todo el listado.
Los cinco `add hl,hl` son la multiplicación por 32.

Los mapas ocupan de `0x43DE` a `0x5468` y **encadenan sin un byte de hueco ni
de solape**: cada uno acaba exactamente donde empieza el siguiente. Eso es lo
que demuestra que el formato está bien leído, y hay un test que lo comprueba.

El más caro es el de la pantalla 15, con 347 bytes comprimidos; el más barato,
el de la 2, con 81. Cuanto más se repite una baldosa, menos ocupa el mapa.

## La ficha de cada pantalla

Detrás de la tabla de mapas hay otras dos, y son las que hacen que cada
pantalla se comporte distinto:

| dirección | qué es |
|---|---|
| `0xD000` | veinticuatro punteros al mapa comprimido de cada pantalla |
| `0xD030` | la **tabla de conducta**: veinticuatro filas de cuatro punteros a rutina |
| `0xD0C0` | las **fichas**: veinticuatro fichas de 88 bytes, una por pantalla |

La tabla de conducta es el guion de cada pantalla: hasta cuatro cosas que
pueden pasar en ella. Los huecos no se dejan a cero, se rellenan con `0xFD9A`,
que es el vector del sonido; o sea, «aquí no hay nada que hacer» se escribe
llamando a algo inofensivo.

Las fichas se reconocen porque **todas llevan en el byte 84 la marca
`FF <número de pantalla en ASCII> FF`**: la primera en `0xD114` y la última en
`0xD8FC`, siempre a 88 bytes de distancia. Esa marca es lo que permitió
acotarlas una a una.

Y ahí está una de las cosas buenas de esta cinta: **encima de esas fichas
quedaron enterradas la tabla de órdenes del monitor de Loriciels y sus tablas
de nemónicos**. Está contado en [Hallazgos](HALLAZGOS.html).

## Lo que se mueve

El jugador vive en tres bytes de la página de variables: `0x8049` y `0x804A`
son su X y su Y, y `0x804B`, el dibujo que le toca.

Enfrente hay dos clases de enemigo, y el código las trata por separado:

- **El perseguidor** (`0x9E88`) va derecho hacia el jugador y **acelera cada
  cuatro pasos**. `0x9638` compara las dos posiciones con una ventana de
  treinta y dos píxeles y, si coinciden, lo despierta.
- **El bicho**, que tiene estados numerados y va cambiando entre ellos
  (`0x9975`, `0x99C9`, `0xADD8`). En el estado 1, si no está ocupado, mira si
  el jugador está a tiro.

Y luego está lo que cae (`0xB61A`), lo que aparece por un lado de la pantalla
(`0x9518`, con un sorteo en `0x9E30`) y los objetos, que se dibujan de dos en
dos casillas (`0xA60A`).

## Los sprites

Los dibujos de sprite no se guardan sueltos: van en **registros de 33 bytes**,
32 de patrón de 16×16 más uno de color. El 33 no es una elección de quien
desensambla, sale del `ld de,0x0021` de `0x82A9`; y el `ld bc,0x0042` de
`0x82AF` dice que se leen **dos registros de golpe**.

Hay dos bancos, y las dos cuentas dan exactas: **242 registros** en `0x0000` y
**214** en `0x1F32`. El juego cambia de banco escribiéndose encima: `0xABB3`
escribe en `0xAB1A`, que es el operando de un `ld c,n`.

## La partida, jugada

Todo lo anterior sale de leer el binario. Esto sale de jugarlo: una partida en
openMSX sobre un **Philips VG-8020** con la cinta de verdad, guiada por
`tools/omsx_partida.tcl`, que no se limita a arrancar el emulador sino que
**mide que se está jugando**.

Lo que se comprobó, con la medida al lado:

- **El mando es el que dice el listado.** `0x8418` llama a GTSTCK (`0x00D5`),
  que con A=0 lee los cursores, y `0x85A9` llama a GTTRIG (`0x00D8`), que lee la
  barra espaciadora. Pulsando la barra se pasa de la presentación a la partida;
  con los cursores el personaje anda.
- **El jugador se mueve de verdad.** `0x8049`, que es su X, va de 128 a 141 y a
  152 pulsando derecha, y baja a 139 y 138 pulsando izquierda. No es una
  impresión: es el byte, leído de la RAM del emulador en cada paso.
- **El marcador.** Arriba se lee `SCORE=000000`, `RECORD=000000` y una barra
  `FORCE=` de dos colores, que es lo que anima `0x994F`.

Y la comprobación que más vale de todas:

> **La pantalla que pinta el emulador es la misma que el mapa dibujado desde la
> cinta.** El cementerio de la primera pantalla —las estrellas, el mausoleo, la
> lápida, la hierba y la tierra roja— sale idéntico en
> `docs/imagenes/mapa-pantalla-00.png`, que no ha visto un emulador en su vida:
> lo dibuja `tools/mapas.py` descomprimiendo los bytes de `0x43DE`.

Lo que **no** se ha hecho: jugar una partida entera. No se han visitado las 24
pantallas, ni se ha visto morir al personaje, ni el `GAME OVER`. Sigue en
[Preguntas abiertas](PREGUNTAS-ABIERTAS.html).

## La pantalla y el sonido

El MSX1 no desplaza la pantalla por hardware, así que el juego lo hace a mano y
lleva **una rutina por sentido** (`0x81CF` en adelante): bajar una columna,
correr las filas, y lo mismo hacia el otro lado.

Los decorados son 2.048 bytes de patrones en `0x6000` y otros 2.048 de color en
`0x6800`. La rutina de `0x8164` los sube **a los tres tercios de la pantalla**
—guarda HL con un `push` y lo recupera en cada vuelta—, así que la baldosa N
tiene el mismo dibujo arriba, en medio y abajo.

La música son pasos de cuatro bytes: tono grueso y fino del canal B, y lo mismo
del canal C. El puntero arranca en `0x7900` y, al llegar al `0xFF`, **rebobina
a `0x79C8` y no al principio**: la entradilla suena una vez y ya no vuelve.
