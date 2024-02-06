; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	VDP initializer
; ------------------------------------------------------------------------------
; Copyright (c) 2021-2024 Takayuki Hara
; All rights reserved.
;
; Redistribution and use of this source code or any derivative works, are
; permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;	 this list of conditions and the following disclaimer.
; 2. Redistributions in binary form must reproduce the above copyright
;	 notice, this list of conditions and the following disclaimer in the
;	 documentation and/or other materials provided with the distribution.
; 3. Redistributions may not be sold, nor may they be used in a commercial
;	 product or activity without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
; "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
; TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
; EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
; PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
; WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
; OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
; ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
; ------------------------------------------------------------------------------
; History:
;   2021/Aug/12th  t.hara  Overall revision.  Coded in ZMA v1.0.15
;   2023/May/29th  KdL     Fixed the initialization of VDP R#10.
; ==============================================================================

			; VDP port 99h [set register]
vdp_control_regs::
;			db		0x00, 0x80				; 0x00 -> R#0 : SCREEN1 (GRAPHIC1 Mode) (default value)
;			db		0x00, 0x81				; 0x00 -> R#1 : SCREEN1 (GRAPHIC1 Mode) and Display Off (default value)
			db		0x1800 >> 10, 0x82		; 0x02 -> R#2 : Pattern Name Table is 0x1800 (LOW)
			db		0x2000 >> 6, 0x83		; 0x2C -> R#3 : Color Table is 0x2000
			db		0x0000 >> 11, 0x84		; 0x00 -> R#4 : Pattern Generator Table is 0x0000
			db		0x1B00 >> 7, 0x85		; 0x03 -> R#5 : Sprite Attribute Table is 0x1B00
			db		0x00, 0x86				; 0x00 -> R#6 : Sprite Pattern Generator Table is 0x0000
			db		0xF1, 0x87				; 0xF1 -> R#7 : Set Color (White on Black)
			db		0x00, 0x8A				; 0x00 -> R#10: Pattern Name Table is 0x1800 (HIGH)
			db		0x00, 0x8B				; 0x00 -> R#11: Sprite Attribute Table is 0x1B00
;			db		0x00, 0x90				; 0x00 -> R#16: Palette selector #0 (default value)
			db		0x00, 0x40				; VRAM address 0x0000
vdp_control_regs_end::

vdp_msx1_palette_regs::						; MSX1 like colors		※vdp_control_regs_end と連続
			db		0x00, 0x00				; 0
			db		0x00, 0x00				; 1
			db		0x22, 0x06				; 2
			db		0x34, 0x07				; 3
			db		0x37, 0x03				; 4
			db		0x47, 0x04				; 5
			db		0x53, 0x03				; 6
			db		0x47, 0x06				; 7
			db		0x63, 0x03				; 8
			db		0x64, 0x04				; 9
			db		0x63, 0x06				; 10
			db		0x65, 0x06				; 11
			db		0x11, 0x05				; 12
			db		0x56, 0x03				; 13
			db		0x66, 0x06				; 14
			db		0x77, 0x07				; 15
vdp_msx1_palette_regs_end::

icon_pattern::								; ※vdp_msx1_palette_regs_end と連続
			; Err. (1)
			db		0x00, 0xFF, 0xE1, 0xDF, 0xE3, 0xF3, 0xC2, 0xC4
			db		0x00, 0xF0, 0x30, 0xD0, 0xD0, 0x90, 0x30, 0x70
			db		0xFF, 0xF3, 0x00, 0x00, 0x02, 0x07, 0x0F, 0x1F
			db		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0xC0
			; EPCS1 (5)
			db		0x49, 0x49, 0xFF, 0xF1, 0xF9, 0xF9, 0xF9, 0xB0
			db		0x20, 0x20, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			; EPCS2 (9)
			db		0x49, 0x49, 0xFF, 0xF0, 0xFE, 0xF8, 0xF3, 0xB0
			db		0x20, 0x20, 0xF0, 0xF0, 0x70, 0xF0, 0xF0, 0x70
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			; SD card (13)
			db		0x00, 0xFF, 0xE1, 0xDF, 0xE3, 0xF3, 0xC2, 0xC4
			db		0x00, 0xF0, 0x30, 0xD0, 0xD0, 0x90, 0x30, 0x70
			db		0xFF, 0xF3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			; Loop Err. (17)
			db		0x0F, 0x1D, 0x35, 0x65, 0x6D, 0x6F, 0x67, 0x30
			db		0x80, 0xC0, 0x60, 0x30, 0xB0, 0xB0, 0x30, 0x60
			db		0x1F, 0x0F, 0x00, 0x00, 0x02, 0x07, 0x0F, 0x1F
			db		0xC0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x80, 0xC0
			; EPCS1 Anim. (21) : Fuzzy LED
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x0A, 0x05, 0x0A
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x05, 0x0A, 0x05
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			; EPCS2 Anim. (25) : Fuzzy LED
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x0A, 0x05, 0x0A
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0xFF, 0x49, 0x49, 0x00, 0x00, 0x05, 0x0A, 0x05
			db		0xF0, 0x20, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
			; SD card Anim. (29) : Slip Ring
			db		0xFF, 0xF3, 0x00, 0x00, 0x02, 0x08, 0x01, 0x04
			db		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
			db		0xFF, 0xF3, 0x00, 0x00, 0x04, 0x01, 0x08, 0x02
			db		0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
