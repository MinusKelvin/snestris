.include "../snes.inc.s"
.include "gameplay.inc.s"
.include "../render.inc.s"

.export to_countdown

.code

to_countdown:
        ; init fields
        ldx #countdown_state
        stx Player::state
        lda #180
        sta Player::timer

        ; push vram update to display the left side of the 3
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$244                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0023, $0025, $8023
        sep #$20
        .a8

        ; push vram update to display the right side of the 3
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$245                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0024, $0026, $8024
        sep #$20
        .a8

        rts

countdown_state:
        dec Player::timer
        lda Player::timer
        beq @start_game                 ; timer == 0
        cmp #60
        beq @display_1_br               ; timer == 60
        cmp #120
        beq @display_2                  ; timer == 120
        rts

@start_game:
        jmp @clear_display

@display_1_br:
        jmp @display_1

@display_2:
        ; push vram update to display the left side of the 2
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$244                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0023, $0029, $002B
        sep #$20
        .a8

        ; push vram update to display the right side of the 2
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$245                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0024, $002A, $8022
        sep #$20
        .a8

        rts

@display_1:
        ; push vram update to display the left side of the 1
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$244                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0027, $4028, $002C
        sep #$20
        .a8

        ; push vram update to display the right side of the 1
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$245                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0028, $0028, $402C
        sep #$20
        .a8

        rts

@clear_display:
        ; push vram update to erase the left side of the 1
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$244                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0000, $0000, $0000
        sep #$20
        .a8

        ; push vram update to erase the right side of the 1
        ldx vram_update_idx
        lda #$81                        ; increment by 32 on word write, no remapping
        sta vram_update_buf + VramUpdate::vmain, X
        rep #$21                        ; 16 bit accumulator, clear the carry
        .a16
        lda Player::vram
        adc #$245                       ; this should be about the center of the playfield
        sta vram_update_buf + VramUpdate::target, X
        lda #6                          ; 3 tiles
        sta vram_update_buf + VramUpdate::count, X
        txa
        adc #.sizeof(VramUpdate)
        tax
        ; push tiles
        push_vram_tiles $0000, $0000, $0000
        sep #$20
        .a8

        jmp to_spawn_delay