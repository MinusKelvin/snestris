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
