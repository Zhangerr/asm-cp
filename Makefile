all: hello.o
	ld hello.o -o hello

hello.o: hello.asm
	nasm -f ELF hello.asm

	
