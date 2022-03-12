		.data	# .data directive lists pertinent data declaration information
		
input_prompt:	.asciiz "Enter an integer: "
even_max:	.asciiz "The even array is full!"
odd_max:	.asciiz "The odd array is full!"
output_even:	.asciiz "The even numbers entered: "
output_odd:	.asciiz "The odd numbers entered: "
		.align 2	# align array contents to word boundary, address alignment error otherwise
even_num:	.space	40
odd_num:	.space	40

		.text	# .text directive allows assembler to find beginning of program
		.globl main	# define main method as global variable
	
main:				# program runs starting from main method

		li $t0, 0	# initialize loop counter as 0 in register $t0
		li $t1, 0	# initialize even_num index as 0 in register $t1
		li $t2, 0	# initialize odd_num index as 0 in register $t2
		li $t3, 40	# initialize array upper bound as 10 in register $t3

loop:				# beginning of input loop
		
		li $v0, 4	# load system call code 4 into register $v0
		la $a0, input_prompt	# store address of input prompt in $a0
		syscall		# call kernel to print string at given address
		
		li $v0, 5	# load system call code 5 into register $v0
		syscall		# call kernel to read integer input
		move $s0, $v0	# move user input stored in $v0 to $t3
		beqz $s0, exit	# if integer stored in $s0 is zero, branch to exit
		
		li $t4, 2	# check if input is odd or even by division by 2
		div $t4, $s0, $t4	# divide value stored in $s0 by 2
		mfhi $t5	# move remainder to register $t5
		
store_even:	
		
		beq $t1, $t3, even_full	# branch to even_full if array is at max capacity
		bnez $t5, store_odd	# branch to store_odd if remainder is not zero
		sw $s0, even_num($t1)	# store num at byte index $t1 if even
		addi $t1, $t1, 4	# increment index by 4 bytes
		j continue		# jump to address at continue to
					# avoid incrementing odd index
					
even_full:
		
		li $v0, 4	# load system call code 4 into register $v0
		la $a0, even_max	# store address of even full message
		syscall		# call kernel to print string at given address
		j continue
		
store_odd:	
		
		beq $t2, $t3, odd_full	# branch to odd_full if array is at max capacity
		sw $s0, odd_num($t2)	# store num at byte index $t2 if odd
		addi $t2, $t2, 4	# increment index by 4 bytes
		j continue

odd_full:
		
		li $v0, 4	# load system call code 4 into register $v0
		la $a0, odd_max	# store address of odd full message
		syscall		# call kernel to print string at given address
		j continue
		
continue:		

		addi $t0, $t0, 1	# increment loop counter
		
		addi $a0, $0, 0xA 	# load 10 into address register (ASCII for line feed)
        	addi $v0, $0, 0xB 	# load system call code 11 into value register
       		syscall			# call kernel to print new line character
		
		j loop
		
		
		
exit:

		li $t0, 0		# load 0 into $t0 as index counter for iteration

printeven:

		li $v0, 4		# load system call code 4 into register $v0
		la $a0, output_even	# load address of even output message
		syscall			# call kernel to print string at given address
		
evenarr:	
		
		beq $t0, $t1, printodd	# branch to print odd array when $t1 (max even index) reached
		li $v0, 1		# load system call code 1 into register $v0
		lw $a0, even_num($t0)	# load address of value at index $t0 in even array
		syscall			# call kernel to print integer value
		addi $t0, $t0, 4	# increment iterator by 4 bytes to next index
		
		addi $a0, $0, 0x20	# load 32 into address register (ASCII for whitespace)
		addi $v0, $0, 0xB	# load system call code 11 into value register
		syscall			# call kernel to print whitespace character
		
		j evenarr		# loop to iterate through array
		
printodd:		

		li $t0, 0		# reset index iterator
		
		addi $a0, $0, 0xA 	# load 10 into address register (ASCII for line feed)
        	addi $v0, $0, 0xB	# load system call code 11 into value register
       		syscall			# call kernel to print new line character
       				
		li $v0, 4		# load system call code 4 into register $v0
		la $a0, output_odd	# store address of odd output message
		syscall			# call kernel to print string at given address
		
oddarr:		

		beq $t0, $t2, terminate	# branch to terminate program when $t2 (max odd index) reached
		li $v0, 1		# load system call code 1 into register $v0
		lw $a0, odd_num($t0)	# load address of value at index $t0 in odd array
		syscall			# call kernel to print integer value
		addi $t0, $t0, 4	# increment iterator by 4 bytes to next index
		
		addi $a0, $0, 0x20	# load 32 into address register (ASCII for whitespace)
		addi $v0, $0, 0xB	# load system call code 11 into value register
		syscall			# call kernel to print whitespace character
		
		j oddarr		# loop to iterate through array 

terminate:						
		
		li $v0, 10	# load system call code 10 into value register
		syscall		# call kernel to terminate program
		
