/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

/* Minimal graphics library (assume 24 bit colour depth) */

.include "macros.inc"

.data
/* Framebuffer state */
framebuffer_pointer:	.word
width:              	.word
height:              	.word

/* Colour state */
red:					.byte
green:					.byte
blue:					.byte

/*
	Setup the graphics library.
	
	void graphics_init(int32_t framebuffer_pointer, int32_t width, int32_t height);
*/
FUNC graphics_init
	ldr r3, =framebuffer_pointer
	str r0, [r3]
	ldr r3, =width
	str r1, [r3]
	ldr r3, =height
	str r2, [r3]
	bx lr

/*
	Set the colour state
	
	void graphics_set_colour(int32_t red, int32_t green, int32_t blue);
*/
FUNC graphics_set_colour
	ldr r3, =red
	strb r0, [r3]
	ldr r3, =green
	strb r1, [r3]
	ldr r3, =blue
	strb r2, [r3]
	bx lr

/*
	Gets the address of the given coordinates
	
	void graphics_get_address(int32_t x, int32_t y);
*/
FUNC graphics_get_address
	/* Address is framebuffer_pointer + 3*x + y*width */
	
	/* 3*x */
	add r0, r0
	add r0, r0
	
	/* y*width */
	ldr r2, =width
	ldr r2, [r2]
	mul r1, r2
	
	ldr r2, =framebuffer_pointer
	ldr r2, [r2]
	
	/* Add everything up */
	add r0, r1
	add r0, r2
	
	bx lr
	
/*
	Draws a pixel at given position
	
	void graphics_draw_pixel(int32_t x, int32_t y);
*/
FUNC graphics_draw_pixel
	push {lr}
	
	bl graphics_get_address
	
	ldr r1, =red
	ldrb r1, [r1]
	strb r1, [r0], #1
	ldr r1, =green
	ldrb r1, [r1]
	strb r1, [r0], #1
	ldr r1, =blue
	ldrb r1, [r1]
	strb r1, [r0], #1
	
	pop {lr}
	bx lr

FUNC graphics_test
	ldr r0, =0
	ldr r1, =100
	bl graphics_get_address
	ldr r1, =200000
	ldr r2, =0xFF
	ldr r3, =0x00
	loop:
		strb r2, [r0], #1
		strb r3, [r0], #1
		strb r2, [r0], #1
		subs r1, #1
		bne loop
	bx lr
