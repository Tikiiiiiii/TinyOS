; MBR主引导程序
; 注意是小端字节序
section MBR vstart=0x7c00
	mov ax,cs
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov fs,ax
	mov sp,0x7c00
;显存地址写入gs
	mov ax,0xb800
	mov gs,ax
	
;调用 int 0x10 功能号 0x06 清屏
	mov ah,0x06     ;ah 功能号
                    ;al 上卷行数（0未写）
	mov bh,0x07     ;bh 上卷行属性
	mov bl,0x00     
	mov cx,0x0000       ;ch,cl 窗口左上角
	mov dx,0x184f       ;dh,dl 窗口右下角
	int 0x10            ;

; 设置显存
; 背景绿色,字体红色,字体闪烁
	mov byte [gs:0x00],'H'
	mov byte [gs:0x01],0xA4

	mov byte [gs:0x02],'E'
	mov byte [gs:0x03],0xA4

	mov byte [gs:0x04],'L'
	mov byte [gs:0x05],0xA4

	mov byte [gs:0x06],'L'
	mov byte [gs:0x07],0xA4

	mov byte [gs:0x08],'O'
	mov byte [gs:0x09],0xA4

jmp $   ;循环在此处

times 510 - ($-$$) db 0
db 0x55, 0xaa
