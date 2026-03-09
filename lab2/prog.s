bits 64
; matrix; heap sort; pointer array

COLS equ 4
RAWS equ 4

section .rodata
raws: db RAWS
cols: db COLS



section .bss
min_el: resd 1
current_raw: resq 1



section .data

cur_idx: dw 0

struc ptr_min ; creating struture to simplify comprehension of following code	
	.ptr: resq 1 ; in x86_64 address consists of 8 bytes
	.min: resd 1 ; need to reserve 4 bytes for dword matrix element
endstruc 

ptr_min_size equ 12 ; in bytes

arr_pm: times RAWS * ptr_min_size db 0 ; array consists of above defined structure

matrix: dd 11, -1000, 99, -1213, -3221, 123, 55, -1, 23, 1, 49, -9999, 11, -11, -12, 12; matrix ;)
raw_size equ COLS * 4
matrix_size equ COLS * RAWS

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
	mov [arr_pm + rax + ptr_min.min], r10d 
	
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





heapify_min: ; later I implement 'heapify_max'
	push rbp
	mov rbp, rsp
	sub rsp, 40
	
	mov [rbp + 8], r8 ; store r8 value in stack; r8 = current index (I)
	mov [rbp + 16], r9 ; store r9 value in stack ; r9 = left child (2I + 1)
	mov [rbp + 24], r10 ; store r10 value in stack ; r10 = right child (2I + 2)
	mov [rbp + 32], rbx ; scale = ptr_min_size = 12 bytes
	mov [rbp + 40], rdx ; used for calculations 
	mov [rbp + 48], r11 ; used for calculation

	
	xor r8, r8
	xor r9, r9
	xor r10, r10

	jmp .loop
 .loop:
	movsx r8, word [cur_idx] ; r8 = current_index
	
	imul r9, r8, 2 
	add r9, 1 ; r9 = current_index * 2 + 1 (left child)
	cmp r9, matrix_size
	jge .exit ; it means that current node (I) can't have children

	imul r10, r8, 2
	add r10, 2 ; r10 = current_index * 2 + 2 (right child)
	cmp r10, matrix_size
	jge .only_left

	; mov r8, [arr_pm + ptr_min * ]
	
.only_left:	
	mov rbx, ptr_min_size ; rbx = 12
	
	imul r8, rbx ; r8 = I * 12 = offset for necessary structure
	mov r8, [arr_pm + r8 + ptr_min.min]
	
	imul r9, rbx ; r9 = (I*2 + 1) * 12 = offset for necessary structure
	mov r9, [arr_pm + r9 + ptr_min.min]

	cmp r9, r8
	jge .exit ; if r9 (left child in MIN-heap) greater or equal r8 (current parent in MIN-heap) than we finished heapifing 
	; if we here whan we need to swap child and parent

 	movzx r8, word [cur_idx] ; parent index
	imul r8, rbx ; parent offset
	movsx r9, dword [arr_pm + r8 + ptr_min.min] ; r9 = min parent value
	mov r10, [arr_pm + r8 + ptr_min.ptr] ; r10 = ptr parent value
	
	imul rbx, [cur_idx], 2 ; rbx = current_index * 2
	add rbx, 1 ; rbx = current_index * 2 + 1
	mov r11, ptr_min_size ; r11 = 12
	imul rbx, r11 ; rbx = left child offset

	movsx rdx, dword [arr_pm + rbx + ptr_min.min] ; rdx = min left child value
	mov r11, [arr_pm + rbx + ptr_min.ptr] ; r11 = ptr left child value

	mov [arr_pm + rbx + ptr_min.min], r9d ; = min parent value
	mov [arr_pm + rbx + ptr_min.ptr], r10 ; = ptr parent value

	mov [arr_pm + r8 + ptr_min.min], edx ; 
	mov [arr_pm + r8 + ptr_min.ptr], r11 ;

	jmp .exit

.exit:
	







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

	
