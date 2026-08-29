# CARGA LA CINTA DE DEMONIA Y GUARDA UN SAVESTATE CON EL JUEGO YA EN MARCHA.
#
# Por que un savestate: la cinta son 58 KB a 1200 baudios, casi nueve minutos de
# tiempo emulado. Cargarla una vez y guardar el estado ahorra esa espera en
# todas las medidas siguientes.
#
# La maquina tiene que ser un MSX1 con ROM real (aqui, el Philips VG-8020): el
# juego llama a rutinas INTERNAS de la ROM del BASIC -0x72E9 y 0x72D4, los
# envoltorios de TAPION y TAPIN con control de error- asi que con C-BIOS no
# carga.
#
# Uso:  DEMONIA_CAS=<ruta.cas> DEMONIA_OUT=<dir> [DEMONIA_TOPE=<segundos>]
#           openmsx -machine Philips_VG_8020 -script este.tcl

set CAS  $::env(DEMONIA_CAS)
set OUT  $::env(DEMONIA_OUT)
set TOPE [expr {[info exists ::env(DEMONIA_TOPE)] ? $::env(DEMONIA_TOPE) : 1200}]
set SEG  [expr {[info exists ::env(DEMONIA_SEG)]  ? $::env(DEMONIA_SEG)  : 120}]
file mkdir $OUT
set LOG [open "$OUT/carga.log" w]
proc say {m} {
    global LOG
    puts $LOG "\[emu [format %8.2f [machine_info time]]\] $m"
    flush $LOG
}

say "maquina: [machine_info config_name]"
set r [catch {cassetteplayer insert $CAS} msg]
say "cassetteplayer insert rc=$r: $msg"
if {$r} { say "ABORTADO"; exit 1 }
set throttle off

# Deja arrancar el BASIC antes de teclear.
proc arranca {} {
    say "tecleo RUN\"CAS:\""
    type "RUN\\\"CAS:\\\"\r"
    after time 2 vigila
}
after time 6 arranca

# Vigilancia: el juego esta en marcha cuando el PC vive en 0x8000-0xDFFF.
set ::dentro 0
set ::hecho 0
proc vigila {} {
    global OUT TOPE
    set pc [reg PC]
    if {$pc >= 0x8000 && $pc < 0xE000} { incr ::dentro } else { set ::dentro 0 }
    if {$::dentro >= 6 && !$::hecho} {
        set ::hecho 1
        say [format "PC estable en zona de juego (0x%04X); guardo savestate" $pc]
        # Un respiro para que el juego termine de arrancar.
        after time 4 guarda
        return
    }
    if {[machine_info time] > $TOPE} {
        say [format "TOPE alcanzado sin ver el juego; PC=0x%04X" $pc]
        say "FIN"
        exit 1
    }
    after time 1 vigila
}

proc vuelca {nombre} {
    global OUT
    set F [open "$OUT/$nombre" w]
    fconfigure $F -translation binary
    puts -nonewline $F [debug read_block "Main RAM" 0 [debug size "Main RAM"]]
    close $F
    say "RAM volcada -> $OUT/$nombre"
}

proc guarda {} {
    global OUT SEG
    # Volcado de los 64 KB de RAM. Es la prueba dura de que la imagen que monta
    # tools/imagen.py es la memoria de verdad: se comparan byte a byte.
    vuelca ram64k.bin
    catch {savestate} msg
    say "savestate: $msg"
    say [format "PC=0x%04X  SP=0x%04X" [reg PC] [reg SP]]
    # Muestreo del PC: lo que separa "el trazador puede llegar" de "se ejecuta".
    set ::h [dict create]
    set ::n 0
    set ::T0 [machine_info time]
    muestrea
    after time 2 cierra
}

proc muestrea {} {
    dict incr ::h [reg PC]
    incr ::n
    after time 0.0005 muestrea
}

proc cierra {} {
    global OUT SEG
    if {[machine_info time] - $::T0 < $SEG} { after time 2 cierra ; return }
    say "$::n muestras, [dict size $::h] direcciones distintas"
    set l {}
    dict for {pc v} $::h { lappend l [list $v $pc] }
    set l [lsort -integer -index 0 -decreasing $l]
    say "las 20 mas calientes:"
    foreach e [lrange $l 0 19] { say [format "   0x%04X  %7d" [lindex $e 1] [lindex $e 0]] }
    set F [open "$OUT/pc.txt" w]
    foreach e $l { puts $F [format "%04X %d" [lindex $e 1] [lindex $e 0]] }
    close $F
    vuelca ram64k_fin.bin
    say "FIN"
    exit 0
}
