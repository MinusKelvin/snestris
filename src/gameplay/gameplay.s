.include "../snes.inc.s"
.include "gameplay.inc.s"

.export tick_player, init_player

.code

.macro das input, timer
.scope
        ; check left DAS
        lda #input
        bit Player::curr_inputs
        beq reset

        ; button is down
        bit Player::used_inputs
        beq decr

        ; movement input unused. if timer >= 3, decrement
        lda timer
        cmp #3
        bmi skip

decr:
        dec timer
        bne skip

        ; das timer == 0: trigger das input
        lda Player::used_inputs
        ora #input
        sta Player::used_inputs
        lda #2
        sta timer
        bra skip
reset:
        lda #10
        sta timer
skip:
.endscope
.endmacro

; The caller must set the direct page register to the player's page.
tick_player:
        ; Handle button presses & releases
        ; used_input will be 1 if the button had unpressed->pressed transition,
        ;                    0 if the button is unpressed,
        ;                    unchanged if the button remained held

        ; but first, hdrop is special since it should be cleared if the button is held
        lda #Input::hdrop
        trb Player::used_inputs

        lda Player::prev_inputs
        eor #$FF
        ora Player::used_inputs
        and Player::curr_inputs
        sta Player::used_inputs

        lda Player::curr_inputs
        sta Player::prev_inputs

        das Input::left, Player::das_left
        das Input::right, Player::das_right

        tdc
        tax
        jmp (Player::state, X)

; The caller must set the direct page register to the player's page.
init_player:
        ; initialize fields
        stz Player::curr_inputs
        stz Player::used_inputs
        stz Player::prev_inputs
        stz Player::das_left
        stz Player::das_right

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
