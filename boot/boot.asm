; BSD License, 2017, Mega Show
; FileName: boot.asm
; Description: Boot Sector(引导扇区)
;==================================================

    org 0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    call DispStr
    hlt
    jmp $    ; infinite loop
DispStr:
    mov ax, BootMessage
    mov bp, ax    ; ES:BP = 串地址
    mov cx, 16    ; CX = 串长度
    mov ax, 0x1301    ; AH = 0x13, AL = 0x01
    mov bx, 0x000c    ; 页号BH = 0x00, 黑底红字BL = 0x0c
    mov dl, 0
    int 10h    ; 10h号中断
    ret
BootMessage:
    db "Hello, OS world!"
    times 510 - ($ - $$) db 0
    dw 0xaa55    ; 结束标志
