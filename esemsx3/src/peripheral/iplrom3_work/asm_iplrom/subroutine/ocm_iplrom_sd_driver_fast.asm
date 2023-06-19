; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	SD-Card Driver
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
;   2022/Oct/22nd  t.hara  Overall revision.
; ==============================================================================

; --------------------------------------------------------------------
;	SD Card Command
; --------------------------------------------------------------------
SDCMD_GO_IDLE_STATE				:= 0
SDCMD_SEND_IO_COND				:= 1
SDCMD_SEND_IF_COND				:= 8
SDCMD_SEND_CSD					:= 9
SDCMD_SEND_CID					:= 10
SDCMD_SEND_STATUS				:= 13
SDCMD_SEND_BKICKLEN				:= 16
SDCMD_READ_SINGLE_BLK			:= 17
SDCMD_WRITE_BLOCK				:= 24
SDCMD_PROGRAM_CSD				:= 27
SDCMD_SET_WRITE_PROT			:= 28
SDCMD_CLR_WRITE_PROT			:= 29
SDCMD_SEND_WRITE_PROT			:= 30
SDCMD_TAG_SECT_START			:= 32
SDCMD_TAG_SECT_END				:= 33
SDCMD_UNTAG_SECTOR				:= 34
SDCMD_TAG_ERASE_G_SEL			:= 35
SDCMD_TAG_ERASE_G_END			:= 36
SDCMD_UNTAG_ERASE_GRP			:= 37
SDCMD_ERASE						:= 38
SDCMD_CRC_ON_OFF				:= 39
SDCMD_LOCK_UNLOCK				:= 42
SDCMD_APP_CMD					:= 55
SDCMD_READ_OCR					:= 58

SDACMD_SET_WR_BLOCK_ERASE_COUNT	:= 23
SDACMD_APP_SEND_OP_COND			:= 41

; --------------------------------------------------------------------
;	SD card type
; --------------------------------------------------------------------
TYPE_UNKNOWN					:= 0
TYPE_MMC						:= 1
TYPE_SDSC						:= 2
TYPE_SDHC						:= 3

; --------------------------------------------------------------------
;	Master Boot Record Offset
; --------------------------------------------------------------------
mbr_boot_strap_loader			:= 0
mbr_1st_partition				:= 0x01BE
mbr_2nd_partition				:= 0x01CE
mbr_3rd_partition				:= 0x01DE
mbr_4th_partition				:= 0x01EE
mbr_boot_signature				:= 0x01FE

mbr_partition_boot_flag			:= 0		; 1byte
mbr_partition_chs_begin_sector	:= 1		; 3bytes
mbr_partition_type				:= 4		; 1byte
mbr_partition_chs_end_sector	:= 5		; 3bytes
mbr_partition_lba_begin_sector	:= 8		; 4bytes
mbr_partition_total_sectors		:= 12		; 4bytes

; --------------------------------------------------------------------
;	Partition Boot Record Offset
; --------------------------------------------------------------------
pbr_jump_instruction			:= 0x0000	; 3bytes
pbr_oem_name					:= 0x0003	; 8bytes
pbr_bios_parameter_block		:= 0x000B	; 25bytes
	pbr_bytes_per_sector		:= 0x000B	;   2bytes
	pbr_sectors_per_cluster		:= 0x000D	;   1byte
	pbr_reserved_sectors		:= 0x000E	;   2bytes
	pbr_num_of_fat				:= 0x0010	;   1byte
	pbr_root_entries			:= 0x0011	;   2bytes
	pbr_small_sector			:= 0x0013	;   2bytes
	pbr_media_type				:= 0x0015	;   1byte
	pbr_sectors_per_fat			:= 0x0016	;   2bytes
	pbr_sectors_per_track		:= 0x0018	;   2bytes
	pbr_number_of_heads			:= 0x001A	;   2bytes
pbr_extend_bios_parameter_block	:= 0x001C	; 26bytes
pbr_bootstrap_code				:= 0x003E	; 448bytes
pbr_signature					:= 0x01FE	; 2bytes

