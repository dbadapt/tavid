Module  : VIDEO.ASM - x86 Direct Memory Video Access Routines for TASM Version 1
Author  : Dave Bennett
Version : 1.2
Date    : 12/22/88
CIS PPN : 74635,1671
e-mail  : dbadapt@gmail.com

Description:
------------

  This is a module of FAST direct video routines for TASM.  At this time they
  are released to the public domain.  Much thanks to Brian Foley for
  FASTWR.PAS (Turbo Pascal V3 Inline Assember Screen Routines) which gave much
  insight on screen positioning and snow suppresion (horiz retrace waiting)

  These routines are dying to have someone write an accompaning windowing
  module... (hint hint)

  Please contact me a tell me what you think via EPlex, IBMNET, Borland
  forums etc...  I am very interested in your opinions, bug reports, etc..

  --Dave

Files in the distributed archive
--------------------------------

  Name     Ext    Size      Description
  ----     ---    -----     -----------
  VIDDEMO  ASM    20487     Demonstration program
  VIDEO    ASM    26416     Video routines
  README   TXT     6792     This file
  VIDDEMO  EXE     2662     Compiled video demo (Not bad for 2.5K!)
  VIDEO    INC     2366     Global Declareations & equates for VIDEO.ASM
  VIDDEMO  MAK      165     Turbo Make file for VIDDEMO.EXE

Features:
---------

  - Video mode detection
  - Monochrome/CGA/EGA support
  - Snow suppression
  - Direct character & string writing
  - Screen saving & restoring
  - Area fills (character, attribute, and both)
  - Cursor on & off control
  - All commands w/ or w/o attribute changes


Global Data:
------------

  BaseOfScreen          Word value set by GetVideoMode proc.  This is
			set to B800h / B000h depending video mode.

  SnowCheck             Byte value set by GetVideoMode.  Set to 1 if
			adapter is CGA (Not EGA) by default.  Mono and
			EGA cards will set this to 0 by default.

  VideoMode             Video mode set by GetVideoMode.  This holds the
			video mode at the time of the last GetVideoMode
			call (Set by BIOS INT 10 func 0Fh).


Global Procedures:
------------------

Note: No routines preserve the flags register!

See VIDDEMO.ASM for examples of all routines,  all references to this module
and VIDEO.INC have been highlighted with a ($) so that you may better
scan VIDDEMO.ASM for examples of how to apply these routines.  --Dave


  EGAInstalled
  ------------
    This procedure checks to see if the current adapter card is an
    EGA.

    Output
	  AL = 1 if EGA Adapter is found / 0 if not

    Modified
	  AX


  GetVideoMode
  ------------
    This procedure checks the video mode and sets the BaseOfScreen
    accordingly.  It also sets SnowCheck to 1 if adapter is a CGA.

    Output
	  BaseOfScreen
	  VideoMode
	  SnowCheck

    Uses
	  EGAInstalled


  DWriteCH
  --------
    Writes a character to the screen using direct memory access.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      Row on screen 1-25
	  AL      Column on screen 1-80
	  BH      Video Attribute
	  BL      Character
	  CX      Number of times

    Output
	  Screen memory (B000:0000 or 8000 CGA/MONO


  DWriteCHNA
  ----------
    Writes a character to the screen using direct memory access.
    This procedure does not disturb current attr setting.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      Row on screen 1-25
	  AL      Column on screen 1-80
	  BL      Character
	  CX      Number of times

    Output
	  Screen memory (B000:0000 or 8000 CGA/MONO


    DWriteStr
    ---------
    This procedure writes a null delimited string to the screen using
    direct memory access.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  DS:SI   Null terminated string to print
	  AH      Row on screen 1-25
	  AL      Column on screen 1-80
	  BH      Video Attribute

    Output
	  Screen memory (B000:0000 or 8000 CGA/MONO

    Modifies
	  SI - Returns 1 byte past null of displayed string


  DWriteStrNA
  -----------
    This procedure writes a null delimited string to the screen using
    direct memory access, attribute is not changed.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  DS:SI   Null terminated string to print
	  AH      Row on screen 1-25
	  AL      Column on screen 1-80

    Output
	  Screen memory (B000:0000 or 8000 CGA/MONO)

    Modifies
	  SI - Returns 1 byte past null of displayed string


  DFillCH
  -------
    This procedure fills an area of the screen with the specified
    character and attribute.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      = Top Row
	  AL      = Left Column
	  BH      = Number of rows
	  BL      = Number of columns
	  DH      = Attribute
	  DL      = Character


  DFillCHNA
  ---------
    This procedure fills an area of the screen with the specified
    character. Attribute remains the same.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      = Top Row
	  AL      = Left Column
	  BH      = Number of rows
	  BL      = Number of columns
	  DL      = Character


  DFillAttr
  ---------
    This procedure fills an area of the screen with the specified
    attribute. Character remains the same.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      = Top Row
	  AL      = Left Column
	  BH      = Number of rows
	  BL      = Number of columns
	  DH      = Attribute


  StoreToMem
  ----------
    This procedure moves an image from the screen to the designated
    memory area.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      = Top Row
	  AL      = Left Column
	  BH      = Number of rows
	  BL      = Number of columns
	  ES:DI   = Memory Destination

    Modifies
	  DI


  StoreToScr
  ----------
    This procedure moves an image from memory to the designated
    screen location.

    *** IMPORTANT -- CALL GetVideoMode Before using this routine!

    Input
	  AH      = Top Row
	  AL      = Left Column
	  BH      = Number of rows
	  BL      = Number of columns
	  DS:SI   = Memory Area of image

    Modifies
	  SI


  CursorOff
  ---------
    This procedure simply turns the Cursor off


  CursorOn
  --------
    This procedure simply turns the Cursor on


Disclaimer
----------

  The current status of these routines is public domain.  Author makes no
  claims to the usefullness of these routines and cannot be held responsible
  for any situation resulting from the use of these routines.

  - David Bennett

v1.1, 1.2 : Toad Hall Tweak, 22 Dec 88
v1.1:
 -	Modified for MASM (early versions .. none of the new v5.0 stuff)
	instead of the TASM assembler.
 -	Rewritten into a simpler .COM file instead of the .EXE version
	(e.g., single segment).
 -	VIDEO1.ASM rewritten to be source INCLUDEd in VIDDEMO1 (or whatever
	program you're writing.
 -	VIDEO1.INC rewritten to be an INCLUDE file for VIDDEMO1 or your
	program.
 -	Slight tweaks, no functional changes.
v1.2:
 -	VIDEO2.ASM rewritten to be compiled separately into its own
	.OBJ file (for later linking with VIDDEMO2 or your program).
 -	VIDDEMO2.ASM also rewritten with this linking in mind.
 -	Still a .COM file format (e.g., single segment).
