.include "snes.inc.s"

.export vblank_state, main_state, blank_screen, show_screen

.segment "HEADER"

; Bookkeeping
.byte "SNESTRIS             " ; ROM name (21 bytes)
.byte $20                     ; Mapping mode (LoROM, no fastrom)
.byte $00                     ; Cart type (ROM only)
.byte 6                       ; ROM size (2^6 KB = 64 KB)
.byte 0                       ; RAM size (no RAM)
.byte $01                     ; Region (NTSC)
.byte 0                       ; Developer ID
.byte 0                       ; Version
.word $AAAA                   ; Checksum (dummy)
.word $5555                   ; Checksum compliment

; Native mode interrupt vectors
.word 0, 0            ; nothing
.word 0               ; COP (unused)
.word 0               ; BRK (unused)
.word 0               ; nothing
.word NMI             ; NMI (start of v-blank)
.word 0               ; nothing
.word 0               ; IRQ (unused)

; Emulation mode interrupt vectors
; We won't be in emulation mode, so these are all unused
.word 0, 0, 0, 0, 0, 0
.word reset           ; reset (SNES starts in emulation mode)
.word 0

.bss

main_state:             .addr 0
vblank_state:           .addr 0

.code

reset:
        clc
        xce                     ; switch to native mode
        sep #$20                ; 8-bit accumulator
        rep #$10                ; 16-bit index

        ; Reset PPU to known state
        lda #$80
        sta INIDISP             ; force-blank & turn off screen
        lda #$01
        sta BGMODE              ; Mode 1, 8x8 tiles
        stz MOSAIC              ; Disable mosaic filter
        stz BG12NBA             ; Background 1&2 character address $0000
        stz OBJSEL              ; 8x8 and 16x16 sprites, character address $0000
        lda #$80
        sta VMAIN               ; Increment by 1 on word write to VMDATA, no address remapping
        stz W12SEL              ; Disable window masks for backgrounds+obj
        stz W34SEL
        stz WOBJSEL
        stz TM                  ; Disable background/obj display
        stz TS
        stz TMW                 ; Disable window masks for main screen
        stz TSW                 ; Disable window masks for sub screen
        stz CGADSUB             ; Disable color math
        stz SETINI              ; No special video stuff

        ; Copy palette from ROM to RAM
        lda #$01
        xba
        lda #$FF
        ldx #.loword(rom_palette)
        ldy #palette
        mvn #^rom_palette, #0

        ; Load 4bpp tileset using DMA
        stz VMADDL
        stz VMADDH              ; tileset will be written to VRAM address $0000
        lda #1
        sta DMAP                ; to PPU (2 registers write once)
        lda #<VMDATAL
        sta BBAD                ; to VMDATA register
        ldx #.loword(tileset_4)
        stx A1TL
        lda #^tileset_4
        sta A1TB                ; from tileset_4
        ldx #tileset_4_len
        stx DASL                ; transfer however many bytes tileset_4 is
        lda #1
        sta MDMAEN              ; initiate DMA transfer

        ; Module initialization routines
        jsr init_frame
        jsr init_player_graphics_fields

        ; set initial state
        jsr to_versus

        ; Enable NMI and auto joypad read
        lda #$81
        sta NMITIMEN

        ; Wait for NMI and loop
:       wai
        bra :-

NMI:
        ; Disable NMI so we don't get interrupted if we lag
        lda #$01
        sta NMITIMEN

        ; Force blanking while we work with PPU.
        ; This way we won't hit UB if we aren't done by the time v-blank ends.
        lda #$80
        sta INIDISP

        ; Clear NMI flag
        lda RDNMI

        ; PPU data transfers
        jsr render

        ; wait for auto-joypad read (i don't think we end up having to wait in practice)
        lda #1
:       bit HVBJOY
        bne :-

        ; jump to state-specific v-blank code
        ldx #0
        jsr (vblank_state, X)

        ; prep for next frame
        jsr init_frame

        ; jump to state code
        ldx #0
        jsr (main_state, X)

        ; Enable NMI and auto joypad read
        lda #$81
        sta NMITIMEN
        rti


show_screen:
        lda #$0F
        sta INIDISP                     ; show screen
blank_screen:
        rts
