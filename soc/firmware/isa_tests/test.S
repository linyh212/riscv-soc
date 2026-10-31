.section .text
.global _start

_start:
    # ori x5, x3, -2
    # Machine Code : 0xffe1e293
    # imm = -2 (0xffe / 12-bit signed), rs1 = x3 (00011), funct3 = ori (110), rd = x5 (00101), opcode = 0010011
    ori x5, x3, -2