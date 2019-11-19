@Driver for RASM4 
	.global _start
	.equ	SIZE, 1024 
	.data
byteCount: 		.word 0
nodeCount: 		.word 0
head_ptr:			.word 0
tail_ptr:			.word 0
outFile: 			.asciz 	"output.txt"
rasmTitle:		.asciz	"RASM4 TEXT EDITOR\n"
memoryComp:	.asciz	"Data Structure Memory Consumption: "
bytes:			.asciz	" bytes\n"
numNodesP:		.asciz	"Number of Nodes: "
enterPrompt: 		.asciz 	"Enter selection: "
enterStringP:		.asciz	"Enter string: "
endProgram:		.asciz 	"Program ended. Thank you for using our program!"
emptyList:		.asciz 	"List is empty!\n"
endl:			.asciz	"\n"
inputBuffer:		.word 	SIZE

	.text
	.extern malloc
	.extern free

start:

	mov r0,#1
	ldr r1, =rasmTitle		@Output title 
	bl putstring
	ldr r1, =memoryComp
	bl putstring

	ldr r1, =byteCount		@Output byte count on the screen
	bl intasc32
	bl putstring
	
	ldr r1, =bytes			@Output "bytes"
	bl putstring

	ldr r1, =numNodesP	@Output "Number of Nodes: "
	bl pustring

	ldr r1, =nodeCount		@Output number of nodes to the screen
	bl intasc32
	bl putstring

	ldr r1, =endl
	bl intasc32
	bl putstring
	
	bl menu				@Output the menu to view selection
	
	ldr r1, =enterPrompt
	bl putstring

	cmp r0, #'1'			@If the user input is 1, then branch to print_list
	beq print_list			@Output link list
	
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

addStringOption:
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r0, =inputBuffer
	bl StringCopy
	mov r4, r0
	bl build_node			@build new node with string
	ldr r1, =head_ptr		@load head ptr into r1
	ldr r2, [r1]				@dereference head ptr
	cmp r2, #0			@if head is null
	streq r4, [r1]			@set head as newNode
	ldr r1, =tail_ptr			@load tail ptr into r1
	bl link_tail			@adding the new node and putting it at the tail of link list
	bl stringLength		@get the length of string
	add r0, #8			@add 8 bytes to byte counter for each node
	ldr r1, =byteCount		@byteCount
	ldr r2, [r1]				@load byteCount value into r2
	add r2, r0				@sum total byteCount
	str r2, [r1]				@store new byteCount, which will increment bytes displayed on the screen
	b start				@branch back to start function

fileStringsOption:
	ldr r1, =head_ptr
	ldr r2, =tail_ptr			@Parameters r1 and r2 are passed into readFileFunc
	bl readFileFunc		@***Have to construct this function to add to list.s, function will return byteCount into r0
	ldr r1, =byteCount		@Load byteCount variable
	ldr r3, [r1]				@load byteCount value
	add r3, r0				@sum the total byte count
	str r3, [r1]				@store the new byte count, which will increment bytes displayed on screen
	b start				@branch back to start function

endProgramOption:
	ldr r1, =endProgram
	bl putstring
	mov r7, #1
	svc 0
	.end
