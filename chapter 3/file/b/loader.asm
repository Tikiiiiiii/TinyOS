%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
    mov byte [gs:160],'2'
    mov byte [gs:161],0x24
    mov byte [gs:162],' '
    mov byte [gs:163],0x24
    mov byte [gs:164],'L'
    mov byte [gs:165],0x24
    mov byte [gs:166],'o'
    mov byte [gs:167],0x24
    mov byte [gs:168],'a'
    mov byte [gs:169],0x24
    mov byte [gs:170],'d'
    mov byte [gs:171],0x24
    mov byte [gs:172],'e'
    mov byte [gs:173],0x24
    mov byte [gs:174],'r'
    mov byte [gs:175],0x24
jmp $