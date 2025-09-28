.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr2
.importzp ptr3
.importzp read_flag

LINE_SIZE = $20
STACK_SZ  = $05

; implement mmap?
.data
tmp: .byte 1
i: .byte 0
cnt: .byte 0
src: .byte 0
dest: .byte 0
line: .res 16, $00
fs: .res 20, $00
fe: .res 20, $00
s: .res 20, $00
se: .res 20, $00
t: .res 20, $00
te: .res 20, $00
c_ptrs:
  fp: .word fe
  sp: .word se
  tp: .word te

.code
.proc main
  jsr read_file
  jsr open_channel
  jsr init_stack

  ldy #LINE_SIZE
  jsr decspy

  ; define new pt variables?
  lda #<crates
  ldx #>crates
  sta ptr1
  stx ptr1+1

  lda #<crates_end_pts
  ldx #>crates_end_pts
  sta ptr2
  stx ptr2+1

  lda #<crates_pts
  ldx #>crates_pts
  sta ptr3
  stx ptr3+1

  ldx #$00
set_crate_pts:
  ldy #$00
  lda ptr1
  sta (ptr2),y
  sta (ptr3),y
  iny
  lda ptr1+1
  sta (ptr2),y
  sta (ptr3),y

  lda ptr1
  clc
  adc #STACK_SZ
  sta ptr1
  bcc nocarry
  inc ptr1+1
nocarry:
  inc ptr2
  inc ptr2
  inc ptr3
  inc ptr3

  inx
  cpx #$0a
  beq read_crates
  jmp set_crate_pts

; P not getting saved
read_crates:
  jsr read_line

  lda #<crates_end_pts
  ldx #>crates_end_pts
  sta ptr2
  stx ptr2+1

  lda #$01
  sta i
add_ch:
  lda i
  tay
  lda (a_sp),y

  ldy i
  cpy buf_size
  bpl read_crates 


  cmp #$31
  beq read_moves

  ;compare empty char
  cmp #$20
  beq move_ptr2 

  pha
  ldy #$00
  lda (ptr2),y
  sta ptr1
  iny
  lda (ptr2),y
  sta ptr1+1

  ;store a 
  pla
  ldy #$00
  sta (ptr1),y

  ;inc address 
  inc ptr1
  bne nc
  inc ptr1+1
nc:
  lda ptr1
  sta (ptr2),y
  iny
  lda ptr1+1
  sta (ptr2),y

move_ptr2:
  ;move ptr2 to next 
  inc ptr2
  inc ptr2
  jsr inci4

  jmp add_ch

  ; save to crates
read_moves:
  jsr read_line
move_crates:
  jsr read_line

  ldy #$05
  ldx #$00
  jsr sub_0

  ldy #$0c
  inx
  jsr sub_0

  ldy #$11
  inx
  jsr sub_0

  ; src points to crates_pt + offset
  ; dest points to crates_end_pt + offset

  lda #<crates_pts
  ldx #>crates_pts 
  sta ptr1
  stx ptr1+1
  sta ptr2
  stx ptr2+1

  lda src
  asl
  clc 
  adc ptr1
  sta ptr1

  lda dest
  asl
  clc 
  adc ptr2
  sta ptr2

move_loop:
  ldy #$00
  lda (ptr2),y
  dec a
  sta (ptr2),y

;   bne nc1
;   dec ptr2+1
; nc1:
  ; ldy #$00
  lda (ptr1),y
  sta (ptr2),y
  inc ptr1
  bne nc2
nc2:
  inc ptr1+1
  sta (ptr2),y

  lda src
  asl
  tax
  lda ptr1
  sta crates_pts,x
  inx
  lda ptr1+1
  sta crates_pts,x

  lda dest
  asl
  tax
  lda ptr2
  sta crates_pts,x
  inx
  lda ptr2+1
  sta crates_pts,x

  dec cnt
  beq next_line

next_line:
  lda read_flag
  cmp #$00
  beq read_end

  jmp read_crates

read_end:
  ; ldy #X_E
  ; ldx #$03
  ; jsr print_hex

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
  rts

inci4:
  inc i
  inc i
  inc i
  inc i
  rts

sub_0:
  lda (a_sp),y
  sec
  sbc #$31
  sta cnt,x
  rts
.endproc