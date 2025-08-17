; AOC 2022 1a

; .import read_file
; .import close_file
; .import open_channel
; .import close_channel
; .import read_char
; .import output_char
; .import init_stack
; .import decspy
; .import pushax
; .import fget_line
; .import pusheax
; .import laddeqsp
; .import strToInt
; .import lcmp
; .import boolgt
; .import ldeaxysp
; .import steaxysp

.autoimport 
; data
.importzp a_sp
.importzp hreg


.segment	"RODATA"
line: .res	5,$00

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
  jsr fget_line ; push stack pointer and len 

  cmp #$00
  beq read_end

  ldy #$00
  lda (a_sp),y
  cmp #$0d
  bne no_new_line 
  jsr new_line
  jmp read_next
no_new_line:
  jsr stoi
read_next:
  jmp read_line

; hack: simply printing out stack with hex values
; TODO: implement printf and sprintf
read_end:
  jsr stoi
  jsr new_line
  ldy #$0e
  ldx #$03
print_hex_loop:
  lda (a_sp), y
  pha
  lsr A
  lsr A
  lsr A
  lsr A
  jsr print

  pla
  and #$0f
  jsr print

  dey
  dex
  bpl print_hex_loop
  
  jsr close_channel
  jsr close_file
  rts

stoi:
  lda a_sp
  ldx a_sp+1
  jsr strToInt 
  ldy #$07
  jsr laddeqsp
  rts

new_line:
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
  ;x=0 dumb fix it
  ldy #$0a
  lda #$00
fill_zero1:
  sta (a_sp), y
  dey
  bpl fill_zero1
  rts

print:
  cmp #$0a
  bcc is_digit

is_letter:
  adc #$36
  jmp output

is_digit:
  ora #$30

output:
  jsr output_char
  rts

.endproc