.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1

X_S       = $06 
X_E       = $09
LINE_SIZE = $06

.data
read_flag:  .byte 1
table:      .byte 3,1+3,2+6,0,1,2+3,3+6,0,2,3+3,1+6
opp:        .byte 1
me:         .byte 1

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

read_line:
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #LINE_SIZE
  ldx #$00
  jsr fget_line
  sta read_flag

  ldy #$00
  lda (a_sp), y
  sec
  sbc #$41
  sta opp; dec x by 23(x->a), store back to stack

  ldy #$02
  lda (a_sp), y
  sec
  sbc #$58
  sta me ; dec x by 23(x->a), store back to stack

  ldy #X_E
  jsr ldeaxysp ; load ans
  pha

  lda opp
  asl a
  asl a  
  
  clc
  adc me
  tay
  lda table, y
  tay

  pla
  jsr inceaxy 
  ldy #X_S
  jsr steaxysp ; add ans += y

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

.endproc
