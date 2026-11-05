.section .text
.global _start

_start:
    # 1. 準備基礎數據 (使用 Type-I ori 寫入暫存器)
    ori   x1, x0, 20       # x1 = 20
    ori   x2, x0, 5        # x2 = 5
    ori   x3, x0, -10      # x3 = -10 (0xFFFFFFF6)

    # 2. 測試 R-Type 指令 (兼測 Data Forwarding 衝突處置)
    add   x4, x1, x2       # x4  = 20 + 5 = 25 (0x19)
    sub   x5, x1, x2       # x5  = 20 - 5 = 15 (0x0F)
    sll   x6, x1, x2       # x6  = 20 << 5 = 640 (0x280)
    slt   x7, x3, x1       # x7  = (-10 < 20) ? 1 : 0 -> 1
    sltu  x8, x3, x1       # x8  = (0xFFFFFFF6 < 20) ? 1 : 0 -> 0 (unsigned 比較)
    xor   x9, x1, x2       # x9  = 20 ^ 5 = 17 (0x11)
    srl   x10, x1, x2      # x10 = 20 >> 5 = 0
    sra   x11, x3, x2      # x11 = -10 >>> 5 = -1 (0xFFFFFFFF)
    or    x12, x1, x2      # x12 = 20 | 5 = 21 (0x15)
    and   x13, x1, x2      # x13 = 20 & 5 = 4  (0x04)