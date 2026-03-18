.syntax unified
.thumb

@base registers for the LEDs
.equ GPIOE, 0x48001000	@ base register for GPIOE (pe8-15 are the LEDs)

@register offsets
.equ ODR, 0x14	@ GPIO output register
.equ MODER, 0x00 @ register for setting the port mode (in/out/etc)

@clock and timing registers
.equ RCC, 0x40021000 @base register for resetting and clock settings
.equ TIM2EN, 0 @enabling offset for timer2
.equ TIM2, 0x40000000 @base register for the general timer2
.equ TIM_CR1, 0x00 @control registers
.equ TIM_CNT, 0x24  @the actual counter location
.equ TIM_PSC, 0x28 @prescaler value
.equ TIM_ARR, 0x2C @the register for the auto-reload

@AHB registers for enabling clocks
.equ AHBENR, 0x14 @enable peripherals
.equ APB1ENR, 0x1C
