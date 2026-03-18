.syntax unified
.thumb

#include "initialise.s"

.global main
.thumb_func

.data
prefix: .asciz "COUNTER = "
prefix_end:
buffer: .space 32

.align 2

.type main, %function

.text

main:
    LDR R1, =prefix
    MOV R2, #0
    MOV R3, #0
    @ Counter Value ---------------- TO CHANGE
    MOV R4, #7

count_string:
    @ Base length: STX(1) + MsgLen(1) + Prefix(10) + ETX(1) + Checksum(1) = 14
    ADD R2, #14

check_digits:
    CMP R4, #10
    BLT single_digit
    CMP R4, #100
    BLT double_digit
    B triple_digit

single_digit:
    ADD R2, #1
    B done_digits

double_digit:
    ADD R2, #2
    B done_digits

triple_digit:
    ADD R2, #3
    B done_digits

done_digits:
    B concatenate

concatenate:
    LDR R6, =buffer
    @Set R7 to buffer index
    MOV R7, #0

    @ Set STX to first byte of buffer
    MOV R5, #0x02
    STRB R5, [R6, R7]
    ADD R7, #1

    @ Set MSG Length to second byte of buffer
    STRB R2, [R6, R7]
    ADD R7, #1

    @ Set prefix bytes to next bytes of buffer
    @Set R3 as index to add string bytes
    MOV R3, #0
copy_prefix:
	@Loop through prefix and add to buffer
    LDRB R5, [R1, R3]
    CMP R5, #0
    @If value is null, string is done
    BEQ prefix_done
    STRB R5, [R6, R7]
    ADD R3, #1
    ADD R7, #1
    B copy_prefix

prefix_done:
    @Check if triple digit (R2 == 17)
    CMP R2, #17
    BLT skip_hundreds

    MOV R5, R4
    MOV R8, #0
hundreds_loop:
	@Obtain hundreds digit of the counter value
    CMP R5, #100
    BLT hundreds_done
    SUB R5, R5, #100
    ADD R8, #1
    B hundreds_loop
hundreds_done:
	@Convert digit into ascii
    ADD R8, #0x30
    STRB R8, [R6, R7]
    ADD R7, #1
    MOV R4, R5

skip_hundreds:
    @Check if double digit or more (R2 >= 16)
    CMP R2, #16
    BLT skip_tens

    MOV R5, R4
    MOV R8, #0
tens_loop:
	@Obtain tens digit of the counter value
    CMP R5, #10
    BLT tens_done
    SUB R5, R5, #10
    ADD R8, #1
    B tens_loop
tens_done:
	@Convert digit into ascii
    ADD R8, #0x30
    STRB R8, [R6, R7]
    ADD R7, #1
    MOV R4, R5

skip_tens:
    @Convert last digit into ascii
    ADD R5, R4, #0x30
    STRB R5, [R6, R7]
    ADD R7, #1

    @ Add ETX to end of string
    MOV R5, #0x03
    STRB R5, [R6, R7]
    ADD R7, #1

checksum:
    @ Set R3 as checksum value
    MOV R3, #0
    @Set R8 as checksum index
    MOV R8, #0
checksum_loop:
	@XOR every byte in the string to obtain checksum value
    LDRB R5, [R6, R8]
    EOR R3, R3, R5
    ADD R8, #1
    CMP R8, R7
    BLT checksum_loop

store_checksum:
    STRB R3, [R6, R7]
    ADD R7, #1

end:
	B end

    @ R7 now holds total packet length
    @ Buffer at R6 contains the complete packet
