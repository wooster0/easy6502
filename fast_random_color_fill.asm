; this is my second approach to drawing pixels with random colors at random points on the screen until the whole screen is filled
; while never filling the same point more than once.
; this program 1. generates a random point and 2. checks whether that point is #0 in the screen buffer from $0200 to $05ff.
; if it is, a new random point is generated, otherwise it 3. draws a pixel with a random color to the point.
; this is in the common case faster than the first approach, see slow_random_color_fill.asm.
; this has a time complexity of O(∞).

; this will give us a random byte
define random $fe

; the point on the screen to fill
define pointL $00
define pointH $01

ldy #0 ; Y is used for indirect addressing and should thus remain zero

drawRandomPixel:
    jsr setNewRandomPoint

    ; draw the pixel
    jsr setRandomColor
    sta (pointL), y

    jmp drawRandomPixel

setRandomColor:
    lda random
    ; make sure the color is in range 1 to 15 to exclude black which represents no color
    ; and would make accurate checking for whether the point has been drawn to harder.
    clc
    adc #1
    and #%00001111 ; limit it to the first 4 bits

    rts

setNewRandomPoint:
    ; load a random byte
    lda random
    sta pointL

    ; load a random byte in range 2 to 5.
    ; remember that the screen buffer starts at $0200 and goes to $05ff (note the 2 and the 5 in those hex integers)
    lda random
    and #%00000011 ; with this we will have a byte in range 0 to 3
    clc
    adc #2 ; now add 2 to make the range 2 to 5
    sta pointH

    lda (pointL), y
    cmp #0
    bne setNewRandomPoint

    rts
