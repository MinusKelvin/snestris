.include "../snes.inc.s"
.include "gameplay.inc.s"

.export try_move

.code

; Requires collision indices to be cached first
; $02 = delta x, $03 = delta y
; Sets the carry if the move was successful
; mangles C, X, Y, $00, $01
try_move:
        lda Player::px
        clc
        adc $02
        sta $00                         ; $00 = new x location

        lda Player::py
        clc
        adc $03
        sta $01                         ; $01 = new y location

        jsr check_location_valid
        bcc @invalid

        ; TODO: check for collision with board

        ; move successful
        lda $00
        sta Player::px
        lda $01
        sta Player::py

        sec
        rts

@invalid:
        clc
        rts
