
.syntax unified
.thumb

.global main
.thumb_func

.type main, %function

#include "initialise.s"

.data
@ define variables


.align
@ can allocate as an array
@ or allocate just as a block of space with this number of bytes
incoming_buffer: .space 62
buffer: .space 24

@ One strategy is to keep a variable that lets you know the size of the buffer.
incoming_counter: .byte 62

@ Define a string
tx_string: .asciz "ABC"
@ one way to know the length of the string is to just define it as a variable


.text
@ define text


@ this is the entry function called from the c file
main:

	@ in class run through the functions to perform the config of the ports
	@ for more details on changing the UART, refer to the week 3 live lecture/tutorial session.

	BL initialise_power
	@BL change_clock_speed
	BL enable_peripheral_clocks
	@BL enable_uart2
	@BL enable_uart3
	BL enable_uart1

	LDR R0, =GPIOA

wait_for_button:
	LDRB R1, [R0, #IDR]
	ANDS R1, #0x01 @Only looking at the lowest bit PA0 for button on or off
	BNE pressed
	B wait_for_button
	@ uncomment the next line to enter a transmission loop

	pressed:
		loop_tx:
    	BL tx_loop
    	B loop_tx


	@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and counter memory areas
	LDR R6, =incoming_buffer
	LDR R8, =incoming_counter

	@ dereference the memory for the maximum buffer size, store it in R9
	LDRB R9, [R8]

	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0


	LDR R0, =UART1       @ UART2 base address
    LDR R6, =incoming_buffer  @ buffer pointer
    MOV R8, #0
@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)


tx_loop:
    LDR R0, =UART1
    LDR R1, =buffer
    LDR R3, =tx_string
    MOV R10, #0           @ string index
	MOV R6, #0
	MOV R5, #0x02
	STRB R5, [R1, R6]       @ STX
	ADD R6, #2               @ skip length slot at buffer[1] for now
	MOV R7, #0               @ data length counter

copy_string_tx:
    LDRB R4, [R3, R10]
    CMP R4, #0
    BEQ add_etx
    CMP R4, #'a'
    BLT store_char
    CMP R4, #'z'
    BGT store_char
    SUB R4, #32

store_char:
    STRB R4, [R1, R6]
    ADD R6, #1
    ADD R10, #1
    ADD R7, #1
    B copy_string_tx

add_etx:
    MOV R4, #0x03
    STRB R4, [R1, R6]
    ADD R6, #1
    ADD R7, #1

    STRB R7, [R1, #1]      @ now safe: store LENGTH in reserved slot

    MOV R12, #0
    MOV R8, #0

checksum_loop:
    CMP R8, R6
    BEQ store_checksum
    LDRB R9, [R1, R8]
    EOR R12, R12, R9
    ADD R8, #1
    B checksum_loop

store_checksum:
    STRB R12, [R1, R6]
    ADD R6, #1

    MOV R8, #0

tx_uart_loop:
    CMP R8, R6
    BGE tx_done
    LDR R9, [R0, USART_ISR]
    TST R9, #(1 << UART_TXE)
    BEQ tx_uart_loop
    LDRB R10, [R1, R8]
    STRB R10, [R0, USART_TDR]
    MOV R12, #100
delay_loop:
    SUBS R12, R12, #1
    BNE delay_loop
    ADD R8, #1
    B tx_uart_loop

tx_done:
    BX LR
