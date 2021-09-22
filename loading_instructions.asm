; execution starts at $0600

LDA #$E8 ; load INX     ; $0600
STA $0605 ; store below	; $0602
; INX will go here      ; $0605
BRK                     ; $0606
