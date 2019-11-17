		.data
prompt_input: .asciz "Enter a string: "
input_buffer: .skip 1024
    ptr_head: .word 0
	 char_nL: .byte 10
		.text
		.global _start

_start:

		ldr r1, =prompt_input
		bl putstring
		ldr r1, =input_buffer
		mov r2, #1024
		bl getstring
		mov r0, r1
		bl String_copy
		mov r5, r0
		bl build_node
		mov r1, r0
		mov r2, r5
		bl fill_node
		mov r2, #0
		bl link_node
		ldr r1, =ptr_head
		str r0, [r1]
		mov r10, #3

loop:
		cmp r10, #0
		beq loop_done
		ldr r1, =prompt_input
		bl putstring
		ldr r1, =input_buffer
		mov r2, #1024
		bl getstring
		mov r0, r1
		bl String_copy
		mov r5, r0
		bl build_node
		mov r1, r0
		mov r2, r5
		bl fill_node
		mov r2, r1
		ldr r1, =ptr_head
		bl link_tail
		sub r10, #1
		b loop
		
loop_done:
		ldr r1, =ptr_head
		bl print_list

		ldr r1, =ptr_head
		mov r2, #1
		bl remove_node

		ldr r1, =ptr_head
		bl print_list

		ldr r1, =ptr_head
		bl clear_list

		ldr r1, =char_nL
		bl putch

terminate:
		mov r7, #1
		svc 0

		.end
