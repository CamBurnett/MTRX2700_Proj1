

@ base register for resetting and clock settings
.equ RCC, 0x40021000
.equ AHBENR, 0x14	@ register for enabling clocks
.equ APB1ENR, 0x1C
.equ APB2ENR, 0x18
.equ AFRH, 0x24 @AF high and low registers
.equ AFRL, 0x20
.equ RCC_CR, 0x00 @ control clock register
.equ RCC_CFGR, 0x04 @ configure clock register

.equ IDR, 0x10 @Setting GPIO address offset
.equ MODER, 0x00
@ specific base address for the desired UART to use
@  find this in the peripheral register memory boundary in the big manual

@ USART1
.equ UART1, 0x40013800 @USART1
.equ UART1_EN, 14 @ specific bit to enable this UART
.equ APBENR1, APB2ENR
.equ MODER_CLEAR_MASK1, (0xF << 8)
.equ MODER_ALT_MASK1, (0xA << 8)
.equ AFRREG1, AFRL
.equ AFR_CLEAR_MASK1, (0xFF << 16)
.equ AFR_SET_MASK1, (0x77 << 16)

@ USART3
.equ UART, 0x40004800 @USART3
.equ UART_EN, 18 @ specific bit to enable this UART
.equ APBENR, APB1ENR
.equ MODER_CLEAR_MASK, (0xF << 20)
.equ MODER_ALT_MASK, (0xA << 20)
.equ AFRREG, AFRH
.equ AFR_CLEAR_MASK, (0xFF << 8)
.equ AFR_SET_MASK, (0x77 << 8)

@ BAUD RATE
.equ BAUD_RATE, 0x43
@.equ BAUD_RATE, 833 @ 9600 Baud
@.equ BAUD_RATE, 208 @ 38400 Baud


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
.equ UART_FECF, 3 @ Frame error clear flag


@ different UARTs use different GPIOs for the pins
.equ GPIOA, 0x48000000	@ base register for GPIOA (pa0 is the button)
.equ GPIOB, 0x48000400	@ base register for GPIOA (pa0 is the button)
.equ GPIOC, 0x48000800	@ base register for GPIOA (pa0 is the button)
.equ GPIOD, 0x48000C00	@ base register for GPIOD (pe8-15 are the LEDs)
.equ GPIOE, 0x48001000	@ base register for GPIOE (pe8-15 are the LEDs)

.equ GPIOA_ENABLE, 17	@ enable bit for GPIOA
.equ GPIOB_ENABLE, 18	@ enable bit for GPIOB
.equ GPIOC_ENABLE, 19	@ enable bit for GPIOC
.equ GPIOD_ENABLE, 20	@ enable bit for GPIOD
.equ GPIOE_ENABLE, 21	@ enable bit for GPIOE


.equ GPIO_MODER, 0x00	@ set the mode for the GPIO
.equ GPIO_OSPEEDR, 0x08	@ set the speed for the GPIO

@ transmitting and receiving data
.equ UART_TXE, 7	@ a new byte is ready to read
.equ USART_TDR, 0x28	@ a new byte is ready to read

.equ UART_RXNE, 5	@ a new byte is ready to read
.equ USART_RDR, 0x24	@ a new byte is ready to read
.equ USART_RQR, 0x18
.equ UART_RXFRQ, 3	@ a new byte is ready to read

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

@@@@

.equ ODR, 0x14          @ Output data register offset

@ LED pin
.equ LED_PIN, 8          @ PE8


