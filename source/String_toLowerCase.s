.global String_toLowerCase
	.extern malloc

String_toLowerCase:
			  push {r4-r11,lr}
			  mov r4, r1
			  bl String_length
			  mov r6, r0
			  add r0, #1
			  bl malloc
			  mov r1, r4
			  mov r5, r0
lower_loop:
			  cmp r6, #0
			  beq lower_loop_done
			  mov r9, #0
              		  ldrb r7, [r4], #1
			  cmp r7, #65
			  addge r9, #1
			  cmp r7, #90
			  addle r9, #1
			  cmp r9, #2
			  addeq r7, #32
			  strb r7, [r5], #1
			  sub r6, #1
			  b lower_loop

lower_loop_done:
			  mov r8, #0
			  strb r8, [r5]
			  pop {r4-r11,lr}
			  bx lr
			  .end