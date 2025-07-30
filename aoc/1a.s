; AOC 2022 1a

.import read_file
.import close_file
.import open_channel
.import close_channel
.import read_char
.import output_char

.data 
prevnum: .res 4
curnum:  .res 4

.proc main
  jsr read_file
  jsr open_channel
  jsr read_char ; saves byte to A

  ; 1234

  ;1 2 3 4

  ;1000 200 30 4


  ; ldy #$00
  ; sty prevnum
  ; sty curnum

  jsr output_char
  jsr close_channel
  jsr close_file
  rts
.endproc