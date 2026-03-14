.syntax unified
.thumb

#include "initialise.s"

.global main
.thumb_func

.type main, %function

.text

main:
	@initialising
	BL initialise_discovery_board @initialising the board
	BL enable_peripheral_clocks @start peripheral clocks such that LEDs can work
	BL enable_timer2_clock @start timer2 such that delay functions can be used

@	BL delay

	@initialising LEDs
	@LDR R7, =0b10110111 @loading register with which LEDs are turning on
	LDR R7, =0b10110111 @loading register with which LEDs are turning on
	LDR R0, =GPIOE @loading register with address of GPIOE
	STRB R7, [R0, #ODR + 1] @loading the LED 'on' into GPIOE_ODR

	/* LDR R1, =TIM2 @initialising timer 2
	MOV R2, #0 @setting value to zero to reset the timer
	STR R2, [R1, #TIM_CNT] @resetting the timer */

/* stop:
    B stop */


delay:
	@initialising timer
	LDR R1, =TIM2 @initialising timer 2
	@MOV R4, #1 @putting 1 in register R2, now R4
	@STR R2, [R4, TIM_CR1] @storing counting timer

	MOV R2, #1 @putting 1 in register R2, now R4
	STR R2, [R1, #TIM_CR1] @storing counting timer

	LDR R3, =5000000 @picking max time to go
	LDR R5, [R1, #TIM_CNT] @loading the value of TIM_CMT into R5
	CMP R5, R3 @compare the two values
	BLT delay

led:
	LDR R7, =0b00000000 @loading register with which LEDs are turning off
	LDR R0, =GPIOE
	@MOV R7, #0
	STRB R7, [R0, #ODR + 1]

	@initialising LEDs
	@LDR R7, =0b10110111 @loading register with which LEDs are turning on
	@LDR R0, =GPIOE @loading register with address of GPIOE
	@STRB R7, [R0, #ODR + 1] @loading the LED 'on' into GPIOE_ODR
