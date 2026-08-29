# Aviso legal y atribución

*(Also available [in English](LEGAL-NOTICE.md).)*

## De quién es cada cosa

**El juego no es nuestro.** *Demonia* es un juego de MSX de 1986. Su propia
portada, que está en el mapa comprimido de `0x4281` y se lee descomprimiéndolo,
pone DEMONIA en letras grandes y lo firma `(C) 1986 PAR SABLATOU CLAUDE`. Que
lo publicara **Microids** sale del catálogo y no del binario, y por eso va
dicho así. Todos los derechos sobre el juego siguen siendo de sus titulares.

Dentro de la cinta viaja además un **monitor de código máquina** firmado
`Copyright (C) 1984 LORICIELS` y `Auteur:Claude SABLATOU`, en los textos de
`0xD948`. Está documentado aquí porque forma parte de lo que la cinta contiene,
y sus derechos son igualmente de sus titulares.

**Lo que sí es nuestro** son las herramientas de este repositorio, los
comentarios del listado, el análisis y la documentación. Eso se publica con la
licencia de `LICENSE`.

## Qué hay en este repositorio

Los trece ficheros `src/demonia_*.asm` son el desensamblado comentado de la
cinta. Se publican para la **preservación, el estudio y la documentación** de un
título que es parte de la historia del software del MSX.

La cinta (`.cas`) **no** se distribuye aquí. Quien quiera volver a montar los
listados tiene que poner la suya, y el `Makefile` comprueba su sha256 antes de
hacer nada.

Las imágenes que produce `tools/mapas.py` no son ilustraciones traídas de fuera
ni capturas de un emulador: son la pantalla del propio juego, reconstruida
repitiendo su descompresor sobre los mapas comprimidos —las mismas direcciones
y el mismo orden que están en el listado— y revelando cada baldosa como lo haría
el VDP, con los patrones de `0x6000` y los colores de `0x6800`. Son parte de la
prueba de que la lectura del binario es correcta: si estuviera mal, saldría
ruido.

## En qué se apoya

En nada de nadie. Todo lo que se afirma aquí sale de leer este binario, y cada
afirmación lleva su evidencia al lado: la instrucción que lee un dato, la cadena
de veintiséis mapas que acaba exactamente donde tiene que acabar, o la cuenta
que sale sola. Lo que no está cerrado se dice que no lo está, y tiene su sitio
en la página de preguntas abiertas.

## Si eres uno de los autores

Si trabajaste en *Demonia* o tienes derechos sobre el juego, y preferirías que
este material no estuviera publicado, **dilo y se retira, sin discusión**. La
intención de este trabajo es justo la contraria de perjudicarte: es dejar
constancia de cómo se hizo.
