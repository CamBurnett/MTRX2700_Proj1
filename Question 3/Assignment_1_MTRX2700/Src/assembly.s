
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
tx_length: .byte 27


.text
@ define text


@ this is the entry function called from the c file
main:

	@ in class run through the functions to perform the config of the ports
	@ for more details on changing the UART, refer to the week 3 live lecture/tutorial session.

	BL initialise_power
	@BL change_clock_speed
	BL enable_peripheral_clocks

	BL enable_uart3
	BL enable_uart1

	LDR R0, =GPIOA

	wait_for_button:
	LDRB R1, [R0, #IDR]
	ANDS R1, #0x01 @Only looking at the lowest bit PA0 for button on or off
	BNE pressed
	B wait_for_button
	@ uncomment the next line to enter a transmission loop

	pressed:
		BL tx_loop


	@ To read in data, we need to use a memory buffer to store the incoming bytes
	@ Get pointers to the buffer and counter memory areas
	LDR R6, =incoming_buffer
	LDR R8, =incoming_counter

	@ dereference the memory for the maximum buffer size, store it in R7
	LDRB R9, [R8]

	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0


	LDR R0, =UART1        @ UART1 base address
    LDR R6, =incoming_buffer  @ buffer pointer
    MOV R8, #0
@ continue reading forever (NOTE: eventually it will run out of memory as we don't have a big buffer)
read_loop:

wait_for_stx:

    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 5)   @ RXNE is usually bit 5
    BEQ wait_for_stx           @ wait until a byte arrives
    LDRB R3, [R0, USART_RDR]  @ read STX
    CMP R3, #0x02              @ STX = 0x02?
    BNE wait_for_stx           @ ignore garbage

    @ Turn LED ON here to test reception
    LDR R0, =GPIOE
    LDR R1, [R0, #0x14]
    ORR R1, R1, #(1 << 8)
    STR R1, [R0, #0x14]

    STRB R3, [R6, R8]          @ store STX
    ADD R8, #1                 @ index for next byte

wait_for_length:

    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 5)   @ RXNE is usually bit 5
    BEQ wait_for_length        @ wait until length byte arrives
    LDRB R7, [R0, USART_RDR]   @ R7 = DATA length
	STRB R7, [R6, R8]          @ store REAL length
	ADD R7, R7, #4             @ now convert to TOTAL length
    ADD R8, #1

read_data_loop:

    CMP R8, R7                  @ have we read all bytes? (length includes data only)
    BEQ process_packet          @ done
    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 5)   @ RXNE is usually bit 5
    BEQ read_data_loop           @ wait until next byte
    LDRB R3, [R0, USART_RDR]
    STRB R3, [R6, R8]
    ADD R8, #1
    B read_data_loop


process_packet:
    @ buffer now contains full packet (length bytes)
    @ Last byte in buffer = received checksum
    @ Compute checksum over buffer[0..length-2]
	MOV R10, #1        @ start at LEN (skip STX at index 0)
	MOV R9, #0         @ checksum

checksum_loop2:
    SUB R11, R7, #1      @ index of CHECKSUM
    CMP R10, R11
    BEQ checksum_done

    LDRB R3, [R6, R10]
    EOR R9, R9, R3

    ADD R10, #1
    B checksum_loop2

checksum_done:
    SUB R11, R7, #1   @ R11 = R7 - 1 (last byte index)
	LDRB R3, [R6, R11]   @ load received checksum
    CMP R9, R3
    BEQ send_ack
send_nak:
    MOV R3, #0x15
    STRB R3, [R0, USART_TDR]
    B end_packet
send_ack:
    MOV R3, #0x06
    STRB R3, [R0, USART_TDR]

end_packet:
    MOV R8, #0                 @ reset index for next packet
    B wait_for_stx


tx_loop:

    LDR R0, =UART        @ UART3 base
    LDR R1, =buffer       @ TX buffer
    LDR R3, =tx_string    @ Source string to transmit
    LDRB R4, [R3]         @ First character in string
    MOV R10, #0           @ Index for tx_string
    MOV R6, #0            @ Index for buffer (after STX)

    MOV R5, #0x02         @ STX
    STRB R5, [R1, #0]     @ Buffer[0] = STX
    ADD R6, #1             @ Next buffer index


copy_string_tx:
    LDRB R4, [R3, R10]    @ Load next character
    CMP R4, #0             @ NULL terminator?
    BEQ add_etx            @ Yes, go add ETX

    @ Convert lowercase to uppercase if needed
    CMP R4, #0x61
    BLT store_char
    CMP R4, #0x7A
    BGT store_char
    SUB R4, #32            @ Convert to uppercase

store_char:
    STRB R4, [R1, R6]     @ Store in buffer
    ADD R6, #1
    ADD R10, #1
    B copy_string_tx


add_etx:
    MOV R4, #0x03          @ ETX
    STRB R4, [R1, R6]
    ADD R6, #1             @ Increment buffer index


    SUB R5, R6, #2         @ DATA length (exclude STX and length byte itself)
    STRB R5, [R1, #1]


    MOV R7, #1             @ start at index 1
    MOV R12, #0            @ checksum accumulator

checksum_loop_tx:
    CMP R7, R6
    BEQ store_checksum_tx
    LDRB R8, [R1, R7]
    EOR R12, R12, R8
    ADD R7, #1
    B checksum_loop_tx

store_checksum_tx:
    STRB R12, [R1, R6]    @ Append checksum
    ADD R6, #1             @ total packet length

    MOV R8, #0             @ Index for transmitting

tx_uart_loop:
    LDR R9, [R0, USART_ISR]
    TST R9, #(1 << 7)      @ Wait until TXE=1
    BEQ tx_uart_loop

    LDRB R10, [R1, R8]
    STRB R10, [R0, USART_TDR]
    ADD R8, #1
    CMP R8, R6
    BLT tx_uart_loop

    BX LR                  @ Done
