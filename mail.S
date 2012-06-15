/* Perform read and writes on mailboxes (as owner 0) */

/* Register addresses */
MAIL0_WRT = 0x200B880
MAIL0_RD  = 0x200B880
MAIL0_POL = 0x200B890
MAIL0_SND = 0x200B894
MAIL0_STA = 0x200B898
MAIL0_CNF = 0x200B89C

MAIL1_WRT = 0x200B8A0
MAIL1_STA = 0x200B8B8

/* Status codes */
MAIL_FULL   = 0x80000000
MAIL_EMPTY  = 0x40000000
MAIL_LEVEL  = 0x400000FF

/*
	Read data from mailbox 0, channel r0 
	
	int32_t mailbox_read(int32_t channel);
*/
FUNC mailbox_read
	/* Wait until the mailbox is not empty */
	0:
		ldr r2, =MAIL0_STA
		1:
			ldr r1, [r2]
			ands r1, #MAIL_EMPTY
		bne 1
		/* Read the mail */
		ldr r2, =MAIL0_RD
		ldr r1, [r2]
		/* Check if it's the right channel */
		and r3, r1, #0xF
		cmp r2, r0
	bne 0
	/* Get the message part, and return */
	and r0, r1, #0xFFFFFFF0
	bx lr

/*
	Write data r1 to mailbox 0, channel r0
	r2 must be 0 or 1, r1 must contain it's data in the upper 28 bits

	void mailbox0_write(int32_t channel, int32_t data28);
*/
FUNC mailbox0_write
	/* Prepare message in r1 */
	and r1, #0xFFFFFFF0
	or r1, r0
	
	/* Wait until the mailbox is not full */
	ldr r2, =MAIL0_STA
	0:
		ld r0, [r2]
		ands r0, #MAIL_FULL
	bne 0
	
	/* Send the mail */
	ldr r2, =MAIL0_SND
	str r1, [r2]
	bx lr
	
	

