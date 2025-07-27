SETLFS  = $FFBA   ; Args: Logical num, Device num, Secondary addr 
SETNAM  = $FFBD   ; Args: filelen, <file_name, > file_nam
OPEN    = $FFC0   ; Args: None
CHKIN   = $FFC6   ; Args: Logical num
CHRIN   = $FFCF   ; Args: None 
CHROUT  = $FFD2   ; Args: Byte Read 
READST  = $FFB7   ; Args: None; this reads the device status in IEEE standard  
CLRCHN   = $FFCC  ; Args: None 
CLOSE   = $FFC3   ; Args: Logical num

EOF_BIT = %01000000

.segment "RODATA"
filename: .byte "mytext.txt", 0

.bss
fnlen: .res 1  

.segment "CODE"
.proc main
  jsr read_file_len
  
  ; lda fnlen
  lda #$0a
  ldx #<filename
  ldy #>filename
  jsr SETNAM

  lda #$04
  ldx #$08
  ldy #$04
  jsr SETLFS

  jsr OPEN
  bcs error

  ldx #$04
  jsr CHKIN
  bcs error

read_file:
  jsr READST
  and #EOF_BIT
  bne end

  jsr CHRIN
  jsr CHROUT
  jmp read_file

end:
  jsr CLRCHN
  lda #$04
  jsr CLOSE
error:
  rts

.endproc

.proc read_file_len
  ldy #$0
loop:
  lda filename,y
  beq end
  inc fnlen
  iny
  jmp loop

end:
  rts

.endproc