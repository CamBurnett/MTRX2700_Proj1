.syntax unified
.thumb

#include "definitions.s"

#.global enable_timer2_clock
#.global enable_peripheral_clocks
#.global initialise_discovery_board

.text
@ define code

initialise_discovery_board:
	LDR R0, =GPIOE
	LDR R1, =0x5555
	STRH R1, [R0, #MODER + 2]
	BX LR

enable_peripheral_clocks:
	LDR R0, =RCC @load the address of the RCC
	@#AHBENR is the address offset, and R0 is where the RCC register address is placed
	LDR R1, [R0, #AHBENR] @load the current value of the peripheral clock registers
	ORR R1, 1 << 21 @21st bit enables the GPIOE clock
	STR R1, [R0, #AHBENR] @store the modified registers in the RCC
	BX LR @return

enable_timer2_clock:
	LDR R0, =RCC @load the address of the RCC
	LDR R1, [R0, APB1ENR] @load the currenty value of the peripheral clock registers using bus 1
	ORR R1, 1 << TIM2EN @1st bit is where timer2 gets enabled
	STR R1, [R0, APB1ENR] @enable the timer
	BX LR @return
