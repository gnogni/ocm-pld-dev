; ==============================================================================
;   IPL-ROM Updater for OCM-PLD v3.9.1 or later
; ------------------------------------------------------------------------------
;   Revision 1.02
;
; Copyright (c) 2022-2025 Takayuki Hara
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

BDOS				:= 0x0005
_STROUT				:= 0x09				; DE = string ( '$' terminated )
_OPEN				:= 0x43				; A = open mode, DE = file name
_CLOSE				:= 0x45				; B = file handle
_READ				:= 0x48				; B = file handle, DE = read buffer, HL = bytes
_TERM				:= 0x62				; B = return code

VDP_PORT0			:= 0x98
VDP_PORT1			:= 0x99

ENASLT				:= 0x0024
RAMAD1				:= 0xF342
REG1SAV				:= 0xF3E0
REG9SAV				:= 0xFFE8

PARAM_LENGTH_POS	:= 0x0080
PARAM				:= 0x0081

SWITCH_IO_PORTS		:= 0x40
OCM_IO				:= 0xD4
OCM_MACHINE_ID		:= 0x49
OCM_VRAM_SLOT_PORT	:= 0x4D
OCM_VERSION_XY_ID	:= 0x4E
OCM_VERSION_Z_ID	:= 0x4F

; EPCS address to be written
IPLROM_1ST_GEN		:= 0x33400
IPLROM_2ND_GEN		:= 0xFF400

READ_BUFFER			:= 0x8000
MAX_READ_SIZE		:= 8192

; MegaSD Slot
MEGA_SD_SLOT		:= 0b1000_1011		; SLOT#3-2
MEGA_SD_MEGACON		:= 0x6000
MEGA_SD_EPCS_BANK	:= 0x60
MEGA_SD_DOS2_BANK	:= 0x00
MEGA_SD_PORT_nCS_0	:= 0x4000
MEGA_SD_PORT_nCS_1	:= 0x5000

; EPCS command							; Address Bytes, Dummy Bytes, Data Bytes, MHz
EPCS_WRITE_ENABLE	:= 0b0000_0110		;      0              0           0        25
EPCS_WRITE_DISABLE	:= 0b0000_0100		;      0              0           0        25
EPCS_READ_STAT		:= 0b0000_0101		;      0              0           1 to inf 25
EPCS_READ_BYTES		:= 0b0000_0011		;      3              0           1 to inf 20
EPCS_READ_SID		:= 0b1010_1011		;      0              3           1 to inf 25
EPCS_FAST_READ		:= 0b0000_1011		;      3              1           1 to inf 40
EPCS_WRITE_STAT		:= 0b0000_0001		;      0              0           1        25
EPCS_WRITE_BYTES	:= 0b0000_0010		;      3              0           1 to 256 25
EPCS_ERASE_BULK		:= 0b1100_0111		;      0              0           0        25
EPCS_ERASE_SECTOR	:= 0b1101_1000		;      3              0           0        25
EPCS_READ_DID		:= 0b1001_1111		;      0              2           1 to inf 25

		org			0x0100

entry_point::
		; Display command name
		ld			de, s_tool_name
		ld			c, _STROUT
		call		BDOS

		; Check command line parameter
		ld			a, [PARAM_LENGTH_POS]
		or			a, a
		jp			z, display_usage

		; Check OCM
		ld			a, OCM_IO
		di
		out			[SWITCH_IO_PORTS], a
		in			a, [SWITCH_IO_PORTS]
		ei
		cp			a, ~OCM_IO
		jp			nz, display_not_ocm

		; Display 'TYPE'
		ld			de, s_type
		ld			c, _STROUT
		call		BDOS

		; Display OCM Type
		call		get_ocm_type_index
		ld			hl, a_name_table
		add			hl, de
		add			hl, de
		ld			e, [hl]
		inc			hl
		ld			d, [hl]
		ld			c, _STROUT
		call		BDOS

		; Display CR
		ld			de, s_crlf
		ld			c, _STROUT
		call		BDOS

		; Check OCM Type
		call		get_ocm_type_index
		cp			a, 2
		jp			c, first_gen
		cp			a, 5
		jp			c, second_gen

		; Unsupported type
		ld			de, s_unsupported
		ld			c, _STROUT
		call		BDOS
		ld			b, 3						; exit code is 3
		jp			exit_program

		; for first generation
first_gen::
		ld			a, '1'
		ld			[check_code], a
		ld			a, IPLROM_1ST_GEN >> 16
		ld			[sector_number], a
		jp			load_iplrom_image

		; for second generation
