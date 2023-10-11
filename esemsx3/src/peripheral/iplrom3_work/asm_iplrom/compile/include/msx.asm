; =============================================================================
;	MSX definition header file
; -----------------------------------------------------------------------------
;	2019/07/03	t.hara	Coded in ZMA v1.0.15
; =============================================================================

; =============================================================================
;	I/O MAP
; =============================================================================
IO_VDP_PORT0_MSX1_ADP		:= 0x88
IO_VDP_PORT1_MSX1_ADP		:= 0x89
IO_VDP_PORT2_MSX1_ADP		:= 0x8A
IO_VDP_PORT3_MSX1_ADP		:= 0x8B
IO_VDP_PORT0				:= 0x98
IO_VDP_PORT1				:= 0x99
IO_VDP_PORT2				:= 0x9A
IO_VDP_PORT3				:= 0x9B

IO_PSG_ADR					:= 0xA0
IO_PSG_DATA_WR				:= 0xA1
IO_PSG_DATA_RD				:= 0xA2

IO_BASE_SLOT				:= 0xA8

IO_MEMMAP0					:= 0xFC
IO_MEMMAP1					:= 0xFD
IO_MEMMAP2					:= 0xFE
IO_MEMMAP3					:= 0xFF

; =============================================================================
;	BIOS (MAIN-ROM)
; =============================================================================

;	for BASIC
CHKRAM						:= 0x0000
SYNCHR						:= 0x0008
RDSLT						:= 0x000C
CHRGTR						:= 0x0010
WRSLT						:= 0x0014
OUTDO						:= 0x0018
CALSLT						:= 0x001C
DCOMPR						:= 0x0020
ENASLT						:= 0x0024
GETYPR						:= 0x0028
CALLF						:= 0x0030
KEYINT						:= 0x0038
INITIO						:= 0x003B
INIFNK						:= 0x003E

;	for VDP access
DISSCR						:= 0x0041
ENASCR						:= 0x0047
RDVRM						:= 0x004A
WRVRM						:= 0x004D
SETRD						:= 0x0050
SETWRT						:= 0x0053
FILVRM						:= 0x0056
LDIRMV						:= 0x0059
LDIRVM						:= 0x005C
CHGMOD						:= 0x005F
CHGCLR						:= 0x0062
NMI							:= 0x0066
CLRSPR						:= 0x0069
INITTXT						:= 0x006C
INIT32						:= 0x006F
INIGRP						:= 0x0072
INIMLT						:= 0x0075
SETTXT						:= 0x0078
SETT32						:= 0x007B
SETGRP						:= 0x007E
SETMLT						:= 0x0081
CALPAT						:= 0x0084
CALATR						:= 0x0087
GSPSIZ						:= 0x008A
GRPPRT						:= 0x008D

;	for PSG
GICINI						:= 0x0090
WRTPSG						:= 0x0093
RDPSG						:= 0x0096
STRTMS						:= 0x0099

;	for Keyboard, CRT, Printer

;	for GAME I/O access
GTSTICK						:= 0x00D5
GTTRIG						:= 0x00D8
GTPAD						:= 0x00DB
GRPDL						:= 0x00DE

;	for Disk access

;	PHYDIO
;	input)
;		A .... Physical Drive # (0:A, 1:B, ... , 7:H)
;		B .... Number of sectors
;		C .... Media ID (0xF8: 1DD-9SEC, 0xF9: 2DD-9SEC, 0xFA: 1DD-8SEC, 0xFB: 2DD-8SEC, 0xFC: 1D-9SEC, 0xFD: 2D-9SEC, 0xFE: 1D-8SEC, 0xFF: 2D-8SEC)
;		DE ... Target sector number
;		HL ... DRAM address
;		Cy ... 0:Read, 1:Write
;	output)
;		Cy ... 0:Success, 1:Failed
;		A .... Error code (when Cy is 1)
;		B .... Remain sectors (when Cy is 1)
;	break)
;		all
;
PHYDIO						:= 0x0144		; Unpublished routine

FORMAT						:= 0x0147
CHKDEV						:= 0x014A
PRINTC						:= 0x014D
KILBUF						:= 0x0156
CALBAS						:= 0x0159
SUBROM						:= 0x015C
EXTROM						:= 0x015F


; =============================================================================
;	SYSTEM WORK AREA
; =============================================================================

;	SUB-ROM SLOT
;	bit   7    6    5    4    3    2    1    0
;	    [ext][N/A][N/A][N/A][EXT.SLOT][BASESLOT]
;
EXBRSA						:= 0xFAF8

