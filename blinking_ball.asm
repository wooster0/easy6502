; a blinking ball controllable with WASD

define W 119
define S 115
define A 97
define D 100

jsr init

loop:
	jsr draw_player
	jsr clear_player
	jsr handle_movement
	jmp loop

init:
	ldx #0 ; player position
	stx $1 ; make sure $1 is zeroed
	lda #1 ; color
	rts

handle_movement:
	lda $ff ; load last pressed key

	; reset the last pressed key so that we only move on new input
	ldy #0
	sty $ff

	cmp #W
	beq move_up
	cmp #S
	beq move_down
	cmp #A
	beq move_left
	cmp #D
	beq move_right

	rts

move_up:
	txa
	sbc #$20
	tax
	rts

move_down:
	txa
	adc #$1f
	tax
	rts

move_left:
	dex
	rts

move_right:
	inx
	rts

draw_player:
	lda #1 ; white
	sta $0200, X
	rts

clear_player:
	lda #0 ; black
	sta $0200, X
	rts
