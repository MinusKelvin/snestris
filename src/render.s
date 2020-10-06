.include "snes.inc.s"
.include "render.inc.s"

.export init_frame, render, vram_update_idx, vram_update_buf, oam_idx, oam_buf, palette
.export bg1_scrollx, bg1_scrolly, bg2_scrollx, bg2_scrolly, bg3_scrollx, bg3_scrolly

.bss

vram_update_idx:        .word 0
vram_update_buf:        .res $800

oam_idx:                .word 0
oam_buf:                .res $200

bg1_scrollx:            .byte 0
bg1_scrolly:            .byte 0
bg2_scrollx:            .byte 0
bg2_scrolly:            .byte 0
bg3_scrollx:            .byte 0
bg3_scrolly:            .byte 0

palette:                .res $200

.code

init_frame:
        ; reset pointers
        stz vram_update_idx
        stz vram_update_idx+1
        stz oam_idx
        stz oam_idx+1

        ; clear all sprites
        lda #$F0
        ldx #$200
:       dex
        sta oam_buf, X
        bne :-

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

        ; DMA palette to VRAM
        ; reuse DMAP, A1TB from previous DMA operation
        stz CGADD
        lda #<CGDATA
        sta BBAD                        ; to color graphics data register
        ldx #palette
        stx A1TL                        ; from palette
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

        ; Calculate pointer to end of buffer
        ; It is preferable for this routine to have the pointer in X instead of an index in X and
        ; using absolute,X addressing mode since we need to add a 16-bit number to X. This would
        ; require a bunch of stuff with the accumulator; instead we'll let DMA incrementing the
        ; source address register do the addition for us. Additionally, we get to use direct,X
        ; addressing (assuming that the direct page is $0000 - which should always be true here).
        rep #$21                        ; 16-bit accumulator, clear the carry
        .a16
        lda #vram_update_buf
        adc vram_update_idx
        sta $00
        sep #$20
        .a8

        ; Init for loop
        ldx #vram_update_buf

@vram_dma_loop:
        cpx $00
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

        lda SLHV
        lda STAT78
        lda OPVCT
        xba
        lda OPVCT
        rep #$20
        .a16
        and #$1FF
        cmp #224
        bpl :+
        ; overspent vblank time. Debugger will let us break on wdm instruction
        wdm 0
:       sep #$20
        .a8

        ; transfer scroll registers, with a loop because im lazy
        ldx #5
:       lda bg1_scrollx, X
        sta BG1HOFS, X
        stz BG1HOFS, X                  ; high byte of scroll is always 0 for us
        dex
        bpl :-

        rts
