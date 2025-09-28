.include        "stdio.inc"
.include        "_file.inc"
.include        "fcntl.inc"
.include        "filedes.inc"
.include        "errno.inc"

.fopt		compiler,"cc65 v 2.19 - Git 29f7ab380"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.importzp	c_sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
.macpack longbranch
.autoimport on
.forceimport	__STARTUP__
.import _fclose
.import _fgetc

.export _main

; ############################
        .import         addysp, popax
        .import         scratch, fnparse, fnaddmode, fncomplete, fnset
        .import         opencmdchannel, closecmdchannel, readdiskerror
        .import         _close
        ; .destructor     closeallfiles, 5

        .include        "cbm.inc"


; #################





.segment "RODATA"
FILENAME:
  .byte $4D,$59,$54,$45,$58,$54,$2E,$54,$58,$54,$00
MODE:
  .byte $52,$00
S0003:
	.byte	$25,$43,$00

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
.proc  _main: near
  ; init stack
  ;lda #$FF
  ;ldx #$CF
  ;sta c_sp
  ;stx c_sp+1

  jsr decsp4
  lda #<FILENAME
  ldx #>FILENAME
  jsr pushax
  lda #<MODE
  ldx #>MODE
  jsr _fopen ;returns pointer to file structure/table
	ldy     #$02
	jsr     staxysp
	jmp     L0004
L0002:	lda     #<(S0003)
	ldx     #>(S0003)
	jsr     pushax
	ldy     #$03
	jsr     ldaxysp
	jsr     pushax
	ldy     #$04
	jsr     _printf
L0004:	ldy     #$03
	jsr     ldaxysp
	jsr     _fgetc
	ldy     #$00
	jsr     staxysp
	cpx     #$FF
	bne     L0005
	cmp     #$FF
L0005:	jsr     boolne
	bne     L0002
	ldy     #$03
	jsr     ldaxysp
	jsr     _fclose
	ldx     #$00
	lda     #$00
	jmp     L0001
L0001:	rts 
.endproc

; ########## READ CHAR ##########

; .proc _fgetc
;   sta ptr1
;   stx ptr1+1
;   jsr pushax

; do_read:
;   ldy #_FILE::f_fd
;   lda (ptr1),y
;   jsr pusha0

;   lda #<c
;   ldx #>c_sp
;   jsr pushax

;   lda #$01
;   ldx #$00

;   ; int read (int fd, void* buf, unsigned count);
;   jsr _read

;   jsr incsp2
;   ldx #$00
;   lda c
;   rts

; .endproc

; .proc _read
;   ;pop params, ptr2: cnt, ptr1: buffer, A: handle
;   jsr rwcommon

;   adc #LFN_OFFS
;   tax
;   lda fdtab-LFN_OFFS,x
;   tay
;   and #LFN_READ

;   tya
;   bmi eof

;   ldy unittab-LFN_OFFS,X
;   sty unit

;   jsr CHKIN
;   bcc @L3

; @L0:
;   jsr BASIN
;   sta tmp1
;   ldx unit
;   bne @L0_1
;   cmp #$0D
;   bne @L0_1
;   jsr BSOUT

; @L0_1:
;   jsr READST
;   sta tmp3
;   and #%10111111
;   bne devnotpresent

;   ldy #0
;   lda tmp1
;   sta (ptr1),y
;   inc ptr1
;   bne @L1
;   inc ptr1+1

; @L1:
;   inc ptr3
;   bne @L2
;   inc ptr3+1

; @L2:    
;   lda     tmp3
;   and     #%01000000
;   bne     @L4   

; @L3:
;   dec ptr2
;   bne @L0
;   dec ptr2+1
;   bne @L0
;   beq done

; @L4:
;   ldx tmp2
;   lda #LFN_EOF
;   ora fdtab,X
;   sta fdtab,x

; done:
;   jsr CLRCH

; eof:
;   lda #0
;   sta ___oserror
;   lda ptr3
;   ldx ptr3+1
;   rts

; devnotpresent:
;   lda     #ENODEV
;   .byte   $2C             ; Skip next opcode via BIT <abs>

