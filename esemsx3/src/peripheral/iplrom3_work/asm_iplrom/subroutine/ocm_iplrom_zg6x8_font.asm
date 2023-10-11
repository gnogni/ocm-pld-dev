; ==============================================================================
;	IPL-ROM for OCM-PLD v3.9.1 or later
;	Font Data
; ------------------------------------------------------------------------------
; Copyright (c) 2020 Caro
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
;   Coded in ZMA v1.0.15
; ==============================================================================

font_data::
; 20h..3Fh
	db    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00	; SPACE
	db    0x00,0x20,0x20,0x20,0x20,0x00,0x20,0x00	; !
	db    0x00,0x48,0x48,0x00,0x00,0x00,0x00,0x00	; "
	db    0x00,0x00,0x50,0xF8,0x50,0xF8,0x50,0x00	; #
	db    0x00,0x20,0xF8,0xA0,0xF8,0x28,0xF8,0x20	; $
	db    0x00,0x00,0xC8,0xD0,0x20,0x58,0x98,0x00	; %
	db    0x00,0x40,0xA0,0x40,0xA8,0x90,0x68,0x00	; &
	db    0x00,0x20,0x40,0x00,0x00,0x00,0x00,0x00	; '
	db    0x00,0x08,0x10,0x10,0x10,0x10,0x08,0x00	; (
	db    0x00,0x40,0x20,0x20,0x20,0x20,0x40,0x00	; (
	db    0x00,0x00,0x50,0x20,0xF8,0x20,0x50,0x00	; *
	db    0x00,0x00,0x20,0x20,0xF8,0x20,0x20,0x00	; +
	db    0x00,0x00,0x00,0x00,0x00,0x20,0x20,0x40	; ,
	db    0x00,0x00,0x00,0x00,0xF8,0x00,0x00,0x00	; -
	db    0x00,0x00,0x00,0x00,0x00,0x60,0x60,0x00	; .
	db    0x00,0x00,0x08,0x10,0x20,0x40,0x80,0x00	; /
; 30h..3Fh
	db    0x00,0x70,0x98,0xA8,0xA8,0xC8,0x70,0x00	; 0
	db    0x00,0x20,0x60,0x20,0x20,0x20,0xF8,0x00	; 1
	db    0x00,0x70,0x88,0x08,0x70,0x80,0xF8,0x00	; 2
	db    0x00,0x70,0x88,0x30,0x08,0x88,0x70,0x00	; 3
	db    0x00,0x10,0x30,0x50,0x90,0xF8,0x10,0x00	; 4
	db    0x00,0xF8,0x80,0xF0,0x08,0x88,0x70,0x00	; 5
	db    0x00,0x70,0x80,0xF0,0x88,0x88,0x70,0x00	; 6
	db    0x00,0xF8,0x08,0x10,0x20,0x20,0x20,0x00	; 7
	db    0x00,0x70,0x88,0x70,0x88,0x88,0x70,0x00	; 8
	db    0x00,0x70,0x88,0x88,0x78,0x08,0x70,0x00	; 9
	db    0x00,0x00,0x20,0x00,0x00,0x20,0x00,0x00	; :
	db    0x00,0x00,0x20,0x00,0x00,0x20,0x20,0x40	; ;
	db    0x00,0x00,0x10,0x20,0x40,0x20,0x10,0x00	; <
	db    0x00,0x00,0x00,0x78,0x00,0x78,0x00,0x00	; =
	db    0x00,0x00,0x20,0x10,0x08,0x10,0x20,0x00	; >
	db    0x00,0x70,0x88,0x10,0x20,0x00,0x20,0x00	; ?
; 40h..4Fh
	db    0x00,0x70,0xA8,0xA8,0xB0,0x80,0x78,0x00	; @
	db    0x00,0x78,0x88,0x88,0xF8,0x88,0x88,0x00	; A
	db    0x00,0xF0,0x88,0xF0,0x88,0x88,0xF0,0x00	; B
	db    0x00,0x70,0x88,0x80,0x80,0x88,0x70,0x00	; C
	db    0x00,0xE0,0x90,0x88,0x88,0x88,0xF0,0x00	; D
	db    0x00,0xF8,0x80,0xF0,0x80,0x80,0xF8,0x00	; E
	db    0x00,0xF8,0x80,0xF0,0x80,0x80,0x80,0x00	; F
	db    0x00,0x70,0x88,0x80,0xB8,0x88,0x70,0x00	; G
	db    0x00,0x88,0x88,0xF8,0x88,0x88,0x88,0x00	; H
	db    0x00,0xF8,0x20,0x20,0x20,0x20,0xF8,0x00	; I
	db    0x00,0x08,0x08,0x08,0x88,0x88,0x70,0x00	; J
	db    0x00,0x90,0xA0,0xC0,0xA0,0x90,0x88,0x00	; K
	db    0x00,0x80,0x80,0x80,0x80,0x80,0xF8,0x00	; L
	db    0x00,0x88,0xD8,0xA8,0xA8,0x88,0x88,0x00	; M
	db    0x00,0x88,0x88,0xC8,0xA8,0x98,0x88,0x00	; N
	db    0x00,0x70,0x88,0x88,0x88,0x88,0x70,0x00	; O
; 50h..5Fh
	db    0x00,0xF0,0x88,0x88,0xF0,0x80,0x80,0x00	; P
	db    0x00,0x70,0x88,0x88,0x88,0xA8,0x70,0x10	; Q
	db    0x00,0xF0,0x88,0x88,0xF0,0x90,0x88,0x00	; R
	db    0x00,0x70,0x80,0x70,0x08,0x88,0x70,0x00	; S
	db    0x00,0xF8,0x20,0x20,0x20,0x20,0x20,0x00	; T
	db    0x00,0x88,0x88,0x88,0x88,0x88,0x70,0x00	; U
	db    0x00,0x88,0x88,0x88,0x88,0x50,0x20,0x00	; V
	db    0x00,0x88,0x88,0x88,0xA8,0xA8,0x50,0x00	; W
	db    0x00,0x88,0x50,0x20,0x20,0x50,0x88,0x00	; X
	db    0x00,0x88,0x88,0x50,0x20,0x20,0x20,0x00	; Y
	db    0x00,0xF8,0x90,0x20,0x40,0x88,0xF8,0x00	; Z
	db    0x00,0x70,0x40,0x40,0x40,0x40,0x70,0x00	; [
	db    0x00,0x00,0x80,0x40,0x20,0x10,0x08,0x00	; \
	db    0x00,0x70,0x10,0x10,0x10,0x10,0x70,0x00	; ]
	db    0x00,0x20,0x50,0x88,0x00,0x00,0x00,0x00	; ^
	db    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xFC	; _
; 60h..6Fh
	db    0x00,0x40,0x40,0x20,0x00,0x00,0x00,0x00	; `
	db    0x00,0x00,0x70,0x08,0x78,0x88,0x78,0x00	; a
	db    0x00,0x80,0x80,0xF0,0x88,0x88,0xF0,0x00	; b
	db    0x00,0x00,0x70,0x88,0x80,0x80,0x78,0x00	; c
	db    0x00,0x08,0x08,0x78,0x88,0x88,0x78,0x00	; d
	db    0x00,0x00,0x70,0x88,0xF0,0x80,0x78,0x00	; e
	db    0x00,0x18,0x20,0x30,0x20,0x20,0x20,0x00	; f
	db    0x00,0x00,0x78,0x88,0x88,0x78,0x08,0x70	; g
	db    0x00,0x80,0x80,0xF0,0x88,0x88,0x88,0x00	; h
	db    0x00,0x20,0x00,0x60,0x20,0x20,0x70,0x00	; i
	db    0x00,0x08,0x00,0x08,0x08,0x08,0x48,0x30	; j
	db    0x00,0x40,0x50,0x60,0x60,0x50,0x48,0x00	; k
	db    0x00,0x20,0x20,0x20,0x20,0x20,0x18,0x00	; l
	db    0x00,0x00,0xD0,0xA8,0xA8,0xA8,0xA8,0x00	; m
	db    0x00,0x00,0xF0,0x88,0x88,0x88,0x88,0x00	; n
	db    0x00,0x00,0x70,0x88,0x88,0x88,0x70,0x00	; o
; 70h..7Fh
	db    0x00,0x00,0xF0,0x88,0x88,0xF0,0x80,0x80	; p
	db    0x00,0x00,0x70,0x90,0x90,0x70,0x10,0x18	; q
	db    0x00,0x00,0x38,0x40,0x40,0x40,0x40,0x00	; r
	db    0x00,0x00,0x70,0x80,0x70,0x08,0xF0,0x00	; s
	db    0x00,0x20,0x70,0x20,0x20,0x20,0x18,0x00	; t
	db    0x00,0x00,0x88,0x88,0x88,0x88,0x70,0x00	; u
	db    0x00,0x00,0x88,0x88,0x50,0x50,0x20,0x00	; v
	db    0x00,0x00,0x88,0xA8,0xA8,0xA8,0x50,0x00	; w
	db    0x00,0x00,0x88,0x50,0x20,0x50,0x88,0x00	; x
	db    0x00,0x00,0x88,0x88,0x88,0x78,0x08,0x70	; y
	db    0x00,0x00,0xF8,0x10,0x20,0x40,0xF8,0x00	; z
	db    0x00,0x38,0x20,0xC0,0x20,0x20,0x38,0x00	; {
	db    0x00,0x20,0x20,0x20,0x20,0x20,0x20,0x00	; |
	db    0x00,0xE0,0x20,0x18,0x20,0x20,0xE0,0x00	; }
	db    0x00,0x28,0x50,0x00,0x00,0x00,0x00,0x00	; ~
	db    0x30,0x48,0xB4,0xC4,0xC4,0xB4,0x48,0x30	; DEL
