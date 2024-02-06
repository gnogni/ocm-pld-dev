; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	load BIOS image
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
;   2022/Oct/22nd  t.hara  Overall revision.  Coded in ZMA v1.0.15
;   2024/Jan/21st  KdL     Added support for C-BIOS.
;                          Added special features to [RALT] and [RCTRL] keys.
; ==============================================================================

; --------------------------------------------------------------------
;	MegaSD Bank ID
; --------------------------------------------------------------------
DOS_ROM1_BANK					:= 0x80
DOS_ROM2_BANK					:= 0x82
DOS_ROM3_BANK					:= 0x84
DOS_ROM4_BANK					:= 0x86
DOS_ROM5_BANK					:= 0x88
DOS_ROM6_BANK					:= 0x8A
DOS_ROM7_BANK					:= 0x8C
DOS_ROM8_BANK					:= 0x8E
MAIN_ROM1_BANK					:= 0x90
MAIN_ROM2_BANK					:= 0x92
XBASIC2_BANK					:= 0x94
MSX_MUSIC_BANK					:= 0x96
SUB_ROM_BANK					:= 0x98
MSX_KANJI1_BANK					:= 0x9A
MSX_KANJI2_BANK					:= 0x9C
OPT_ROM_BANK					:= 0x9E
JIS1_KANJI1_BANK				:= 0xA0
JIS1_KANJI2_BANK				:= 0xA2
JIS1_KANJI3_BANK				:= 0xA4
JIS1_KANJI4_BANK				:= 0xA6
JIS1_KANJI5_BANK				:= 0xA8
JIS1_KANJI6_BANK				:= 0xAA
JIS1_KANJI7_BANK				:= 0xAC
JIS1_KANJI8_BANK				:= 0xAE
JIS2_KANJI1_BANK				:= 0xB0
JIS2_KANJI2_BANK				:= 0xB2
JIS2_KANJI3_BANK				:= 0xB4
JIS2_KANJI4_BANK				:= 0xB6
JIS2_KANJI5_BANK				:= 0xB8
JIS2_KANJI6_BANK				:= 0xBA
JIS2_KANJI7_BANK				:= 0xBC
JIS2_KANJI8_BANK				:= 0xBE

; ------------------------------------------------------------------------------
;	load_bios
;	input:
;		cde ... target sector number
;		hl .... bios image link table
;	output:
;		none
;	break:
;		all
;	comment:
;		Load the BIOS image, and if it loads successfully, boot the image.
; ------------------------------------------------------------------------------
			scope	load_bios
load_bios::
			; Load the BIOS image
			ld			a, 0xD4
			ld			[bios_updating], a				; Write the bios_updating flag.

			ld			a, DOS_ROM1_BANK				; target bank ID on ESE-RAM
			ld			[bank_id], a
load_block_loop::
			; get bios image link table
			ld			a, [hl]
			inc			hl
			cp			a, 0x40							; 0...63 : load bios image
			jr			c, load_bios_images
			jp			z, fill_ff_or_c9
			cp			a, 0xFE - 1
			jr			nc, exit_load_bios				; Return with Zf=0 and Cy=0, when finish code 0xFF/0xFE.
fill_zero:
			push		hl
			and			a, 0x3F
			ld			b, a
			ld			c, 0
fill_zero_loop:
			call		fill_bank
			djnz		fill_zero_loop
			pop			hl
			jr			load_block_loop
exit_load_bios:

			; KanjiROM JIS 2nd enabler					; JIS2 enable  , JIS2 disable
			rrca										; 0xFF ==> 0xFF, 0xFE ==> 0x7F
			cpl											; 0xFF ==> 0x00, 0x7F ==> 0x80
			out			[0x4E], a

			ld			a, [animation_id]				; clear the animation
			call		vdp_put_icon

			; set_f4_device
set_f4_device::
			call		get_msx_version
			out			[0x4C], a						; auto-set the VDP ID
			sub			a, 3
			jr			z, s1							; BIOS error if msx version is > 3
			ret			nc
s1:
			out			[0x4F], a						; 0x0? = normal, 0xF? = inverted
			out			[0xF4], a						; force MSX logo = ON

			; let's intercept [RALT] key after loading the BIOS
