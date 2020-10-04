.include "snes.inc.s"
.include "structs.inc.s"

.export tick_player, init_player

.code

.macro push_vram_tiles v1, v2, v3, v4, v5, v6, v7, v8, v9, v10
.ifblank v1
        stx vram_update_idx
        .exitmacro
.else
        lda #v1
        sta vram_update_buf, X
        inx
        inx
        push_vram_tiles v2, v3, v4, v5, v6, v7, v8, v9, v10
.endif
.endmacro

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

; Switch to spawn delay state (TODO)
to_spawn_delay:
        ldx #spawn_delay
        stx Player::state
        lda #4
        sta Player::timer
        rts

spawn_delay:
        dec Player::timer
        beq @spawn_piece
        rts

@spawn_piece:
        lda #0
        sta Player::piece_state
        lda #4
        sta Player::px
        lda #19
        sta Player::py

        ldx #falling
        stx Player::state

        rts

falling:
        lda #0
        xba                             ; clear the upper half of the 16-bit accumulator
        lda Player::piece_state
        asl
        asl
        tay                             ; index into piece info tables in Y register

        ldx oam_idx                     ; sprite index in X register
        lda #$04
        sta $00                         ; loop counter. 1 iteration per cell

@draw_piece_loop:
        ; calculate tile X position
        ; this should be (cellx + piecex)*8 + scroll offset + adjustment
        ; cellx + piecex could set carry, but due to invariants asl will shift 0 into carry
        clc
        lda Player::px
        adc piece_cell_x, Y
        asl
        asl
        asl
        adc #$20
        adc Player::scroll_x_offset
        sta oam_buf + Sprite::xcoord, X

        ; calculate tile Y position
        ; this should be adjustment - (celly + piecey)*8
        clc
        lda Player::py
        adc piece_cell_y, Y
        asl
        asl
        asl
        eor #$FF
        sec
        adc #$C8
        sta oam_buf + Sprite::ycoord, X

        lda piece_cell_dir, Y
        sta oam_buf + Sprite::chr, X    ; sprite graphic connected texture
        stz oam_buf + Sprite::flags, X  ; palette 0, nothing special
        .repeat .sizeof(Sprite)
                inx
        .endrepeat

        iny
        dec $00
        bne @draw_piece_loop

        stx oam_idx                     ; update oam_idx

        rts

nothing_state:
        rts

.rodata

piece_cell_x:
        ; Z
        .byte   $FF, $00, $00, $01      ; Spawn
        .byte   $01, $01, $00, $00      ; Cw
        .byte   $01, $00, $00, $FF      ; 180
        .byte   $FF, $FF, $00, $00      ; Ccw

piece_cell_y:
        ; Z
        .byte   $01, $01, $00, $00      ; Spawn
        .byte   $01, $00, $00, $FF      ; Cw
        .byte   $FF, $FF, $00, $00      ; 180
        .byte   $FF, $00, $00, $01      ; Ccw

piece_cell_dir:
        .byte   $B, $5, $A, $7          ; Spawn
        .byte   $D, $6, $9, $E          ; Cw
        .byte   $7, $A, $5, $B          ; 180
        .byte   $E, $9, $6, $D          ; Ccw
