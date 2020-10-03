
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
.endstruct

.struct VramUpdate
        vmain           .byte
        target          .addr
        count           .word
.endstruct

.struct Sprite
        xcoord          .byte
        ycoord          .byte
        chr             .byte
        flags           .byte
.endstruct
