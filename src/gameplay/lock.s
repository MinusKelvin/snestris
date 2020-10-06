.include "../snes.inc.s"
.include "../render.inc.s"
.include "gameplay.inc.s"

.export lock

.code

lock:
        ldx #lock_state
        stx Player::state

        jmp draw_piece

lock_state:
        jsr to_spawn_delay

        ; calculate piece offset into board
        lda Player::px
        sta $00
        stz $01                         ; w$00 = zero-extended px

        lda Player::py
        rep #$21                        ; 16-bit accumulator, clear carry
        .a16
        and #$00FF                      ; clear top half of accumulator
        asl
        sta $02                         ; py*2
        asl
        asl
        adc $02                         ; py*10 = py*2 + py*8

        adc $00
        sta $02                         ; w$02 = py*10 + px

        lda #0
        sep #$20                        ; 8-bit accumulator
        .a8
        lda Player::piece_state
        asl
        asl                             ; 4 cells
        sta $04                         ; w$04 is index into cell data registers
        stz $05

        lda #4
        sta $00                         ; loop counter

@cell_write_loop:
        ; Calculate board index
        rep #$20                        ; 16-bit accumulator
        .a16
        lda $04
        asl
        tax                             ; word access
        lda piece_cell_offset, X
        clc
        adc $02
        tay                             ; Y = board index
        sep #$20                        ; 8-bit accumulator
        .a8

        ; Calculate board cell value
        lda Player::piece_state
        and #<~3                        ; piece_state >> 2 is piece id
        asl
        asl                             ; piece id << 4 sets the correct color bits
        adc #$10
        ldx $04
        ora piece_cell_dir, X           ; bitwise or with directions produces board bits
        sta (Player::board), Y          ; store board value

        inc $04
        dec $00
        bne @cell_write_loop

        jmp redraw_board
