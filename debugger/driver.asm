        org 0EC00h
        ld ix,09000h
        ld hl,08000h
dloop:  push hl
        call 0A000h
        pop hl
        ld a,(0C1E3h)
        ld (hl),a
        inc hl
        ld de,0C1E4h
        ld b,010h
dcp:    ld a,(de)
        ld (hl),a
        inc de
        inc hl
        djnz dcp
        ld a,(0C1E3h)
        ld e,a
        ld d,000h
        add ix,de
        push ix
        pop bc
        ld a,b
        cp 090h
        jr c,dloop
        ld a,c
        cp 01eh
        jr c,dloop
        halt
