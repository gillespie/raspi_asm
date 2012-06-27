/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

/*
	Perform read and writes on mailboxes (as owner 0 - CPU)
	By default the CPU will write to mailbox 1, and read from mailbox 0
*/

.include "macros.inc"

/* Register addresses */
MAIL0_WRT = 0x2000B880
MAIL0_RD  = 0x2000B880
MAIL0_POL = 0x2000B890
MAIL0_SND = 0x2000B894
MAIL0_STA = 0x2000B898
MAIL0_CNF = 0x2000B89C

MAIL1_WRT = 0x2000B8A0
MAIL1_STA = 0x2000B8B8

/* Status codes */
MAIL_FULL   = 0x80000000
MAIL_EMPTY  = 0x40000000
MAIL_LEVEL  = 0x400000FF

/* Config options/Error codes */
MBOX_IHAVEDATAIRQEN    = 0x00000001 /* mailbox irq enable:  has data */
MBOX_IHAVESPACEIRQEN   = 0x00000002 /* mailbox irq enable:  has space */
MBOX_OPPISEMPTYIRQEN   = 0x00000004 /* mailbox irq enable: Opp. is empty */
MBOX_MAIL_CLEAR        = 0x00000008 /* mailbox clear write 1, then  0 */
MBOX_IHAVEDATAIRQPEND  = 0x00000010 /* mailbox irq pending:  has space */
MBOX_IHAVESPACEIRQPEND = 0x00000020 /* mailbox irq pending: Opp. is empty */
MBOX_OPPISEMPTYIRQPEND = 0x00000040 /* mailbox irq pending */
/* Bit 7 is unused */
MBOX_ERRNOOWN          = 0x00000100 /* error : none owner read from mailbox */
MBOX_ERROVERFLW        = 0x00000200 /* error : write to fill mailbox */
MBOX_ERRUNDRFLW        = 0x00000400 /* error : read from empty mailbox */

/*
	Read data from mailbox 0, channel r0 
	
	int32_t mailbox_read(int32_t channel);
*/
FUNC mailbox_read
	push {lr}
	/* Wait until the mailbox is not empty */
	0:
		ldr r2, =MAIL0_STA
		1:
			ldr r1, [r2]
			and r1, #MAIL_EMPTY
			cmp r1, #MAIL_EMPTY
		beq 1b
	
		/* Read the mail */
		ldr r2, =MAIL0_RD
		ldr r1, [r2]
		/* Check if it's the right channel */
		and r3, r1, #0xF
		cmp r3, r0
	bne 0b
	/* Get the message part, and return */
	and r0, r1, #0xFFFFFFF0
	pop {lr}
	bx lr

/*
	Write data r1 to mailbox 1, channel r0
	r1 must contain it's data in the upper 28 bits

	void mailbox_write(int32_t channel, int32_t data28);
*/
FUNC mailbox_write
	/* Prepare message in r1 */
	and r0, #0xF
	and r1, #0xFFFFFFF0
	orr r1, r0
	
	/* Wait until the mailbox is not full */		
	ldr r0, =MAIL0_STA
	0:
		ldr r3, [r0]
		ands r3, #MAIL_FULL
		bne 0b
	
	/* Send the mail */
	ldr r2, =MAIL1_WRT
	str r1, [r2]
	
	bx lr


	

