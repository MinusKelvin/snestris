.include "../snes.inc.s"
.include "gameplay.inc.s"

.export tick_player, init_player

.code

; The caller must set the direct page register to the player's page.
tick_player:
        tdc
        tax
        jmp (Player::state, X)

; The caller must set the direct page register to the player's page.
init_player:
        ; initialize fields

        ; clear board
        lda #0
        ldy #400
:       dey
        sta (Player::board), Y
        bpl :-

        ; DMA empty board tileset into relevant vram address
        ldx Player::vram
        stx VMADDL              ; tileset will be written to VRAM address $0000
        lda #1
        sta DMAP                ; to PPU (2 registers write once)
        lda #<VMDATAL
        sta BBAD                ; to VMDATA register
        ldx #.loword(empty_board)
        stx A1TL
        lda #^empty_board
        sta A1TB                ; from empty_board
        ldx #empty_board_len
        stx DASL                ; transfer however many bytes empty_board is
        lda #1
        sta MDMAEN              ; initiate DMA transfer

        ; Init background scroll
        lda Player::scroll_x_offset
        sta (Player::scroll_x_ptr)
        lda #$2F
        sta (Player::scroll_y_ptr)

        ; switch to countdown state
        jsr to_countdown

        rts


nothing_state:
        rts
