.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1

; 3 pointers
; first, mid, end

X_S       = $40
X_E       = $43
LINE_SIZE = $40

.data
read_flag: .byte 1
tmp: .byte 1
line: .res 64, $00

.zeropage
pfirst: .res 2
pmid: .res 2
pend: .res 2

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

  lda #<line
  ldx #>line
  jsr set_ptr
  jsr copyline

  lsr buf_size

  lda pfirst
  ldx pfirst+1

  ; set mid
  jsr pos_ptr
  sta pmid
  stx pmid+1

  ; set end
  jsr pos_ptr
  sta pend
  stx pend+1

read_first_half:
  lda pmid
  ldx pmid+1
  sta ptr1
  stx ptr1+1

  ldy #$00
  lda (pfirst),y
  tax

read_second_half:
  txa
  cmp (ptr1),y
  beq match_found

  inc ptr1
  lda ptr1
  cmp pend
  beq first_half_done

  jmp read_second_half

first_half_done:
  inc pfirst
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
  jsr ldeaxysp

  ldy tmp
  jsr inceaxy
  ldy #X_S
  jsr steaxysp

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

set_ptr:
  sta pfirst
  stx pfirst+1

copyline:
  ldy #$00
putc_loop:
  lda (a_sp),y
  sta (pfirst),y

  iny
  cpy buf_size
  bne putc_loop  
  rts

pos_ptr:
  clc
  adc buf_size
  bcc nocarry
  inx
nocarry:
  rts

.endproc