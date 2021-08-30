
; saga graphics experiments
; old kingtut on saga screen
; resolution: 320x256 pixels
; colors: 256 colors (indexed)
; like ocs example but with saga

	SECTION	main,CODE

start:
	bsr     DoSomeVoodoo		; align SAGA screen buffer address
			
	move.w  #$0301,d0		; 320x256, 8bit (indexed)
	bsr	SetGfxMode
	
	bsr     MakeColorTable

	bsr	ClearScreen
	;bsr     ShowColorTable		; optional code to show color table

	bsr     CopyPic2gfxdata		; comment out to show color table (preceeding call to ShowColorTable)
	
	bsr     WaitMouseLeft	
	bsr	RestoreGfxMode
	rts				; end of program

; ***********************************************************************
; this correction will probably become obsolete with core R7 
; for the moment it is necessary to avoid off-by-1-pixel effects

DoSomeVoodoo:
	move.l  #gfxdata,d0		; these lines replace a simple 
	addi.l  #31,d0			; lea gfxdata,d0
	andi.l  #~31,d0			; goal is to make sure
	move.l  d0,a0			; gfxdata ptr is aligned to 32 bytes
	move.l  d0,aligned_address
	clr.l   d0			; for SAGA

	rts
	
; ***********************************************************************
; with indexed screen mode, color table can be written directly
; to $DFF388

MakeColorTable:
	lea  	cmap,a3		; a3 = cmap (= col palette from PPaint)	
	move.l  #48,d4		; offset 48 = 1st rgb entry in cmap
	add.l   d4,a3
		
	move.l  #31,d4          ; d4 = 32 colors
cloop:	
	move.l  #31,d5
	sub.l   d4,d5		; d5 = color
	lsl.l   #8,d5
	
	move.b  (a3)+,d5	; red
	lsl.l   #8,d5
	move.b  (a3)+,d5	; green
	lsl.l   #8,d5
	move.b  (a3)+,d5        ; blue

	move.l  d5,$DFF388	; write color directly to $DFF388	
	dbra    d4,cloop

	rts

; ***************************************************************************

ShowColorTable:
	move.l 	#31,d0
	;lea     gfxdata,a0		; replace this by vodooized address
	move.l  aligned_address,a0
repeatcolors:
	move.l  #31,d1
	sub.l   d0,d1
	move.l  #5,d3		; 5 lines per color
repeatlines:
	move.l  #319,d2		; counter horizontal pixels
repeatpixels:
	move.b  d1,(a0)+
	
	dbra    d2,repeatpixels
	dbra    d3,repeatlines
	dbra    d0,repeatcolors

	rts
	
; ***************************************************************************

WaitMouseLeft:
mouse:
	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse
	rts

; **************************************************************************

******************************
; CopyPic2gfxdata

CopyPic2gfxdata:
	;lea     gfxdata,a0		; saga screenbuffer (chunky)
	move.l  aligned_address,a0
	lea	picture,a1		; address of picture in d0 (planar)

	move.l  #40*256,d0		; length bitplane

	; prepare one address register for each bitplane
	move.l  a1,a2
	add.l   d0,a2
	move.l  a2,a3
	add.l   d0,a3
	move.l  a3,a4
	add.l   d0,a4
	move.l  a4,a5
	add.l   d0,a5

	sub.l   #1,d0
writecols:
	move.l  #7,d7		; bit-position
maskloop:
	move.l  #0,d6		; color

	move.l  #1,d5		; and-mask
	lsl.b   d7,d5
	move.l  d5,d3		; copy and-mask
	
	and.b   (a1),d5		; bpl5
	lsr.b   d7,d5
	;lsl.b   #0,d5
	add.b   d5,d6

	move.l  d3,d5
	and.b   (a2),d5		; bpl4
	lsr.b   d7,d5
	lsl.b   #1,d5
	add.b   d5,d6

	move.l  d3,d5
	and.b   (a3),d5		; bpl3
	lsr.b   d7,d5
	lsl.b   #2,d5
	add.b   d5,d6

	move.l  d3,d5
	and.b   (a4),d5		; bpl2
	lsr.b   d7,d5
	lsl.b   #3,d5
	add.b   d5,d6

	move.l  d3,d5
	and.b   (a5),d5		; bpl1
	lsr.b   d7,d5
	lsl.b   #4,d5
	add.b   d5,d6

	; now write color number to gfxdata
	move.b  d6,(a0)+	
	
	dbra	d7,maskloop

	add.l   #1,a1
	add.l   #1,a2
	add.l   #1,a3
	add.l   #1,a4
	add.l   #1,a5

	dbra    d0,writecols
	
	rts
	
