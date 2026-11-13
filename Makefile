TOP        = test_top
GTKWAVE    = gtkwave

BUILD_DIR  = build
TARGET_BIN = $(BUILD_DIR)/V$(TOP)

ISA_TEST_BIN = soc/firmware/isa_tests/test.bin
C_FW_DIR     = soc/firmware
C_FW_BIN     = $(C_FW_DIR)/firmware.bin

V_SRC    = soc/rtl/core/test_top.v
V_SRC   += $(wildcard soc/rtl/device/*.v)
V_SRC   += soc/rtl/core/pipe_crtl.v
V_SRC   += soc/rtl/core/interrupt_ctrl.v
V_SRC   += $(wildcard soc/rtl/core/if/*.v)
V_SRC   += $(wildcard soc/rtl/core/id/*.v)
V_SRC   += $(wildcard soc/rtl/core/exe/*.v)
V_SRC   += $(wildcard soc/rtl/core/mem/*.v)
V_SRC   += $(wildcard soc/rtl/core/wb/*.v)
V_SRC   += $(wildcard soc/rtl/memory/*.v)

# C++ Testbench 原始碼
SIM_SRC  = $(wildcard soc/sim/*.cpp)

INC      = -Isoc/rtl/include

.PHONY: all run run_c test wave clean build_c_fw

all: run

# --------------------------------------------------
# 韌體編譯規則
# --------------------------------------------------
$(ISA_TEST_BIN):
	$(MAKE) -C soc/firmware/isa_tests

build_c_fw:
	$(MAKE) -C $(C_FW_DIR)

# --------------------------------------------------
# Verilator 硬體轉譯與編譯
# --------------------------------------------------
$(TARGET_BIN): $(V_SRC) $(SIM_SRC)
	@mkdir -p $(BUILD_DIR)
	verilator -Wall -Wno-fatal --cc --exe --build \
		$(INC) \
		--Mdir $(BUILD_DIR) \
		--trace \
		--top-module $(TOP) \
		$(V_SRC) $(SIM_SRC)

# --------------------------------------------------
# 執行與測試指令
# --------------------------------------------------
run: $(ISA_TEST_BIN) $(TARGET_BIN)
	./$(TARGET_BIN) $(ISA_TEST_BIN)

run_c: build_c_fw $(TARGET_BIN)
	@mkdir -p log
	./$(TARGET_BIN) $(C_FW_BIN)

test: $(TARGET_BIN)
	$(MAKE) -C soc/firmware/isa_tests
	python3 soc/test_all_isa.py

wave: run
	$(GTKWAVE) wave.vcd &

clean:
	if [ -f soc/firmware/isa_tests/Makefile ]; then $(MAKE) -C soc/firmware/isa_tests clean; fi
	if [ -f $(C_FW_DIR)/Makefile ]; then $(MAKE) -C $(C_FW_DIR) clean; fi
	rm -rf $(BUILD_DIR) wave.vcd log/