.data
str1:    .asciiz "Average pixel value of the original image:\n"
str2:    .asciiz "Average pixel value of new image:\n"
fname:   .space 200
outname: .asciiz "output.ppm"
prompt:  .asciiz "Enter filename:\n"
buffer:  .space 1024

.text
.globl main

main:
    # Prompt the user to enter the input filename
    li $v0, 4
    la $a0, prompt
    syscall

    # Read the input filename from the user
    li $v0, 8
    la $a0, fname
    li $a1, 200
    syscall

    # Open the input file for reading
    li $v0, 13
    la $a0, fname
    li $a1, 0
    syscall

    # Check for errors while opening the input file (return value in $v0)
    bne $v0, open_failed  # Branch if $v0 is not 0 (error)

    # Read from the input file
    li $v0, 14
    move $a0, $v0
    la $a1, buffer
    li $a2, 3
    syscall

    # Check for errors while reading from the input file (return value in $v0)
    bne $v0,$zero,read_failed  # Branch if $v0 is not 0 (error)


    # Open the output file for writing
    li $v0, 15
    la $a0, outname
    li $a1, 1
    syscall

    # Check for errors while opening the output file (return value in $v0)
    bne $v0,$zero,write_failed  # Branch if $v0 is not 0 (error)

    # Write to the output file
    li $v0, 15
    move $a0, $v0
    la $a1, buffer
    li $a2, 1024
    syscall

    # Check for errors while writing to the output file (return value in $v0)
    bne $v0,$zero,write_failed  # Branch if $v0 is not 0 (error)

    # Close the input file
    li $v0, 16
    move $a0, $v0
    syscall

    # Close the output file
    li $v0, 16
    move $a0, $v0
    syscall

    # Exit program
    li $v0, 10
    syscall

open_failed:
    # Handle input file open error (e.g., print an error message)
    li $v0, 10
    syscall

read_failed:
    # Handle file read error (e.g., print an error message)
    li $v0, 10
    syscall

write_failed:
    # Handle file write error (e.g., print an error message)
    li $v0, 10
    syscall
