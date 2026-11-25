#include <stdint.h>

#define CONSOLE_TX_ADDR 0x00200004

static void boot_puts(const char *s) {
    volatile uint32_t *uart = (volatile uint32_t *)CONSOLE_TX_ADDR;
    while (*s) {
        *uart = (uint32_t)(*s++);
    }
}

void boot_main(void) {
    boot_puts("[BOOTROM] RV32 SoC Booting from 0x10000000...\n");
    boot_puts("[BOOTROM] Jumping to Main RAM (0x00000000)...\n");
    asm volatile ("fence.i");
}