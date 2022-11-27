; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	VDP initializer
; ------------------------------------------------------------------------------
; Copyright (c) 2021-2022 Takayuki Hara
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
;   2021/Aug/12th  t.hara  Overall revision.
; ==============================================================================

			; VDP port 99h [set register]
vdp_control_regs::
;			db		0x00, 0x80				; 0x00 -> R#0 : SCREEN1 (GRAPHIC1 Mode) (default value)
;			db		0x00, 0x81				; 0x00 -> R#1 : SCREEN1 (GRAPHIC1 Mode) and Display Off (default value)
			db		0x1800 >> 10, 0x82		; 0x02 -> R#2 : Pattern Name Table is 0x1800
			db		0x2000 >> 6, 0x83		; 0x2C -> R#3 : Color Table is 0x2000
			db		0x0000 >> 11, 0x84		; 0x00 -> R#4 : Pattern Generator Table is 0x0000
			db		0x1B00 >> 7, 0x85		; 0x03 -> R#5 : Sprite Attribute Table is 0x1B00
			db		0x00, 0x86				; 0x00 -> R#6 : Sprite Pattern Generator Table is 0x0000
			db		0xF1, 0x87				; 0xF1 -> R#7 : Set Color (White on Black)
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
			; SD card (1)
			db		0xFF, 0xCB, 0xBD, 0xCD, 0xE9, 0x93, 0xFC, 0x00
			; EPCS1 (2)
;			db		0x54, 0x54, 0xFE, 0xFE, 0xBE, 0xFE, 0x54, 0x54
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

ICON_SD_CARD		:= 1;
ICON_EPCS1			:= 2;

; --------------------------------------------------------------------
;	Put icon
;	input:
;		A .... ICON Number 1: SD card, 2: EPCS1
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
			ld		c, vdp_port1
			out		[c], l
			out		[c], h
			out		[vdp_port0], a
			ret
			endscope
