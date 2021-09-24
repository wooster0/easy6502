; this was my first approach to drawing pixels with random colors at random positions on the screen until the whole screen is filled
; while never filling the same position more than once.
; the way this works is that filled positions are recorded in a buffer and aren't drawn to again by iterating through the entire
; buffer every time and checking whether the new position is in the buffer.
; this has a time complexity of O(n) and is very slow.

; NB: BEQ branches when zero flag is 1 and BNE branches when zero flag is 0.

; this will give us a random byte
define random $fe

; the position on the screen to fill
define positionL $00
define positionH $01

; the buffer to record filled positions in
define bufferL $02
define bufferH $03

; the buffer index to check filled positions with
define bufferIndexL $04
define bufferIndexH $05

jsr initBuffer

ldy #0 ; Y is used for indirect addressing and should thus remain zero

drawRandomPixel:
    jsr setRandomPosition

    ; make sure the random position we just set
    ; hasn't already been drawn to previously
    jsr checkWhetherBufferContainsPosition
    bcs drawRandomPixel ; if so, the carry will be set and we try again.

    ; otherwise, the position will be recorded in the buffer
    lda positionL
    jsr pushToBuffer
    lda positionH
    jsr pushToBuffer

    ; draw the pixel
    lda random ; random color
    sta (positionL), y

    jmp drawRandomPixel

setRandomPosition:
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

    rts

initBuffer:
    ; the buffer is placed at $1000 to make sure it doesn't clash with anything else
    ; load LSB of the buffer
    lda #$00 ;   $00
    sta bufferL
    ; load MSB of the buffer
    lda #$10 ; $1000
    sta bufferH

    jsr setBufferIndex

    rts

setBufferIndex:
    ; load LSB of the buffer index
    lda #$00 ;   $00
    sta bufferIndexL
    ; load MSB of the buffer index
    lda #$10 ; $1000
    sta bufferIndexH

    rts

incrementBufferIndex:
    ; 1. increment the buffer index low byte.
    lda bufferIndexL
    clc
    adc #1 ; we will use the carry of this operation below
    sta bufferIndexL
    ; 2. add the carry of the previous ADC to the buffer index high byte
    lda bufferIndexH
    adc #0 ; add carry
    sta bufferIndexH

    rts

pushToBuffer:
    ; 1. push
    sta (bufferL), y
    ; 2. increment the buffer low byte
    lda bufferL
    clc
    adc #1 ; we will use the carry of this operation below
    sta bufferL
    ; 3. add the carry of the previous ADC to the buffer high byte
    lda bufferH
    adc #0 ; add carry
    sta bufferH

    rts

; 1. submit your buffer stuff to the IRC as a minimized example
; 2. make a second version that doesn't have its own buffer but just checks for free space from $0200 to $05ff

; checks whether the buffer contains the current position.
checkWhetherBufferContainsPosition:
    lda positionL
    cmp (bufferIndexL), y
    bne continue

    jsr incrementBufferIndex

    ; ; did we reach the end?
    ; lda bufferIndexL
    ; cmp bufferL
    ; bne nextCheck
    lda bufferIndexH
    cmp bufferH
    beq endReached
;nextCheck:

    lda positionH
    cmp (bufferIndexL), y
    bne continue

    ; we have a match.
    ; reset the buffer index and set the carry flag.
    jsr setBufferIndex
    sec
    rts
continue:
    jsr incrementBufferIndex

    ; did we reach the end?
    ; lda bufferIndexL
    ; cmp bufferL
    ; bne checkWhetherBufferContainsPosition
    lda bufferIndexH
    cmp bufferH
    bne checkWhetherBufferContainsPosition
endReached:
    ; reset the buffer index and clear the carry flag.
    jsr setBufferIndex
    clc
    rts