card_type						:= 0xFFCF	; 1byte: 2: MMC/SDSC, 3: SDHC

; --------------------------------------------------------------------
;	MMC/SDSC/SDHC command
;	input)
; --------------------------------------------------------------------
		scope	set_sd_command
set_sd_command::
		ld		a, [card_type]		;	Card type
		cp		a, TYPE_SDHC
		jr		c, set_sd_mmc

		;	for SDHC
set_sdhc:
		ld		a, [hl]
		ld		[hl], b				;	set command code
		ld		[hl], 0
		ld		[hl], c
		ld		[hl], d
		ld		[hl], e
		jr		set_src95

		;	for SD/MMC
set_sd_mmc:
		sla		e					;	convert 'number of sector' to 'number of byte'
		rl		d					;	cde = cde * 2
		rl		c
send_command::
		ld		a, [hl]
		ld		[hl], b				;	set command code
		ld		[hl], c
		ld		[hl], d
		ld		[hl], e
		ld		[hl], 0

set_src95:
		ld		[hl], 0x95			;	CRC

		ld		b, 16				;	retry count = 16
receive_response::
		ld		a, [hl]
wait_command_accept:
		ld		a, [hl]				;	receive R1 response
		cp		a, 0xFF
		ccf
		ret		nc					;	no error, and return R1 response
		djnz	wait_command_accept	;	no flag change
		ret							;	Cy = 1
		endscope

; --------------------------------------------------------------------
;	Initialize SD card
;	input)
;		none
;	output)
;		HL .... mega_sd_register
;		Cy .... 1: error, 0: others
;		Zf .... 0: error, 0: others
; --------------------------------------------------------------------
		scope	sd_initialize
send_cmd0:
		;	"/CS=1, DI=1" is input for a period of 74 clocks or more.
		;	"/CS=1, DI=1" の状態で 74clock 以上クロックを投入する.
		ld		b, 10
	wait_cs:
		ld		a, [ megasd_sd_register | (1 << 12) ]	;	/CS = 1 (bit12)
		djnz	wait_cs									; B = 0

		;	send SDCMD_GO_IDLE_STATE (CMD0)
		ld		a, [hl]								; dummy read
		ld		[hl], 0x40 | SDCMD_GO_IDLE_STATE	; CMD0 command
		ld		[hl], b								; CMD0 parameter 1st
		ld		[hl], b								; CMD0 parameter 2nd
		ld		[hl], b								; CMD0 parameter 3rd
		ld		[hl], b								; CMD0 parameter 4th
		ld		[hl], 0x95							; CMD0 CRC
		ret

