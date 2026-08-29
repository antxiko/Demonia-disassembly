# Empezar

Este repositorio contiene un **desensamblado comentado** de Demonia para MSX
(Microids, 1986, cinta). Todo lo que hay aquí sale del binario y se puede
volver a generar a partir de él.

## Qué hace falta

- **Python 3** (sin paquetes de terceros)
- **pasmo**, para reensamblar
- **z80dasm**, sólo para los nemónicos
- la cinta, que este repositorio **no distribuye**

La cinta va en la raíz, con el nombre `demonia.cas`. Son exactamente 58.334
bytes:

    sha256  69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9

El `Makefile` la pide por ese sha256 y avisa si no cuadra.

## La comprobación que importa

    make verify

Reensambla los trece listados con pasmo y compara el resultado con el `.cas`
original, byte a byte. Aquí eso tiene un paso más que en un cartucho: primero
se comprueba cada listado por separado y luego se pegan los trozos en el orden
en que la cinta los trae, con sus centinelas, sus cabeceras y su relleno. Si
sale `OK`, el desensamblado no se ha inventado nada: es la misma cinta escrita
de otra manera.

## Todo lo demás que se puede lanzar

    make            # el ciclo entero: extraer, trazar, listar, verificar
    make listados   # regenera los trece src/demonia_*.asm
    make sanity     # las comprobaciones que el reensamblado NO cubre
    make test       # los tests
    make densidad   # cuántos comentarios lleva cada rutina
    make sobra      # las cuentas de lo que el juego lleva y no usa
    make imagenes   # redibuja los PNG de docs/imagenes desde la cinta
    make web        # regenera esta web

`make sanity` es el que vigila lo que un reensamblado correcto puede esconder:
datos leídos como código. Los bytes salen igual de las dos maneras, porque no
cambian; lo único que cambia es lo que decimos de ellos.

## Los tests corren sin la cinta

Los diecinueve tests de `tests/` **no necesitan la cinta ni `make`**: leen los
trece listados publicados, que es donde está cada byte —las filas `defb` traen
los datos con su dirección, y las instrucciones traen la suya en el comentario.

Se hizo así a propósito. Un test que se salta solo cuando falta un fichero es
un sitio donde esconder una comprobación que en realidad no se hace nunca; y
además lo que se publica es el listado, así que es el listado lo que hay que
vigilar. Si alguien edita un `defb` a mano, los tests se enteran. Y no se
pierde rigor, porque `make verify` ya demuestra que ensamblar esos listados
devuelve la cinta exacta.

## Por dónde seguir

- [El juego](EL-JUEGO.html) — qué es Demonia y cómo está montado por dentro
- [La cinta](LA-CINTA.html) — trece bloques, tres ficheros que se llaman igual
  y 26 KB escondidos debajo de la ROM
- [El código](EL-CODIGO.html) — el mapa de memoria, las tablas y el polizón
- [Hallazgos](HALLAZGOS.html) — lo que apareció al desmontarla
- [Preguntas abiertas](PREGUNTAS-ABIERTAS.html) — lo que no se ha podido cerrar
