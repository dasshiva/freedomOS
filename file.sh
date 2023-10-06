set -e
cd src
C_SRC=*.c
ASM_SRC=*.S

for i in $C_SRC
do
    gcc -m32 -ffreestanding -nostdlib -mno-red-zone -Wall -c $i -o ../bin/$i.o
done

for i in $ASM_SRC
do
    nasm -felf32 -o ../bin/$i.o $i
done
cd ..
ld -m elf_i386 -T linker.ld bin/*.o -o kernel.elf
qemu-system-i386 -drive format=raw,file=disk.img -serial stdio -kernel kernel.elf