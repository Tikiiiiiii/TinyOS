; MBR主引导程序
; 注意是小端字节序
section MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
	
;调用 int 0x10 功能号 0x06 清屏
	mov ah,0x06     ;ah 功能号
                    ;al 上卷行数（0未写）
	mov bh,0x07     ;bh 上卷行属性
	mov bl,0x00     
	mov cx,0x0000       ;ch,cl 窗口左上角
	mov dx,0x184f       ;dh,dl 窗口右下角
	int 0x10            ;
	
;调用 int 0x10 功能号 0x03 获取光标的位置
	mov ah,0x03     ;功能号
	mov bh,0x00     ;待获取的页号：第几页
	int 0x10

;调用 int 0x10 功能号 0x13号 打印字符串
	mov ax,message      
	mov bp,ax           ;待打印字符串起始地址
	mov cx,0x0b         ;字符串长度
	mov ah,0x13         ;功能号
	mov al,0x01         ;写字符形式
	mov bx,0x0002       ;bh:输出页号 bl:字符属性黑底绿字（02）
	int 0x10

jmp $   ;循环在此处

message db "Tiki's MBR"
times 510 - ($-$$) db 0
db 0x55, 0xaa
