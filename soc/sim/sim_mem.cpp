#include <cstdint>
#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include "Vtest_top.h"
#include "Vtest_top_rom.h"
#include "Vtest_top_ram.h"
#include "Vtest_top_regfile.h"

void sim_mem_write(Vtest_top_rom* rom, uint32_t addr, size_t length, const void* bytes) {
    const uint8_t* p = reinterpret_cast<const uint8_t*>(bytes);
    for (size_t i = 0; i < length; i++) {
        rom->writeByte(addr + i, p[i]);
    }
}

void sim_ram_load_bin(Vtest_top_ram* ram, const uint8_t* bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        ram->writeByte(i, bytes[i]);
    }
}

void sim_mem_load_bin(Vtest_top_rom* rom, Vtest_top_ram* ram, std::string fn) {
    std::ifstream bpfs(fn, std::ios::binary | std::ios::ate);
    if (!bpfs.is_open()) {
        std::cerr << "Error opening binary file: " << fn << std::endl;
        exit(EXIT_FAILURE);
    }
    std::streamsize f_length = bpfs.tellg();
    char* buf = new char[f_length];
    bpfs.seekg(0, std::ios::beg);
    bpfs.read(buf, f_length);
    bpfs.close();

    std::cout << "Successfully loaded firmware (" << fn << "), size: " << f_length << " bytes." << std::endl;

    sim_mem_write(rom, 0, static_cast<size_t>(f_length), buf);
    sim_ram_load_bin(ram, reinterpret_cast<const uint8_t*>(buf), static_cast<size_t>(f_length));
    delete[] buf;
}

uint32_t sim_regs_read(Vtest_top_regfile* regs, uint32_t addr) {
    uint32_t v;
    regs->readRegister(addr, v);
    return v;
}
