/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

.include "macros.inc"

/******** Entry ********/
FUNC entry
	/* Show that we're alive */
	bl led_init
	
	bl mm_init
	/*bl interrupts_enable*/
	0:
		bl fb_init
		cmp r0, #0
		bne 1f
		bl led_flash
		bl wait
		b 0b
	1:
	ldr r1, =0xFF
	ldr r2, =0xFF
	ldr r3, =0x00
	ldr r4, =900000
	l2:
		strb r1, [r0], #1
		strb r2, [r0], #1
		strb r3, [r0], #1
		sub r4, #1
		cmp r4, #0
		bne l2
	
	bl led_on
	
	loop:
		b loop

FUNC wait
	mov r2, #0x0100000
	0:
		subs r2, #1
		bne 0b
	bx lr
