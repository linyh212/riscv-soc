#include "util.h"
#include "soc_reg.h"
#include "kprintf.h"

int main(void) 
{
    int c = 0x31;
    char *s = "Hello";
    kprintf("DCLab RISC-V SoC %s %c, %d, %x, %p\n", s, c, c, c, s);
    sim_halt();
    return 0;
}