;equivalent to what tee does, should investigate fsync and close
;all registers besides eax are preserved
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
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 2; seek_end
	int 80h
	mov [filesize], eax;eax is now the file size
	
	mov eax, 19 ; lseek
	mov ecx, 0 ; offset
	mov edx, 0; seek_set (seek back to beginning for read)
	int 80h
	;mov eax, [filesize]
	;idiv [bufsize] ; eax has quotient, remainder is edx
	;cmp edx, 0
	;je noadd
	;add eax, 1
	;noadd:
	mov eax, 3 ; read
	mov ecx, buf
	mov edx, [bufsize]
	int 80h
	push eax ; we need to save this i guess
	
	
	
	;ebx _should_ be the same
	;mov ecx, stat
	;mov eax, 28 ; fstat
	;int 80h 
	
	pop eax
	mov edx, eax ; length written
	mov [size], edx ;save length of buffer for later
	mov eax, 4 ;write 
	mov ebx, 1 ; stdout
	int 80h

	pop ebx ;argv[2]
	mov eax, 5 ; open
	mov ecx, mode ; open in create and RW mode
	mov edx, 700q ;file permission
	int 80h 

	mov ebx, eax ;move file descriptor
	mov edx, [size] ; restore size written
	mov ecx, buf ; write the buffer
;	mov ebx, 1
	mov eax, 4 ; write
	int 80h

	mov ebx, 0 ; exit code
	mov eax, 1 ; exit
	int 80h

section .data
	msg db "hello world", 10
	len equ $ - msg
	bufsize dd 1024
	mode equ 2q | 100q
	size dd 2100786140
	filesize dd 0 
section .bss
	buf resb 1024
	stat resb 52
