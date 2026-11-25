#include <stdint.h>
#include "util.h"

#define TIMER_BASE        0x00300000UL
#define TIMER_CTRL        (*(volatile uint32_t *)(TIMER_BASE + 0x00))
#define TIMER_PRESCALER   (*(volatile uint32_t *)(TIMER_BASE + 0x04))
#define TIMER_VALUE       (*(volatile uint32_t *)(TIMER_BASE + 0x08))
#define TIMER_COMPARE     (*(volatile uint32_t *)(TIMER_BASE + 0x0C))

volatile uint32_t irq_count = 0;

void __attribute__((interrupt("machine"), aligned(4))) trap_handler(void) {
    uint32_t mcause;
    asm volatile ("csrr %0, mcause" : "=r"(mcause));

    // interrupt_ctrl.v 觸發 timer 中斷時會設為 interrupt=1, cause=7 (0x80000007)
    if (mcause == 0x80000007UL) {
        irq_count++;
        // 關鍵：寫入 TIMER_VALUE 會清除 irq_o (irq_o <= 1'b0)，避免一離開 ISR 又立刻重進中斷
        TIMER_VALUE = 0;
    }
}

int main(void) {
    // 1. 設定 mtvec 指向 trap_handler
    asm volatile ("csrw mtvec, %0" :: "r"(&trap_handler));

    // 2. 初始化 Timer 暫存器
    TIMER_CTRL      = 0;      // 先關閉 Timer 並清除殘留中斷
    TIMER_PRESCALER = 9;      // 每 10 個 clock 計數 1 次 (0~9)
    TIMER_VALUE     = 0;      // 計數器歸零
    TIMER_COMPARE   = 100;    // 計數到 100 時觸發中斷 (約 1000 個 clock 一次)

    // 3. 開啟 mie.MTIE (bit 7 = 0x80) 與 mstatus.MIE (bit 3 = 0x8)
    asm volatile ("csrs mie, %0" :: "r"(1 << 7));
    asm volatile ("csrs mstatus, %0" :: "r"(1 << 3));

    // 4. 啟動 Timer：bit[0]=1 (timer_en), bit[1]=1 (auto_reload) -> 0x3
    TIMER_CTRL = 0x3;

    // 5. 等待觸發 3 次 Timer 中斷
    while (irq_count < 3);

    // 6. 關閉 Timer 並結束模擬
    TIMER_CTRL = 0;
    sim_halt();
    return 0;
}