all: cp.o
	ld cp.o -o hello

cp.o: cp.asm
	nasm -f ELF cp.asm

	
