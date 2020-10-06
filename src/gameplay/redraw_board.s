.include "../snes.inc.s"
.include "../render.inc.s"
.include "gameplay.inc.s"

.export redraw_board

.struct Update
        data    .tag VramUpdate
        tiles   .word 25
.endstruct

.code

; Generates 10 VRAM updates at the same time, each of which draw a whole column (25 tiles)

redraw_board:
        ldx vram_update_idx             ; X is vram_update_idx

        lda #$81                        ; Increment by 32, no remapping
.repeat 10, i
        sta vram_update_buf + i*.sizeof(Update) + VramUpdate::vmain, X
.endrepeat

        rep #$21                        ; 16-bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$EA
.repeat 10, i
        dec
        sta vram_update_buf + i*.sizeof(Update) + VramUpdate::target, X
.endrepeat

        lda #50                         ; 25 tiles
.repeat 10, i
        sta vram_update_buf + i*.sizeof(Update) + VramUpdate::count, X
.endrepeat
        sep #$20
        .a8

        ldy #10*25                      ; Y is board index of left column
        lda #25
        sta $00                         ; loop counter
@draw_loop:
.repeat 10, i
        dey
        lda (Player::board),Y
        and #$1F
        sta vram_update_buf + i*.sizeof(Update) + Update::tiles, X
        lda (Player::board),Y
        and #<~$1F
        lsr
        lsr
        adc #$08
        sta vram_update_buf + i*.sizeof(Update) + Update::tiles + 1, X
.endrepeat
        inx
        inx
        dec $00
        beq @draw_loop_done
        jmp @draw_loop
@draw_loop_done:

        rep #$21                        ; 16-bit accumulator, clear carry
        .a16
        lda vram_update_idx
        adc #10*.sizeof(Update)
        sta vram_update_idx
        sep #$20                         ; 8-bit accumulator
        .a8

        rts