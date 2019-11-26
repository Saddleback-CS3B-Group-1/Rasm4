@Driver for RASM4 
	.data
byteCount: 		.word 0
byte_string:		.skip 12
nodeCount: 		.word 0
node_string:		.skip 12
head_ptr:		.word 0
char_nL:		.byte 10
tail_ptr:		.word 0
index:		.word 0
ptrsubStr:	.word 0
ptrStr:		.word 0
outFile: 		.asciz 	"output.txt"
rasmTitle:		.asciz	"\nRASM4 TEXT EDITOR\n"
memoryComp:	.asciz	"Data Structure Memory Consumption: "
bytes:			.asciz	" bytes\n"
numNodesP:		.asciz	"Number of Nodes: "
enterStringP:		.asciz	"Enter string: "
enterIndexPrompt:	.asciz	"Enter line number: "
enterStringSearchP: .asciz 	"Enter string to search for: "
InvalidInP:			.asciz	"Invalid index, not in range\n"
InvalidInP2:		.asciz	"Invalid input\n"
endProgram:		.asciz 	"Program ended. Thank you for using our program!\n"
emptyList:		.asciz 	"List is empty!\n"
endl:			.asciz	"\n"
idle_prompt:    .asciz  "\n...enter to continue..."
fileWritePrompt:.asciz  "FILE READ from \"input.txt\""
fileSavePrompt:.asciz  "FILE SAVED to \"output.txt\""
fileOut:        .asciz  "output.txt"
inputBuffer:		.skip 	SIZE

	.text
	.global _start
	.equ	SIZE, 1024 
	.extern malloc
	.extern free

_start:

    mov r0, #100
	ldr r1, =endl

cls_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls_loop

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

editStringOption:

	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r1, #0
	beq listEmpty
	
	ldr r1, =enterIndexPrompt
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	ldr r1, =inputBuffer
	bl ascint32
	sub r0, #1
	@bcs invalidInput
	@bvs invalidRange
	ldr r1, =index
	
	str r0, [r1]
	cmp r0, #0
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
	mov r1, r0
	ldr r2, =char_nL
	bl String_concat		@branch link to string concat
	mov r5, r0
	mov r0, r1
	push {r0-r12}
	bl free
	pop {r0-r12}
	mov r0, r5
	mov r2, r0 			@String address is in r1
	mov r1, r0
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
	
	b _start
	
invalidRange:
	ldr r1, =InvalidInP @output invalid range
	bl putstring
	b editStringOption

invalidInput:
	ldr r1, =InvalidInP2
	bl putstring
	b editStringOption

searchStringOption:
	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r0, #0
	beq listEmpty
	
	mov r0, #1
	ldr r1, =enterStringP
	bl putstring
	ldr r1, =inputBuffer
	mov r2, #SIZE
	bl getstring
	
	ldr r1, =inputBuffer
	bl String_copy
	mov r2, r0 	
	
	ldr r4, =head_ptr
	ldr r4, [r4]
	
searchLoop:

	cmp r4, #0
	beq searchEnd
	ldr r1, [r4], #4
	bl String_indexOf_3
	cmp r0, #-1
	blne putstring
	ldr r4, [r4]  @next node
	b searchLoop
	
searchEnd:
	mov r0, r2
	push {r0-r12}
	bl free
	pop {r0-r12}


removeStringOption:

	ldr r1, =head_ptr
	ldr r1, [r1]
	cmp r0, #0
	beq listEmpty
	
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
	blt invalidRangeDel
	
	ldr r1, =head_ptr
	mov r2, r0

	bl remove_node

	ldr r1, =nodeCount
	ldr r8, [r1]
	sub r8, #1
	str r8, [r1]

	ldr r1, =index
	str r0, [r1]

	bl data_at
	cmp r0, #0			@if null was returned, then output that desired index is invalid
	beq invalidRangeDel

	mov r4, r0 			@mov desired node address to r4
	ldr r0, [r4] 			@load string from desired node
	bl String_length
	mov r5, r0 			@move the string length of the string into r5

	add r5, #9
	
	ldr r1, =byteCount		@Load byteCount variable
	ldr r6, [r1]				@load byteCount value
	sub r6, r5				@get the total byte count from the difference
	str r6, [r1]				@store the new byte count, which will decrement bytes displayed on screen

	b _start
	
	
invalidRangeDel:
	ldr r1, =InvalidInP 		@output invalid range
	bl putstring
	b removeStringOption
	

	
printListOption:
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
	b _start
	
listEmpty:

	mov r0, #100
	ldr r1, =endl
cls4_loop:
	bl putstring
	sub r0, #1
	cmp r0, #0
	bgt cls4_loop
	ldr r1, =emptyList
	bl putstring
	ldr r1, =idle_prompt
	bl putstring
	ldr r1, =inputBuffer
	bl getstring
	b _start

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
	b _start
addTail:
	mov r1, r4
	mov r2, #0
	bl link_node
	ldr r1, =head_ptr
	mov r2, r4
	bl link_tail
	b _start				@branch back to start function

@fileStringsOption:
@	ldr r1, =head_ptr
@	bl load_file
@	mov r5, r0
@	mov r6, r2
@	ldr r4, =head_ptr
@	str r1, [r4]
@	ldr r1, =byteCount		@Load byteCount variable
@	ldr r0, [r1]
@	add r0, r5			@sum the total byte count
@	str r0, [r1]			@store the new byte count, which will increment bytes displayed on screen
@	ldr r1, =nodeCount
@	ldr r0, [r1]
@	add r0, r6
@	str r0, [r1]
    
@	mov r0, #100
@	ldr r1, =endl

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
	b _start				@branch back to start function



saveFileOption:
	ldr r0, =fileOut
	mov r1, #0101
	ldr r2, =0666
	mov r7, #5
	svc 0
	mov r2, r0
	ldr r1, =head_ptr
	bl write_list
	
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
	b _start

endProgramOption:
	ldr r1, =endProgram
	bl putstring
	ldr r1, =head_ptr
	bl clear_list
	mov r7, #1
	svc 0
	.end