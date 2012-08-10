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

BPP  = 24

MBOX_CHAN_FB = 1

/*
	Initialises the framebuffer
	
	int32_t framebuffer_address fb_init(int32_t width, int32_t height)
*/
FUNC fb_init
	push {r4-r7, lr}
	
	/* Save parameters */
	mov r6, r0
	mov r7, r1
	
	/* Allocate 10 words + 16 bytes of memory - we need to get 10 words, but 16 byte aligned */
	ldr r0, =(10 * 0x20)
	
	bl mm_alloc
	mov r4, r0
	mov r5, r0
	
	/* Round up to a 16 byte alignment */
	sub r4, #1
	and r4, #0xFFFFFFF0
	add r4, #16
	
	/* Populate struct based at r4
	
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
			uint32_t size; 			//GPU fills this in
		};
	*/
	/* Set resolution */
	/* x */
	mov r1, r6
	str r1, [r4]
	str r1, [r4, #8]
	/* y */
	mov r1, r7
	str r1, [r4, #4]
	str r1, [r4, #12]
	/* Set depth */
	ldr r1, =BPP
	str r1, [r4, #20]
	/* 0 offsets, pitch and pointer */
	ldr r1, =0
	str r1, [r4, #16]
	str r1, [r4, #24]
	str r1, [r4, #28]
	str r1, [r4, #32]
	str r1, [r4, #36]
	
	/* Write to mailbox */
	ldr r0, =MBOX_CHAN_FB
	mov r1, r4
	bl mail_write
	
	ldr r0, =MBOX_CHAN_FB
	bl mail_read
	
	/* Free the memory */
	mov r0, r5
	bl mm_free
	
	/* Return the pointer */
	ldr r1, [r4, #32]
	mov r0, r1
	
	pop {r4-r7, lr}
	bx lr
