;
; File generated by cc65 v 2.19 - Git 4e0806c6b
;
	.fopt		compiler,"cc65 v 2.19 - Git 4e0806c6b"
	.setcpu		"6502"
	.smart		on
	.autoimport	on
	.case		on
	.debuginfo	off
	.importzp	c_sp, sreg, regsave, regbank
	.importzp	tmp1, tmp2, tmp3, tmp4, ptr1, ptr2, ptr3, ptr4
	.macpack	longbranch
	.forceimport	__STARTUP__
	.import		_fclose
	.import		_fgets
	.import		_fopen
	.import		_printf
	.export		_main

.segment	"RODATA"

S0002:
	.byte	$54,$45,$53,$54,$2E,$54,$58,$54,$00
S0004:
	.byte	$25,$53,$00
S0003:
	.byte	$52,$00


; ---------------------------------------------------------------
; int __near__ main (void)
; ---------------------------------------------------------------

.segment	"CODE"

.proc	_main: near

.segment	"CODE"

	jsr     decsp7
	ldy     #$04
L0002:	lda     M0001,y
	sta     (c_sp),y
	dey
	bpl     L0002
	lda     #<(S0002)
	ldx     #>(S0002)
	jsr     pushax
	lda     #<(S0003)
	ldx     #>(S0003)
	jsr     _fopen
	ldy     #$05
	jsr     staxysp
	jmp     L0005
L0003:	lda     #<(S0004)
	ldx     #>(S0004)
	jsr     pushax
	lda     #$02
	jsr     leaa0sp
	jsr     pushax
	ldy     #$04
	jsr     _printf
L0005:	lda     c_sp
	ldx     c_sp+1
	jsr     pushax
	ldx     #$00
	lda     #$05
	jsr     pushax
here:
	ldy     #$0A
	jsr     ldaxysp
	jsr     _fgets
	cpx     #$00
	bne     L0006
	cmp     #$00
L0006:	jsr     boolne
	jne     L0003
	ldy     #$06
	jsr     ldaxysp
	jsr     _fclose
	ldx     #$00
	lda     #$00
	jmp     L0001
L0001:	rts

.segment	"RODATA"

M0001:
	.byte	$41,$42,$43,$00
	.res	1,$01

.endproc


.data
junk1: .res 1