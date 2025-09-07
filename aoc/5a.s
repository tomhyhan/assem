.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr2
.importzp read_flag

LINE_SIZE = $10
STAKC_SZ  = $10

.data
tmp: .byte 1
i: .byte 0
line: .res 16, $00
crates: .res 400, $00
crates_pts: .res 20, $00

.code
.proc main
  jsr read_file
  jsr open_channel
  jsr init_stack

  ldy #LINE_SIZE
  jsr decspy

  lda #<crates
  ldx #>crates
  sta ptr1
  stx ptr1+1

  lda #<crates_pts
  ldx #>crates_pts
  sta ptr2
  stx ptr2+1

  ldx #$00
set_crate_pts:
  ldy #$00
  lda ptr1
  sta (ptr2),y
  iny
  lda ptr1+1
  sta (ptr2),y

  lda ptr1
  clc
  adc #STAKC_SZ
  sta ptr1
  bcc nocarry
  inc ptr1+1
nocarry:
  inc ptr2
  inc ptr2

  inx
  cpx #$0a
  beq read_crates
  jmp set_crate_pts

read_crates:
  jsr read_line

  lda #<crates_pts
  ldx #>crates_pts
  sta ptr2
  stx ptr2+1

  lda #$01
  sta i
add_ch:
  lda i
  tay
  sta (a_sp),y
  jsr inci4

  ldy i
  cpy buf_size
  bpl read_moves 

  ; check if empty string is #$00
  cmp #$00
  beq add_ch 

  pha
  ldy #$00
  lda (ptr2),y
  sta ptr1
  iny
  lda (ptr2),y
  sta ptr1+1

  ;store a 
  pla
  ldy #$00
  sta (ptr1),y

  ;inc address 
  inc ptr1
  bne nc
  inc ptr1+1
nc:
  lda ptr1
  sta (ptr2),y
  iny
  lda ptr1+1
  sta (ptr2),y

  ;move ptr2 to next 
  inc ptr2
  inc ptr2

  jmp read_crates

  ; save to crates
read_moves:
  jsr read_line
  jsr read_line

move_crates:
  jsr read_line
  ; read str to num


next_line:
  lda read_flag
  cmp #$00
  beq read_end

  jmp read_crates

read_end:
  ; ldy #X_E
  ; ldx #$03
  ; jsr print_hex

  jsr close_channel
  jsr close_file
  rts

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line
  rts

inci4:
  inc i
  inc i
  inc i
  inc i
  rts

.endproc