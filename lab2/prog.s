bits 64
; matrix; heap sort; pointer array

section .rodata
rows: db 3
cols: db 3

section .bss
min_el dd 0
current_raw dq 0

section .data
matrix: dd 11, 77, 99, -32, 123, 55, 23, 1, 49
	
row_ptr: dq
	0, 0, 0

global _start

_start:
	mov current_raw, matrix
	call min
	


min: ; find minimal element in raw of 'cols' elements
	push rbp ; implement base pointer
	mov rbp, rsp ; store stack pointer in base pointer not to lose it 
	sub rsp, 24 ; initially allocate memory for next calulation (need to store eax(4) + rsi(8) + rbx(8))


	mov qword[rbp - 8],  rax ; store previous data of rax in stack
	mov qword [rbp - 16], rbx ; store number of elements (columns) in raw
	mov qword [rbp - 24], rsi ; store previous data in rsi in stack
	
	mov rsi, [current_raw] ; current_raw is address that stores current_raw address 
	mov eax, [rsi] ; eax = first number of raw
	mov rbx, 1 ; countdown for cycle
	jmp .loopa ; go to cycle

.loopa:
	cmp rbx, byte [cols] ; while rbx is less than number columns (cols)
	jz .exit_function ; if bl = cols then we exit from function 'min'
	
	cmp eax, [rsi + 4 * rbx] ; compare current minimal number (stored in eax) 	
	jg .condition
	
	inc rbx ; increment countdown 
	jmp .loopa

.condition:
	mov eax, [rsi + 4 * rbx] ; new minimal value is that one in squared brackets
	inc rbx ; increment countdown 
	jmp .loopa

.exit_function:
	mov min_el, eax
	mov eax, [rbp - 4]
	mov rbx, [rbp - 12]
	mov rsi, [rbp - 20]

	mov rsp, rbp ; set initial state of rsp
	pop rbp

	ret

	
