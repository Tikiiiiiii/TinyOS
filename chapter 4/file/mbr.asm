; mbr.asm
; MBR主引导程序
; 注意是小端字节序
%include "boot.inc"
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
    mov al,0x00     ;al 上卷行数（0未写）
	mov bh,0x07     ;bh 上卷行属性
	mov bl,0x00     
	mov cx,0x0000       ;ch,cl 窗口左上角
	mov dx,0x184f       ;dh,dl 窗口右下角
	int 0x10            

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

	mov eax, LOADER_START_SECTOR	;起始扇区地址
	mov bx, LOADER_BASE_ADDR		;写入地址
	mov cx, 4						;待读入扇区数;修改
	call rd_disk_m_16				;调用函数

	jmp LOADER_BASE_ADDR			;跳到加载程序处

;读取硬盘n个扇区 n是cx寄存器的值：1
rd_disk_m_16:
	mov esi,eax		;备份eax（原LBA扇区号）
	mov di,cx		;备份cx

	;磁盘操作的7个步骤
	mov dx,0x1f2	;1.选择通道
	mov al,cl 		;1.设置待读取扇区数
	out dx,al		

	mov eax,esi 	;恢复ax
	;2.填写LBA 0-23位
	mov dx,0x1f3
	out dx,al 
	mov cl,8
	shr eax,cl
	mov dx,0x1f4
	out dx,al
	shr eax,cl 
	mov dx,0x1f5
	out dx,al

	;2.填写LBA 24-27
	shr eax,cl 
	and al,0000_1111b
	;3.device选择硬盘，开启LBA模式，选择主盘
	or  al,1110_0000b 
	mov dx,0x1f6
	out dx,al 

	;4.向端口写入读命令0x20
	mov dx,0x1f7
	mov al,0x20
	out dx,al 

	;5.检测硬盘状态
.not_ready:
	nop 	;停顿等待一会
	in al,dx 
	and al,1000_1000b ;第4位1表示准备好，第7位1表示忙碌
	cmp al,0000_1000b
	jnz .not_ready	;循环检查

	;6.读数据
	mov ax,di	;读取扇区数
	mov dx,256  ;每次读2B，需要512/2=256次
	mul dx 		;8位乘法，结果在ax种
	mov cx,ax 	;得到要读取的总次数
	mov dx,0x1f0
.go_on_read:
	in ax,dx 
	mov [bx],ax 
	add bx,2
	loop .go_on_read

	ret

	times 510 - ($-$$) db 0
	db 0x55, 0xaa