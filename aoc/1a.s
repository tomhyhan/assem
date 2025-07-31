; AOC 2022 1a

.import read_file
.import close_file
.import open_channel
.import close_channel
.import read_char
.import output_char
.import init_stack
.import decspy
.import pushax

; data
.importzp a_sp


.segment	"RODATA"
line: .res	5,$00

.data 
prevnum: .res 4
curnum:  .res 4

;TODO:
; 1. init stack and get stack pointer
; 2. init line char array with size (not needed)
; 3. create a stack by dec stack size
; 4. store value in line to stack
; 5. call each character and store inside stack
; 6. convert value in stack to int32
; 7. save value int to somewhere
; 8. return to 5, and compare new value to prev value
; 9. save bigger int
; 10. print to screen

.segment "CODE"
.proc main
  jsr read_file
  jsr open_channel

  jsr init_stack
  
  ldy #$07
  jsr decspy

  ldy #$06
  lda #$00
fill_zero:
  sta (a_sp), y
  dey
  bpl fill_zero

  lda a_sp
  ldx a_sp+1
  pushax
  lda #$07
  ldx #$00
  jsr fget_line ; push stack pointer and len 
  
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