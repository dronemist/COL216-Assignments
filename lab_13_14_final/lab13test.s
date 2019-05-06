	b Reset		@address 0x000
	b Undef		@address 0x004
    b SWI_single @address 0x008
    b SWI_multi @address 0x00c
    b SWI_read @address 0x010
gap1:	.space 0x008
	b IRQ			@address 0x018
gap2:	.space 0x024
Reset:			@ address 0x040
	mov r10, #252	@a constant for address generation
    mov sp, r10
    mov r5,#8
    mov r4,#14
    str r4,[r5]
	mov r0, #1
	sub sp, sp, #4
	str r0, [sp]	@push #1 in supervisor stack
	mov r0, #2
	sub sp, sp, #4
	str r0, [sp] 	@push #2 in supervisor stack
	mov r1, r10,LSL #5 	@generate address 0x200 in supervisor area
	mov r2, r10,LSL #7	@generate address 0x800 in data area
	mov r0, #3
	str r0, [r1] 	@store #3 in supervisor data area
	mov r0, #4
	str r0, [r2] 	@store #4 in user data area
	ldr r0, [r1] 	@read from supervisor data area
	ldr r0, [r2] 	@read from user data area
	mov r0, #0x10
	msr cpsr, r0		@ set user mode with all flags clear and IRQ enabled
	b User
Undef:	
    ldr r0, [sp]
	add sp, sp, #4 	@pop from supervisor stack
	movs pc, lr
SWI_read:
    mov r1, #12
    ldr r0, [r1]
    mov pc,lr
SWI_single:
    str r4, [sp] , #-4 @ storing r4 in the supervisor stack
    str r3, [sp] , #-4
    str r5, [sp] , #-4
    mov r3, #2 @ single digit display has value 2
    mov r5, #0 
    str r3, [r5] @ restoring values
    @ The digit to be displayed is stored in r0
    mov r5, #4
    str r0, [r5]
    @ The position where the digit is to be displayed is stored in r1
    cmp r1, #1
    moveq r4, #14
    cmp r1, #2
    moveq r4, #13
    cmp r1, #3
    moveq r4, #11
    cmp r1, #4
    moveq r4, #7
    mov r5, #8
    str r4,[r5] @ storing initial anode pattern
    ldr r5 , [sp, #4]!
    ldr r3, [sp, #4]!
    ldr r4, [sp, #4]!
    movs pc,lr
SWI_multi:
    @ The digit to be displayed is stored in r0
    str r5, [sp], #-4
    str r4, [sp], #-4
    str r3, [sp], #-4
    mov r3, #1 @ multi digit display has value 1
    mov r5, #0 
    str r3, [r5]
    mov r5, #4
    str r0, [r5]
    ldr r3 , [sp, #4]!
    ldr r4, [sp, #4]!
    ldr r5, [sp, #4]!
    movs pc,lr
IRQ:
    str r5, [sp], #-4
    str r4, [sp], #-4
    str r3, [sp], #-4
    mov r5, #0
    ldr r3, [r5]
    cmp r3,#1 @ multi
    beq MULTI 
    cmp r3,#2 @ single 
    beq SINGLE
    cmp r3,#3 @ read
    ldr r3 , [sp, #4]!
    ldr r4, [sp, #4]!
    ldr r5, [sp, #4]!
    movs pc,lr   
MULTI:
    mov r5,#8
    ldr r4, [r5]
    @ shifting #1 by one position
    cmp r4, #14
    moveq r4, #7
    beq c
    cmp r4, #13
    moveq r4, #14
    beq c
    cmp r4, #11
    moveq r4, #13
    beq c
    cmp r4, #7
    moveq r4, #11
c:  str r4, [r5]
    ldr r3 , [sp, #4]!
    ldr r4, [sp, #4]!
    ldr r5, [sp, #4]!
    movs pc,lr
SINGLE: 
    ldr r3 , [sp, #4]!
    ldr r4, [sp, #4]!
    ldr r5, [sp, #4]!
    movs pc,lr    
         
gap3:	.space 0x244
User:
swi 0x010
mov r1,#3
swi 0x00c
b User
