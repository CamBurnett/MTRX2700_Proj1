.syntax unified
    .thumb
    .global main

    .section .data

MyString:
    .asciz "Supercalafragalisticexpialadocious"

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

	@Compare the byte of the string address to zero
	CMP R3, #0

	@If the byte is equal to zero, break the function
	BEQ done

	ADD R2, #1
	@If the byte is not equal to zero, restart loop
	B count

done:
    B done

    .size main, .-main
    .end

