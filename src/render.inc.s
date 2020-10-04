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
