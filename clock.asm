; a clock displaying the minute and second.
; the time is initially configured using the number keys.

define latest_keypress $ff
define screen $0200
define char_0 $30
define char_9 $39
define digit_color 1
define rectangle_line_color 15
define rectangle_corner_color 12
define rectangle_fill_color 11

jsr draw_rectangle

; read minute digit one
jsr await_number_keypress
jsr convert_keypress_to_integer
jsr multiply_by_10

; read minute digit two
jsr await_number_keypress
jsr convert_keypress_to_integer
jsr multiply_by_10

brk

await_number_keypress:
	lda latest_keypress
	cmp #0
	beq await_number_keypress

	; we got input.
	; is it a digit?

	cmp #char_0
	; if the keypress is less than '0',
	; the carry bit will be cleared
	bcc await_number_keypress

	cmp #char_9
	; if the keypress is greater than '9',
	; the carry bit will be set
	bcs await_number_keypress

	; clear for the next input
	lda #0
	sta latest_keypress

	rts

convert_keypress_to_integer:
	sbc #$30
	rts

multiply_by_10:
	; to do this, we will do A = A*2 + A*8

	asl ; with this A is multiplied by 2
	sta $0 ; store A*2 to add it later
	asl ; with this A is multiplied by 4
	asl ; with this A is multiplied by 8
	adc $0 ; here we add the two
	rts

draw_rectangle:
	; X is the index
	jsr draw_corner
	jsr draw_horizontal_line
	jsr draw_corner

	; advance to the next line
	txa
	adc #$13
	tax

	jsr draw_vertical_line

	; advance to the next line
	txa
	adc #$15
	tax

	jsr draw_vertical_line

	rts

draw_corner:
	lda #rectangle_corner_color
	sta screen, x
	inx
	rts

draw_horizontal_line:
	ldy #0 ; index
	lda #rectangle_line_color
draw_horizontal_line_loop:
	sta screen, x
	inx
	iny
	cpy #10
	bne draw_horizontal_line_loop
	rts

draw_vertical_line:
	lda #rectangle_line_color
	sta screen, x

	; increase index
	txa
	adc #10
	tax

	lda #rectangle_line_color
	inx
	sta screen, x

	rts

next_line:
	txa
	adc #$13
	tax
	rts
