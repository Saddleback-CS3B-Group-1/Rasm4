@Driver for RASM4 
	.global _start
	.equ	SIZE, 1024 
	.data
byteCount: 		.word 0
byte_string:		.skip 12
nodeCount: 		.word 0
node_string:		.skip 12
head_ptr:		.word 0
char_nL:		.byte 10
tail_ptr:		.word 0
index:		.word 0
outFile: 		.asciz 	"output.txt"
rasmTitle:		.asciz	"\nRASM4 TEXT EDITOR\n"
memoryComp:	.asciz	"Data Structure Memory Consumption: "
bytes:			.asciz	" bytes\n"
numNodesP:		.asciz	"Number of Nodes: "
enterStringP:		.asciz	"Enter string: "
enterIndexPrompt:	.asciz	"Enter index: "
InvalidInP:			.asciz	"Invalid index, not in range\n"
InvalidInP2:		.asciz	"Invalid input\n"
endProgram:		.asciz 	"Program ended. Thank you for using our program!\n"
emptyList:		.asciz 	"List is empty!\n"
endl:			.asciz	"\n"
inputBuffer:		.word 	SIZE

	.text
	.extern malloc
	.extern free

start:

	mov r0, #1
	ldr r1, =rasmTitle		@Output title 
	bl putstring
	ldr r1, =memoryComp
	bl putstring

	ldr r0, =byteCount		@Output byte count on the screen
	ldr r0, [r0]
	ldr r1, =byte_string
	bl intasc32
	bl putstring
	
	ldr r1, =bytes			@Output "bytes"
	bl putstring

	ldr r1, =numNodesP	@Output "Number of Nodes: "
	bl putstring

	ldr r0, =nodeCount		@Output number of nodes to the screen
	ldr r0, [r0]
	ldr r1, =node_string
	bl intasc32
	bl putstring

	ldr r1, =endl
	bl putstring
	
	bl menu			@Output the menu to view selection
	
	

	cmp r0, #'1'			@If the user input is 1, then branch to print_list
	beq printListOption			@Output link list
	
	cmp r0, #'a'
	beq addStringOption
	cmp r0, #'A'
	beq	addStringOption

	@cmp r0, #'b'
	@beq fileStringsOption
	@cmp r0, #'B'
	@beq fileStringsOption

	@cmp	R0,#'3'		
	@beq	removeStringOption
	
	cmp	R0,#'4'		
	beq	editStringOption
	
	@cmp	R0,#'5'		
	@beq	searchStringOption
	
	@cmp	R0,#'6'		
	@beq	saveFileOption
	
	cmp	R0,#'7'	
	beq	endProgramOption

editStringOption:

	@ldr r1, =head_ptr
	@ldr r1, [r1]
	@cmp r1, #0
	@beq listEmpty
	
	ldr r1, =enterIndexPrompt
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl ascint32
	@bcs invalidInput
	@bvs invalidRange
	ldr r1, =index
	
	str r0, [r1]
	cmp r1, #0
	blt invalidRange
	ldr r1, =head_ptr 	@load head_ptr into r1
	mov r2, r0  		@index of node
	bl data_at 			@call data_at to get address of desired node data
	cmp r0, #0			@if null was returned, then output that desired index is invalid
	beq invalidRange
	mov r4, r0 			@mov desired node address to r4
	ldr r0, [r4] 		@load string from desired node
	bl String_length
	mov r5, r0 			@move the string length of the old string into r5
	
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl String_copy
	mov r2, r0 			@String address is in r2
	bl String_length	@get string length of new string
	sub r0, r5 			@subtract old string length from new string
	ldr r1, =byteCount	@Load byteCount variable
	ldr r6, [r1]		@load byteCount value
	add r6, r0			@sum the total byte count
	str r6, [r1]		@store the new byte count, which will increment bytes displayed on screen
	
	ldr r1, =head_ptr
	ldr r3, =index
	ldr r3, [r3]
	bl edit_node
	
	b start
	
invalidRange:
	ldr r1, =InvalidInP @output invalid range
	bl putstring
	b editStringOption

invalidInput:
	ldr r1, =InvalidInP2
	bl putstring
	b editStringOption

	
printListOption:
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	beq listEmpty
	ldr r1, =head_ptr
	bl print_list
	b start
	
listEmpty:
	ldr r1, =emptyList
	bl putstring
	b start

addStringOption:
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
	@ldrb r2, [r2]			@original string and string as the newline character
	bl String_concat		@branch link to string concat
	mov r5, r0
	mov r0, r1
	push {r0-r12}
	bl free
	pop {r0-r12}
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
	bl build_node			@build new node with string
	mov r1, r0
	mov r2, r5			@preverse new string
	bl fill_node			@stick data address into node
	mov r4, r1
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	@call link node func 
	bne addTail
addHead:
	mov r1, r4
	mov r2, #0
	bl link_node 
	ldr r1, =head_ptr
	str r4, [r1]
	b start
addTail:
	mov r1, r4
	mov r2, #0
	bl link_node
	ldr r1, =head_ptr
	mov r2, r4
	bl link_tail
	b start				@branch back to start function

/****
fileStringsOption:
	ldr r1, =head_ptr
	ldr r2, =tail_ptr			@Parameters r1 and r2 are passed into readFileFunc
	bl readFileFunc		@***Have to construct this function to add to list.s, function will return byteCount into r0
	ldr r1, =byteCount		@Load byteCount variable
	ldr r3, [r1]				@load byteCount value
	add r3, r0				@sum the total byte count
	str r3, [r1]				@store the new byte count, which will increment bytes displayed on screen
	b start				@branch back to start function
****/

endProgramOption:
	ldr r1, =endProgram
	bl putstring
	mov r7, #1
	svc 0
	.end

