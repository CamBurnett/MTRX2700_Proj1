.syntax unified
.thumb

@base registers for the LEDs
@ different UARTs use different GPIOs for the pins
.equ GPIOA, 0x48000000	@ base register for GPIOA (pa0 is the button)
.equ GPIOB, 0x48000400	@ base register for GPIOA (pa0 is the button)
.equ GPIOC, 0x48000800	@ base register for GPIOA (pa0 is the button)
.equ GPIOD, 0x48000C00	@ base register for GPIOD (pe8-15 are the LEDs)
.equ GPIOE, 0x48001000	@ base register for GPIOE (pe8-15 are the LEDs)

@Enable bits for any UART
.equ GPIOA_ENABLE, 17	@ enable bit for GPIOA
.equ GPIOB_ENABLE, 18	@ enable bit for GPIOB
.equ GPIOC_ENABLE, 19	@ enable bit for GPIOC
.equ GPIOD_ENABLE, 20	@ enable bit for GPIOD
.equ GPIOE_ENABLE, 21	@ enable bit for GPIOE

@register offsets
.equ ODR, 0x14	@ GPIO output register
.equ IDR, 0x10 @Setting GPIO address offset
.equ MODER, 0x00 @ register for setting the port mode (in/out/etc)
.equ GPIO_MODER, 0x00	@ set the mode for the GPIO
.equ GPIO_OSPEEDR, 0x08	@ set the speed for the GPIO

@clock and timing register
.equ RCC, 0x40021000 @base register for resetting and clock settings
.equ TIM2EN, 0 @enabling offset for timer2
.equ TIM2, 0x40000000 @base register for the general timer2
.equ TIM_CR1, 0x00 @control registers
.equ TIM_CNT, 0x24  @ The actual counter location

@AHB registers for enabling clocks
.equ AHBENR, 0x14 @enable peripherals
.equ APB1ENR, 0x1C
.equ APB2ENR, 0x18
.equ AFRH, 0x24 @AF high and low registers
.equ AFRL, 0x20
.equ RCC_CR, 0x00 @ control clock register
.equ RCC_CFGR, 0x04 @ configure clock register

@USART2 Configuration definitions
.equ UART2, 0x40004400      @ USART2 base
.equ UART2_EN, 17           @ USART2 enable bit in APB1ENR (bit 17)
.equ APBENR, APB1ENR        @ same APB1 peripheral enable register
.equ MODER2_CLEAR_MASK, (0xF << 4)   @ PA2/PA3 alternate function clear (bits 4-7)
.equ MODER2_ALT_MASK,   (0xA << 4)   @ PA2/PA3 alternate function mode
.equ AFRREG, AFRL             @ AFRL for PA2/PA3 (pins 0-7)
.equ AFR_CLEAR_MASK, (0xFF << 8)    @ AFRL bits for PA2/PA3
.equ AFR_SET_MASK,   (0x77 << 8)    @ AF7 for USART2 TX/RX

@ USART3 Configuration definitions
.equ UART3, 0x40004800 @USART3
.equ UART3_EN, 18 @ specific bit to enable this UART
.equ MODER3_CLEAR_MASK, (0xF << 20)
.equ MODER3_ALT_MASK, (0xA << 20)
.equ AFRREG, AFRH

@ BAUD RATE
@.equ BAUD_RATE, 0x43
@.equ BAUD_RATE, 833 @ 9600 Baud
.equ BAUD_RATE, 208 @ 38400 Baud

@ register addresses and offsets for general UARTs
.equ USART_CR1, 0x00
.equ USART_BRR, 0x0C
.equ USART_ISR, 0x1C @ UART status register offset
.equ USART_ICR, 0x20 @ UART clear flags for errors

.equ UART_TE, 3	@ transmit enable bit
.equ UART_RE, 2	@ receive enable bit
.equ UART_UE, 0	@ enable bit for the whole UART
.equ UART_ORE, 3 @ Overrun flag
.equ UART_FE, 1 @ Frame error

.equ UART_ORECF, 3 @ Overrun clear flag
.equ UART_FECF, 1 @ Frame error clear flag

@ setting the clock speed higher using the PLL clock option
.equ HSEBYP, 18	@ bypass the external clock
.equ HSEON, 16 @ set to use the external clock
.equ HSERDY, 17 @ wait for this to indicate HSE is ready
.equ PLLON, 24 @ set the PLL clock source
.equ PLLRDY, 25 @ wait for this to indicate PLL is ready
.equ PLLEN, 16 @ enable the PLL clock
.equ PLLSRC, 16
.equ USBPRE, 22 @ with PLL active, this must be set for the USB

.equ PWREN, 28
.equ SYSCFGEN, 0

.equ PB10_MODER_CLEAR_MASK, (0x3 << 20)   @ clear bits 20-21 (mode)
.equ PB10_MODER_AF_MASK,    (0x2 << 20)   @ set alternate function mode (10b)
.equ PB10_AFRH_MASK_CLEAR,  (0xF << 8)    @ clear AFRH[11:8] for PB10
.equ PB10_AFRH_AF7,         (0x7 << 8)    @ set AF7 for PB10

.equ PA10_MODER_CLEAR_MASK, (0x3 << 20)
.equ PA10_MODER_AF_MASK,    (0x2 << 20)
.equ PA10_AFRH_MASK_CLEAR,  (0xF << 8)
.equ PA10_AFRH_AF7,         (0x7 << 8)