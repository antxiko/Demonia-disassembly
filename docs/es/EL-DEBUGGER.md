# El debugger, devuelto a la vida

Demonia lleva dentro un monitor de código máquina entero — un **debugger**, que
Claude Sablatou escribió para Loriciels en 1984 y que viaja en el juego de 1986
porque el mismo hombre firmó los dos. La página de [Hallazgos](HALLAZGOS.html)
cuenta cómo se encontró y por qué, en esta cinta, **ya no responde**: el juego
grabó sus 24 fichas de pantalla justo encima de su sección de datos
(`0xD000`-`0xD8FF`), borrándole la tabla de órdenes, las tablas del
desensamblador y una docena de subrutinas de pantalla y teclado.

Esta página va de ponerlo otra vez en pie — y funciona.

> **Que quede claro desde el principio: esto no es el debugger original
> recuperado entero. No tenemos el 100% del código de Sablatou.** Cerca del 40%
> del monitor — los datos y rutinas que el juego borró — ya no existe en ninguna
> parte y hubo que rehacerlo. Lo que corre es más o menos un 60% de su código
> original superviviente y un 40% reconstruido para encajar: un equivalente que
> funciona, no el original perdido.

![El monitor resucitado, arrancado suelto, pintando los doce registros del programa detenido](imagenes/monitor-registros.png)

## Qué sobrevivió y qué no

El sesenta por ciento del monitor está intacto: su intérprete de órdenes, su
paso a paso, su volcado de registros, el **código** del desensamblador y todos
sus textos siguen vivos de `0xC24D` a `0xCFFF` y de `0xD900` a `0xDAC7`. Lo que
el juego destrozó fueron sus **datos**, en `0xD000`-`0xD8FF`:

| pieza perdida | qué era |
|---|---|
| tabla de órdenes (`0xD5C6`) | 15 entradas de *inicial + puntero al manejador* |
| tablas del desensamblador (`0xD64A`, `0xD67C`, `0xD826`, `0xD88B`, `0xD5F3`…) | ~2 KB: nemónicos, mapas de opcode, punteros de formato |
| subrutinas de pantalla/teclado (`0xD200`-`0xD2E8`) | limpiar, salto de línea, esperar tecla… |

**Esto es una reconstrucción, no una recuperación.** Los bytes originales de
Sablatou para esas tablas y rutinas se perdieron para siempre. Lo que sigue es
un *equivalente funcional*: código y datos nuevos que cumplen los mismos
contratos que espera el código superviviente, para que su código vuelva a correr
y el monitor se comporte como lo hacía.

## Devolver el monitor interactivo

La maquinaria de bajo nivel que sobrevive — escribir un carácter en pantalla,
leer el teclado, el despachador de órdenes, los manejadores — solo necesitó que
se rehicieran un puñado de sus helpers borradas, deducidas de cómo las llaman los
supervivientes: `0x0072`/INITXT para su pantalla de texto de 40 columnas
(demostrado por su propia geometría de casilla, `fila*40 + columna + 2`), CHGET
para la espera de tecla, y las primitivas de borrado. Con eso puesto, el monitor
**arranca, monta su pantalla y pinta los doce registros del programa detenido** —
la imagen de arriba, donde `HL=1234`, `DE=5678`, `IX=AAAA` son los valores que un
pequeño lanzador puso ahí a propósito.

La tabla de órdenes se rehízo letra a letra desde los manejadores supervivientes.
Dos están cableadas y probadas de momento:

**`G` — Go.** El manejador de `0xC5D3` lee una dirección en hexadecimal, la
guarda y salta ahí. El [fósil](HALLAZGOS.html) dejó lo último que el autor
tecleó, `G7FE0`, congelado en el tampón de entrada. Teclear esa misma orden en el
monitor resucitado salta a la rutina de sonido de `0x7FE0` — su sesión de
depuración de 1986, repetida a mano:

![Tecleando G7FE0H — la orden fosilizada del autor — de vuelta en el monitor](imagenes/monitor-orden-g.png)

## El desensamblador

El desensamblador fue lo difícil. Sus tablas fueron lo más a fondo borrado, y las
rutinas que formateaban sus operandos vivían también en la zona muerta. Así que
el desensamblador es el *equivalente* más completo: un desensamblador Z80
compacto que cumple el contrato del monitor — dada una dirección en `IX`, escribe
el texto del nemónico y la longitud de la instrucción exactamente donde el código
de pantalla superviviente (`0xC568`) los espera. Solo hubo que repuntar esa única
llamada.

Cubre **todo el juego de instrucciones del Z80** — sin prefijo, `CB`, `ED`,
`DD`/`FD` (IX/IY) y `DDCB`/`FDCB` — y se comprobó instrucción a instrucción en el
emulador: **38 de 38 correctas**, incluidos los saltos relativos, los
desplazamientos `(IX+d)` y `(IY-d)` y todas las longitudes. El volcado de
registros ya lo demuestra en pantalla — la línea bajo los registros desensambla
la instrucción del contador de programa:

![La línea bajo los registros desensambla la instrucción del PC: CALL C924](imagenes/monitor-pc.png)

Y con la orden `L` (listar) cableada a su manejador superviviente en `0xC535`, el
monitor desensambla cualquier rango. La prueba más fina que hay: **el monitor
desensamblando su propio código máquina**, su rutina de entrada, en vivo en
pantalla — `LD (C1F6),SP`, `IM 1`, la ristra de `PUSH` que guarda los registros,
`LD SP,(C1F6)`:

![El monitor desensamblando su propia rutina de entrada, línea a línea](imagenes/monitor-listado.png)

## Cómo se lee, y cómo se hizo

Los números usan la convención Intel/Loriciels que espera el parser: una
dirección en hexadecimal lleva una `H` detrás (`L7FE0H,7FE6H`). La reconstrucción
vive en el repositorio bajo `debugger/`: el generador del desensamblador
(`gen_disasm.py`), las helpers y la tabla de órdenes rehechas, y los guiones de
openMSX que arrancan el monitor y capturaron cada pantallazo de esta página en un
MSX1 real (un Philips VG-8020). Aquí no hay ningún montaje; cada imagen es un
fotograma en crudo del emulador corriendo el monitor reconstruido.

*Cuidado con la afirmación: lo medido es que el monitor reconstruido arranca,
acepta órdenes y desensambla bien, mostrado por las capturas y una comprobación
de 38/38 instrucciones. Lo que es reconstrucción — dicho claro — son las letras
de la tabla de órdenes, las rutinas helper rehechas y el propio desensamblador;
son equivalentes, no los originales perdidos de Sablatou.*