; ; Error entry: The given file descriptor is not valid or not open

; invalidfd:
;   lda     #EBADF
;   jmp     ___directerrno  ; Sets _errno, clears __oserror, returns -1

; .endproc

; ########## READ FILE ##########
; _fopen
; .proc _fopen
;   jsr pushax
;   jsr __fdesc ;must get stream 
;   jmp __fopen ; 
; .endproc

; ; ; __fdesc
; .proc __fdesc
;   ldy #0
;   lda #_FOPEN
; Loop:
;   and __filetab + _FILE::f_flags,y
;   beq Found
; .repeat .sizeof(_FILE)
;   iny
; .endrepeat 
;   cpy #(FOPEN_MAX * .sizeof(_FILE))
;   bne Loop

; Found: 
;   tya
;   clc
;   adc #<__filetab
;   ldx #>__filetab
;   bcc @L1
;   inx
; @L1:
;   rts
; .endproc

; ; ; __fopen
; .proc   __fopen
;   ;store filetab address to file
;   sta file
;   stx file+1

;   ldy #1
;   lda (c_sp), y
;   sta ptr1+1
;   dey
;   lda (c_sp), y
;   sta ptr1

;   ldx #$00
;   lda (ptr1),y
;   cmp #'r' ;this must be 0
;   ldx #O_RDONLY

; modeok:
;   ; this saves mode in stack ex. #$0001
;   ldy #$00
;   txa
;   sta (c_sp),y
;   tya
;   iny
;   sta (c_sp),y
;   ldy     #4
;   jsr _open ;return handle

; openok:
;   ldy file
;   sty ptr1
;   ldy file+1
;   sty ptr1+1
;   ldy #_FILE::f_fd
;   sta (ptr1),y
;   ldy #_FILE::f_flags
;   lda #_FOPEN
;   sta (ptr1),y

;   lda ptr1
;   ldx ptr1+1
;   rts

; .endproc

; _open

; .proc _open
; paramok:
;   dey
;   dey
;   dey
;   dey
;   jsr popax
;   sta tmp3 ;now, this is mode in hex not mode in string address

;   jsr popax ;get file name
;   jsr fnparse
;   tax

;   jsr freefd
;   stx tmp2
  
;   lda tmp3
;   and #(O_RDWR | O_CREAT)
;   cmp #O_RDONLY
;   beq doread

; doread:
;   lda #'r'
;   jsr fnaddmode
;   ; pha
;   ; lda #','
;   ; jsr fnadd
;   ; pla
;   ; jsr fnadd

;   lda #LFN_READ
;   bne common

; common:
;   sta tmp3; now this contains LFN
;   jsr fnset
;   ;call SETNAME kernal function
;   ; lda fnlen
;   ; ldx #<fnbuf
;   ; ldy #>fnbuf
;   ;jmp SETNAM

;   lda tmp2
;   ; this is very cofusing, but i guess kernal
;   ; reserves first 3 offsets to something else
;   ; so need to add 3 (LFN_OFFS)
;   clc
;   adc #LFN_OFFS
;   ldx fnunit
;   tay
;   ;set params
;   jsr SETLFS
;   jsr OPEN

;   ldx fnunit
;   jsr opencmdchannel
;   ldx fnunit
;   jsr readdiskerror

;   ldx tmp2
;   lda tmp3
;   sta fdtab,X
;   lda fnunit
;   sta unittab,X

;   txa
;   ldx #0
;   stx ___oserror
;   rts

; .endproc

; ;fnadd
; .proc fnadd
;   ldx fnlen
;   inc fnlen
;   sta fnbuf,X
;   rts

; .endproc

;fnparse
; .proc fnparse
;   sta ptr1
;   stx ptr1+1 ;this is saving string address to ptr1

;   lda #$08
;   sta fnunit 

;   lda #'0'
;   sta fnbuf+0
;   lda #':'
;   sta fnbuf+1
;   ldy #$00

;   lda #2
;   sta fnlen

;   sta fnisfile

; fnparsename:
;   lda #0
;   sta tmp1

; nameloop:
;   lda (ptr1),y
;   beq namedone
  
