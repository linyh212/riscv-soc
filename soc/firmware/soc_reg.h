#ifndef __SOC_REGS_H__
#define __SOC_REGS_H__

// Console MMIO
#define CTRL_BASE        0x00200000
#define CTRL_OUT         0x4
#define CTRL_CTRL        0x8

// Timer MMIO
#define TIMER_BASE       0x00300000
#define TIMER_CTRL       0x00
#define TIMER_PRESCALER  0x04
#define TIMER_VALUE      0x08
#define TIMER_COMPARE    0x0C

#endif  // __SOC_REGS_H__