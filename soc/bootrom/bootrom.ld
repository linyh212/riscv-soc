OUTPUT_ARCH( "riscv" )
ENTRY( _start )
MEMORY {
    ROM (rx) : ORIGIN = 0x10000000, LENGTH = 4K
}
SECTIONS {
    .text : {
        *(.text.init)
        *(.text*)
        *(.rodata*)
    } > ROM
}