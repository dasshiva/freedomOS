[BITS 32]

MBALIGN  equ  1 << 0            ; align loaded modules on page boundaries
MEMINFO  equ  1 << 1            ; provide memory map
MBFLAGS  equ  MBALIGN | MEMINFO ; this is the Multiboot 'flag' field
MAGIC    equ  0x1BADB002        ; 'magic number' lets bootloader find the header
CHECKSUM equ -(MAGIC + MBFLAGS)

section .multiboot
align 4
    dd MAGIC 
    dd MBFLAGS
    dd CHECKSUM

section .bss
align 16
stack_bottom: resb 8192
stack_end:

section .rodata
gdt_start:
gdt_null:
    dq 0
gdt_code:
    dw 0xFFFF
    dw 0
    db 0
    db 10011010b 
    db 11001111b
    db 0
gdt_data:
    dw 0xFFFF
    dw 0
    db 0
    db 10010010b
    db 11001111b
    db 0
gdt_end:

gdt_desc:
    dw gdt_end - gdt_start
    dd gdt_start

section .text 
global _start

_start:
    cli
    mov dx, 0x3F8
    mov al, 66
    out dx, al
    mov esp, stack_end
    xor ax, ax
    mov ds, ax
    lgdt [gdt_desc]
    jmp 08h: stage1
    jmp $

stage1:
    mov dx, 0x3F8
    mov al, 66
    out dx, al
    extern kmain 
    call kmain
    jmp $