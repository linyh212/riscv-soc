#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <cstdint>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtest_top.h"
#include "Vtest_top_test_top.h"
#include "Vtest_top_regfile.h"
#include "Vtest_top_dpram__R100000_RB14.h"

void sim_mem_load_bin(Vtest_top_dpram__R100000_RB14* rom, Vtest_top_dpram__R100000_RB14* ram, std::string fn);

// 記錄模擬時間以供波形產生
vluint64_t main_time = 0;

void step_clock(Vtest_top* top, VerilatedVcdC* tfp = nullptr) {
    top->clk_i = 1;
    top->eval();
    if (tfp) tfp->dump(main_time++);

    top->clk_i = 0;
    top->eval();
    if (tfp) tfp->dump(main_time++);
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vtest_top>();

    std::string bin_file = (argc > 1) ? argv[1] : "soc/firmware/isa_tests/test.bin";
    bool use_gp_result = bin_file.find("soc/firmware/isa_tests/test.bin") != std::string::npos;

    // 僅在執行簡短 ISA 測試時建立波形紀錄，避免 CoreMark 產生過大 wave.vcd 拖慢速度
    std::unique_ptr<VerilatedVcdC> tfp = nullptr;
    if (use_gp_result) {
        Verilated::traceEverOn(true);
        tfp = std::make_unique<VerilatedVcdC>();
        top->trace(tfp.get(), 99);
        tfp->open("wave.vcd");
    }

    sim_mem_load_bin(top->test_top->data_ram0, top->test_top->data_ram0, bin_file);

    // Reset 階段
    top->rst_i = 1;
    for (int i = 0; i < 5; ++i) {
        step_clock(top.get(), tfp.get());
    }
    top->rst_i = 0;

    // 放寬週期上限至 10 億個 cycles 以容納 CoreMark 完整跑分
    uint64_t max_cycles = use_gp_result ? 100000ULL : 1000000000ULL;
    uint64_t current_cycle = 0;
    bool finished = false;
    int exit_code = -1;

    while (!Verilated::gotFinish() && current_cycle < max_cycles) {
        step_clock(top.get(), tfp.get());
        current_cycle++;

        if (use_gp_result) {
            uint32_t gp = top->test_top->regfile0->regs[3];
            if (gp == 1) {
                std::cout << "[RESULT] PASS" << std::endl;
                finished = true;
                exit_code = 0;
                break;
            } else if (gp > 1 && (gp & 1U)) {
                std::cout << "[RESULT] FAIL (Test Case #" << (gp >> 1) << ")" << std::endl;
                finished = true;
                exit_code = static_cast<int>(gp >> 1);
                break;
            }
        }

        // ISA tests use x3 as the in-progress case number, then set its final
        // pass/fail code before asking the console to halt.
        if (top->test_top->__PVT__console_halt_o) {
            uint32_t gp = top->test_top->regfile0->regs[3];
            if (gp > 1 && (gp & 1U)) {
                std::cout << "\n[RESULT] FAIL (Test Case #" << (gp >> 1) << ")" << std::endl;
                exit_code = static_cast<int>(gp >> 1);
            } else if (gp == 1) {
                std::cout << "\n[RESULT] PASS" << std::endl;
                exit_code = 0;
            } else {
                std::cout << "\n[RESULT] PASS (Halted by console software request)" << std::endl;
                exit_code = 0;
            }
            finished = true;
            break;
        }
    }

    if (!finished) {
        std::cout << "[RESULT] TIMEOUT after " << current_cycle << " cycles" << std::endl;
    }

    top->final();
    if (tfp) tfp->close();

    return exit_code;
}