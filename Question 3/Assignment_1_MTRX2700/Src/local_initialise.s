.syntax unified
.thumb

#include "definitions.s"

enable_button:

	LDR R0, =GPIOA

	LDRB R1, [R0, #MODER]
	AND R1, #0b11111100
	STRB R1, [R0, #MODER]


@ function to enable the clocks for the peripherals we could be using (A, B, C, D and E)
enable_peripheral_clocks:

	@ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R0, =RCC

	@ enable all of the GPIO peripherals in AHBENR
	LDR R1, [R0, #AHBENR]
	ORR R1, 1 << GPIOE_ENABLE | 1 << GPIOD_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOB_ENABLE | 1 << GPIOA_ENABLE  @ enable GPIO
	STR R1, [R0, #AHBENR]

	BX LR @ return



@ function to enable a UART device - this requires:
@  setting the alternate pin functions for the UART (select the pins you want to use)
@
@ BAUD rate needs to change depending on whether it is 8MHz (external clock) or 24MHz (our PLL setting)
enable_uart3:
    LDR R0, =GPIOB          @ change from GPIOC to GPIOB

    @ Alternate function register (AFRH because PB10 is pin 10)
    LDR R1, [R0, AFRH]
    BIC R1, R1, #(0xF << 8) @ clear bits for PB10
    ORR R1, R1, #(0x7 << 8) @ set AF7 for UART3_TX
    STR R1, [R0, AFRH]

    @ MODER register: alternate function mode
    LDR R1, [R0, MODER]
    BIC R1, R1, #(0x3 << 20) @ clear mode bits 20-21 for PB10
    ORR R1, R1, #(0x2 << 20) @ set AF mode
    STR R1, [R0, MODER]

    @ High speed
    LDR R1, [R0, GPIO_OSPEEDR]
    ORR R1, R1, #(0x3 << 20)  @ high speed
    STR R1, [R0, GPIO_OSPEEDR]

    @ Enable UART3 clock (APB1)
    LDR R0, =RCC
    LDR R1, [R0, APB1ENR]
   @ ORR R1, R1, 1 << UART_EN
    STR R1, [R0, APB1ENR]

    @ Set baud rate
    LDR R0, =UART3
    MOV R1, BAUD_RATE
    STRH R1, [R0, USART_BRR]

    @ Enable UART, TX and RX
    LDR R1, [R0, USART_CR1]
    ORR R1, R1, (1 << UART_UE | 1 << UART_TE | 1 << UART_RE)
    STR R1, [R0, USART_CR1]

    BX LR

enable_uart1:

    LDR R0, =GPIOC           @ PC4/PC5
    @ AFRL
    LDR R1, [R0, AFRL]
    BIC R1, R1, #PC4_AFRL_MASK_CLEAR
    ORR R1, R1, #PC4_AFRL_AF7
    BIC R1, R1, #PC5_AFRL_MASK_CLEAR
    ORR R1, R1, #PC5_AFRL_AF7
    STR R1, [R0, AFRL]

    @ MODER alternate
    LDR R1, [R0, MODER]
    BIC R1, R1, #PC4_MODER_CLEAR_MASK
    ORR R1, R1, #PC4_MODER_AF_MASK
    BIC R1, R1, #PC5_MODER_CLEAR_MASK
    ORR R1, R1, #PC5_MODER_AF_MASK
    STR R1, [R0, MODER]

    @ high speed
    LDR R1, [R0, GPIO_OSPEEDR]
    ORR R1, R1, #(0x3 << 8)   @ PC4 high speed
    ORR R1, R1, #(0x3 << 10)  @ PC5 high speed
    STR R1, [R0, GPIO_OSPEEDR]

    @ Enable UART1 clock (APB2)
    LDR R0, =RCC
    LDR R1, [R0, APB2ENR]
    ORR R1, R1, 1 << UART1_EN
    STR R1, [R0, APB2ENR]

    @ Set baud rate
    LDR R0, =UART1
    MOV R1, BAUD_RATE
    STRH R1, [R0, USART_BRR]

    @ Enable UART1, TX only (RX optional)
    LDR R1, [R0, USART_CR1]
    ORR R1, R1, (1 << UART_UE | 1 << UART_TE)
    STR R1, [R0, USART_CR1]

    BX LR

enable_uart2:

    LDR R0, =GPIOA          @ GPIOA for PA2/PA3

    @ Alternate function register (AFRL because PA2 is pin 2)
    LDR R1, [R0, AFRL]
    BIC R1, R1, #(0xF << 8)   @ clear bits for PA2 (AFRL[11:8])
    ORR R1, R1, #(0x7 << 8)   @ set AF7 for USART2_TX
    STR R1, [R0, AFRL]

    LDR R1, [R0, AFRL]
    BIC R1, R1, #(0xF << 12)  @ clear bits for PA3 (AFRL[15:12])
    ORR R1, R1, #(0x7 << 12)  @ set AF7 for USART2_RX
    STR R1, [R0, AFRL]

    @ MODER register: alternate function mode
    LDR R1, [R0, MODER]
    BIC R1, R1, #(0x3 << 4)   @ clear mode bits 4-5 for PA2
    ORR R1, R1, #(0x2 << 4)   @ set AF mode
    BIC R1, R1, #(0x3 << 6)   @ clear mode bits 6-7 for PA3
    ORR R1, R1, #(0x2 << 6)   @ set AF mode
    STR R1, [R0, MODER]

    @ High speed
    LDR R1, [R0, GPIO_OSPEEDR]
    ORR R1, R1, #(0x3 << 4)   @ PA2 high speed
    ORR R1, R1, #(0x3 << 6)   @ PA3 high speed
    STR R1, [R0, GPIO_OSPEEDR]

    @ Enable USART2 clock (APB1ENR, bit 17)
    LDR R0, =RCC
    LDR R1, [R0, APB1ENR]
    ORR R1, R1, 1 << 17
    STR R1, [R0, APB1ENR]

    @ Set baud rate
    LDR R0, =UART2
    MOV R1, BAUD_RATE
    STRH R1, [R0, USART_BRR]

    @ Enable UART, TX and RX
    LDR R1, [R0, USART_CR1]
    ORR R1, R1, (1 << UART_UE | 1 << UART_TE | 1 << UART_RE)
    STR R1, [R0, USART_CR1]

    BX LR


@ set the PLL (clocks are described in page 125 of the large manual)
change_clock_speed:
@ step 1, set clock to HSE (the external clock)
	@ enable HSE (and wait for complete)
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	LDR R2, =1 << HSEBYP | 1 << HSEON @ make a bit mask with a '1' in the 0th bit position
	ORR R1, R2 @ apply the bit mask to the previous values of the enable register
	STR R1, [R0, #RCC_CR] @ store the modified enable register values back to RCC

	@ wait for the changes to be completed
wait_for_HSERDY:
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	TST R1, 1 << HSERDY @ Test the HSERDY bit (check if it is 1)
	BEQ wait_for_HSERDY

@ step 2, now the clock is HSE, we are allowed to switch to PLL
	@ clock is set to External clock (external crystal) - 8MHz, can enable the PLL now
	LDR R1, [R0, #RCC_CFGR] @ load the original value from the enable register
	LDR R2, =1 << 20 | 1 << PLLSRC | 1 << 22 @ the last term is for the USB prescaler to be 1
	ORR R1, R2  @ set PLLSRC (use PLL) and PLLMUL to 0100 - bit 20 is 1 (set speed as 6x faster)
				@ see page 140 of the large manual for options
				@ NOTE: cannot go faster than 72MHz)
	STR R1, [R0, #RCC_CFGR] @ store the modified enable register values back to RCC

	@ enable PLL (and wait for complete)
	LDR R0, =RCC @ the base address for the register to turn clocks on/off
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	ORR R1, 1 << PLLON @ apply the bit mask to turn on the PLL
	STR R1, [R0, #RCC_CR] @ store the modified enable register values back to RCC

wait_for_PLLRDY:
	LDR R1, [R0, #RCC_CR] @ load the original value from the enable register
	TST R1, 1 << PLLRDY @ Test the HSERDY bit (check if it is 1)
	BEQ wait_for_PLLRDY

@ step 3, PLL is ready, switch over the system clock to PLL
	LDR R0, =RCC  @ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R1, [R0, #RCC_CFGR]  @ load the current value of the peripheral clock registers
	MOV R2, 1 << 10 | 1 << 1  @ some more settings - bit 1 (SW = 10)  - PLL set as system clock
									   @ bit 10 (HCLK=100) divided by 2 (clock is faster, need to prescale for peripherals)
	ORR R1, R2	@ Set the values of these two clocks (turn them on)
	STR R1, [R0, #RCC_CFGR]  @ store the modified register back to the submodule

	LDR R1, [R0, #RCC_CFGR]  @ load the current value of the peripheral clock registers
	ORR R1, 1 << USBPRE	@ Set the USB prescaler (when PLL is on for the USB)
	STR R1, [R0, #RCC_CFGR]  @ store the modified register back to the submodule

	BX LR @ return



@ initialise the power systems on the microcontroller
@ PWREN (enable power to the clock), SYSCFGEN system clock enable
initialise_power:

	LDR R0, =RCC @ the base address for the register to turn clocks on/off

	@ enable clock power in APB1ENR
	LDR R1, [R0, #APB1ENR]
	ORR R1, 1 << PWREN @ apply the bit mask for power enable
	STR R1, [R0, #APB1ENR]

	@ enable clock config in APB2ENR
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << SYSCFGEN @ apply the bit mask to allow clock configuration
	STR R1, [R0, #APB2ENR]

	BX LR @ return




