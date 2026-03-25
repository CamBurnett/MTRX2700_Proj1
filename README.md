# MTRX2700_Proj1
Project 1

People:
Chelsea Satriavi

Angus Malcolm

Cameron Burnett

Elena Zengovski

Tasks:

Question 1: Cameron Burnett

High-Level Information about code:

**Transmitting Message:**
1. Load in a string
2. Count number of characters in string
3. Capitalise string if the number of characters is even, otherwise make string lowercase
4. Add an STX byte to start of message to indicate to receiver that string has begun
5. Add the length of the string to the message
6. Add the upper-cased or lower-cased string to the message
7. Add an ETX byte to the end of the message to indicate to receiver that the string has ended
8. Perform a checksum over the entire message to ensure that received message is correct

**Verifying Message:**
1. Load in the transmitted message
2. Perform checksum on the message (not including checksum byte)
3. If the checksum is the same as the transmitted checksum, set a register to 1 to indicate successful transmission, otherwise set register to 0.

**Checksum Process:**
1. Set checksum register to 0
2. Move to first byte of message and perform XOR function of the byte, and the current checksum value (0). New checksum value becomes the XOR'ed result
3. Move to next byte in message and XOR new checksum value with current byte. Set checksum value to XOR'ed result
4. Continue this process over every byte in the message.

Instructions for user:
1. Load an ascii string into MyString
2. Set a buffer space into buffer to ensure message has enough room for all bytes.
3. Message will be created into R1
4. To verify message: Create data in fake_data function, if R3 returns 1, the fake message is the same as the original message, otherwise it is different

Details about testing procedure:
1. Original ascii string is stored in R1, after the buffer
2. The finshed message in stored in the buffer in R1
3. The structure of the finished message is: [STX - Message Length - String Body - ETX - Checksum]
4. The verify loop checksum does not account for the checksum of the transmitted message, as it is not required

Question 2: Elena Zengovski
This program implements a counter that increases and decreases with either a button press or automatically. The program is broken into modules with hardware initialisation, control logic, input handling, and timing.
1. The initialisation of the program occurs first where clocks are enabled and GPIO pins are configured
2. In the main program loop, the program checks for either a button mode or automatic mode to increase or decrease the counter
3. For input handling, if in button press mode, the program checks for a valid press with an additional release check to ensure that one press corresponds to one increment
4. with each press, the counter module updates the value in R4 and goes up until it reaches its limit at 0xff and then back down to its limit 0x00
5. The output module displays the binary value on the LEDs
6. The delay module is responsible for controlling the timing in automatic mode and debouncing the button
7. In automatic mode, the counter updates continuously 

Instructions for user:
1. By default, the program starts in button mode (R7=0), this can be changed by changing R7 to 1
2. In button mode, increase or decrease the counter by pressing the button
3. when switching to automatic mode, rerun the program and the counter will update continuously

Details about testing procedure:
1. for button mode testing, testing to ensure that one button press corresponded to one increment or decrement
2. for automatic mode, observing that the LEDs change at a continous and steady rate
3. confirming the pattern of the LEDs matches the binary values changing in R4
4. Verifying the values being stored in the registers 


Question 3: Angus Malcom
High-Level Information about code:

1. Allocate a buffer of space for string
2. Initialise the Board Clocks, Peripherals and UART configurations for Receive and Transmit pins and Button configuation
3. Wait until the user presses the button to continue further
4. First, append the STX to the first byte of the buffer
5. Copy the string into the third byte (leaving room for the message length byte)
6. Convert lowercase letters to uppercase and concatanate into buffer, while counting amount of letters in string
7. Add in message length into buffer
8. Append ETX onto end of message
9. Compute an XOR checksum of the message, using same method as discussed in Question 1
10. Transmit the message byte by byte through UART1 until transmit register is empty
11. Reply with an acknowledgement of message 

Instructions for user:
1. Load an ASCII string into tx_string
2. Set a buffer space into buffer to ensure the message has enough room for all bytes
3. Press the user button (PA0) to begin transmission
4. The message packet will be built into the buffer and transmitted over UART1 repeatedly
5. The structure of the finished message is: [STX - Message Length - String Body - ETX - Checksum]

