.include "../snes.inc.s"
.include "gameplay.inc.s"
.include "../render.inc.s"

.export draw_piece

.code

draw_piece:
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
        sta oam_buf + Sprite::xcoord + .sizeof(Sprite), X       ; ghost x is the same

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

        ; ghost y is above + (piecey - ghosty)*8
        sta $01
        lda Player::py
        sec
        sbc Player::ghost_y
        asl
        asl
        asl
        adc $01
        sta oam_buf + Sprite::ycoord + .sizeof(Sprite), X       ; ghost y

        lda piece_cell_dir, Y
        sta oam_buf + Sprite::chr, X    ; sprite graphic connected texture
        adc #$20
        sta oam_buf + Sprite::chr + .sizeof(Sprite), X          ; ghost graphic connected texture
        lda Player::sprite_palette
        sta oam_buf + Sprite::flags + .sizeof(Sprite), X        ; ghost sprite doesn't have priority
        ora #$20                        ; priority
        sta oam_buf + Sprite::flags, X
        .repeat .sizeof(Sprite)
                inx
                inx
        .endrepeat

        iny
        dec $00
        bne @draw_piece_loop

        stx oam_idx                     ; update oam_idx

        rts