second_gen::
		ld			a, '2'
		ld			[check_code], a
		ld			a, IPLROM_2ND_GEN >> 16
		ld			[sector_number], a

		; load IPLROM image
load_iplrom_image::
		ld			hl, PARAM					; Command line parameter address (Input file name)
		ld			bc, [PARAM_LENGTH_POS]
		ld			b, 0
	_skip_space:
		ld			a, [hl]
		cp			a, ' '
		jr			nz, _no_space
		inc			hl
		dec			bc
		jr			_skip_space
	_no_space:
		ld			de, file_name
		ldir

		; -- replace 0Dh to 00h on file name
		ld			a, [PARAM_LENGTH_POS]		; MAX 0x7E
		and			a, 0x7F						; safety
		ld			b, a
		ld			hl, file_name
	_replace_0dh:
		ld			a, [hl]
		cp			a, 0x0D
		jr			nz, _no_replace
		ld			[hl], 0
	_no_replace:
		inc			hl
		djnz		_replace_0dh

		; -- file_handle = fopen( file_name, "rb" )
		xor			a, a						; Open mode is 0b0000_0000 (normal)
		ld			de, file_name
		ld			c, _OPEN
		call		BDOS

		or			a, a
		jp			nz, open_error

		ld			a, b
		ld			[file_handle], a

		; -- fread( READ_BUFFER, 8192, 1, file_handle )
		ld			de, READ_BUFFER
		ld			hl, MAX_READ_SIZE
		ld			c, _READ
		call		BDOS

		ld			[file_size], hl
		or			a, a
		jp			nz, read_error

		; -- fclose( file_handle )
		ld			a, [file_handle]
		ld			b, a
		ld			c, _CLOSE
		call		BDOS

		; -- display file size
		ld			de, s_file_size
		ld			c, _STROUT
		call		BDOS

		ld			hl, [file_size]
		call		puts_hl

		ld			de, s_bytes
		ld			c, _STROUT
		call		BDOS

		; -- Check Signature
		ld			b, 13
		ld			de, s_iplrom_signature
		ld			hl, READ_BUFFER
	_compare_loop:
		ld			a, [de]
		cp			a, [hl]
		jp			nz, invalid_file_error
		inc			de
		inc			hl
		djnz		_compare_loop

		; -- Check generation ID
		ld			a, [check_code]
		cp			a, [hl]
		jp			nz, no_match_generation_error

		; -- Check OCM-PLD version
		ld			a, OCM_IO
		di
		out			[SWITCH_IO_PORTS], a
		in			a, [OCM_VERSION_Z_ID]
		rrca
		rrca
		rrca
		rrca
		rrca
		and			a, 3
		ld			c, a						; sub-version num (0 to 3)
		in			a, [OCM_VERSION_XY_ID]
		ld			b, a						; version num (00.0 to 25.5)
		ei

		ld			a, [READ_BUFFER + 14]		; version num
		cp			a, b
		jp			c, no_match_version_error
		jp			nz, _skip_revision_check

		ld			a, [READ_BUFFER + 15]		; revision num
		cp			a, c
		jp			c, no_match_version_error
	_skip_revision_check:

		; get silicon ID
		call		epcs_open
		ld			[hl], EPCS_READ_SID
		ld			[hl], a						; 1st dummy byte
		ld			[hl], a						; 2nd dummy byte
		ld			[hl], a						; 3rd dummy byte
		ld			a, [hl]						; 1st attempt
		ld			a, [hl]						; 2nd attempt
		ld			a, [hl]						; 3rd attempt
		ld			a, [hl]						; 4th attempt
		ld			a, [hl]						; 5th attempt
		ld			[silicon_id], a
		ld			a, [MEGA_SD_PORT_nCS_1]
		call		epcs_close

		; check silicon ID
		ld			a, [check_code]
		cp			a, '2'
		jr			z, check_silicon_id_for_2nd_gen

		; check silicon ID for 1st generation
check_silicon_id_for_1st_gen::
		ld			a, [silicon_id]
		cp			a, 0b0001_0000				; error, when EPCS1
		jp			z, epcs_device_error
		cp			a, 0b0001_0100				; error, when EPCS16
		jp			z, epcs_device_error
		cp			a, 0b0001_0110				; error, when EPCS64
		jp			z, epcs_device_error
		jr			end_of_check_silicon_id

		; check silicon ID for 2nd generation
check_silicon_id_for_2nd_gen::
		ld			a, [silicon_id]
		cp			a, 0b0001_0000				; error, when EPCS1
		jp			z, epcs_device_error
		cp			a, 0b0001_0010				; error, when EPCS4
		jp			z, epcs_device_error
