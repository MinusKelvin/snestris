collision_index_cache = $40

.struct Player
        temps           .res $80
        ; stuff the gamemode has to initialize
        board           .addr
        vram            .addr
        scroll_x_ptr    .addr
        scroll_y_ptr    .addr
        scroll_x_offset .byte
        ; stuff init_player initializes
        state           .addr
        timer           .byte
        piece_state     .byte
        px              .byte
        py              .byte
        curr_inputs     .byte
        prev_inputs     .byte
        used_inputs     .byte
        das_left        .byte
        das_right       .byte
.endstruct

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

.enum Input
        right = %00000001
        left  = %00000010
        sdrop = %00000100
        hdrop = %00001000
        hold  = %00010000
        cw    = %00100000
        ccw   = %01000000
.endenum
