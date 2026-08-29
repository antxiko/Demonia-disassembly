# El código

[Empezar](EMPEZAR.html) · [El juego](EL-JUEGO.html) · [La cinta](LA-CINTA.html) · [Hallazgos](HALLAZGOS.html) · [Preguntas abiertas](PREGUNTAS-ABIERTAS.html)

## El mapa de memoria, una vez cargado

Cuando los siete trozos han terminado de moverse, la memoria del MSX queda así.
Son **50.712 bytes ocupados de los 65.536**, el 77,4 % del mapa:

| dirección | bytes | qué hay | de qué trozo |
|---|---:|---|---|
| `0x0000-0x1F31` | 7.986 | primer banco de sprites: 242 registros de 33 bytes | carga 4 |
| `0x1F32-0x3AC7` | 7.062 | segundo banco: 214 registros | carga 5 |
| `0x4000-0x5467` | 5.224 | los 26 mapas de pantalla comprimidos | carga 3 |
| `0x6000-0x6FFF` | 4.096 | los decorados: 2.048 de patrón y 2.048 de color | carga 6 |
| `0x7900-0x7FE7` | 1.768 | la música | carga 7 |
| `0x8000-0xDFFF` | 24.576 | el juego entero | el BIN grande |

Las cuatro primeras filas y la quinta están **debajo de la ROM del BASIC**: son
las páginas 0 y 1, que en un MSX arrancado normalmente no son RAM. Sólo el
bloque de `0x8000` vive donde se le ve.

Y `0x5480`, justo detrás de los mapas comprimidos, es donde el descompresor
deja el mapa de la pantalla en curso: 640 baldosas sin comprimir.

## Las tres tablas que gobiernan el juego

Están las tres seguidas, al final del bloque del juego:

| dirección | tamaño | qué es |
|---|---|---|
| `0xD000` | 24 × 2 | puntero al mapa comprimido de cada pantalla |
| `0xD030` | 24 × 4 punteros | la conducta de cada pantalla |
| `0xD0C0` | 24 × 88 bytes | la ficha de cada pantalla |

La **tabla de conducta** es lo más parecido a un guion que tiene este juego:
cada pantalla declara hasta cuatro rutinas, y las que no usa no se dejan a cero
sino apuntando a `0xFD9A`, el vector del sonido. Es una forma barata de decir
«aquí no hay nada que hacer» sin tener que comprobar nada.

Las **fichas** se acotaron por una marca que llevan todas en el byte 84:
`FF <número de pantalla en ASCII> FF`. La primera cae en `0xD114` y la última
en `0xD8FC`, siempre a 88 bytes de distancia; con eso se pudo separar una a una
sin suponer nada.

## Código que se escribe encima

Este juego se automodifica en varios sitios, y conviene saberlo antes de leer
el listado:

- `0xABB3` escribe en `0xAB1A`, que es **el operando de un `ld c,n`**, para
  cambiar de banco de sprites.
- `0x864E` y `0x8653` parchean dos operandos, los de `0x8603` y `0x8623`.
- Y dentro del monitor de Loriciels, `0xC645` escribe la dirección de vuelta
  encima del operando del `jp` de `0xC65E`.

Los mismos operandos hacen de variables: el cargador de cinta guarda en
`0x81F8` el puntero a la entrada que está leyendo y en `0x81FA` la dirección de
ejecución del trozo, y los escribe los dos antes de leerlos, así que los
valores que trae la cinta dan igual.

## Cómo se hizo el listado

No es un desensamblado lineal. Se traza el flujo de verdad desde los puntos de
entrada y sólo se marca como código lo que se alcanza; el resto queda como
datos y hay que explicarlo.

- **55 puntos de entrada**, y cada uno lleva escrito en el fichero
  `src/imagen.entries` **por qué** es un punto de entrada: un retorno empujado
  a la pila, una tabla de saltos, un operando automodificado. Hay un test que
  falla si alguno se queda sin justificación.
- **277 directivas `D`** acotan los rangos de datos, cada uno con su nombre y
  la anchura de su estructura.
- `make sanity` cruza las dos cosas: ninguna zona declarada como datos puede
  salir como código, y ningún punto de entrada puede caer dentro de una zona de
  datos.

El trazado se validó además con el emulador: se muestreó el contador de
programa durante 200 segundos de juego real en un Philips VG-8020 y salieron
1.357 direcciones distintas. **Las 1.357 caen dentro de lo que el trazador
marca como código, ni una fuera.**

(Al revés no vale: ese muestreo coge el PC cada 0,5 ms y ve una fracción mínima
de lo que corre, así que no dice nada sobre qué código está muerto. Para eso
está [Hallazgos](HALLAZGOS.html), que lo mide de otra manera.)

## Los comentarios, medidos

De poco sirve un listado completo si está mudo. La vara de la serie es doble:

    make densidad

    TOTAL             9790    3230     33,0%     1308       0

Nueve mil setecientas noventa instrucciones, tres mil doscientas treinta con
comentario de línea: **33,0 % de densidad**. Y la segunda cifra, que es la que
cuesta: **cero rutinas por debajo del 10 %**, de 1.308.

El listón de la serie es 22 % de densidad y ninguna rutina floja. Este es, de
los desensamblados publicados, uno de los más densos.
