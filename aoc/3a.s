.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1


X_S       = $40
X_E       = $43
LINE_SIZE = $40

.data
read_flag: .byte 1
i: .byte 1
j: .byte 1
tmp: .byte 1

.code
.proc main
  jsr read_file
  jsr open_channel
  jsr init_stack

  lda #$00
  sta hreg
  sta hreg+1
  ldx #$00
  jsr pusheax ; int ans = 0 ;

  ldy #LINE_SIZE
  jsr decspy     ; char line[64]

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line
  sta read_flag

  lda #$00
  sta i
  sta j

  lsr buf_size

read_first_half:
  ldy i
  lda (a_sp), y
  tax
read_second_half:
  lda j
  clc
  adc buf_size
  tay
  txa
  cmp (a_sp), y
  beq match_found

  inc j
  lda j
  cmp buf_size
  bcs first_half_done

  jmp read_second_half

first_half_done:
  ; look at how compiler does this
  lda #$00
  sta j
  inc i
  jmp read_first_half

match_found:
  cmp #$61
  bcs isLower
  sec
  sbc #$26
  jmp add2x
isLower:
  sec
  sbc #$60
add2x:
  sta tmp

  ldy #X_E
  jsr ldaxysp

  ldy tmp
  jsr inceaxy
  ldy #X_S
  jsr steaxysp

read_done:

  ldy #X_E
  ldx #$03
  jsr print_hex
  jsr close_channel
  jsr close_file
  rts
.endproc