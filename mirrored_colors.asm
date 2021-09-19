LDA #0 ; color and index

first_draw_pass:
  TAX
  STA $0200, X
  PHA ; push for the second pass
  ADC #1
  CMP #$10
  BNE first_draw_pass

TAX
DEX

second_draw_pass:
  PLA
  INX
  STA $0200, X
  CPX #$20
  BNE second_draw_pass
