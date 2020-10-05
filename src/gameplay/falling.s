.include "../snes.inc.s"
.include "gameplay.inc.s"
.include "../render.inc.s"

.export falling

.code

falling:
        ; move right check
        lda #Input::right
        bit Player::used_inputs
        beq @skip_move_right

        ; right pressed
        inc Player::px
        jsr check_location_valid
        bcc @move_right_failed

        lda #Input::right
        trb Player::used_inputs
        bra @skip_move_right

@move_right_failed:
        dec Player::px
@skip_move_right:

        ; move left check
        lda #Input::left
        bit Player::used_inputs
        beq @skip_move_left

        ; left pressed
        dec Player::px
        jsr check_location_valid
        bcc @move_left_failed

        lda #Input::left
        trb Player::used_inputs
        bra @skip_move_left

@move_left_failed:
        inc Player::px
@skip_move_left:

        lda #0
        xba                             ; clear the upper half of the 16-bit accumulator
        lda Player::piece_state
        asl
        asl
        tay                             ; index into piece info tables in Y register

        ldx oam_idx                     ; sprite index in X register
        lda #$04
        sta $00                         ; loop counter. 1 iteration per cell

@draw_piece_loop:
        ; calculate tile X position
        ; this should be (cellx + piecex)*8 + scroll offset + adjustment
        ; cellx + piecex could set carry, but due to invariants asl will shift 0 into carry
        clc
        lda Player::px
        adc piece_cell_x, Y
        asl
        asl
        asl
        adc #$20
        adc Player::scroll_x_offset
        sta oam_buf + Sprite::xcoord, X

        ; calculate tile Y position
        ; this should be adjustment - (celly + piecey)*8
        clc
        lda Player::py
        adc piece_cell_y, Y
        asl
        asl
        asl
        eor #$FF
        sec
        adc #$C8
        sta oam_buf + Sprite::ycoord, X

        lda piece_cell_dir, Y
        sta oam_buf + Sprite::chr, X    ; sprite graphic connected texture
        stz oam_buf + Sprite::flags, X  ; palette 0, nothing special
        .repeat .sizeof(Sprite)
                inx
        .endrepeat

        iny
        dec $00
        bne @draw_piece_loop

        stx oam_idx                     ; update oam_idx

        rts