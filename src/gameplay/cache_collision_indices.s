.include "../snes.inc.s"
.include "gameplay.inc.s"

.export cache_collision_indices

.code

; mangles C, X, Y, $00, $01
cache_collision_indices:
        lda Player::px
        sta $00
        stz $01                         ; w$00 = zero-extended px

        lda #0
        xba                             ; clear upper half of C
        lda Player::py
        rep #$21                        ; 16-bit accumulator, clear carry
        .a16
        asl
        sta $02                         ; py*2
        asl
        asl
        adc $02                         ; py*10 = py*2 + py*8

        adc $00
        sta $00                         ; w$00 = px + py*10

        lda Player::piece_state
        and #$FF                        ; need an 8-bit load, don't want to switch sizes again
        asl
        asl
        asl                             ; 4 cells * 2 bytes per word
        tax                             ; X = index into piece tables
        ldy #6                          ; Y = loop variable, but also index into cell index cache

@collision_index_loop:
        lda piece_cell_offset, X
        clc
        adc $00
        sta collision_index_cache, Y    ; store cached cell index

        inx
        inx
        dey
        dey
        bpl @collision_index_loop

        ; done; go back to 8-bit accumulator
        sep #$20
        .a8
        rts
