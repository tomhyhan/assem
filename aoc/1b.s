.autoimport

.importzp a_sp
.importzp hreg

.proc main
  jsr read_file
  jsr open_channel
  jsr init_stack

  ldy #$0c
  jsr decspy ; int ans[3] (32bit)

  lda #$00
  sta hreg+1
  sta hreg
  ldx #$00
  jsr pusheax ; int x;

  ldy #$07
  jsr decspy ; char line[7] 

  ldy #$06
  lda #$00
  jsr fill_zero

read_line:
  ; pass fget_line params: char *line, int file_len
  lda a_sp
  ldx a_sp+1
  jsr pushax
  lda #$07
  ldx #$00
  jsr fget_line

  cmp #$00
  beq read_end
  
  ldy #$00
  lda (a_sp),y
  cmp #$0d
  bne no_new_line
  jsr new_line
  jmp read_next
no_new_line:
  jsr stoi
read_next:
  jmp read_line

read_end:
  jsr stoi
  jsr new_line

  ; increase y stride in loop: 12, 16
  ldy #$12      ; load a[1]
  jsr ldeaxysp
  ldy #$0b
  jsr laddeqsp

  ldy #$16      ; load a[2]
  jsr ldeaxysp
  ldy #$0b
  jsr laddeqsp
  ; a[1] = sum(a)

  ldy #$0e
  ldx #$03  
print_hex_loop:
  lda (a_sp),y
  pha
  lsr A
  lsr A
  lsr A
  lsr A
  jsr print

  pla
  and #$0f
  jsr print

  dey 
  dex 
  bpl print_hex_loop

  jsr close_channel
  jsr close_file
  rts

; ldy #$12 ; load ans[1]
; ldy #$16 ; load ans[1]
; ldy #$1a ; load ans[2]
new_line:
  ldy #$0a ; load x
  jsr ldeaxysp
  jsr pusheax
  
  ldy #$12 ; load ans[0]
  jsr ldeaxysp
  jsr lcmp
  jsr boolgt
  beq lte
  ; bigger: move a[0] -> a[1] -> a[2]
  jsr move_1to2
  jsr move_0to1
  ldy #$0a
  jsr ldeaxysp
  ldy #$0b
  jsr steaxysp
  jmp end_compare
lte:
  jmp second
  ; goto new_line again and check ans[1], ans[0] 

  ; before exit clear x: x=0 
  ; TODO: merge with fill_zero 
end_compare:
  ldy #$0a
  lda #$00
  jsr fill_zero
  rts

second:
  ldy #$0a ; load x
  jsr ldeaxysp
  jsr pusheax

  ldy #$16 ; load ans[1]
  jsr ldeaxysp
  jsr lcmp
  jsr boolgt
  beq lte0
  ; bigger: move a[1] -> a[2]
  jsr move_1to2
  ldy #$0a
  jsr ldeaxysp
  ldy #$0f
  jsr steaxysp
  jmp end_compare
lte0:
  jmp third
  ; rts

third:
  ldy #$0a ; load x
  jsr ldeaxysp
  jsr pusheax

  ldy #$1a ; load ans[2]
  jsr ldeaxysp
  jsr lcmp
  jsr boolgt
  beq lte1
  ldy #$0a
  jsr ldeaxysp
  ldy #$13
  jsr steaxysp
lte1:
  jmp end_compare 
  ; rts

move_0to1:
  ldy #$0d
  jsr ldeaxysp
  ldy #$0e
  jsr steaxysp
  rts

move_1to2:
  ldy #$12
  jsr ldeaxysp
  ldy #$13
  jsr steaxysp
  rts

stoi:
  lda a_sp
  ldx a_sp+1
  jsr strToInt 
  ldy #$07
  jsr laddeqsp
  rts

print:
  cmp #$0a
  bcc is_digit

is_letter:
  adc #$36
  jmp output

is_digit:
  ora #$30

output:
  jsr output_char
  rts

fill_zero:
  sta (a_sp), y
  dey
  bpl fill_zero
  rts

.endproc