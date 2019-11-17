		.global build_node
		.global link_tail
		.global fill_node
		.global link_node
		.global print_list
		.global remove_node
		.global clear_list
		.extern malloc
		.extern free
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

@--- Prints the list to the console ---@ @INPUT:R1=Address of head node
print_list:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		ldr r4, [r1]
print_loop:
		cmp r4, #0
		beq print_end
		ldr r1, [r4], #4
		bl putstring
		ldr r4, [r4]
		b print_loop
print_end:
		pop {r4-r8,r10,r11,lr}
		mov r1, r8
		bx lr
@-----------------------------@

@--- Removes a node from a given list ---@ @INPUT: R1=Address of head node, R2=index of node to remove
remove_node:
		mov r8, r1
		push {r4-r8,r10,r11,lr}
		mov r3, #0
		ldr r4, [r1]
remove_loop:
		cmp r2, #0
		beq remove_consider
		mov r1, r4
		add r4, #4
		ldr r4, [r4]
		b tail_loop
remove_consider:
		cmp r3, #0
		beq remove_head
		b remove_other
remove_head:
		ldr r0, [r4]
		bl free
		mov r0, r4
		add r4, #4
		ldr r5, [r4]
		bl free
		str r5, [r8]
remove_other:
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
		bl free
		mov r0, r5
		bl free
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
