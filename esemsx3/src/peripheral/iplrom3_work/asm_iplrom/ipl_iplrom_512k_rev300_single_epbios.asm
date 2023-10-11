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

; ------------------------------------------------------------------------------
; IPL file header
		ds		"OCMPLD_IPLROM"					; Fixed signature
		db		'2'								; '1': 1st gen, '2': 2nd gen
		db		39								; Require version of OCM-PLD
		db		2								; Require revision of OCM-PLD

; ------------------------------------------------------------------------------
; IPL-ROM body
		binary_link "hex_iplrom_512k_rev300_single_epbios.bin"
