TITLE 'Video Demo Program'

;
; This is a short program to demonstrate the VIDEO.ASM TASM Assembler module.
; You may use VIDDEMO.MAK to automate the assembly of this program.  It is
; only designed to work in a 80x25 mode. (Video Modes 2, 3, & 7)
;
; All lines that make use of VIDEO.ASM routines or VIDEO.INC equates have
; been marked with ($) so you can scan through this file and see how to
; use the routine fairly easily.
;
; -- Dave
;v1.2
; -	Designed to use VIDEO2.OBJ (with LINK).
;	MASM VIDDEMO2;			Produces VIDDEMO2.OBJ
;	MASM VIDEO2;			Produces VIDEO2.OBJ
;	LINK VIDDEMO2 VIDEO2;		Produces VIDDEMO2.EXE
;	EXE2COM VIDDEMO2		Produces VIDDEMO2.COM
;	Delete all the junk .OBJ, .EXE files.
;
; -	Still a .COM file (no separate Data, Stack segs).

;v1.1, 22 Dec 88  Toad Hall Tweak
; -	Rewritten for MASM (early versions, tho tested with v5.0)
; -	Rewritten for .COM file format rather than .EXE
; -	Reformatted to more conventional assembler source format.
; -	Slightly tightened and tweaked.
; -	VIDEO1.ASM and VIDEO1.INC are now INCLUDEd files.
;	No more separate compilation.
; -	No significant functional changes.
;David Kirschbaum
;Toad Hall
;kirsch@braggvax.ARPA

	INCLUDE VIDEO1.INC	; Global declarations for VIDEO1.ASM

; ------
; Macros
; ------

Pause	MACRO	seconds
	LOCAL PauseLoop, KeyFound
;
; This macro will pause until a key is pressed.
;
; Uses:
;	KeyPressed, ClearKBD
;
	push	ax		; Save regs
	push	cx
IFNB <Seconds>
	mov	cx, (Seconds*18)+(Seconds/5)	; 5 is recip of .2!
ELSE
	mov	cx, 91		; 5 Seconds
ENDIF
PauseLoop:
	call	KeyPressed	; check for pressed key
	or	al, al		; Sets the zero flag if null
	jnz	KeyFound	; loop until key is pressed
	 call	Delay		; Delay for .055 of a second
	 loop	PauseLoop
KeyFound:
	call	ClearKBD	; Clear the key
	pop	cx		; Restore registers
	pop	ax
ENDM

; ---------------
; Program Equates
; ---------------

VERSION		EQU	'1.1'
DATE		EQU	'12/22/88'

MAXROWS		EQU	25		; Maximum rows
CENTERROW	EQU	(MAXROWS/2)	; Center row
MAXCOLS		EQU	80		; Maximum columns
CENTERCOL	EQU	(MAXCOLS/2)	; Center column
FILLROWS	EQU	5		; Number of rows for fill demo
FILLCOLS	EQU	20		; Number of cols for fill demo

; -------------
; Stack Segment
; -------------
;v1.1 no stack segment, making this a .COM file
;STACK	7FFFh		; 32k Stack (Much more than enough)

CSeg	SEGMENT PUBLIC PARA 'CODE'
	ASSUME	CS:CSeg, DS:CSeg, ES:CSeg, SS:CSeg
	org	100H

VidDemo2	proc	near
	jmp	Start		;jump over demo data			v1.1

;Externals in VIDEO2.OBJ

	EXTRN	MoveXY_DI: NEAR,	MoveXY_SI: NEAR
	EXTRN	EGAInstalled: NEAR,	GetVideoMode: NEAR
	EXTRN	DWriteCh: NEAR,		DWriteChNA: NEAR
	EXTRN	DWriteStr: NEAR,	DWriteStrNA: NEAR
	EXTRN	DFillCh: NEAR,		DFillChNA: NEAR
	EXTRN	DFillAttr: NEAR,	StoreToMem: NEAR
	EXTRN	StoreToScr: NEAR,	CursorOff: NEAR
	EXTRN	CursorOn: NEAR

	EXTRN	baseOfScreen : WORD
	EXTRN	snowcheck: BYTE,	videomode: BYTE

