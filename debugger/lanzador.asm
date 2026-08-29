        org 0E000h
        di
        ld sp,0EFF0h
        ld hl,01234h
        ld de,05678h
        ld bc,09ABCh
        ld ix,0AAAAh
        ld iy,0BBBBh
        ei
        call 0C924h        ; entra en el monitor por CALL, con pila limpia
        di
bucle:  halt
        jr bucle
