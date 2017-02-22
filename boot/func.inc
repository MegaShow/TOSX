; BSD License, 2017, Mega Show
; FileName: func.inc
; Description: the macro and usage of function
;======================================================================


;----------------------------------------------------------------------
; real_print_s(word address, byte page, word position);
;----------------------------------------------------------------------
%macro    real_print_s    3
		mov    dx, %1
		mov    bp, dx
		mov    bh, %2
		mov    dx, %3
		call   FUNC_REAL_PRINT_S
%endmacro


;----------------------------------------------------------------------
; print_s(dword address, word position);
;----------------------------------------------------------------------
%macro    print_s    2
		mov    ax, SelectorData
		mov    es, ax
		mov    ecx, %1
		mov    dx, %2
		call   FUNC_PRINT_S
%endmacro
