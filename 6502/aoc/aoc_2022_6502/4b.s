.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr3
.importzp read_flag

X_S       = $10
X_E       = $13
LINE_SIZE = $10

.data
tmp: .byte 1
line: .res 16, $00
i: .byte 0
pairs:
  x1: .byte 0
  y1: .byte 0
  x2: .byte 0
  y2: .byte 0

.code
.proc main
  jsr read_file
  jsr open_channel
  jsr init_stack

  lda #$00
  sta hreg
  sta hreg+1
  tax
  jsr pusheax

  ldy #LINE_SIZE
  jsr decspy

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line

parsing:
  lda a_sp
  ldx a_sp+1
  jsr set_ptr

  lda #$00
  sta i
store_coord:
  lda ptr3
  ldx ptr3+1
  jsr strToInt
  ldx i
  sta pairs,x

  tya
  clc
  adc ptr3
  sta ptr3
  inc ptr3

  inc i
  lda i
  cmp #$04
  beq compare
  jmp store_coord

compare:
  lda x1
  cmp y2
  beq lt
  bmi lt
  jmp next_line

lt:
  lda y1
  cmp x2
  bpl addx 
  jmp next_line

addx:
  ldy #X_E
  jsr ldeaxysp

  ldy #$01
  jsr inceaxy

  ldy #X_S
  jsr steaxysp

next_line:
  lda read_flag
  cmp #$00
  beq read_end

  jmp read_line

read_end:
  ldy #X_E
  ldx #$03
  jsr print_hex

  jsr close_channel
  jsr close_file
  rts

set_ptr:
  sta ptr3
  stx ptr3+1
  rts
.endproc