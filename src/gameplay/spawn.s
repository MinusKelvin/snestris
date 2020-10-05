.include "../snes.inc.s"
.include "gameplay.inc.s"

.export to_spawn_delay

.code

; Switch to spawn delay state (TODO)
to_spawn_delay:
        ldx #spawn_delay
        stx Player::state
        lda #4
        sta Player::timer
        rts


spawn_delay:
        dec Player::timer
        beq @spawn_piece
        rts

@spawn_piece:
        lda #0
        xba

        ; TODO get piece from queue
        lda #0

        asl
        asl
        sta Player::piece_state         ; piece state = piece num * 4

        ; Copy this piece's color palette to the relevant palette 
        asl
        asl
        bit #$10
        beq :+
        adc #2                          ; odd-numbered pieces have their palettes offset 1 color
:       adc #$50                        ; source palette byte = 2*(piece num * $08 + $28)
        rep #$21
        .a16
        adc #palette
        tax                             ; source palette ptr is in X register

        lda Player::sprite_palette      ; sprite palette is either 0 or 2
        and #$FF
        asl
        asl
        asl
        asl
        adc #palette + $102             ; destination palette byte = 2*($10 * sprite palette + $81)
        tay                             ; destination palette ptr is in Y register
        lda #$10                        ; 8 colors = $10 bytes
        mvn #0, #0
        sep #$20
        .a8

        lda #4
        sta Player::px
        lda #19
        sta Player::py

        ldx #falling
        stx Player::state

        rts