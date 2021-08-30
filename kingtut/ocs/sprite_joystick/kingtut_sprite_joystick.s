
; planar graphics experiments
; old kingtut on planar screen
; draw a sprite (*)
; move it around with joystick in port 1
; (*) some reminiscences might come up with the evil bird from Pharaohs curse ;)

	SECTION	main,CODE

	bsr     StopMultiTask	
	bsr     OpenGfxLib
	bsr     SaveOldCop	; gfxbase must be in a6
	bsr     SetColors
	bsr     MakeNewCop	; complete copper list (including picture)

	bsr	InitializeSprite

	bsr     WaitMouseLeft	
	bsr     RestoreOldCop
	bsr     StartMultiTask
	bsr     CloseGfxLib
	rts			; end of program

; ***********************************************************************
; WriteNewSpritePosition
; d0 = x
; d1 = y
; d2 = height
; a0 = ptr sprite data

WriteNewSpritePosition:
	move.l  d0,d4		; d4 = x
	move.l  d1,d5		; d5 = y

	; *** write vstart
	; low 8 bits
	move.b  d5,(a0)

	; clear all high bits first
	move.b #0,3(a0)
	
	; high bit
	lsr.l	#6,d5
	and.w   #%100,d5
	or.b    d5,3(a0)

	; *** write hstart
	move.l 	d4,d6
	and.l   #1,d6
	or.b    d6,3(a0)

	lsr.l 	#1,d4
	move.b  d4,1(a0)

	; *** write vstop
	add.l  	d1,d2
	move.b  d2,2(a0)

	; high bit
	lsr.l   #7,d2
	and.l   #%10,d2
	or.b    d2,3(a0)
	
	rts
	
; ***********************************************************************

MoveSprite:
	; read vertical position
	clr.l   d0
	clr.l   d1
	
	;move.w  $DFF004,d0	; most significant bits (VPOSR)
	move.w  $DFF006,d1	; vert and horiz position (VHPOSR)
	
	lsr.l   #8,d1
	cmp.b   #5,d1

	; move sprite
	; calculate actual x and y
	move.w  $dff00c,d2	; read joydat1
	cmp.w   #$300,d2
	beq     left
	cmp.w   #$3,d2
	beq     right
	cmp.w   #$100,d2
	beq     up
	cmp.w   #$1,d2
	beq     down
	cmp.w   #$103,d2
	beq     upright
	cmp.w   #$2,d2
	beq     downright
	cmp.w   #$301,d2
	beq     downleft
	cmp.w   #$200,d2
	beq     upleft
	bra	contmove

left:
	sub.w   #1,spr0posx
	bra	contmove
right:
	add.w   #1,spr0posx
	bra	contmove
up:
	sub.w   #1,spr0posy
	bra	contmove
down:
	add.w   #1,spr0posy
	bra	contmove
upright:
	sub.w   #1,spr0posy
	add.w   #1,spr0posx
	bra	contmove
downright:
	add.w   #1,spr0posy
	add.w   #1,spr0posx
	bra	contmove
downleft:
	add.w   #1,spr0posy
	sub.w   #1,spr0posx
	bra	contmove
upleft:
	sub.w   #1,spr0posy
	sub.w   #1,spr0posx
	bra	contmove

contmove:	
	clr.l   d0
	clr.l   d1
	move.w  spr0posx,d0
	move.w	spr0posy,d1
	move.l  #11,d2
	lea     sprite0,a0

	bsr	WriteNewSpritePosition
	
	;move.w  d0,spr0ctrlwrd1
	;move.w  d1,spr0ctrlwrd2	
	
	; wait
	move.l  #1000,d0
.wloop1:
	move.l  #1000,d1
.wloop2:
	dbra    d1,.wloop2
	dbra    d0,.wloop1	
dontmove:

	rts

; ***********************************************************************

InitializeSprite:
	lea     spritelist,a0	; same as newcop
	move.l  #sprite0,d0	; address sprite0
	move.w  d0,6(a0)	; SPR0PTH (high bits sprite0 ptr)
	swap    d0
	move.w  d0,2(a0)	; SPR0PTL (low bits sprite0 ptr)

	; set control words
	; control word 1
	; write coordinates (=> other bits in control word 2)
	move.w  #150,spr0posy
	move.b  #150,spr0vstrtl	; VSTART (low 8 bits)

	move.w  #160,spr0posx
	move.b  #80,spr0hstrth	; HSTART (high 8 bits)

	; write same values to custom registers (possible to set this in 2 ways?)
	move.w  spr0hstrth,$dff140	; SPR0POS
	
	; control word 2
	; write vstop (all other bits = 0)
	move.b  #161,spr0vstpl	; VSTOPL (low 8 bits)

	; again: write to custom registers
	move.w  spr0vstpl,$dff142	; SPR0CTL
	
	rts
	
