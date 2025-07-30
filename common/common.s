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

.segment "BSS"
fnlen: .res 1

.segment "RODATA"
filename: .byte "input.txt", 0

.segment "CODE"
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
  ; jsr READST
  ; and #EOF_BIT
  ; bne end
  jsr CHRIN
  rts
.endproc

.proc output_char
  jsr CHROUT
  rts
.endproc
