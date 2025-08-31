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
; i is in buffers 
i:          .byte 0
buffers:
  first: .res 64, $00
  second: .res 64, $00
  third: .res 64, $00

.zeropage
pfirst: .res 2
psecond: .res 2
pthird: .res 2

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
  asl a
  asl a
  asl a
  asl a
  asl a
  asl a

  clc
  adc #<buffers
  pha
  lda #>buffers
  bcs nocarry
  adc #$00
nocarry:
  tax
  pla
  jsr set_ptr
  jsr copy_line
  
  inc i 
  sta i
  cmp #$03
  bne read_loop

debug:

  ; jsr read_line
  ; lda #<first
  ; ldx #>first
  ; jsr set_ptr
  ; jsr copy_line

  ; jsr read_line
  ; lda #<second
  ; ldx #>second
  ; jsr set_ptr
  ; jsr copy_line

  ; jsr read_line
  ; lda #<third
  ; ldx #>third
  ; jsr set_ptr
  ; jsr copy_line

  lda #<first
  ldx #>first
  sta pfirst
  stx pfirst+1

  lda #<second
  ldx #>second
  sta psecond
  stx psecond+1

  lda #<third
  ldx #>third
  sta pthird
  stx pthird+1

; first_loop:
;   lda psecond
;   ldx psecond+1
;   sta ptr1
;   stx ptr1+1

;   lda pthird
;   ldx pthird+1
;   sta ptr2
;   stx ptr2+1

;   ldy #$00
;   lda (pfirst),y
;   tax
;   second_loop:
;     txa
;     cmp (ptr1),y
;     beq loop_end
;     txa

;     cmp second,y
;     beq third_loop

;     inc j
;     jmp second_loop
  
;   jmp loop_end

;   third_loop:
;     ldy k

;     tax
;     lda #$00
;     cmp third,y
;     beq loop_end
;     txa

;     cmp third,y
;     beq match_found

;     inc k
;     jmp third_loop

; loop_end:
;   inc i
;   lda #$00
;   sta j
;   sta k
;   jmp first_loop

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
