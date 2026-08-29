# Demonia (MSX, 1986) - desensamblado comentado

*(Also available [in English](README.md).)*

Desensamblado completo y reproducible byte a byte de la cinta de Demonia para
MSX1. El listado se genera a partir de un trazado de flujo real, no de un
desensamblado lineal, y `make verify` comprueba que al ensamblarlo vuelve a
salir el `.cas` original, con su mismo sha256.

## La cinta no esta aqui

Este repositorio contiene solo el trabajo de documentacion. Para reconstruirlo
todo hace falta tu propia copia de la cinta, con el nombre `demonia.cas` en la
raiz y este sha256:

    69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9

## Que tiene de raro este juego

No cabe en la RAM visible de un MSX arrancado desde BASIC. Lo que hace es
buscar un slot con 64 KB y esconder 26 KB **debajo de la ROM del BASIC**, en
las paginas 0 y 1. Los siete bloques que la cinta trae detras del cargador no
se ejecutan donde se cargan: cada uno lleva pegada una rutinilla que conmuta el
slot, hace un LDIR y lo devuelve.

Por eso aqui hay trece listados y no nueve, y por eso el verify tiene dos
pasos: primero cada listado, y despues pegar los trozos en el orden de la cinta.

Y hay algo mas, que esta contado en [docs/es/HALLAZGOS.md](docs/es/HALLAZGOS.md):
dentro del bloque del juego viaja un **monitor de codigo maquina** de Loriciels
de 1984, del mismo autor, con su puerta de entrada todavia enchufada y sus
ordenes ya inservibles.

## Uso

    make verify     # extrae, traza, genera y comprueba byte a byte
    make sanity     # coherencia del trazado y presupuesto al 100 %
    make densidad   # densidad de comentarios contra el liston de la serie
    make sobra      # las cuentas de lo que sobra
    make test       # los tests

Hace falta `pasmo`, `z80dasm` y `python3`.

Y para la web:

    make imagenes   # redibuja los PNG desde la cinta
    make web        # genera docs/ y docs/es/

## Documentacion

La web del proyecto es bilingue y se genera con `make web`. Las paginas viven
en `docs/` (ingles) y `docs/es/` (castellano):

- [docs/es/HALLAZGOS.md](docs/es/HALLAZGOS.md) - todo lo que el juego lleva
  dentro y no usa, con la cuenta delante ([in English](docs/FINDINGS.md)).
- [docs/es/EL-DEBUGGER.md](docs/es/EL-DEBUGGER.md) - el monitor de Loriciels de
  1984 que lleva dentro, **reconstruido y funcionando** (un equivalente: NO
  sobrevive el 100% del codigo original - ver [debugger/](debugger/)).
- [docs/es/PREGUNTAS-ABIERTAS.md](docs/es/PREGUNTAS-ABIERTAS.md) - lo que queda
  abierto, separando lo MEDIDO de lo SUPUESTO
  ([in English](docs/OPEN-QUESTIONS.md)).
- [docs/es/LA-CINTA.md](docs/es/LA-CINTA.md) - los trece bloques, los tres
  ficheros que se llaman igual y los 26 KB escondidos
  ([in English](docs/THE-TAPE.md)).
- [docs/es/EL-JUEGO.md](docs/es/EL-JUEGO.md) y
  [docs/es/EL-CODIGO.md](docs/es/EL-CODIGO.md) - como esta montado por dentro
  ([in English](docs/THE-GAME.md) y [the code](docs/THE-CODE.md)).

Las imagenes de `docs/imagenes/` **no son capturas**: las dibuja
`tools/mapas.py` desde los bytes de la cinta, repitiendo el descompresor del
propio juego y revelando cada baldosa como lo haria el VDP.

## Licencia y atribucion

Las herramientas, los comentarios y la documentacion de este repositorio van con
la licencia de [LICENSE](LICENSE). **El juego no**: sus derechos siguen siendo
de sus titulares, y la cinta no se distribuye aqui. Esta contado en
[AVISO-LEGAL.md](AVISO-LEGAL.md).
