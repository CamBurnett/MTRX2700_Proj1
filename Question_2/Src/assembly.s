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
	BL delay_function	@delay to control speed of counting
    B counter	@branch to counter update function

button:
check_press:
	LDR R0, =GPIOA	@load the base address of GPIOA into R0 (input button port)
	LDR R1, [R0, #IDR] @read the GPIOA input data register into R1
	ANDS R1, #0x01	@mask bits
	BEQ check_press @if button not pressed loop again

	BL delay_function	@delay for debouncing button press

	LDR R0, =GPIOA
	LDR R1, [R0, #IDR]
	ANDS R1, #0x01	@mask bits
	BEQ check_press	@when button no longer pressed

counter:
	CMP R5, #1 @compare direction flag to 1
	BEQ go_down @if 1, count down logic starts

go_up:
	ADDS R4, R4, #1	@increment the counter value by 1
	CMP R4, #0xFF	@check if all LEDs on
	BNE led_display	@if all not on, branch to display value
	MOV R5, #1	@if all are on, change to count down
	B led_display	@branch to function that updates LEDs

go_down:
	SUBS R4, R4, #1	@decrease the counter value by 1
	CMP R4, #0	@check if all LEDs off
	BNE led_display	@if all not off, branch to display value
	MOV R5, #0	@if all are off, change to count up

led_display:
	LDR R0, =GPIOE	@load the base address of GPIOE into R0
	STRB R4, [R0, #ODR + 1]	@store low byte of R4 to PE8–PE15

	CMP R7, #0	@compare mode flag to 0
	BNE program_loop @if automatic, skip button press check

button_press:
	LDR R0, =GPIOA	@load the base address of GPIOA into R0
    LDR R1, [R0, #IDR]	@read the GPIOA input data register into R1
    ANDS R1, R1, #0x01 @mask bits
    BNE button_press	@if button still pressed program pauses

	B program_loop	@button released and goes back to start

delay_function:
    LDR R6, =0x0001FFFF @delay loop count

debounce:
    SUBS R6, R6, #1	@subtract from delay loop count
    BNE debounce	@continue looping until 0

    BX LR
