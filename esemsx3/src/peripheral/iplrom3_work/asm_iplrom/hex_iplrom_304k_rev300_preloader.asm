; ==============================================================================
;   IPL-ROM v3.00 for OCM-PLD v3.9.1 or later
; ------------------------------------------------------------------------------
;   Initial Program Loader for Cyclone & EPCS (Altera)
;   Revision 3.00
;
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
; IPL-ROM Revision 2.00 for 512 kB unpacked with Dual-EPBIOS support
; EPCS16 [or higher] start adr 100000h - Optimized by KdL 2020.01.09
;
; Coded in TASM80 v3.2ud w/ TWZ'CA3 for OCM-PLD Pack v3.4 or later
; TASM is at http://www.ticalc.org
;
; SDHC support by Yuukun-OKEI, thanks to MAX
; ------------------------------------------------------------------------------
; History:
;   2023/May/29th  v3.00  t.hara  Overall revision.  Coded in ZMA v1.0.15
; ==============================================================================

; --------------------------------------------------------------------
;	IPL-ROM PRELOADER v1.02 for EPCS4
; --------------------------------------------------------------------
IPLROM_BANK								:= 0xFF			; last ESE-RAM block (8 kB)
loading_attempts						:= 0x10			; number of attempts before showing the error icon

; --------------------------------------------------------------------
;	HEX-file location
; --------------------------------------------------------------------
target_sector_number					:= 0x019A		; EPCS start address 33400h / 512 bytes
destination_address						:= 0xB400		; B400h~BFFFh, 3072 bytes
number_of_sectors						:= 0x06			; the current length of the IPL-ROM is < 1536 bytes, max value is 0x06

; --------------------------------------------------------------------
;	MegaSD Information
; --------------------------------------------------------------------
megasd_sd_register						:= 0x4000		; Command register for read/write access of SD/SDHC/MMC/EPCS Controller (4000h-57FFh)
megasd_mode_register					:= 0x5800		; Mode register for write access of SD/SDHC/MMC/EPCS Controller (5800h-5FFFh)
megasd_status_register					:= 0x5800		; status register for read access of SD/SDHC/MMC/EPCS Controller (5800h-5BFFh)
megasd_last_data_register				:= 0x5C00		; last data register for read access of SD/SDHC/MMC/EPCS Controller (5C00h-5FFFh)

eseram8k_bank0							:= 0x6000		; 4000h~5FFFh bank selector
eseram8k_bank1							:= 0x6800		; 6000h~7FFFh bank selector
eseram8k_bank2							:= 0x7000		; 8000h~9FFFh bank selector
eseram8k_bank3							:= 0x7800		; A000h~BFFFh bank selector

; --------------------------------------------------------------------
;	Expanded I/O
; --------------------------------------------------------------------
exp_io_vendor_id_port					:= 0x40			; Vendor ID register for Expanded I/O
exp_io_1chipmsx_id						:= 0xD4			; KdL's switch device ID

; --------------------------------------------------------------------
;	Work area
; --------------------------------------------------------------------
dram_code_address						:= 0x0000		; program code address on DRAM

; --------------------------------------------------------------------
			org			dram_code_address
begin_of_code:

			di

init_switch_io::
			ld			a, exp_io_1chipmsx_id
			out			[exp_io_vendor_id_port], a

			include		"../subroutine/ocm_iplrom_preloader.asm"

			include		"../subroutine/ocm_iplrom_vdp.asm"
			ld			a, ICON_ERROR
stop_with_error::
			call		vdp_put_icon
			ld			a, 0x35							; Lock Hard Reset Key
			out			[0x41], a
			ld			a, 0x1F							; Set MegaSD Blink OFF
			out			[0x41], a
			ld			a, 0x23							; Set Lights Mode ON + Red Led ON
			out			[0x41], a
			halt										; stop

; --------------------------------------------------------------------
			include		"../subroutine/ocm_iplrom_serial_rom.asm"
			include		"../subroutine/ocm_iplrom_vdp_preloader_icon.asm"
end_of_code:

			if (end_of_code - begin_of_code) > 512
				error "The size is too BIG. (" + (end_of_code - begin_of_code) + "byte)"
			else
				message "Size is not a problem. (" + (end_of_code - begin_of_code) + "byte)"
			endif
