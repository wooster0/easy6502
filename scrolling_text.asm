define SCREEN $f000 ; memory-mapped screen
define TEXT_X 0
define TEXT_LEN 5

; initialize variables
lda #0
sta TEXT_X

loop:
	ldx #0
	ldy TEXT_X
draw:
	lda text, x

	; draw the byte to the screen
	sta SCREEN, y

	inx ; next byte
	iny ; next screen pos

	cpx #TEXT_LEN
	bne draw

	; clear text
	ldy TEXT_X
	lda text, x
	ldx #0
clear:
	sta SCREEN, y
	iny
	inx
	cpx #TEXT_LEN
	bne clear

	lda TEXT_X
	adc #1
	sta TEXT_X

	jmp loop

text:
	dcb "H", "E", "L", "L", "O"
	dcb 32 ; space for clearing
