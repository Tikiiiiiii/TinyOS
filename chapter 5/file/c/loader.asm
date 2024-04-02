%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

;------------------------------
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
times 60 dq 0

SELECTOR_CODE       equ (0x0001<<3)+TI_GDT+RPL0
SELECTOR_DATA       equ (0x0002<<3)+TI_GDT+RPL0
SELECTOR_VIDEO      equ (0x0003<<3)+TI_GDT+RPL0 

total_mem_bytes     dd  0;存放内存大小

gdt_ptr             dw GDT_LIMIT
                    dd GDT_BASE

;------- 记录 ARDS结构体数 ----------
ards_buf            times   244 db 0
ards_nr             dw      0

;------------------------------

mov byte[gs:320],'['
mov byte[gs:322],']'
mov byte[gs:326],'G'
mov byte[gs:328],'D'
mov byte[gs:330],'T'

loader_start: 
    ;--- 获取内存布局 ---
    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf

.e820_mem_get_loop:
    mov eax, 0x0000e820
    mov ecx,20
    int 0x15
    jc .e820_failed_so_try_e801

    add di,cx
    inc word [ards_nr]
    cmp ebx, 0
    jnz .e820_mem_get_loop
    
    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx,edx

.find_max_mem_area:
    mov eax,[ebx]
    add eax,[ebx+8]
    add ebx, 20
    cmp edx,eax

    jge .next_ards
    mov edx,eax
.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

;------ int 15h ax=E801和------

.e820_failed_so_try_e801:
    mov ax,0xe801
    int 0x15
    jc .e801_failed_so_try88

    mov cx,0x400
    mul cx
    shl edx,16
    and eax,0x0000FFFF
    or edx,eax
    add edx, 0x100000
    mov esi,edx

    xor eax,eax
    mov ax,bx
    mov ecx,0x10000
    mul ecx

    add esi,eax
    mov edx,esi
    jmp .mem_get_ok

;------ int 15h ah=0x88 ------
.e801_failed_so_try88:
    mov ah,0x88
    int 0x15
    jc .error_hlt
    and eax,0x0000FFFF

    mov cx,0x400
    mul cx
    shl edx,16
    or edx,eax
    add edx,0x100000

.mem_get_ok:
    mov [total_mem_bytes],edx



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
.error_hlt:
    hlt
[bits 32]
p_mode_start:
    mov ax,SELECTOR_DATA
    mov ds,ax
    mov es,ax
    mov ss,ax 
    mov esp,LOADER_STACK_TOP
    mov ax,SELECTOR_VIDEO
    mov gs,ax

mov byte[gs:480],'['
mov byte[gs:482],']'
mov byte[gs:486],'P'
mov byte[gs:488],'r'
mov byte[gs:490],'o'
mov byte[gs:492],'t'
mov byte[gs:494],'e'
mov byte[gs:496],'c'
mov byte[gs:498],'t'
mov byte[gs:500],'i'
mov byte[gs:502],'o'
mov byte[gs:504],'n'
mov byte[gs:508],'m'
mov byte[gs:510],'o'
mov byte[gs:512],'d'
mov byte[gs:514],'e'


;--- 加载内核kernel ---
mov byte[gs:640],'['
mov byte[gs:642],']'
mov byte[gs:646],'L'
mov byte[gs:648],'o'
mov byte[gs:650],'a'
mov byte[gs:652],'d'
mov byte[gs:656],'t'
mov byte[gs:658],'h'
mov byte[gs:660],'e'
mov byte[gs:664],'k'
mov byte[gs:666],'e'
mov byte[gs:668],'r'
mov byte[gs:670],'n'
mov byte[gs:672],'e'
mov byte[gs:674],'l'

    mov eax,KERNEL_START_SECTOR
    mov ebx,KERNEL_BIN_BASE_ADDR
    mov ecx,200

    call rd_disk_m_32
