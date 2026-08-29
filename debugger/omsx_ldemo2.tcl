set OUT $::env(MON_OUT); file mkdir $OUT
set LOG [open "$OUT/l.log" w]
proc say {m} { global LOG; puts $LOG $m; flush $LOG }
proc arranca {} {
    foreach {var addr} {MON_BIN 0xC000 MON_LAN 0xE000 MON_DIS 0xA000 MON_SND 0x7FE0} {
        set f [open $::env($var) rb]; fconfigure $f -translation binary; set d [read $f]; close $f
        debug write_block "Main RAM" $addr $d
    }
    reg PC 0xE000; say "entrado, monitor en marcha"
    after realtime 3 lista
}
proc lista {} {
    # invocar la orden LISTAR directamente: IX=0x7FE0, limite 0xC1D8=0x7FE7, PC=0xC538
    reg ix 0xC924
    debug write "Main RAM" 0xC1D8 0x60
    debug write "Main RAM" 0xC1D9 0xC9
    reg PC 0xC538
    after realtime 3 {screenshot -raw "$::env(MON_OUT)/l.png"; say "captura PC=0x[format %04X [reg PC]]"; exit}
}
after realtime 6 arranca
after realtime 20 exit
