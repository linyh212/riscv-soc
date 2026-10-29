#include <stdio.h>
#include <string>
#include <iostream>
#include "Vinst_fetch.h"
#include "Vinst_fetch_inst_fetch.h"
#include "Vinst_fetch_rom.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

#define MAX_SIM_CYCLE 20
vluint64_t main_time = 0;

void sim_mem_load_bin(Vinst_fetch_rom* rom, std::string filename);

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
    Vinst_fetch *top = new Vinst_fetch("top");
    top->trace(tfp, 99);
    tfp->open("wave.vcd");

    // 1. 執行 Reset 重置階段
    top->rst_i = 1;
    for (int i = 0; i < 5; i++) {
        top->clk_i = 0; top->eval(); main_time += 5; tfp->dump(main_time);
        top->clk_i = 1; top->eval(); main_time += 5; tfp->dump(main_time);
    }
    top->rst_i = 0;

    // 2. Reset 完成後載入二進位檔並立即評估狀態
    sim_mem_load_bin(top->inst_fetch->rom0, std::string(argv[1]));
    top->eval();

    // 3. 執行正式模擬
    for (int i = 0; i < MAX_SIM_CYCLE; i++) {
        top->clk_i = 0;
        top->eval();
        main_time += 5;
        tfp->dump(main_time);
        top->clk_i = 1;
        top->eval();
        main_time += 5;
        tfp->dump(main_time);
        printf("[Cycle %02d] PC = 0x%08x, INST = 0x%08x\n", i, top->pc_o, top->inst_o);
    }

    top->final();
    tfp->close();
    delete top;
    delete tfp;
    return 0;
}