;	BASE SLOT EXTEND INFORMATION
;
EXPTBL0						:= 0xFCC1		; [ext][N/A][N/A][N/A][EXT.SLOT][BASESLOT]	MAIN-ROM slot
EXPTBL1						:= 0xFCC2		; [ext][N/A][N/A][N/A][N/A][N/A][N/A][N/A]	slot#1
EXPTBL2						:= 0xFCC3		; [ext][N/A][N/A][N/A][N/A][N/A][N/A][N/A]	slot#2
EXPTBL3						:= 0xFCC4		; [ext][N/A][N/A][N/A][N/A][N/A][N/A][N/A]	slot#3

;	MSX I/O INTERRUPT HOOK
H_KEYI						:= 0xFD9A

;	VSYNC INTERRUPT HOOK
;	59.94Hz in NTSC, 50Hz in PAL
;
H_TIMI						:= 0xFD9F

;	USER AREA TOP LIMIT ADDRESS
;
HIMEM						:= 0xFC4A

SCRMOD						:= 0xFCAF

;	VDP Registeter backup area
REG0SAV						:= 0xF3DF		; VDP R#0
REG1SAV						:= 0xF3E0		; VDP R#1
REG2SAV						:= 0xF3E1		; VDP R#2
REG3SAV						:= 0xF3E2		; VDP R#3
REG4SAV						:= 0xF3E3		; VDP R#4
REG5SAV						:= 0xF3E4		; VDP R#5
REG6SAV						:= 0xF3E5		; VDP R#6
REG7SAV						:= 0xF3E6		; VDP R#7
STATFL						:= 0xF3E7		; VDP S#0

FORCLR						:= 0xF3E9		; Fore ground color
BAKCLR						:= 0xF3EA		; Back ground color
BDRCLR						:= 0xF3EB		; Border color

REG8SAV						:= 0xFFE7		; VDP R#8
REG9SAV						:= 0xFFE8		; VDP R#9
REG10SAV					:= 0xFFE9		; VDP R#10
REG11SAV					:= 0xFFEA		; VDP R#11
REG12SAV					:= 0xFFEB		; VDP R#12
REG13SAV					:= 0xFFEC		; VDP R#13
REG14SAV					:= 0xFFED		; VDP R#14
REG15SAV					:= 0xFFEE		; VDP R#15
REG16SAV					:= 0xFFEF		; VDP R#16
REG17SAV					:= 0xFFF0		; VDP R#17
REG18SAV					:= 0xFFF1		; VDP R#18
REG19SAV					:= 0xFFF2		; VDP R#19
REG20SAV					:= 0xFFF3		; VDP R#20
REG21SAV					:= 0xFFF4		; VDP R#21
REG22SAV					:= 0xFFF5		; VDP R#22
REG23SAV					:= 0xFFF6		; VDP R#23

REG25SAV					:= 0xFFF8		; VDP R#25
REG26SAV					:= 0xFFF9		; VDP R#26
REG27SAV					:= 0xFFFA		; VDP R#27

;	Disk access
H_PHYD						:= 0xFFA7		; hook PHYDIO

; =============================================================================
;	BDOS
; =============================================================================
BDOS_ON_MSXDOS					:= 0x0005
BDOS_ON_DISKBASIC				:= 0xF37D

BDOS_FUNC_SYSTEM_RESET			:= 0x00
BDOS_FUNC_GETC					:= 0x01
BDOS_FUNC_PUTC					:= 0x02
BDOS_FUNC_DEV_GETC				:= 0x03
BDOS_FUNC_DEV_PUTC				:= 0x04
BDOS_FUNC_PRT_PUTC				:= 0x05
BDOS_FUNC_DIRECT_CON_IO			:= 0x06
BDOS_FUNC_DIRECT_CON_GETC		:= 0x07
BDOS_FUNC_DIRECT_CON_GETC_WOE	:= 0x08
BDOS_FUNC_STR_OUT				:= 0x09
BDOS_FUNC_BUF_LINE_INPUT		:= 0x0A
BDOS_FUNC_CON_STATUS			:= 0x0B

BDOS_FUNC_VERSION				:= 0x0C
BDOS_FUNC_DISK_RESET			:= 0x0D
BDOS_FUNC_SELECT_DISK			:= 0x0E

BDOS_FUNC_FCB_OPEN_FILE			:= 0x0F
BDOS_FUNC_FCB_CLOSE_FILE		:= 0x10
BDOS_FUNC_FCB_FIND_1ST			:= 0x11
BDOS_FUNC_FCB_FIND_NEXT			:= 0x12
BDOS_FUNC_FCB_DELETE_FILE		:= 0x13
BDOS_FUNC_FCB_SEQ_READ			:= 0x14
BDOS_FUNC_FCB_SEQ_WRITE			:= 0x15
BDOS_FUNC_FCB_CREATE_FILE		:= 0x16
BDOS_FUNC_FCB_RENAME_FILE		:= 0x17

