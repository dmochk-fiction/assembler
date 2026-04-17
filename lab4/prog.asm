bits 64

default rel
extern printf, scanf
extern log, sqrt
extern fopen
extern fclose
extern fprintf
extern asinh

section .rodata

two: dq 2.0
minus: dq -1.0
one: dq 1.0
six: dq 6.0

sign_mask: dq 0x7FFFFFFFFFFFFFFF ; 1 bit = 0, other 63 equals 1

; define messages 

no_filename: db "Missing filename", 10, 0

greeting_msg: db "Programm started: performing calculation of numerical series", 10, 0
;greet_size equ $ - greeting

file_not_found: db "No such file found", 10, 0
;fnf_size equ $ - file_not_found

invalid_deviation: db "Current deviation is impossible", 10, 0
;indev_size equ $ - invalid_deviation

incorrect_var: db "X is stricktly between -1 and 1 including borders", 10, 0
;incvar_size equ $ - incorrect_var

prog_comp: db "Programm completed", 10, 0

input_x: db "Enter X value: ", 0
input_dev: db "Enter deviation value: ", 0


; output formats for printf
fmt_str: db "%s", 0 ; just for simple line of text
fmt_dbl: db "%lf", 0 ; lonf float = double
fmt_to_file: db "Number: %d", 9, "Value: %.40lf", 10, 0
fmt_end: db "Left: %.40lf", 10, "Right: %.40lf", 10, 0
fmt_fragmented_left_calc: db "Left fragmented: %.40lf", 10, 0

mode_w: db "w+", 0

section .bss

; file work
file_handler: resq 1; = FILE* 
filename: resq 1 ;

; 
sum: resq 1; accumulate sum of numerical series there
cur_a_n: resq 1; to avoid spoiling data after calls of libc functions
num_iter: resq 1; reserve 64 bits to store number of current numerical series
deval: resq 1 ; reserve 64 bits for double deviation value
xval: resq 1 ; reserve 64 bits for double x value
ret_code: resq 1 ; reserve memory to save return address

section .text
global main

main:
	sub rsp, 8 ; to make stack alligned by 16 bytes

	cmp rdi, 2 ; rdi = argc after MAIN call
	jl few_arg ; if true, then finish the programm

	mov rax, [rsi + 8] ; rsi = massive of pointers to command line arguments
	mov qword [filename], rax 
	; so [rsi] = pointer to programm name = argv[0]
	; and [rsi + 8] = argv[1]


	lea rdi, [rel fmt_str] ; simple "%s"
	lea rsi, [rel greeting_msg] ; direct message
	call printf

	lea rsi, [rel fmt_str] ; simple "%s"
	lea rdi, [rel input_x] ; direct message
	call printf

	lea rdi, [rel fmt_dbl] ; we wait for double value to be input
	lea rsi, [rel xval] ; address where to store value of x
	xor rax, rax ; we mention that we have ZERO float arguments that should be in xmm0 - xmm7 registers
	call scanf ; got X value

	cmp rax, 1 ; rax = number of arguments that scanf got
	jne var_input_error
	
	; take abs of xval to define if it lies between borders
	movsd xmm0, qword [xval] ; xmm = xval
	movsd xmm1, qword [sign_mask]
	andpd xmm0, xmm1 ; xmm0 = abs(xval) 
	movsd xmm1, qword [one]
	ucomisd xmm0, xmm1
	ja var_input_error ; ja = jump if above
	
	
	lea rdi, [rel fmt_str] ; expectable input format
	lea rsi, [rel input_dev] ; prompt to get deviation value
	xor rax, rax
	call printf

	lea rdi, [rel fmt_dbl] ; expectable input format 
	lea rsi, [rel deval] ; where to store deviation value
	xor rax, rax ; no float arguments that should be in xmm0-xmm7 registers
	call scanf ; got deviation value

	cmp rax, 1
	jne dev_input_error

	; okay, we got input values: X and deviation
	; we should open file for writing
	
	; open file for writing
	mov rdi, qword [filename]
	lea rsi, [mode_w]
	call fopen
	mov qword [file_handler], rax 
	; file opened

	; calculate numerical series sum
	; start with x + a_1
	
	movsd xmm0, qword [xval]
	movsd xmm1, qword [xval]
	mulsd xmm0, xmm1	
	mulsd xmm0, xmm1 ; xmm0 = x^3
	movsd xmm1, qword [minus]
	mulsd xmm0, xmm1 ; xmm0 = -(x^3)
	movsd xmm1, qword [six]
	divsd xmm0, xmm1 ; xmm0 = (-1) * x^3 * (1/6)	

	movsd qword [cur_a_n], xmm0
	mov qword [sum], 0	
	mov qword [num_iter], 1
	; start cycle
