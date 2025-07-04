.segment "CODE"

main:
  LDA #$01
  STA $0400
  LDA #$02
  STA $0401

loop:
  JMP loop
