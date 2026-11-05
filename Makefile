TOP      = test_top
GTKWAVE  = gtkwave

# RTL 原始碼搜尋路徑
V_SRC    = soc/rtl/core/test_top.v
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

.PHONY: all run wave clean

all: run

# 1. 編譯測試軟體 (test.bin)
soc/firmware/isa_tests/test.bin:
	$(MAKE) -C soc/firmware/isa_tests

# 2. Verilator 建置
build/V$(TOP).mk: $(V_SRC) $(SIM_SRC)
	mkdir -p build
	verilator -Wall -Wno-fatal --cc --exe --build \
		$(INC) $(SIM_SRC) $(V_SRC) \
		--Mdir build \
		--trace \
		--top-module $(TOP)

# 3. 執行模擬
run: soc/firmware/isa_tests/test.bin build/V$(TOP).mk
	./build/V$(TOP) soc/firmware/isa_tests/test.bin

# 4. 開啟 GTKWave 觀察波形
wave: run
	$(GTKWAVE) wave.vcd &

clean:
	if [ -f soc/firmware/isa_tests/Makefile ]; then $(MAKE) -C soc/firmware/isa_tests clean; fi
	rm -rf build wave.vcd