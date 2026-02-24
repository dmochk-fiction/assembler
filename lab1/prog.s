bits 64
; ( (a * b * c) - (c * d * e) ) / ( a / b + c / d)
section .data
a: dd 11

b: dd 12

c: dq 100

d: dw 7

e: db 7
section .text
global _start
_start:
	mov ebx, [b]
	or ebx, ebx
	jz err ; check if number b equals zero to escape zero division

	mov cx, [d]
	or cx, cx
	jz err ; check if number d equals zero to escape zero division
	; area of allowed values defined
	
	mov eax, [a]
	mul ebx ; multiplication of a and b numbers

	mov r8, rdx
	shl r8, 32
	or r8, rax ; r8 = a * b

	movzx rax, word [d] ; convert 16-bit d to 32-bit value stored in eax
	movzx rbx, byte [e] ; convert 8-bit e to 32-bit value stored in ebx
	mul ebx ; edx:eax

	mov r9, rax ; in fact we multiply [8-bit <= 16-bit] and [16-bit <= 16-bit] so It cant be in edx
	; and operation above covers whole number (d * e)

	sub r8, r9
	jc err ; if r8 < r9 then announce calculation error and complete the program

	mov rax, [c]
	mul r8 ; rdx:rax = c * ((a * b) - (d * e)) = 128-bit result

	mov r8, rdx ; just to keep it away from general registers rdx:rax 
	mov r9, rax ; just to keep it away from general registers rdx:rax

	; a / b
	mov eax, [a] ; 32-bit
	mov ebx, [b] ; 32-bit 
	mov edx, 0 ; put zero to edx to get 64-bit in edx:eax
	div ebx; get quotient in eax and rest in edx
	mov rdi, rax ; 
	
	; c / d
	mov eax, dword[c]
	mov edx, dword[c + 4] ; 
	movzx ebx, word[d]
	div ebx
	mov rsi, rax
	
	; (a / b) + (c / d)
	add rdi, rsi ; no chance of overflow
	jc err

	mov rdx, r8
	mov rax, r9

	div rdi

	mov rax, 60
	mov rdi, 0
	syscall
err:
	mov rax, 60
	mov edi, 1
	syscall
