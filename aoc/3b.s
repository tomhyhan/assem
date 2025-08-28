.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1

X_S       = $c0
X_E       = $c3
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

  jsr read_line
  lda #<first
  sta ptr1
  lda #>first
  sta ptr1+1
  jsr copy_line

  jsr read_line
  lda #<second
  sta ptr1
  lda #>second
  sta ptr1+1
  jsr copy_line

  jsr read_line
  lda #<third
  sta ptr1
  lda #>third
  sta ptr1+1
  jsr copy_line


first_loop:
  ldy i
  lda first,y
  second_loop:
    ldy j
    cmp second,y
    beq third_loop

    inc j
    jmp second_loop
  
  jmp loop_end

  third_loop:
    ldy k
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

  ; WRONG
  ; jmp read_line

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

.endproc
