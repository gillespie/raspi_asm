/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

/* Framebuffer setup */

.include "macros.inc"

/* Use constant x,y for now */
XRES = 800
YRES = 600
BPP  = 24

MBOX_CHAN_FB = 1

FUNC fb_init
	push {r4, lr}
	/* Allocate 10 words of memory */
	ldr r0, =(10 * 0x20)
	
	bl malloc
	mov r0, r4
	
	/* Populate struct based at r0
	
		struct Bcm2835FrameBuffer
		{
			uint32_t xres;	 		//Width of the frame buffer (pixels)
			uint32_t yres;	 		//Height of the frame buffer
			uint32_t xres_virtual;	//Simplest thing to do is to set vwidth = width
			uint32_t yres_virtual;	//Simplest thing to do is to set vheight = height
			uint32_t pitch; 		//GPU fills this in; set to zero
			uint32_t depth; 		//Bits per pixel; set to 24
			uint32_t x; 			//Offset in x direction. Simplest thing to do is set to zero
			uint32_t y; 			//Offset in y direction. Simplest thing to do is set to zero
			uint32_t pointer; 		//GPU fills this in to be a pointer to the frame buffer
									//I find this is usually (always?) 0x4F...TODO: Finish
			uint32_t size; 			//GPU fills this in
		};
	*/
	/* Set resolution */
	mov r1, #XRES
	str r1, [r4]
	str r1, [r4, #8]
	mov r1, #YRES
	str r1, [r4, #4]
	str r1, [r4, #12]
	/* Set depth */
	mov r1, #BPP
	str r1, [r4, #20]
	/* 0 offsets */
	mov r1, #0
	str r1, [r4, #24]
	str r1, [r4, #28]
	
	/* Write to mailbox */
	mov r1, r0, lsl #4
	ldr r0, =MBOX_CHAN_FB
	bl mailbox_write
	
	bl led_on
	
	bl mailbox_read
	
	
	pop {r4, lr}
	bx lr
