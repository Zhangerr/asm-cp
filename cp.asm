;copies a file
;equivalent to what tee does, should investigate fsync and close
;all registers besides eax are preserved
%define BUFFER_SIZE 1024 ; size in bytes
section .text
	global main
	main:
	pop ebx ; argc
	pop ebx ; arv[0] (program name)
	pop ebx ; argv[1]; first actual argument
	; open - input file and get file descriptor
	mov eax, 5; open file
	mov ecx, 2; O_RDWR	
	int 80h ; call kernel
	; lseek	- seek to end of file to get file size
	mov ebx, eax; move file descriptor from result of open to ebx
	mov [ifd], eax ; set the input file descriptor
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 2; seek_end
	int 80h
	; preserve eax
	mov edi, eax ; eax is now the file size
	; lseek - seek to beginning
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 0; seek_set (seek back to beginning for read)
	int 80h

	mov eax, edi ; restore eax
	; to figure out how many iterations: math.ceil(FILE_SIZE/BUFFER_SIZE)
	; since we obviously don't have a math.ceil function we perform an integer divion and check for a remainder, if there is one do an extra iteration to get the remainder
	; values below the BUFFER_SIZE go to 1; having a larger buffer than needed is okay
	mov ebx, BUFFER_SIZE ; can't directly divide with constant
	idiv ebx ; EDX:EAX / EBX; result: eax has quotient, remainder is edx
	cmp edx, 0
	je noadd 
	add eax, 1
	noadd:
	mov edi, eax ; edi now becomes our "loop counter"
	; open - output file for writing
	pop ebx ; argv[2]
	mov eax, 5 ; open
	mov ecx, mode ; open in create and RW mode
	mov edx, 700q ; file permission (read, write and execute for owner)
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
	mode equ 2q | 100q ; O_RDWR and CREATE permission
	ifd dd 0 ; input file descriptor
	ofd dd 0 ; output file descriptor
section .bss
	buf resb BUFFER_SIZE	