/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <tomjamesgillespie@gmail.com> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return - Thomas Gillespie
 * ----------------------------------------------------------------------------
 */

.include "macros.inc"

/* 
	Initialises the led - sets gpio pin 16 to output
	
	void led_init();
*/
FUNC led_init
	/* Set pin 16 to output */
	ldr r0, =16
	ldr r1, =1
	bl set_gpio_mode


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

/* 
	'prints' r0 by flashing the led

	void led_print(uint32_t value);
*/
FUNC led_print
	push {lr}
	ldr r1, =0xF
	ldr r3, =28
	0:
		push {r0-r3}
		bl led_on
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl led_off
		bl wait
		bl wait
		bl wait
		bl wait
		pop {r0-r3}
		and r2, r1, r0, lsr r3
		cmp r2, #0
		beq 2f
		1:
			push {r0-r3}
			bl led_on
			bl wait
			bl led_off
			bl wait
			pop {r0-r3}
			subs r2, #1
			bne 1b
		2:
		push {r0-r3}
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		bl wait
		pop {r0-r3}
		subs r3, #4
		bge 0b
	pop {lr}
	bx lr
