; Kernal Functions 
SETLFS  = $FFBA   ; Args: Logical num, Device num, Secondary addr 
SETNAM  = $FFBD   ; Args: filelen, <file_name, > file_nam
OPEN    = $FFC0   ; Args: None
CHKIN   = $FFC6   ; Args: Logical num
CHRIN   = $FFCF   ; Args: None 
CHROUT  = $FFD2   ; Args: Byte Read 
READST  = $FFB7   ; Args: None; this reads the device status in IEEE standard  
CLRCHN  = $FFCC   ; Args: None 
CLOSE   = $FFC3   ; Args: Logical num

EOF_BIT = %01000000

.export read_file
.export close_file
.export open_channel
.export close_channel
.export read_char
.export output_char
.export init_stack
.export decspy
.export fget_line
.export pushax
.export pusheax
.export popax
.export laddeqsp
.export strToInt
.export lcmp
.export boolgt
.export ldeaxysp
.export steaxysp
.export inceaxy

; print op
.export print_hex

.export a_sp
.export hreg
.export buf_size

.zeropage
a_sp:  .res 2
hreg:  .res 2
sl:    .res 1
ptr1:  .res 2
ptr2:  .res 2
ptr4:  .res 2

.segment "BSS"
fnlen:    .res 1
buf:      .res 2
size:     .res 2
didread:  .res 1
buf_size: .res 1

.segment "RODATA"
filename: .byte "input.txt", 0

.segment "CODE"
;########## FILE OP ##########

.proc fget_line ; line pointer and len
  sta size
  stx size+1

  jsr popax
  sta ptr1
  stx ptr1+1
  sta buf
  stx buf+1

  ldy #$00
  sty didread
read_loop:
  dec size
  beq done

  jsr read_char

  ldy #$00
  sta (ptr1),y
  inc ptr1

  cmp #$0a
  beq done

  pha
  jsr READST
  ; and #EOF_BIT
  and #%01000000 
  bne eof 
  pla

  bne read_loop

done:
  ; add null terminator to mock C string?
  jsr get_buf_size
  dec buf_size
  dec buf_size ; get rid of newline
  lda #$FF
  rts

eof:
  jsr get_buf_size
  pla
  lda #$00
  rts

get_buf_size:
  lda ptr1
  sec
  sbc buf
  sta buf_size
  rts

.endproc

.proc read_file
  jsr read_file_len

  lda fnlen
  ldx #<filename
  ldy #>filename
  jsr SETNAM

  lda #$04
  ldx #$08
  ldy #$04
  jsr SETLFS

  jsr OPEN
end:
  rts
.endproc

.proc open_channel
  ldx #$04
  jsr CHKIN
  rts
.endproc

.proc close_channel
  jsr CLRCHN
  rts
.endproc

.proc close_file
  lda #$04
  jsr CLOSE
  rts
.endproc

.proc read_file_len
  ldy #$0
  sty fnlen 
loop:
  lda filename,y
  beq end
  inc fnlen
  iny
  jmp loop

end:
  rts
.endproc

.proc read_char
  jsr CHRIN
  rts
.endproc

.proc output_char
  jsr CHROUT
  rts
.endproc

;########## STACK OP ##########
.proc init_stack
  ; little endian
  lda #$FF
  sta a_sp
  lda #$CF
  sta a_sp+1
  rts
.endproc

.proc decspy
  ; already knows about Y
  sty sl
  lda a_sp
  sec
  sbc sl
  sta a_sp
  bcc borrow
  rts

borrow:
  dec a_sp+1
  rts
.endproc

.proc pushax
  pha
  lda a_sp
  sec
  sbc #$02
  sta a_sp
  bcs notborrow
  dec a_sp+1
notborrow: 
  ldy #$01
  txa
  sta (a_sp),y 
  pla
  dey
  sta (a_sp),y
  rts
.endproc

.proc pusheax
  pha
  ldy #$04
  jsr decspy
  ldy #$03
  lda hreg+1
  sta (a_sp),y
  dey
  lda hreg
  sta (a_sp),y
  dey
  txa
  sta (a_sp),y
  dey
  pla
  sta (a_sp),y
  rts
.endproc

