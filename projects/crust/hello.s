.intel_syntax noprefix
.section .text
.global  _start

_start:
	mov rax, 1
	mov rdi, 1
	mov rsi, OFFSET hello
	mov rdx, OFFSET len
	syscall
	mov rax, 60
	mov rdi, 0
	syscall

	.section .rodata

hello:
	.ascii "Hello, Lars!\n"
	.set   len, . - hello
