#include <stdio.h>
#include <string>
#include <iostream>
#include "Vtest_top.h"
#include "Vtest_top_test_top.h"
#include "Vtest_top_rom.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define MAX_SIM_CYCLE 10
vluint64_t main_time = 0;

void sim_mem_load_bin(Vtest_top_rom* rom, std::string filename);

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char **argv) {
    Verilated::commandArgs(argc, argv);
    Verilated::traceEverOn(true);

    if (argc < 2) {
        printf("Usage: %s <binary_file>\n", argv[0]);
        return -1;
    }

    VerilatedVcdC* tfp = new VerilatedVcdC();
    Vtest_top *top = new Vtest_top("top");

    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    // 載入二進位檔案
    sim_mem_load_bin(top->test_top->rom0, std::string(argv[1]));

    // Reset 階段
    top->rst_i = 1;
    for (int i = 0; i < 5; i++) {
        top->clk_i = 0; top->eval(); main_time += 5; tfp->dump(main_time);
        top->clk_i = 1; top->eval(); main_time += 5; tfp->dump(main_time);
    }
    top->rst_i = 0;

    // 模擬階段
    for (int i = 0; i < MAX_SIM_CYCLE; i++) {
        top->clk_i = 0; top->eval(); main_time += 5; tfp->dump(main_time);
        top->clk_i = 1; top->eval(); main_time += 5; tfp->dump(main_time);

        printf("[Cycle %02d] PC = 0x%08x | IF_INST = 0x%08x | ID_INST = 0x%08x | OP1 = 0x%08x | OP2(Imm) = 0x%08x\n",
               i,
               top->pc_o,
               top->if_inst_o,
               top->if_id_inst_o,
               top->id_op1_o,
               top->id_op2_o);
    }

    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}