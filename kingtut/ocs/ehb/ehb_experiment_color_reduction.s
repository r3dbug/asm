
; extra half-brite experiments
; the idea was to reduce the original colors of kingtut palette
; using the 6th plane for extra half bright and then use the freed
; colors for sprite in ocs
; in the end it turned out that about 5 colors can be freed this way
; (keeping 100% accurate colors compared to original palette)

	SECTION	main,CODE

	bsr     StopMultiTask	
	bsr     OpenGfxLib
	bsr     SaveOldCop	; gfxbase must be in a6
	;bsr     SetColors
	bsr	SetEHBColors
	bsr     MakeNewCop	; complete copper list 
	;bsr	ShowEHBColors
	bsr	ShowOrigPalWithEHBColors

	;bsr     CopyKingTutToEHB
	
	bsr     WaitMouseLeft	
	bsr     RestoreOldCop
	bsr     StartMultiTask
	bsr     CloseGfxLib
	rts			; end of program

; ***********************************************************************

CopyKingTutToEHB:

	rts
	
; ***********************************************************************

SetEHBColors:

	lea     newcolors,a5	; a5 = new ehb colors
	lea 	copcols0,a4	; a4 = copperlist 
	addq.l	#2,a4
	
	move.l  #31,d4          ; 32 colors
cloop:	
	move.w  (a5)+,(a4)+	
	addq.l  #2,a4		; a4 = next entry in copperlist
	
	dbra    d4,cloop

	rts
	
; ***********************************************************************

ShowOrigPalWithEHBColors:

	; a0-a5 = bplptrs
	lea	screen,a0
	move.l  #80*256,d0
	move.l	a0,a1
	add.l   d0,a1
	move.l  a1,a2
	add.l   d0,a2
	move.l  a2,a3
	add.l   d0,a3
	move.l  a3,a4
	add.l   d0,a4
	move.l  a4,a5
	add.l   d0,a5	

	; write colors
	move.l	#31,d0		; colors
.nc:
	move.l  #7,d1		; lines
.nl:
	move.l  #79,d2		; pixels
.np:
	; calculate color
	; 1st byte
	move.l  d0,d5
	add.l   #1,d5
	move.l  #32,d3
	sub.l   d5,d3		; d3 = color value

	move.b  d3,tempc	; backup original color
	
	; replace color if necessary
	; replace original color with ehb
	lea	ehb_replace,a6
	move.l	#erepe,d7
	sub.l   a6,d7
	lsr.l   #1,d7
	move.l  #0,d6
.ehbrep:
	move.w  (a6)+,d6	; read ehb rep table value
	lsl.l   #8,d6
	swap    d6
	cmp.b   d6,d3
	bne     .nochange1
	swap	d6
	lsr.l   #8,d6
	move.b	d6,d3
	add.l   #32,d3		; +32 = ehb color
	;move.l  #31,d3		; red = replace with ehb color
	bra 	.nobaserep	; ehb applied? => dont remap base colors
.nochange1:
	dbra    d7,.ehbrep	

	; bra .nobaserep		; for debugging (no base color replacement)

	; replace original color with remapped base color
	lea	orig_replace,a6
	move.l	#orepe,d7
	sub.l   a6,d7
	lsr.l   #1,d7
	move.l  #0,d6
.orep:
	move.w  (a6)+,d6	; read orig rep table value
	lsl.l   #8,d6
	swap    d6
	cmp.b   d6,d3
	bne	.nochange2
	swap	d6
	lsr.l   #8,d6
	move.b	d6,d3		; replace orig color with remapped
	;move.l  #30,d3		; green = base color replace
.nochange2:
	dbra    d7,.orep
.nobaserep:			; for debugging

	; prepare bytes
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000001,d4
	cmp.l   #%000001,d4
	bne	.0
	move.l  #$ff,d5
.0:
	move.b  d5,(a0)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000010,d4
	cmp.l   #%000010,d4
	bne	.1
	move.l  #$ff,d5
