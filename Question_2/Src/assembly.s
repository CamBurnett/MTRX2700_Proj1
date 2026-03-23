.syntax unified
.thumb

.global main

.thumb_func

.type main, %function

#include "definitions.s"
#include "initialise.s"

.data

.text

main:
	@function call to enable clock
	BL enable_peripheral_clocks
	@function call to initialise discovery board
	BL initialise_discovery_board

	MOV R4, #0 @setting the LED counter to 0 using R4
	MOV R5, #0 @setting the direction of the counter to 0 (up)
	MOV R7, #0 @setting R7 to 0 (button) or 1 (automatic) to indicate mode

program_loop:
	CMP R7, #0 @comparing R7 to 0 to check mode
    BEQ button @if R7 is 0 then the program branches to button mode

automatic:
	BL delay_function
    B counter

button:
check_press:
	LDR R0, =GPIOA
	LDR R1, [R0, #IDR]
	ANDS R1, #0x01
	BEQ check_press

	BL delay_function

	LDR R0, =GPIOA
	LDR R1, [R0, #IDR]
	ANDS R1, #0x01
	BEQ check_press

counter:
	CMP R5, #1
	BEQ go_down

go_up:
	ADDS R4, R4, #1
	CMP R4, #0xFF
	BNE led_display
	MOV R5, #1
	B led_display

go_down:
	SUBS R4, R4, #1
	CMP R4, #0
	BNE led_display
	MOV R5, #0

led_display:
	LDR R0, =GPIOE
	STRB R4, [R0, #ODR + 1]

	CMP R7, #0
	BNE program_loop

button_press:
	LDR R0, =GPIOA
    LDR R1, [R0, #IDR]
    ANDS R1, R1, #0x01
    BNE button_press

	B program_loop

delay_function:
    LDR R6, =0x0001FFFF

debounce:
    SUBS R6, R6, #1
    BNE debounce

    BX LR
