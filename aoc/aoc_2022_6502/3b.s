.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr2

X_S       = $40
X_E       = $43
LINE_SIZE = $40

.data
read_flag:  .byte 0
tmp:        .byte 0
i:          .byte 0
buffers:
  first:  .res 64, $00
  second: .res 64, $00
  third:  .res 64, $00
buffers_pts:
  pfirst:  .word first
  psecond: .word second
  pthird:  .word third

; .zeropage
; pfirst: .word first
; psecond: .word second
; pthird: .word third

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

read3:
read_loop:
  jsr read_line
  lda i
  jsr mul2
  tax

  lda buffers_pts,x
  sta ptr1
  lda buffers_pts+1,x
  sta ptr1+1
  jsr copy_line
  
  inc i 
  lda i
  cmp #$03
  bne read_loop

  lda pfirst
  ldx pfirst+1
  jsr set_ptr
first_loop:
  lda psecond
  ldx psecond+1
  jsr set_ptr2

  ldy #$00
  lda (ptr1),y
  sta tmp
  second_loop:
    lda (ptr2),y

    cmp #$00
    beq loop_end

    cmp tmp
    beq first_match_found

    inc ptr2
    jmp second_loop

  first_match_found:
    pha
    lda pthird
    ldx pthird+1
    jsr set_ptr2
    pla

  third_loop:
    lda (ptr2),y

    cmp #$00
    beq loop_end

    cmp tmp
    beq match_found

    inc ptr2
    jmp third_loop

loop_end:
  inc ptr1
  jmp first_loop

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
  jsr ldeaxysp

  ldy tmp
  jsr inceaxy
  ldy #X_S
  jsr steaxysp

  lda read_flag
  cmp #$00
  beq read_done

  lda #$00
  sta i

  jmp read3

read_done:
  ldy #X_E
  ldx #$03
  jsr print_hex
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
  sta read_flag
  rts

copy_line:
  ldy #$00
put_char:
  lda (a_sp),y
  sta (ptr1),y

  iny
  cpy buf_size
  bne put_char

  lda ptr1
  clc
  adc buf_size
  bcc nocarry1
  inc ptr1+1
nocarry1:
  sta ptr1
  ldy #$00
fill0:
  lda #$00
  sta (ptr1),y
end:
  rts

set_ptr:
  sta ptr1
  stx ptr1+1
  rts

set_ptr2:
  sta ptr2
  stx ptr2+1
  rts

mul2:
  asl a
  rts

.endproc
