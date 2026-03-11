.syntax unified
.thumb
    .global main

    .section .data

	buffer: .space 24

MyString:
    .asciz "Cam"

    .section .text
    .type main, %function
    .thumb_func

main:
	@Load the address of the string into register 1
    LDR R1, =MyString
    @Create an empty register for counting the amount of chars in string
    MOV R2, #0
    @Load empty Register 3
	MOV R3, #0


count:
	@Load the byte in register 3 at the value of R2
	LDRB R3, [R1,R2]

	@Check if charcter is null
	CMP R3, #0

	BEQ done

	@Check if character is lowercased
	CMP R3, #0x61
	BLT next

	CMP R3, #0x7A
	BGT next

	@Convert lower to uppercase
	SUB R3, #32

	@Store the new R3 value in R1 at index of R2
	STRB R3, [R1, R2]

next:
	@Increase count by one
	ADD R2, #1

	@If the byte is not equal to zero, restart loop
	B count


done:
    B concatanate

concatanate:
	@Load String into R0
	LDR R0, =MyString
	@Load STX into R1
	LDR R1, =buffer

	@R2 = String Length
	@R4 = Destination Index
	@R5 = Temporary byte store location

	@Set STX to first position of buffer
	MOV R5, #0x02
	STRB R5, [R1]

	@Use R6 as a temporary storage of message length
	@Add 3 to String length to account for ETX
	ADD R6, R2, #3
	@Store the length at the second position of R1
	STRB R6, [R1, #1]

	@Set index and destination index
	MOV R3, #0
	MOV R4, #2

copy_string:
	@Load the bytes of the string individually and store temporarily in R5
	LDRB R5, [R0, R3]
	@Check if NULL
	CMP R5, #0
	@ If NULL add ETX
	BEQ add_ETX
	@Else store the byte into R1
	STRB R5, [R1, R4]

	@Increment indexes
	ADD R3, #1
	ADD R4, #1

	@Repeat function until end of string
	B copy_string

add_ETX:
	@Move ETX byte into R1
	MOV R5, 0x03
	STRB R5, [R1, R4]

	@Store total length into R2
	ADD R2, R2, #3

checksum:
	@XOR register set to 0
	MOV R3, #0
	@Counter
	MOV R7, #0

checksum_loop:
	@Load R7th byte of R1 into R8
	LDRB R8, [R1, R7]

	@Compare loaded byte with R3 value and store in R3
	EOR R3, R3, R8

	@Increment counter
	ADD R7, #1

	CMP R7, R4
	BLS checksum_loop

store_checksum:
	@Append checksum
	STRB R3, [R1, R7]

	@Add 1 to total length
	ADD R2, #1

fake_data:
	MOV R0, R3
	STRB R0, [R1, R7]

check_receiving:
	@LDR R1, =ReceivingString
	@LDR R2, =receivingbuffer
	@Set Count to zero
	MOV R4, #0
	@Index
	MOV R5, #0
	@Checksum index
	SUB R6, R2, #1

verify_loop:
	@Check the l
	CMP R5, R6

	BGE verify_compare

	@Load next R1 byte at index R5
	LDRB R0, [R1, R5]
	@Perform XOR on loaded byte
	EOR R4, R4, R0

	@Next index and loop again until R5
	ADD R5, #1
	B verify_loop

verify_compare:
	@Load the checksum byte of receiving string
	LDRB R0, [R1, R5]

	@Compare received checksum to original checksum
	CMP R4, R0

	@If the checksum is the same, set R3 to 1, otherwise set to 0
	BEQ valid_checksum

	MOV R3, #0

	B end

valid_checksum:
	MOV R3, #1

end:
	B end

    .size main, .-main
    .end

