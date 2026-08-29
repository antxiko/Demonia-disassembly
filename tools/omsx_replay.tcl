# QUE SE EJECUTA DE VERDAD EN UNA PARTIDA: muestreo del PC sobre el replay.
#
# El replay es una partida real del usuario. Vale mucho mas que dejar el juego
# solo: recorre pantallas y situaciones a las que el attract no llega, y sale
# igual todas las veces, asi que la medida es repetible.
#
# La resta (lo que el trazador alcanza) - (lo que aqui se ejecuta) da los
# CANDIDATOS a codigo muerto. Candidatos: que algo no salga en esta partida no
# prueba que este muerto, solo que aqui no se ha ejecutado.
#
# Ademas del PC se apunta el registro de slots (puerto 0xA8) en cada muestra:
# es lo que distingue una direccion baja que es BIOS de una que es RAM del
# juego, y en este juego eso cambia varias veces por fotograma.
#
# Uso:  DEMONIA_REPLAY=<ruta.omr> DEMONIA_OUT=<dir> [DEMONIA_T=<ini>] [DEMONIA_FIN=<fin>]
#           openmsx -script este.tcl

set REPLAY $::env(DEMONIA_REPLAY)
set OUT    $::env(DEMONIA_OUT)
file mkdir $OUT
set LOG [open "$OUT/replay.log" w]
proc say {m} {
    global LOG
    puts $LOG "\[emu [format %8.2f [machine_info time]]\] $m"
    flush $LOG
}

# El replay se grabo en un Sony HB-20P y pide su ROM por sha1. Aqui no esta, y
# no se puede descargar. Se le anade al filepool un directorio del proyecto con
# una ROM de MSX1 SUSTITUTA bajo ese nombre, a ver si openMSX la acepta.
# ESTO NO ES GRATIS: si openMSX la traga, la maquina no es la misma y el replay
# puede desincronizarse. Por eso mas abajo se vigila donde acaba el PC: si no
# esta en la zona del juego, la medida NO VALE y hay que decirlo.
if {[info exists ::env(DEMONIA_ROMS)]} {
    set r [catch {filepool add -path $::env(DEMONIA_ROMS) -types system_rom -position 1} m]
    say "filepool add rc=$r: $m"
    say "filepool: [filepool list]"
}
set r [catch {reverse loadreplay -viewonly $REPLAY} msg]
say "loadreplay rc=$r: $msg"
if {$r} { say "ABORTADO"; exit 1 }
array set st [reverse status]
set T   [expr {[info exists ::env(DEMONIA_T)]   ? $::env(DEMONIA_T)   : $st(begin)}]
set FIN [expr {[info exists ::env(DEMONIA_FIN)] ? $::env(DEMONIA_FIN) : $st(end)}]
say "replay de $st(begin) a $st(end); ventana $T-$FIN"
say "maquina: [machine_info config_name]"
if {$T > $st(begin)} { set r [catch {reverse goto $T} msg]; say "goto rc=$r: $msg" }
set throttle off

set ::h [dict create]
set ::pag0 [dict create]
set ::n 0
proc muestrea {} {
    set pc [reg PC]
    dict incr ::h $pc
    if {$pc < 0x8000} { dict incr ::pag0 [debug read "ioports" 0xA8] }
    incr ::n
    after time 0.0005 muestrea
}
muestrea

proc vigila {} {
    global FIN OUT
    if {[machine_info time] >= $FIN} {
        say "$::n muestras, [dict size $::h] direcciones distintas"
        set l {}
        dict for {pc v} $::h { lappend l [list $v $pc] }
        set l [lsort -integer -index 0 -decreasing $l]
        say "las 25 mas calientes:"
        foreach e [lrange $l 0 24] {
            say [format "   0x%04X  %8d" [lindex $e 1] [lindex $e 0]]
        }
        say "reparto del puerto 0xA8 cuando el PC esta por debajo de 0x8000:"
        dict for {a8 v} $::pag0 { say [format "   A8=0x%02X  %8d muestras" $a8 $v] }
        set F [open "$OUT/pc_replay.txt" w]
        foreach e $l { puts $F [format "%04X %d" [lindex $e 1] [lindex $e 0]] }
        close $F
        set F [open "$OUT/ram_replay.bin" w]
        fconfigure $F -translation binary
        puts -nonewline $F [debug read_block "Main RAM" 0 [debug size "Main RAM"]]
        close $F
        say "FIN"
        exit 0
    }
    after time 5 vigila
}
after time 5 vigila
