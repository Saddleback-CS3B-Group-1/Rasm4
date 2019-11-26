@Driver for RASM4 
				  .data
byteCount: 		  .word 0
byte_string:	  .skip 12
nodeCount: 		  .word 0
node_string:	  .skip 12
head_ptr:		  .word 0
char_nL:		  .byte 10
tail_ptr:		  .word 0
index:		      .word 0
ptrsubStr:	      .word 0
ptrStr:		      .word 0
outFile: 		  .asciz  "output.txt"
rasmTitle:		  .asciz  "\nRASM4 TEXT EDITOR\n"
memoryComp:	      .asciz  "Data Structure Memory Consumption: "
bytes:			  .asciz  " bytes\n"
numNodesP:		  .asciz  "Number of Nodes: "
enterStringP:	  .asciz  "Enter string: "
enterIndexPrompt: .asciz  "Enter line number: "
InvalidInP:		  .asciz  "Invalid index, not in range\n"
InvalidInP2:	  .asciz  "Invalid input\n"
endProgram:		  .asciz  "Program ended. Thank you for using our program!\n"
emptyList:		  .asciz  "List is empty!\n"
endl:			  .asciz  "\n"
idle_prompt:      .asciz  "\n...enter to continue..."
fileWritePrompt:  .asciz  "FILE READ from \"input.txt\""
fileSavePrompt:   .asciz  "FILE SAVED to \"output.txt\""
fileOut:          .asciz  "output.txt"
removeNodePrompt: .asciz  "...has been removed...\n"
inputBuffer:	  .skip   SIZE
char_lP:          .byte 40
char_rP:          .byte 41
char_wS:          .byte 32
				  .text
	.global _start
	.equ	SIZE, 1024 
	.extern malloc
	.extern free

_start:
/*
	Clear the screen so that the menu can be printed.
*/
    mov r0, #100
	ldr r1, =endl
cls_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls_loop
/*
	Output the menu prompt to the console.
*/
	mov r0, #1
	ldr r1, =rasmTitle		@Output title 
	bl putstring
	ldr r1, =memoryComp
	bl putstring
/*
	Output the current byte count, used by the program.
*/
	ldr r0, =byteCount		@Output byte count on the screen
	ldr r0, [r0]
	ldr r1, =byte_string
	bl intasc32
	bl putstring	
	ldr r1, =bytes			@Output "bytes"
	bl putstring
/*
	Output the current node count, used by the proram.
*/
	ldr r1, =numNodesP	@Output "Number of Nodes: "
	bl putstring
	ldr r0, =nodeCount		@Output number of nodes to the screen
	ldr r0, [r0]
	ldr r1, =node_string
	bl intasc32
	bl putstring
/*
	Call "menu" which will produce desired options and
	handle menu input validation.
*/
	ldr r1, =endl
	bl putstring
	bl menu			@Output the menu to view selection
/*
	Evaluate the result from the menu interaction and call
	appropriate subroutine to handle request.
*/
	cmp r0, #'1'			@If the user input is 1, then branch to print_list
	beq printListOption			@Output link list
	cmp r0, #'a'
	beq addStringOption
	cmp r0, #'A'
	beq	addStringOption
	cmp r0, #'b'
	beq fileStringsOption
	cmp r0, #'B'
	beq fileStringsOption
	cmp	R0,#'3'		
	beq	removeStringOption
	cmp	R0,#'4'		
	beq	editStringOption
	cmp	R0,#'5'		
	beq	searchStringOption
	cmp	R0,#'6'		
	beq	saveFileOption
	cmp	R0,#'7'	
	beq	endProgramOption
	/* RETURN TO START */
	b _start

editStringOption:
/* 
	First check if current head pointer
	points to 'NULL' or 0.
*/
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	beq listEmpty
/*
	Clear the screen so that the menu can be printed.
*/
    mov r0, #100
	ldr r1, =endl
cls10_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls10_loop
/*
	Prompt the user for which line to edit.
	User enters in a line number which is 
	then subtracted by 1 to be used as the
	index, for the linked list.
*/
	ldr r1, =enterIndexPrompt
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl ascint32
	sub r0, #1
	ldr r1, =index	
	str r0, [r1]
	cmp r0, #0
	blt invalidRange
	ldr r1, =nodeCount
	ldr r1, [r1]
	cmp r0, r1
	bgt invalidRange
/*
	Use the index with "data_at" to retrieve the
	original string value of indexed node. If 0
	is returned, the index was too high.
*/
	ldr r1, =head_ptr 	@load head_ptr into r1
	mov r2, r0  		@index of node
	bl data_at 			@call data_at to get address of desired node data
	cmp r0, #0			@if null was returned, then output that desired index is invalid
	beq invalidRange