enforce_slot0_primary_mode::
			in			a, [0xAA]
			and			a, 0xF0
			add			a, 0x0B							; row[B] of the Japanese Key Matrix Table
			out			[0xAA], a
			in			a, [0xA9]
			bit			3, a							; bit[3] of the Japanese Key Matrix Table
			jr			nz, enforce_extra_mapper
			; bit[3] = 0, [RALT] key is held down
			ld			a, 0xF9
			out			[0x41], a						; Slot0 Primary Mode (not expanded)
			cpl											; a = 0b0000_0110, [RCTRL] key will be ignored
			; let's intercept [RCTRL] key after loading the BIOS
enforce_extra_mapper:
			bit			1, a							; bit[1] of the Japanese Key Matrix Table
			jr			nz, boot_up_bios
			; bit[1] = 0, [RCTRL] key is held down
			ld			a, 0x57							; Extra-Mapper 4096 kB = ON (available only if Slot0 is expanded)
			out			[0x41], a

boot_up_bios::
			call		get_msx_version
			or			a, a
			jr			z, bank_init					; if MSX BIOS ID = 0, skip the MSX2 palette
set_msx2_palette:
			ld			a, 2
			out			[vdp_port1], a
			ld			a, 0x90
			out			[vdp_port1], a
			ld			bc, ((vdp_msx2_palette_regs_end - vdp_msx2_palette_regs) << 8) | vdp_port2
			ld			hl, vdp_msx2_palette_regs
			otir
bank_init:
			; initialize ESE-RAM bank registers
			xor			a, a
			out			[exp_io_vendor_id_port], a		; ID canceled to support many more cartridges
			ld			[bios_updating], a				; Delete the bios_updating flag.
			ld			[eseram8k_bank0], a				; init ESE-RAM Bank#0
			inc			a
			ld			[eseram8k_bank1], a				; init ESE-RAM Bank#1
			ld			[eseram8k_bank2], a				; init ESE-RAM Bank#2
			ld			[eseram8k_bank3], a				; init ESE-RAM Bank#3
			ld			a, 0xC0
			out			[primary_slot_register], a		; ff_ldbios_n <= '1' [sm_emsx_top.vhd]
			rst			00								; reset MSX BASIC
			endscope

; ------------------------------------------------------------------------------
;	load_bios_images
;	input:
;		cde .. target sector address
;		a .... number of blocks
;	output:
;		cde .. next sector address
;	break:
;		a, b, f
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		load_bios_images
load_bios_images::
loop:
			; read sectors
			ex			af,af'
			call		set_bank
			push		hl
			ld			b, 16384 / 512					; Number of sectors equal to 16KB
			ld			hl, 0x8000
			read_sector_cbr := $ + 1
			call		sd_read_sector
			pop			hl
			ret			c								; error
			; check "AB" mark
			ld			a, [bank_id]
			cp			a, JIS1_KANJI1_BANK
			jr			z, make_cbios_check
			cp			a, DOS_ROM2_BANK
			jr			nz, skip_ab_check
			call		ab_check
			ret			nz								; "AB" not found
skip_ab_check:
			ex			af,af'
			dec			a
			jr			nz, loop
			jp			load_block_loop
make_cbios_check:
			; check for C-BIOS Logo ROM
			call		cbios_check
			jr			skip_ab_check
			endscope

; ------------------------------------------------------------------------------
;	ab_check
;	input:
;		none
;	output:
;		none
;	break:
;		af
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		ab_check
ab_check::
			push		hl
			ld			hl, 0x8000
			ld			a, [hl]
			xor			a, 'A'
			xor			a, 'B'
			inc			hl
			cp			a, [hl]
			pop			hl
			ret
			endscope

; ------------------------------------------------------------------------------
;	cbios_check
;	input:
;		none
;	output:
;		none
;	break:
;		af
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		cbios_check
cbios_check::
			push		hl
			ld			hl, 0x8000
			ld			a, [hl]
			xor			a, 'C'
			xor			a, '-'
			inc			hl
			cp			a, [hl]
			pop			hl
			ret			nz								; "C-" not found
			ld			a, 0xF9
			out			[0x41], a						; C-BIOS Mode = ON
			push		bc
			ld			bc, 0xC000
wait_a_moment:
			dec			c
			cp			a, c
			jr			nz, wait_a_moment
			djnz		wait_a_moment
			pop			bc
			ret
			endscope

; ------------------------------------------------------------------------------
;	fill_ff_or_c9
;	input:
;		none
;	output:
;		none
;	break:
;		af
;	comment:
;		If it is a turboR BIOS, it will fill the current bank with C9h.
;		Otherwise, it will fill with FFh.
; ------------------------------------------------------------------------------
			scope		fill_ff_or_c9
