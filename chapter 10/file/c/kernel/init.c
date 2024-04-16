#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "../device/timer.h"
#include "../device/keyboard.h"
#include "memory.h"

/*负责初始化所有模块*/
void init_all()
{
    put_str("init_all\n");
    idt_init(); //初始化中断
    mem_init();
    thread_init();
    timer_init();
    console_init();
    keyboard_init();
}
