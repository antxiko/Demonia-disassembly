# MIDE EL JUEGO YA CARGADO: vuelca la RAM y muestrea el contador de programa.
#
# Parte del savestate que deja tools/omsx_carga.tcl, para no repetir los cuatro
# minutos de cinta en cada medida.
#
# Dos salidas, y las dos son prueba de cosas distintas:
#
#   ram64k.bin  los 64 KB de RAM tal cual estan. Comparado con la imagen que
#               monta tools/imagen.py, demuestra que el reparto de la cinta a
#               memoria que dice el proyecto es el que ocurre de verdad.
#   pc.txt      cuantas veces se ha visto el PC en cada direccion. Es lo que
#               separa "el trazador puede llegar aqui" de "esto se ejecuta".
#               OJO: que una direccion no salga NO prueba que este muerta; solo
#               que no se ha ejecutado en esta ventana.
#
# Uso:  DEMONIA_OUT=<dir> [DEMONIA_SEG=<segundos de muestreo>]
#           openmsx -machine Philips_VG_8020 -script este.tcl

set OUT $::env(DEMONIA_OUT)
set SEG [expr {[info exists ::env(DEMONIA_SEG)] ? $::env(DEMONIA_SEG) : 120}]
file mkdir $OUT
set LOG [open "$OUT/medida.log" w]
proc say {m} {
    global LOG
    puts $LOG "\[emu [format %8.2f [machine_info time]]\] $m"
    flush $LOG
}

set r [catch {loadstate} msg]
say "loadstate rc=$r: $msg"
if {$r} { say "ABORTADO"; exit 1 }
set throttle off
say [format "arranco en PC=0x%04X" [reg PC]]

# --- volcado de la RAM ------------------------------------------------------
set F [open "$OUT/ram64k.bin" w]
fconfigure $F -translation binary
puts -nonewline $F [debug read_block "Main RAM" 0 [debug size "Main RAM"]]
close $F
say "RAM volcada: [debug size {Main RAM}] bytes -> $OUT/ram64k.bin"

# --- muestreo del PC --------------------------------------------------------
set ::h [dict create]
set ::n 0
proc muestrea {} {
    dict incr ::h [reg PC]
    incr ::n
    after time 0.0005 muestrea
}
set ::T0 [machine_info time]
muestrea

proc vigila {} {
    global OUT SEG
    if {[machine_info time] - $::T0 >= $SEG} {
        say "$::n muestras, [dict size $::h] direcciones distintas"
        set l {}
        dict for {pc v} $::h { lappend l [list $v $pc] }
        set l [lsort -integer -index 0 -decreasing $l]
        say "las 20 mas calientes:"
        foreach e [lrange $l 0 19] {
            say [format "   0x%04X  %7d" [lindex $e 1] [lindex $e 0]]
        }
        set F [open "$OUT/pc.txt" w]
        foreach e $l { puts $F [format "%04X %d" [lindex $e 1] [lindex $e 0]] }
        close $F
        # Segundo volcado: si el juego escribe en su propio bloque, aqui se ve.
        set F [open "$OUT/ram64k_fin.bin" w]
        fconfigure $F -translation binary
        puts -nonewline $F [debug read_block "Main RAM" 0 [debug size "Main RAM"]]
        close $F
        say "FIN"
        exit 0
    }
    after time 2 vigila
}
after time 2 vigila
