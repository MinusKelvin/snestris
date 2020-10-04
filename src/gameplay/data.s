.include "../snes.inc.s"

.export mul_10, piece_cell_x, piece_cell_y, piece_cell_dir, piece_cell_offset

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