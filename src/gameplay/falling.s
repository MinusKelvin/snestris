.include "../snes.inc.s"
.include "gameplay.inc.s"

.export falling

.code

falling:
        ; move right check
        lda #Input::right
        bit Player::used_inputs
        beq @skip_move_right

        ; right pressed
        lda #1
        sta $02
        stz $03
        jsr try_move
        bcc @skip_move_right

        ; moved right successfully
        lda #Input::right
        trb Player::used_inputs
@skip_move_right:

        ; move left check
        lda #Input::left
        bit Player::used_inputs
        beq @skip_move_left

        ; left pressed
        lda #<-1
        sta $02
        stz $03
        jsr try_move
        bcc @skip_move_left

        lda #Input::left
        trb Player::used_inputs
@skip_move_left:

        ; save original y position
        lda Player::py
        sta Player::ghost_y

        ; move down until ground is reached
        stz $02
        lda #<-1
        sta $03
:       jsr try_move
        bcs :-

        ; save ghost y and restore original y position
        lda Player::ghost_y
        xba
        lda Player::py
        sta Player::ghost_y
        xba
        sta Player::py

        ; hard drop check
        lda #Input::hdrop
        bit Player::used_inputs
        beq @skip_hdrop

        ; hard drop pressed. teleport to ghost and lock
        lda Player::ghost_y
        sta Player::py
        jmp lock

@skip_hdrop:

        jmp draw_piece
