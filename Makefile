all: cp.o
	ld cp.o -o cp

cp.o: cp.asm
	nasm -f ELF cp.asm

	
