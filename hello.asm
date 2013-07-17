;equivalent to what tee does, should investigate fsync and close
;all registers besides eax are preserved
%define BUFFER_SIZE 1024
section .text
	global main
	main:
	pop ebx ; argc
	pop ebx ; arv[0] (program name)
	pop ebx ; argv[1]; first actual argument

	mov eax, 5; open file
	mov ecx, 2; O_RDWR	
	int 80h ; call kernel
	
	mov ebx, eax; move file descriptor from result of open to ebx
	mov [ifd], eax ; set the input file descriptor
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 2; seek_end
	int 80h
	mov edi, eax ;eax is now the file size
	
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 0; seek_set (seek back to beginning for read)
	int 80h

	mov eax, edi
	mov ebx, BUFFER_SIZE; can't directly divide with constant
	idiv ebx ; eax has quotient, remainder is edx
	cmp edx, 0
	je noadd
	add eax, 1
	noadd:
	mov edi, eax

	pop ebx ;argv[2]
	mov eax, 5 ; open
	mov ecx, mode ; open in create and RW mode
	mov edx, 700q ;file permission
	int 80h 

	mov [ofd], eax

	loop:
	mov eax, 3 ; read
	mov ebx, [ifd]
	mov ecx, buf

	mov edx, BUFFER_SIZE
	int 80h	
		
	mov edx, eax ; length read
	mov esi, edx ;save length of buffer for later
	mov eax, 4 ;write 
	mov ebx, 1 ; stdout
	int 80h

	mov ebx, [ofd] ;restore file descriptor
	mov edx, esi; restore size written
	mov ecx, buf ; write the buffer
	mov eax, 4 ; write
	int 80h

	sub edi, 1
	cmp edi, 0
	jne loop

	mov ebx, 0 ; exit code
	mov eax, 1 ; exit
	int 80h

section .data	
	mode equ 2q | 100q		
	ifd dd 0
	ofd dd 0
section .bss
	buf resb BUFFER_SIZE	