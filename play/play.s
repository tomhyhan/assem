.data
vr: .byte $05

.segment "CODE"
.proc main
  lda #50
  sec
  sbc #130
  eor #$FF 
  brk
  bcs @L2

@L1:
  ldx #$FF
  brk
@L2:
  ldx #$00
  brk

.endproc

 