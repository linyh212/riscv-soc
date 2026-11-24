#include <cstdint>
#include <iostream>
#include <memory>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vtest_top.h"
#include "Vtest_top_dpram__R100000_RB14.h"
#include "Vtest_top_regfile.h"
#include "Vtest_top_test_top.h"

void sim_mem_load_bin(Vtest_top_dpram__R100000_RB14* rom, Vtest_top_dpram__R100000_RB14* ram, std::string fn);

namespace {
    constexpr const char* kDefaultBinPath = "soc/firmware/isa_tests/test.bin";
    constexpr int kResetCycles = 5;
    constexpr uint64_t kIsaMaxCycles = 100'000ULL;
    constexpr uint64_t kCoremarkMaxCycles = 1'000'000'000ULL;
    // 記錄模擬時間以供波形產生
    vluint64_t main_time = 0;
    // 推進單一 Clock 週期並紀錄波形
    void step_clock(Vtest_top* top, VerilatedVcdC* tfp = nullptr) {
        top->clk_i = 1;
        top->eval();
        if (tfp) tfp->dump(main_time++);
        top->clk_i = 0;
        top->eval();
        if (tfp) tfp->dump(main_time++);
    }
    // 解析 RISC-V ISA Test 的 gp (x3) 狀態：回傳 0 為 PASS，>0 為 FAIL 測項編號，-1 為尚未結束
    int check_gp_result(uint32_t gp, bool allow_halt_pass = false) {
        if (gp == 1) {
            std::cout << "\n[RESULT] PASS" << std::endl;
            return 0;
        }
        if (gp > 1 && (gp & 1U)) {
            int failed_case = static_cast<int>(gp >> 1);
            std::cout << "\n[RESULT] FAIL (Test Case #" << failed_case << ")" << std::endl;
            return failed_case;
        }
        if (allow_halt_pass) {
            std::cout << "\n[RESULT] PASS (Halted by console software request)" << std::endl;
            return 0;
        }
        return -1;
    }
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vtest_top>();
    std::string bin_file = (argc > 1) ? argv[1] : kDefaultBinPath;
    bool is_isa_test = (bin_file.find(kDefaultBinPath) != std::string::npos);
    // 僅在執行簡短 ISA 測試時建立波形紀錄，避免 CoreMark 產生過大 VCD 檔拖慢速度
    std::unique_ptr<VerilatedVcdC> tfp = nullptr;
    if (is_isa_test) {
        Verilated::traceEverOn(true);
        tfp = std::make_unique<VerilatedVcdC>();
        top->trace(tfp.get(), 99);
        tfp->open("wave.vcd");
    }
    // 載入測試二進位檔至記憶體
    sim_mem_load_bin(top->test_top->data_ram0, top->test_top->data_ram0, bin_file);
    // 系統重置 (Reset) 階段
    top->rst_i = 1;
    for (int i = 0; i < kResetCycles; ++i) {
        step_clock(top.get(), tfp.get());
    }
    top->rst_i = 0;
    // 依據測試類型設定週期上限（放寬至 10 億 cycles 以容納 CoreMark 跑分）
    const uint64_t max_cycles = is_isa_test ? kIsaMaxCycles : kCoremarkMaxCycles;
    uint64_t current_cycle = 0;
    int exit_code = -1;
    // 主模擬迴圈
    while (!Verilated::gotFinish() && current_cycle < max_cycles) {
        step_clock(top.get(), tfp.get());
        current_cycle++;
        uint32_t gp = top->test_top->regfile0->regs[3];
        // ISA 測試期間即時監控 gp (x3) 暫存器是否已寫入結果
        if (is_isa_test) {
            exit_code = check_gp_result(gp, /*allow_halt_pass=*/false);
            if (exit_code != -1) break;
        }
        // 軟體主動請求 Console Halt 結束模擬
        if (top->test_top->__PVT__console_halt_o) {
            exit_code = check_gp_result(gp, /*allow_halt_pass=*/true);
            break;
        }
    }
    // 逾時檢查與資源釋放
    if (exit_code == -1) std::cout << "\n[RESULT] TIMEOUT after " << current_cycle << " cycles" << std::endl;
    top->final();
    if (tfp) tfp->close();
    return exit_code;
}