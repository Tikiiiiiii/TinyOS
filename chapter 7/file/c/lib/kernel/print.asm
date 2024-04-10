TI_GDT  equ 0
RPL0    equ 0
SELECTOR_VIDEO  equ (0x0003 << 3) + TI_GDT + RPL0

[bits 32]
section .data 
put_int_buffer dq   0
section .text
;------------- put_str ----------------------
global put_str
put_str:
    push ebx
    push ecx
    xor ecx,ecx
    mov ebx, [esp+12]
.goon:
    mov cl,[ebx]
    cmp cl,0
    jz .str_over
    push ecx
    call put_char
    add esp,4
    inc ebx
    jmp .goon
.str_over:
    pop ecx
    pop ebx
    ret
;----------------- put_char ------------------
;功能描述：把栈中一个字符写入光标处
;---------------------------------------------
global put_char
put_char:
    pushad
    mov ax,SELECTOR_VIDEO
    mov gs,ax

    ;;;;;;;;;;获取当前光标位置;;;;;;;;;
    ;高8位
    mov dx,0x03d4
    mov al,0x0e
    out dx,al
    mov dx,0x03d5
    in al,dx
    mov ah,al

    ;低8位
    mov dx,0x03d4
    mov al,0x0f
    out dx,al
    mov dx,0x03d5
    in al,dx
    
    ;光标放入 bx
    mov bx,ax
    ;放入待打印的字符
    mov ecx,[esp + 36] ;因为pushad压入4*8=32字节,还要跳过4字节的返回地址。
    cmp cl,0xd ;回车符号
    jz .is_carriage_return 
    cmp cl,0xa ;换行符号
    jz .is_line_feed

    cmp cl,0x8 ;Backspace的ascll码是0x8
    jz .is_backspace
    jmp .put_other

.is_backspace:
    dec bx
    shl bx,1 ;坐标左移1位,并将等待删除的字节补上0或空格
    mov byte [gs:bx],0x20
    inc bx
    mov byte [gs:bx],0x07
    shr bx,1
    jmp .set_cursor

.put_other:
    shl bx,1
    mov [gs:bx],cl
    inc bx
    mov byte [gs:bx],0x07
    shr bx,1
    inc bx
    cmp bx,2000
    jl .set_cursor

.is_line_feed:          ;换行符 LF(\n)
.is_carriage_return:    ;回车符 CR(\r)
    xor dx,dx
    mov ax,bx
    mov si,80
    div si
    sub bx,dx

.is_carriage_return_end:
    add bx,80
    cmp bx,2000
.is_line_feed_end:      ;若是LF(\n),将光标移+80即可
    jl .set_cursor

;滚屏，把屏幕的 1-24行搬运到第 0-23 行
;再将第 24 行用空格填充。
.roll_screen:
    cld
    mov ecx,960
    mov esi,0xc00b80a0;第一行首部
    mov edi,0xc00b8000;第零行首部
    rep movsd

    ;空白填充最后一行
    mov ebx,3840
    mov ecx,80

.cls:
    mov word [gs:ebx], 0x0720;黑底白字空格键
    add ebx,2
    loop .cls
    mov bx,1920

.set_cursor:
;设置光标为 bx 值
;高8位
    mov dx,0x03d4
    mov al,0x0e
    out dx,al
    mov dx,0x03d5
    mov al,bh
    out dx,al
;低8位
    mov dx,0x03d4
    mov al,0x0f
    out dx,al
    mov dx,0x03d5
    mov al,bl
    out dx,al
.put_char_done:
    popad
    ret

;--------put_int-----------------------------------------
global put_int
put_int:
    pushad
    mov ebp,esp
    mov eax,[ebp+4*9]
    mov edx,eax
    mov edi,7
    mov ecx,8
    mov ebx,put_int_buffer
;将32位数字按照16进制的形式从低到高位逐个处理
;共处理8个十六进制数字
.16based_4bits:
    and edx,0x0000000F
    cmp edx,9
    jg .is_A2F
    add edx,'0'
    jmp .store 
.is_A2F:
    sub edx,10
    add edx,'A'
.store:
    mov [ebx+edi],dl 
    dec edi 
    shr eax,4 
    mov edx,eax 
    loop .16based_4bits
.ready_to_print:
    inc edi 
.skip_prefix_0:
    cmp edi,8
    je .full0
.go_on_skip:
    mov cl,[put_int_buffer+edi]
    inc edi 
    cmp cl,'0'
    je .skip_prefix_0;判断继续下一个字符是否是字符0
    dec edi 
    jmp .put_each_num 

.full0:
    mov cl,'0'
.put_each_num:
    push ecx
    call put_char 
    add esp,4 
    inc edi 
    mov cl,[put_int_buffer+edi]
    cmp edi,8
    jl .put_each_num
    popad 
    ret