*******************************
; PutPixel
; d0 = x
; d1 = y
; d2 = color
; a0 = gfxptr

PutPixel:
	movem.l d0-d7/a0-a7,-(sp)
	move.l  #0,d3
	move.w  MAXX,d3
	mulu.l 	d3,d1
	add.l   d1,d0
	asl.l   #2,d0     ; x2 (long word size)
	add.l   d0,a0
	move.l  d2,(a0)
	movem.l (sp)+,d0-d7/a0-a7
	rts

*******************************
; ClearScreen

ClearScreen:
	;move.l  #$00FF0000,$DFF388	; color0 = red
	move.l  #0,d1			; d1 = 0
	move.w  MAXY,d1			; d1.w = MAXY
	sub.l   #1,d1
vloop:
	move.l  #0,d0			; d0 = 0
	move.w  MAXX,d0			; d0.w = MAXX
	sub.l   #1,d0			; counter dbra
hline:
	move.b  #1,(a0)+		; draw black line
	dbra 	d0,hline

	dbra	d1,vloop

	rts
	
*******************************
; SetGfxMode
; d0 = mode
; a0 = gfxptr
 
SetGfxMode:
	move.w	$DFF002,D1		; SAVE DMACON
	or.w	D1,DMACON
	move.w	#$7FFF,$DFF096		; ALL DMA OFF

	move.w	$DFF01C,D1		; SAVE INTENA
	or.w	D1,INTENA
	move.w	#$7FFF,$DFF09A		; ALL INTENA OFF

	move.l	$DFF1EC,CHUNKYPTR	; Save GFXPTR	
	move.w	$DFF1F4,GFXMODE		; Save GFXMode
	clr.w	$DFF1E6			; clear modulo

	move.l	a0,$DFF1EC		; Set GFXPTR
	move.w  d0,$dff1f4

	; set maxx, maxy
	move.b  #0,d0
	ror.w	#8,d0
	sub.l   #1,d0
	asl.w   #2,d0  ; x 4 (2 x word size)
	lea     MODES_MAXXY,a1
	add.l   d0,a1
	move.w  (a1)+,MAXX
	move.w  (a1),MAXY
	
	rts

*******************************
; RestoreGfxMode

RestoreGfxMode:
	move.w	#$7FFF,$DFF096
	move.w	DMACON,$DFF096
	move.w	INTENA,$DFF09A
	move.l	CHUNKYPTR,$DFF1EC
	move.w	GFXMODE,$DFF1F4

	rts

*******************************

GFXMODE:	dc.w $0000		; save old gfxmode
CHUNKYPTR: 	dc.l 0			; save old gfxptr
MAXX:      	dc.w 0
MAXY:		dc.w 0
BITSHIFT:	dc.w 0

*******************************

DMACON:		dc.w $8000
INTENA:		dc.w $8000
MODES_MAXXY:	dc.w 320,200	; $01
		dc.w 320,240 	; $02
		dc.w 320,256	; $03
		dc.w 640,400	; $04
		dc.w 640,480	; $05
		dc.w 640,512	; $06
		dc.w 960,540	; $07
		dc.w 480,270	; $08
		dc.w 304,224	; $09
		dc.w 1280,720	; $0A
		dc.w 640,360	; $0B
		dc.w 800,600	; $0C
		dc.w 1024,768	; $0D
		dc.w 720,576	; $0E
		dc.w 848,480	; $0F
		dc.w 640,200	; $10

ColorTable	ds.l 32		; reserve 32 colors
	
	SECTION	graphics,BSS_F			

cmap:   
	incbin  "kingtut.col"   ; ilbm cmap (rgb-color = 3 bytes, one each value)
picture:
	incbin	"Ah_kingtut.tft2.raw"	; raw picture = bpl values (without colors)
aligned_address:
	ds.l 	1
gfxdata:
	ds.b	(320*256*4)+32		; adapted from Flype (again: be sure data is on longword for SAGA)
extrabuffer: 
	ds.l    32			; additional screen buffer (avoid buffer overflow due to alignment correction)

	END
	
