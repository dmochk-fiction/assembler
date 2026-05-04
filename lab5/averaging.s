bits 64

; Передача аргументов: Первые 6 аргументов целочисленного типа или
; указателей передаются через регистры (rdi, rsi, rdx, rcx, r8, r9), остальные — через стек.


section .text
global img_averaging_asm

img_averaging_asm:
	; rdi = char* img_data
	; rsi = weidth
	; rdx = height

	mov rax, rsi
	mul rdx ; rax = rsi * rdx = number of pixels

	xor rcx, rcx ; rcx = counter (i) = 0
	mov r8, 3 ; r8 = number of colors makeing up a pixel
	
.loop:
	xor r11, r11 ; r11 = sum = 0
	mov r9, r8 ; r9 = 3
	imul r9, rcx ; r9 = 3 * counter

	movzx r10, byte [rdi + r9 + 0] ; r10 = red
	add r11, r10 ; r11 = red

	movzx r10, byte [rdi + r9 + 1] ; r10 = green
	add r11, r10 ; r11 = red + green


	movzx r10, byte [rdi + r9 + 2] ; r10 = blue
	add r11, r10 ; r11 = red + green + blue

	push rax

	mov rax, r11 ; rax = r11 = red + green + blue < 256 *  3 = 768
	xor rdx, rdx ; rdx = 0 to establish correct division by 3
	div r8 ; rdx:rax / r8o
	mov r11, rax ; (red + green + blue) / 3

	pop rax

	mov byte [rdi + r9 + 0], r11b
	mov byte [rdi + r9 + 1], r11b
	mov byte [rdi + r9 + 2], r11b

	inc rcx
	cmp rcx, rax
	jne .loop

.done:
	ret
