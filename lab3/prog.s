bits 64

section .bss
word_length: resq 1 ; to store word length
filename: resq 1 ; to store pointer to filenaeme (it is convinient)


current_string: res_q 1 ; to mark current string
file_desc: resq 1 ; file descriptor (узнать о нём побольше)
buffer_in: resb 4096 ; where we temporary store the chunk of file
buffer_out: resb 4096 ; where we collect data to be send to stdout
section .data
error_no_file: db "Error: file name not found", 10
error_no_file_len: equ $ - error_no_file

error_open: db "Error: file not found", 10
error_open_len: equ $ - error_open

error_read: db "Error: file can not be read", 10
error_read_len: equ $ - error_read


; а здесь сделать сообщение в случае успеха всех этапов обработки файла
success_msg: db "File processed successfuly", 10
success_msg_len: equ $ - success_msg


section .text

global _start

_start:
	pop rax ; rax = argc (amount of arguments given)
	cmp rax, 2
	jl error_filename ; go to error_handler

	; if we are here we got file name
	pop rdi ; path to the current programm argv[0]
	pop rdi ; pointer to the first symbol of the given file name of the source file argv[1]
	mov [filename], rdi ; [filename] = pointer to fisrt symbol of given file name
	; rdi = pointer to file name
	; ====================================================

	; file opening =======================================
	mov rax, 2 ; sys_open
	mov rsi, 0 ; (only READ)
	mov rdx, 0 ; no need at rights of access while opening
	syscall 

	cmp rax, 0 ; if rax >= 0 we continue processing 
	jl error_openfile ; else go to error handler
	

	; file reading ======================================
	mov [file_desc], rax ; store 'fd' value in [file_decs]

.read_file_chunk: ; loop
	mov rax, 0 ; sys_read
	mov rdi, [file_desc] ;
	mov rsi, buffer ; buffer for reading (place where we temporary store current data/chunk)
	mov rdx, 4096 ; maximum value of one read chunk
	syscall
	
	cmp rax, 0 ; then we got End-Of-File and should finish the program
	je success_end ; it means that there is not anything to be read
	jl error_read 
	; else we have somthing in 'buffer' ===> processing

	mov [current_string], buffer
.process_strings:
		
	xor rcx, rcx ; rcx = counter of word length
.get_first_length: ; define length of the first word
	cmp 	
	
	

.process_string:
		

	; so now we have something in our buffer
	; we need to process it using cycle








.exit:
	mov rax, 60 ; sys_exit (60 for 64-bit)
	mov rdi, 0 ; return code 0
	syscall ; system call	

error_filename:
	mov rax, 1 ; sys_write
	mov rdi , 1 ; write to 'stdout'
	mov rsi, error_no_file ; message we want to be displayed in console
	mov rdx, error_no_file_len ; lenght of the message or how many bytes should be displayed
	syscall 

	jmp _start.exit ; возможно стоит сделать вывод с ошибкой особый
	; finish the programm

error_openfile:
	mov rax, 1 ; sys_write
	mov rdi, 1 ; to stdout
	mov rsi, error_open
	mov rdx, error_open_len
	
	jmp _start.exit

error_readfile:
	mov rax, 1 ; sys_write
	mov rdi, 1 ; to STDOUT
	mov rsi, error_read
	mov rdx, error_read_len
	syscall

	jmp _start.exit 

success_end:
	mov rax, 1; sys_write
	mov rdi, 1; stdout
	mov rsi, success_msg
	mov rdx, success_msg_len
	syscall

	jmp _start.exit
