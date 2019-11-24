@ Menu options function is used also to validate input 
@ Layered with subselection for adding strings
	
	.global menu
	.global load_file
	.equ	SIZE, 1024 
	.data

option1:	.asciz	"<1> View all strings\n"

option2:	.asciz	"<2> Add string\n"
option2a:	.asciz	"<a> from Keyboard\n"
option2b:	.asciz 	"<b> from File. Static file named input.txt\n"

option3:		.asciz	"<3> Delete string. Given an index #, delete the entire string and de-allocate memory (including the node).\n"
option4:		.asciz 	"<4> Edit string. Given an index #, replace old string w/ new string. Allocate/De-allocate as needed.\n"
option5: 		.asciz 	"<5> String search. Regardless of case, return all strings that match the substring given.\n"
option6:		.asciz 	"<6> Save File (output.txt)\n"
option7:		.asciz  "<7> Quit\n"
enterPrompt: 		.asciz 	"Enter selection: "
invalidMsg:		.asciz  "ERROR: Invalid Input!\n"
input_buffer:	.skip 	1025

        filename: .asciz "input.txt"
	 file_handle: .word 0
        head_ptr: .word 0
   remainder_ptr: .word 0
   	  byte_count: .word 0
         char_nL: .byte 10
				.text

menu:
	push	{R4-R8, R10, R11, LR}		@ Push AAPCS Required registers
 
 	mov	R0,#1			
	
	ldr	R1,=option1			@ Displaying the menu options
	bl	putstring
	
	ldr	R1,=option2
	bl	putstring
	
	ldr	R1,=option3
	bl	putstring	
	
	ldr	R1,=option4
	bl	putstring	
	
	ldr	R1,=option5
	bl	putstring
	
	ldr	R1,=option6
	bl	putstring
	
	ldr	R1,=option7
	bl	putstring

	ldr r1, =enterPrompt
	bl putstring

	ldr	R1,=input_buffer			@ Load input buffer into R1
	mov	R2,#SIZE			@ Load input buffer size into R2
	bl	getstring			@ Getstring input
	cmp	R0,#2				@ Check if user input size is valid
	bgt	invalidInput			@ If user input is invalidInput, branch to invalidInput
	ldr	R1, =input_buffer		@ Load input buffer into R1
	ldrb R1,[R1]				@ Load first byte of user input
	cmp	R1,#'1'				@ If input is 0 or negative, branch to invalidInput input
	blt	invalidInput			
	cmp	R1,#'7'				@ If input is greater than 7, branch to invalidInput
	bgt	invalidInput		
	cmp	R1,#'2'				@ Check if user entered 2 for addingString
	bne	endMenu				@ If not equal to 2 branch to endMenu

	mov	R0,#1				@ If user inputs a 2, there is options for adding a string
	ldr	R1,=option2a			@ either add string  manually or read from file
	bl	putstring
	ldr	R1,=option2b
	bl	putstring

	@Check to make sure this subselection is given a valid input
	
	ldr	R1,=input_buffer			@ Load input buffer into R1
	mov	R2,#SIZE			@ Load input buffer size into R2
	bl	getstring			@ Getstring input
	cmp	R0,#2				@ Check if user input size is valid
	bgt	invalidInput			@ If user input is not valid branch to invalidInput
	ldr	R1,=input_buffer			@ Load input buffer into R1
	ldrb R1,[R1]				@ Load first byte of user input
	cmp	R1,#'a'				@ Check if user input 'a'
	beq	endMenu				@ If input is valid branch to endMenu
	cmp	R1,#'A'				@ Check if user input 'A'
	beq	endMenu				@ If input is valid branch to endMenu
	cmp	R1,#'b'				@ Check if user input 'b'
	beq	endMenu				@ If input is valid branch to endMenu
	cmp	R1,#'B'				@ Check if user input 'B'
	beq	endMenu				@ If input is valid branch to endMenu
	
invalidInput:	
	mov	R0,#1				@ Set output to stdout
	ldr	R1, =invalidMsg			@ Load invalid input message into R1
	bl	putstring			@ Output invalid input message
	b	menu				@ Branch to menu

endMenu:
	mov	R0,R1				@ Move user input into R0
	pop	{R4-R8, R10, R11, LR}		@ Restore AAPCS Required registers
	bx	LR				@ Return to calling program

@@--- READ FROM FILE ---@@

load_file:
		push {r4-r8,r10,r11,lr}
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
		mov r10, #0
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
		add r10, r0
		add r10, #9          @update our byte count (stringLength + 1)
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
		mov r0 ,r10
		ldr r1, =head_ptr
		ldr r1, [r1]
		pop {r4-r8,r10,r11,lr}
		bx lr
	.end
