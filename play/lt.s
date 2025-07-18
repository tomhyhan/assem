.segment "RODATA"
MYTEXT: .byte $61,$62,$63,$00
.segment "CODE"
.proc main
  ldy #<MYTEXT
  ldx #>MYTEXT
.endproc