; NOTE: Program relies on data being in current order.  Do not reorder, delete
;	or insert new data into the list.  Data can be appended to this segment
;	definition.

;DATASEG

Title1		DB 'VIDEO.ASM - Direct Screen Writing Routines', 0
T1LEN		EQU	$-Title1

Title2		DB 'Author: Dave Bennett / CompuServe 74635,1671', 0
T2LEN		EQU	$-Title2

Title3		DB 'Version ', VERSION, ' - Date: ', DATE, 0
T3LEN		EQU	$-Title3

Title4		DB 'Features:', 0
Title5		DB ' - Video mode detection', 0
Title6		DB ' - Monochrome/CGA/EGA support', 0
Title7		DB ' - Snow suppression', 0
Title8		DB ' - Direct character & string writing', 0
Title9		DB ' - Screen saving & restoring', 0
Title10		DB ' - Area fills (character, attribute, and both)', 0
Title11		DB ' - Cursor on & off control', 0
Title12		DB ' - All commands w/ or w/o attribute changes',0

Msg		DB 'Direct Screen Writing is Fast!!!', 0
MSGLEN		EQU	$-Msg

SaveMsg		DB ' Screen has been saved... ', 0
SMSGLEN		EQU	$-SaveMsg

CharMsg1	DB ' Character ', 0
CharMsg2	DB ' Writing!! ', 0

Wheel		DB 179, '/-\', 179, '/-\'  ; Wheel Chars
MAXWHEEL	EQU	$-Wheel		; Maximum Wheel offset

FillMsg1	DB '-AREA-', 0
FillMsg2	DB '-FILL-', 0

RestoreMsg	DB ' Here''s your saved screen image! ', 0
RMSGLEN		EQU	$-RestoreMsg

VidModErr	DB 'Invalid Video Mode!', 0Dh, 0Ah, '$'

RDir		DB 0			; Row Direction
CDir		DB 0			; Col Direction

VidDemo2	endp


Start	proc	near		;v1.1
	call	GetVideoMode	; Get vid mode data.  MUST BE CALLED FIRST ($)

	cmp	VideoMode, BW80		; ($)
	je	VideoMode_OK		; Video Mode BW80 is ok
	cmp	VideoMode, CO80		; ($)
	je	VideoMode_OK		; Video Mode CO80 is ok
	cmp	VideoMode, MONO		; ($)
	je	VideoMode_OK		; Monochrome is ok

	mov	dx, OFFSET VidModErr	; All other modes are unacceptable
	mov	ah, 09			; DOS print string func
	int	21h			; Call DOS
	jmp	ErrExit			; Exit the program

VideoMode_OK:
;	mov	SnowCheck,0	; No Snow Checking! ($)
	call	CursorOff	; Turn the cursor off ($)

; ------------
; Title Screen
; ------------

	call	ClrScr			; Clear the screen
	mov	si,OFFSET Title1	; First Message
	mov	bh, Normal		; Gray on Black ($)
	mov	ax,(1 SHL 8)+(CENTERCOL-(T1LEN/2))	;start at top row,
					;center the msg			v1.1
	call	DWriteStr		; Write without attribute ($)
	inc	ah			; Double
	inc	ah			;   Space
	mov	al, (CENTERCOL-(T2LEN/2))	; Center Title Msg 2

; NOTE: SI Already points to Title2 (See DATASEG)

	call	DWriteStr		; Write the string to the scr ($)
	inc	ah			; Single Space
	mov	al, (CENTERCOL-(T3LEN/2))	; Center title Msg 3
	call	DWriteStr		; Write string to scr ($)
	inc	ah			; Double
	inc	ah			;   Space
	mov	al, (CENTERCOL-(T1LEN/2)) ; Align with first row
	call	DWriteStr		; Write str to scr ($)
	inc	ah			; Double
	inc	ah			;   Space
	inc	al			; Indent
	inc	al			;   2 Spaces
	mov	cx, 8			; 8 Feature lines