end_of_check_silicon_id::

; ==============================================================================
		; VDP R#1 setup
		call		setup_vdp_r1

		; change VRAM slot ID by KdL
		ld			hl, vram_slot_id
		in			a, [OCM_VRAM_SLOT_PORT]
		cpl
		cp			a, [hl]
		jr			z, _set_vram_slot_id03
		ld			[hl], a
		ld			a, 0b1110_1111				; 64 KB VRAM slot ID 0,1
		jr			_change_vram_slot_id
	_set_vram_slot_id03:
		ld			a, 0b1100_1111				; 64 KB VRAM slot ID 0,3
	_change_vram_slot_id:
		out			[OCM_VRAM_SLOT_PORT], a
; ==============================================================================

		call		epcs_open

		; backup target sector to VRAM 0x10000-0x1FFFF
		exx
		ld			hl, 0						; VRAM address
		ld			de, 256
		exx

		; -- read the target sector on EPCS
		ld			a, [sector_number]
		ld			d, a
		ld			b, 0
		ld			c, b
	_read_page_loop:
		exx
		call		set_write_vram_address
		add			hl, de
		exx

		ld			[hl], EPCS_READ_BYTES
		ld			[hl], d						; A[23:16] = (sector ID)
		ld			[hl], c						; A[15:8]  = (page ID)
		ld			[hl], b						; A[7:0]   = 0
		ld			a, [hl]						; dummy read

	_read_256bytes_loop:
		ld			a, [hl]
		out			[VDP_PORT0], a
		djnz		_read_256bytes_loop
		ld			a, [MEGA_SD_PORT_nCS_1]
		nop

		inc			c
		jr			nz, _read_page_loop

		call		epcs_close

		; -- set VRAM address
		ld			c, VDP_PORT1
		ld			a, [check_code]
		cp			a, '2'
		jr			z, _set_vram_address_for_2nd_gen
	_set_vram_address_for_1st_gen:
		ld			hl, IPLROM_1ST_GEN & 0xFFFF
		jr			_set_vram_address

	_set_vram_address_for_2nd_gen:
		ld			hl, IPLROM_2ND_GEN & 0xFFFF
	_set_vram_address:
		call		set_write_vram_address

		; -- over write new IPLROM on VRAM
		ld			hl, [file_size]
		ld			bc, -16
		add			hl, bc
		ld			b, h
		ld			c, l
		ld			hl, READ_BUFFER + 16
	_overwrite_loop:
		ld			a, [hl]
		out			[VDP_PORT0], a
		inc			hl
		dec			bc
		ld			a, c
		or			a, b
		jr			nz, _overwrite_loop

		; erase sectors
		call		epcs_open

		ld			a, EPCS_WRITE_ENABLE
		ld			[hl], a						; WRITE_ENABLE command
		ld			a, [MEGA_SD_PORT_nCS_1]

		ld			a, [sector_number]
		ld			b, 0
		ld			c, a
		ld			a, EPCS_ERASE_SECTOR
		ld			[hl], a						; EPCS_ERASE_SECTOR command
		ld			[hl], c						; address [23:16]
		ld			[hl], b						; address [16:8]
		ld			[hl], b						; address [7:0]
		ld			a, [MEGA_SD_PORT_nCS_1]
		nop

		; Wait until the write progress bit is set to 0
		ld			a, EPCS_READ_STAT
		ld			[hl], a
	_wait_erase:
		ld			a, [hl]
		and			a, 1
		jr			nz, _wait_erase
		ld			a, [MEGA_SD_PORT_nCS_1]

		; Set read mode for VDP
		exx
		ld			hl, 0						; VRAM address
		ld			de, 256
		exx

		; Write sector
		ld			a, [sector_number]
		ld			d, a						; sector ID : D = [sector_number]
		ld			b, 0
		ld			c, b						; page ID   : C = 0
	_write_page_loop:
		exx
		call		set_read_vram_address
		add			hl, de
		exx

		ld			a, EPCS_WRITE_ENABLE
		ld			[hl], a						; WRITE_ENABLE command
		ld			a, [MEGA_SD_PORT_nCS_1]
		nop

		ld			[hl], EPCS_WRITE_BYTES		; WRITE_BYTES command (MAX 256bytes)
		ld			[hl], d						; address [23:16] (sector ID)
		ld			[hl], c						; address [15:8] (page ID)
		ld			[hl], b						; address [7:0] = 0

	_write_256bytes_loop:
		in			a, [VDP_PORT0]
		ld			[hl], a
		djnz		_write_256bytes_loop
		ld			a, [MEGA_SD_PORT_nCS_1]
		nop

		ld			[hl], EPCS_READ_STAT
	_wait_write:
		ld			a, [hl]
		and			a, 1
		jr			nz, _wait_write
		ld			a, [MEGA_SD_PORT_nCS_1]

		inc			c
		jr			nz, _write_page_loop

		call		epcs_close
		call		reset_vram_high_address
