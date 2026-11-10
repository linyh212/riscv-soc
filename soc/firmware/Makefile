CROSS_COMPILE ?= riscv64-unknown-elf-
CC            := $(CROSS_COMPILE)gcc
OBJCOPY       := $(CROSS_COMPILE)objcopy
OBJDUMP       := $(CROSS_COMPILE)objdump

CFLAGS        := -nostdlib -nostartfiles -fno-builtin -march=rv32im -mabi=ilp32 -g -Wall

OBJS          := boot.o main.o util.o kprintf.o
TARGET        := firmware

.PHONY: all clean code hex

all: $(TARGET).bin

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) -T link.ld -o $@ $(OBJS)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

code: $(TARGET).elf
	$(OBJDUMP) -d $< | less

hex: $(TARGET).bin
	hexdump -C $<

clean:
	rm -f *.o *.elf *.bin