TS_Features:
	call	DWriteStr		; Write a feature ($)
	inc	ah			; Double
	inc	ah			;   Space
	loop	TS_Features		; Loop for all feature lines

	Pause	10			; Wait for a pressed key (10 seconds)

;---------------
; DFillAttr Demo
; --------------

	cmp	VideoMode, MONO		; This code is'nt suited for mono ($)
	je	DWN_Begin		; So goto DWriteStNA demo if mono

	mov	ax, 0101h		; First row/First column
	mov	bx,(MAXROWS SHL 8)+MAXCOLS	;all rows, all cols	v1.1
	mov	dh, 1			; Initialize attribute

DDFA_Top:
	and	dh, 00001111b		; Clear all but foreground
	or	dh,dh			;check for no attribute		v1.1
	jne	DDFA_Fill		; Go ahead if attribute
	 inc	dh			; Make sure theres and attr
DDFA_Fill:
	call	DFillAttr		; Fill screen with attribute ($)
	call	Delay			; Delay for .055 of a second
	inc	dh			; Next Attribute
	push	ax			; Store row/col info
	call	KeyPressed		; Check for a key
	or	al, al			; Sets zero flag if no char
	pop	ax			; Restore row/col info
	jz	DDFA_Top		; If no key the loop
	call	ClearKBD		; Clear key(s) from buffer

;-----------------
; DWriteStrNA Demo
; ----------------

DWN_Begin:
	call	ClrScr		; Clear the screen
	xor	ax,ax		;Initialize row/col			v1.1
	mov	bh, Normal	; Initialize Attribute ($)

DWN_MoveMsg:
	mov	si, OFFSET Msg  ; Point to Msg
	test	RDir,1		; Check the direction
	jz	DWN_RInc	; If direction is right then goto RInc

	dec	ah		; Decrement the row
	cmp	ah, 1		; Check to see if row eq 1
	jne	DWN_CheckCol	;   If not then check columns
	inc	RDir		; Change the direction
	jmp	short DWN_CheckCol	; Check columns

DWN_RInc:
	inc	ah		; Increment the row
	cmp	ah, MAXROWS		; Check to see if row eq MAXROWS
	jne	DWN_CheckCol		;   If not then check columns
	 inc	RDir			; Change the row-wise direction
DWN_CheckCol:
	test	CDir, 1			; Check column wise direction
	jz	DWN_CInc		; If direction is down then goto CInt
	dec	al			; Decrement the row (Go up)
	cmp	al, 1			; Check to see if this is column one
	jne	DWN_WriteIt		;   If not then check attr
	inc	CDir			; Change the direction
	jmp	short DWN_WriteIt	; Check the attr

DWN_CInc:
	inc	al			; Increment the row
	cmp	al, (MAXCOLS-MSGLEN)	; Check to see if row eq MAXCOLS
	jne	DWN_WriteIt		;	    If not then check attr
	 inc	CDir			; Change the column-wise direction
DWN_WriteIt:
	call	DWriteStrNA	; Write the str on scr w/o attr change ($)
	push	ax			; Store ax reg
	call	KeyPressed	; Check to see if a key has been pressed
	or	al, al			; Does AL eq zero?
	pop	ax			; Restore registers
	jz	DWN_MoveMsg		; if Yes then Redisplay message
	call	ClearKBD		; Clear the keyboard

; --------------
; DWriteStr Demo
; --------------

	cmp	VideoMode, MONO		; Demo not well suited for mono ($)
	je	STM_Begin		; so goto StoreToMem demo if mono

