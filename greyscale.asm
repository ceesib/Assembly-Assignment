.data
    filePathIn:     .asciiz "C:\Users\ceejay sibeko\Downloads\house_64_in_ascii_crlf.ppm" 	# Input file path
    filePathOut:    .asciiz "C:\Users\ceejay sibeko\Downloads\increase_brightness.ppm"		# Output file path
    fileWords:      .space 1024                                                            	# Buffer for reading from the input file
    buffer:         .space 1024                                                            	# Buffer for integer-to-string conversion
    buffer2:        .space 1024                                                            	# Buffer for storing converted integers
    line:           .asciiz "\n"                                                            # Newline character
    str1:           .asciiz "Average pixel value of the original image:\n"                  # String 1
    str2:           .asciiz "Average pixel value of new image:\n"                           # String 2
    ppm:            .asciiz "P3"                                                            # PPM format identifier
    size:           .asciiz "64 64"                                                         # Image dimensions
    comment:        .asciiz "#Jet"                                                          # Comment in the PPM header
    max:            .asciiz "255"                                                           # Maximum pixel value

.text
.globl main

main:
    # Open input file
    li $v0, 13
    la $a0, filePathIn
    li $a1, 0
    syscall
    move $s0, $v0

    # Open output file for writing
    li $v0, 13
    la $a0, filePathOut
    li $a1, 1
    li $a2, 0
    syscall
    move $s1, $v0

    # Initialize variables
    li $t7, 48         # ASCII code for '0'
    li $t5, 10         # Base 10
    move $t6, $zero    # Initialize temporary register
    move $t0, $zero    # Initialize loop counter
    move $s5, $zero    # Initialize sum of pixel values in original image
    move $s6, $zero    # Initialize sum of pixel values in new image
    move $s7, $zero    # Initialize count of pixels
    move $t8, $zero    # Temporary register
    move $t3, $zero    # Temporary register
    move $s2, $zero    # Temporary register
    li $s3, 3133440    # Constant value for divisor

readLoop0:
    beq $t0, 4, readLoop1  # If we have read the header lines, go to the next loop
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    li $a2, 1
    syscall

    beq $v0, $zero, close_files  # If the read operation fails, close the files
    la $t4, fileWords
    lb $s4, 0($t4)

    beq $s4, 10, increment  # If we encounter a newline character, increment and continue

    j readLoop0

increment:
    addi $t0, $t0, 1
    j readLoop0

readLoop1:
    # Read and ignore PPM header lines
    li $v0, 15
    move $a0, $s1
    la $a1, ppm
    li $a2, 2
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, comment
    li $a2, 4
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, size
    li $a2, 5
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall
	
	li $v0, 15
    move $a0, $s1
    la $a1, max
    li $a2, 3
    syscall
	
	li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall

    j readLoop  # Continue to the main reading loop

readLoop:
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    li $a2, 1
    syscall

    beqz $v0, close_files  # If we reach the end of the file, close the files

    la $t4, fileWords
    lb $t1, 0($t4)

    beq $t1, 10, reset  # If we encounter a newline character, reset and process the pixel value

    sub $t2, $t1, $t7  # Calculate the pixel value
    mul $t6, $t6, $t5
    add $t6, $t6, $t2

    j readLoop

reset:
    la $t9, buffer  # Load the buffer for integer-to-string conversion
    add $s5, $s5, $t6  # Add the pixel value to the sum

    addi $t6, $t6, 10
    bgt $t6, 255, fix  # If the pixel value is greater than 255, fix it
    add $s6, $s6, $t6

    move $s2, $t6  # Store the pixel value

    j convert_int_to_str

fix:
    li $t6, 255  # Set the pixel value to 255
    add $s6, $s6, $t6
    move $s2, $t6
    j convert_int_to_str

convert_int_to_str:
    # Initialize variables for integer-to-string conversion
    li $t1, 10         # Divisor (10 for base 10)
    li $t2, 0          # Initialize digit count

    # Handle the case when the input integer is 0
    beqz $t6, zero_case
    j convert_loop

zero_case:
    # Special case for input 0
    li $t3, '0'        # ASCII code for '0'
    sb $t3, 0($t9)     # Store '0' in the buffer
    addi $t2, $t2, 1   # Increment digit count
    addi $t9, $t9, 1   # Move buffer pointer
    j end_conversion

convert_loop:
    # Divide the integer by 10
    divu $t6, $t6, $t1
    mfhi $t3            # Remainder (ASCII digit)

    # Convert remainder to ASCII
    addi $t3, $t3, '0'  # Convert to ASCII character

    # Store ASCII digit in the buffer
    sb $t3, 0($t9)
    addi $t2, $t2, 1   # Increment digit count
    addi $t9, $t9, 1   # Move buffer pointer

    # Check if the quotient is 0 (end of conversion)
    beqz $t6, end_conversion

    j convert_loop

end_conversion:
    # Null-terminate the string
    sb $zero, 0($t9)
    addi $t9, $t9, -1  # Adjust buffer pointer

    # Copy the integer as a string to buffer2
    la $t5, buffer2
copy_loop:
    lb $t0, 0($t9)
    beqz $t0, options  # If we've copied the entire string, proceed to options

    sb $t0, 0($t5)
    addi $t9, $t9, -1
    addi $t5, $t5, 1

    j copy_loop

options:
    beq $t2, 2, print_buffer3  # If the digit count is 2, print buffer3
    beq $t2, 3, print_buffer2  # If the digit count is 3, print buffer2

print_buffer2:
    # Write the integer-as-a-string to the output file
    li $v0, 15
    move $a0, $s1
    la $a1, buffer2
    li $a2, 3
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall

    li $t7, 48
    li $t5, 10

    move $t6, $zero
    move $t0, $zero
    move $t2, $zero
    move $t8, $zero
    move $t3, $zero
    move $s2, $zero

    j readLoop

print_buffer3:
    # Write the integer-as-a-string to the output file
    li $v0, 15
    move $a0, $s1
    la $a1, buffer2
    li $a2, 2
    syscall

    li $v0, 15
    move $a0, $s1
    la $a1, line
    li $a2, 1
    syscall

    li $t7, 48
    li $t5, 10

    move $t6, $zero
    move $t0, $zero
    move $t2, $zero
    move $t8, $zero
    move $t3, $zero
    move $s2, $zero

    j readLoop

close_files:
    mtc1.d $s5, $f4       # Move sum of pixel values in original image to $f4
    cvt.d.w $f4, $f4    # Convert integer to float in $f4
    mtc1.d $s6, $f6       # Move sum of pixel values in new image to $f6
    cvt.d.w $f6, $f6    # Convert integer to float in $f6
    mtc1.d $s3, $f2       # Move constant divisor to $f2
    cvt.d.w $f2, $f2    # Convert integer to float in $f2
    div.d $f0, $f4, $f2 # Calculate average pixel value of original image
    div.d $f8, $f6, $f2 # Calculate average pixel value of new image

    li $v0, 16
    move $a0, $s0
    syscall

    li $v0, 16
    move $a0, $s1
    syscall

exit:
    li $v0, 4
    la $a0, str1
    syscall

    li $v0, 3
    mov.d $f12, $f0
    syscall

    li $v0, 4
    la $a0, line
    syscall

    li $v0, 4
    la $a0, str2
    syscall

    li $v0, 3
    mov.d $f12, $f8
    syscall

    li $v0, 10
    syscall