sd_initialize::
		ld		a, 0x40
		ld		[eseram8k_bank0], a					; BANK 40h

		;	ブロックリードの途中でリセットされた場合、/CS=1にしてもブロックリード状態が維持されるカードがある
		;	その場合、CMD0等の各コマンドを正常に処理できないので、まずは 1ブロック分空読みして読み捨てる。
		xor		a, a								; High speed and data enable mode
		ld		[megasd_mode_register], a
		ld		b, a
		ld		hl, megasd_sd_register				;	/CS = 0 (bit12)
	dummy_read1:
		cp		a, [hl]								; read 256bytes
		djnz	dummy_read1
	dummy_read2:
		cp		a, [hl]								; read 256bytes
		djnz	dummy_read2

		;	"/CS=1,DI=1"
		xor		a, a								; High speed and data enable mode
		ld		[megasd_mode_register], a

		; dummy send (If there is a command halfway through before reset, this command can force termination.)
		; Result signal may not return properly. The result signal is not acquired.
		call	send_cmd0
		; The original CMD0 is issued again.
		; This one checks the result signal.
		call	send_cmd0
		; Result signal check on CMD0
		ld		b, 16
	get_r1_wait:
		ld		a, [hl]								; read R1
		cp		a, 0xFF
		jr		c, skip
		djnz	get_r1_wait
		scf
		ret											; error
	skip:

		;	Check R1 Response
		and		a, 0xF3
		sub		a, 0x01								;	bit0 - in idle state?
		ret		nz									;	error (SD is not idle state when bit0 is zero.)

		ld		[card_type], a

		; ---------------------------------------------------------------------
		; CMD8 (Voltage Check Command)
		;   bit 47 46 45-40 39-22 21   20   19-16 15-08   07-01 00
		;       S  D  Index Resv. PCIe PCIe VHS   Pattern CRC7  E
		;
		; Response (Format R7)
		;   bit 39-32 31-28 27-12 11-08 07-00
		;       R1    Ver.  Resv. Vacc. pattern
		;
		;  Vacc. ... Voltage accepted
		;            0000b  Not defined
		;            0001b  2.7 ... 3.6V
		;            0010b  Reserved for Low Voltage Range
		;            0100b  Reserved
		;            1000b  Reserved
		;            Others Not defined
		; ---------------------------------------------------------------------
		cp		a, [hl]
		ld		[hl], 0x40 | SDCMD_SEND_IF_COND
		ld		[hl], a
		ld		[hl], a
		ld		[hl], 0x01					; VHS = 2.7 ... 3.6V
		ld		[hl], 0xAA					; Pattern
		ld		[hl], 0x87					; CRC7, E
		ld		b, 16						; retry count
		call	receive_response
		ret		c							; error
		dec		a
		jr		nz, check_sd1				; Not SD version 2, go to check SD version 1.

		ld		a, [hl]						; R7 bit31-24
		ld		a, [hl]						; R7 bit23-16
		ld		a, [hl]						; R7 bit15-08
		and		a, 0x0F						; A = R7 bit11-08 = Voltage accepted
		dec		a							; 1 = 2.7 ... 3.6V
		ld		a, [hl]						; R7 bit07-00
		ret		nz							; error when mismatch
		cp		a, 0xAA						; Check pattern
		ret		nz							; error when mismatch

		; Try initialize SDHC card.
		;
		; ---------------------------------------------------------------------
		; ACMD41
		;   bit 47 46 45-40  39   38  37 36  35   34-33 32   31-16 15-08 07-01 00
		;       S  D  Index  Busy HCS FB XPC HO2T Rsv.  S18R OCR   Resv. CRC7  E
		;       0  1  101001 0    X   0  X   X    00    X    XX    00    XX    1
		;
		;  { HCS, HO2T }
		;    00b : SDSC Supported Host
		;    10b : SDHC/SDXC Supported Host
		;    11b :   Over 2TB Supported Host
		;    01b : N/A
		;
		; Send SDACMD_APP_SEND_OP_COND(ACMD41). Initialize connection for SDHC.
		; SDカードに対して SDACMD_APP_SEND_OP_COND(ACMD41), { HCS, HO2T } = 10b で接続初期化を指示。
retry_acmd41_v2:
		ld		bc, ((0x40 | SDCMD_APP_CMD) << 8) | 0x00
		call	send_command
		ret		c							;	error
		dec		a
		ret		nz							;	error

		ld		bc, ((0x40 | SDACMD_APP_SEND_OP_COND) << 8) | 0x40
		call	send_command
		ret		c							;	error
		and		a, 1
		jr		nz, retry_acmd41_v2

		; ---------------------------------------------------------------------
		; CMD58
		;   bit 47 46 45-40  39  38-35 34  33-17 16-08 07-01 00
		;       S  D  Index  MIO FNO   BUS ADDR  BUC   CRC7  E
		;       0  1  111010 X   XX    X   17bit XX    XX    1
		;
		;   MIO (Memory or I/O)
		;     0: Memory Extension
		;     1: I/O Extension
		;
		;  FNO (Function No.)
		;
		;  BUS (Block Unit Select)
		;     0: 512 Bytes
		;     1: 32768 Bytes
		;
		;  BUC (Block Unit Count)
		;     0: 1 unit
		;     1: 2 units
		;       :
		;
		;  After initialization is completed, the host should get CCS information in the response of CMD58.
		;  CCS is valid when the card accepted CMD8 and after the completion of initialization.
		;  CCS=0 means that the card is SDSC. CCS=1 means that the card is SDHC or SDXC.
		;
		; Send SDCMD_READ_OCR(CMD58). And receive OCR datas.
		; SDカードに対して SDCMD_READ_OCR(CMD58) を送信して OCRデータを読み取る。
		ld		bc, ((0x40 | SDCMD_READ_OCR) << 8) | 0x00		; READ_OCR
		call	send_command				;	Send command and receive R1
		jr		c, check_mmc				;	go to check MMC card, when error

		ld		a, [hl]						;	receive OCR 1st (bit31-24)
		cp		a, [hl]						;	receive OCR 2nd (bit23-16)
		cp		a, [hl]						;	receive OCR 3rd (bit15-08)
		cp		a, [hl]						;	receive OCR 4th (bit07-00)
		bit		6, a						;	check CCS bit (bit6 on OCR 1st)
		ld		a, TYPE_SDSC
		jr		z, is_byte_access
		inc		a							;	TYPE_SDHC
