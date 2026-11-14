#include "util.h"
#include "soc_reg.h"

void sim_halt(void) 
{ 
    DEV_WRITE(CTRL_BASE + CTRL_CTRL, 1); 
}

uint64_t get_cycle_value(void)
{
    uint32_t cycle_lo, cycle_hi, cycle_hi_check;
    do {
        asm volatile("csrr %0, mcycleh" : "=r"(cycle_hi));
        asm volatile("csrr %0, mcycle"  : "=r"(cycle_lo));
        asm volatile("csrr %0, mcycleh" : "=r"(cycle_hi_check));
    } while (cycle_hi != cycle_hi_check);

    return ((uint64_t)cycle_hi << 32) | cycle_lo;
}