Simple program to show the legendary Kingtut image on a lowres screen

Picture resolution: 320x256 (lowres PAL), 32 colors

Any picture can be included using the program PPAINT:
1) Export picture as RAW file
2) Export palette as CMAP file (extension: *.col)

The RAW file contains the bitmap info (5 bitplanes)
The CMAP file contains rgb values starting at offset 48 (1 byte per value, 32 * 3 bytes = 96 bytes in total).

On OCS only the four higher bits (upper nibble) of the color value is used.


