VERILATOR = verilator
TOP = test_top

# 自動搜尋 soc/rtl 下所有子目錄的 Verilog 檔案
V_SRC := $(shell find soc/rtl -name "*.v")
SIM_SRC := $(wildcard soc/sim/*.cpp)

# 加入 include 搜尋路徑
INC := -Isoc/rtl/include -Isoc/rtl/core -Isoc/rtl/if -Isoc/rtl/id -Isoc/rtl/exe -Isoc/rtl/mem -Isoc/rtl/wb -Isoc/rtl/memory

.PHONY: all sim clean

all: sim

sim:
	$(MAKE) -C soc/firmware/isa_tests
	mkdir -p build
	$(VERILATOR) -Wall -Wno-fatal --cc --exe --build \
		$(INC) \
		--Mdir build \
		--trace \
		$(SIM_SRC) $(V_SRC) \
		--top-module $(TOP)
	./build/V$(TOP) soc/firmware/isa_tests/test.bin

clean:
	if [ -f soc/firmware/isa_tests/Makefile ]; then $(MAKE) -C soc/firmware/isa_tests clean; fi
	rm -rf build wave.vcd