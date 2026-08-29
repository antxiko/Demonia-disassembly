# Arnes de openMSX: arranca el monitor reconstruido y le teclea ordenes.
#   openmsx -machine Philips_VG_8020 -script omsx_ordenes.tcl
# Variables de entorno:
#   MON_DIR   carpeta con monitor_boot.bin, disasm.bin y lanzador.bin
#   MON_OUT   carpeta de salida (ruta Windows): capturas PNG, volcados de pantalla y ordenes.log
#   MON_STEPS fichero Tcl que define la lista `steps`: {texto espera_s nombre} por paso.
#             El texto se mete en el tampon del teclado (type_via_keybuf); "" = solo captura.
#   MON_ENTRADA  (opcional) "frio" arranca por 0xC20E; si no, por el lanzador (0xE000)
set OUT $::env(MON_OUT); file mkdir $OUT
set LOG [open "$OUT/ordenes.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }
proc hex {addr n} { set s ""; for {set i 0} {$i<$n} {incr i} { append s [format "%02X " [debug read {Main RAM} [expr {$addr+$i}]]] }; return $s }
proc pantalla {} {
    # las 24 filas de la tabla de nombres (SCREEN 0: VRAM 0..959), como texto
    set t ""
    for {set f 0} {$f<24} {incr f} {
        set l ""
        for {set c 0} {$c<40} {incr c} {
            set b [debug read VRAM [expr {$f*40+$c}]]
            if {$b<32 || $b>126} {set b 46}
            append l [format %c $b]
        }
        append t "[format %02d $f] $l\n"
    }
    return $t
}
set steps {}
source $::env(MON_STEPS)
set i 0
proc siguiente {} {
    global steps i
    if {$i >= [llength $steps]} { say "fin"; exit }
    lassign [lindex $steps $i] texto espera nombre
    incr i
    if {$texto ne ""} {
        say "tecleo [string map {\r <CR> \x03 <CTRL-C> \x85 <F1> \x86 <F2> \x87 <F3> \x88 <F4>} $texto]"
        type_via_keybuf $texto
    }
    after realtime $espera [list captura $nombre]
}
proc captura {nombre} {
    global OUT
    screenshot -raw "$OUT/$nombre.png"
    set f [open "$OUT/$nombre.txt" w]; puts $f [pantalla]; close $f
    say "captura $nombre PC=[format %04X [reg PC]] SP=[format %04X [reg SP]] C1F4(PC prog)=[hex 0xC1F4 2] C1D3=[hex 0xC1D3 1] C1BB/C1C4=[hex 0xC1BB 1][hex 0xC1C4 2]"
    siguiente
}
proc arranca {} {
    set dir $::env(MON_DIR)
    foreach {f addr} {monitor_boot.bin 0xC000 lanzador.bin 0xE000 disasm.bin 0xA000} {
        set fp [open "$dir/$f" rb]; fconfigure $fp -translation binary; set d [read $fp]; close $fp
        debug write_block "Main RAM" $addr $d
    }
    if {[info exists ::env(MON_EXTRA)]} {
        # ficheros extra: "ruta@hex ruta@hex ..."
        foreach e $::env(MON_EXTRA) {
            lassign [split $e @] ruta addr
            set fp [open $ruta rb]; fconfigure $fp -translation binary; set d [read $fp]; close $fp
            debug write_block "Main RAM" $addr $d
            say "extra $ruta en $addr"
        }
    }
    set renderer SDLGL-PP
    if {[info exists ::env(MON_ENTRADA)] && $::env(MON_ENTRADA) eq "frio"} {
        reg PC 0xC20E; say "entrada en frio por 0xC20E"
    } else {
        reg PC 0xE000; say "entrada por el lanzador 0xE000 (call 0xC924)"
    }
    after realtime 3 siguiente
}
after realtime 6 arranca
after realtime 180 {say "TIMEOUT"; exit}
