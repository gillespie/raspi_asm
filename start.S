/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

.include "macros.inc"

.section .text
/******** Start ********/
_start:
	b entry

/******** Entry ********/
.balign 0x8000
FUNC entry
	/* Set up */
	mov sp, #0x8000 /* Setup stack */
	
	/* Set pin 16 to output */
	ldr r0, =16
	ldr r1, =1
	bl set_gpio_mode
	
	bl init_mm
	
	ldr r0, =1232
	bl malloc
	mov r4, r0
	
	ldr r0, =267
	bl malloc
	mov r5, r0
	
	bl led_off
	bl wait
	
	mov r0, r4
	bl free
	
	0:
		bl led_on
		bl wait
		bl led_off
		bl wait
		b 0b

FUNC wait
	mov r0, #0x0300000
	0:
		subs r0, #1
		bne 0b
	bx lr

/* 'prints' r0 */
FUNC debug
	push {lr}
	ldr r1, =0xF
	ldr r3, =28
	0:
		push {r0-r3}
		bl led_on
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl led_off
		bl wait
		bl wait
		bl wait
		bl wait
		pop {r0-r3}
		and r2, r1, r0, lsr r3
		cmp r2, #0
		beq 2f
		1:
			push {r0-r3}
			bl led_on
			bl wait
			bl led_off
			bl wait
			pop {r0-r3}
			subs r2, #1
			bne 1b
		2:
		push {r0-r3}
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		pop {r0-r3}
		subs r3, #4
		bge 0b
	pop {lr}
	bx lr
