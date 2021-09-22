; a ball bouncing vertically

; load LSB
lda #$00
sta $00
; load MSB
lda #$02
sta $01

bounce_down:
	jsr wait
	clc

	; clear previous pixel
	lda #0 ; black
	sta ($02), y

	lda #1 ; white
	sta ($00), y

	; add LSB
	lda $00
	sta $02 ; store previous LSB
	adc #$20
	sta $00

	; add carry to MSB
	lda $01
	sta $03 ; store previous MSB
	adc #0
	sta $01

	cmp #6
	bne bounce_down

	; otherwise bounce up

bounce_up:
	jsr wait

	; clear previous pixel
	lda #0 ; black
	sta ($02), y

	lda #1 ; white
	sta ($00), y

	; sub LSB
	lda $00
	sta $02 ; store previous LSB
	sbc #$20
	sta $00

	; sub borrow from MSB
	lda $01
	sta $03 ; store previous MSB
	sbc #0
	sta $01

	cmp #1
	beq bounce_down

	jmp bounce_up

; busy loop
wait:
	ldx #0
wait_loop:
	inx
	cpx #$40
	bne wait_loop
	rts