/*
	Unload the string from memory and retrieve its
	length using "String_length".
*/
	mov r4, r0 			@mov desired node address to r4
	ldr r1, [r4] 		@load string from desired node
	bl String_length
	mov r6, r0 			@move the string length of the old string into r6
/*
	Prompt and receive the new desired string from 
	the user. The string is then appended with a 
	new line character and then concatenated using
	"String_concat". The intermediary string is
	then subsequently freed.
*/
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl String_copy
	mov r1, r0
	ldr r2, =char_nL
	bl String_concat		@branch link to string concat
	mov r5, r0
	mov r0, r1
	push {r0-r12}
	bl free
	pop {r0-r12}
/*
	The new string is then passed to "String_length
	so that the current bytecount can be modified 
	to account for the edit."
*/
	mov r0, r5
	mov r2, r0 			@String address is in r1
	mov r1, r0
	bl String_length	@get string length of new string

	ldr r1, =byteCount	@Load byteCount variable
	ldr r5, [r1]		@load byteCount value
	sub r5, r6 
	add r5, r0			@sum the total byte count
	str r5, [r1]		@store the new byte count, which will increment bytes displayed on screen
/*
	Set up the "edit_node" list library function
	call by placing the head node, new string
	address, and list index in R1, R2, and R3
	respectively.
*/
	ldr r1, =head_ptr
	ldr r3, =index
	ldr r3, [r3]
	bl edit_node
	/* RETURN TO START */
	b _start
	
/*
	Outputs for results of invalid user inputs for
	"edit string option".
*/
invalidRange:
    mov r0, #100
	ldr r1, =endl
cls8_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls_loop
	ldr r1, =InvalidInP @output invalid range
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start

invalidInput:
    mov r0, #100
	ldr r1, =endl
cls9_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls_loop
	ldr r1, =InvalidInP2
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start

	
printListOption:
/*
	First check if the current head is NULL or 0,
	and then if not, output the list contents by
	calling "print_list". And finally output an
	idle statement, and wait for user to press
	enter by calling "getstring".
*/
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	beq listEmpty
	ldr r1, =head_ptr
	bl print_list
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start
	
listEmpty:
/*
	Clear the screen for menu print.
*/
	mov r0, #100
	ldr r1, =endl
cls4_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls4_loop
/*
	Print the empty list and idle prompt and wait
	for user input by calling "getline".
*/
	ldr r1, =emptyList
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start

addStringOption:
/*	Prompt the user to enter their new desired string
	and append a new line character by calling 
	"String_concat". The temporary string is then
	freed to recover system memory.
*/
	mov	R0, #1		@ Set output to stdout
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl String_copy
	mov r1, r0
	ldr r2, =char_nL
	bl String_concat		@branch link to string concat
	mov r5, r0
	mov r0, r1
	push {r0-r12}
	bl free
	pop {r0-r12}
/*
	The new string is then passed to "String_length" to
	increment current byte count. Each time a node is 
	generated in this way the count is incremented by
	"newString.length() + 9", where the 9 is given by
	"1(null character) + 8(bytes needed for node)"
*/
	mov r0, r5
	mov r1, r0
	bl String_length
	add r0, #9			@add 1 to string length for null byte
	ldr r1, =nodeCount
	ldr r6, [r1]
	add r6, #1
	str r6, [r1]
	ldr r1, =byteCount		@Load byteCount variable
	ldr r3, [r1]			@load byteCount value
	add r3, r0			@sum the total byte count
	str r3, [r1]			@store the new byte count, which will increment bytes displayed on screen
/*
	A new 8 byte link node is generated for the new string.
	Then the new string and node are passed to fill_node,
	which places the string inside the node.
*/
	bl build_node			@build new node with string
	mov r1, r0
	mov r2, r5			@preverse new string
	bl fill_node			@stick data address into node
/*
	The head is checked for the value of NULL or 0, if so
	the new node is added as the new head, otherwise the
	new node is placed at the end of the list by calling
	"link_tail".In either case the node is given the value
	of NULL or 0 stored in its next pointer address by 
	calling "link_node", prior to insertion.
*/
	mov r4, r1
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	bne addTail
addHead:
	mov r1, r4
	mov r2, #0
	bl link_node 
	ldr r1, =head_ptr
	str r4, [r1]
	/* RETURN TO START */
	b _start
addTail:
	mov r1, r4
	mov r2, #0
	bl link_node
	ldr r1, =head_ptr
	mov r2, r4
	bl link_tail
	/* RETURN TO START */
	b _start				@branch back to start function

fileStringsOption:
/*
	Pass the head pointer to "load_file" which
	will create or append a list by series of
	a read system calls.
*/
	ldr r1, =head_ptr
	bl load_file
	mov r5, r0
	mov r6, r2
	ldr r4, =head_ptr
	str r1, [r4]
