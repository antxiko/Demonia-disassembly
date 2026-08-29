# Preguntas abiertas

Lo que queda abierto, separando lo MEDIDO de lo SUPUESTO.

Las otras paginas: [Empezar](EMPEZAR.html) · [El juego](EL-JUEGO.html) ·
[La cinta](LA-CINTA.html) · [El codigo](EL-CODIGO.html) ·
[Hallazgos](HALLAZGOS.html) Lo medido lleva al
lado la medida; lo supuesto va marcado como tal y no se ha escrito en el
listado como si fuera un hecho.

---

## MEDIDO

### La cinta

- Trece bloques. Tres ficheros con nombre, todos llamados `DEMON`: un ASCII
  (el cargador BASIC), un BIN de 249 bytes en 0x8180 y un BIN de 24.576 bytes
  en 0x8000. Entre los dos BIN van siete bloques SIN cabecera.
- La linea 50 del cargador BASIC es `BLOAD"CAS:DEMON",R:RUN`. Como la cinta es
  secuencial, la primera vez encuentra el BIN pequeno y la segunda -despues del
  `RUN`- el grande. Los dos se llaman igual a proposito.
- `make verify` reconstruye el `.cas` entero, sha256
  `69031ee25099df0703332ca74a64b52e6dd9909e4cfded4c3699be153adc5fc9`.

### El reparto a memoria

- La tabla de 0x8180 declara los siete trozos. `tools/cuerpos.py` comprueba que
  cada entrada cuadra con el tamano de su bloque y aborta si no.
- Los cinco trozos que se esconden bajo la ROM coinciden **byte a byte** con la
  RAM de openMSX con el juego en marcha (`tools/coteja_ram.py`), y tambien con
  las instantaneas de RAM que lleva dentro el replay `Demonia.omr`, que se grabo
  en otra maquina (un Sony HB-20P). Dos medidas independientes.
- El bloque del juego difiere de la cinta en 83 bytes nada mas arrancar, todos
  dentro de 0x8000-0x80FF. En 200 segundos de juego cambian 134 bytes, 133 de
  ellos en esa misma pagina y el otro es 0x8C5E.

### Geometrias

- **Sprites**: registros de 33 bytes (32 de patron de 16x16 + 1 de color), en
  dos bancos, 242 registros en 0x0000 y 214 en 0x1F32. Sale de la rutina 0x8292
  y las dos cuentas dan exactas.
- **Mapas de pantalla**: 26 mapas comprimidos con `0xFF <baldosa> <cuantas>`.
  Descomprimidos dan 640 baldosas (32x20) cada uno y terminan exactamente donde
  empieza el siguiente. El descompresor es 0x819D.
- **Decorados**: 2048 bytes de patrones en 0x6000 y 2048 de color en 0x6800, que
  se suben a los TRES tercios de la pantalla (0x8150). Los tres tercios
  comparten dibujo.
- **Musica**: pasos de 4 bytes (tono grueso y fino del canal B, y del canal C).
  El puntero arranca en 0x7900 y al llegar al 0xFF rebobina a 0x79C8, no al
  principio.

### El titulo

El juego se llama **DEMONIA**, y lo pone su propia portada: el mapa comprimido
de 0x4281, descomprimido y dibujado con sus patrones (`tools/mapas.py`, PNG en
`docs/imagenes/portada-titulo.png`), lleva DEMONIA en letras enormes ocupando
las ocho primeras filas. Debajo, en letras pequenas, `L'INTRUSION` en la fila
17 y `(C) 1986 PAR SABLATOU CLAUDE` en la 19.

Esas dos filas de abajo son las unicas que se leen si el mapa se vuelca como
TEXTO, porque el titulo esta hecho de baldosas graficas y no de ASCII. Un
volcado asi engano una vez y de ahi salio la idea de que el juego se titulaba
`L'INTRUSION`: es el subtitulo. La cinta tambien se llama DEMONIA.

---

## SUPUESTO (marcado como tal, y sin escribir en el listado como hecho)

- **Que 0x9C72 sea una puerta trasera de depuracion.** Lo medido es que lee
  INTFLG (0xFC9B), compara con 3 y llama a la entrada del monitor. Que la
  intencion fuera dejarse una puerta abierta es una lectura, no un dato.
- **Que el `ld hl,(0x8078)` del tampon de paso a paso de 0xCC5F sea el fosil de
  una sesion de depuracion de este juego.** Lo medido son los cuatro bytes y
  que 0x8078 cae en la pagina de variables. Encaja, pero no lo dice el binario.
- **Que la tabla de ordenes del monitor la borrase el propio autor al montar el
  juego encima.** Lo medido es que en 0xD5C6 hay fichas de pantalla y no una
  tabla. Quien lo hizo y cuando, no.