BDOS_FUNC_GET_LOGIN_VECTOR		:= 0x18
BDOS_FUNC_GET_CURRENT_DRIVE		:= 0x19
BDOS_FUNC_SET_DTA				:= 0x1A
BDOS_FUNC_GET_ALLOC_INFO		:= 0x1B

BDOS_FUNC_RND_READ				:= 0x21
BDOS_FUNC_RND_WRITE				:= 0x22
BDOS_FUNC_GET_FILE_SIZE			:= 0x23
BDOS_FUNC_SET_RND_RECORD		:= 0x24

BDOS_FUNC_RND_BLOCK_WRITE		:= 0x26
BDOS_FUNC_RND_BLOCK_READ		:= 0x27
BDOS_FUNC_RND_WRITE_ZERO_FILL	:= 0x28

BDOS_FUNC_GET_DATE				:= 0x2A
BDOS_FUNC_SET_DATE				:= 0x2B
BDOS_FUNC_GET_TIME				:= 0x2C
BDOS_FUNC_SET_TIME				:= 0x2D
BDOS_FUNC_SET_VERIFY_FLAG		:= 0x2E

BDOS_FUNC_ABS_SECTOR_READ		:= 0x2F
BDOS_FUNC_ABS_SECTOR_WRITE		:= 0x30

; MSX-DOS2
BDOS_FUNC_GET_DISK_PARAM		:= 0x31

BDOS_FUNC_FIND_1ST				:= 0x40
BDOS_FUNC_FIND_NEXT				:= 0x41
BDOS_FUNC_FIND_NEW				:= 0x42

BDOS_FUNC_FILE_HANDLE_OPEN		:= 0x43
BDOS_FUNC_FILE_HANDLE_CREATE	:= 0x44
BDOS_FUNC_FILE_HANDLE_CLOSE		:= 0x45
BDOS_FUNC_FILE_HANDLE_ENSURE	:= 0x46
BDOS_FUNC_FILE_HANDLE_DUPLICATE	:= 0x47
BDOS_FUNC_FILE_HANDLE_READ		:= 0x48
BDOS_FUNC_FILE_HANDLE_WRITE		:= 0x49
BDOS_FUNC_MOVE_FILE_HANDLE_PTR	:= 0x4A
BDOS_FUNC_IO_CTRL				:= 0x4B
BDOS_FUNC_FILE_HANDLE_TEST		:= 0x4C


; under constructions ;-P


BDOS_FUNC_FORMAT_DISK			:= 0x67
BDOS_FUNC_RAM_DISK				:= 0x68
BDOS_FUNC_ALLOC_SECTOR_BUFFER	:= 0x69
BDOS_FUNC_LOGICAL_DRV_ASSIGN	:= 0x6A

BDOS_FUNC_GET_ENV_ITEM			:= 0x6B
BDOS_FUNC_SET_ENV_ITEM			:= 0x6C
BDOS_FUNC_FIND_ENV_ITEM			:= 0x6D

BDOS_FUNC_DISK_CHECK_STATUS		:= 0x6E
BDOS_FUNC_GET_MSXDOS_VERSION	:= 0x6F
BDOS_FUNC_REDIRECTION_STATUS	:= 0x70

; =============================================================================
;	DEFAULT VRAM MAP
; =============================================================================

;	screen 0 (width40)
SC0_W40_PAT_NAME			:= 0x0000
SC0_W40_PAT_GEN				:= 0x0800

;	screen 0 (width80)
SC0_W80_PAT_NAME			:= 0x0000
SC0_W80_BLINK				:= 0x0800
SC0_W80_PAT_GEN				:= 0x1000

;	screen 1
SC1_PAT_GEN					:= 0x0000
SC1_PAT_NAME				:= 0x1800
SC1_SPR_ATTR				:= 0x1B00
SC1_SPR_GEN					:= 0x3800

;	screen 2
SC2_PAT_GEN0				:= 0x0000
SC2_PAT_GEN1				:= 0x0800
SC2_PAT_GEN2				:= 0x1000
SC2_PAT_NAME				:= 0x1800
SC2_SPR_ATTR				:= 0x1B00
SC2_PAT_COL0				:= 0x2000
SC2_PAT_COL1				:= 0x2800
SC2_PAT_COL2				:= 0x3000
SC2_SPR_GEN					:= 0x3800

;	screen 3
SC3_PAT_GEN					:= 0x0000
SC3_PAT_NAME				:= 0x0800
SC3_SPR_ATTR				:= 0x1B00
SC3_SPR_GEN					:= 0x3800

;	screen 4
SC4_PAT_GEN0				:= 0x0000
SC4_PAT_GEN1				:= 0x0800
SC4_PAT_GEN2				:= 0x1000
SC4_PAT_NAME				:= 0x1800
SC4_SPR_COL					:= 0x1C00
SC4_SPR_ATTR				:= 0x1E00
SC4_PAT_COL0				:= 0x2000
SC4_PAT_COL1				:= 0x2800
SC4_PAT_COL2				:= 0x3000
SC4_SPR_GEN					:= 0x3800

