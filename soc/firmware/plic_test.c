#include <stdint.h>
#include "kprintf.h"
#include "util.h"

// PLIC 暫存器定義
#define PLIC_BASE 0x0C000000
#define PLIC_PRIORITY(id) (*(volatile uint32_t *)(PLIC_BASE + (id) * 4))
#define PLIC_PENDING (*(volatile uint32_t *)(PLIC_BASE + 0x001000))
#define PLIC_ENABLE (*(volatile uint32_t *)(PLIC_BASE + 0x002000))
#define PLIC_THRESHOLD (*(volatile uint32_t *)(PLIC_BASE + 0x200000))
#define PLIC_CLAIM (*(volatile uint32_t *)(PLIC_BASE + 0x200004))
#define PLIC_SW_TRIG (*(volatile uint32_t *)(PLIC_BASE + 0x200008))

// 現有 Timer0 暫存器定義 (0x00300000)
#define TIMER_CTRL (*(volatile uint32_t *)0x00300000)
#define TIMER_PRESCALER (*(volatile uint32_t *)0x00300004)
#define TIMER_VALUE (*(volatile uint32_t *)0x00300008)
#define TIMER_COMPARE (*(volatile uint32_t *)0x0030000C)

static volatile uint32_t claim_order[4];
static volatile uint32_t irq_count = 0;

// Trap Handler (需 4-byte 對齊)
void __attribute__((interrupt, aligned(4))) trap_handler(void)
{
    uint32_t mcause;
    asm volatile("csrr %0, mcause" : "=r"(mcause));

    // 確認為 Machine External Interrupt (0x8000000B)
    if (mcause == 0x8000000BU)
    {
        uint32_t id = PLIC_CLAIM; // 1. Claim 取得最高優先權 ID
        if (id != 0)
        {
            if (irq_count < 4)
            {
                claim_order[irq_count++] = id;
            }
            // 2. 清除對應周邊的中斷來源
            if (id == 1)
            {
                TIMER_CTRL = 0; // 關閉 Timer 並清除 irq_o
                TIMER_VALUE = 0;
            }
            else
            {
                PLIC_SW_TRIG &= ~(1U << id); // 清除測試 IRQ
            }
            // 3. Complete 通知 PLIC 解除 Gateway 鎖定
            PLIC_CLAIM = id;
        }
    }
}

int main(void)
{
    kprintf("=== Starting PLIC Verification ===\n");

    // 1. 設定 Trap Vector (Direct Mode)
    asm volatile("csrw mtvec, %0" ::"r"((uint32_t)trap_handler));

    // 2. 測試一：多中斷同時觸發的優先權仲裁 (Source 2 Prio=2 vs Source 3 Prio=5)
    PLIC_PRIORITY(2) = 2;
    PLIC_PRIORITY(3) = 5;
    PLIC_THRESHOLD = 1;
    PLIC_ENABLE = (1U << 2) | (1U << 3);

    // 同時拉高 Source 2 與 Source 3
    PLIC_SW_TRIG = (1U << 2) | (1U << 3);

    // 開啟 mie.MEIE (Bit 11) 與 mstatus.MIE (Bit 3)
    asm volatile("csrs mie, %0" ::"r"(1U << 11));
    asm volatile("csrs mstatus, %0" ::"r"(1U << 3));

    while (irq_count < 2)
    {
        asm volatile("nop");
    }

    kprintf("Arbitration order: first=%d, second=%d\n", claim_order[0], claim_order[1]);
    if (claim_order[0] != 3 || claim_order[1] != 2)
    {
        kprintf("[RESULT] FAIL (Priority arbitration mismatch)\n");
        sim_halt();
        return 1;
    }

    // 3. 測試二：現有 Timer0 透過 PLIC Source 1 觸發外部中斷
    PLIC_PRIORITY(1) = 4;
    PLIC_ENABLE |= (1U << 1);

    TIMER_PRESCALER = 0;
    TIMER_VALUE = 0;
    TIMER_COMPARE = 50; // 50 cycles 後觸發
    TIMER_CTRL = 1;     // Enable Timer (One-shot)

    while (irq_count < 3)
    {
        asm volatile("nop");
    }

    kprintf("Timer0 PLIC IRQ claimed ID: %d\n", claim_order[2]);
    if (claim_order[2] == 1)
    {
        kprintf("[RESULT] PASS\n");
    }
    else
    {
        kprintf("[RESULT] FAIL\n");
    }
    sim_halt();
    return 0;
}