;   ldx tmp1
;   jsr fnadd
;   iny
;   inc tmp1
;   bne nameloop

; namedone:
;   rts

; .endproc


; ;--------------------------------------------------------------------------


; .proc   _fopen

; ; Bring the mode parameter on the stack

;         jsr     pushax

; ; Allocate a new file stream

;         jsr     __fdesc

; ; Check if we have a stream

;         cmp     #$00
;         bne     @L1
;         cpx     #$00
;         bne     @L1

; ; Failed to allocate a file stream

;         lda     #EMFILE
;         jsr     ___seterrno     ; Set __errno, will return 0 in A
;         tax
;         rts                     ; Return zero

; ; Open the file and return the file descriptor. All arguments are already
; ; in place: name and mode on the stack, and f in a/x

; @L1:    jmp     __fopen

; .endproc

; .proc   __fopen

;         sta     file
;         stx     file+1          ; Save f

; ; Get a pointer to the mode string

;         ldy     #1
;         lda     (c_sp),y
;         sta     ptr1+1
;         dey
;         lda     (c_sp),y
;         sta     ptr1

; ; Look at the first character in mode

;         ldx     #$00            ; Mode will be in X
;         lda     (ptr1),y        ; Get first char from mode
;         cmp     #'w'
;         bne     @L1
;         ldx     #(O_WRONLY | O_CREAT | O_TRUNC)
;         bne     @L3
; @L1:    cmp     #'r'
;         bne     @L2
;         ldx     #O_RDONLY
;         bne     @L3
; @L2:    cmp     #'a'
;         bne     invmode
;         ldx     #(O_WRONLY | O_CREAT | O_APPEND)

; ; Look at more chars from the mode string

; @L3:    iny                     ; Next char
;         beq     invmode
;         lda     (ptr1),y
;         beq     modeok          ; End of mode string reached
;         cmp     #'+'
;         bne     @L4
;         txa
;         ora     #O_RDWR         ; Always do r/w in addition to anything else
;         tax
;         bne     @L3
; @L4:    cmp     #'b'
;         beq     @L3             ; Binary mode is ignored

; ; Invalid mode

; invmode:
;         lda     #EINVAL
;         jsr     ___seterrno     ; Set __errno, returns zero in A
;         tax                     ; a/x = 0
;         jmp     incsp4

; ; Mode string successfully parsed. Store the binary mode onto the stack in
; ; the same place where the mode string pointer was before. Then call open()

; modeok: ldy     #$00
;         txa                     ; Mode -> A
;         sta     (c_sp),y
;         tya
;         iny
;         sta     (c_sp),y
;         ldy     #4              ; Size of arguments in bytes
;         jsr     _open           ; Will cleanup the stack

; ; Check the result of the open() call

;         cpx     #$FF
;         bne     openok
;         cmp     #$FF
;         bne     openok
;         jmp     return0         ; Failure, errno/__oserror already set

; ; Open call succeeded

; openok: ldy     file
;         sty     ptr1
;         ldy     file+1
;         sty     ptr1+1
;         ldy     #_FILE::f_fd
;         sta     (ptr1),y        ; file->f_fd = fd;
;         ldy     #_FILE::f_flags
;         lda     #_FOPEN
;         sta     (ptr1),y        ; file->f_flags = _FOPEN;

; ; Return the pointer to the file structure

;         lda     ptr1
;         ldx     ptr1+1
;         rts

; .endproc




















; ; ;--------------------------------------------------------------------------
; ; ; closeallfiles: Close all open files.

; ; .proc   closeallfiles

; ;         ldx     #MAX_FDS-1
; ; loop:   lda     fdtab,x
; ;         beq     next            ; Skip unused entries

; ; ; Close this file

; ;         txa
; ;         pha                     ; Save current value of X
; ;         ldx     #0
; ;         jsr     _close
; ;         pla
; ;         tax

; ; ; Next file

; ; next:   dex
; ;         bpl     loop

; ;         rts

; ; .endproc




; ;--------------------------------------------------------------------------
; ; _open

; .proc   _open

