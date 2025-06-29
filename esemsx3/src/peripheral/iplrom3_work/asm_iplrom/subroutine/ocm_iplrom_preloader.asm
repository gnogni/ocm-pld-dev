; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	Preloader tool
; ------------------------------------------------------------------------------
; Copyright (c) 2022-2025 KdL
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
;   2022/Oct/22nd  KdL  Overall revision.  Coded in ZMA v1.0.15
; ==============================================================================

			scope		init_preloader
init_preloader::
			ld			a, 0x40
			ld			[eseram8k_bank0], a					; BANK 40h
			ld			a, [megasd_status_register]
			ld			c, a								; save megasd status register
			; Change to EPCS access bank, and change to High speed and data disable mode
			ld			a, 0x60
			ld			[eseram8k_bank0], a					; init ESE-RAM Bank#0
			inc			a
			ld			[megasd_mode_register], a			; bit7 = 0, bit0 = 1 : high speed and data disable
			; /CS=1
			ld			b, 160
dummy_read0:
			ld			a, [megasd_sd_register|(1<<12)]		; /CS=1 (address bit12)
			nop
			djnz		dummy_read0
			ld			a, [megasd_sd_register|(0<<12)]		; /CS=0 (address bit12)
			xor			a, a
			ld			[megasd_mode_register], a			; bit7 = 0, bit0 = 0 : high speed and data enable
			ld			a, IPLROM_BANK						; Set to the last ESE-RAM block
			ld			[eseram8k_bank3], a					; init ESE-RAM Bank#3
			ld			b, loading_attempts					; b = number of attempts to load IPL-ROM
new_attempt:
			push		bc
			ld			de, target_sector_number
			ld			hl, destination_address
			ld			b, number_of_sectors				; 512 bytes per sector
			call		read_sector_from_epcs
			pop			bc
			jr			c, loading_error					; Cy = 1 : loading error
			ld			a, [destination_address]
			cp			a, 0xF3								; DI opcode?
			jr			nz, loading_error					; No, loading error
			ld			a, c								; restore megasd status register
			jp			destination_address					; Yes, start IPL-ROM
loading_error:
			djnz		new_attempt
			endscope
