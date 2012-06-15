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
	
	ldr r0, =0x10000
	ldr r1, =0x20200028
	str r0, [r1]
	
	0:
		bl led_on
		bl wait
		bl led_off
		bl wait
		b 0b

FUNC wait
	mov r0, #0x1000000
	0:
		subs r0, #1
		bne 0b
	bx lr
