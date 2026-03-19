bits 64
; this programm has been created only for my personal task given me as conviction for few knowledge about stack
; i need to extract value of global variable with name "SORT"

global _start

section .bss
value: resb 4

section .data
STACK: db 83, 84, 65, 67, 75, 61 ; last code is associeted    


section .text

_start:
	pop r8 ; r8 = number of arguments given to programm
	; so now peak of the stack is on first argument of the programm
	; stack consists of addresses 

	xor rax, rax ; rax = 0
	mov rax, 8 ; rax = 8
	mul r8 ; so now rax stores offset for zero pointer
	
	; following algorithm is about to keep rsp stable but to move in stack using another registry
	xor rbx, rbx

	mov rbx, rsp ; rbp = rsp
	add rbx, rax ; so now we are at 'zero border' between arguments and enviroment variables 
	;mov rbx, [rbx] ; rbx = 0 
	; after we should analyze content of every address in stack and compare it with given name (currently – STACK)

	; go to loop
	jmp .loop_stack

.finish:

	mov rax, 60
	mov rdi, 22
	syscall


.loop_stack:
	add rbx, 8 ; add 8 bytes to current address to move to next address in stack
	cmp qword [rbx], 0
	jz .finish

	mov r9, [rbx] ; get address to data stored in current enviroment variable 
	xor rcx, rcx
.loop_cmp:
	mov al, [r9]
	cmp al, byte [STACK + rcx]
	jnz .loop_stack
	inc r9 ; go to next symbol
	
	add rcx, 1
	cmp rcx, 6
	jne .loop_cmp


	xor rcx, rcx
.copy_data:
	cmp rcx, 3
	jz .finish

	mov al, [r9]
	mov byte [value + rcx], al

	inc r9 ; first symbol of value out of 4

	add rcx, 1 ; increment index
	jmp .copy_data









