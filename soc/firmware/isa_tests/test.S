.text
.global _start

_start:
    # 初始化 x3 = 0，避免測試過程中途誤觸發 PASS/FAIL
    li x3, 0

    # --- Test Case 1: CSRRWI (imm = 0x15) ---
    csrrwi x4, mscratch, 0x15   # mscratch <- 0x15, x4 <- 0
    li x15, 0
    bne x4, x15, fail_1

    # --- Test Case 2: CSRRSI (imm = 0x08) & Data Hazard ---
    csrrsi x5, mscratch, 0x08   # mscratch <- 0x15 | 0x08 = 0x1D, x5 <- 0x15
    li x15, 0x15
    bne x5, x15, fail_2

    # --- Test Case 3: CSRRCI (imm = 0x05) & Data Hazard ---
    csrrci x6, mscratch, 0x05   # mscratch <- 0x1D & ~0x05 = 0x18, x6 <- 0x1D
    li x15, 0x1D
    bne x6, x15, fail_3

    # --- Test Case 4: CSRRS (rs1 = 0xF0) ---
    li x7, 0x000000F0
    csrrs x8, mscratch, x7      # mscratch <- 0x18 | 0xF0 = 0xF8, x8 <- 0x18
    li x15, 0x18
    bne x8, x15, fail_4

    # --- Test Case 5: CSRRC (rs1 = 0x30) ---
    li x9, 0x00000030
    csrrc x10, mscratch, x9     # mscratch <- 0xF8 & ~0x30 = 0xC8, x10 <- 0xF8
    li x15, 0xF8
    bne x10, x15, fail_5

    # --- Test Case 6: CSRRW (rs1 = 0x12345678) 並驗證前一步結果 0xC8 ---
    li x11, 0x12345678
    csrrw x12, mscratch, x11    # mscratch <- 0x12345678, x12 <- 0xC8
    li x15, 0xC8
    bne x12, x15, fail_6

    # --- Test Case 7: 連續 CSRRW 驗證緊鄰 Data Hazard (MEM -> EXE Forwarding) ---
    li x13, 0xAABBCCDD
    csrrw x14, mscratch, x13    # mscratch <- 0xAABBCCDD, x14 <- 0x12345678
    li x15, 0x12345678
    bne x14, x15, fail_7

    # --- Test Case 8: 驗證唯讀保護 (rs1 = x0 時 CSRRS 不應改寫 mscratch) ---
    csrrs x16, mscratch, x0     # x16 <- 0xAABBCCDD, mscratch 維持不變
    li x15, 0xAABBCCDD
    bne x16, x15, fail_8

pass:
    li x3, 1                    # 設定 gp (x3) = 1，通知 testbench PASS
    j done

fail_1: li x3, (1 << 1) | 1; j done
fail_2: li x3, (2 << 1) | 1; j done
fail_3: li x3, (3 << 1) | 1; j done
fail_4: li x3, (4 << 1) | 1; j done
fail_5: li x3, (5 << 1) | 1; j done
fail_6: li x3, (6 << 1) | 1; j done
fail_7: li x3, (7 << 1) | 1; j done
fail_8: li x3, (8 << 1) | 1; j done

done:
    j done
.end