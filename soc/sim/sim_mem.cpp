#include <cstdint>
#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include "Vinst_fetch.h"
#include "Vinst_fetch_rom.h"

void sim_mem_write(Vinst_fetch_rom* rom, uint32_t addr, size_t length, const void* bytes) {
    const uint8_t* p = reinterpret_cast<const uint8_t*>(bytes);
    for (size_t i = 0; i < length; i++) {
        rom->writeByte(addr + i, p[i]);
    }
}

void sim_mem_load_bin(Vinst_fetch_rom* rom, std::string fn) {
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

    // 將二進位內容直接從位址 0x0 依序寫入 ROM
    sim_mem_write(rom, 0, f_length, buf);

    delete[] buf;
}