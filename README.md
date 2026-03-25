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
High-Level Information about code:
Instructions for user:
Details about testing procedure:

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
Details about testing procedure:

Question 4: Chelsea Satriavi
High-Level Information about code:
Instructions for user:
Details about testing procedure:

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
