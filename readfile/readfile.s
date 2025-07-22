.include        "stdio.inc"
.include        "_file.inc"
.include        "fcntl.inc"
.include        "filedes.inc"
.include        "errno.inc"

.import         curunit
.importzp       c_sp, ptr1, ptr2, ptr3, tmp1, tmp2, tmp3
.autoimport on


.segment "RODATA"
FILENAME:
  .byte $4D,$59,$54,$45,$58,$54,$2E,$54,$58,$54,$00
MODE:
  .byte $52,$00

.bss
  file:           .res    2
  fnunit:         .res    1
  fnlen:          .res    1
  fnisfile:       .res    1
  c:              .res    1
  unit:           .res    1
  
.data
  fnbuf:          .res    35

.segment "CODE"
.proc  main
  ; init stack
  lda #$FF
  ldx #$CF
  sta c_sp
  stx c_sp+1

  jsr decsp4
  lda #<FILENAME
  ldx #>FILENAME
  jsr pushax
  lda #<MODE
  ldx #>MODE
  jsr _fopen ;returns pointer to file structure/table

.endproc

; ########## READ CHAR ##########

.proc _fgetc
  sta ptr1
  stx ptr1+1
  jsr pushax

do_read:
  ldy #_FILE::f_fd
  lda (ptr1),y
  jsr pusha0

  lda #<c
  ldx #>c_sp
  jsr pushax

  lda #$01
  ldx #$00

  ; int read (int fd, void* buf, unsigned count);
  jsr _read

.endproc

.proc _read
  ;pop params, pt2: cnt, pt1: buffer, A: handle
  jsr rwcommon

  adc #LFN_OFFS
  tax
  lda fdtab-LFN_OFFS,x
  tay
  and #LFN_READ

  tya
  bmi eof

  ldy unittab-LFN_OFFS,X
  sty unit

  jsr CHKIN
  bcc @L3

;"here"
@L0:
  brk

@L3:
  dec ptr2
  bne @L0
  dec ptr2+1
  bne @L0
  beq done

done:
  brk

eof:
  lda #0
  sta ___oserror
  lda ptr3
  ldx ptr3+1
  rts


.endproc
; ########## READ FILE ##########
; _fopen
.proc _fopen
  jsr pushax
  jsr __fdesc ;must get stream 
  jmp __fopen ; 
.endproc

;__fdesc
.proc __fdesc
  ldy #0
  lda #_FOPEN
Loop:
  and __filetab + _FILE::f_flags,y
  beq Found
.repeat .sizeof(_FILE)
  iny
.endrepeat 
  cpy #(FOPEN_MAX * .sizeof(_FILE))
  bne Loop

Found: 
  tya
  clc
  adc #<__filetab
  ldx #>__filetab
  bcc @L1
  inx
@L1:
  rts
.endproc

; __fopen
.proc   __fopen
  ;store filetab address to file
  sta file
  stx file+1

  ldy #1
  lda (c_sp), y
  sta ptr1+1
  dey
  lda (c_sp), y
  sta ptr1

  lda (ptr1),y
  cmp #'r' ;this must be 0
  ldx #O_RDONLY

modeok:
  ; this saves mode in stack ex. #$0001
  ldy #$00
  txa
  sta (c_sp),y
  tya
  iny
  sta (c_sp),y
  jsr _open ;return handle

openok:
  ldy file
  sty ptr1
  ldy file+1
  sty ptr1+1
  ldy #_FILE::f_fd
  sta (ptr1),y
  ldy #_FILE::f_flags
  lda #_FOPEN
  sta (ptr1),y

  lda ptr1
  ldx ptr1+1
  rts

.endproc

;_open
.proc _open
paramok:
  jsr popax
  sta tmp3 ;now, this is mode in hex not mode in string address

  jsr popax ;get file name
  jsr fnparse

  jsr freefd
  stx tmp2
  
  lda tmp3
  cmp #O_RDONLY
  beq doread

doread:
  lda #'r'
  pha
  lda #','
  jsr fnadd
  pla
  jsr fnadd

  lda #LFN_READ
  bne common

common:
  sta tmp3; now this contains LFN
  ;call SETNAME kernal function
  lda fnlen
  ldx #<fnbuf
  ldy #>fnbuf
  ;jmp SETNAM

  lda tmp2
  ; this is very cofusing, but i guess kernal
  ; reserves first 3 offsets to something else
  ; so need to add 3 (LFN_OFFS)
  clc
  adc #LFN_OFFS
  ldx fnunit
  tay
  ;set params
  jsr SETLFS
  jsr OPEN

  ldx tmp2
  lda tmp3
  sta fdtab,X
  lda fnunit
  sta unittab,X

  txa
  ldx #0
  stx ___oserror
  rts

.endproc

;fnadd
.proc fnadd
  ldx fnlen
  inc fnlen
  sta fnbuf,X
  rts

.endproc

;fnparse
.proc fnparse
  sta ptr1
  stx ptr1+1 ;this is saving string address to ptr1

  lda #$08
  sta fnunit 

  lda #'0'
  sta fnbuf+0
  lda #':'
  sta fnbuf+1
  ldy #$00

  lda #2
  sta fnlen

  sta fnisfile

fnparsename:
  lda #0
  sta tmp1

nameloop:
  lda (ptr1),y
  beq namedone
  
  ldx tmp1
  jsr fnadd
  iny
  inc tmp1
  bne nameloop

namedone:
  rts

.endproc

