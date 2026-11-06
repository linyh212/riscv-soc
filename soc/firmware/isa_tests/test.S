.section .text
.global _start

_start:
    # ------------------------------------------------------------------
    # 1. 測試 BNE & BEQ (Equal / Not Equal Comparison)
    # ------------------------------------------------------------------
    li      x2, 10
    li      x3, 20
    bne     x2, x3, test_beq_pass   # 應該跳轉 (10 != 20)
    li      x10, 0xEE01             # Error: BNE 失敗
    j       fail

test_beq_pass:
    li      x3, 10
    beq     x2, x3, test_blt_pass   # 應該跳轉 (10 == 10)
    li      x10, 0xEE02             # Error: BEQ 失敗
    j       fail

# ------------------------------------------------------------------
# 2. 測試 BLT & BGE (Signed Comparison)
# ------------------------------------------------------------------
test_blt_pass:
    li      x2, -5
    li      x3, 5
    blt     x2, x3, test_bge_pass   # 應該跳轉 (-5 < 5)
    li      x10, 0xEE03             # Error: BLT 失敗
    j       fail

test_bge_pass:
    bge     x3, x2, test_bltu_pass  # 應該跳轉 (5 >= -5)
    li      x10, 0xEE04             # Error: BGE 失敗
    j       fail

# ------------------------------------------------------------------
# 3. 測試 BLTU & BGEU (Unsigned Comparison)
# ------------------------------------------------------------------
test_bltu_pass:
    li      x2, 5                   # 0x00000005
    li      x3, -5                  # 0xFFFFFFFB (Unsigned 巨大數值)
    bltu    x2, x3, test_bgeu_pass  # 應該跳轉 (5 < 0xFFFFFFFB)
    li      x10, 0xEE05             # Error: BLTU 失敗
    j       fail

test_bgeu_pass:
    bgeu    x3, x2, test_jal_pass   # 應該跳轉 (0xFFFFFFFB >= 5)
    li      x10, 0xEE06             # Error: BGEU 失敗
    j       fail

# ------------------------------------------------------------------
# 4. 測試 JAL (Jump and Link: Save PC+4 to rd)
# ------------------------------------------------------------------
test_jal_pass:
    jal     x1, func_jal            # 跳轉並將 PC+4 (0x0000003C) 寫入 x1
    li      x10, 0xEE07             # Error: JAL 未跳轉
    j       fail

func_jal:
    # 驗證 ra (x1) 存入的回傳位址是否正確
    la      x4, test_jal_pass + 4
    bne     x1, x4, fail_jal_link

# ------------------------------------------------------------------
# 5. 測試 JALR (Jump and Link Register: Base + Imm & ~1)
# ------------------------------------------------------------------
    la      x6, target_jalr
    jalr    x5, x6, 0               # 跳轉至 target_jalr 並將 PC+4 寫入 x5
    li      x10, 0xEE08             # Error: JALR 未跳轉
    j       fail

fail_jal_link:
    li      x10, 0xEE09             # Error: JAL 寫回 PC+4 數值不符
    j       fail

target_jalr:
    # ------------------------------------------------------------------
    # 6. 全部測試通過
    # ------------------------------------------------------------------
    li      x10, 0x666              # Pass Code
pass_loop:
    j       pass_loop

fail:
    # 測試失敗循環
1:  j       1b

.end