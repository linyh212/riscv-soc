from __future__ import annotations
import subprocess
import sys
from pathlib import Path

GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
RESET = "\033[0m"

def find_first_existing(paths: list[Path]) -> Path | None:
    return next((p for p in paths if p.exists()), None)

def evaluate_output(output: str) -> tuple[str, str, str]:
    if "PASS" in output: return "PASS", GREEN, ""
    if "FAIL" in output: return "FAIL", RED, output
    if "TIMEOUT" in output: return "TIMEOUT", YELLOW, ""
    return "UNKNOWN", RED, output

def run_isa_tests() -> None:
    script_dir = Path(__file__).resolve().parent
    project_root = script_dir.parent
    # 1. Locate test binaries and simulator executable
    bin_dir = find_first_existing(
        [
            script_dir / "firmware/isa_tests/isa/generated",
            script_dir / "firmware/riscv-tests/isa/generated",
        ]
    )
    tb_bin = find_first_existing(
        [
            project_root / "obj_dir/Vtest_top",
            project_root / "build/Vtest_top",
        ]
    )
    if not tb_bin:
        sys.exit("Error: Simulator executable not found (obj_dir/Vtest_top or build/Vtest_top). Please run 'make' first.")
    if not bin_dir:
        sys.exit("Error: Test binary directory not found. Please run 'make -C soc/firmware/isa_tests' to compile the .bin files.")
    bin_files = sorted(bin_dir.glob("*.bin"))
    if not bin_files:
        print(f"Warning: No .bin files found in {bin_dir}")
        return
    # 2. Run tests and print results
    failed_tests: list[str] = []
    print(f"{'Test Target':<40} {'Status':<15} {'Details'}")
    print("=" * 65)
    for bin_file in bin_files:
        res = subprocess.run([str(tb_bin), str(bin_file)], capture_output=True, text=True)
        status, color, details = evaluate_output(res.stdout.strip())
        detail_str = f"  {details}" if details else ""
        print(f"{bin_file.name:<40} {color}{status:<12}{RESET}{detail_str}")
        if status != "PASS":
            failed_tests.append(bin_file.name)
    # 3. Summary report
    print("=" * 65)
    if not failed_tests:
        print(f"{GREEN}🎉 Congratulations! All RISC-V ISA tests passed successfully!{RESET}")
    else:
        print(f"{RED}❌ Total Failed/Timeout: {len(failed_tests)}{RESET}")
        for test in failed_tests:
            print(f"  - {test}")
        sys.exit(1)

if __name__ == "__main__":
    run_isa_tests()
