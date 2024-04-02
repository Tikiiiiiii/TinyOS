;loader.asm
%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
;jmp loader_start 

;构建gdt及其内部的描述符
GDT_BASE:           dd 0x00000000
                    dd 0x00000000

CODE_DESC:          dd 0x0000FFFF
                    dd DESC_CODE_HIGH4

DATA_STACK_DESK:    dd 0x0000FFFF
                    dd DESC_DATA_HIGH4

VIDEO_DESC:         dd 0x80000007               
                    dd DESC_VIDEO_HIGH4

GDT_SIZE            equ $-GDT_BASE
GDT_LIMIT           equ GDT_SIZE-1
times 60 dq 0       ;预留60个段描述符

SELECTOR_CODE       equ (0x0001<<3)+TI_GDT+RPL0  ;相当于 (CODE_DESC-GDT_BASE)/8+TI_GDT+RPL0
SELECTOR_DATA       equ (0x0002<<3)+TI_GDT+RPL0
SELECTOR_VIDEO      equ (0x0003<<3)+TI_GDT+RPL0 

total_mem_bytes     dd 0 ;存放内存大小

gdt_ptr             dw GDT_LIMIT
                    dd GDT_BASE

; 记录 ARDS 结构体数
ards_buf            times   244 db 0
ards_nr             dw      0

loader_start:  
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

    ; 调用参数设置，获取内存布局 
    xor ebx, ebx
    mov edx, 0x534d4150
    mov di, ards_buf

.e820_mem_get_loop:
    mov eax, 0x0000e820     ;执行中断调用
    mov ecx,20
    int 0x15
    jc .e820_failed_so_try_e801     ;根据cd判断成功否，失败使用e801

    add di,cx
    inc word [ards_nr]
    cmp ebx, 0

jnz .e820_mem_get_loop
    ;找到ards中 base_add_low+length_low的最大值即为内存最大值
    mov cx, [ards_nr]
    mov ebx, ards_buf
    xor edx,edx
.find_max_mem_area:
    mov eax,[ebx]
    add eax,[ebx+8]
    add ebx, 20
    cmp edx,eax

    ;冒泡排序
    jge .next_ards
    mov edx,eax
.next_ards:
    loop .find_max_mem_area
    jmp .mem_get_ok

;e801方法
.e820_failed_so_try_e801:
    mov ax,0xe801
    int 0x15
    jc .e801_failed_so_try88 ;失败尝试0x88
    
    ;计算低15MB内存
    mov cx,0x400
    mul cx
    shl edx,16
    and eax,0x0000FFFF
    or edx,eax
    add edx, 0x100000
    mov esi,edx
    
    ;计算16MB以上内存，并单位转换
    xor eax,eax
    mov ax,bx
    mov ecx,0x10000
    mul ecx

    add esi,eax
    mov edx,esi
    jmp .mem_get_ok

;0x88 同理
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

    mov byte [gs:800], 'P'
    ;jmp $

; 创建页目录、页表 初始化内存位图 
    call setup_page
    sgdt[gdt_ptr]
    mov ebx,[gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000
    add dword [gdt_ptr + 2],   0xc0000000

    add esp,0xc0000000
    ;页目录地址赋cr3
    mov eax, PAGE_DIR_TABLE_POS
    mov cr3,eax

    ;打开cr0的pg位
    mov eax,cr0
    or eax,0x80000000
    mov cr0,eax

    ;gdt地址重新加载
    lgdt[gdt_ptr]
    mov byte [gs:960],'V'

    jmp $

setup_page:
    ; 页目录清零
    mov ecx,4096 
    mov esi,0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

;创建PDE
.create_pde:
    mov eax,PAGE_DIR_TABLE_POS
    add eax,0x1000
    mov ebx,eax

    or eax,PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_POS + 0x0],eax      ;写入第一个页表地址0x101000和属性
    mov [PAGE_DIR_TABLE_POS + 0xc00],eax    ;第768个页目录项同样写入0x101000。为了实现操作系统高3GB以上的虚拟地址对应到低端1MB.

    sub eax,0x1000
    mov [PAGE_DIR_TABLE_POS + 4092],eax     ;最后一个页目录项写入页目录基址。

; 创建PTE
    mov ecx,256
    mov esi,0
    mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
    mov [ebx+esi*4],edx                     ;第一个页表，指向的是1MB——0~0xfffff，所以是8位。
    add edx,4096                        
    inc esi
    loop .create_pte

; 创建内核页目录项(PDE) 剩下的254个页目录项从0x102000开始
    mov eax,PAGE_DIR_TABLE_POS
    add eax, 0x2000                         ;第一个页表为+0x1000，这里是第二个页表的位置+0x2000
    or eax, PG_US_U | PG_RW_W | PG_P 
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx,254
    mov esi,769                            
.create_kernel_pde:
    mov [ebx+esi*4],eax
    inc esi
    add eax,0x1000
    loop .create_kernel_pde
    ret