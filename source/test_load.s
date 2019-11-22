		.data
     filename: .asciz "input.txt"
	  fileOut: .asciz "output.txt"
  file_handle: .word 0
 input_buffer: .skip 1025
     head_ptr: .word 0
remainder_ptr: .word 0
   byte_count: .word 0
      char_nL: .byte 10
	  		   .text
	  		   .equ SIZE, 1024
			   .global _start

_start:
		ldr r0, =filename
		mov r1, #00
		ldr r2, =0666
		mov r7, #5
		svc 0
		cmp r0, #0    @branch to done if open fails
	    beq done
		ldr r1, =file_handle
		str r0, [r1]  @preserve the file handle
		mov r11, #1   @set r11 to 1, for control flag of buffer loop
buffer_loop:
		ldr r0, =file_handle
		ldr r0, [r0]
		cmp r11, #0
		beq done
		ldr r1, =input_buffer
		mov r2, #SIZE
		mov r7, #3
		svc 0

		cmp r0, #SIZE  @if bytes read is less than buffer size, file is done
		movlt r11, #0
		ldr r1, =byte_count
		str r0, [r1]
		mov r3, #SIZE
		sub r3, r0
		add r0, r3
		ldr r1, =input_buffer
		mov r2, #0
		add r1, r0
		strb r2, [r1]     @add null terminator to end of buffer
		mov r7, #0
inner_loop:
		ldr r1, =byte_count
		ldr r1, [r1]
		cmp r7, r1
		bge inner_done
		ldr r1, =input_buffer
		add r1, r7
		ldr r2, =char_nL
		ldrb r2, [r2]
		bl String_indexOf_1
		cmp r0, #-1
		beq inner_done
		mov r3, r0
		add r3, r7          @set end index to currentIndex + firstIndexOf result
		ldr r1, =input_buffer
		mov r2, r7
		mov r7, r3          
		add r7, #1          @set current index to end of current string + 1
		ldr r5, =byte_count
		ldr r5, [r5]
		cmp r3, r5
		movge r3, r5
		subge r3, #1
		bl String_substring_1
		ldr r1, =remainder_ptr
		ldr r1, [r1]
		cmp r1, #0
		blne remainder_include
		mov r8, r0          @preserve our new string
		mov r1, r0
		bl String_length
		add r9, r0
		add r9, #1          @update our byte count (stringLength + 1)
		bl build_node
		mov r2, r8
		mov r1, r0
		bl fill_node
		mov r2, r1
		ldr r1, =head_ptr
		ldr r1, [r1]
		cmp r1, #0          @check if head is empty
		beq empty_head
		mov r1, r2
		mov r2, #0
		bl link_node
		mov r2, r1
		ldr r1, =head_ptr
		bl link_tail
		b inner_loop

empty_head:
		mov r1, r2
		mov r2, #0
		bl link_node
		mov r2, r1
		ldr r1, =head_ptr
		str r2, [r1]
		b inner_loop

remainder_include:
		push {lr}
		ldr r1, =remainder_ptr
		ldr r1, [r1]
		mov r2, r0
		bl String_concat
		mov r5, r0
		mov r0, r2
		push {r0-r12}
		bl free
		pop {r0-r12}
		mov r0, r1
		push {r0-r12}
		bl free
		pop {r0-r12}
		mov r0, r5
		mov r2, #0
		ldr r3, =remainder_ptr
		str r2, [r3]
		pop {lr}
		bx lr

inner_done:
		cmp r11, #0
		beq buffer_loop
		ldr r1, =input_buffer
		mov r2, r7
		ldr r3, =byte_count
		ldr r3, [r3]
		sub r3, #1
		bl String_substring_1
		ldr r1, =remainder_ptr
		str r0, [r1]
		b buffer_loop

done:
		ldr r0, =file_handle
		ldr r0, [r0]
		mov r7, #6
		svc 0

		ldr r0, =fileOut
		mov r1, #0101
		ldr r2, =0666
		mov r7, #5
		svc 0
		ldr r1, =file_handle
		str r0, [r1]  @preserve the file handle

		mov r2, r0
		ldr r1, =head_ptr
		bl write_list

		ldr r0, =file_handle
		ldr r0, [r0]
		mov r7, #6
		svc 0
		
		ldr r1, =head_ptr
		bl print_list
		ldr r1, =char_nL
		bl putch
		ldr r1, =head_ptr
		bl clear_list

		mov r7, #1
		svc 0
		.end		
