#ifndef __KERNEL_INTERRUPT_H
#define __KERNEL_INTERRUPT_H

#include "stdint.h"
typedef void* intr_handler;
enum intr_status{
    INTR_OFF,
    INTR_ON
};

void idt_init();

enum intr_status intr_get_status(void);
enum intr_status intr_set_status(enum intr_status);
enum intr_status intr_enable(void);
enum intr_status intr_disable(void);

 #endif
