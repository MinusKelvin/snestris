.include "snes.inc.s"
.include "structs.inc.s"

.export tick_player, init_player

.code

; Board format is 1 byte per cell, 10 cells per row, 40 rows.
; Cell byte is 0cccdddd
; c = color: 0 = garbage, 1-8 = piece
; d = directions:
;       0001 = clear if north connection
;       0010 = clear if south connection
;       0100 = clear if east connection
;       1000 = clear if west connection
;       all bits 0 means empty tile. color must be 0 in this case
; palette number = cell >> 5
; tileset number = cell & $1F

; The caller must set the direct page register to the player's page.
tick_player:
        tdc
        tax
        jmp (Player::state, X)

; The caller must set the direct page register to the player's page.
init_player:
        ; initialize fields
        ldx #nothing_state
        stx Player::state

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

        lda Player::scroll_x_offset
        sta (Player::scroll_x_ptr)
        lda #$2F
        sta (Player::scroll_y_ptr)

        rts

nothing_state:
        rts