;--- 创建页目录及页表 ---
mov byte[gs:800],'['
mov byte[gs:802],']'
mov byte[gs:806],'C'
mov byte[gs:808],'r'
mov byte[gs:810],'e'
mov byte[gs:812],'a'
mov byte[gs:814],'t'
mov byte[gs:816],'e'
mov byte[gs:820],'P'
mov byte[gs:822],'D'
mov byte[gs:826],'P'
mov byte[gs:828],'T'
    
    call setup_page
    sgdt[gdt_ptr]
    mov ebx,[gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [gdt_ptr + 2],   0xc0000000

    add esp,0xc0000000
    ;将页目录地址赋给cr3
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3,eax

    ;打开cr0的pg位
    mov eax,cr0
    or eax,0x80000000
    mov cr0,eax

    ;开启分页后，用gdt新的地址重新加载
    lgdt[gdt_ptr]
    mov byte [gs:960],'V'

    ;jmp $
;--------- 跳到读取的内核上 ----------
mov byte[gs:960],'['
mov byte[gs:962],']'
mov byte[gs:966],'J'
mov byte[gs:968],'m'
mov byte[gs:970],'p'
mov byte[gs:974],'k'
mov byte[gs:976],'e'
mov byte[gs:978],'r'
mov byte[gs:980],'n'
mov byte[gs:982],'e'
mov byte[gs:984],'l'
    jmp SELECTOR_CODE:enter_kernel
enter_kernel:
    call kernel_init
    mov esp,0xc009f000
    jmp KERNEL_ENTRY_POINT
;-----------------   将kernel.bin中的segment拷贝到编译的地址   -----------
kernel_init:
   xor eax, eax
   xor ebx, ebx     ;ebx记录程序头表地址
   xor ecx, ecx     ;cx记录程序头表中的program header数量
   xor edx, edx     ;dx 记录program header尺寸,即e_phentsize

   mov dx, [KERNEL_BIN_BASE_ADDR + 42]    ; 偏移文件42字节处的属性是e_phentsize,表示program header大小
   mov ebx, [KERNEL_BIN_BASE_ADDR + 28]   ; 偏移文件开始部分28字节的地方是e_phoff,表示第1 个program header在文件中的偏移量
                      ; 其实该值是0x34,不过还是谨慎一点，这里来读取实际值
   add ebx, KERNEL_BIN_BASE_ADDR
   mov cx, [KERNEL_BIN_BASE_ADDR + 44]    ; 偏移文件开始部分44字节的地方是e_phnum,表示有几个program header
.each_segment:
   cmp byte [ebx + 0], PT_NULL        ; 若p_type等于 PT_NULL,说明此program header未使用。
   je .PTNULL

   ;为函数memcpy压入参数,参数是从右往左依然压入.函数原型类似于 memcpy(dst,src,size)
   push dword [ebx + 16]          ; program header中偏移16字节的地方是p_filesz,压入函数memcpy的第三个参数:size
   mov eax, [ebx + 4]             ; 距程序头偏移量为4字节的位置是p_offset
   add eax, KERNEL_BIN_BASE_ADDR      ; 加上kernel.bin被加载到的物理地址,eax为该段的物理地址
   push eax               ; 压入函数memcpy的第二个参数:源地址
   push dword [ebx + 8]           ; 压入函数memcpy的第一个参数:目的地址,偏移程序头8字节的位置是p_vaddr，这就是目的地址
   call mem_cpy               ; 调用mem_cpy完成段复制
   add esp,12                 ; 清理栈中压入的三个参数
.PTNULL:
   add ebx, edx               ; edx为program header大小,即e_phentsize,在此ebx指向下一个program header 
   loop .each_segment
   ret

;----------  逐字节拷贝 mem_cpy(dst,src,size) ------------
;输入:栈中三个参数(dst,src,size)
;输出:无
;---------------------------------------------------------
mem_cpy:              
   cld
   push ebp
   mov ebp, esp
   push ecx        ; rep指令用到了ecx，但ecx对于外层段的循环还有用，故先入栈备份
   mov edi, [ebp + 8]      ; dst
   mov esi, [ebp + 12]     ; src
   mov ecx, [ebp + 16]     ; size
   rep movsb           ; 逐字节拷贝

   ;恢复环境
   pop ecx      
   pop ebp
   ret


;---------- 创建页目录和页表 ----------

;---页目录清零---
setup_page:
    mov ecx,4096 ;一个项4字节*1024个目录项
    mov esi,0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

;---创建页目录项---
.create_pde:
    mov eax,PAGE_DIR_TABLE_POS
    add eax,0x1000
    mov ebx,eax

    or eax,PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_POS + 0x0],eax      ;第一个页目录项写入第一个页表的地址。该处的原因是因为使loader在分页时候保存对应原来的位置。
    mov [PAGE_DIR_TABLE_POS + 0xc00],eax    ;第768个页目录项同样写入第一个页表的地址。为了实现操作系统高3GB以上的虚拟地址对应到低端1MB.

    sub eax,0x1000
    mov [PAGE_DIR_TABLE_POS + 4092],eax     ;最后一个页目录项写入页目录基址。

;---创建页表项---
    mov ecx,256
    mov esi,0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx+esi*4],edx                     ;第一个页表，指向的是1MB——0~0xfffff，所以是8位。
    add edx,4096                            ;4096即是一个4K
    inc esi
    loop .create_pte

;---创建内核其他页表的页目录项(PDE)--- 将剩下的254个页目录项项写入页目录中从0x102000开始
    mov eax,PAGE_DIR_TABLE_POS
    add eax, 0x2000                         ;第一个页表为+0x1000，这里是第二个页表的位置+0x2000
    or eax, PG_US_U | PG_RW_W | PG_P 
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx,254
    mov esi,769                             ;769属于操作系统高3GB以上的部分，第二个目录项。
.create_kernel_pde:
    mov [ebx+esi*4],eax
    inc esi
    add eax,0x1000
    loop .create_kernel_pde
    ret

rd_disk_m_32:      
      mov esi,eax      ; 备份eax
      mov di,cx        ; 备份扇区数到di
;第1步：设置要读取的扇区数
      mov dx,0x1f2
      mov al,cl
      out dx,al            ;读取的扇区数

      mov eax,esi      ;恢复ax

;第2步：将LBA地址存入0x1f3 ~ 0x1f6
      mov dx,0x1f3                       
      out dx,al                          

      mov cl,8
      shr eax,cl
      mov dx,0x1f4
      out dx,al

      shr eax,cl
      mov dx,0x1f5
      out dx,al

      shr eax,cl
      and al,0x0f      ;lba第24~27位
      or al,0xe0       ; 设置7～4位为1110,表示lba模式
      mov dx,0x1f6
      out dx,al

;第3步：向0x1f7端口写入读命令，0x20 
      mov dx,0x1f7
      mov al,0x20                        
      out dx,al

;第4步：检测硬盘状态
.not_ready:          
      nop
      in al,dx
      and al,0x88      
      cmp al,0x08
      jnz .not_ready      

;第5步：从0x1f0端口读数据
      mov ax, di       
      mov dx, 256     
      mul dx
      mov cx, ax       
      mov dx, 0x1f0
  .go_on_read:
      in ax,dx      
      mov [ebx], ax
      add ebx, 2
      loop .go_on_read
      ret