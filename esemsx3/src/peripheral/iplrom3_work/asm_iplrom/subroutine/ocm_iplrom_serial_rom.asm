; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	EPCS Serial ROM Driver
; ------------------------------------------------------------------------------
; Copyright (c) 2021-2025 Takayuki Hara
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
;   2022/Oct/22nd  t.hara  Overall revision.  Coded in ZMA v1.0.15
; ==============================================================================

; --------------------------------------------------------------------
;	EPCS Operation Codes
; --------------------------------------------------------------------
EPCS_WRITE_ENABLE		:= 0b0000_0110
EPCS_WRITE_DISABLE		:= 0b0000_0100
EPCS_READ_STATUS		:= 0b0000_0101
EPCS_READ_BYTES			:= 0b0000_0011
EPCS_READ_SILICON_ID	:= 0b1010_1011			; require EPCS1/4/16/64
EPCS_FAST_READ			:= 0b0000_1011
EPCS_WRITE_STATUS		:= 0b0000_0001
EPCS_WRITE_BYTES		:= 0b0000_0010
EPCS_ERASE_BULK			:= 0b1100_0111
EPCS_ERASE_SECTOR		:= 0b1101_1000
EPCS_READ_DEVICE_ID		:= 0b1001_1111			; require EPCS128 or later

; ------------------------------------------------------------------------------
;	read_sector_from_epcs
;	input:
;		DE .... target sector number
;		HL .... destination address
;		B ..... number of sectors (1-127)
;	output:
;		Cy .... 0: success, 1: error
;		DE .... next sector number
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		read_sector_from_epcs
read_sector_from_epcs::
			push		de								; target sector number

			ex			de, hl							; de = de * 2
			add			hl, hl
			ex			de, hl
			xor			a, a							; dea = byte address, Cy = 0
			ld			c, b							; C = number of sectors
			ld			b, a							; B = 0

			push		bc								; save number of sectors
			push		hl								; save destination address
			ld			hl, megasd_sd_register|(0<<12)	; /CS=0 (address bit12)
			ld			[hl], EPCS_READ_BYTES			; command byte
			ld			[hl], d							; byte address b23-b16
			ld			[hl], e							; byte address b15-b8
			ld			[hl], a							; byte address b7-b0
			cp			a, [hl]
			pop			de								; DE = destination address

			ld			a, c							; A = number of sectors
			ld			c, b							; C = 0
read_all:
			push		hl
			ld			b, 2							; BC = 512
			ldir										; read 1 sector
			pop			hl								; HL = megasd_sd_register|(0<<12)
			dec			a
			jr			nz, read_all

			ld			a, [megasd_sd_register|(1<<12)]	; /CS=1 (address bit12)

			pop			hl								; HL = number of sectors
			pop			de								; target sector number
			add			hl, de							; Cy = 0
			ex			de, hl							; next sector (512 bytes)
			ret
			endscope

