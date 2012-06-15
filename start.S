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
	
	/*bl FbTest*/
	
	entry.loop:
		bl led_on
		bl wait
		bl led_off
		bl wait
		b entry.loop

FUNC wait
	mov r0, #0x1000000
	wait.loop:
		subs r0, #1
		bne wait.loop
	bx lr
