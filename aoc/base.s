.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp read_flag

X_S       = $10
X_E       = $13
LINE_SIZE = $10

.data
tmp: .byte 1
line: .res 16, $00

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

.endproc