.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1

X_S       = $40
X_E       = $43
LINE_SIZE = $40

.data
read_flag: .byte 0
i: .byte 0
j: .byte 0
k: .byte 0
tmp: .byte 0
first: .res 64, $00
second: .res 64, $00
third: .res 64, $00

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
  jsr read_line
  lda #<first
  ldx #>first
  jsr set_ptr
  jsr copy_line

  jsr read_line
  lda #<second
  ldx #>second
  jsr set_ptr
  jsr copy_line

  jsr read_line
  lda #<third
  ldx #>third
  jsr set_ptr
  jsr copy_line

first_loop:
  ldy i
  lda first,y
  second_loop:
    ldy j

    tax
    lda #$00
    cmp second,y
    beq loop_end
    txa

    cmp second,y
    beq third_loop

    inc j
    jmp second_loop
  
  jmp loop_end

  third_loop:
    ldy k

    tax
    lda #$00
    cmp third,y
    beq loop_end
    txa

    cmp third,y
    beq match_found

    inc k
    jmp third_loop

loop_end:
  inc i
  lda #$00
  sta j
  sta k
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

  jsr reset_vars
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
  rts

reset_vars:
  lda #$00
  sta i
  sta j
  sta k

  lda #<first
  ldx #>first
  jsr set_ptr
  jsr put0_loop

  lda #<second
  ldx #>second
  jsr set_ptr
  jsr put0_loop

  lda #<third
  ldx #>third
  jsr set_ptr
  jsr put0_loop

  rts

put0_loop:
  ldy #$00
put0:
  lda (ptr1),y
  cmp #$00
  beq end_put0
  lda #$00
  sta (ptr1),y
  iny
  jmp put0
end_put0:
  rts

set_ptr:
  sta ptr1
  stx ptr1+1
  rts

.endproc