; ***********************************************************************

SetColors:

	lea  	cmap,a3		; a3 = cmap (= col palette from PPaint)
	lea 	copcols0,a4	; a4 = copperlist 
	
	move.l  #48,d4		; offset 48 = 1st rgb entry in cmap
	add.l   d4,a3
	addq.w  #2,a4		; offset 2 = 1st rgb entry in copperlist
	
	move.l  #31,d4          ; d4 = 32 colors
cloop:	
	move.l  #0,d5
	move.l  #0,d6
	move.l  #0,d7
	
	move.b  (a3)+,d5	; red
	move.b  (a3)+,d6	; green
	move.b  (a3)+,d7        ; blue

	lsl.l   #4,d5
	lsr.l   #4,d7		; d7 = blue>>4
	add.l   d6,d5		; d5 = 00000rg0
	add.l   d7,d5		; d5 = 00000rgb

	move.w  d5,(a4)+	; write color to copperlist
	addq.l  #2,a4		; a4 = next entry in copperlist
	
	dbra    d4,cloop

	rts

; ***********************************************************************

StopMultiTask:
	move.l	4.w,a6		; execbase in a6
	jsr	-$78(a6)	; stop multitasking
	rts

; **********************************************************************
	
OpenGfxLib:
	move.l	4.w,a6		; execbase in a6
	lea	gfxname,a1	; name (string) of graphics library in a1
	jsr	-$198(a6)	; OpenLibrary
	move.l	d0,gfxbase	; save address in GfxBase
	rts
gfxname:
	dc.b	"graphics.library",0,0

gfxbase:
	dc.l    0

; **********************************************************************

SaveOldCop:
	move.l  gfxbase,a6	; make sure gfxbase is in a6
	move.l	$26(a6),oldcop	; save old copperlist
	rts
oldcop:	
	dc.l	0	; address of old copper list

; **********************************************************************

; prepare new copperlist => make it point to our bitplanes
; data for copperlist must be in chip ram (see section at end)

MakeNewCop:
	move.l	#picture,d0	; address of picture (= bpl0) in d0
	lea	bplptrs,a1	; bitplane pointers (in copperlist) => a1
	moveq	#4,d1		; number of bitplanes -1

prpnewcop:
	move.w	d0,6(a1)	; copy lower word of bpl0 to copperlist
	swap	d0		; swap words inside d0 ($1234 > $3412)
	move.w	d0,2(a1)	; copy higher word of bpl0 to copperlist
	swap	d0		; reswap words in d0
	add.l	#40*256,d0	; add 10240 (= offset to next bitplane) to d0
	addq.w	#8,a1		; make a1 point to next entry in copperlist (bpl1)
	dbra	d1,prpnewcop	; loop until copperlist for all bpl is complete

; activate our copperlist

	move.l	#newcop,$dff080	; write address of newcop to $dff080
	move.w	d0,$dff088	; activate newcop (write anything to $dff088)

	move.w	#0,$dff1fc	; FMODE - disable AGA
	move.w	#$c00,$dff106	; BPLCON3 - disable AGA
	rts
	
; ***************************************************************************

WaitMouseLeft:
mouse:
	bsr	MoveSprite
	btst	#6,$bfe001	; left mouse button pressed?
	bne.s	mouse
	rts

; **************************************************************************

RestoreOldCop:
	move.l	oldcop,$dff080	; restablish oldcop
	move.w	d0,$dff088	; activate it
	rts

; *************************************************************************

StartMultiTask:
	move.l	4.w,a6
	jsr	-$7e(a6)	; restart multitasking
	rts

; *************************************************************************

CloseGfxLib:
	move.l  4.w,a6
	move.l	gfxbase,a1	; base address graphics library
	jsr	-$19e(a6)	; Closelibrary
	rts			; end of program

; **************************************************************************

; data


	SECTION	graphics,DATA_C     ; graphics data in chip ram

