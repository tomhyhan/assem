.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1

X_S       = $06 
X_E       = $09
LINE_SIZE = $06

.data
read_flag: .byte 1

.code
.proc main
  jsr read_file
  jsr open_channel

  jsr init_stack

  lda #$00
  sta hreg
  sta hreg+1
  ldx #$00
  jsr pusheax  ; int ans = 0; 

  ldy #LINE_SIZE 
  jsr decspy ; char line[5]
; R 0 P 1 S 2    XYZ
; -1 -1 2
; -2  1 1
read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line
  sta read_flag

  ldy #$02
  lda (a_sp), y
  sec
  sbc #$17
  sta (a_sp), y ; dec x by 23(x->a), store back to stack

  cmp #$42
  beq draw
  cmp #$43
  beq win
  jmp lose
draw:
  jsr load_x_a0

  clc
  adc #$03

  jsr str2x
  jmp next_iter

win:
  jsr load_x_a0

  cmp #$43
  bne add_one
  sec
  sbc #$02
  jmp add_win
add_one:
  clc
  adc #$01
add_win:
  clc
  adc #$06 

  jsr str2x
  jmp next_iter

lose:
  jsr load_x_a0

  cmp #$41
  bne dec_one
  clc
  adc #$02
  jmp no_add
dec_one:
  sec
  sbc #$01
no_add:
  jsr str2x

next_iter:  
  lda read_flag
  cmp #$00
  beq read_done

  jmp read_line

read_done:
  ldy #X_E
  ldx #$03
  jsr print_hex

  jsr close_channel
  jsr close_file
  rts

load_x_a0:
  ldy #X_E
  jsr ldeaxysp
  sta ptr1

  ldy #$00
  lda (a_sp),y  ; load a[0]
  rts

str2x:  
  sec
  sbc #$40
  tay

  lda ptr1
  jsr inceaxy 
  ldy #X_S
  jsr steaxysp ; add ans += 0
  rts
.endproc