/*
	Update the current bytecount by adding the
	total bytes returned from "load_file" to the
	current count.
*/
	ldr r1, =byteCount		@Load byteCount variable
	ldr r0, [r1]
	add r0, r5			@sum the total byte count
	str r0, [r1]			@store the new byte count, which will increment bytes displayed on screen
	ldr r1, =nodeCount
	ldr r0, [r1]
	add r0, r6
	str r0, [r1]
/*
	Clear the screen and prompt the user with the
	"file read from" message and wait for user input
	by calling "getline".
*/
	mov r0, #100
	ldr r1, =endl
cls2_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls2_loop
	ldr r1, =fileWritePrompt
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start				@branch back to start function

searchStringOption:
/*
	Check if head is currently empty.
*/
	ldr r1, =head_ptr
	ldr r0, [r1]
	cmp r0, #0
	beq listEmpty
/*
	Clear the menu for search results.
*/
	mov r0, #100
	ldr r1, =endl
cls5_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls5_loop
	mov r0, #1
/*
	Prompt the user for the search string,
	and then output all strings that contain
	the search string by calling "search_list".
	Finally, wait for user to press enter by
	calling "getstring".
*/
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring	
	ldr r1, =inputBuffer
	bl String_copy
	ldr r1, =head_ptr
	mov r2, r0 		@make copy of desired string input and put in r3
	bl search_list
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start 

saveFileOption:
/* 
	Open a new output file and pass the file handle 
	and head pointer to "write_list", which will
	write the list's contents to disk.
*/
	ldr r0, =fileOut
	mov r1, #0101
	ldr r2, =0666
	mov r7, #5
	svc 0
	mov r2, r0
	ldr r1, =head_ptr
	bl write_list
/*
	Clear the screen and prompt the user with the
	file write confirmation and wait for user input
	by calling "getline".
*/
	mov r0, #100
	ldr r1, =endl
cls3_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls3_loop
	ldr r1, =fileSavePrompt
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start

removeStringOption:
/*
	Check if head is currently empty.
*/
	ldr r1, =head_ptr
	ldr r0, [r1]
	cmp r0, #0
	beq listEmpty
/*
	Clear the menu.
*/
	mov r0, #100
	ldr r1, =endl
cls6_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls6_loop
	mov r0, #1
/*
	Prompt the user for the search string,
	and then output all strings that contain
	the search string by calling "search_list".
	Finally, wait for user to press enter by
	calling "getstring".
*/
	ldr r1, =enterIndexPrompt
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl ascint32
	sub r0, #1
	ldr r1, =index	
	str r0, [r1]
	cmp r0, #0
	blt invalidRange
	ldr r1, =nodeCount
	ldr r1, [r1]
	cmp r0, r1
	bgt invalidRange
/*
	Use the index with "data_at" to retrieve the
	original string value of indexed node. If 0
	is returned, the index was too high.
*/
	ldr r1, =head_ptr 	@load head_ptr into r1
	mov r2, r0  		@index of node
	bl data_at 			@call data_at to get address of desired node data
	cmp r0, #0			@if null was returned, then output that desired index is invalid
	beq invalidRange
/*
	Unload the string from memory and retrieve its
	length using "String_length".
*/
	mov r4, r0 			@mov desired node address to r4
	ldr r1, [r4] 		@load string from desired node
	bl String_length
	mov r6, r0 			@move the string length of the old string into r6
    ldr r1, =nodeCount
	ldr r0, [r1]
	sub r0, #1
	str r0, [r1]
	ldr r1, =byteCount
	ldr r0, [r1]
	sub r0, #9
	sub r0, r6
	str r0, [r1]
/*
	Pass the head pointer and index to "remove_node"
	which will remove the requested node. The removed
	string is presented to the user and waits for enter
	input by calling "getstring".
*/
    ldr r1, =char_lP
	bl putch
	ldr r1, =index
	ldr r0, [r1]
	add r0, #1
	ldr r1, =byte_string
	bl intasc32
	bl putstring
	ldr r1, =char_rP
	bl putch
	ldr r1, =char_wS
	bl putch
	ldr r1, [r4]
	bl putstring
	ldr r1, =removeNodePrompt
	bl putstring
	ldr r1, =index
	ldr r2, [r1]
	ldr r1, =head_ptr
	bl remove_node
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	/* RETURN TO START */
	b _start

endProgramOption:
/*
	Prompt the user with the exit program message
	and then pass the head pointer to "clear_list"
	which will free up all memory allocations the 
	list inhabits. Then closes the program with
	system call.
*/
	ldr r1, =endProgram
	bl putstring
	ldr r1, =head_ptr
	bl clear_list
	mov r7, #1
	svc 0
	.end
