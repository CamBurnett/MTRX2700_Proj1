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
    BEQ send_ack

send_nak:
    MOV R3, #0x15

    nak_tx_wait:
    LDR R1, [R0, USART_ISR]
    TST R1, #(1 << 7)   @ TXE
    BEQ nak_tx_wait

    STRB R3, [R0, USART_TDR]
    B end_packet

send_ack:
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
