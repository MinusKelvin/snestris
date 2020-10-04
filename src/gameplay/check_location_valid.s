.include "../snes.inc.s"
.include "gameplay.inc.s"

.export check_location_valid

.code

; Sets the carry if the piece is in a valid location, clears it if it's not
check_location_valid:
        lda #0
        xba                             ; clear upper half of C
        lda Player::piece_state
        asl
        asl
        tax                             ; X = piece cell index
        ldy #4                          ; Y = loop counter

@check_cell_loop:
        ; check x coordinate
        lda Player::px
        clc
        adc piece_cell_x, X             ; calculate cell x coord
        bmi @invalid                    ; cell is off the left side of the playfield
        cmp #10
        bpl @invalid                    ; cell is off the right side of the playfield

        ; check y coordinate
        lda Player::py
        clc
        adc piece_cell_y, X             ; calculate cell y coord
        bmi @invalid                    ; cell is off the bottom of the playfield
        cmp #40
        bpl @invalid                    ; cell is off the top of the playfield

        inx
        dey
        bne @check_cell_loop

        ; all cells valid
        sec
        rts

@invalid:
        clc
        rts
