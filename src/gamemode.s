.include "snes.inc.s"
.include "structs.inc.s"

.export init_sprint, init_player_graphics_fields

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

        rts

; state that initializes the sprint gamemode
; make sure you also set vblank_state to blank_screen when you switch to this state!
init_sprint:
        ; set state to sprint, vblank state to show game
        ldx #sprint
        stx main_state
        ldx #show_screen
        stx vblank_state

        ; setup common graphics registers
        lda #$10<<2
        sta BG1SC                       ; one tilemap at address $4000
        lda #$11<<2
        sta BG2SC                       ; one tilemap at address $4400
        stz BG12NBA                     ; BGs 1&2 have character data at address $0000
        lda #%10001
        sta TM                          ; enable obj, BG1 for main screen

        phd

        ; init player 1
        pea player1
        pld                             ; set direct page to player1's page
        jsr init_player
        pld

        ; done
        rts

sprint:
        phd

        pea player1
        pld                             ; set direct page to player1's page
        jsr tick_player                 ; tick player 1

        pld

        rts
