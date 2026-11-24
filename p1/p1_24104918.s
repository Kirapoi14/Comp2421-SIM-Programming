# 
# Readme
#
# How to run: Read the input which is a positive integer from the user, then print out the binary,
#           quaternary, and octal representations of the corresponding number, and loop until the user
#           chooses to exit.
#
# Design:
#   - Uses system calls for console I/O.
#   - Binary conversion: extracts each bit from bit 31 to bit 0 and stores '0' or '1' in a buffer.
#   - Quaternary conversion: each quaternary digit corresponds to 2 bits;
#     		processes 16 digits from bit 15 to bit 0
#   - Octal conversion: each octal digit corresponds to 3 bits; processes 11 digits from bit 10 to bit 0
#   - Main loop asks for continuation.
#
# Notes:
#   - Assumes input is a positive integer.
#   - Run on QtSpim with branch delay slots ignored.

	.data
prompt: 	.asciiz "Enter a number: "
input: 		.asciiz "Input number is "
binary: 		.asciiz "\nBinary: "
quaternary: .asciiz "\nQuaternary: "
octal: 		.asciiz "\nOctal: "
continue: 	.asciiz "\nContinue? (1=Yes/0=No) "
bye: 		.asciiz "\nBye!\n"

# Conversion result buffers
bi_buffer: 		.space 33
quat_buffer: 	.space 17
oct_buffer: 		.space 12

	.text
	.globl main

main:
	# Main loop: read the input, print out in different number systems, and ask to continue
loop:
	# Prompt for input
   	li      $v0, 4
    	la     $a0, prompt
    	syscall

	# Read integer
    	li      $v0, 5
    	syscall
    	move    $t0, $v0

	# Print "Input number is "
    	li      $v0, 4
    	la     $a0, input
    	syscall
    	
	# Print the number itself (decimal)
    	li      $v0, 1
    	move    $a0, $t0
    	syscall

	# Print out its binary form
    	la      $a1, bi_buffer
    	jal     trans_binary
    	li       $v0, 4
    	la      $a0, binary
    	syscall
   	li      $v0, 4
    	la     $a0, bi_buffer
    	syscall

	# Print out its quaternary form
    	la      $a1, quat_buffer
    	jal     trans_quaternary
    	li       $v0, 4
    	la      $a0, quaternary
    	syscall
   	li      $v0, 4
    	la     $a0, quat_buffer
    	syscall

	# Print out its octal form
    	la      $a1, oct_buffer
    	jal     trans_octal
    	li       $v0, 4
    	la      $a0, octal
    	syscall
   	li      $v0, 4
    	la     $a0, oct_buffer
    	syscall

	# Ask to continue
    	li      $v0, 4
    	la     $a0, continue
    	syscall
    	li      $v0, 5
    	syscall
    	beq     $v0, 1, loop

	# Exit program
    	li      $v0, 4
    	la     $a0, bye
    	syscall
    	li      $v0, 10
    	syscall   

# Trans_binary
trans_binary:
	li      $t1, 31				# Start from bit 31
    	move    $t2, $a1			# $t2 points to current buffer position
bi_loop:
	srlv    $t3, $t0, $t1
	andi   $t3, $t3, 1			# Leave the last bit
	addi    $t3, $t3, '0'		# Transfer to ASCII code
    	sb      $t3, 0($t2)			# Store in buffer
	addiu   $t2, $t2, 1		# Move the pointer forward
	addi    $t1, $t1, -1		# Decrement 1 bit index
	bgez   $t1, bi_loop
	sb      $0, 0($t2)
	jr       $ra

#Trans_quaternary
trans_quaternary:
    	li      $t1, 15
    	move    $t2, $a1
quat_loop:
	sll     $t3, $t1, 1			# Shift bits =  16 digits * 2
	srlv    $t4, $t0, $t3		# Bits per right shift = 2
	andi    $t4, $t4, 3	
    	addi    $t4, $t4, '0'
    	sb      $t4, 0($t2)
    	addiu   $t2, $t2, 1
    	addi     $t1, $t1, -1
    	bgez    $t1, quat_loop
    	sb      $0, 0($t2)
    	jr      $ra

#Trans_octal
trans_octal:
    	li      $t1, 10
    	move    $t2, $a1
oct_loop:
	sll     $t3, $t1, 1
	add    $t3, $t3, $t1
	srlv    $t4, $t0, $t3
	andi    $t4, $t4, 7
    	addi    $t4, $t4, '0'
    	sb      $t4, 0($t2)
    	addiu   $t2, $t2, 1
    	addi     $t1, $t1, -1
    	bgez    $t1, oct_loop
    	sb      $0, 0($t2)
    	jr      $ra