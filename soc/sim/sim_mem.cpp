#include <cstdint>
#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include "Vtest_top.h"
#include "Vtest_top_rom.h"

void sim_mem_write(Vtest_top_rom* rom, uint32_t addr, size_t length, const void* bytes) {
    const uint8_t* p = reinterpret_cast<const uint8_t*>(bytes);
    for (size_t i = 0; i < length; i += 4) {
        rom->writeByte(addr + i,     p[i]); // 最高位元組 [31:24]
        rom->writeByte(addr + i + 1, p[i + 1]);
        rom->writeByte(addr + i + 2, p[i + 2]);
        rom->writeByte(addr + i + 3, p[i + 3]); // 最低位元組 [7:0]
    }
}

void sim_mem_load_bin(Vtest_top_rom* rom, std::string fn) {
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

    for (int i = 0; i < f_length; i += 4) {
        sim_mem_write(rom, i, 4, reinterpret_cast<uint8_t*>(buf + i));
    }

    delete[] buf;
}