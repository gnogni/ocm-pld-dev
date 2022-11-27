; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	EPCS Serial ROM Driver
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
;   2021/Aug/09th  t.hara  Overall revision.
; ==============================================================================

; ------------------------------------------------------------------------------
			scope		load_from_epcs
load_from_epcs::
			ld			hl, read_sector_from_epcs
			ld			[read_sector_cbr], hl

			; Change to EPCS access bank, and change to High speed and data disable mode
			ld			a, 0x60
			ld			[eseram8k_bank0], a
			inc			a
			ld			[megasd_mode_register], a			; bit7 = 0, bit0 = 1 : high speed and data disable

			; /CS=1
			ld			b, 160
dummy_read:
			ld			a, [megasd_sd_register|(1<<12)]		; /CS=1 (address bit12)
			nop
			djnz		dummy_read

			ld			a, [megasd_sd_register|(0<<12)]		; /CS=0 (address bit12)
			xor			a, a
			ld			[megasd_mode_register], a			; bit7 = 0, bit0 = 0 : high speed and data enable

			; set EPBIOS1 address
			ld			de, epcs_bios1_start_address
			ld			a, ICON_EPCS1_ANI + 2 * (1 - EPCS_ANI_ENABLER)
			ld			[animation_id + 2], a
			ld			a, ICON_EPCS1_ANI + 2
			ld			[animation_id + 1], a
			ld			a, ICON_EPCS1
			ld			[animation_id], a
			call		vdp_put_icon
			ld			hl, epbios_image_table
;			jp			load_bios							; Assuming load_bios is immediately next.
			endscope
