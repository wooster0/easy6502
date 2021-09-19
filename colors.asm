; A = color to draw
LDA #0

; X = graphics index
LDX #0

draw:
  STA $0200, X ; store A (the color) at $0200 + X

  ADC #1

  CPX #$ff
  INX
  BNE draw
