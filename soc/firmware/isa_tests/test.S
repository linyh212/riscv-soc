.section .text
.global _start

_start:
    ori x5, x4, 2    # Mechanical code expected: 00226293
    ori x5, x4, 3    # Mechanical code expected: 00326293
    ori x5, x4, 4    # Mechanical code expected: 00426293
    ori x5, x4, 5    # Mechanical code expected: 00526293