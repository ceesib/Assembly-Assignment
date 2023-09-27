.data
    filePathIn:     .asciiz "C:\Users\ceejay sibeko\Downloads\house_64_in_ascii_crlf.ppm"
    filePathOut:    .asciiz "C:\Users\ceejay sibeko\Downloads\output.ppm"
    fileWords:      .space 1024
    buffer:         .space 1024
    buffer2:        .space 1024
    line:           .asciiz "\n"
    str1:           .asciiz "Average pixel value of the original image:\n"
    str2:           .asciiz "Average pixel value of new image:\n"
	ppm:			.asciiz "P3"
	size: 			.asciiz "64 64"
	comment: 		.asciiz "#Jet"
	max:			.asciiz "255"

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
    li $t7, 48
    li $t5, 10

    move $t6, $zero
    move $t0, $zero
    move $s5, $zero
    move $s6, $zero
    move $s7, $zero
    move $t8, $zero
    move $t3, $zero
    move $s2, $zero
    li $s3, 3133440

readLoop0:
    beq $t0, 4, readLoop1
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    li $a2, 1
    syscall

    beq $v0, $zero, close_files
    la $t4, fileWords
    lb $s4, 0($t4)

    beq $s4, 10, increment

    j readLoop0

increment:
    addi $t0, $t0, 1
    j readLoop0
readLoop1:
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
	
 j readLoop
readLoop:
    li $v0, 14
    move $a0, $s0
    la $a1, fileWords
    li $a2, 1
    syscall

    beqz $v0, close_files

    la $t4, fileWords
    lb $t1, 0($t4)

    beq $t1, 10, reset

    sub $t2, $t1, $t7
    mul $t6, $t6, $t5
    add $t6, $t6, $t2

    j readLoop

reset:
    la $t9, buffer
    add $s5, $s5, $t6
    addi $s7, $s7, 1

    addi $t6, $t6, 10
    bgt $t6, 255, fix
    add $s6, $s6, $t6

    move $s2, $t6

    j convert_int_to_str
fix:
    li $t6, 255
    add $s6, $s6, $t6
    move $s2, $t6
    j convert_int_to_str

convert_int_to_str:
    # Initialize variables
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
	addi $t9,$t9,-1
    # Copy the integer as a string to buffer2
    
    la $t5, buffer2
copy_loop:
    lb $t0, 0($t9)
	beqz $t0, options
    sb $t0, 0($t5)
    addi $t9, $t9, -1
    addi $t5, $t5, 1
   
    j copy_loop
options:
	beq $t2,2,print_buffer3
	beq $t3,3,print_buffer2
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
    li $v0, 16
    move $a0, $s0
    syscall

    li $v0, 16
    move $a0, $s1
    syscall

exit:
    li $v0, 10
    syscall
