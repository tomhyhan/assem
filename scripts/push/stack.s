        .import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated
        .importzp       c_sp


.proc   decsp4 
        lda     #<(__MAIN_START__ + __MAIN_SIZE__)
        ldx     #>(__MAIN_START__ + __MAIN_SIZE__)
        lda     c_sp
        sec
        sbc     #4
        sta     c_sp
        bcc     @L1
        rts

@L1:    dec     c_sp+1
        rts

.endproc
