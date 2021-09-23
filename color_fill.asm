; draws pixels with random colors at random positions of the screen until the whole screen is filled.
; filled positions are recorded in a buffer and aren't drawn to again.

; NB: BEQ branches when zero flag is 1 and BNE branches when zero flag is 0.

define random $fe
define positionL $00
define positionH $01
; the buffer to save filled positions to.
; it starts after $fe and $ff to make sure it doesn't clash with those values.
define buffer $100

ldx #0 ; buffer index
ldy #0 ; used to draw with indirect addressing and should thus generally remain zero

drawRandomPixel:
    ; load a random byte
    lda random
    sta positionL

    ; load a random byte in range 2 to 5.
    ; remember that the screen buffer starts at $0200 and goes to $05ff (note the 2 and the 5 in those hex integers)
    lda random
    and #%00000011 ; with this we will have a byte in range 0 to 3
    clc
    adc #2 ; now add 2 to make the range 2 to 5
    sta positionH

    ; make sure the random position we just generated
    ; hasn't already been drawn to previously
    jsr checkWhetherBufferContainsPosition
    bcs drawRandomPixel ; if so, the carry will be set. in that case, we try again.

    ; otherwise, the position will be recorded in the buffer
    lda positionL
    sta buffer, x
    inx
    lda positionH
    sta buffer, x
    inx

    ; INX affects the zero flag and is set if it's zero (i.e. an overflow happened)
    ; and BEQ will branch if the zero flag is set
    beq overflow

    ; draw the pixel
    lda random ; random color
    sta (positionL), y

    jmp drawRandomPixel

; checks whether the buffer contains the position of positionL and positionH.
; Y will be initially zero.
checkWhetherBufferContainsPosition:
    ; did we reach the end of the buffer?
    cpy x
    beq bufferDoesntContainPosition

    lda positionL
    cmp buffer, y
    bne continue

    ; the buffer contains the position low byte

    lda positionH
    cmp buffer, y
    bne continue

    ; the buffer contains both the position low byte and the position high byte
    sec
    ldy #0
    rts
continue:
    iny
    jmp checkWhetherBufferContainsPosition
bufferDoesntContainPosition:
    clc
    ldy #0
    rts

overflow:
    brk
