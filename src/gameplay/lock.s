.include "../snes.inc.s"
.include "../render.inc.s"
.include "gameplay.inc.s"

.export lock

.code

lock:
        ldx #lock_state
        stx Player::state

        jmp draw_piece

lock_state:
        rts
