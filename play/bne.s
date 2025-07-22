.data
vr: .byte $05

.segment "CODE"
.proc main
  dec vr
  bne @L1
  jmp @L2  

@L1:
  ldx #$FF
  brk
@L2:
  ldx #$00
  brk

.endproc

 