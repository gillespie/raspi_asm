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
	Just turns on pin 16 (OK LED) for now
	
	void init_gpio();
*/
FUNC init_gpio
	ldr r0, =GPFSEL1
	mov r1, #0x40000 /* (1<<18) */
	str r1, [r0]
	
	bx lr

/*
	Set gpio pin r0
	
	void gpio_set(int32_t pin);
*/
FUNC gpio_set
	/* Target register is GPSET0 or GPSET1 */
	ldr r1, =GPSET0
	cmp r0, #32
	blt gpio_set.L0_31
		sub r0, #32
		add r1, #4 /* GPSET1 - GPSET0 = 4 */
	gpio_set.L0_31:
	
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
	blt gpio_clear.L0_31
		sub r0, #32
		add r1, #4 /* GPCLR1 - GPCLR0 = 4 */
		bx lr
	gpio_clear.L0_31:
	
	/* Set bit r0 to 1 */
	mov r2, #1
	lsl r2, r0
	str r2, [r1]
	
	bx lr
	

/*
	Switches on the OK LED
	
	void led_on();
*/
FUNC led_on
	push {lr}
	
	/* Call gpio_clear(16) */
	ldr r0, =16
	bl gpio_clear
	
	pop {lr}
	bx lr

/*
	Switches off the OK LED
	
	void led_off();
*/
FUNC led_off
	push {lr}
	
	/* Call gpio_set(16) */
	ldr r0, =16
	bl gpio_set
	
	pop {lr}
	bx lr
	