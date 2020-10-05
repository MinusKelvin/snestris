.include "../snes.inc.s"
.include "../gameplay/gameplay.inc.s"

.export init_player_graphics_fields, init_1p, init_2p, tick_1p, tick_2p
.export player1, player2

.bss

.align $100
player1:        .tag Player
.align $100
player2:        .tag Player

p1_board:       .res 400
p2_board:       .res 400

.code

init_player_graphics_fields:
        ldx #p1_board
        stx player1 + Player::board
        ldx #p2_board
        stx player2 + Player::board

        ldx #$4000
        stx player1 + Player::vram
        ldx #$4400
        stx player2 + Player::vram

        ldx #bg1_scrollx
        stx player1 + Player::scroll_x_ptr
        inx
        stx player1 + Player::scroll_y_ptr
        ldx #bg2_scrollx
        stx player2 + Player::scroll_x_ptr
        inx
        stx player2 + Player::scroll_y_ptr

        lda #$F0
        sta player1 + Player::scroll_x_offset
        lda #$70
        sta player2 + Player::scroll_x_offset

        stz player1 + Player::sprite_palette
        lda #$02
        sta player2 + Player::sprite_palette

        rts

init_2p:
        ; init player 2
        phd
        pea player2
        pld                             ; set direct page to player 2's page
        jsr init_player
        pld

        lda #%10011
        sta TM                          ; enable obj, BG2, BG1 for main screen

        jmp common_init

init_1p:
        lda #%10001
        sta TM                          ; enable obj, BG1 for main screen
        ; fallthrough

common_init:
        ldx #show_screen
        stx vblank_state

        ; init player 1
        phd
        pea player1
        pld                             ; set direct page to player 1's page
        jsr init_player
        pld

        ; setup common graphics registers
        lda #$10<<2
        sta BG1SC                       ; one tilemap at address $4000
        lda #$11<<2
        sta BG2SC                       ; one tilemap at address $4400
        stz BG12NBA                     ; BGs 1&2 have character data at address $0000

        rts

.macro joy_to_input joyreg
        lda joyreg+1
        and #$0F
        sta $00                         ; L => left, R => right, U => hdrop, D => sdrop
        lda joyreg+1
        lsr
        ora joyreg+1
        and #$40
        ora $00
        sta $00                         ; B | Y => ccw
        lda joyreg
        lsr
        ora joyreg
        sta $01                         ; bit 6 is A | X, bit 4 is LB | RB
        and #$40
        lsr
        ora $00
        sta $00                         ; A | X => cw
        lda $01
        and #$10
        ora $00                         ; LB | RB => hold
.endmacro

tick_2p:
        ; read inputs
        joy_to_input JOY2L
        sta player2 + Player::curr_inputs

        phd
        pea player2
        pld
        jsr tick_player
        pld
        ; fallthrough

tick_1p:
        ; read inputs
        joy_to_input JOY1L
        sta player1 + Player::curr_inputs

        phd
        pea player1
        pld
        jsr tick_player
        pld

        rts
