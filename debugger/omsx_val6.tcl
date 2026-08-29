set OUT $::env(MON_OUT); file mkdir $OUT
set LOG [open "$OUT/val.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }
proc arranca {} {
    foreach {var addr} {MON_DIS 0xA000 MON_DRV 0xEC00 MON_TST 0x9000} {
        set f [open $::env($var) rb]; fconfigure $f -translation binary; set d [read $f]; close $f
        debug write_block "Main RAM" $addr $d
    }
    reg PC 0xEC00
    after realtime 2 leer
}
proc leer {} {
    set p 0x8000; set ix 0x9000
    for {set k 0} {$k<12} {incr k} {
        set len [debug read "Main RAM" $p]
        if {$len<1 || $len>4} break
        set s ""
        for {set i 0} {$i<14} {incr i} { append s [format %c [debug read {Main RAM} [expr $p+1+$i]]] }
        set by ""
        for {set i 0} {$i<$len} {incr i} { append by [format "%02X " [debug read {Main RAM} [expr $ix+$i]]] }
        say [format "%04X  %-11s |%s| (%d)" $ix $by [string trimright $s] $len]
        set p [expr $p+17]; set ix [expr $ix+$len]
        if {$ix >= 0x901D} break
    }
    say "FIN"; exit
}
after realtime 6 arranca
after realtime 20 exit
