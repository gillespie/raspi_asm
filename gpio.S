/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

.include "macros.inc"

/* GPIO function select registers - 3 bits/pin
000 = Input
001 = Output
Otherwise, alternate function (?) */
GPFSEL0 = 0x20200000 /* Pins 00-09 */
GPFSEL1 = 0x20200004 /* Pins 10-19 */
GPFSEL2 = 0x20200008 /* Pins 20-29 */
GPFSEL3 = 0x2020000C /* Pins 30-39 */
GPFSEL4 = 0x20200010 /* Pins 40-49 */
GPFSEL5 = 0x20200014 /* Pins 50-53 */

/* GPIO set registers - 1 bit/pin */
GPSET0  = 0x2020001C /* Pins 00-31 */
GPSET1  = 0x20200020 /* Pins 32-53 */

/* GPIO clear registers - 1 bit/pin */
GPCLR0  = 0x20200028 /* Pins 00-31 */
GPCLR1  = 0x2020002C /* Pins 32-53 */

/* GPIO pin level registers - 1 bit/pin */
GPLEV0  = 0x20200034 /* Pins 00-31 */
GPLEV1  = 0x20200038 /* Pins 32-53 */

/* TODO - Event detection, clocks */

/*
	Sets pin r0 to mode r1
	
	void set_gpio_mode(int32_t pin, int32_t mode);
*/
FUNC set_gpio_mode
	push {r4}
	
	/* Pick the right select register */
	ldr r2, =GPFSEL0
	0:
		add r2, #4 /* GPFSEL(i+1) - GPFSEL(i) = 4 */
		subs r0, #10
		bpl 0b
	add r0, #10
	sub r2, #4
		
	/* Write the message */
	/* Setup the bit offset */
	ldr r3, =3
	mul r0, r3
	/* Old register value */
	ldr r3, [r2]
	/* Clear the target pin */
	ldr r4, =0xFFFFFFF8
	and r3, r4, ror r0
	/* Add in the target mode */
	orr r3, r1, ror r0
	/* Write back */
	str r3, [r2]
	
	pop {r4}
	bx lr

/*
	Set gpio pin r0
	
	void gpio_set(int32_t pin);
*/
FUNC gpio_set
	/* Target register is GPSET0 or GPSET1 */
	ldr r1, =GPSET0
	cmp r0, #32
	blt 0f
		sub r0, #32
		add r1, #4 /* GPSET1 - GPSET0 = 4 */
	0:
	
	/* Set bit r0 to 1 */
	mov r2, #1
	lsl r2, r0
	str r2, [r1]

	bx lr
	
/*
	Clear gpio pin r0
	
	void gpio_clear(int32_t pin);
*/
FUNC gpio_clear
	/* Target register is GPCL0 or GPCLR1 */
	ldr r1, =GPCLR0
	cmp r0, #32
	blt 0f
		sub r0, #32
		add r1, #4 /* GPCLR1 - GPCLR0 = 4 */
		bx lr
	0:
	
	/* Set bit r0 to 1 */
	mov r2, #1
	lsl r2, r0
	str r2, [r1]
	
	bx lr
