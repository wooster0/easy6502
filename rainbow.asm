; this is essentially an extension of colors.asm with the difference
; that the rainbow extends over the whole screen now

; the screen index. it starts at $0200
lda #$00
sta $00
lda #$02
sta $01
; we will be making use of indirect addressing here.
; the least significant byte comes first in indirect addressing

loop:
	lda $00 ; load color
	sta ($00), y ; draw the pixel

    ; add the least significant byte.
	lda $00
	adc #1 ; this will produce a carry on overflow, at $ff
	sta $00

    ; add the most significant byte.
	; for this we just add the carry (if there is one) of the previous addition.
	lda $01
	adc #0 ; all this does is add the carry,
           ; if there is one
	sta $01

	jmp loop
