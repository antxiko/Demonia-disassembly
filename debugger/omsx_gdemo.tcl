set OUT $::env(MON_OUT); file mkdir $OUT
set LOG [open "$OUT/gdemo.log" w]; set ::hit 0
proc say {m} { global LOG; puts $LOG $m; flush $LOG }
proc cap {n} { screenshot -raw "$::env(MON_OUT)/g_$n.png"; say "cap g_$n PC=0x[format %04X [reg PC]]" }
proc arranca {} {
    foreach {var addr} {MON_BIN 0xC000 MON_LAN 0xE000 MON_SND 0x7FE0} {
        set f [open $::env($var) rb]; fconfigure $f -translation binary; set d [read $f]; close $f
        debug write_block "Main RAM" $addr $d
    }
    debug set_bp 0x7FE0 {} { set ::hit 1; say [format "*** BP 0x7FE0 ALCANZADO A=0x%02X" [reg A]] }
    reg PC 0xE000; say "entrado"
    after realtime 3 {cap 1_dump}
    after realtime 4 {say "tecleo G7FE0H (sin enter)"; catch {type "G7FE0H"}}
    after realtime 6 {cap 2_tecleado}
    after realtime 7 {say "Enter"; catch {type "\r"}}
    after realtime 9 {cap 3_tras_enter}
    after realtime 10 final
}
proc final {} { say "hit=$::hit PC=0x[format %04X [reg PC]] buffer=[debug read_block {Main RAM} 0xC144 8]"; exit }
after realtime 6 arranca
after realtime 20 exit
