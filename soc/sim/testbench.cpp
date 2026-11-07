#include <iostream>
#include <fstream>
#include <memory>
#include <string>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vtest_top.h"
#include "Vtest_top_test_top.h"
#include "Vtest_top_regfile.h"
#include "Vtest_top_rom.h"
#include "Vtest_top_ram.h"

void sim_mem_load_bin(Vtest_top_rom* rom, Vtest_top_ram* ram, std::string fn);

void step_clock(Vtest_top* top) {
    top->clk_i = 1;
    top->eval();
    top->clk_i = 0;
    top->eval();
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vtest_top>();

    std::string bin_file = (argc > 1) ? argv[1] : "soc/firmware/isa_tests/test.bin";
    sim_mem_load_bin(top->test_top->rom0, top->test_top->ram0, bin_file);

    top->rst_i = 1;
    for (int i = 0; i < 5; ++i) {
        step_clock(top.get());
    }
    top->rst_i = 0;

    int max_cycles = 50000;
    int current_cycle = 0;
    bool finished = false;
    int exit_code = -1;

    while (!Verilated::gotFinish() && current_cycle < max_cycles) {
        step_clock(top.get());
        current_cycle++;

        uint32_t gp = top->test_top->regfile0->regs[3];

        if (gp == 1) {
            std::cout << "[RESULT] PASS" << std::endl;
            finished = true;
            exit_code = 0;
            break;
        } else if (gp > 1) {
            uint32_t fail_case = gp >> 1;
            std::cout << "[RESULT] FAIL (Test Case #" << fail_case << ")" << std::endl;
            finished = true;
            exit_code = static_cast<int>(fail_case);
            break;
        }
    }

    if (!finished) {
        std::cout << "[RESULT] TIMEOUT after " << current_cycle << " cycles" << std::endl;
    }

    return exit_code;
}
