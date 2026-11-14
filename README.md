# NDHU CSIE SoC Design

以 Verilog 實作的 RV32 SoC，使用 Verilator 編譯 RTL，並透過 C++ testbench 載入裸機韌體進行模擬。處理器包含取指、解碼、執行、記憶體與寫回等 pipeline stages，並整合 RAM、console、timer、CLINT、中斷與 machine-mode CSR。

- **相關文件與開發筆記**：[HackMD 筆記](https://hackmd.io/@linyh212/rJZLTEnpfl)

## 需求

- Verilator
- RISC-V GNU toolchain，需提供 `riscv64-unknown-elf-gcc`、`objcopy` 與 `objdump`
- GNU Make 與 C++ 編譯器
- Python 3（執行 ISA 批次測試）
- GTKWave（選用，用來檢視波形）

## 快速開始

在專案根目錄執行：

```sh
make clean
make
```

預設目標會編譯 `soc/firmware/isa_tests/test.S`、建置 Verilator 模擬器，並執行該 ISA 測試。模擬器也可以直接載入其他韌體映像：

```sh
./build/Vtest_top path/to/firmware.bin
```

## 執行韌體與 CoreMark

```sh
# 建置並執行 C 裸機韌體
make build_c_fw
make run_c

# 建置並執行 CoreMark
make build_cm
make coremark
```

模擬器透過 MMIO console 顯示韌體輸出。成功結束時會印出 `[RESULT] PASS`；若韌體未在模擬器的週期上限內結束，則會回報 timeout。

## ISA 測試套件

```sh
make test
```

此目標會建置模擬器和 `soc/firmware/isa_tests/test.bin`，再執行 `soc/test_all_isa.py`。批次腳本會搜尋 `soc/firmware/isa_tests/isa/generated/*.bin`，並以 `soc/firmware/riscv-tests/isa/generated/*.bin` 作為備用路徑。若兩處都沒有測試映像，便不會執行完整的 RISC-V ISA 測試；請先準備 generated 測試映像，再執行此目標。

## 記憶體與周邊位址

| 裝置 | 基底位址 | 說明 |
| --- | --- | --- |
| RAM | `0x00000000` | 1 MiB；韌體由位址 0 開始執行 |
| Console | `0x00200000` | 輸出暫存器位於基底位址 `+0x04`；控制暫存器位於 `+0x08` |
| Timer | `0x00300000` | 控制、prescaler、計數值與比較值位於 `+0x00` 至 `+0x0C` |
| CLINT | `0x02000000` | 軟體中斷、`mtimecmp` 與 `mtime` 暫存器 |

## 波形與清理

```sh
make wave
make clean
```

`make wave` 執行預設 ISA 測試並以 GTKWave 開啟 `wave.vcd`。`make clean` 會清除模擬器建置目錄、波形、log，以及各韌體子專案產生的建置檔。

## 專案目錄

- `soc/rtl/core/`：處理器 pipeline、控制與 CSR/中斷邏輯
- `soc/rtl/memory/`：ROM、RAM 與雙埠 RAM
- `soc/rtl/device/`：SoC bus、console、timer 與 CLINT
- `soc/sim/`：Verilator C++ testbench 與模擬記憶體載入程式
- `soc/firmware/`：裸機 C 韌體與 ISA 測試
- `soc/coremark/`：CoreMark benchmark