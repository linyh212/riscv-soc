.section .text
.global _start

_start:
    # 1. 準備基礎數據
    li  x1, 0x12345678
    li  x2, 0xABCDEF99
    la  x3, _array

    # 2. 測試 Store 指令 (SW, SH, SB)
    sw  x1, 0(x3)            # M[_array + 0] = 0x12345678
    sh  x2, 4(x3)            # M[_array + 4] = 0x----EF99
    sb  x1, 6(x3)            # M[_array + 6] = 0x--78----

    # 3. 測試 Load 指令 (LW, LH, LHU, LB, LBU) 及其擴充行為
    lw  x4, 0(x3)            # x4  = 0x12345678
    lh  x5, 4(x3)            # x5  = 0xFFFFEF99 (Sign-extended)
    lhu x6, 4(x3)            # x6  = 0x0000EF99 (Zero-extended)
    lb  x7, 6(x3)            # x7  = 0x00000078 (Sign-extended, MSB=0)
    lbu x8, 4(x3)            # x8  = 0x00000099 (Zero-extended)

    # 4. Load-Use Hazard 驗證 (緊接 Load 使用暫存器)
    lh  x9, 0(x3)            # x9  = 0x5678
    add x10, x9, x1          # 測試 Pipeline 是否自動完成 1 Cycle Stall

_array:
    .word 0x00000000
    .word 0x00000000

    .end