bits 64
; matrix; heap sort; pointer array

section .rodata
rows: db 3
cols: db 3

section .bss
min_el: resd 1
current_raw: resq 1

raw_ptr: res

section .data

struc rawp_min
	.min_el: resd 0
	.raw_pinter: resq 0
endstruc

matrix: dd 11, -1000, 99, -3221, 123, 55, 23, 1, 49
	

global _start

section .text
_start:
	mov qword [current_raw], matrix
	call min
	
 	mov rax, 60
	xor rdi, rdi
	syscall

min: ; find minimal element in raw of 'cols' elements
	push rbp ; implement base pointer
	mov rbp, rsp ; store stack pointer in base pointer not to lose it 
	sub rsp, 32 ; initially allocate memory for next calulation (need to store eax(4) + rsi(8) + rbx(8))


	mov qword[rbp - 8],  rax ; store previous data of rax in stack
	mov qword [rbp - 16], rbx ; rbx is used as index starts from 1
	mov qword [rbp - 24], rcx ; store number of elements of raw
	mov qword [rbp - 32], rsi ; store previous data in rsi in stack
	
	xor rax, rax ; to make rax be zero

	mov rsi, [current_raw] ; current_raw is address that stores current_raw address 
	mov eax, [rsi] ; eax = first number of raw
	mov rbx, 1 ; countdown for cycle
	
	xor rcx, rcx
	mov cl, [cols]
	jmp .loopa ; go to cycle

.loopa:
	cmp rbx, rcx ; while rbx is less than number columns (cols)
	jz .exit_function ; if bl = cols then we exit from function 'min'
	
	cmp eax, [rsi + 4 * rbx] ; compare current minimal number (stored in eax) 	
	jg .condition
	
	inc rbx ; increment countdown 
	jmp .loopa

.condition:
	movsx rax, dword [rsi + 4 * rbx] ; new minimal value is that one in squared brackets
	inc rbx ; increment countdown 
	jmp .loopa

.exit_function:
	mov [min_el], eax
	mov rax, [rbp - 8]
	mov rbx, [rbp - 16]
	mov rcx, [rbp - 24]
	mov rsi, [rbp - 32]

	mov rsp, rbp ; set initial state of rsp
	pop rbp

	ret

	
