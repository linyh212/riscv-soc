# 目標檔名
PROGRAM = core_main

# 路徑設定
FIRMWARE_DIR = ../firmware
TOOL_PREFIX  = riscv64-unknown-elf-

CC      = $(TOOL_PREFIX)gcc
OBJCOPY = $(TOOL_PREFIX)objcopy
OBJDUMP = $(TOOL_PREFIX)objdump

# 架構與編譯參數 (RV32IM)
ARCH_FLAGS = -march=rv32im_zicsr -mabi=ilp32
CFLAGS     = $(ARCH_FLAGS) -O2 -Wall -g \
             -fno-common -funroll-loops -finline-functions \
             --param max-inline-insns-auto=20 \
             -falign-functions=4 -falign-jumps=4 -falign-loops=4 \
             -fno-builtin-printf -fno-builtin-malloc -nostdlib \
             -I. -I$(FIRMWARE_DIR) \
             -DITERATIONS=1000 -DPERFORMANCE_RUN=1 -DFLAGS_STR="\"-O2\""

LDFLAGS    = -T $(FIRMWARE_DIR)/link.ld -nostartfiles -Wl,-Map=$(PROGRAM).map

# 原始碼清單：CoreMark 核心 + 裸機底層驅動
ASM_SRCS = $(FIRMWARE_DIR)/boot.S
C_SRCS   = core_list_join.c \
           core_main.c \
           core_matrix.c \
           core_state.c \
           core_util.c \
           core_portme.c \
           $(FIRMWARE_DIR)/util.c \
           $(FIRMWARE_DIR)/kprintf.c

OBJS     = $(ASM_SRCS:.S=.o) $(C_SRCS:.c=.o)

.PHONY: all clean

all: $(PROGRAM).bin $(PROGRAM).dump

$(PROGRAM).elf: $(OBJS)
	$(CC) $(ARCH_FLAGS) $(LDFLAGS) $(OBJS) -lgcc -o $@

$(PROGRAM).bin: $(PROGRAM).elf
	$(OBJCOPY) -O binary $< $@

$(PROGRAM).dump: $(PROGRAM).elf
	$(OBJDUMP) -D $< > $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	$(CC) $(ARCH_FLAGS) -I$(FIRMWARE_DIR) -c $< -o $@

clean:
	rm -f *.o $(FIRMWARE_DIR)/*.o $(PROGRAM).elf $(PROGRAM).bin $(PROGRAM).dump $(PROGRAM).map