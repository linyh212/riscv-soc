.section .text
.global _start

_start:
    li      gp, 0

    li      x2, 10
    li      x4, 20
    bne     x2, x4, test_beq_pass
    li      gp, 4
    j       fail

test_beq_pass:
    li      x4, 10
    beq     x2, x4, test_blt_pass
    li      gp, 6
    j       fail

test_blt_pass:
    li      x2, -5
    li      x4, 5
    blt     x2, x4, test_bge_pass
    li      gp, 8
    j       fail

test_bge_pass:
    bge     x4, x2, test_bltu_pass
    li      gp, 10
    j       fail

test_bltu_pass:
    li      x2, 5                   
    li      x4, -5                  
    bltu    x2, x4, test_bgeu_pass
    li      gp, 12
    j       fail

test_bgeu_pass:
    bgeu    x4, x2, test_jal_pass
    li      gp, 14
    j       fail

test_jal_pass:
    jal     x1, func_jal            
    li      gp, 16
    j       fail

func_jal:
    la      x7, test_jal_pass + 4
    bne     x1, x7, fail_jal_link
    j       test_jalr_start

fail_jal_link:
    li      gp, 18
    j       fail

test_jalr_start:
    la      x6, target_jalr
    jalr    x5, x6, 0               
    li      gp, 20
    j       fail

target_jalr:
    li      gp, 1
pass_loop:
    j       pass_loop

fail:
1:  j       1b

.end