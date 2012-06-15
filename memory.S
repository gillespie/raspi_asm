/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

/* Memory management */

.include "macros.inc"

MEMORY_START = 0x0020000
TOTAL_MEMORY = 0xC000000
HEADER_SIZE  = 0x0000009

/*
	Writes a header 
	
	void write_header(int32_t location, int32_t size, int32_t next_free);
*/
FUNC write_header
	str r1, [r0]
	str r2, [r0, #4]
	bx lr

/*
	Initialise memory manager
	
	void init_mm();
*/
FUNC init_mm
	push {lr}

	/* First block of memory is a dummy block */
	ldr r0, =MEMORY_START
	ldr r1, =0
	ldr r2, =(HEADER_SIZE + MEMORY_START)
	bl write_header
	
	/* Second block is a huge free block */
	ldr r0, =(HEADER_SIZE + MEMORY_START)
	ldr r1, =(TOTAL_MEMORY-MEMORY_START-HEADER_SIZE*2)
	ldr r2, =MEMORY_START
	bl write_header
	
	pop {lr}
	bx lr

/*
	Allocate memory
	
	int32_t malloc(int32_t size);
*/
FUNC malloc
	push {lr}
	
	/* Start at memory start */
	ldr r2, =MEMORY_START
	0:
		/* Save the adress of the previous header.next_free */
		mov r3, r2
		/* Move to the next header */
		ldr r2, [r2, #4]
		/* Check if we're out of memory */
		cmp r2, #MEMORY_START
		beq out_of_memory
		/* Load header.size field */
		ldr r1, [r2]
		/* If it's too small, repeat */
		cmp r1, r0
		blt 0b
	
	/* Found a block at r2 */
	/* Mark memory from r2 + HEADER_SIZE + size (== r2 + r0 + HEADER_SIZE) 
	   to               r2 + HEADER_SIZE + header.free (== r2 + r1)
	   as a new free block
	   (only if this region is at least one byte bigger than HEADER_SIZE,
	   i.e. if header.free - size  > HEADER_SIZE */
	sub r1, r0
	cmp r1, #HEADER_SIZE
	blt 1f
		/* We have space, so write a new free block */
		/* Write header of new block */
		push {r0, r2}
		/* Address = r2 + HEADER_SIZE + size = r0 + r2 + HEADER_SIZE */
		add r0, r2
		add r0, #HEADER_SIZE
		/* New block size is r1 already */
		/* Set next free block to be the next free block of the one we just assigned*/
		ldr r2, [r2, #4]
		bl write_header
		/* Save the address of the new block */
		mov r1, r0
		pop {r0, r2}
		
		b 2f
	1:
		/* If the free space after the block we allocated is too small, just allocate it all */
		ldr r1, [r2, #4]
		mov r0, [r2]
	2:
	
	/* Point the previous block to the new next free block */
	str r1, [r3, #4]
	
	/* Write new header at r2 */
	push {r2}
	/* Set size as r0 (which is either requested size or header.size) */
	mov r1, r0
	/* Set location to r2, the free block that we found */
	mov r0, r2
	/* Set next free block to 0 */
	ldr r2, =0
	bl write_header
	pop {r2}
	
	/* Set return value */
	add r0, r2, #HEADER_SIZE
	
	pop {lr}
	bx lr
	
	out_of_memory:
		/* Fuck */
		pop {lr}
		bx lr

/*
	Free memory
	
	void free(int32_t address);
*/
FUNC free
	push {lr}
	
	/* Write new header */
	push {r0}
	/* Move back to the start of the header */
	sub r0, #HEADER_SIZE
	/* Load the size */
	ldr r1, [r0]
	/* Set the next free block to be the one pointed to by the dummy header */
	ldr r2, #MEMORY_START
	ldr r2, [r2, #4]
	bl write_header
	pop {r0}
	
	/* Re-write dummy header to point to newly freed block */
	ldr r2, r0
	ldr r1, =0
	ldr r0, =MEMORY_START
	bl write_header
	
	pop {lr}
	bx lr
