set OUT $::env(MON_OUT); file mkdir $OUT
set LOG [open "$OUT/f.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }
proc arranca {} {
    foreach {f addr} {monitor_boot.bin 0xC000 lanzador.bin 0xE000 disasm.bin 0xA000} {
        set fp [open $f rb]; fconfigure $fp -translation binary; set d [read $fp]; close $fp
        debug write_block "Main RAM" $addr $d
    }
    reg PC 0xE000
    after realtime 3 {
        screenshot -raw "$::env(MON_OUT)/final.png"
        set s ""; for {set i 0} {$i<12} {incr i} { append s [format %c [debug read {Main RAM} [expr 0xC1E4+$i]]] }
        say "PC-disasm 0xC1E4=|$s| len=[debug read {Main RAM} 0xC1E3]"
        exit
    }
}
after realtime 6 arranca
after realtime 15 exit
