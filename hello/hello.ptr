.segment "RODATA"
hello: .byte "hello world!", $00
CLRHOME=$FF5B
;$FF81;$E544
E8=$E8
E9=$E9
.segment "CODE"

JSR clear_screen
JSR main
JSR loop

clear_screen:
  JSR CLRHOME
  RTS

print_char:
  LDA (E8), Y
  ; sub only when X is Alpha
  SEC
  SBC  #$40
  BPL store_a
  ADC  #$40
store_a:
  STA $0400, Y
  INY
  CPY #$0C
  BNE print_char
  RTS

main:
  JSR CLRHOME
  LDX #<(hello)
  STX E8
  LDX #>(hello)
  STX E9
  LDY #$00
  JSR print_char
  RTS

loop:
  JMP loop