DW_MoveMsg:
	mov	si, OFFSET Msg		; Point to Msg
	test	RDir,1			; Check the direction
	jz	DW_RInc			; If direction is right then goto RInc

	dec	ah			; Decrement the row
	cmp	ah, 1			; Check to see if row eq 1
	jne	DW_CheckCol		;   If not then check columns
	 inc	RDir			; Change the direction
	 jmp	short DW_CheckCol	; Check columns

DW_RInc:
	inc	ah			; Increment the row
	cmp	ah, MAXROWS		; Check to see if row eq MAXROWS
	jne	DW_CheckCol		;   If not then check columns
	 inc	RDir			; Change the row-wise direction
DW_CheckCol:
	test	CDir,1			; Check column wise direction
	jz	DW_CInc			; If direction is down then goto CInt
	dec	al			; Decrement the row (Go up)
	cmp	al, 1			; Check to see if this is column one
	jne	DW_CheckAttr		;   If not then check attr
	inc	CDir			; Change the direction
	jmp	short DW_CheckAttr	; Check the attr

DW_CInc:
	inc	al			; Increment the row
	cmp	al, (MAXCOLS - MSGLEN)	; Check to see if row eq MAXCOLS
	jne	DW_CheckAttr		; If not then check attr
	 inc	CDir			; Change the column-wise direction
DW_CheckAttr:
	inc	bh			; Increment the attribute
	test	bh, Blink		; Test to see if blink bit is on
	jz	DW_WriteIt		; If not then skip to WriteIt
	 mov	bh, 1			; Set BH eq 1
DW_WriteIt:
	call	DWriteStr		; Write the string on the screen ($)
	push	ax			; Store ax reg
	call	KeyPressed		; Check to see if key has been pressed
	or	al, al			; Does AL eq zero?
	pop	ax			; Restore registers
	jz	DW_MoveMsg		; if Yes then Redisplay message
	call	ClearKBD		; Clear the keyboard

; ----------------------------------------------------------
; Move current screen image to save area (StoreToMem - Demo)
; ----------------------------------------------------------

STM_Begin:
	mov	ax,CS
	mov	ES,ax			;v1.1

; This might be a good place for some stack checking code. (hint hint)

	mov	di, OFFSET SaveScr	; offset to saved image area (See Stack)
	mov	ax, 0101h		; Row 1 / Col 1
	mov	bx,(MAXROWS SHL 8)+MAXCOLS	;capture all rows & cols v1.1
	call	StoreToMem		; Save the screen to memory ($)

; Note: SI Already points to SaveMsg (See DATASEG)

	mov	ax,(CENTERROW SHL 8)+(CENTERCOL-(SMSGLEN/2))	;center msg v1.1
	mov	bh, Reverse+Blink	; Reverse attr (Black on White)
					; & Blink ($)
	call	DWriteStr		; Display the string! ($)

	Pause	10			; Macro to pause for 10 seconds

; -------------
; DWriteCH Demo
; -------------

CHARMSG1COL	=	24
CHARMSG2COL	=	48
ROWSTART	=	1	; Row to start in
COLSTART	=	6	; Column to start in

; Note: SI already points to CharMsg1 (See DATASEG)

	call	ClrScr				; Clear the screen
	mov	bh, (Brown*10h+Blue)		; Blue on Brown (Also ul mono) ($)
	mov	ax,(CENTERROW SHL 8)+CHARMSG1COL	;AH = middle row of scr
						;AL=column for first msg	v1.1
	call	DWriteStr			; Write the first string ($)

; Note: SI now points to CharMsg2 (See DATASEG)

	mov	al, CHARMSG2COL			; Column for second msg
	call	DWriteStr			; Write the second string ($)

	mov	ax,(ROWSTART SHL 8)+COLSTART	;start row & col	v1.1
	mov	bh, White			; White on black ($)
	mov	cx, 1				; One Character
	mov	si, OFFSET Wheel		; Offset of wheel characters
