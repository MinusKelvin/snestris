#!/usr/bin/python3

from sys import argv
from os.path import splitext
import imageio

if len(argv) != 3:
    print(f"Usage: {argv[0]} <outfile> <infile>")
    exit()

inimg = imageio.imread(argv[2])

bpp_part = splitext(splitext(argv[2])[0])[1]
if bpp_part == "":
    # palette
    assert len(inimg) == 16
    assert len(inimg[0]) == 16
    with open(argv[1], "wb") as f:
        for y in range(16):
            for x in range(16):
                # convert from 8-bit color channel to 5-bit color channel
                r = inimg[y][x][0] // 8
                g = inimg[y][x][1] // 8
                b = inimg[y][x][2] // 8
                c = int(r + g * 32 + b * 32 * 32)
                f.write(c.to_bytes(2, "little"))

else:
    # character data
    bpp = int(bpp_part[1:])
    def palette(pixel):
        # transparent color is always color number 0
        if pixel[3] == 0: return 0
        for x in range(bpp*bpp):
            if (inimg[0][x] == pixel).all():
                return x

    def bitplanes(data):
        planes = []
        for b in range(bpp):
            planes.append([])
            for i in range(0, len(data), 8):
                v = 0
                for j in range(8):
                    v = (v << 1) | ((data[i+j] >> b) & 1)
                planes[-1].append(v)
        return planes

    with open(argv[1], "wb") as f:
        for ty in range(len(inimg)//8):
            for tx in range(len(inimg[0])//8):
                character_data = []
                for y in range(8):
                    for x in range(8):
                        character_data.append(palette(inimg[ty*8+y+1][tx*8+x]))
                planes = bitplanes(character_data)
                for i in range(0, bpp, 2):
                    for d in range(8):
                        for j in range(2):
                            f.write(planes[i+j][d].to_bytes(1, "little"))