.proc popax
  ldy #$01
  lda (a_sp),y
  tax 
  dey
  lda (a_sp),y

  ; incsp2
  inc a_sp
  beq lzero
  inc a_sp
  beq hzero
  rts

lzero: inc a_sp
hzero: inc a_sp+1
  rts
.endproc

.proc addysp
  ; already knows y
  pha
  tya
  clc
  adc a_sp
  sta a_sp
  bcc nocarry
  inc a_sp+1 
nocarry:
  pla
  rts
.endproc

.proc laddeqsp
  ; know y already
  clc
  adc (a_sp),y
  sta (a_sp),y
  pha
  iny
  txa
  adc (a_sp),y
  sta (a_sp),y
  tax
  iny
  lda hreg
  adc (a_sp),y
  sta (a_sp),y
  sta hreg
  iny
  lda hreg+1
  adc (a_sp),y
  sta (a_sp),y
  sta hreg+1
  pla
  rts
.endproc

.proc ldeaxysp
  ;knows y
  lda (a_sp),y 
  sta hreg+1 
  dey
  lda (a_sp),y
  sta hreg
  dey
  lda (a_sp),y
  tax
  dey
  lda (a_sp),y
  rts
.endproc

.proc steaxysp
  sta (a_sp),y
  pha
  txa
  iny
  sta (a_sp),y 
  lda hreg
  iny
  sta (a_sp),y
  lda hreg+1
  iny
  sta (a_sp),y
  pla
  rts
.endproc

.proc inceaxy
  ; know y (value to add)
  sty ptr4
  clc
  adc ptr4
  bcc ret
  inx
  bne ret
  inc hreg
  bne ret
  inc hreg+1

ret:
  rts
.endproc

;########## CAST OP ##########
.proc hexToInt
  rts
.endproc

.proc strToInt
  sta ptr1
  stx ptr1+1
  ldy #$00
  sty ptr2
  sty ptr2+1
  sty hreg
  sty hreg+1

cast_int:
  lda (ptr1),y
  sec
  sbc #'0'
  tax
  cmp #$0a
  bcs done

  ;mul 10
  jsr mul2
  lda hreg+1
  pha
  lda hreg
  pha
  lda ptr2+1
  pha
  lda ptr2
  pha

  jsr mul2
  jsr mul2

  clc
  pla
  adc ptr2
  sta ptr2
  pla
  adc ptr2+1
  sta ptr2+1
  pla
  adc hreg
  sta hreg
  pla
  adc hreg+1
  sta hreg+1

  ;add num
  txa
  clc
  adc ptr2
  sta ptr2
  bcc next_char
  inc ptr2+1
  bne next_char
  inc hreg
  bne next_char
  inc hreg+1

next_char:
  iny
  bne cast_int 

done:
  lda ptr2
  ldx ptr2+1
  rts

mul2:
  asl ptr2
  rol ptr2+1
  rol hreg
  rol hreg+1
  rts

.endproc

;##########  boolean OP ##########
.proc lcmp
  ; load a
  sta ptr1
  stx ptr1+1

  ldy #$03
  lda (a_sp),y
  sec
  sbc hreg+1
  bne highbit

  dey
  lda (a_sp),y
  cmp hreg
  bne lowbit

  dey
  lda (a_sp),y
  sec
  sbc ptr1+1
  bne lowbit

  dey
  lda (a_sp),y
  sec
  sbc ptr1

lowbit:
  php
  ldy #$04
  jsr addysp
  plp
  beq equal
  bcs positive
  lda #$FF ;negative (-1)
equal:
  rts
positive:
  lda #$01
  rts

highbit:
  bvc nooverflow
  eor #$FF ; overflow flag is lying
           ; so fix N flag if overflow 
  ora #$01
nooverflow:
  php
  ldy #$04
  jsr addysp
  plp
  rts
.endproc

.proc boolgt
  beq eq
  bpl gt
eq:
  ldx #$00
  txa
  rts
gt:
  ldx #$00
  lda #$01
  rts
.endproc

;##########  print OP ##########
.proc print_hex
  ; knows x and y
loop:
  lda (a_sp), y
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
  bpl loop
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
.endproc