DWC_Top:
	mov	bl,[si]				; Load character into bl
DWC_WriteIt:
	call	DWriteCH			; Write the character ($)
	inc	ah				; Next row
	inc	al				; Next column
	cmp	ah, MAXROWS			; Check AH against Maximum rows
	jle	DWC_CheckCol			; If less then then Check columns
	 mov	ah, 1				; Reset row
DWC_CheckCol:
	cmp	al, MAXCOLS			; Check AL agains max cols
	jle	DWC_WriteIt			; If less than max cols
						; then write
	mov	ax,(ROWSTART SHL 8)+COLSTART	;reset row, col		v1.1
;	call	Delay				; Wait 1 / 18.2 of a second
	inc	si				; Point to next char in wheel
	cmp	si, (OFFSET Wheel + MAXWHEEL)	; Maximum offset of Wheel
	jle	DWC_Top
DWC_InKey:
	push	ax			; Store row/col info
	call	KeyPressed		; Check to see if key has been pressed
	or	al, al			; Sets zero flag if al eq 0
	pop	ax			; Restore row/col info
	jnz	DWC_End			; If a key has been pressed (not null)
					; then end
	mov	si, OFFSET Wheel	; Set SI to offset zero of wheel
	jmp	DWC_Top			; If zero flag set then loop

DWC_End:
	call	ClearKBD	; Clear the keyboard

; ------------
; DFillCH Demo
; ------------

FILLMSGCOL	=	36	; Fill Msgs in column 25
FILLMSG1ROW	=	3	; Message one in row 3
FILLMSG2ROW	=	20	; Message two in row 20
FILLWID		=	15	; Width of fill
FILLHT		=	4	; Fill Height
RINC		=	2	; Row Increment
CINC		=	7	; Column Increment

	call	ClrScr			; Clear the screen
	mov	ax,(FILLMSG1ROW SHL 8)+FILLMSGCOL	;AH=row for first msg,
					;AL=col for the msg		v1.1
	mov	bh, LightBlue+Blink	; LightBlue on Black w/ Blink
					; (ul mono) ($)

; NOTE: SI Points to first msg already

	call	DWriteStr		; Write the first message
					; (SI points to 2nd) ($)
	mov	ah, FILLMSG2ROW		; Row for the second message
	call	DWriteStr		; Write the second message
					; to the screen ($)

	mov	ax, 0101h		; Top row / Left Col
	mov	bx,(FILLHT SHL 8)+FILLWID	;BH=nr of rows,
					;BL=nr of cols			v1.1
	xor	dh,dh			;Initialize attr		v1.1

DFCH_Top:
	inc	dh			; Increment dh
	mov	dl, dh			; Move attribute to character
	call	DFillCh			; Do the fill ($)
	add	ah, RINC		; Increment rows
	add	al, CINC		; Increment columns
	cmp	ah, (MAXROWS-FILLHT)	; compare ah to max rows - fill ht
;	jle	DFCH_CheckCol		; If less than or equal to
					; then check columns
;	jmp	DFCH_SecPart		; Goto the second part
	jnle	DFCH_SecPart		;TH

DFCH_CheckCol:
	cmp	al, (MAXCOLS-FILLWID)	; compare al to max cols - fill width
	jle	DFCH_Top		; Jump to the top if in bounds
DFCH_SecPart:
	xor	dh,dh			;init the attrib		v1.1
	mov	ax,(1 SHL 8) + (MAXCOLS-FILLWID)	;AH=top row,
					;AL=right side			v1.1

DFCH_Top2:
	inc	dh			; Increment dh
	mov	dl, dh			; Move attribute to character
	call	DFillCh			; Do the fill
	add	ah, RINC		; Increment rows
	sub	al, CINC		; Decrement columns
	cmp	ah, (MAXROWS-FILLHT)	; compare ah to max rows - fill ht
;	jle	DFCH_CheckCol2		; If less than or equal to
					; then check columns
