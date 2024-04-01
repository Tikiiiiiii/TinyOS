%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
jmp loader_start 

;构建gdt及其内部的描述符
GDT_BASE:           dd 0x00000000
                    dd 0x00000000

CODE_DESC:          dd 0x0000FFFF
                    dd DESC_CODE_HIGH4

DATA_STACK_DESK:    dd 0x0000FFFF
                    dd DESC_DATA_HIGH4

VIDEO_DESC:         dd 0x80000007               ;limit=(0xbffff-0xb8000)/4k=0x7
                    dd DESC_VIDEO_HIGH4         ;此时dp1为0

GDT_SIZE            equ $-GDT_BASE
GDT_LIMIT           equ GDT_SIZE-1
times 60 dq 0       ;预留60个段描述符

SELECTOR_CODE       equ (0x0001<<3)+TI_GDT+RPL0  ;相当于 (CODE_DESC-GDT_BASE)/8+TI_GDT+RPL0
SELECTOR_DATA       equ (0x0002<<3)+TI_GDT+RPL0
SELECTOR_VIDEO      equ (0x0003<<3)+TI_GDT+RPL0 

gdt_ptr             dw GDT_LIMIT
                    dd GDT_BASE

loadermsg           db '2 loader in real.'

loader_start: 
    ;打印字符串
    mov byte[gs:640],'L'
    mov byte[gs:642],'O'
    mov byte[gs:644],'A'
    mov byte[gs:646],'D'
    mov byte[gs:648],'E'
    mov byte[gs:650],'R'
    mov byte[gs:652],'_'
    mov byte[gs:654],'S'
    mov byte[gs:656],'T'
    mov byte[gs:658],'A'
    mov byte[gs:660],'R'
    mov byte[gs:662],'T'

;子功能号13打印字符串
    mov sp,LOADER_BASE_ADDR
    mov bp,loadermsg
    mov cx,17
    mov ax,0x1301
    mov bx,0x001f
    mov dx,0x1800
    int 0x10

    ;---准备进入保护模式---
    ;---打开A20---
    in al,0x92
    or al,0000_0010B
    out 0x92,al
   
    ;---加载GDT---
    lgdt [gdt_ptr]
    
    ;---cr0第0个位置1
    mov eax,cr0 
    or eax,0x00000001
    mov cr0,eax 

    jmp dword SELECTOR_CODE:p_mode_start ;刷新流水线

[bits 32]
p_mode_start:
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax 
    mov esp,LOADER_STACK_TOP
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    mov byte [gs:800], 'P'
    jmp $