fill_ff_or_c9::
			call		get_msx_version
			cp			a, 3						; Is this turboR BIOS?
			ld			c, 0xFF						; -- No, fill 0xFF
			jr			c, fill_ff
			ld			c, 0xC9						; -- Yes, fill 0xC9
fill_ff:
			call		fill_bank
			jp			load_block_loop
			endscope

; ------------------------------------------------------------------------------
;	get_msx_version
;	input:
;		none
;	output:
;		a .... MSX version number: 0=MSX1, 1=MSX2, 2=MSX2+, 3=MSXtR
;	break:
;		af
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		get_msx_version
get_msx_version::
			ld			a, MAIN_ROM1_BANK
			ld			[eseram8k_bank2], a
			ld			a, [0x8000 + 0x002D]
			ret
			endscope

; ------------------------------------------------------------------------------
;	fill_bank
;	input:
;		bank_id ... Target bank ID
;		c ......... Fill data
;	output:
;		none
;	break:
;		bc', de', hl'
;	comment:
;		Fill data by A into 0x8000-0xBFFF.
; ------------------------------------------------------------------------------
			scope		fill_bank
fill_bank::
			call		set_bank
			ld			a, c
			exx
			ld			hl, 0x8000
			ld			de, 0x8001
			ld			bc, 0x4000 - 1
			ld			[hl], a
			ldir
			exx
			ret
			endscope

; ------------------------------------------------------------------------------
;	set_bank
;	input:
;		bank_id ... Target bank ID
;	output:
;		none
;	break:
;		af
;	comment:
;		-
; ------------------------------------------------------------------------------
			scope		set_bank
set_bank::
			ld			a, [animation_id + 1]
			push		af
			ld			a, [animation_id + 2]
			ld			[animation_id + 1], a
			push		bc
			push		hl
			; make the animation
			call		vdp_put_animation
			pop			hl
			pop			bc
			pop			af
			ld			[animation_id + 2], a
			; set ESE-RAM bank ID for Bank2 and Bank3
			ld			a, [bank_id]
			ld			[eseram8k_bank2], a
			inc			a
			ld			[eseram8k_bank3], a
			inc			a
			ld			[bank_id], a
			ret
			endscope

; ------------------------------------------------------------------------------
;	MEMO: Japanese Key Matrix Table
;	
;	 bit    7 F   6 E   5 D   4 C   3 B   2 A   1 9   0 8
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBE5 | 7 ' | 6 & | 5 % | 4 $ | 3 # | 2 " | 1 ! |  0  |  0
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBE6 | ; + | [ { | @ ` |Yen || ^ ~ | - = | 9 ) | 8 ( |  1
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBE7 |  B  |  A  |  _  | / ? | . > | , < | ] } | : * |  2
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBE8 |  J  |  I  |  H  |  G  |  F  |  E  |  D  |  C  |  3
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBE9 |  R  |  Q  |  P  |  O  |  N  |  M  |  L  |  K  |  4
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBEA |  Z  |  Y  |  X  |  W  |  V  |  U  |  T  |  S  |  5
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBEB | F3  | F2  | F1  | Kana|CapsL|Graph| Ctrl|Shift|  6
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBEC |Enter|Selec| BS  | Stop| Tab | Esc | F5  | F4  |  7
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBED |Right| Down| Up  | Left| Del | Ins | Home|Space|  8
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBEE | [4] | [3] | [2] | [1] | [0] | [/] | [+] | [*] |  9
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	#FBEF | [.] | [,] | [-] | [9] | [8] | [7] | [6] | [5] |  A
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	 ---- |     |     |     |     |[Can]|     |[Exe]|     |  B    Can: Torikeshi(Cancel) = [RALT], Exe: Jikkou(Execute) = [RCTRL]
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	 ---- |     |     |     |     |     |     |     |     |  D
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	 ---- |     |     |     |     |     |     |     |     |  D
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	 ---- |ScrLk|     |     |     |     |     |     |     |  E
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	 ---- | N/A |PrtSc|PgUp |PgDn | F9  | F10 | F11 | F12 |  F
;	      +-----+-----+-----+-----+-----+-----+-----+-----+
;	bit     7 F   6 E   5 D   4 C   3 B   2 A   1 9   0 8
; ------------------------------------------------------------------------------
