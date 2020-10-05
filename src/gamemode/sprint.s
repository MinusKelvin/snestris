.include "../snes.inc.s"

.export to_sprint

.code

to_sprint:
        ldx #init_sprint
        stx main_state
        ldx #blank_screen
        stx vblank_state

        rts

init_sprint:
        ldx #sprint
        stx main_state
        jmp init_1p

sprint:
        jmp tick_1p
