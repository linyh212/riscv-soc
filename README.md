# NDHU CSIE SoC Design

本專案以 Verilog 實作基於 RISC-V RV32 指令集架構之 SoC，使用 Verilator 進行 RTL 編譯與模擬，並透過 C++ Testbench 載入裸機韌體進行功能驗證。

處理器採用 Pipeline 架構，包含取指、解碼、執行、記憶體存取及寫回等階段，並整合 RAM、Console、Timer、CLINT、中斷處理及 Machine-mode CSR。

- **技術文件與開發紀錄**：[HackMD 筆記](https://hackmd.io/@linyh212/rJZLTEnpfl)

## 開發環境

- Verilator
- RISC-V GNU Toolchain（`gcc`、`objcopy`、`objdump`）
- GNU Make 與 C++ 編譯器
- Python 3（ISA 批次測試）
- GTKWave（選用，波形分析）

## 建置與執行

```sh
make clean
make
```

預設目標會編譯 ISA 測試程式、建置 Verilator 模擬器並執行測試。亦可指定其他韌體映像：

```sh
./build/Vtest_top path/to/firmware.bin
```

## 韌體與 CoreMark

```sh
make build_c_fw
make run_c

make build_cm
make coremark
```

韌體透過 MMIO Console 輸出執行資訊。正常結束時顯示 `[RESULT] PASS`，超過模擬週期上限則回報 Timeout。

## ISA 測試

```sh
make test
```

建置模擬器及測試映像後，執行 `soc/test_all_isa.py`。測試腳本搜尋以下目錄：

- `soc/firmware/isa_tests/isa/generated/*.bin`
- `soc/firmware/riscv-tests/isa/generated/*.bin`（備援路徑）

若缺少 generated 測試映像，則無法執行完整 ISA 測試。

## 記憶體映射

| 裝置 | 基底位址 | 說明 |
| --- | --- | --- |
| RAM | `0x00000000` | 1 MiB |
| Console | `0x00200000` | 輸出與控制暫存器 |
| Timer | `0x00300000` | 控制、Prescaler、計數與比較暫存器 |
| CLINT | `0x02000000` | 軟體中斷、`mtimecmp`、`mtime` |

## 波形與清理

```sh
make wave
make clean
```

`make wave` 執行預設 ISA 測試並透過 GTKWave 檢視 `wave.vcd`。`make clean` 清除建置產物、波形及 Log 檔案。

## 專案架構

```text
soc/
├── rtl/
│   ├── core/       # 處理器 Pipeline、控制邏輯及 CSR／中斷處理
│   ├── memory/     # ROM、RAM 與雙埠 RAM 模組
│   └── device/     # SoC Bus、Console、Timer 與 CLINT
├── sim/            # Verilator C++ Testbench 與模擬記憶體載入程式
├── firmware/       # 裸機 C 韌體與 ISA 測試程式
└── coremark/       # CoreMark Benchmark
```
