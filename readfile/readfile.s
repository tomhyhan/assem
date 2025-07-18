.include        "stdio.inc"
.include        "_file.inc"
.importzp       c_sp, ptr1
.autoimport on


.segment "RODATA"
FILENAME:
  .byte $4D,$59,$54,$45,$58,$54,$2E,$54,$58,$54,$00
MODE:
  .byte $52,$00

.bss
  file: .res 2

.segment "CODE"
.proc  main
  ; init stack
  lda #$FF
  ldx #$CF
  sta c_sp
  stx c_sp+1

  jsr dscsp4
  lda #<FILENAME
  ldx #>FILENAME
  jsr pushax
  lda #<MODE
  ldx #>MODE
  jsr _fopen
.endproc

; _fopen
.proc _fopen
  jsr pushax
  jsr __fdesc ; not checking err, must have a stream
  jmp __fopen
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
  sta file
  stx file+1

  ldy #1
  lda (c_sp), y
  rts
.endproc