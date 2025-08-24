.autoimport

.importzp a_sp
.importzp hreg

X_S       = $06 
X_E       = $09
LINE_SIZE = $06

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

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line

  pha
  ldy #$00
  lda (a_sp), y
  iny
  iny
  
  pha
  lda (a_sp), y
  sec
  sbc #$17
  sta (a_sp), y ; dec x by 23(x->a), store back to stack

  pla 
  sec
  sbc (a_sp), y ; a - x

  beq draw
  cmp #$FF
  beq win
  cmp #$02
  beq win
  jmp next_iter
draw:
  ldy #X_E
  jsr ldeaxysp
  ldy #$03 
  jsr inceaxy ; add ans + 3
  ldy #X_S
  jsr steaxysp
  jmp next_iter

win:
  ldy #X_E
  jsr ldeaxysp
  ldy #$06
  jsr inceaxy ; add ans + 3
  ldy #X_S
  jsr steaxysp
  jmp next_iter

next_iter:  
  ldy #X_E
  jsr ldeaxysp
  pha

  ldy #$02
  lda (a_sp),y  ; load x
  sec
  sbc #$40
  tay
  
  pla 
  jsr inceaxy
  ldy #X_S
  jsr steaxysp

  pla
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
.endproc
