.export rom_palette, tileset_4, tileset_4_len, empty_board, empty_board_len

.segment "BANK1"

rom_palette:            .incbin "../out/palette.bin"
tileset_4:              .incbin "../out/tileset.4.bin"
tileset_4_len =         * - tileset_4
empty_board:            .incbin "../res/empty_board.bin"
empty_board_len =       * - empty_board
