.include "../snes.inc.s"

.export to_versus

.code

to_versus:
        ldx #init_versus
        stx main_state
        ldx #blank_screen
        stx vblank_state

        rts

init_versus:
        ldx #versus
        stx main_state
        jmp init_2p

versus:
        jmp tick_2p
