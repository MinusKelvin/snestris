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
        sta Player::piece_state
        lda #4
        sta Player::px
        lda #19
        sta Player::py

        ldx #falling
        stx Player::state

        rts