.syntax unified
.thumb

#include "initialise.s"

.global main
.thumb_func

.type main, %function

.text

main:
	@initialising
	BL enable_peripheral_clocks @start peripheral clocks such that LEDs can work
	BL initialise_discovery_board @initialising the board
	BL enable_timer2_clock @start timer2 such that delay functions can be used

	/*
	@initialising LEDs
	LDR R7, =0b10110111 @loading register with which LEDs are turning on
	LDR R0, =GPIOE @loading register with address of GPIOE
	STRB R7, [R0, #ODR + 1] @loading the LED 'on' into GPIOE_ODR

	@BL prescaler @starting the prescaler
	@BL timer @branching into delay function using timer

	@hardware delay function
	BL prescaler_prescaler @branching into prescaler delay
	BL delay_prescaler @branching into delay function


	@turning off LEDs
	LDR R7, =0b00000000 @loading register with which LEDs are turning off
	LDR R0, =GPIOE @loading register with address of GPIOE
	STRB R7, [R0, #ODR + 1] @loading the LED 'off' into GPIOE_ODR */


	LDR R0, =TIM2

	@ prescaler: adjust this if needed for your board clock
	@ if TIM2 clock = 8 MHz, PSC = 7 gives 1 tick = 1 us
	MOV R1, #7
	STR R1, [R0, #TIM_PSC]

	@ load prescaler
	BL trigger_prescaler

	@ reset counter
	MOV R1, #0
	STR R1, [R0, #TIM_CNT]

	@ start timer
	MOV R1, #1
	STR R1, [R0, #TIM_CR1]

	LDR R0, =GPIOE
	MOV R1, #0
	STRB R1, [R0, #ODR + 1]     @ all selected LEDs off initially

	LDR R4, =200000             @ LED1 period
	LDR R5, =700000             @ LED2 period

	@ next toggle times
	MOV R6, #0                  @ LED1 next toggle time
	MOV R7, #0                  @ LED2 next toggle time

main_loop:
	@ read current timer count
	LDR R0, =TIM2
	LDR R1, [R0, #TIM_CNT]      @ current time

	@comparing values to check whether the time has been reched
	CMP R1, R6
	BLT skip_led1

	LDR R0, =GPIOE
	LDRB R2, [R0, #ODR + 1]
	EOR R2, R2, #(1 << 0)       @ toggle LED1
	STRB R2, [R0, #ODR + 1]

	ADD R6, R6, R4              @ next LED1 toggle time

skip_led1:
	LDR R0, =TIM2
	LDR R1, [R0, #TIM_CNT]      @ read again just to be safe

	CMP R1, R7
	BLT skip_led2

	LDR R0, =GPIOE
	LDRB R2, [R0, #ODR + 1]
	EOR R2, R2, #(1 << 1)       @ toggle LED2
	STRB R2, [R0, #ODR + 1]

	ADD R7, R7, R5              @ next LED2 toggle time

skip_led2:
	B main_loop

stop:
	B stop @stopping the file

timer:
	@initialising timer
	LDR R1, =TIM2 @initialising timer 2

	@resetting the timer to zero
	MOV R4, #0 @putting 0 in register R2
    STR R4, [R1, #TIM_CNT]   @ reset counter

	@storing counting timer
	MOV R6, #1 @putting 1 in register R2
	STR R6, [R1, #TIM_CR1] @storing counting timer

	@creating loading function
	LDR R8, =50000000 @setting value for when overflow
	STR R8, [R1, TIM_ARR] @set the ARR register

@delay loop using time passed through register R1
delay:
	@picking delay length
	LDR R3, =50000000 @picking max time to go


delay_loop:
	LDR R5, [R1, #TIM_CNT] @loading the value of TIM_CMT into R5
	CMP R5, R3 @compare the two values

	BLT delay_loop @loop if less than

	BX LR @back to preceding function

trigger_prescaler:
	LDR R0, =TIM2 @load the base address for the timer

	LDR R1, =0x1 @setting value for when overflow
	STR R1, [R0, TIM_ARR] @set the ARR register

	MOV R2, #0 @loading value to R2
	STR R2, [R0, #TIM_CNT] @resetting value of timer to 0

	NOP @stalling for time
	NOP @stalling for time

	LDR R1, =0xffffffff @ set the ARR back to the default value
	STR R1, [R0, TIM_ARR] @ set the ARR register

	BX LR @back to prescaler

@using prescaler
delay_prescaler:

	@initialising timer
	LDR R0, =TIM2 @initialising timer 2

	MOV R2, #0 @putting 0 in register R2
    STR R2, [R0, #TIM_CNT]   @ reset counter

    @ clear update flag first check if the registers here are correct
	LDR R2, [R0, #TIM_SR]
	BIC R2, R2, #1
	STR R2, [R0, #TIM_SR]

	MOV R2, #1 @putting 1 in register R2
	STR R2, [R0, #TIM_CR1] @storing counting timer

	LDR R3, =1 @picking max time to go for 5 seconds
	@LDR R3, = 3600 @picking max time to go for an hour

delay_loop_prescaler:
	@BLT delay_loop
	LDR R2, [R0, #TIM_SR]       @ read status
    TST R2, #1                  @ test UIF bit
    BEQ delay_loop_prescaler            @ stay until UIF = 1

    LDR R2, [R0, #TIM_SR]       @ clear UIF after delay
    BIC R2, R2, #1
    STR R2, [R0, #TIM_SR]

    SUBS R3, R3, #1
	BNE delay_loop_prescaler

	BX LR

@creating prescaler
prescaler_prescaler:
	@storing a value for the prescaler
	LDR R0, =TIM2 @load the base address for the timer
	LDR R1, = 7999 @putting the prescaler value into R1 for 1 second
	@LDR R1, = 7 @putting prescaler value into R1 for 1 microsecond
	STR R1, [R0, TIM_PSC] @setting prescaler register

	@setting ARPE = 1
	LDR R1, [R0, #TIM_CR1]
	ORR R1, R1, #(1 << 7)
	STR R1, [R0, #TIM_CR1]

trigger_prescaler_prescaler:
	LDR R0, =TIM2 @load the base address for the timer

	LDR R1, =999 @setting value for when overflow
	STR R1, [R0, TIM_ARR] @set the ARR register

	MOV R1, #1
	STR R1, [R0, #TIM_EGR]   @ force update event

	MOV R2, #0 @loading value to R2
	STR R2, [R0, #TIM_CNT] @resetting value of timer to 0

	BX LR @back to prescaler

