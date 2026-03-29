bits 64

section .bss
fword_len: resq 1 ; to store first word of the string length
word_len: resq 1; to store other word length

filename: resq 1 ; to store pointer to filename (it is convinient)


file_desc: resq 1 ; file descriptor (узнать о нём побольше)
buffer_in: resb 4096 ; where we temporary store the chunk of file
buffer_out: resb 4096 ; where we collect data to be send to stdout

last_act: resb 1 ; to know if the current print last or not
flag_fw: resb 1; to know if the current processing word is first or not : 0 - first, else – no

st_word: resw 1 ; to have offest for first letter of the current word
idx_in: resw 1 ; to store current position in buffer_in
idx_out: resw 1 ; to store current position in buffer_out




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
	mov rdi, [file_desc] ; load descriptor to rdi
	mov rsi, buffer_in ; buffer for reading (place where we temporary store current data/chunk)
	mov rdx, 4096 ; maximum value of one read chunk
	syscall
	
	cmp rax, 0 ; then we got End-Of-File and should finish the program
	je success_end ; it means that there is not anything to be read
	jl error_read 
	; else we have somthing in 'buffer' ===> processing

	mov r8, -1 ; idx in buffer_in
.process_special:
	inc r8
	mov [idx_in], r8w

	cmp r8, 4096
	je to_stdout ; ну или типа того пока что
	; добавить проверку на получение нуль-терминатораш

	mov r9b, [buffer_in + r8 * 1] ; 
	cmp r9b, 0
	je .read_file_chunk ; to eventually come to 'rax = 0' and success_end mark
	cmp r9b, 32 ; we got ' ' => process next symbol
	je .process_special
	cmp r9b, 9 ; we got '\t' => process next symbol
	je .process_special
	cmp r9b, 10 ; we got '\n'/Line feed =>
	je insert_lf ; in 'buffer_out;	
	
	mov r10, r8 ; to do subtraction (r8 - r10) afret the cycle 
.get_word_length: ; define length of the first word	
	; if we are here, then we need to start defining length of the next word
	inc r8 ; take next index
	mov [idx_in], r8w

	cmp r8, 4096 ; then we have reached the end of the 'buffer_in' and need to move 'file descriptor'
	je offset_fd ; we do offset for out file descriptor


	mov r9b, [buffer_in + r8 * 1] ; got symbol of the next symbol
	cmp r9b, 0
	je process_word ; to eventually come to 'rax = 0' and success_end mark
	cmp r9b, 32 ; 
	je process_word
	cmp r9b, 9
	je process_word
	cmp r9b, 10
	je process_word
	jmp .get_word_length
	

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
	mov byte [last_act], 1
	call to_stdout

	mov rax, 1; sys_write
	mov rdi, 1; stdout
	mov rsi, success_msg
	mov rdx, success_msg_len
	syscall

	jmp _start.exit

insert_lf: ; insert Line Feed
	push r8

	movzx r8, word [idx_out]
	mov byte [buffer_out + r8 * 1], 10
	inc r8
	mov [idx_out], r8w
	mov byte [flag_fw], 0 ; so we got ending of the line and next word is first
	
	pop r8
	jmp _start.process_special

process_word:
	mov word [st_word], r10w
	sub r10, r8 ; r10 = -word_length
	neg r10 ; r10 = word_length < WORD
	
	dec r8 ; to process character immediatly after the world, else we ignore this probably important character
	
	cmp byte [flag_fw], 1
	je cmp_len ; then we compare lengths and decide to add the word to string or not
	; if we are here then, we need assign [fword_len] current word length and copy it to buffer_out
	mov [fword_len], r10w
	call copy_word
	mov byte [flag_fw], 1

	jmp _start.process_special

cmp_len:
	movzx r11, word [fword_len] ; r11w = length of the first symbol of the string
	cmp r10, r11
	jne _start.process_special
	call copy_word
	jmp _start.process_special

copy_word:
	cmp byte [flag_fw], 0
	je skip
	movzx rbx, word [idx_out]
	mov byte [buffer_out + rbx], 32 ; arrange ' ' character before every copy
	add word [idx_out], 1 ;
skip:
	movzx rbx, word [st_word]
	mov rsi, buffer_in ; rsi = buffer_in
	add rsi, rbx ; rsi = buffer_in + [st_word] => rsi is pointer ot first symbol of the current word

	movzx rbx, word [idx_out]
	mov rdi, buffer_out ; rsi = buffer_out
	add rdi, rbx ; rdi = buffer_out + [idx_out] => rsi is a pointer to first free byte in buffer_out

	mov rcx, [fword_len] ; counter
	rep movsb
	
	mov r11w, [idx_out]
	add r11w, word [fword_len]
	mov [idx_out], r11w

	ret


offset_fd: ; do left offset for file descriptor to start processing current word with no separation between different buffers
	sub r10, r8 ; current read length of the word (NEGATIVE)	

	mov rax, 8 ; lseek
	mov rdi, [file_desc]
	mov rsi, r10
	mov rdx, 1 ; SEEK_CUR (from current)
	syscall
	
	; after we should print values to STDOUT
	jmp to_stdout


to_stdout:
	mov rax, 1 ; syscall write (64-bit)
	mov rdi, 1 ; STDOUT
	mov rsi, buffer_out
	movzx rdx, word [idx_out] ; idx_out is offset in 'buffer_out' to first free byte so length of the written text is equal to idx_out
	syscall
	; so buffer_out is in STDOUT (i hope)
	mov word [idx_out], 0 ; because we refresh buffer_out
	mov word [idx_in], 0 ; because we refresh buffer_in
	

	; we have no necessary to take care about the word separation and go next
	cmp byte [last_act], 0 
	je _start.read_file_chunk
	
	; if we are here then we have just printed last chunk
	ret




