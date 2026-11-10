#ifndef _UTILS_H_
#define _UTILS_H_

#include <stdint.h>

#define DEV_WRITE(addr, val) (*((volatile uint32_t *)(addr)) = (val))
#define DEV_READ(addr)       (*((volatile uint32_t *)(addr)))

void sim_halt(void);

#endif