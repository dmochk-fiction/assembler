bits 64

default rel
extern printf, scanf, fgets, stdin, stdout, fflush
extern fopen
extern fclose

section .rodata

one: dq 1.0

sign_mask: dq 0x7FFFFFFFFFFFFFFF ; 1 bit = 1, other 63 equals 0

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

mode_w: db "w+", 0

section .bss

; file work
file_handler: resq 1; = FILE* 
filename: resq 1 ;

; 
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

	cmp rax, 1
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





	
prog_end:
	
	lea rdi, [rel fmt_str]
	lea rsi, [rel prog_comp]
	xor rax, rax
	call printf

	add rsp, 8
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

