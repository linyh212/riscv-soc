# 交叉編譯前綴
CROSS_COMPILE ?= riscv64-unknown-elf-

# 目錄與檔案設定
SOC_DIR      := soc
RTL_DIR      := $(SOC_DIR)/rtl
SIM_DIR      := $(SOC_DIR)/sim
TEST_DIR     := $(SOC_DIR)/firmware/isa_tests
BUILD_DIR    := build

TEST_BIN     := $(TEST_DIR)/test.bin
TOP_MODULE   := inst_fetch

VERILATOR    := verilator
VFLAGS       := -Wall --cc --exe --build -I$(RTL_DIR)/core -I$(RTL_DIR)/memory --trace

.PHONY: all sim wave clean

all: sim

# 1. 呼叫子目錄 Makefile 編譯 test.S 產生 test.bin
$(TEST_BIN):
	$(MAKE) -C $(TEST_DIR)

# 2. 執行 Verilator 建立 C++ 模型並跑模擬
sim: $(TEST_BIN)
	mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) \
		--Mdir $(BUILD_DIR) \
		$(SIM_DIR)/testbench.cpp $(SIM_DIR)/sim_mem.cpp \
		$(RTL_DIR)/core/defines.v $(RTL_DIR)/core/pc_reg.v \
		$(RTL_DIR)/memory/rom.v $(RTL_DIR)/core/inst_fetch.v \
		--top-module $(TOP_MODULE)
	./$(BUILD_DIR)/V$(TOP_MODULE) $(TEST_BIN)

# 3. 使用 GTKWave 檢視波形
wave: sim
	gtkwave wave.vcd &

# 4. 清除產生檔案
clean:
	if [ -f $(TEST_DIR)/Makefile ]; then $(MAKE) -C $(TEST_DIR) clean; fi
	rm -rf $(BUILD_DIR) wave.vcd