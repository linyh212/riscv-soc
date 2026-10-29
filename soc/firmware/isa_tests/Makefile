CROSS_COMPILE ?= riscv64-unknown-elf-
CC            := $(CROSS_COMPILE)gcc
OBJCOPY       := $(CROSS_COMPILE)objcopy
OBJDUMP       := $(CROSS_COMPILE)objdump

CFLAGS        := -nostdlib -fno-builtin -march=rv32ima -mabi=ilp32 -g -Wall

.PHONY: all clean

all: test.bin

test.elf: test.S
	$(CC) $(CFLAGS) $< -Ttext=0x00000000 -o $@
	$(OBJDUMP) -S $@ > test.dis

test.bin: test.elf
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f *.o *.elf *.bin *.dis