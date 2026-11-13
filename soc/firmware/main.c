#include <stdint.h>
#include "soc_reg.h"
#include "kprintf.h"
#include "util.h"

// CLINT 暫存器位址 (依你的 bus.v 設定調整)
#define CLINT_BASE          0x02000000
#define CLINT_MSIP          (*(volatile uint32_t *)(CLINT_BASE + 0x0000))
#define CLINT_MTIMECMP_LO   (*(volatile uint32_t *)(CLINT_BASE + 0x4000))
#define CLINT_MTIMECMP_HI   (*(volatile uint32_t *)(CLINT_BASE + 0x4004))
#define CLINT_MTIME_LO      (*(volatile uint32_t *)(CLINT_BASE + 0xBFF8))
#define CLINT_MTIME_HI      (*(volatile uint32_t *)(CLINT_BASE + 0xBFFC))

volatile int irq_count = 0;

static inline void set_next_timer(uint32_t delta) {
    uint32_t lo = CLINT_MTIME_LO;
    uint32_t hi = CLINT_MTIME_HI;
    uint32_t next_lo = lo + delta;
    // 處理 32-bit 進位
    if (next_lo < lo) {
        hi += 1;
    }
    // 依 RISC-V 規範，更新 64-bit mtimecmp 時先將高位設為最大值避免誤觸發
    CLINT_MTIMECMP_HI = 0xFFFFFFFF;
    CLINT_MTIMECMP_LO = next_lo;
    CLINT_MTIMECMP_HI = hi;
}

void __attribute__((interrupt("machine"))) trap_handler(void) {
    uint32_t mcause;
    asm volatile("csrr %0, mcause" : "=r"(mcause));

    // Machine Timer Interrupt: bit 31 = 1, code = 7 (0x80000007)
    if (mcause == 0x80000007) {
        irq_count++;
        kprintf("Timer IRQ triggered! count = %d\n", irq_count);
        set_next_timer(1000);
    }
}

int main(void) {
    // 1. 設定 mtvec 指向 trap_handler (Direct Mode: mode = 00)
    asm volatile("csrw mtvec, %0" : : "r"(&trap_handler));

    // 2. 設定第一次 Timer 中斷時間
    set_next_timer(1000);

    // 3. 開啟 mie.MTIE (bit 7) 與全域中斷 mstatus.MIE (bit 3)
    asm volatile("csrs mie, %0" : : "r"(1 << 7));
    asm volatile("csrs mstatus, %0" : : "r"(1 << 3));

    while (irq_count < 3) {
        // 等待中斷發生
    }

    // Prevent another timer interrupt from interleaving with the final message.
    asm volatile("csrc mstatus, %0" : : "r"(1 << 3));
    kprintf("All 3 Timer Interrupts handled successfully!\n");
    sim_halt();
    return 0;
}