; ; Throw away any additional parameters passed through the ellipsis

;         dey                     ; Parm count < 4 shouldn't be needed to be...
;         dey                     ; ...checked (it generates a c compiler warning)
;         dey
;         dey
;         beq     parmok          ; Branch if parameter count ok
;         jsr     addysp          ; Fix stack, throw away unused parameters

; ; Parameters ok. Pop the flags and save them into tmp3

; parmok: jsr     popax           ; Get flags
;         sta     tmp3

; ; Get the filename from stack and parse it. Bail out if is not ok

;         jsr     popax           ; Get name
;         jsr     fnparse         ; Parse it
;         tax
;         bne     oserror         ; Bail out if problem with name

; ; Get a free file handle and remember it in tmp2

;         jsr     freefd
;         lda     #EMFILE         ; Load error code
;         bcs     seterrno        ; Jump in case of errors
;         stx     tmp2

; ; Check the flags. We cannot have both, read and write flags set, and we cannot
; ; open a file for writing without creating it.

;         lda     tmp3
;         and     #(O_RDWR | O_CREAT)
;         cmp     #O_RDONLY       ; Open for reading?
;         beq     doread          ; Yes: Branch
;         cmp     #(O_WRONLY | O_CREAT)   ; Open for writing?
;         beq     dowrite

; ; Invalid open mode

;         lda     #EINVAL

; ; Error entry. Sets _errno, clears __oserror, returns -1

; seterrno:
;         jmp     ___directerrno

; ; Error entry: Close the file and exit. OS error code is in A on entry

; closeandexit:
;         pha
;         lda     tmp2
;         clc
;         adc     #LFN_OFFS
;         jsr     CLOSE
;         ldx     fnunit
;         jsr     closecmdchannel
;         pla

; ; Error entry: Set oserror and errno using error code in A and return -1

; oserror:jmp     ___mappederrno

; ; Read bit is set. Add an 'r' to the name

; doread: lda     #'r'
;         jsr     fnaddmode       ; Add the mode to the name
;         lda     #LFN_READ
;         bne     common          ; Branch always

; ; If O_TRUNC is set, scratch the file, but ignore any errors

; dowrite:
;         lda     tmp3
;         and     #O_TRUNC
;         beq     notrunc
;         jsr     scratch

; ; Complete the file name. Check for append mode here.

; notrunc:
;         lda     tmp3            ; Get the mode again
;         and     #O_APPEND       ; Append mode?
;         bne     append          ; Branch if yes

; ; Setup the name for create mode

;         lda     #'w'
;         jsr     fncomplete      ; Add type and mode to the name
;         jmp     appendcreate

; ; Append bit is set. Add an 'a' to the name

; append: lda     #'a'
;         jsr     fnaddmode       ; Add open mode to file name
; appendcreate:
;         lda     #LFN_WRITE

; ; Common read/write code. Flags in A, handle in tmp2

; common: sta     tmp3
;         jsr     fnset           ; Set the file name

;         lda     tmp2
;         clc
;         adc     #LFN_OFFS
;         ldx     fnunit
;         ldy     fnisfile        ; Is this a standard file on disk?
;         beq     nofile          ; Branch if not
;         tay                     ; Use the LFN also as SA for files
; nofile:                         ; ... else use SA=0 (read)
;         jsr     SETLFS          ; Set the file params

;         jsr     OPEN
;         bcs     oserror

; ; Open the drive command channel and read it

;         ldx     fnunit
;         jsr     opencmdchannel
;         bne     closeandexit
;         ldx     fnunit
;         jsr     readdiskerror
;         bne     closeandexit    ; Branch on error

; ; File is open. Mark it as open in the table
;         ; tmp2: file handle, tmp3: LNF_READ
;         ; so save tmp3 to file handel offset by tmp2
;         ldx     tmp2
;         lda     tmp3
;         sta     fdtab,x
;         lda     fnunit
;         sta     unittab,x       ; Remember

; ; Done. Return the handle in a/x

;         txa                     ; Handle
;         ldx     #0
;         stx     ___oserror      ; Clear __oserror
;         rts

; .endproc

