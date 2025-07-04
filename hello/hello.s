.segment "CODE"

main:
  LDA #$01
  STA $0400

loop:
  JMP loop