.loop:
	mov rdi, qword [file_handler] ; rdi = FILE*
	lea rsi, [fmt_to_file]
	mov rdx, qword [num_iter] 
	; xmm0 already has a_n value
	mov rax, 1 ; rax = quantity of xmm-registers with data
	call fprintf	

	; restore values
	movsd xmm0, qword [cur_a_n]
	movsd xmm1, qword [sum]
	movsd xmm2, qword [deval] ; xmm2 stores deviation
	addsd xmm1, xmm0
	movsd qword [sum], xmm1 ; sum += cur_a_n

	movsd xmm3, xmm0
	movsd xmm4, qword [sign_mask] ;
	andpd xmm3, xmm4; xmm3 = abs(xmm3)

	comisd xmm2, xmm3 ; if xmm2(deviation) >= xmm3(current a_n)
	jae epilog
	

	call quotient ; after call we have xmm3 = quotient
	mulsd xmm0, xmm3 ; xmm0 = a_(n + 1)
	movsd qword [cur_a_n], xmm0

	mov rdx, qword [num_iter]
	inc rdx
	mov qword [num_iter], rdx ;

	jmp .loop

epilog:
	addsd xmm1, qword [xval] ; numerical series + x
	movsd qword[sum], xmm1 ; save value of summary

	movsd xmm0, qword [xval]
	call asinh
	
	movsd xmm1, qword [sum]

	lea rdi, [rel fmt_end]
	mov rax, 2
	call printf	

	lea rdi, [rel fmt_fragmented_left_calc] ; rdi = format of the string
	call left_fragmented
	; xmm0 = ln(sqrt(x^2 + 1) + x)
	mov rax, 1 ; quantity of float-arguments
	call printf


	lea rdi, [rel fmt_str]
	lea rsi, [rel prog_comp]
	xor rax, rax
	call printf


	mov rdi, qword [file_handler]
	call fclose

prog_end:

	add rsp, 8
	ret


quotient:
	

	movsd xmm3, qword [xval] ; xmm3 = x
	mulsd xmm3, xmm3 ; xmm3 = x^2
	movsd xmm4, qword[minus] ; xmm4 = -1.0
	mulsd xmm3, xmm4 ; xmm3 = -x^2
	movsd xmm4, qword [num_iter]; xmm4 = n
	mulsd xmm4, qword [two] ; xmm4 = 2*n
	addsd xmm4, qword [one] ; xmm4 = 2*n + 1
	movsd xmm5, xmm4 ; xmm5 = xmm4 = 2*n +1
	mulsd xmm4, xmm4 ; xmm4 = (2*n + 1)^2
	mulsd xmm3, xmm4 ; xmm3 = -x^2 * (2n + 1)^2
	addsd xmm5, qword [one] ; xmm5 = (2n + 2)
	movsd xmm4, xmm5 ; xmm4 = (2n + 2)
	addsd xmm4, qword [one] ; xmm4 = (2n + 3)
	mulsd xmm4, xmm5 ; xmm4 = (2n + 2) * (2n + 3)
	divsd xmm3, xmm4 ; xmm3 = -x^2 * (2n + 1)^2 / ((2n + 2)(2n + 3))
	ret

left_fragmented:
	movsd xmm0, qword [xval] ; xmm0 = x
	mulsd xmm0, xmm0 ; xmm0 = x^2
	addsd xmm0, qword [one] ; xmm0 = x^2 + 1
	call sqrt
	; x = sqrt(x^2 + 1)
	addsd xmm0, qword [xval] ; xmm0 = sqrt(x^2 + 1) + x
	call log
	; ln(sqrt(x^2 + 1) + x)
	ret

few_arg:
	lea rdi, [rel fmt_str] ; 1-st arg = format
	lea rsi, [rel no_filename] ; 2-nd arg = first '%<X>' value
	xor rax, rax
	call printf
	
	jmp prog_end

var_input_error:
	lea rdi, [rel fmt_str] ; simple "%"
	lea rsi, [rel incorrect_var]
	xor rax, rax ; because we have zero float arguments
	call printf

	jmp prog_end

dev_input_error:
	lea rdi, [rel fmt_str]
	lea rsi, [rel invalid_deviation]
	xor rax, rax
	call printf
	
	jmp prog_end

