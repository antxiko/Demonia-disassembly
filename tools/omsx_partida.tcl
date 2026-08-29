# JUEGA UNA PARTIDA DE DEMONIA EN openMSX Y DEJA LA PRUEBA DE QUE SE JUGO.
#
# POR QUE. Del juego se sabia todo lo que dice el binario -las 24 pantallas, sus
# fichas de 88 bytes, el perseguidor, lo que cae- pero no se habia visto una
# partida. Esto la juega y, sobre todo, MIDE que se esta jugando, que es lo que
# separa "el emulador arranco" de "el personaje se movio".
#
# LO QUE MIDE, y por que es prueba y no impresion:
#
#   * 0x8049 y 0x804A son la X y la Y del jugador (el `ld hl,07880h` de 0x8869
#     las pone al empezar). Si cambian al pulsar un cursor, se esta jugando.
#   * el PC muestreado tiene que caer en `un_paso_del_juego` (0x88F8) y en la
#     zona del bucle de partida, no en la pantalla de espera (0x8411).
#   * y la pantalla se guarda en PNG en los momentos que importan.
#
# EL MANDO, sacado del listado y no supuesto: 0x8418 llama a GTSTCK (0x00D5),
# que con A=0 lee los CURSORES, y 0x85A9 llama a GTTRIG (0x00D8), que con A=0
# lee la BARRA ESPACIADORA. En la matriz del MSX las dos cosas viven en la fila
# 8: espacio el bit 0, izquierda el 4, arriba el 5, abajo el 6, derecha el 7.
#
# La maquina tiene que ser un MSX1 con ROM real (el Philips VG-8020): el juego
# llama a rutinas INTERNAS de la ROM del BASIC, asi que con C-BIOS no carga.
#
# Uso:  DEMONIA_CAS=<ruta.cas> DEMONIA_OUT=<dir> \
#           openmsx -machine Philips_VG_8020 -script este.tcl

set CAS $::env(DEMONIA_CAS)
set OUT $::env(DEMONIA_OUT)
set TOPE [expr {[info exists ::env(DEMONIA_TOPE)] ? $::env(DEMONIA_TOPE) : 900}]
file mkdir $OUT
set LOG [open "$OUT/partida.log" w]
proc say {m} {
    global LOG
    puts $LOG "\[emu [format %8.2f [machine_info time]]\] $m"
    flush $LOG
}

# --- la fila 8 de la matriz del teclado ---------------------------------------
set ::ESPACIO  0x01
set ::IZQUIERDA 0x10
set ::ARRIBA   0x20
set ::ABAJO    0x40
set ::DERECHA  0x80

proc pulsa {mask cuanto} {
    keymatrixdown 8 $mask
    after time $cuanto [list keymatrixup 8 $mask]
}

proc jugador {} {
    # X, Y y el dibujo en curso, tal como los deja 0x8869
    set x [debug read "Main RAM" 0x8049]
    set y [debug read "Main RAM" 0x804A]
    set d [debug read "Main RAM" 0x804B]
    return [format "X=%3d Y=%3d dibujo=%3d" $x $y $d]
}

say "maquina: [machine_info config_name]"
set r [catch {cassetteplayer insert $CAS} msg]
say "cassetteplayer insert rc=$r: $msg"
if {$r} { say "ABORTADO"; exit 1 }
set throttle off

proc arranca {} {
    say "tecleo RUN\\\"CAS:\\\""
    type "RUN\\\"CAS:\\\"\r"
    after time 2 vigila
}
after time 6 arranca

# --- espera a que el juego este en marcha -------------------------------------
set ::dentro 0
set ::hecho 0
proc vigila {} {
    global TOPE
    set pc [reg PC]
    if {$pc >= 0x8000 && $pc < 0xE000} { incr ::dentro } else { set ::dentro 0 }
    if {$::dentro >= 6 && !$::hecho} {
        set ::hecho 1
        say [format "el juego corre (PC=0x%04X)" $pc]
        after time 6 presentacion
        return
    }
    if {[machine_info time] > $TOPE} {
        say [format "TOPE sin ver el juego; PC=0x%04X" $pc]
        exit 1
    }
    after time 1 vigila
}

# --- la presentacion, y de ahi a la partida -----------------------------------
proc presentacion {} {
    global OUT
    screenshot -raw "$OUT/p1_presentacion.png"
    say "presentacion: [jugador]"
    say "pulso ESPACIO para empezar"
    set ::intentos 0
    empieza
}

proc empieza {} {
    global OUT
    incr ::intentos
    pulsa $::ESPACIO 0.15
    after time 3 [list mira_si_empezo]
}

proc mira_si_empezo {} {
    global OUT
    set x [debug read "Main RAM" 0x8049]
    set y [debug read "Main RAM" 0x804A]
    say "intento $::intentos tras ESPACIO: [jugador]  PC=[format 0x%04X [reg PC]]"
    screenshot -raw "$OUT/p2_intento$::intentos.png"
    # 0x8869 arranca la partida poniendo la pareja en 0x7880: X=0x80, Y=0x78
    if {($x == 0x80 && $y == 0x78) || $::intentos >= 6} {
        after time 2 mueve
        return
    }
    empieza
}

# --- ahora si: mover al personaje y medir -------------------------------------
set ::pasos 0
set ::visto {}
proc mueve {} {
    global OUT
    say "EN PARTIDA. Empiezo a mover. [jugador]"
    set ::h [dict create]
    set ::n 0
    muestrea
    paso
}

proc muestrea {} {
    dict incr ::h [reg PC]
    incr ::n
    after time 0.0005 muestrea
}

proc paso {} {
    global OUT
    incr ::pasos
    # derecha, derecha, espacio, izquierda, abajo, arriba... y vuelta
    set orden [list $::DERECHA $::DERECHA $::ESPACIO $::IZQUIERDA $::ABAJO $::ARRIBA]
    set m [lindex $orden [expr {($::pasos - 1) % 6}]]
    pulsa $m 0.4
    lappend ::visto "paso $::pasos [jugador]"
    if {$::pasos % 4 == 0} {
        screenshot -raw "$OUT/p3_juego[format %02d $::pasos].png"
    }
    if {$::pasos >= 24} { after time 2 cierra ; return }
    after time 1.2 paso
}

proc cierra {} {
    global OUT
    say "--- como se movio el jugador ---"
    foreach l $::visto { say "   $l" }
    say "--- $::n muestras del PC, [dict size $::h] direcciones distintas ---"
    set l {}
    dict for {pc v} $::h { lappend l [list $v $pc] }
    set l [lsort -integer -index 0 -decreasing $l]
    say "las 25 mas calientes:"
    foreach e [lrange $l 0 24] { say [format "   0x%04X  %7d" [lindex $e 1] [lindex $e 0]] }
    set F [open "$OUT/pc_partida.txt" w]
    foreach e $l { puts $F [format "%04X %d" [lindex $e 1] [lindex $e 0]] }
    close $F
    set F [open "$OUT/variables_partida.bin" w]
    fconfigure $F -translation binary
    puts -nonewline $F [debug read_block "Main RAM" 0x8000 256]
    close $F
    say "FIN"
    exit 0
}
