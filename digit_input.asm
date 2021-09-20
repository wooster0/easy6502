; this program allows entering ones and zeroes into a display.
; what was supposed to become a clock grew into something slightly different.

define latest_keypress $ff
define screen $0200
define char_0 $30
define char_9 $39
define digit_color 1
define rectangle_line_color 15
define rectangle_corner_color 12
define rectangle_fill_color 11

; load digit data.
; each digit takes up 2 bytes to store the pixels

; one
lda #%01101010
sta 0
lda #%01010110
sta 1

; zero
lda #%01110100
sta 2
lda #%10010010
sta 3

jsr draw_rectangle
lda #1
sta $f5
new_input:
	jsr await_number_keypress
	lda $f3
	sbc #$30

	clc
	adc #1

	; multiply the index by 2 because every digit is 2
	; bytes long
	asl

	; the index of the digit we want to draw is
	; going to be in $f0
	sta $f0

	jsr load_and_draw_digit
return:
	lda $f5
	clc
	adc #4
	sta $f5
	lda #0
	sta $f2
	ldx #0
	ldy #0
	jsr new_input

load_and_draw_digit:
	; load the first byte
	ldx $f0
	lda $0, x

	pha

	ldx #0 ; X-axis
	ldy $f5 ; the initial index is loaded from $f5
load_and_draw_digit_check:
	pla
	pha

	; check the last bit
	and #%00000001

	beq skip_draw

	lda #digit_color
	sta $0220, y ; base y is 1
skip_draw:
	inx
	iny

	; cut off the last bit, making sure
	; we check a different bit next time
	pla
	lsr
	pha

	cmp #0
	beq load_second_byte

	continue:

	cpx #3
	bne load_and_draw_digit_check

	tya
	adc #28 ; 32 - 4
	tay

	ldx #0

	jmp load_and_draw_digit_check
load_second_byte:
	; if $f2 is 1, that means we already loaded
	; the second byte, meaning we can return
	lda $f2
	cmp #1
	beq return

	pla

	; temporarily store X in f1
	stx $f1

	; load the second byte
	ldx $f0
	lda $1, x

	ldx $f1

	pha

	; in $f2 we indicate that the
	; second byte has been loaded
	lda #1
	sta $f2

	jmp continue

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

	sta $f3 ; store the input in $f3

	; clear for the next input
	lda #0
	sta latest_keypress

	rts

draw_rectangle:
	; X is the index

	jsr draw_corner
	jsr draw_horizontal_line
	jsr draw_corner

	; advance to the next line
	txa
	adc #$12
	tax

	jsr draw_vertical_line
	jsr draw_vertical_line
	jsr draw_vertical_line
	jsr draw_vertical_line
	jsr draw_vertical_line

	jsr draw_corner
	jsr draw_horizontal_line
	jsr draw_corner

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
	cpy #11
	bne draw_horizontal_line_loop
	rts

draw_vertical_line:
	lda #rectangle_line_color
	sta screen, x

	inx

	; fill inside
	ldy #0 ; index
	lda #rectangle_fill_color
draw_vertical_line_fill_loop:
	sta screen, x
	inx
	iny
	cpy #11
	bne draw_vertical_line_fill_loop

	lda #rectangle_line_color
	sta screen, x

	txa
	adc #$13
	tax

	rts

next_line:
	txa
	adc #$12
	tax
	rts
