		.global build_node
		.global link_tail
		.global fill_node
		.global link_node
		.global data_at
		.global edit_node
		.global print_list
		.global search_list
		.global write_list
		.global remove_node
		.global clear_list
		.extern malloc
		.extern free
		.data
		char_lP: .byte 40 
		char_rP: .byte 41
		char_wS: .byte 32
		num_out: .skip 4
		.text
@--- Generates a new 8 byte node ---@ @INPUT: nan
build_node:
		push {r4-r8,r10,r11,lr}
		mov r0, #8
		bl malloc
		pop {r4-r8,r10,r11,lr}
		bx lr
@-----------------------------------------------------@

@--- Adds a given node to the end of a given list. ---@ @INPUT: R1=Address of the head node , R2=Address of the new node
link_tail:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
tail_loop:
		cmp r4, #0
		beq tail_end
		mov r1, r4
		add r4, #4
		ldr r4, [r4]
		b tail_loop
tail_end:
		bl link_node
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr
@------------------------------------------------@

@--- Inserts a data-address into a given node ---@ @INPUT: R1=Address of the node, R2=Address of the data
fill_node:
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
		str r2, [r1]
		pop {r4-r8,r10,r11,lr}
		bx lr
@--------------------------------------------@ @INPUT: R1=Address of the parent node, R2=Address of the child node

@--- Links a node to a another given node ---@
link_node:
		push {r4-r8,r10,r11,lr}
		mov r4, r1
		add r4, #4
		str r2, [r4]
		pop {r4-r8,r10,r11,lr}
		bx lr
@--------------------------------------@

@--- Returns the data address of a requested node ---@ @INPUT:R1=Address of the head node, R2=index of node
data_at:                                               @OUTPUT: R0=address of node's data
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
at_loop:
		cmp r2, #0
		beq at_done
		add r4, #4
		ldr r4, [r4]
		sub r2, #1
		b at_loop
at_done:
		mov r0, r4
		pop {r4-r8,r10,r11,lr}
		bx lr
@---------------------------------------@
		
@----------------------------------------------------@

@--- Edit a node with the given index ---@ @INPUT: R1=Address of head node, R2=Address of a data, R3=index of node
edit_node:
		mov r8, r1
		push {r4-r8,r10,r11,lr}		
		ldr r4, [r1]
edit_loop:
		cmp r3, #0
		beq edit_done
		add r4, #4
		ldr r4, [r4]
		sub r3, #1
		b edit_loop
edit_done:
		mov r1, r4
		bl fill_node
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr

@----------------------------------------@

@--- Prints the list to the console ---@ @INPUT:R1=Address of head node
print_list:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
		mov r7, #1
print_loop:
		cmp r4, #0
		beq print_end
		ldr r1, =char_lP
		bl putch
		mov r0, r7
		ldr r1, =num_out
		bl intasc32
		bl putstring
		add r7, #1
		ldr r1, =char_rP
		bl putch
		ldr r1, =char_wS
		bl putch
		ldr r1, [r4], #4
		bl putstring
		ldr r4, [r4]
		b print_loop
print_end:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr
@-----------------------------@

@--- Print matching strings ---@
search_list:
		mov r8, r1
		mov r10, r2
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
		mov r7, #1
search_loop:
		cmp r4, #0
		beq search_end
		ldr r1, [r4]
		mov r2, r10
		bl String_indexOf_3
		cmp r0, #0
		blt search_bypass_print
		ldr r1, =char_lP
		bl putch
		mov r0, r7
		ldr r1, =num_out
		bl intasc32
		bl putstring
		ldr r1, =char_rP
		bl putch
		ldr r1, =char_wS
		bl putch
		ldr r1, [r4]
		bl putstring
search_bypass_print:
		add r7, #1
		add r4, #4
		ldr r4, [r4]
		b search_loop
search_end:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr

@------------------------------@

@--- Write the list to a file ---@ @INPUT:R1=Address of head node, R2=file handle for output
write_list:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
		mov r7, #4
		mov r3, r2
write_loop:
		cmp r4, #0
		beq write_done
		ldr r1, [r4], #4
		bl String_length
		mov r2, r0
		mov r0, r3
		svc 0
		ldr r4, [r4]
		b write_loop
write_done:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr
@--------------------------------@

@--- Removes a node from a given list ---@ @INPUT: R1=Address of head node, R2=index of node to remove
remove_node:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		mov r3, #0
		ldr r4, [r1]
remove_loop:
		cmp r2, #0
		beq remove_consider
		mov r3, r4
		add r4, #4
		ldr r4, [r4]
		sub r2, #1
		b remove_loop
remove_consider:
		cmp r3, #0
		beq remove_head
		mov r5, r4
		add r5, #4
		ldr r5, [r5]
		cmp r5, #0
		beq remove_tail
		b remove_middle
remove_head:
		ldr r0, [r4]
		bl free
		mov r0, r4
		add r4, #4
		ldr r5, [r4]
		bl free
		str r5, [r8]
		b remove_end
remove_tail:
		add r3, #4
		mov r0, #0
		str r0, [r3]
		ldr r0, [r4]
		bl free
		mov r0, r4
		bl free
		b remove_end
remove_middle:
		mov r1, r3
		mov r2, r5
		bl link_node
		ldr r0, [r4]
		bl free
		mov r0, r4
		bl free
remove_end:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr

@----------------------------------------@


@--- Frees the entire list ---@ @INPUT: R1=Address of head node
clear_list:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		ldr r1, [r1]
clear_loop:
		cmp r1, #0
		beq clear_end
		mov r5, r1
		ldr r0, [r1], #4
		ldr r4, [r1]
		push {r0-r12}
		bl free
		pop {r0-r12}
		mov r0, r5
		push {r0-r12}
		bl free
		pop {r0-r12}
		mov r1, r4
		b clear_loop
clear_end:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		mov r7, #0
		str r7, [r8]
		bx lr
@------------------------------@
		.end