.1:
	move.b  d5,(a1)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000100,d4
	cmp.l   #%000100,d4
	bne	.2
	move.l  #$ff,d5
.2:
	move.b  d5,(a2)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%001000,d4
	cmp.l   #%001000,d4
	bne	.3
	move.l  #$ff,d5
.3:
	move.b  d5,(a3)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%010000,d4
	cmp.l   #%010000,d4
	bne	.4
	move.l  #$ff,d5
.4:
	move.b  d5,(a4)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%100000,d4
	cmp.l   #%100000,d4
	bne	.5
	move.l  #$ff,d5
.5:
	move.b  d5,(a5)+

	dbra    d2,.np
	dbra    d1,.nl
	dbra    d0,.nc
	
	rts
	
; ***********************************************************************

ShowEHBColors:

	; a0-a5 = bplptrs
	lea	screen,a0
	move.l  #80*256,d0
	move.l	a0,a1
	add.l   d0,a1
	move.l  a1,a2
	add.l   d0,a2
	move.l  a2,a3
	add.l   d0,a3
	move.l  a3,a4
	add.l   d0,a4
	move.l  a4,a5
	add.l   d0,a5	

	; write colors
	move.l	#63,d0		; colors
.nc:
	move.l  #3,d1		; lines
.nl:
	move.l  #79,d2		; pixels
.np:
	; calculate color
	; 1st byte
	move.l  d0,d5
	add.l   #1,d5
	move.l  #64,d3
	sub.l   d5,d3

	; prepare bytes
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000001,d4
	cmp.l   #%000001,d4
	bne	.0
	move.l  #$ff,d5
.0:
	move.b  d5,(a0)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000010,d4
	cmp.l   #%000010,d4
	bne	.1
	move.l  #$ff,d5
.1:
	move.b  d5,(a1)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%000100,d4
	cmp.l   #%000100,d4
	bne	.2
	move.l  #$ff,d5
.2:
	move.b  d5,(a2)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%001000,d4
	cmp.l   #%001000,d4
	bne	.3
	move.l  #$ff,d5
.3:
	move.b  d5,(a3)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%010000,d4
	cmp.l   #%010000,d4
	bne	.4
	move.l  #$ff,d5
.4:
	move.b  d5,(a4)+
	move.l  #0,d5
	move.l  d3,d4
	and.l   #%100000,d4
	cmp.l   #%100000,d4
	bne	.5
	move.l  #$ff,d5
.5:
	move.b  d5,(a5)+

	dbra    d2,.np
	dbra    d1,.nl
	dbra    d0,.nc
	
	rts
	
; ***********************************************************************

SetColors:

	lea  	cmap,a3		; a3 = cmap (= col palette from PPaint)
	lea 	copcols0,a4	; a4 = copperlist 
	
	move.l  #48,d4		; offset 48 = 1st rgb entry in cmap
	add.l   d4,a3
	addq.w  #2,a4		; offset 2 = 1st rgb entry in copperlist
	
	move.l  #31,d4          ; d4 = 32 colors
.cloop:	
	move.l  #0,d5
	move.l  #0,d6
	move.l  #0,d7
	
	move.b  (a3)+,d5	; red
	move.b  (a3)+,d6	; green
	move.b  (a3)+,d7        ; blue

	lsl.l   #4,d5		; d5 = red<<4
	lsr.l   #4,d7		; d7 = blue>>4
	add.l   d6,d5		; d5 = 00000rg0
	add.l   d7,d5		; d5 = 00000rgb

	move.w  d5,(a4)+	; write color to copperlist
	addq.l  #2,a4		; a4 = next entry in copperlist
	
	dbra    d4,.cloop

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
	dc.w    0

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
	move.l	#screen,d0	; address of picture (= bpl0) in d0
	lea	bplptrs,a1	; bitplane pointers (in copperlist) => a1
	moveq	#5,d1		; number of bitplanes -1

prpnewcop:
	move.w	d0,6(a1)	; copy lower word of bpl0 to copperlist
	swap	d0		; swap words inside d0 ($1234 > $3412)
	move.w	d0,2(a1)	; copy higher word of bpl0 to copperlist
	swap	d0		; reswap words in d0
	add.l	#80*256,d0	; add 2x10240 (= offset to next bitplane) to d0
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

	; disactivate ($0000) all sprites so that they won't disturb
	
	dc.w	$120,$0000,$122,$0000,$124,$0000,$126,$0000
	dc.w	$128,$0000,$12a,$0000,$12c,$0000,$12e,$0000
	dc.w	$130,$0000,$132,$0000,$134,$0000,$136,$0000
	dc.w 	$138,$0000,$13a,$0000,$13c,$0000,$13e,$0000

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

	dc.w	$100,%1110000100000000	; 1=HiRes / 14-12=6 bitplanes
	dc.w	$102,%0000000000000000	; no playfield priority
	dc.w	$104,%0000000000000000	; no playfield priority
	
bplptrs:
	dc.w $e0,$0000,$e2,$0000	; BPL0PT
	dc.w $e4,$0000,$e6,$0000	; BPL1PT
	dc.w $e8,$0000,$ea,$0000	; BPL2PT
	dc.w $ec,$0000,$ee,$0000	; BPL3PT
	dc.w $f0,$0000,$f2,$0000	; BPL4PT
	dc.w $f4,$0000,$f6,$0000	; BPL5PT
	dc.w $f8,$0000,$fa,$0000	; BPL6PT

copcols0:
	dc.w	$0180,$000	; color0
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

newcolors:
c0:	dc.w	$0000		; =
c1:	dc.w	$0558		; =
c2:	dc.w	$0ec5		; <= 29 (ehb 7)
c3:	dc.w	$0011		; =
c4:	dc.w	$0dc3		; <= 28 (ehb 11)
c5:	dc.w	$0023		; =
c6:	dc.w	$0233		; =
c7:	dc.w	$0003		; = (ehb for 2)
c8:	dc.w	$0a71		; <= 27
c9:	dc.w	$0226		; = (ehb for 8)
c10:	dc.w	$0337		; =
c11:	dc.w	$0035		; = (ehb for 4)
c12:	dc.w	$0256		; = 
c13:	dc.w	$0110		; = (ehb for 0, 31)
c14:	dc.w	$0862		; <= 26 (ehb 17)
c15:	dc.w	$0850		; <= 25 (ehb 20)
c16:	dc.w	$0310		; =
c17:	dc.w	$0430		; = (ehb for 14)
c18:	dc.w	$0540		; =
c19:	dc.w	$0850		; = 
c20:	dc.w	$0640		; = (ehb for 15)
c21:	dc.w	$0741		; =
c22:	dc.w	$0751		; = 
c23:	dc.w	$0861		; =
c24:	dc.w	$0a72		; =
c25:	dc.w	$0850		; =
c26:	dc.w	$0530   	; <= 30
c27:	dc.w	$0000   ; free
c28:	dc.w	$0000	; free
c29:	dc.w	$0fff	; free
c30:	dc.w	$00f0	; free
c31:	dc.w	$0f00	; free

orig_replace:		; replace original value x in palette by y
	dc.b    31,  0
	dc.b	30, 26	; c30: $530 => c26: $530
	dc.b    29,  2
	dc.b	28,  4
	dc.b    27,  8
orepe:

ehb_replace: 		; replace original color x by ehb color y
	dc.b     2,  7
	dc.b	 4, 11
	dc.b	 8,  9
	dc.b    14, 17
erepe:

cmap:   incbin  "sources:ehb/kingtut.col"   ; ilbm cmap (rgb-color = 3 bytes, one each value)

picture:

	incbin	"sources:ehb/Ah_kingtut.tft2.raw"	; raw picture = bpl values (without colors)

screen:
	ds.b	((640*256)/8)*6		; 640x256 with 6 bitplanes for EHB

tempc:	dc.b	0

	end