icon_pattern_end::

vdp_msx2_palette_regs::						; MSX2 colors
			db		0x11, 0x06				; 2
			db		0x33, 0x07				; 3
			db		0x17, 0x01				; 4
			db		0x27, 0x03				; 5
			db		0x51, 0x01				; 6
			db		0x27, 0x06				; 7
			db		0x71, 0x01				; 8
			db		0x73, 0x03				; 9
			db		0x61, 0x06				; 10
			db		0x64, 0x06				; 11
			db		0x11, 0x04				; 12
			db		0x65, 0x02				; 13
			db		0x55, 0x05				; 14
vdp_msx2_palette_regs_end::

; --------------------------------------------------------------------
;	set_msx2_palette
;	input:
;		none
;	output:
;		none
;	break:
;		B,C,D,E
;	comment:
;
; --------------------------------------------------------------------
;			scope	set_msx2_palette
;set_msx2_palette::
;			ld		a, 2
;			out		[vdp_port1], a
;			ld		a, 0x90
;			out		[vdp_port1], a
;			ld		bc, ((vdp_msx2_palette_regs_end - vdp_msx2_palette_regs) << 8) | vdp_port2
;			ld		hl, vdp_msx2_palette_regs
;			otir
;			ret
;			endscope

; ====================================================================
NO_EPCS_ICON		:= 0;		ECPS Icon:		0 = Shown,	1 = Hidden
NO_SD_ICON			:= 0;		SD card Icon:	0 = Shown,	1 = Hidden
EPCS_ANI_ENABLER	:= 1;		EPCS Anim.:		0 = Off,	1 = On
SD_ANI_ENABLER		:= 1;		SD card Anim.:	0 = Off,	1 = On
; ====================================================================
ICON_ERROR			:= 1;
ICON_EPCS1			:= 32 * NO_EPCS_ICON + 5;
ICON_EPCS2			:= 32 * NO_EPCS_ICON + 9;
ICON_SD_CARD		:= 32 * NO_SD_ICON + 13;
ICON_LOOP			:= 17;
ICON_EPCS1_ANI		:= 16 * EPCS_ANI_ENABLER + ICON_EPCS1;
ICON_EPCS2_ANI		:= 16 * EPCS_ANI_ENABLER + ICON_EPCS2;
ICON_SD_ANI			:= 16 * SD_ANI_ENABLER + ICON_SD_CARD;

; --------------------------------------------------------------------
;	Put icon
;	input:
;		A .... ICON Number	1: Err., 5: EPCS1, 9: EPCS2, 13: SD card, 17: Loop Err.,
;							21: EPCS1 Anim., 25: EPCS2 Anim., 29: SD card Anim.
;	output:
;		none
;	break:
;		A,B,C,H,L
;	comment:
;
; --------------------------------------------------------------------
			scope	vdp_put_icon
vdp_put_icon::
			ld		hl, 0x1801 | 0x4000
			call	sub_code
vdp_put_animation::
			ld		hl, 0x1821 | 0x4000
sub_code:
			ld		c, vdp_port1
			out		[c], l
			out		[c], h
			out		[vdp_port0], a
			inc		a
			out		[vdp_port0], a
			inc		a
			ret
			endscope
