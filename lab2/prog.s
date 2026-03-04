bits 64
; matrix; heap sort; pointer array

section .rodata
rows: db 3
cols: db 3

section .bss
current_raw dq 0

section .data
matrix: dd
	11, 77, 99
	-32, 123, 55
	23, 1, 49
	
row_ptr: dq
	0, 0, 0

global _start

_start:
	


min: ; find minimal element in raw of 'cols' elements
	push rbp ; implement base pointer
	mov rbp, rsp ; store stack pointer in base pointer not to lose it 
	sub rsp, 5 ; initially allocate memory for next calulation (need to store eaxw)

	mov [ebp], eax ; store previous data of eax in stack
	mov [ebp + 4], bl ; store number of elements (columns) in raw
 
	mov eax, [current_raw] ; eax = first number of raw
	mov bl, 0 ; countdown for cycle
	jmp .loopa ; go to cycle

.loopa:
	inc bl ; increment countdown 
	cmp bl, cols ; while bl is less than number columns (cols)
	jz .exit_function ; if bl = cols then we exit from function 'min'

	cmp eax, [current_raw + 4 * bl] ; compare current minimal number (stored in eax) 
	jg .condition
	
.condition:
	mov eax, [current_raw + 4 * bl]
	
.exit_function:
	mov rsp, rbp ; set initial state of rsp
	add rsp, 5
	pop rbp

	ret

	
