.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr2
.importzp read_flag
.importzp r13
.importzp r11

; problems
; with adding i?
; with hash length?
; problem with hash table and adding i ?
.data
tmp: .byte 1
line: .res 16, $00
stack: .res 8, 0
stack_p: .word stack
i: .res 2, 0
hash: .res 26, 0
hash_p: .word hash

.code
.proc main
  jsr mmap; file_memory, file_pt

  lda file_pt
  ldx file_pt+1
  sta ptr1
  stx ptr1+1 ; start of file

  lda hash_p
  ldx hash_p+1
  sta ptr2
  stx ptr2+1 ; start of hash_table

  lda stack_p
  ldx stack_p+1
  sta r13
  stx r13+1 ; stack pointer

loop_line:
  ldx #$02
move_stack:
  txa
  tay
  lda (r13),y
  iny
  sta (r13),y

  dex
  bpl move_stack

push_char:
  ldy #$00
  lda (ptr1),y
  sta (r13),y

  inc ptr1
  bne nc6a1
  inc ptr1+1
nc6a1:
  ldy #$00

  ldx #$01
  lda i,x
  cmp #$01
  bpl gt_3
  lda i
  cmp #$03
  bcc next_char
  ; jsr fill_zero

gt_3:
  ldy #$00
compare_stack:
  lda (r13),y
  sec
  sbc #$61

  tax

  lda hash,x
  bne next_char

  inc hash,x

  iny
  cpy #$04
  bne compare_stack

  jmp done

next_char:
  jsr fill_zero
  inc i
  bne nc6a
  inc i+1
nc6a:
  jmp loop_line

done:
  inc i
  rts

fill_zero:
  ldx #$00
loop_array:
  lda #$00
  sta hash,x

  inx
  cpx #$1a
  beq end_fill
  jmp loop_array

end_fill:
  rts


.endproc