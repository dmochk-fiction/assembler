bits 64
; matrix; heap sort; pointer array

COLS equ 3
RAWS equ 3

section .rodata
raws: db RAWS
cols: db COLS



section .bss
min_el: resd 1
current_raw: resq 1



section .data

struc ptr_min ; creating struture to simplify comprehension of following code	
	.ptr: resq 1 ; in x86_64 address consists of 8 bytes
	.min: resd 1 ; need to reserve 4 bytes for dword matrix element
endstruc 

ptr_min_size equ 12 ; in bytes

arr_pm: times RAWS * ptr_min_size db 0 ; array consists of above defined structure

matrix: dd 11, -1000, 99, -3221, 123, 55, 23, 1, 49 ; matrix ;)
raw_size equ COLS * 4

global _start

section .text
_start:
	call process_matrix
	
	movsx rax, dword [arr_pm + ptr_min.min]
	mov rax, [arr_pm + ptr_min.ptr]
	mov rbx, matrix
	sub rax, rbx

	movsx rax, dword [arr_pm + ptr_min_size + ptr_min.min]
	mov rax, [arr_pm + ptr_min_size + ptr_min.ptr]
	mov rbx, matrix
	add rbx, raw_size
	sub rax, rbx
	
	movsx rax, dword [arr_pm + ptr_min_size + ptr_min_size + ptr_min.min]
	mov rax, [arr_pm + ptr_min_size + ptr_min_size + ptr_min.ptr]
	mov rbx, matrix
	add rbx, raw_size
	add rbx, raw_size
 	sub rax, rbx
	
	mov rax, 60
	xor rdi, rdi
	syscall



process_matrix: ; this function will fill 'arr_pm' with structure 'ptr_min'
	push rbp ; store basic pointer in stack
	mov rbp, rsp ; save value of 'rsp' in base pointer not to lose 
	sub rsp, 40 ; so now we allocated memory and saved address of 'rsp'

	mov [rbp - 8], rcx ; to store rcx value in stack while processing
 	mov [rbp - 16], rax
	mov [rbp - 24], r8
	mov [rbp - 32], r9
	mov [rbp - 40], r10

	xor rcx, rcx ; to escape rubbish in rcx
	xor rax, rax ; to escape rubbish in rax
	
	
	mov cl, [raws] ; = raws ; beacuse raws <= 255

	mov r8, 0 ; = index of raw => loop from zero	
	
	mov r9, matrix ; pointer to matrix
	jmp .loop

.loop:
	cmp r8, rcx
	jz .exit
	
	mov rax, ptr_min_size ; rax stores ptr_min_size to be multiplied later
	mov [current_raw], r9 ; current_raw stores pointer to raw to be processed in 'min' function
	
	mul r8 ; because no capability to multiply r8 by ptr_min_size due to scale ist not equal 1, 2, 4, 8
	; rax = ptr_min_size * r8 (scale * index)
	mov [arr_pm + rax + ptr_min.ptr], r9 ;
	
	call min
	add r9, raw_size

	movsx r10, dword [min_el]
	mov [arr_pm + rax + ptr_min.min], r10 
	
	inc r8

	jmp .loop
.exit:
	mov rcx, [rbp - 8] ; give back 'rcx' its value
 	mov rax, [rbp - 16] ; give back 'rax' its value
	mov r8,  [rbp - 24]
	mov r9,  [rbp - 32]
	mov r10, [rbp - 40]

	mov rsp, rbp
	pop rbp
	ret

















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
	movsx rax, dword [rsi] ; rax = first number of raw
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

	
