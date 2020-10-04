.include "snes.inc.s"
.include "structs.inc.s"

.export tick_player, init_player

collision_index_cache = $40

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
        lda #$01
        bit JOY1H
        beq @skip_move_right
        ; right pressed
        inc Player::px
        jsr check_location_valid
        bcs @skip_move_right
        dec Player::px
@skip_move_right:

        lda #$02
        bit JOY1H
        beq @skip_move_left
        ; left pressed
        dec Player::px
        jsr check_location_valid
        bcs @skip_move_left
        inc Player::px
@skip_move_left:

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


; Sets the carry if the piece is in a valid location, clears it if it's not
check_location_valid:
        lda #0
        xba                             ; clear upper half of C
        lda Player::piece_state
        asl
        asl
        tax                             ; X = piece cell index
        ldy #4                          ; Y = loop counter

@check_cell_loop:
        ; check x coordinate
        lda Player::px
        clc
        adc piece_cell_x, X             ; calculate cell x coord
        bmi @invalid                    ; cell is off the left side of the playfield
        cmp #10
        bpl @invalid                    ; cell is off the right side of the playfield

        ; check y coordinate
        lda Player::py
        clc
        adc piece_cell_y, X             ; calculate cell y coord
        bmi @invalid                    ; cell is off the bottom of the playfield
        cmp #40
        bpl @invalid                    ; cell is off the top of the playfield

        inx
        dey
        bne @check_cell_loop

        ; all cells valid
        sec
        rts

@invalid:
        clc
        rts

cache_collision_indices:
        lda Player::px
        sta $00
        stz $01                         ; w$00 = zero-extended px

        lda #0
        xba                             ; clear upper half of C
        lda Player::py
        asl
        tax                             ; X is now an index into the multiplication table
        rep #$21                        ; 16-bit accumulator, clear carry
        .a16
        lda mul_10, X                   ; py * 10

        adc $00
        sta $00                         ; w$00 = px + py*10

        lda Player::piece_state
        and #$FF                        ; need an 8-bit load, don't want to switch sizes again
        asl
        asl
        asl                             ; 4 cells * 2 bytes per word
        tax                             ; X = index into piece i table
        ldy #8                          ; Y = loop variable, but also index into cell index cache

@collision_index_loop:
        dey
        dey

        lda piece_cell_offset, X
        clc
        adc $00
        sta collision_index_cache, Y    ; store cached cell index

        inx
        inx
        bne @collision_index_loop

        ; done; go back to 8-bit accumulator
        sep #$20
        .a8
        rts

.rodata

mul_10:
.repeat 40, i
        .word i*10
.endrepeat

.macro cell_xs d0, x0, y0,  d1, x1, y1,  d2, x2, y2,  d3, x3, y3
        .lobytes x0,  x1,  x2,  x3              ; normal
        .lobytes y0,  y1,  y2,  y3              ; cw
        .lobytes -(x0), -(x1), -(x2), -(x3)     ; 180
        .lobytes -(y0), -(y1), -(y2), -(y3)     ; ccw
.endmacro

.macro cell_ys d0, x0, y0,  d1, x1, y1,  d2, x2, y2,  d3, x3, y3
        .lobytes y0,  y1,  y2,  y3              ; normal
        .lobytes -(x0), -(x1), -(x2), -(x3)     ; cw
        .lobytes -(y0), -(y1), -(y2), -(y3)     ; 180
        .lobytes x0,  x1,  x2,  x3              ; ccw
.endmacro

.macro d_cw d0, d1, d2, d3
        .byte d0 & %0011 << 2 | d0 & %1000 >> 3 | d0 & %0100 >> 1
        .byte d1 & %0011 << 2 | d1 & %1000 >> 3 | d1 & %0100 >> 1
        .byte d2 & %0011 << 2 | d2 & %1000 >> 3 | d2 & %0100 >> 1
        .byte d3 & %0011 << 2 | d3 & %1000 >> 3 | d3 & %0100 >> 1
.endmacro

.macro d_180 d0, d1, d2, d3
        .byte d0 & %0101 << 2 | d0 & %1010 >> 2
        .byte d1 & %0101 << 2 | d1 & %1010 >> 2
        .byte d2 & %0101 << 2 | d2 & %1010 >> 2
        .byte d3 & %0101 << 2 | d3 & %1010 >> 2
.endmacro

.macro d_ccw d0, d1, d2, d3
        .byte d0 & %0001 << 3 | d0 & %0010 << 1 | d0 & %1100 >> 2
        .byte d1 & %0001 << 3 | d1 & %0010 << 1 | d1 & %1100 >> 2
        .byte d2 & %0001 << 3 | d2 & %0010 << 1 | d2 & %1100 >> 2
        .byte d3 & %0001 << 3 | d3 & %0010 << 1 | d3 & %1100 >> 2
.endmacro

.macro cell_dirs d0, x0, y0,  d1, x1, y1,  d2, x2, y2,  d3, x3, y3
        .byte d0, d1, d2, d3
        d_cw  d0, d1, d2, d3
        d_180 d0, d1, d2, d3
        d_ccw d0, d1, d2, d3
.endmacro

.macro cell_offsets d0, x0, y0,  d1, x1, y1,  d2, x2, y2,  d3, x3, y3
        ; normal
        .word .loword(x0+10*y0)
        .word .loword(x1+10*y1)
        .word .loword(x2+10*y2)
        .word .loword(x3+10*y3)
        ; cw
        .word .loword(y0+10*-(x0))
        .word .loword(y1+10*-(x1))
        .word .loword(y2+10*-(x2))
        .word .loword(y3+10*-(x3))
        ; 180
        .word .loword(-(x0)+10*-(y0))
        .word .loword(-(x1)+10*-(y1))
        .word .loword(-(x2)+10*-(y2))
        .word .loword(-(x3)+10*-(y3))
        ; ccw
        .word .loword(-(y0)+10*x0)
        .word .loword(-(y1)+10*x1)
        .word .loword(-(y2)+10*x2)
        .word .loword(-(y3)+10*x3)
.endmacro

.macro piece_spec p0
piece_cell_x:
        cell_xs p0
piece_cell_y:
        cell_ys p0
piece_cell_dir:
        cell_dirs p0
piece_cell_offset:
        cell_offsets p0
.endmacro

.linecont +
piece_spec \
        {$B, -1, 1,  $5, 0, 1,  $A, 0, 0,  $7, 1, 0}
