.include "../snes.inc.s"
.include "gameplay.inc.s"

.export try_move

.code

; Requires collision indices to be cached first
; $02 = delta x, $03 = delta y
; Sets the carry if the move was successful
; mangles C, X, Y, $00, $01, $04, $05
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

        ; calculate delta to apply to collision indices
        lda $03
        asl
        asl
        clc
        adc $03
        asl                             ; multiply by 10

        clc
        adc $02                         ; A = 10*y + x
        sta $04

        bmi @one_extend
        stz $05
        bra @extend_done
@one_extend:
        lda #$FF
        sta $05
@extend_done:

        rep #$20                        ; switch to 16-bit accumulator
        .a16

        ldx #6
@collision_check_loop:
        lda collision_index_cache, X
        clc
        adc $04                         ; A = board index
        tay
        lda #$00FF
        and (Player::board), Y          ; test for collision
        bne @invalid_switch
        dex
        dex
        bpl @collision_check_loop

        ; move successful

        ; update collision index cache
        ldx #6
@collision_index_update_loop:
        lda collision_index_cache, X
        clc
        adc $04
        sta collision_index_cache, X
        dex
        dex
        bpl @collision_index_update_loop

        sep #$20                        ; 8-bit accumulator
        .a8

        ; update piece location
        lda $00
        sta Player::px
        lda $01
        sta Player::py

        sec
        rts

@invalid_switch:
        sep #$20                        ; 8-bit accumulator
        .a8
@invalid:
        clc
        rts
