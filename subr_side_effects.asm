main:
	ldx #17
	ldy #7
	jsr set_pixel

	jmp exit

; the screen width
width:
	; this is data that will be in RAM
	; when the program starts.
	; this is like part of the data section.
	dcb 32

; this subroutine takes X and Y to set a pixel at that position.
; note that Y can't currently be more than 7 because that causes
; an overflow. we would have to use RAM to have a 16-bit integer
; for the address
set_pixel:
	; the formula to determine the index for screen memory
	; is `x + y * width`.
	; first, we calculate `y * width` using
	; the A register, so we'll store the result in A.
	lda #0

	; use the Y arg to determine
	; how many times to add `width` to A
	cpy #$00
	beq skip_mul
	mul:
		; add without carry
		clc
		adc width
		dey
		bne mul
	skip_mul:
		; Y is 0 and we don't need to add `width`

	; now add arg X to A.
	; to do this we will need to use non-stack memory.
	; there's no other way.
	;
	; well, I think we could use the stack
	; but only if we know there's not currently
	; anything on the stack.
	; if it was so, we could abuse the knowledge that
	; the stack lives at $0100 to $01ff, growing
	; downwards.
	; remember that the stack also lives in RAM (in page 1)
	; but it's obviously reserved as stack memory so
	; in theory we could do something like this:
	; 
	;	txa
	;	pha
	;	clc
	;	adc $0100
	;	pla
	;
	; again, this requires the stack to be empty which it
	; won't be anyway because we're inside a subroutine here.
	;
	; the problem with using non-stack memory
	; (in this case we will use $00) is that because of that
	; this subroutine will cause a side effect:
	; what if there is an important external value at $00?
	; this is why we have to make sure that all memory
	; (except for page 1, the stack memory)
	; stays as it was before our subroutine was called.
	;
	; additionally, you could argue that modifying the processor status
	; register (i.e. the flags) inside a subroutine is also
	; a bad side effect.
	; this however is ridiculous and I will not
	; do PHP in every subroutine and PLP at the end.
	; and then what about mutating A, X, and Y inside a
	; subroutine? is that also a "bad side effect"?
	; it's complicated and ultimately, of course, it all
	; depends on entirely on what you're actually doing.

	; use Y because we no longer need the Y arg
	tay
	lda $00
	pha
	tya

	; now the original value at $00 is in the stack
	; and we can use memory location $00 for ourself
	stx $00
	clc
	adc $00
	tax

	lda #1
	sta $0200,x ; $0200 is the screen

	; now reset memory location $00
	pla
	sta $00
	
	; we're done!
	rts

exit:
