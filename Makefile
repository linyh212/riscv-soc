# 交叉編譯前綴
CROSS_COMPILE ?= riscv64-unknown-elf-

# 目錄與檔案設定
SOC_DIR      := soc
RTL_DIR      := $(SOC_DIR)/rtl
SIM_DIR      := $(SOC_DIR)/sim
TEST_DIR     := $(SOC_DIR)/firmware/isa_tests
BUILD_DIR    := build

TEST_BIN     := $(TEST_DIR)/test.bin
TOP_MODULE   := test_top

VERILATOR    := verilator
# 加上 -Wno-fatal 忽略預留訊號的 Lint 警告
VFLAGS       := -Wall -Wno-fatal --cc --exe --build -I$(RTL_DIR)/core -I$(RTL_DIR)/memory --trace

.PHONY: all sim wave clean

all: sim

$(TEST_BIN):
	$(MAKE) -C $(TEST_DIR)

sim: $(TEST_BIN)
	mkdir -p $(BUILD_DIR)
	$(VERILATOR) $(VFLAGS) \
		--Mdir $(BUILD_DIR) \
		$(SIM_DIR)/testbench.cpp $(SIM_DIR)/sim_mem.cpp \
		$(RTL_DIR)/core/defines.v \
		$(RTL_DIR)/core/pc_reg.v \
		$(RTL_DIR)/core/if_id.v \
		$(RTL_DIR)/core/regfile.v \
		$(RTL_DIR)/core/id_type_i.v \
		$(RTL_DIR)/core/id.v \
		$(RTL_DIR)/core/id_exe.v \
		$(RTL_DIR)/memory/rom.v \
		$(RTL_DIR)/core/test_top.v \
		--top-module $(TOP_MODULE)
	./$(BUILD_DIR)/V$(TOP_MODULE) $(TEST_BIN)

wave: sim
	gtkwave wave.vcd &

clean:
	if [ -f $(TEST_DIR)/Makefile ]; then $(MAKE) -C $(TEST_DIR) clean; fi
	rm -rf $(BUILD_DIR) wave.vcd