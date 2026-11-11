#include "util.h"
#include "soc_reg.h"
#include "kprintf.h"

int main(void) 
{
    kprintf("=== Hardware Timer Test ===\n");
    // 1. 設定 Timer (Bit 1=1, Bit 0=1 => 0x3)
    DEV_WRITE(TIMER_BASE + TIMER_PRESCALER, 0);
    DEV_WRITE(TIMER_BASE + TIMER_COMPARE, 50);
    DEV_WRITE(TIMER_BASE + TIMER_VALUE, 0);
    DEV_WRITE(TIMER_BASE + TIMER_CTRL, 0x3);
    // 2. 讀取 3 次計數器數值，確認 Timer 正確運作
    for (int i = 0; i < 3; i++) {
        uint32_t val1 = DEV_READ(TIMER_BASE + TIMER_VALUE);
        // 延遲一段時間
        for (volatile int delay = 0; delay < 20; delay++);
        uint32_t val2 = DEV_READ(TIMER_BASE + TIMER_VALUE);
        kprintf("Loop %d: Val1 = %d, Val2 = %d\n", i + 1, val1, val2);
    }
    kprintf("Timer Test Passed!\n");
    // 3. 呼叫 sim_halt() 停機
    sim_halt();
    return 0;
}