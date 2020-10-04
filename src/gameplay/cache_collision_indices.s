.include "../snes.inc.s"
.include "gameplay.inc.s"

.export cache_collision_indices

.code

cache_collision_indices:
        lda Player::px
        sta $00
        stz $01                         ; w$00 = zero-extended px

        lda #0
        xba                             ; clear upper half of C
        lda Player::py
        asl
        tax                             ; X is now an index into the multiplication table
        rep #$21                        ; 16-bit accumulator, clear carry
        .a16
        lda mul_10, X                   ; py * 10

        adc $00
        sta $00                         ; w$00 = px + py*10

        lda Player::piece_state
        and #$FF                        ; need an 8-bit load, don't want to switch sizes again
        asl
        asl
        asl                             ; 4 cells * 2 bytes per word
        tax                             ; X = index into piece i table
        ldy #8                          ; Y = loop variable, but also index into cell index cache

@collision_index_loop:
        dey
        dey

        lda piece_cell_offset, X
        clc
        adc $00
        sta collision_index_cache, Y    ; store cached cell index

        inx
        inx
        bne @collision_index_loop

        ; done; go back to 8-bit accumulator
        sep #$20
        .a8
        rts