newcop:
spritelist:
	; disactivate ($0000) all sprites so that they won't disturb
	; possibilty to reactivate sprite(s) by poking directly into spritelist
	
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000,$128,$0000
	dc.w	$12a,$0000,$12c,$0000,$12e,$0000,$130,$0000,$132,$0000
	dc.w	$134,$0000,$136,$0000,$138,$0000,$13a,$0000,$13c,$0000
	dc.w	$13e,$0000

	; default values for following registers
	
	dc.w	$8e,$2c81	; DiwStrt 
	dc.w	$90,$2cc1	; DiwStop
	dc.w	$92,$0038	; DdfStart
	dc.w	$94,$00d0	; DdfStop
	dc.w	$102,0		; BplCon1
	dc.w	$104,0		; BplCon2
	dc.w	$108,0		; Bpl1Mod
	dc.w	$10a,0		; Bpl2Mod

; BPLCON0 ($dff100) value for screen with 5 bpl and 32 colors

	dc.w	$100,%0101001000000000	; bits 14-12 = number of bitplanes = 5
	dc.w    $104,%0000000001100000 ; sprites priority over pf1	
bplptrs:
	dc.w $e0,$0000,$e2,$0000	; BPL0PT
	dc.w $e4,$0000,$e6,$0000	; BPL1PT
	dc.w $e8,$0000,$ea,$0000	; BPL2PT
	dc.w $ec,$0000,$ee,$0000	; BPL3PT
	dc.w $f0,$0000,$f2,$0000	; BPL4PT
	dc.w $f4,$0000,$f6,$0000	; BPL5PT
	
copcols0:
	dc.w	$0180,0		; color0
	dc.w	$0182,0		; color1
	dc.w	$0184,0		; color2
	dc.w	$0186,0		; color3
copcols4:
	dc.w	$0188,0		; color4
	dc.w	$018a,0		; color5
	dc.w	$018c,0		; color6
	dc.w	$018e,0		; color7
copcols8:
	dc.w	$0190,0		; color8
	dc.w	$0192,0		; color9
	dc.w	$0194,0		; color10
	dc.w	$0196,0		; color11
copcols12:
	dc.w	$0198,0		; color12
	dc.w	$019a,0		; color13
	dc.w	$019c,0		; color14
	dc.w	$019e,0		; color15
copcols16:
	dc.w	$01a0,0		; color16
	dc.w	$01a2,0		; color17
	dc.w	$01a4,0		; color18
	dc.w	$01a6,0		; color19
copcols20:
	dc.w	$01a8,0		; color20
	dc.w	$01aa,0		; color21
	dc.w	$01ac,0		; color22
	dc.w	$01ae,0		; color23
copcols24:
	dc.w	$01b0,0		; color24
	dc.w	$01b2,0		; color25
	dc.w	$01b4,0		; color26
	dc.w	$01b6,0		; color27
copcols28:
	dc.w	$01b8,0		; color28
	dc.w	$01ba,0		; color29
	dc.w	$01bc,0		; color30
	dc.w	$01be,0		; color31
colors:
	dc.w	$FFFF,$FFFE	; end of copperlist

sprite0:
spr0ctrlwrd1:
spr0vstrtl:	
	dc.b    $0					; control word1: VSTART:HSTART
spr0hstrth:
	dc.b    $0
spr0ctrlwrd2:
spr0vstpl:
	dc.b	$0
spr0ctrlwrd2ii:
	dc.b	$0					; control word2: VSTOP:BIT7:BITS3..6(0):BIT2(+VSTART):BIT1(+VSTOP):BITO(+HSTART)
spr0dta:
	dc.w    %0000001110000000, %0000001110000000	; line1: high/low order words
	dc.w    %0000001110000000, %0000001110000000	; color: 11
	dc.w    %0000111111100000, %0000111111100000
	dc.w    %0000111111100000, %0000111111100000
	dc.w    %0011111111111000, %0011111111111000
	dc.w    %0011111111111000, %0011111111111000
	dc.w    %1111111111111110, %1111111111111110
	dc.w    %0000111111100000, %0000000000000000	; color: 10
	dc.w	%0000001110000000, %0000001110000000	; color: 11
	dc.w    %0000000000000000, %0000110001100000	; color: 01
	dc.w    %0000000000000000, %0000110001100000
	dc.w    $00,$00					; 2 end words (all 0 = last vertical use of sprite in this frame)

spr0posx: 	dc.w	80
spr0posy:	dc.w  	150
spr0dx:		dc.b    1
spr0dy:     	dc.b    1

cmap:   incbin  "kingtut.col"   ; ilbm cmap (rgb-color = 3 bytes, one each value)

picture:

	incbin	"Ah_kingtut.tft2.raw"	; raw picture = bpl values (without colors)

	end

