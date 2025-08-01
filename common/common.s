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
.export decspy
.export init_stack
.export decspy
.export a_sp
.export fget_line
.export pushax
.export popax

.zeropage
a_sp:  .res 2
hreg:  .res 2
sl:    .res 1

.segment "BSS"
fnlen: .res 1
buf:   .res 2
size:  .res 2

.segment "RODATA"
filename: .byte "input.txt", 0

.segment "CODE"
;########## FILE OP ##########

.proc fget_line
  sta size
  stx size+1

  popax
  sta ptr1
  stx ptr1+1
  sta buf
  stx buf+1

  ldy #$00
read_loop:
  dec size
  beq done

  jsr read_char
  
  jsr READST
  and #EOF_BIT
  bne done

  ldy #$00
  sta (ptr1),y
  inc ptr1
  
  cmp #'\n'
  beq done
  bne read_loop

done:
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

;##########  OP ##########
;##########  OP ##########