Details about testing procedure:
1. Original ASCII string is stored in tx_string in the data section
2. The finished message is stored in the buffer, pointed to by R1
3. The structure of the finished message is: [STX - Message Length - String Body - ETX - Checksum]
4. Any lowercase letters in the source string are converted to uppercase during the copy into the buffer
5. The checksum is computed by XORing all bytes in the buffer from STX through to ETX
6. The message is transmitted byte by byte over UART1, verified by checking the TXE flag before each send
7. After transmission completes, the function returns and is called again in a loop, continuously retransmitting the same packet

Question 4: Chelsea Satriavi

High-Level Information about code:

**Basic Delay Polling**
1. Load the base address of TIM2
2. Reset the timer counter (TIM_CNT) to 0
3. Enable the timer by setting the CEN bit in TIM_CR1
4. Set a large value in TIM_ARR to define the maximum count
5. Load a target delay value into a register
6. Continuously read TIM_CNT and compare it to the target value
7. Stay in a loop until the timer count reaches the target value
8. Exit the function once the required delay has elapsed

**Prescaler-Based Hardware Delay**
1. Load the base address of TIM2
2. Set the prescaler (TIM_PSC) to control the timer tick speed
3. Enable ARPE (Auto-Reload Preload Enable) in TIM_CR1
4. Set the auto-reload value (TIM_ARR) to define overflow period
5. Force an update event using TIM_EGR to apply prescaler and ARR values
6. Reset the timer counter (TIM_CNT) to 0
7. Clear the update interrupt flag (UIF) in TIM_SR
8. Start the timer by enabling CEN in TIM_CR1
9. Wait for the UIF flag in TIM_SR to become 1 (indicating overflow)
10. Clear UIF after each overflow
11. Repeat this process for a specified number of overflow periods
12. Exit the function once the required number of periods has elapsed

**Concurrent LED Blinking (Non-Blocking Timing)**
1. Load the base address of TIM2
2. Set the prescaler so the timer increments in microseconds
3. Force update event to apply prescaler settings
4. Reset TIM_CNT to 0
5. Start the timer by enabling CEN
6. Initialise GPIOE output register to turn LEDs off
7. Store toggle periods for LED1 and LED2 in registers
8. Initialise next toggle times for both LEDs to 0
9. Continuously read the current timer value (TIM_CNT)
10. Compare current time with LED1 next toggle time
11. If current time has reached the scheduled time:
    1) Toggle LED1 using XOR
    2) Update the next toggle time by adding the period
12. Repeat the same process for LED2 independently
13. Loop continuously so both LEDs toggle at different frequencies without blocking each other

Instructions for user:

Ensure TIM2 clock is enabled before running the program
**For basic delay:**
Use the timer, delay, and delay_loop functions
Adjust the delay length by modifying the target count value

**For prescaler-based delay:**
Call prescaler_prescaler and trigger_prescaler_prescaler
Then call delay_prescaler
Adjust delay duration by changing the number of overflow counts

**For LED blinking:**
Modify R4 to change LED1 frequency
Modify R5 to change LED2 frequency
Period values are in microseconds when prescaler is configured for 1 µs ticks
LEDs will toggle automatically based on the defined timing values

Details about testing procedure:
**For basic delay:**
Turn an LED on before calling the delay function
Turn it off after the delay completes
Verify that the LED stays on for the expected duration

**For prescaler-based delay:**
Use an LED to visually confirm delay length
Ensure that each overflow corresponds to the expected time interval
Confirm multiple overflows produce longer delays (e.g. 5 seconds)

**For concurrent LED blinking:**
Observe both LEDs running simultaneously
Confirm that each LED toggles at its own frequency
Change R4 and R5 values and verify behaviour updates correctly

Ensure LEDs do not interfere with each other, confirming independent timing
Verify timing accuracy by comparing expected periods with observed LED behaviour

Question 5: All
Tasks:
- Cameron: Create Transmitted Message
- Chelsea: Counter Logic
- Angus: Transmitting and Receiving Logic
- Elena: LED Logic

High-Level Information about code:
1. Initialise "Counter = " prefix with ASCII String Body and buffer length.
2. Count the length of the string, minus the digits counted: STX(1) + MsgLen(1) + Prefix(10) + ETX(1) + Checksum(1) = 14
3. Count the amount of digits in the counted total (1 for <10, 2 for 10-100, 3 for >100), and add to total length
4. Concatanate message in buffer with structure: [STX - Message Length - String Prefix - Count Value - ETX]
5. Perform a checksum of the message, same process as Question 1. Concatanate Checksum value onto message
6. 
Instructions for user:
Details about testing procedure:
