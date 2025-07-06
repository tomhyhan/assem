.segment "RODATA"
hello: .byte "hello world!", $00
CLRHOME=$FF5B
;$FF81;$E544

.segment "CODE"

JSR clear_screen
JSR main
JSR loop

clear_screen:
  JSR CLRHOME
  RTS

print_char:
  LDA hello, X
  CLC
  SBC #$3F
  STA $0400, X
  INX
  CPX #$0C
  BNE print_char
  RTS

main:
  JSR CLRHOME
  LDX #$00
  JSR print_char
  RTS

loop:
  JMP loop
