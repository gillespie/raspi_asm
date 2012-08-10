/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

.include "macros.inc"

XRES = 1920
YRES = 1080

/******** Entry ********/
FUNC entry
	/* Show that we're alive */
	bl led_init
	
	bl mm_init
	/*bl interrupts_enable*/
	
	ldr r0, =XRES
	ldr r1, =YRES
	bl fb_init
	
	ldr r1, =XRES
	ldr r2, =YRES
	bl graphics_init
	
	ldr r1, =0xFFFFFFFF
	ldr r2, =200000
	g:
		str r1, [r0], #4
		subs r2, #1
		bne g
	
	bl graphics_test
	
	hang:
		b hang
	
	ldr r0, =0xFF
	ldr r1, =0xFF
	ldr r2, =0x00
	bl graphics_set_colour
	
	ldr r4, =100
	loop:
		ldr r0, =100
		mov r1, r4
		bl graphics_draw_pixel
		subs r4, #1
		bne loop
	
	bl led_on
	
	hang2:
		b hang2

FUNC wait
	mov r2, #0x0100000
	0:
		subs r2, #1
		bne 0b
	bx lr
