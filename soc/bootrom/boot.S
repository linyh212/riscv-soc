.section .text.init
.global _start
_start:
    csrw mie, zero
    csrw mip, zero
    li sp, 0x000FFFF0      # Stack 設在 1MB RAM 的最頂端
    call boot_main
    li t0, 0x00000000      # 跳轉至 Main RAM 起始位址執行主程式！
    jr t0