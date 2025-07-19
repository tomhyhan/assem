.proc main 
  ldx #0
  clc
loop:
  inx
  cpx #3
  bcc loop
end:
  brk
.endproc
