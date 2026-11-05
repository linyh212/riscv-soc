.section .text
.global _start

_start:
    ori x5, x5, 1    # x5 = 0 | 1 = 1
    ori x1, x5, 2    # x1 = x5 (Forwarded from EXE) | 2 = 1 | 2 = 3
    ori x2, x5, 4    # x2 = x5 (Forwarded from MEM) | 4 = 1 | 4 = 5
    ori x3, x5, 8    # x3 = x5 (Forwarded from WB/Regfile) | 8 = 1 | 8 = 9
    ori x4, x5, 16   # x4 = x5 (Read directly from Regfile) | 16 = 1 | 16 = 17 (0x11)