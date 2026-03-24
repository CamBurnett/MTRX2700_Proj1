@Receiving end code. Here, it grabs the start flag, length and computes for the correct final length, and then computes the checksum
@We'll neeed to extract the count number from the received data and send it to Elena's code so her lights can display the count.
@Right now it only reads in the whole package
.syntax unified
.thumb

#include "initialise.s"

.global main
.thumb_func

.data
buffer: .space 32
incoming_buffer: .space 62

.align 2

.type main, %function

.text

main:
    BL initialise_power
    BL enable_peripheral_clocks
    BL enable_uart3
    BL initialise_discovery_board

read_loop:
	@ Keep a pointer that counts how many bytes have been received
	MOV R8, #0


	LDR R0, =UART3        @ UART2 base address
    LDR R6, =incoming_buffer  @ buffer pointer
    MOV R8, #0

wait_for_stx:

    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 5)   @ RXNE is usually bit 5
    BEQ wait_for_stx           @ wait until a byte arrives
    LDRB R3, [R0, USART_RDR]  @ read STX
    CMP R3, #0x02              @ STX = 0x02?
    BNE wait_for_stx           @ ignore garbage
    STRB R3, [R6, R8]
    ADD R8, #1

wait_for_length:

    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 5)   @ RXNE is usually bit 5
    BEQ wait_for_length        @ wait until length byte arrives
    LDRB R7, [R0, USART_RDR]   @ R7 = DATA length
	STRB R7, [R6, R8]          @ store length
    ADD R8, #1

read_data_loop:

    CMP R8, R7                  @ have we read all bytes? 
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
	MOV R10, #0   ; include STX
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
    BNE bad_message

    B initialise_counter


initialise_counter:
	MOV R4, #0 @R4 stores the final numeric value and initialise to 0
	MOV R10, #12 @R10 set to the first digit (offsets by 12)


extract_number:
	LDRB R3, [R6, R10]	@load the next ASCII character from the buffer into R3
	CMP R3, #0x03	@Compare with 0x03 (end of the number)
	BEQ display_number @if ETX, display result

	SUB R3, R3, #0x30 @convert ASCII to numeric

	MOV R2, #10	 @Load 10 to R2 to shift decimal place
	MUL R4, R4, R2	@Multiply current value by 10
	ADD R4, R4, R3	@Add new digit to number

	ADD R10, #1	@Move to next character in buffer
	B extract_number	@repeat loop for next digit

display_number:
	LDR R0, =GPIOE	@Load base address of GPIOE
    STRB R4, [R0, #ODR + 1]	@Output lower 8 bits of R4 to LEDs
    B send_ack	@Send ACK for valid message received

bad_message:
	BL flash_3	@For errors call the function to flash LEDs 3 times
    B send_nak	@Send NAK for malformed messages

flash_3:
	MOV R11, #6	@Set loop counter to 6 for 3 flashes
    MOV R12, #0x00 @lights off initially

flash_loop:
	LDR R0, =GPIOE	@Load GPIOE base address
    STRB R12, [R0, #ODR + 1]	@Load current on or off to LEDs
    EOR R12, R12, #0xFF @toggle all bits

    BL delay_function	@Delay to create flash

    SUBS R11, R11, #1	@Decrease flash counter
    BNE flash_loop	@Repeat 6 times

    BX LR

delay_function:
	LDR R5, =0x0FFFFF	@load value to create delay

not_finished:
	SUBS R5, R5, #1	@Decrease delay counter
    BNE not_finished	@Continue looping until counter reaches zero

    BX LR

send_nak:
	LDR R0, =UART3
    MOV R3, #0x15

    nak_tx_wait:
    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 7)   @ TXE
    BEQ nak_tx_wait

    STRB R3, [R0, USART_TDR]
    B end_packet

send_ack:
    LDR R0, =UART3
    MOV R3, #0x06
    
    ack_tx_wait:
    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 7)   @ TXE
    BEQ ack_tx_wait

    STRB R3, [R0, USART_TDR]
    B end_packet

end_packet:
    MOV R8, #0                 @ reset index for next packet
    B read_loop
