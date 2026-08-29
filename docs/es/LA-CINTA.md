# La cinta

[Empezar](EMPEZAR.html) · [El juego](EL-JUEGO.html) · [El codigo](EL-CODIGO.html) · [Hallazgos](HALLAZGOS.html) · [Preguntas abiertas](PREGUNTAS-ABIERTAS.html)

Demonia no viene en un cartucho: viene en una cinta de 58.334 bytes, y casi
todo lo raro de este juego empieza ahí.

## Trece bloques y tres ficheros que se llaman igual

Un `.cas` es una lista de bloques, cada uno precedido por ocho bytes de
centinela. Aquí hay **trece**, y entre ellos hay **tres ficheros con nombre**.
Los tres se llaman `DEMON`:

| fichero | tipo | carga en | tamaño |
|---|---|---|---:|
| `DEMON` | ASCII | — | el cargador BASIC |
| `DEMON` | BIN | `0x8180` | 249 bytes |
| `DEMON` | BIN | `0x8000` | 24.576 bytes |

Entre los dos BIN van **siete bloques sin cabecera**, que no se pueden cargar
desde BASIC porque no llevan nombre: los lee el programa del segundo fichero.

Que los tres se llamen igual no es un descuido. La línea 50 del cargador BASIC
es:

    BLOAD"CAS:DEMON",R:RUN

Como la cinta es secuencial, la primera vez que se ejecuta esa línea la cabeza
está antes del BIN pequeño y encuentra **ése**. El `,R` lo arranca; cuando ese
programa termina, vuelve al BASIC, el `:RUN` reinicia el cargador y la línea 50
se ejecuta otra vez. Pero la cinta ya está pasada por delante de los siete
bloques, así que esta segunda vez encuentra **el BIN grande**, que es el juego.

Dos ficheros con el mismo nombre y un `RUN` para elegir entre ellos.

## Los siete trozos, y la tabla que los declara

El BIN pequeño es el cargador de verdad. En `0x8180` lleva una tabla de siete
entradas de ocho bytes, y cada entrada trae tres direcciones y un centinela:

    defw 0a000h,0a618h,0a600h,0ffffh   ; carga, fin, ejecucion, FFFF
    defw 0ad00h,0c07fh,0c050h,0ffffh
    defw 0a000h,0b531h,0b468h,0ffffh
    defw 0a000h,0bf57h,0bf32h,0ffffh
    defw 0a000h,0bbbbh,0bb96h,0ffffh
    defw 0afd0h,0bfffh,0afe0h,0ffffh
    defw 09000h,0971fh,096f8h,0ffffh

El bucle de `0x8208` la recorre entera y **para en `0x81B8`**, que es lo que
dice el `ld de,0x81B8` de `0x8236`. Ocho bytes por entrada, de `0x8180` a
`0x81B8`: siete.

Para cada trozo, el cargador saca de la tabla la dirección de carga (bytes 0 y
1) y la final (bytes 2 y 3), calcula la longitud restando y sumando uno, lee el
bloque de la cinta y **salta a la dirección de ejecución** (bytes 4 y 5). O
sea: cada trozo se ejecuta nada más leerse, antes de leer el siguiente.

Fíjese en que cuatro de los siete cargan en `0xA000` pero se ejecutan mucho más
arriba. Eso es porque lo que se ejecuta no es el trozo entero, sino la cola que
lleva pegada.

## Veintiséis kilobytes debajo de la ROM del BASIC

Un MSX arrancado en BASIC ve la ROM en las páginas 0 y 1, y la RAM sólo en la 2
y la 3. Son 32 KB, y este juego no cabe.

Lo que hace es buscar un slot con 64 KB y **meter 26 KB debajo de la ROM**. La
cola que lleva pegada cada trozo es siempre la misma idea: conmuta el slot para
que la página que toca sea RAM, hace un `LDIR` que copia el trozo a su sitio
definitivo, y devuelve el slot como estaba.

Por eso el desensamblado tiene **trece listados y no siete**: hay que
desensamblar el trozo tal como cae en la cinta *y* la memoria tal como queda
después de moverlo todo.

| listado | org | bytes |
|---|---|---:|
| `arranque` | `0x8180` | 249 |
| `bajo0000` | `0x0000` | 15.048 |
| `bajo4000` | `0x4000` | 5.224 |
| `bajo6000` | `0x6000` | 4.096 |
| `bajo7900` | `0x7900` | 1.768 |
| `carga1` | `0xA000` | 1.561 |
| `carga2` | `0xAD00` | 4.992 |
| `carga3cola` | `0xB468` | 202 |
| `carga4cola` | `0xBF32` | 38 |
| `carga5cola` | `0xBB96` | 38 |
| `carga6cab` | `0xAFD0` | 48 |
| `carga7cola` | `0x96E8` | 56 |
| `juego` | `0x8000` | 24.576 |

Los cinco trozos escondidos se comprobaron **byte a byte** contra la RAM de
openMSX con el juego en marcha, y también contra las instantáneas de RAM que
lleva dentro un replay grabado en otra máquina distinta. Dos medidas
independientes que dan lo mismo.

## El presupuesto: ni un byte sin explicar

```
cinta entera                58.334 bytes
  código trazado            20.299
  datos con nombre          37.597
  envoltorio de la cinta       438
  sin explicar                   0   ->  100,00 %
```

Los 438 del envoltorio se desglosan así, y ninguno es misterio:

| qué | bytes |
|---|---:|
| centinelas de bloque | 104 (13 bloques × 8) |
| cabeceras de fichero | 48 (3 ficheros × 16) |
| cabecera BIN | 12 (2 ficheros × 6) |
| cargador BASIC | 256 |
| relleno de alineación | 18 |

**Lo que la cinta gasta en ser cinta son 18 bytes.** Un bloque tiene que
empezar en múltiplo de ocho, así que detrás de cada uno puede haber hasta siete
bytes de relleno; aquí sólo cinco de los trece lo necesitan.

El cargador BASIC, en cambio, va casi vacío: sus dos líneas ocupan 93 bytes y
los otros 163 son el `0x1A` con el que el MSX completa el trozo de 256. **Un
64 % del primer fichero de la cinta es relleno.**

## Y por eso el verify tiene dos pasos

`make verify` no puede limitarse a reensamblar y comparar, como en un cartucho.
Aquí hace dos cosas:

1. reensambla cada uno de los trece listados y comprueba que sale exactamente
   el trozo de memoria que le corresponde;
2. **vuelve a montar el `.cas` entero** —los trece bloques, con sus
   centinelas, sus cabeceras, el cargador BASIC y el relleno— y comprueba que
   da el mismo sha256 que la cinta original.

Si los dos pasos salen bien, el desensamblado no se ha inventado nada.