; ==============================================================================
		; restore VRAM slot ID
		ld			a, [vram_slot_id]
		out			[OCM_VRAM_SLOT_PORT], a

		; restore VDP R#1
		call		restore_vdp_r1
; ==============================================================================

		ld			de, s_completed
		ld			c, _STROUT
		call		BDOS
		ld			b, 0						; exit code is 0
		jp			exit_program

; ==============================================================================
; setup VDP R#1 by KdL
setup_vdp_r1::
		ld			a, [REG1SAV]
		ld			[backup_vdp_r1], a
		ld			a, [REG9SAV]
		bit			3, a						; check for interlace mode (VDP R#9 bit3)
		ret			z							; exit if not interlaced
		ld			a, [REG1SAV]
		and			a, 0b1011_1111				; screen disabled (VDP R#1 bit6)
		jr			set_vdp_r1

; restore VDP R#1
restore_vdp_r1::
		ld			a, [backup_vdp_r1]
set_vdp_r1::
		di
		out			[VDP_PORT1], a
		ld			a, 0b1000_0000 | 1
		ei
		out			[VDP_PORT1], a
		ret
; ==============================================================================

		; EPCS open
epcs_open::
		; -- Change slot to MegaSD
		ld			a, MEGA_SD_SLOT
		ld			h, 0x40						; page 1
		call		ENASLT

		; -- Change bank to EPCS
		ld			a, MEGA_SD_EPCS_BANK
		ld			[MEGA_SD_MEGACON], a
		ld			hl, MEGA_SD_PORT_nCS_0
		ret

		; EPCS close
epcs_close::
		; -- Change bank to DOS2
		ld			a, MEGA_SD_DOS2_BANK
		ld			[MEGA_SD_MEGACON], a

		; -- Change slot to RAM
		ld			a, [RAMAD1]
		ld			h, 0x40						; page 1
		call		ENASLT
		ret

		; Get OCM Type index
get_ocm_type_index::
		ld			a, OCM_IO
		di
		out			[SWITCH_IO_PORTS], a
		in			a, [OCM_MACHINE_ID]
		ei
		rrca
		rrca
		and			a, 0x0F
		ld			e, a
		ld			d, 0
		ret

		; set VRAM address for write (HL)
set_write_vram_address::
		ld			a, h
		rlca
		rlca
		and			a, 0b0000_0011
		or			a, 0b0000_0100
		out			[VDP_PORT1], a
		ld			a, 0b1000_0000 | 14
		out			[VDP_PORT1], a				; VDP address[16:14] = { 1, H[15:14] }
		ld			a, l
		out			[VDP_PORT1], a				; VDP address[7:0] = L
		ld			a, h
		and			a, 0b0011_1111
		or			a, 0b0100_0000
		out			[VDP_PORT1], a				; VDP address[13:8] = { H[13:8]; write mode
		ret

		; set VRAM address for read (HL)
set_read_vram_address::
		ld			a, h
		rlca
		rlca
		and			a, 0b0000_0011
		or			a, 0b0000_0100
		out			[VDP_PORT1], a
		ld			a, 0b1000_0000 | 14
		out			[VDP_PORT1], a				; VDP address[16:14] = { 1, H[15:14] }
		ld			a, l
		out			[VDP_PORT1], a				; VDP address[7:0] = L
		ld			a, h
		and			a, 0b0011_1111
		out			[VDP_PORT1], a				; VDP address[13:8] = { H[13:8]; read mode
		ret

		; reset VDP R#14
reset_vram_high_address::
		xor			a, a
		out			[VDP_PORT1], a
		ld			a, 0b1000_0000 | 14
		out			[VDP_PORT1], a				; VDP address[16:14] = 0
		ret

epcs_device_error::
		ld			de, s_epcs_device_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 8						; exit code is 8
		jp			exit_program

no_match_version_error::
		ld			de, s_no_match_version_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 7						; exit code is 7
		jp			exit_program

no_match_generation_error::
		ld			de, s_no_match_generation_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 6						; exit code is 6
		jp			exit_program

invalid_file_error::
		ld			de, s_invalid_file_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 5						; exit code is 5
		jp			exit_program

open_error::
		ld			de, s_open_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 4						; exit code is 4
		jp			exit_program

read_error::
		ld			de, s_read_error
		ld			c, _STROUT
		call		BDOS
		ld			b, 3						; exit code is 3
		jp			exit_program

		; Display not OCM and exit program
display_not_ocm::
		ld			de, s_not_ocm
		ld			c, _STROUT
		call		BDOS
		ld			b, 2						; exit code is 2
		jp			exit_program

		; Display usage and exit program
display_usage::
		ld			de, s_usage
		ld			c, _STROUT
		call		BDOS
		ld			b, 1						; exit code is 1

exit_program::
		ld			c, _TERM
		jp			BDOS

		scope		puts_hl
puts_hl::
		ld			bc, str_buffer
		ld			de, 10000
		call		_count
		ld			de, 1000
		call		_count
		ld			de, 100
		call		_count
		ld			de, 10
		call		_count
		ld			de, 1
		call		_count

		ld			hl, str_buffer
		ld			b, 4
_non_zero_search:
		ld			a, [hl]
		cp			a, '0'
		jr			nz, _non_zero
		inc			hl
		djnz		_non_zero_search
_non_zero:
		ex			de, hl
		ld			c, _STROUT
		jp			BDOS						; CALL BDOS and RET
_count:
		push		bc
		xor			a, a						; a = 0 and Cy = 0
_count_loop:
		sbc			hl, de
		jr			c, _count_exit
		inc			a
		jr			_count_loop
_count_exit:
		add			hl, de
		pop			bc
		add			a, '0'
		ld			[bc], a
		inc			bc
		ret
		endscope

; ------------------------------------------------------------------------------
s_tool_name::
		ds			"IPL-ROM Updater v1.02\r\n"
		ds			"==================================\r\n"
		ds			"Programmed by (C)2022-2025 HRA!\r\n"
		db			'$'

s_usage::
		ds			"Usage> IPLUPD <romimage.ipl>\r\n"
		db			'$'

s_not_ocm::
		ds			"This is not OCM.\r\n"
		db			'$'

s_type::
		ds			"OCM TYPE:\r\n $"

s_crlf::
		ds			"\r\n$"

s_unsupported::
		ds			"This type is not supported.\r\n"
		db			'$'

s_open_error::
		ds			"File open error.\r\n"
		db			'$'

s_read_error::
		ds			"File read error.\r\n"
		db			'$'

s_invalid_file_error::
		ds			"Invalid file error.\r\n"
		db			'$'

s_no_match_generation_error::
		ds			"No match generation error.\r\n"
		db			'$'

s_no_match_version_error::
		ds			"The version of OCM-PLD is out of date.\r\n"
		db			'$'

s_epcs_device_error::
		ds			"This is a non-compliant config ROM.\r\n"
		db			'$'

s_file_size::
		ds			"FILE SIZE: "
		db			'$'

s_bytes::
		ds			"BYTES\r\n"
		db			'$'

s_completed::
		ds			"Completed.\r\n"
		db			'$'

a_name_table::
		dw			s_1chipmsx					; ID 0
		dw			s_sx1						; ID 1
		dw			s_smx						; ID 2
		dw			s_sx2						; ID 3
		dw			s_smxmini					; ID 4
		dw			s_de0cv						; ID 5
		dw			s_sxe						; ID 6
		dw			s_unknown					; ID 7
		dw			s_unknown					; ID 8
		dw			s_unknown					; ID 9
		dw			s_unknown					; ID 10
		dw			s_unknown					; ID 11
		dw			s_unknown					; ID 12
		dw			s_unknown					; ID 13
		dw			s_unknown					; ID 14
		dw			s_unknown					; ID 15

s_1chipmsx::
		ds			"1chipMSX$"
s_sx1::
		ds			"Zemmix Neo, SX-1 or related$"
s_smx::
		ds			"SM-X or MC2P$"
s_sx2::
		ds			"SX-2$"
s_smxmini::
		ds			"SM-X Mini, SM-X HB or u2-SX$"
s_de0cv::
		ds			"DE0CV+DEOCM$"
s_sxe::
		ds			"SX-E or SX-Lite$"
s_unknown::
		ds			"Unknown$"
s_iplrom_signature::
		ds			"OCMPLD_IPLROM"				; 13 bytes
; ------------------------------------------------------------------------------
;	work area
file_name::
		space		128, 0
file_handle::
		db			0
file_size::
		dw			0
str_buffer::
		space		5, 0
		db			'$'
check_code::
		db			'1'
silicon_id::
		db			0
sector_number::
		db			IPLROM_1ST_GEN >> 16
vram_slot_id::
		db			0b1110_1111
backup_vdp_r1::
		db			0
