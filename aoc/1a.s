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
.import fget_line
.import pusheax
.import laddeqsp
.import strToInt
.import lcmp
.import boolgt
.import ldeaxysp
.import steaxysp

; data
.importzp a_sp
.importzp hreg


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

  lda #$00
  sta hreg+1
  sta hreg
  ldx #$00
  jsr pusheax

  lda #$00
  sta hreg+1
  sta hreg
  ldx #$00
  jsr pusheax

  ldy #$07
  jsr decspy

  ldy #$06
  lda #$00
fill_zero:
  sta (a_sp), y
  dey
  bpl fill_zero

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #$07
  ldx #$00
  ;TODO: figure out why it save at cff2 instead of cff0
  jsr fget_line ; push stack pointer and len 

  cmp #$00
  beq read_end

  ldy #$00
  lda (a_sp),y
  cmp #$0d
  beq new_line

  lda a_sp
  ldx a_sp+1
  jsr strToInt 
  ldy #$07
  jsr laddeqsp

  jmp read_line

new_line:
  ; create another variable ans
  ; compare ans to x
  ; save bigger number to ans
  ; jmp back to read_line
  ldy #$0a ; load x
  jsr ldeaxysp
  jsr pusheax
  ldy #$12 ; load a
  jsr ldeaxysp
  jsr lcmp
  jsr boolgt
  beq lte
  ldy #$0a
  jsr ldeaxysp
  ldy #$0b
  jsr steaxysp
lte:
  ;x=0 dump fix it
  ldy #$0a
  lda #$00
fill_zero1:
  sta (a_sp), y
  dey
  bpl fill_zero1
  jmp read_line

read_end:

  ; ldy #$00
  ; sty prevnum
  ; sty curnum

  ; jsr output_char
  jsr close_channel
  jsr close_file
  rts
.endproc