CC      = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

CFLAGS  = -march=rv32im_zicsr_zifencei -mabi=ilp32 -nostdlib -nostartfiles -ffreestanding -O2
LDFLAGS = -T bootrom.ld

all: bootrom.bin

bootrom.elf: boot.S boot.c bootrom.ld
	$(CC) $(CFLAGS) $(LDFLAGS) boot.S boot.c -o $@

bootrom.bin: bootrom.elf
	$(OBJCOPY) -O binary $< $@

dump: bootrom.elf
	$(OBJDUMP) -d $<

clean:
	rm -f bootrom.elf bootrom.bin