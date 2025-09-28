.proc main
  lda #$00
  beq addx
  lda #$01
  rts

addx:
  lda #$FF
  rts
.endproc