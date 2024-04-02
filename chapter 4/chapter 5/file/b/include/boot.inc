;loader 和 kernel
LOADER_BASE_ADDR    equ 0x900
LOADER_START_SECTOR equ 0x2
LOADER_STACK_TOP    equ LOADER_BASE_ADDR ;应该出现在boot.inc而不是loader.asm
;gdt描述符属性 
DESC_G_4K           equ 100000000000000000000000b
DESC_D_32           equ  10000000000000000000000b
DESC_L              equ   0000000000000000000000b 
DESC_AVL            equ    000000000000000000000b 
DESC_LIMIT_CODE2    equ     11110000000000000000b
DESC_LIMIT_DATA2    equ     DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2   equ      0000000000000000000b 
DESC_P              equ         1000000000000000b 
DESC_DPL_0          equ          000000000000000b 
DESC_DPL_1          equ          010000000000000b 
DESC_DPL_2          equ          100000000000000b 
DESC_DPL_3          equ          110000000000000b
DESC_S_CODE         equ            1000000000000b 
DESC_S_DATA         equ             DESC_S_CODE
DESC_S_sys          equ            0000000000000b 
DESC_TYPE_CODE      equ             100000000000b
;x=1,c=0,r=0,a=0 代码段是可执行的，非一致性，不可读，巳访问位a清零
DESC_TYPE_DATA      equ             001000000000b 
;x=0,e=0,w=1,a=0 数据段是不可执行的，向上扩展的，可写，己访问位a清零

DESC_CODE_HIGH4     equ           (0x00<<24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + \
DESC_P + DESC_DPL_0 + DESC_S_CODE + \
DESC_TYPE_CODE + 0x00

DESC_DATA_HIGH4     equ           (0x00<<24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x00

DESC_VIDEO_HIGH4    equ           (0x00<<24) + DESC_G_4K + DESC_D_32 + \
DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + \
DESC_P + DESC_DPL_0 + DESC_S_DATA + \
DESC_TYPE_DATA + 0x0b

;选择子属性
RPL0    equ 00b 
RPL1    equ 01b 
RPL2    equ 10b 
RPL3    equ 11b 
TI_GDT   equ 000b
TI_LDT   equ 100b

; 页目录表基地址
PAGE_DIR_TABLE_POS	equ	0x100000

; 页表相关属性
PG_P 		equ	1b
PG_RW_R		equ 00b
PG_RW_W		equ	10b
PG_US_S		equ	000b
PG_US_U		equ	100b