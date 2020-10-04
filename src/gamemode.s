.include "snes.inc.s"
.include "structs.inc.s"

.export init_player_graphics_fields
.export init_sprint, init_versus

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

; state that initializes the sprint gamemode
; make sure you also set vblank_state to blank_screen when you switch to this state!
init_sprint:
        ldx #sprint
        stx main_state
        jmp init_1p

; state that initializes the sprint gamemode
; make sure you also set vblank_state to blank_screen when you switch to this state!
init_versus:
        ldx #versus
        stx main_state
        jmp init_2p

sprint:
        phd

        pea player1
        pld                             ; set direct page to player 1's page
        jsr tick_player                 ; tick player 1

        pld

        rts

versus:
        phd

        pea player1
        pld                             ; set direct page to player 1's page
        jsr tick_player

        pea player2
        pld                             ; set direct page to player 2's page
        jsr tick_player

        pld

        rts