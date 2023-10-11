; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	VDP initializer
; ------------------------------------------------------------------------------
; Copyright (c) 2021-2023 Takayuki Hara
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
;   2023/May/29th  t.hara  Overall revision.  Coded in ZMA v1.0.15
; ==============================================================================

; --------------------------------------------------------------------
;	I/O
; --------------------------------------------------------------------
vdp_port0						:= 0x98
vdp_port1						:= 0x99
vdp_port2						:= 0x9A
vdp_port3						:= 0x9B

; --------------------------------------------------------------------
;	Initialize VDP
;	input:
;		none
;	output:
;		none
;	break:
;		B,C,H,L
;	comment:
;		MSX2 and later BIOS initialize the palette in the BIOS.
;		However, the MSX1 BIOS does not initialize the palette.
;		In this section, we will initialize the palette to get MSX1-like 
;		hues when trying MSX1-BIOS with SDBIOS.
; --------------------------------------------------------------------
			scope		init_vdp
init_vdp::
			ld			hl, vdp_control_regs
			ld			bc, ((vdp_control_regs_end - vdp_control_regs) << 8) | vdp_port1
			otir
			ld			bc, ((vdp_msx1_palette_regs_end - vdp_msx1_palette_regs) << 8) | vdp_port2
			otir										; B = 0 になる
			dec			c								; C = vdp_port1

			; clear pattern generator table, pattern name table and sprite attribute table
			xor			a, a
			ld			d, 0x20							; 0x2000 bytes
loop1:
			out			[vdp_port0], a
			djnz		loop1
			dec			d
			jr			nz, loop1

			; clear color table
			ld			b, 32							; 32 bytes
			ld			a, 0xF1							; Set Color (White on Black)
loop2:
			out			[vdp_port0], a
			djnz		loop2

			; display on
			ld			de, 0x8140
			out			[c], e
			out			[c], d

			; set icon pattern to pattern generator table
			ld			d, 1 * 8						; ED = 0x4008
			out			[c], d
			out			[c], e
			dec			c
			ld			b, ((icon_pattern_end - icon_pattern) % 256)
			otir
			endscope
