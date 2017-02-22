; BSD License, 2017, Mega Show
; FileName: boot.asm
; Description: Boot Sector
;==================================================

		org    0x7c00
		jmp    LABEL_GDT_INIT
		nop

%include  "fat12.inc"
%include  "func.inc"
%include  "pm.inc"


; GDT                            段基址              段界限           属性
LABEL_GDT:          Descriptor	      0,                  0,             0
LABEL_DESC_VIDEO:	Descriptor  0xb8000,  0xbffff - 0xb8000,        DA_DRW
LABEL_DESC_DATA:    Descriptor        0,     SegDataLen - 1,         DA_DR
LABEL_DESC_CODE32:	Descriptor	      0,   SegCode32Len - 1,  DA_C + DA_32

GdtLen  equ  $ - LABEL_GDT
GdtPtr  dw   GdtLen - 1     ; GDT界限
        dd   0              ; GDT基址

; 选择子
SelectorVideo     equ    LABEL_DESC_VIDEO - LABEL_GDT
SelectorData      equ    LABEL_DESC_DATA - LABEL_GDT
SelectorCode32    equ    LABEL_DESC_CODE32 - LABEL_GDT


LABEL_SEG_DATA:
		DiskReadError    db    "Read disk failed!", 0
		HelloMessage     db    "Hello, TOSX!", 0
		WebsiteMessage   db    "http://icytown.com/tosx/", 0
OffsetDiskReadError     equ    DiskReadError - LABEL_SEG_DATA
OffsetHelloMessage      equ    HelloMessage - LABEL_SEG_DATA
OffsetWebsiteMessage    equ    WebsiteMessage - LABEL_SEG_DATA
SegDataLen  equ  $ - LABEL_SEG_DATA



[BITS 16]
;------------------------------------------------------------------------
; ###  GDT init operation
;------------------------------------------------------------------------
LABEL_GDT_INIT:
		mov    ah, 0x06
		mov    al, 0       ; clear screen
		mov    bh, 0
		mov    cx, 0x0000
		mov    dx, 0xffff
		int    0x10

		mov    ax, cs
		mov    ds, ax

		; LABEL_GDT段基址初始化
		xor    eax, eax
		mov    ax, ds
		shl    eax, 4
		add    eax, LABEL_GDT
		mov    [GdtPtr + 2], eax

		; LABEL_DESC_DATA段基址初始化
		xor    eax, eax
		mov    ax, ds
		shl    eax, 4
		add    eax, LABEL_SEG_DATA
		mov    [LABEL_DESC_DATA + 2], ax
		shr    eax, 16
		mov    [LABEL_DESC_DATA + 4], al
		mov    [LABEL_DESC_DATA + 7], ah

		; LABEL_DESC_CODE32段基址初始化
		xor    eax, eax
		mov    ax, ds
		shl    eax, 4
		add    eax, LABEL_SEG_CODE32
		mov    [LABEL_DESC_CODE32 + 2], ax
		shr    eax, 16
		mov    [LABEL_DESC_CODE32 + 4], al
		mov    [LABEL_DESC_CODE32 + 7], ah


;-------------------------------------------------------------------------
; ### read the third sector
;-------------------------------------------------------------------------
LABEL_DISK_READ:
		mov    ax, 0x0800
		mov    es, ax
		mov    bx, 0
		mov    ah, 0x02
		mov    al, 1
		mov    ch, 0
		mov    cl, 3      ; sector
		mov    dh, 0
		mov    dl, 0x00
		int    0x13
		jnc    .1
		real_print_s    DiskReadError, 0, 0x0000
		jmp    $
.1:		nop


;----------------------------------------------------------------------
; ### load GDT, run protect mode
;----------------------------------------------------------------------
LABEL_GDT_LOAD:
		lgdt   [GdtPtr]
		cli
		in     al, 0x92
		or     al, 0b0000_0010
		out    0x92, al
		mov    eax, cr0
		or     eax, 1
		mov    cr0, eax
		jmp    dword SelectorCode32:0


;----------------------------------------------------------------------
; real_print_s(word address, byte page, word position);
;
; ###  print string in real mode
; @param: bp => string address (string end by 0)
; @param: bh => page number
; @param: dl => print x-position
; @param: dh => print y-position
;----------------------------------------------------------------------
FUNC_REAL_PRINT_S:
		mov    ax, bp
		dec    bp
.1:		inc    bp
		cmp    byte [bp], 0
		jne    .1
		mov    cx, bp
		sub    cx, ax
		mov    bp, ax
		mov    ax, cs
		mov    es, ax
		mov    ax, 0x1301
		mov    bl, 0b0000_1111     ; FRGB_IRGB
		int    0x10
		ret



[BITS 32]
;-----------------------------------------------------------------------
; ### code in protect mode
;-----------------------------------------------------------------------
LABEL_SEG_CODE32:
		print_s    OffsetHelloMessage, 0x0000
		jmp    dword SelectorCode32:(LABEL_SEG_LOADER-LABEL_SEG_CODE32)


;-----------------------------------------------------------------------
; print_s(dword address, word position);
;
; ### print string in protect mode
; @param: es  => string address's segment
; @param: eax => string address's offset
; @param: dl  => x-position
; @param: dh  => y-position
;-----------------------------------------------------------------------
FUNC_PRINT_S:
		mov    ax, SelectorVideo
		mov    gs, ax
		xor    eax, eax
		mov    al, 80
		mul    dh
		mov    dh, 0
		add    ax, dx
		mov    dh, 2
		mul    dh
		mov    edi, eax
		mov    ah, 0b0000_1111     ; FRGB_IRGB
.1:		mov    al, [es:ecx]
		cmp    al, 0
		je     .2
		mov    [gs:edi], ax
		add    edi, 2
		inc    ecx
		jmp    .1
.2:		ret



;=======================================================================
times    510-($-$$)    db    0
db       0x55, 0xaa
times    512           db    0
;=======================================================================


;-----------------------------------------------------------------------
; load in memory 0x8000
;-----------------------------------------------------------------------
LABEL_SEG_LOADER:
		print_s    OffsetWebsiteMessage, 0x0100
		jmp    $

SegCode32Len    equ    $ - LABEL_SEG_CODE32

times  1440*1024-($-$$)  db  0
