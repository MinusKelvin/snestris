.include "../snes.inc.s"

.export piece_cell_x, piece_cell_y, piece_cell_dir, piece_cell_offset

.rodata

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

.macro piece_spec p0, p1, p2, p3, p4, p5, p6
piece_cell_x:
        cell_xs p0
        cell_xs p1
        cell_xs p2
        cell_xs p3
        cell_xs p4
        cell_xs p5
        cell_xs p6
piece_cell_y:
        cell_ys p0
        cell_ys p1
        cell_ys p2
        cell_ys p3
        cell_ys p4
        cell_ys p5
        cell_ys p6
piece_cell_dir:
        cell_dirs p0
        cell_dirs p1
        cell_dirs p2
        cell_dirs p3
        cell_dirs p4
        cell_dirs p5
        cell_dirs p6
piece_cell_offset:
        cell_offsets p0
        cell_offsets p1
        cell_offsets p2
        cell_offsets p3
        cell_offsets p4
        cell_offsets p5
        cell_offsets p6
.endmacro

.linecont +
piece_spec \
        {$B, -1, 1,        $5,  0, 1,        $A,  0, 0,        $7,  1, 0}, \
        {$7,  1, 1,        $9,  0, 1,        $6,  0, 0,        $B, -1, 0}, \
        {$D, -1, 1,        $A, -1, 0,        $3,  0, 0,        $7,  1, 0}, \
        {$D,  1, 1,        $B, -1, 0,        $3,  0, 0,        $6,  1, 0}, \
        {$9,  0, 1,        $5,  1, 1,        $6,  1, 0,        $A,  0, 0}, \
        {$B, -1, 0,        $3,  0, 0,        $3,  1, 0,        $7,  2, 0}, \
        {$D,  0, 1,        $B, -1, 0,        $2,  0, 0,        $7,  1, 0}