- **Los dos valores iniciales del cargador (0x81F8 = 0x8188, 0x81FA = 0xC050)**
  son consistentes con una foto de la memoria tomada mientras corria el trozo 2.
  Es lo unico que se puede decir: el codigo los escribe antes de leerlos, asi
  que dan igual.

---

## ABIERTO: lo que no se ha podido cerrar

### 1. El replay del usuario no se puede reproducir aqui

`Demonia.omr` se grabo en un **Sony HB-20P**
y openMSX pide su ROM por sha1 (`63050d2d21214a721cc55f152c22b7be8061ac33`).
Esa ROM no esta en esta maquina y no se puede descargar.

Se intento tres veces:

1. Reapuntar la cinta a la local con `tools/prepara_replay.py`. La ruta se
   corrige (24 referencias), pero el fallo era otro.
2. Meter una ROM de MSX1 sustituta con ese nombre en un `filepool` propio, sin
   tocar la instalacion del usuario. openMSX resuelve las ROM de sistema **por
   sha1**, no por nombre, y la rechaza.
3. Reescribir el sha1 dentro del `.omr` para que apunte a la sustituta. **El
   replay carga y corre los 926 segundos**, pero con otra ROM la carga de cinta
   se desincroniza: el 100 % de las 1.854.327 muestras del PC caen en las
   rutinas de casete de la BIOS (0x046F, 0x047B, 0x1B2A...) y el juego no llega
   a arrancar. La medida no vale y no se ha usado.

**Lo que si se saco del replay, sin emulador**: abriendolo con gzip y
descomprimiendo sus doce instantaneas de RAM. Desde la cuarta (t=256 s) el
bloque del juego coincide al 99,5 % con el de la cinta, y los cinco trozos
escondidos bajo la ROM coinciden al 100 %. O sea que en la partida de verdad el
reparto de memoria es exactamente el que dice este proyecto. Las instantaneas
estan en `work/replay/ram_snapNN.bin` si se vuelven a extraer.

**Para cerrarlo hace falta**: el fichero `hb-20p_basic-bios1.rom` con ese sha1
en `~/Documents/openMSX/share/systemroms/`. Con eso, `tools/omsx_replay.tcl`
da el muestreo del PC de una partida entera y la seccion 6 de
[Hallazgos](HALLAZGOS.html) deja de ser un dato flojo.

### 2. Que hace el juego, jugado

No se ha documentado una partida. Lo que se sabe del juego sale del codigo y de
sus datos: 24 pantallas con su ficha de 88 bytes y sus cuatro rutinas de
conducta, un interprete de guiones de doce opcodes, marcador con `SCORE=`,
`RECORD=` y `FORCE=`, y un `GAME OVER`. Falta atar cada pantalla con lo que se
ve, y para eso el camino bueno es el replay del punto 1.

### 3. Las fichas de pantalla, por dentro

Se sabe que son 24 fichas de 88 bytes en 0xD0C0-0xD8FF y que el byte 84 de cada
una lleva la marca `FF <numero de pantalla en ASCII> FF`. **No** se ha
desmenuzado el resto de los 88 bytes campo a campo. Se ve que hay grupos de
tres bytes que empiezan por 0x06, 0x0E, 0x15 y 0x1B -numeros que crecen y que
podrian ser posiciones- pero eso es una impresion, no una medida, y por eso no
esta en el listado.

### 4. Las tablas cortas sin identificar

Quedan doce tramos de datos con nombre pero sin uso explicado, porque se sabe
QUIEN los lee pero no PARA QUE. Son: 0x89F1, 0x8C58, 0x9B47, 0xA5E4, 0xA7FF,
0xB4F0, 0xB540, 0xBA64, 0xBDB1, 0xDAD7 y las dos de baldosas 0xA830 y 0xDAA3.
En el listado estan con la direccion de la instruccion que las carga, que es lo
que se sabe.

De 0xB4F0 si se sabe la forma: siete registros de diez bytes, y los campos
avanzan a paso fijo de un registro al siguiente (+0x18 en el tercer byte,
+0x300 en la pareja siguiente, +1 en el octavo). Parece una tabla de siete
cosas iguales colocadas en fila; que cosas, no se ha medido.

### 5. El tempo de la musica

El reproductor de 0x7F90 cambia de nota cada 14 llamadas (0x7F9B). **No se ha
medido a cuantas llamadas por segundo va**, asi que no se puede dar un tempo en
notas por minuto ni decir si eso depende de PAL o NTSC. Lo que si esta medido
son los periodos del PSG: el primer paso da 679 en el canal B y 339 en el C, o
sea 329,5 Hz y 659,1 Hz con el reloj del MSX (3.579.545/16), la misma nota a una
octava.

### 6. Los tres RET NC del cargador

En 0x823A hay tres `RET NC` seguidos donde con uno bastaba: el primero ya
vuelve. No se ha encontrado explicacion. Puede ser un salto relativo que se
cambio por un RET y dejo dos bytes detras, pero eso es una suposicion.