;	screen 5
SC5_PAT_NAME				:= 0x0000
SC5_SPR_COL					:= 0x7400
SC5_SPR_ATTR				:= 0x7600
SC5_SPR_GEN					:= 0x7800

;	screen 6
SC6_PAT_NAME				:= 0x0000
SC6_SPR_COL					:= 0x7400
SC6_SPR_ATTR				:= 0x7600
SC6_SPR_GEN					:= 0x7800

; =============================================================================
;	VDP COMMAND
; =============================================================================
VDPCMD_HMMC					:= 0b1111_0000
VDPCMD_YMMM					:= 0b1110_0000
VDPCMD_HMMM					:= 0b1101_0000
VDPCMD_HMMV					:= 0b1100_0000
VDPCMD_LMMC					:= 0b1011_0000
VDPCMD_LMCM					:= 0b1010_0000
VDPCMD_LMMM					:= 0b1001_0000
VDPCMD_LMMV					:= 0b1000_0000
VDPCMD_LINE					:= 0b0111_0000
VDPCMD_SRCH					:= 0b0110_0000
VDPCMD_PSET					:= 0b0101_0000
VDPCMD_POINT				:= 0b0100_0000
VDPCMD_STOP					:= 0b0000_0000

VDPROP_IMP					:= 0x0000
VDPROP_AND					:= 0x0001
VDPROP_OR					:= 0x0010
VDPROP_EOR					:= 0x0011
VDPROP_NOT					:= 0x0100
VDPROP_TIMP					:= 0x1000
VDPROP_TAND					:= 0x1001
VDPROP_TOR					:= 0x1010
VDPROP_TEOR					:= 0x1011
VDPROP_TNOT					:= 0x1100

; =============================================================================
;	MACROs
; =============================================================================
ROM_HEADER					MACRO	init
								defs	"AB"			; ID
								defw	init			; INIT
								defw	0				; STATEMENT
								defw	0				; DEVICE
								defw	0				; TEXT
								defb	0,0,0,0,0,0		; RESERVE
							ENDM

BSAVE_HEADER				MACRO	saddr, eaddr, exec
								defb	0xFE
								defw	saddr
								defw	eaddr
								defw	exec
							ENDM

ROM_ALIGN					MACRO
								if FILE_ADDRESS % 16384
									defs	" " * (16384 - (FILE_ADDRESS % 16384))
								endif
							ENDM

USE_WAIT_VDP_COMMAND		MACRO	intr_ctrl
		message		"**********************************************************"
		message		" WAIT_VDP_COMMAND"
		message		" input)"
		message		"    none."
		message		" output)"
		message		"    none."
		message		" break)"
		message		"    A, B, C, F"
		message		" function)"
		message		"    VDPコマンドが稼働中であれば、完了するまで待機する。"
		if intr_ctrl
			message	"    内部で割り込み禁止・解除を行うので注意。"
		else
			message	"    割り込み禁止・解除は行わない。割り込み禁止状態で"
			message	"    呼ぶことが前提。"
		endif
		message		"**********************************************************"
		scope		sc_wait_vdp_command
		wait_vdp_command::
			ld			bc, ((0x80 | 15) << 8) | IO_VDP_PORT1
			ld			a, 2
			if intr_ctrl
				di
			endif
			out			[c], a
			out			[c], b
		polling_loop:
			in			a, [c]
			and			a, 1
			jp			nz, polling_loop
			out			[c], a
			out			[c], b
			if intr_ctrl
				ei
			endif
			ret
		endscope
	ENDM

USE_VDP_COMMAND		MACRO	intr_ctrl
		message		"**********************************************************"
		message		" VDP_COMMAND"
		message		" input)"
		message		"    HL ... R#32～46 にセットする内容を格納したテーブルのアドレス"
		message		" output)"
		message		"    none."
		message		" break)"
		message		"    A, B, C, H, L, F"
		message		" function)"
		message		"    VDPコマンドの待機は行わない。必要に応じて別途行うこと。"
		if intr_ctrl
			message	"    内部で割り込み禁止・解除を行うので注意。"
		else
			message	"    割り込み禁止・解除は行わない。割り込み禁止状態で"
			message	"    呼ぶことが前提。"
		endif
		message		"**********************************************************"
		scope		sc_vdp_command
		VDP_COMMAND::
			if intr_ctrl
				di
			endif
			ld			a, 32
			out			[IO_VDP_PORT1], a
			ld			a, 0x80 | 17
			out			[IO_VDP_PORT1], a
			ld			bc, (15 << 8) | IO_VDP_PORT3
			otir
			if intr_ctrl
				ei
			endif
			ret
		endscope
	ENDM