;	jmp	DFCH_Pause		; Goto the pause routine
	jnle	DFCH_Pause		;if greater, go to the pause	v1.1

DFCH_CheckCol2:
	cmp	al, 1			; compare al to 1 (First column)
	jg	DFCH_Top2		; Jump to the top if in bounds
DFCH_Pause:
	Pause	10			; Macro to pause 10 seconds

; ---------------
; StoreToScr Demo
; ---------------

	mov	ax, 0101h		; First row & col
	mov	bx,(MAXROWS SHL 8)+MAXCOLS	;all rows, all cols	v1.1
	mov	si, OFFSET SaveScr	; Point to area where screen was saved
	call	StoreToScr		; Restore the saved screen ($)

	mov	si, OFFSET RestoreMsg	; Point to restore screen message
	mov	ax,(CENTERROW SHL 8)+(CENTERCOL-(RMSGLEN/2))
					;AH=center of screen,
					;AL=center the msg		v1.1
	mov	bh, Reverse+Blink	; Reverse attr (Black on White)
					; & Blink ($)
	call	DWriteStr		; Display the string! ($)

	Pause	10			; Macro - Pause for 10 secs
					; or until key press

Exit:
	call	ClrScr			; Clean up the display
ErrExit:
	call	CursorOn		; Turn the cursor on ($)
	mov	ah, 4Ch			; DOS exit function
	int	21h			; Call DOS to exit
Start	endp

; -------------------
; Programs Procedures
; -------------------

ClrScr	proc	near
;
; This procedure Clears the screen using VIDEO.ASM
;
	push	ax			; Store registers
	push	bx
	push	dx
	mov	ax, 0101h		; First row & col
	mov	bx,(MAXROWS SHL 8)+MAXCOLS	;all rows,all cols v1.1
	mov	dx,(NORMAL SHL 8)+' '	;DH=attr (Grey on Black)($)
					;DL=fill scr with spaces	v1.1
	call	DFillCH			; Do it! ($)
	pop	dx			; Restore registers
	pop	bx
	pop	ax
	ret

ClrScr	endp

KeyPressed	proc	near
;
; This procedure uses DOS to check if a key has been pressed.
;
; Output
;	AL = FFh/0  Yes/No
; Modifies
;	AX
;
	mov	ah, 0Bh		; DOS func 0Bh (Check for pressed key)
	int	21h		; Call DOS
	xor	ah, ah		; Clear AH reg
	ret

KeyPressed	endp

ClearKBD	proc	near
;
; This procedure uses DOS to clear the keyboard buffer.
;
	push	ax		; Store AX reg
	mov	ax, 0C00h	; Dos func 0Ch = Clear KBD
	int	21h		; Call DOS
	pop	ax		; Restore AX
	ret

ClearKBD	endp

Delay	proc	near
;
; This procedure delays the CPU for about 1 timer tick or 1/18.2 of
; of a second.
;
	push	ax
	push	cx
	push	dx
	xor	ah,ah			;Int 1A GetTime function	v1.1
	int	01ah			; Call timer interrupt
	mov	word ptr LowTick, dx	; DX returns low timer tick value
DelayLoop:
	xor	ah,ah			;Int 1A GetTime function	v1.1
	int	01ah			; Call timer interrupt
	cmp	dx,word ptr LowTick	; Compare current val to first
	je	DelayLoop		; If still the same then loop
	pop	dx
	pop	cx
	pop	ax
	ret

Delay	endp

; --------------------------
; Uninitialized Data Segment
; --------------------------
;v1.2 moved down to leave room for VIDEO2.OBJ
;VIDEO2 requires (as written) 891 bytes, so we'll leave 1000 to be safe.

LowTick	=	$+1000		; Tick holder for Delay routine
SaveScr	=	$+1002		; Screen Save Area (4000 bytes)

CSeg	ENDS
	end	VidDemo2
