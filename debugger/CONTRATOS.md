# Reconstruccion del MONITEUR MSX (Loriciels 1984, Claude Sablatou)
# Lo que hay que rehacer de 0xD000-0xD8FF (pisado por las 24 fichas de pantalla)

El codigo del monitor (0xC24D-0xCFD3) y sus textos (0xD900-0xDAC7) SOBREVIVEN.
Toda la maquinaria de bajo nivel esta intacta y se lee del listado:
  - monitor_imprime_un_caracter (0xCCEF)      imprime A por la ventana o el BASIC
  - monitor_escribe_en_la_ventana (0xCDEE)    A -> casilla de la ventana en VRAM
  - monitor_escribe_en_vram / _direccion_de_vram (0xCE01/0xCE16)  puertos 0x99/0x98
  - monitor_escribe_hasta_el_cero (0xCB07)    imprime cadena terminada en 0x00
  - monitor_casilla_de_la_ventana             calcula la casilla (0xC1D4 = pos, 38 ancho)
  - todo el interprete, el paso a paso, el volcado de registros, los manejadores

Solo falta rehacer TRES cosas. Contrato deducido de sus PUNTOS DE LLAMADA:

## A) Subrutinas de pantalla/teclado en 0xD200-0xD2E8  (RECONSTRUIBLES por contrato)
| dir    | llamada desde            | contrato deducido |
|--------|--------------------------|-------------------|
| 0xD272 | monitor_lee_una_tecla    | espera una tecla y la devuelve en A (=CHGET, BIOS 0x009F) |
| 0xD2DB | entrada + 10 sitios       | prepara/limpia la pantalla del monitor (init VDP + borra) |
| 0xD20B | entrada + 0xCC93          | INITXT: cambia a modo TEXTO 40 col (SCREEN 0). CONFIRMADO por casilla=fila*40+col+2 |
| 0xD2D2 | entrada + 8 sitios        | salto de linea / coloca la ventana en la fila siguiente |
| 0xD260 | tras "Commande illegale"  | pausa/espera-tecla en la linea de aviso |
| 0xD21F | orden Go (0xC63F)         | prepara la vuelta al programa |
| 0xD232/48/50/58 | 0xCB20-CB2F        | cuatro variantes de una misma helper (flechas del paso a paso) |
| 0xD23A | 0xCBB0                    | idem |
| 0xD296 | 0xC5E9                    | helper de impresion de un valor |
NOTA: son primitivas cortas (~232 bytes / ~12 rutinas = ~19 bytes cada una),
todas apoyadas en la maquinaria que SI sobrevive. No son los bytes de Sablatou:
son equivalentes que cumplen el mismo contrato.

## B) Tabla de ordenes en 0xD5C6  (15 entradas x 3 bytes: inicial + puntero)
Los PUNTEROS se recuperan: son los manejadores huerfanos que siguen en el codigo.
Las LETRAS se deducen de lo que hace cada manejador y del texto que imprime.
  0xC5B6 imprime "Resultat= "   -> probable '=' (evaluar expresion)
  0xCD84 imprime en decimal      -> parte de la anterior
  0xC63F restaura y salta al PC  -> 'G' (Go/continuar)   [corroborado por el fosil]
  0xCF51 el desensamblador       -> 'L' (List/desensamblar)
  0xC97A paso a paso             -> 'T' (Trace) o 'P' (Step)
  ...resto por asignar leyendo cada manejador.
Reconstruible FUNCIONAL; las letras exactas pueden no ser las historicas.

## C) Tablas del desensamblador (0xD64A, 0xD652, 0xD662, 0xD67C, 0xD788...0xD8FF)
Deterministas: las fija el juego de instrucciones del Z80 y el codigo que las
indexa (0xCFC0, 0xCF51, 0xCFD4). Las de nombres de registro son triviales;
la tabla grande opcode->nemonico es ~2 KB y es el grueso del trabajo.
Se valida opcode a opcode.

## D) FORMATO DE LAS TABLAS DEL DESENSAMBLADOR (0xCE27), ya reverseado
El desensamblador (0xCE27) escribe el nemonico en 0xC1E4 (16 char) y el tamano
en 0xC1E3. Lee el opcode en IX y separa por prefijo (CB/ED/DD/FD/ninguno).
Tablas que hay que rehacer (todas en la zona muerta 0xD000-0xD8FF):

- **0xD67C** tabla de NEMONICOS: 4 chars por entrada (copia_el_nemonico: A*4).
  Ej. "LD  ","CALL","JP  ","ADD ". Indice = codigo de nemonico.
- **0xD5F3** tabla de FORMATOS: punteros de 2 bytes (index*2) a las RUTINAS de
  formateo de operandos. Las rutinas SOBREVIVEN (0xCF51+, escribe_el_operando);
  solo se perdio la tabla de punteros -> se reconstruye mapeando cada rutina.
- **0xD662** nombres de registro para operandos (como 0xD652). Reconstruible.
- **0xD826** tabla SIN prefijo, busqueda con MASCARA: entradas de 4 bytes
  [mascara][valor][idx_nemonico][idx_formato]. Termina en 0x00.
- **0xD88B** tabla SIN prefijo, busqueda EXACTA: 3 bytes [opcode][idx_nem][idx_fmt].
  Termina en 0xFF.
- **0xD7ED** tabla CB (mascara). **0xD816** tabla DD/FD (16 opcodes, byte exacto).
- **0xD788, 0xD7AD** mas tablas (prefijo ED, por confirmar).

REGLA DE RECONSTRUCCION: es determinista (lo fija el Z80 y estas rutinas). Se
rehace enumerando los 256 opcodes x cada prefijo, asignando nemonico+formato, y
se VALIDA desensamblando codigo conocido en openMSX (que "E016 CD" pase de
"???" a "CALL nnnn"). Es el grueso de la Fase 2.
