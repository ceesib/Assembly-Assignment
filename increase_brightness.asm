.data
	filePathIn:	.asciiz "C:\Users\ceejay sibeko\Downloads\house_64_in_ascii_crlf.ppm"
	filePathOut:	.asciiz "C:\Users\ceejay sibeko\Downloads\output.txt"
	fileWords:	.space 1024
    buffer:        .space 1024
    line:   .asciiz "\n"
	str1: .asciiz "Average pixel value of the original image:\n"
	str2: .asciiz "Average pixel value of new image:\n"
	format_float: .asciiz "%.2f\n"
.text
.globl main
main:
	
	#Open file 
	li $v0, 13
	la $a0, filePathIn
	li $a1,0
	syscall
	move $s0, $v0	

    #Open file to write
    li $v0, 13
    la $a0, filePathOut
    li $a1, 1
    li $a2, 0
    syscall
    move $s1, $v0
	li $t7, 48
    li $t5, 10      #The value to add so help create string int
	#li $t3, 0		#line counter

    move $t6, $zero 
	move $t0,$zero
	move $s5,$zero
	move $s6,$zero
	move $s7,$zero
	readLoop0:
		beq $t0,4,readLoop
		li $v0, 14
		move $a0, $s0
		la $a1, fileWords
		li $a2, 1
		syscall
		
		beq $v0,$zero, close_files
		la $t4, fileWords
		lb $s4,0($t4)
		
		beq $s4,10, increment
		  
	j readLoop0
	increment:
	addi $t0,$t0,1
	j readLoop0
	readLoop:
		li $v0, 14
		move $a0, $s0
		la $a1, fileWords
		li $a2, 1
		syscall

		beq $v0,$zero, close_files
			
		la $t4, fileWords
        lb $t1, 0($t4)          #Value is ASCII
        beq $t1, 10, reset      #When we reach end of the line we set t6=0

        sub $t2, $t1, $t7      
        mul $t6, $t6, $t5
        add $t6, $t6, $t2
 
        j   readLoop
	

	reset:  

        #Write it to file
        jal write

        sb $t6, buffer
        la $t3, buffer
        lb $s3, 0($t3)
        #Write to files
		li $v0, 15
		move $a0, $s1
        la $a1, buffer
        li $a2, 1
		syscall

        #reset
        li $t6, 0
        
        j   readLoop
	

    write:
		
		add  $s5,$s5,$t6
		addi $s7,$s7,1
		
		addi $t6,$t6,10
		add $s6,$s6,$t6
		
		bgt $t6,255,fix
        #print to screen for now
        li $v0, 1
        move $a0, $t6
        syscall

        #new Line
        li $v0, 4
        la $a0, line
        syscall
    jr $ra
	
	fix:
	li $t6,255
	#print to screen for now
        li $v0, 1
        move $a0, $t6
        syscall

        #new Line
        li $v0, 4
        la $a0, line
        syscall
	jr $ra

	close_files:	#Close file
		#div $s5,$s7
		#div $s6,$s7
		li $v0, 16
		move $a0, $s0
		syscall

		li $v0, 16
		move $a0, $s1
		syscall
		


exit:
	li $v0,4
	la $a0,str1
	syscall
	#li $v0,2
	#move.s $f12,$t8
	#la $a0,format_float
	#syscall
	li $v0,4
	la $a0,str2
	syscall
	#li $v0,2
	#move.s $f12,$t9
	#la $a0,format_float
	#syscall
	li $v0,	10
	syscall
