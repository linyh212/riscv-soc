CROSS_COMPILE ?= riscv64-unknown-elf-
CC            := $(CROSS_COMPILE)gcc
OBJCOPY       := $(CROSS_COMPILE)objcopy
OBJDUMP       := $(CROSS_COMPILE)objdump

CFLAGS        := -nostdlib -nostartfiles -fno-builtin -march=rv32imazicsr -mabi=ilp32 -g -Wall

APP           ?= main
OBJS          := boot.o $(APP).o util.o kprintf.o
TARGET        := $(APP)

TESTS         := $(TARGET).bin plic_test.bin

.PHONY: all clean code hex

all: $(TESTS)

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

plic_test.elf: boot.o plic_test.o util.o kprintf.o
	$(CC) $(CFLAGS) -T link.ld -o $@ $^

$(TARGET).elf: $(OBJS)
	$(CC) $(CFLAGS) -T link.ld -o $@ $(OBJS)

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

code: $(TARGET).elf
	$(OBJDUMP) -d $< | less

hex: $(TARGET).bin
	hexdump -C $<

clean:
	rm -f *.o *.elf *.bin