is_byte_access:
		ld		[card_type], a
		xor		a, a
		ret									;	success (Cy = 0, Z = 1)

check_sd1:
		; Send SDACMD_APP_SEND_OP_COND(ACMD41). Initialize connection for SDHC.
		; SDカードに対して SDACMD_APP_SEND_OP_COND(ACMD41), { HCS, HO2T } = 00b で接続初期化を指示。
retry_acmd41_v1:
		ld		bc, ((0x40 | SDCMD_APP_CMD) << 8) | 0x00
		call	send_command
		jr		c, check_mmc				;	go to check MMC, when error
		dec		a
		jr		nz, check_mmc				;	go to check MMC, when error

		ld		bc, ((0x40 | SDACMD_APP_SEND_OP_COND) << 8) | 0x00
		call	send_command
		jr		c, check_mmc				;	go to check MMC, when error
		and		a, 1
		jr		nz, retry_acmd41_v1
		ld		a, TYPE_SDSC
		ld		[card_type], a
		ret									;	success (Cy = 0, Z = 1)

check_mmc:
		; Send SDCMD_SEND_IO_COND(CMD1). Initialize connection for MMC.
		; SDカードに対して SDCMD_SEND_IO_COND(CMD1) で接続初期化を指示。
retry_cmd1:
		ld		bc, ((0x40 | SDCMD_SEND_IO_COND) << 8) | 0x00
		call	send_command				;	Send command and receive R1
		ret		c							; if Cy = 1 then error
		bit		2, a
		ret		nz							; if bit2 on R1 then error
		and		a, 1
		jr		nz, retry_cmd1
		ld		a, TYPE_MMC
		ld		[card_type], a
		ret
		endscope

; --------------------------------------------------------------------
;	Read sectors from MMC/SDSC/SDHC card
;	input)
;		B   = number of sectors
;		HL  = read buffer
;		CDE = sector number
; --------------------------------------------------------------------
		scope	sd_read_sector
timeout:
		pop		bc
		pop		de
		scf
		ret							;	timeout error
retry_init:
		call	sd_initialize
		pop		bc
		pop		de
		pop		hl
		ret		c					;	initialize error
		scf
		ret		nz					;	initialize error

sd_read_sector::
		push	hl
		push	de
		push	bc

		ld		b, 0x40 + SDCMD_READ_SINGLE_BLK
		ld		hl, megasd_sd_register
		call	set_sd_command
		jr		c, retry_init

		pop		bc
		pop		de
		pop		hl
		or		a, a
		scf
		ret		nz					;	error

		push	de
		push	bc
		ex		de, hl
		ld		hl, megasd_sd_register
		ld		b, h				;	BC = 0x4000
		ld		c, l
read_wait:
		dec		bc
		ld		a, c
		or		a, b
		jr		z, timeout
		ld		a, [hl]
		cp		a, 0xFE
		jr		nz, read_wait

		ld		bc, 0x0200			;	512bytes
		ldir						;	read sector
		ex		de, hl
		ld		a, [de]
		pop		bc
		ld		a, [de]
		pop		de
		inc		de
		ld		a, d
		or		a, e

		jr		nz, skip

		inc		c
skip:
		djnz	sd_read_sector		;	next sector

		ret
		endscope
