TOP      = test_top
GTKWAVE  = gtkwave

# 模擬器執行檔路徑
BUILD_DIR = build
TARGET_BIN = $(BUILD_DIR)/V$(TOP)

# RTL 原始碼搜尋路徑 (自動涵蓋 exe/ 下的 mul.v, div.v 等所有模組)
V_SRC    = soc/rtl/core/test_top.v
V_SRC   += soc/rtl/core/pipe_crtl.v
V_SRC   += $(wildcard soc/rtl/core/if/*.v)
V_SRC   += $(wildcard soc/rtl/core/id/*.v)
V_SRC   += $(wildcard soc/rtl/core/exe/*.v)
V_SRC   += $(wildcard soc/rtl/core/mem/*.v)
V_SRC   += $(wildcard soc/rtl/core/wb/*.v)
V_SRC   += $(wildcard soc/rtl/memory/*.v)

# C++ Testbench 原始碼
SIM_SRC  = $(wildcard soc/sim/*.cpp)

# Include 目錄
INC      = -Isoc/rtl/include

.PHONY: all run wave test clean

all: run

# 1. 編譯測試軟體 (test.bin)
soc/firmware/isa_tests/test.bin:
	$(MAKE) -C soc/firmware/isa_tests

# 2. Verilator 轉譯與建置 (直接編譯出 build/Vtest_top)
$(TARGET_BIN): $(V_SRC) $(SIM_SRC)
	@mkdir -p $(BUILD_DIR)
	verilator -Wall -Wno-fatal --cc --exe --build \
		$(INC) \
		--Mdir $(BUILD_DIR) \
		--trace \
		--top-module $(TOP) \
		$(V_SRC) $(SIM_SRC)

# 3. 執行預設單一韌體模擬
run: soc/firmware/isa_tests/test.bin $(TARGET_BIN)
	./$(TARGET_BIN) soc/firmware/isa_tests/test.bin

# 4. 批次執行全套 RISC-V ISA Tests (rv32ui / rv32um)
test: $(TARGET_BIN)
	$(MAKE) -C soc/firmware/isa_tests
	python3 soc/test_all_isa.py

# 5. 開啟 GTKWave 觀察波形
wave: run
	$(GTKWAVE) wave.vcd &

clean:
	if [ -f soc/firmware/isa_tests/Makefile ]; then $(MAKE) -C soc/firmware/isa_tests clean; fi
	rm -rf $(BUILD_DIR) wave.vcd