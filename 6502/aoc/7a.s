.autoimport

.importzp a_sp
.importzp hreg
.importzp ptr1
.importzp ptr2
.importzp read_flag
.importzp r13
.importzp r11

.data

.code
.proc main
  jsr mmap; file_memory, file_pt

  lda file_pt
  ldx file_pt+1
  sta ptr1
  stx ptr1+1 ; start of file

.endproc