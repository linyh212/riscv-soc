import os
import subprocess
import sys
from pathlib import Path

def run_isa_tests():
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    
    # 1. bin 目錄位置
    bin_dir = script_dir / "firmware" / "isa_tests" / "isa" / "generated"
    if not bin_dir.exists():
        bin_dir = script_dir / "firmware" / "riscv-tests" / "isa" / "generated"
    
    # 2. 模擬執行檔的位置 (優先找 obj_dir/Vtest_top，其次找 build/Vtest_top)
    tb_bin = project_root / "obj_dir" / "Vtest_top"
    if not tb_bin.exists():
        tb_bin = project_root / "build" / "Vtest_top"
    if not tb_bin.exists():
        print(f"Error: 找不到模擬器執行檔 ({tb_bin})，請先執行 make 編譯。")
        sys.exit(1)
    if not bin_dir.exists():
        print(f"Error: 找不到測試檔目錄 {bin_dir}，請確認是否已執行 make -C soc/firmware/isa_tests 編譯 .bin 檔案。")
        sys.exit(1)
    
    bin_files = sorted(list(bin_dir.glob("*.bin")))
    if not bin_files:
        print(f"Warning: 在 {bin_dir} 下找不到任何 .bin 檔案")
        return
    
    failed_tests = []
    print(f"{'Test Target':<40} {'Status':<15} {'Details'}")
    print("=" * 65)
    
    for bin_file in bin_files:
        cmd = [str(tb_bin), str(bin_file)]
        result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        output = result.stdout.strip()
        if "PASS" in output:
            print(f"{bin_file.name:<40} \033[92mPASS\033[0m")
        elif "FAIL" in output:
            print(f"{bin_file.name:<40} \033[91mFAIL\033[0m          {output}")
            failed_tests.append(bin_file.name)
        elif "TIMEOUT" in output:
            print(f"{bin_file.name:<40} \033[93mTIMEOUT\033[0m")
            failed_tests.append(bin_file.name)
        else:
            print(f"{bin_file.name:<40} \033[91mUNKNOWN\033[0m      {output}")
            failed_tests.append(bin_file.name)

    print("=" * 65)
    if not failed_tests:
        print("\033[92m🎉 Congratulations! All RISC-V ISA tests passed successfully!\033[0m")
    else:
        print(f"\033[91m❌ Total Failed/Timeout: {len(failed_tests)}\033[0m")
        for test in failed_tests:
            print(f"  - {test}")
            
if __name__ == "__main__":
    run_isa_tests()
