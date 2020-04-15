; These are EQUates / global declaractions for the VIDEO.ASM module.

; Author: David Bennett - Version 1.0 - Date: 11/9/88
;
; Please see the file VIDEO.DOC for more info.  VIDDEMO.ASM has examples
; of how to use this include file in your programs.
;
;v1.1, Toad Hall Tweak, 22 Dec 88
; -	Removed global definitions.
; -	Suitable for VIDDEMO1.ASM, VIDDEMO2.ASM, VIDEO1.ASM, VIDEO2.ASM

; ---------------------
; Various video equates
; ---------------------

; Memory areas

MONOSEG		EQU	0B000h		; Mono screen segment
CGASEG		EQU	0B800h		; CGA screen segment

; Video Modes

BW40		EQU	0		; 40x25 B/W on Color Adapter
CO40		EQU	1		; 40x25 Color on Color Adapter
BW80		EQU	2		; 80x25 B/W on Color Adapter
CO80		EQU	3		; 80x25 Color on Color Adapter
MONO		EQU	7		; 80x25 on Monochrome Adapter

; Foreground / Background color constants

BLACK		EQU	0
BLUE		EQU	1
GREEN		EQU	2
CYAN		EQU	3
RED		EQU	4
MAGENTA		EQU	5
BROWN		EQU	6
LIGHTGRAY	EQU	7

; Foreground color constants

DARKGRAY	EQU	8
LIGHTBLUE	EQU	9
LIGHTGREEN	EQU	10
LIGHTCYAN	EQU	11
LIGHTRED	EQU	12
LIGHTMAGENTA	EQU	13
YELLOW		EQU	14
WHITE		EQU	15

; Add this for blink

BLINK		EQU	10000000b	; Blink Bit
UNDERLINE	EQU	00000001b	; Underline Bit (Mono Only)

; Some commonly used attributes

NORMAL		EQU	7	; Gray on Black (Low Intensity)
REVERSE		EQU	112	; Black on Gray
HIGHINT		EQU	15	; White on Black (High Intensity)
