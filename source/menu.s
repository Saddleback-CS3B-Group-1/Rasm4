@ Menu options function is used also to validate input 
@ Layered with subselection for adding strings
	
	.global menu
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
inputBuffer:	.skip 	SIZE

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

	ldr	R1,=inputBuffer			@ Load input buffer into R1
	mov	R2,#SIZE			@ Load input buffer size into R2
	bl	getstring			@ Getstring input
	cmp	R0,#2				@ Check if user input size is valid
	bgt	invalidInput			@ If user input is invalidInput, branch to invalidInput
	ldr	R1, =inputBuffer		@ Load input buffer into R1
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
	
	ldr	R1,=inputBuffer			@ Load input buffer into R1
	mov	R2,#SIZE			@ Load input buffer size into R2
	bl	getstring			@ Getstring input
	cmp	R0,#2				@ Check if user input size is valid
	bgt	invalidInput			@ If user input is not valid branch to invalidInput
	ldr	R1,=inputBuffer			@ Load input buffer into R1
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