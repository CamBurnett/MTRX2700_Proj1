.syntax unified
.thumb

#include "definitions.s"

#.global enable_timer2_clock
#.global enable_peripheral_clocks
#.global initialise_discovery_board

.text
@ define code

initialise_discovery_board:
	LDR R0, =GPIOE
	LDR R1, =0x5555
	STRH R1, [R0, #MODER + 2]
	@BX LR

	@Power Board Initialisation for UART Transmission
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

enable_peripheral_clocks:
	LDR R0, =RCC @load the address of the RCC
	@#AHBENR is the address offset, and R0 is where the RCC register address is placed
	LDR R1, [R0, #AHBENR] @load the current value of the peripheral clock registers
	ORR R1, 1 << GPIOE_ENABLE | 1 << GPIOD_ENABLE | 1 << GPIOC_ENABLE | 1 << GPIOB_ENABLE | 1 << GPIOA_ENABLE  @ enable GPIO's
	STR R1, [R0, #AHBENR] @store the modified registers in the RCC
	BX LR @return

enable_timer2_clock:
	LDR R0, =RCC @load the address of the RCC
	LDR R1, [R0, APB1ENR] @load the currenty value of the peripheral clock registers using bus 1
	ORR R1, 1 << TIM2EN @1st bit is where timer2 gets enabled
	STR R1, [R0, APB1ENR] @enable the timer
	BX LR @return

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