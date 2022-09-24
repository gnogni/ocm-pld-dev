; =============================================================================
;	Z80 Utility
; -----------------------------------------------------------------------------
;	2019/07/04	t.hara
; =============================================================================

; =============================================================================
;	RL16	{BC|DE|HL}
;
;	左ビットローテイト。bit0 には CF の値が、CF にははみ出した bit15 が格納される。
; =============================================================================
RL16	macro	@reg16
			if		reg16 == "BC"
				RL		C
				RL		B
			elseif	reg16 == "DE"
				RL		E
				RL		D
			elseif	reg16 == "HL"
				RL		L
				RL		H
			else
				error	"Unsupported argument \" + reg16 + "\" in RL16 macro."
			endif
		endm

; =============================================================================
;	RR16	{BC|DE|HL}
;
;	右ビットローテイト。bit15 には CF の値が、CF にははみ出した bit0 が格納される。
; =============================================================================
RR16	macro	@reg16
			if		reg16 == "BC"
				RR		B
				RR		C
			elseif	reg16 == "DE"
				RR		D
				RR		E
			elseif	reg16 == "HL"
				RR		H
				RR		L
			else
				error	"Unsupported argument \" + reg16 + "\" in RR16 macro."
			endif
		endm

; =============================================================================
;	SLA16	{BC|DE|HL}
;
;	算術1bit左シフト。bit0 は 0 になる。
; =============================================================================
SLA16	macro	@reg16
			if		reg16 == "BC"
				SLA		C
				RL		B
			elseif	reg16 == "DE"
				SLA		E
				RL		D
			elseif	reg16 == "HL"
				SLA		L
				RL		H
			else
				error	"Unsupported argument \" + reg16 + "\" in SLA16 macro."
			endif
		endm

; =============================================================================
;	SRA16	{BC|DE|HL}
;
;	算術1bit右シフト。bit15 は変化無し。
; =============================================================================
SRA16	macro	@reg16
			if		reg16 == "BC"
				SRA		B
				RR		C
			elseif	reg16 == "DE"
				SRA		D
				RR		E
			elseif	reg16 == "HL"
				SRA		H
				RR		L
			else
				error	"Unsupported argument \" + reg16 + "\" in SRA16 macro."
			endif
		endm

; =============================================================================
;	SRL16	{BC|DE|HL}
;
;	論理1bit右シフト。bit15 は 0 になる。
; =============================================================================
SRL16	macro	@reg16
			if		reg16 == "BC"
				SRL		B
				RR		C
			elseif	reg16 == "DE"
				SRL		D
				RR		E
			elseif	reg16 == "HL"
				SRL		H
				RR		L
			else
				error	"Unsupported argument \" + reg16 + "\" in SRL16 macro."
			endif
		endm

; =============================================================================
;	BYTE_ALIGN	align
;
;	アドレスが align で示される数値の倍数 になるまでパディングする
; =============================================================================
BYTE_ALIGN	MACRO	align
			if FILE_ADDRESS % align
				defs	" " * (align - (FILE_ADDRESS % align))
			endif
		endm
