.include "snes.inc.s"
.include "structs.inc.s"

.export init_frame, render, vram_update_ptr, oam_ptr
.export bg1_scrollx, bg1_scrolly, bg2_scrollx, bg2_scrolly, bg3_scrollx, bg3_scrolly

.bss

vram_update_ptr:        .word 0
vram_update_buf:        .res $1000

oam_ptr:                .word 0
oam_buf:                .res $200

bg1_scrollx:            .byte 0
bg1_scrolly:            .byte 0
bg2_scrollx:            .byte 0
bg2_scrolly:            .byte 0
bg3_scrollx:            .byte 0
bg3_scrolly:            .byte 0

.code

init_frame:
        ; reset pointers
        ldx #vram_update_buf
        stx vram_update_ptr
        ldx #oam_buf
        stx oam_ptr

        ; clear all sprites
        lda #$F0
        ldx #$200
:       dex
        sta oam_buf, X
        bpl :-

        rts

render:
        ; DMA sprites to OAM
        stz OAMADDL
        stz OAMADDH
        stz DMAP                        ; 1 register write once, increment 1 byte
        lda #<OAMDATA
        sta BBAD                        ; to OAM data register
        ldx #oam_buf
        stx A1TL
        stz A1TB                        ; from oam_buf
        ldx #$200
        stx DASL                        ; 512 bytes
        lda #1
        sta MDMAEN                      ; initiate DMA

        ; Init for DMA'ing updates to VRAM
        lda #$1
        sta DMAP                        ; 2 registers write once, increment 1 byte
        lda #<VMDATAL
        sta BBAD                        ; To VRAM data register
        stz A1TB                        ; Bank byte of transfer is always 0

        ; Init for loop
        ldx #vram_update_buf

@vram_dma_loop:
        cpx vram_update_ptr
        beq @vram_dma_done

        ; DMA arguments
        lda VramUpdate::vmain, X
        sta VMAIN
        ldy VramUpdate::target, X
        sty VMADDL
        ldy VramUpdate::count, X
        sty DASL
        ; advance X past arguments
        .repeat .sizeof(VramUpdate)
                inx
        .endrepeat
        ; now X points to the data to DMA
        stx A1TL

        lda #1
        sta MDMAEN                      ; initiate DMA

        ldx A1TL                        ; read back the location DMA finished. this will point to
                                        ; the next entry, and is easier than doing an addition.

        jmp @vram_dma_loop
@vram_dma_done:

        ; transfer scroll registers, with a loop because im lazy
        ldx #5
:       lda bg1_scrollx, X
        sta BG1HOFS, X
        stz BG1HOFS, X                  ; high byte of scroll is always 0 for us
        dex
        bpl :-

        rts
