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
Question 2: Elena Zengovski

Question 3: Angus Malcom

Question 4: Chelsea Satriavi

Question 5: All
