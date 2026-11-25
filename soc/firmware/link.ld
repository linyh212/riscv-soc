OUTPUT_ARCH(riscv)

MEMORY
{
    ram   : ORIGIN = 0x00000000, LENGTH = 0x100000 /* 1MB RAM */
    stack : ORIGIN = 0x001F8000, LENGTH = 0x2000   /* 8KB Stack */
}

_min_stack    = 0x2000;
_stack_len    = LENGTH(stack);
_stack_start  = ORIGIN(stack) + LENGTH(stack);

ENTRY(_start)

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*boot.o(.text))
        *(.text)
        *(.text.*)
    } > ram

    .rodata : {
        . = ALIGN(4);
        *(.srodata)
        *(.srodata.*)
        *(.rodata);
        *(.rodata.*)
    } > ram

    .data : {
        . = ALIGN(4);
        *(.sdata)
        *(.sdata.*)
        *(.data);
        *(.data.*)
    } > ram

    .bss : {
        . = ALIGN(4);
        _bss_start = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        _bss_end = .;
    } > ram

    .stack (NOLOAD) : {
        . = ALIGN(4);
        . = . + _min_stack ;
        . = ALIGN(4);
        stack = . ;
        _stack = . ;
    } > stack
}