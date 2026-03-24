################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (14.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
S_SRCS += \
../Src/definitions.s \
../Src/initialise.s \
../Src/rx_assembly.s \
../Src/tx_assembly.s 

OBJS += \
./Src/definitions.o \
./Src/initialise.o \
./Src/rx_assembly.o \
./Src/tx_assembly.o 

S_DEPS += \
./Src/definitions.d \
./Src/initialise.d \
./Src/rx_assembly.d \
./Src/tx_assembly.d 


# Each subdirectory must supply rules for building sources it contributes
Src/%.o: ../Src/%.s Src/subdir.mk
	arm-none-eabi-gcc -mcpu=cortex-m4 -g3 -DDEBUG -c -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv4-sp-d16 -mfloat-abi=hard -mthumb -o "$@" "$<"

clean: clean-Src

clean-Src:
	-$(RM) ./Src/definitions.d ./Src/definitions.o ./Src/initialise.d ./Src/initialise.o ./Src/rx_assembly.d ./Src/rx_assembly.o ./Src/tx_assembly.d ./Src/tx_assembly.o

.PHONY: clean-Src

