.forceimport __STARTUP__
.include "cbm_kernal.inc"

.export _main

.rodata

filename: .byte "mytext.txt", 00

.bss
fnlen: .res 1

.segment "CODE"

.proc _main: near
  lda #$0a
  sta fnlen
  lda fnlen
  ldx #<filename
  ldy #>filename
  jmp SETNAM

  lda #$04
  ldx #$08
  ldy #$00
  jsr SETLFS

  jsr OPEN
  bcs error

  ldx #$04
  jsr CHKIN
  bcs error

  jsr CHRIN
  jsr CHROUT

  rts

error:
  rts

.endproc