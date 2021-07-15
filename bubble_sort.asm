#----------BUBBLE SORT OF STRING VALUES READ FROM FILE----------------#
#----------Created-by-hozaslan@sabanciuniv.edu--5/23/2020-------------#
#--PLEASE CHANGE FILE DIRECTORY OF INPUT FILE IN .data TO GET OUTPUT--#
.data
fileName: 	.asciiz "D:/cs401/term_project/input.txt" # Input file path
writeFile:	.asciiz "D:/cs401/term_project/bubble_sort_out.txt" # Output file path
fileWords: 	.space 1024	
strings:	.space 1024
new_line:	.asciiz "\n"
	.text
	.globl main
main:
	li $v0, 13	 	#open file syscall code
	la $a0, fileName  	#geting the file name
	li $a1, 0		# file flag to read from file(0 flag = read)
	syscall
	move $s0, $v0
	
	li $v0, 14		#read file syscall code
	move $a0, $s0		#file descriptor
	la $a1, fileWords	#buffer to hold string value
	la $a2, 1024		#buffer length
	syscall
	la $s0, fileWords
	la $s3, strings
	li $t0, 0		#iterator for input buffer start at 0
	li $t1, 0		#iterator for string array set to 0
	li $t2, 0		#iterator for inner string creation set to 0
loop:
	
	add $s4, $s3, $t2	#$s4 = strings[k]
	add $s1, $s0, $t0	#$s1 = fileWords[i]
	lb $s2, 0($s1)
	beq $s2, $zero, exit
	beq $s2, 0x0A, new_element
	sb $s2, ($s4)
	add $t0, $t0, 1		#1 char(byte) per character
	add $t2, $t2, 1		#strings inside the strings[] array iterator
	j loop
	
new_element:
	
	add $t1, $t1, 10 		#at most 10 characters per string
	add $t2, $t1, 0
	add $t0, $t0, 1
	j loop
exit:	

	move $t1, $zero
	la $a0, strings
	addi $a1, $zero, 8
	jal sort
	
	move $t3, $zero	
print_loop:		
	beq $t3, 80, exit_print_loop
	li $v0, 4
	la $a0, strings($t3)
	syscall
	li $v0, 4
	la $a0, new_line
	syscall	
	add $t3, $t3, 10
	j print_loop
exit_print_loop:
	
	
	li $v0, 16		#close the input file
	move $a0, $s0
	syscall
	
	li $v0, 13		#create and open new file
	la $a0, writeFile
	li $a1, 1
	syscall
	move $s1, $v0
	move $t3, $zero
write_loop:
	beq, $t3, 80, write_loop_exit
	
	li $v0, 15		#write to file
	move $a0, $s1		#file descriptor
	la $a1, strings($t3)	#load current string element's adress to argument ( $a1 = array[i] ) 
	jal string_length 	#procedure for getting the current string's length
	la $a1, strings($t3)	#relaod the $a1 register to array[i] address ($a1 address changed in procedure call)
	la $a2, 0($t0)		#output of the procedure is used to define length of writing
	syscall
	
	la $v0, 15
	la $a1, new_line
	la $a2, 1
	syscall
	addi $t3, $t3, 10
	j write_loop
	
write_loop_exit:
	
	li $v0, 16		#close the write file
	move $a0, $s0
	syscall

	li  $v0, 10		# Done!
	syscall
#--------------------------------------------------------------#
	
swap:
	add $t3, $zero, 10		#our array has 10 bytes of character string in each index
	mul $t3, $t3, $a1
	add $t1, $a0, $t3		#$t1 = adress of array[i] --- first character of starting string
	move $s7, $zero			#increment value to get out of loop
swap_loop:	
	beq $s7, 10, exit_swap_loop
	lb $t0, ($t1)			#$t0 = value of array[i]
	lb $t2, 10($t1)			#$t2 = value of array[i+1]
	
	sb $t2, ($t1)			#value of array[i] = $t2
	sb $t0, 10($t1)			#value of array[i+1] = $t0
	add $t1, $t1, 1
	add $s7, $s7, 1
	j swap_loop
exit_swap_loop:	
	jr $ra				#return to calling routine
	
#--------------#

	
sort:
	addi $sp, $sp, -20		# allocate space for 5 registers
	sw $ra, 16($sp)	
	sw $s3, 12($sp)
	sw $s2, 8($sp)
	sw $s1, 4($sp)
	sw $s0, 0($sp)
	
	move $s2, $a0
	move $s3, $a1
	move $s0, $zero 		# i = 0 

first_loop:
	slt $t0, $s0, $s3 		# $t0 = 1 if $s0 is less than $s3
	beq $t0, $zero, second_exit	# if $t0 = 0 terminate the loop
	addi $s1, $s0, -1		# j = i-1
second_loop:
	slti $t0, $s1, 0		#if $s1 is less than 0 skip the loop
	bne $t0, $zero, first_exit
	add $t3, $zero, 10
	mul $t3, $t3, $s1
	add $t2, $s2, $t3
	move $s7, $zero

sort_loop:				#loop for sorting individual chars of string element in the string array
	beq $s7, 10, first_exit		#if all chars exhausted for the string element (10 char per string pre -defined) continue next string in array (do not need to swap)
	lb $t3, ($t2)			#load first string's char value
	lb $t4, 10($t2)			#load second string's char value
	#slt  $t0, $t4, $t3 		#t0 = 1 if t3 > t4
	sgt $t0, $t3, $t4		#t0 = 1 if t3 is greater than t4 (ASCII VALUES COMPARISON)
	beq $t0, 1, sort_loop_exit	#if char value is greater in the following, swap places of these strings
	sgt $t0, $t4, $t3
	beq $t0, 1, first_exit		# if the following value is greater, it is correctly ordered go to next iteration
	add $s7, $s7, 1			#incrementing counter and byte number
	add $t2, $t2, 1
	j sort_loop
sort_loop_exit:
	move $a0, $s2			# first swap parameter is old $a0 array
	move $a1, $s1			# second swap paramaeter is the current location of the swap element
	jal swap
	addi $s1, $s1, -1 		# j = j-1	
	j second_loop	
first_exit:
	addi $s0, $s0, 1		# i++
	j first_loop
second_exit:
	lw $s0, ($sp)
	lw $s1,4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	jr $ra				#return to calling routine	


string_length:
	#INPUTS:
	#a1 = adress of the given array
	#OUTPUT:
	#$t0 = length of string
	move $t0, $zero				# output length
string_length_loop:
	lb $t2, 0($a1)
	beq $t2, 10, string_length_loop_exit	#terminate when see newline character
	beqz $t2, string_length_loop_exit 	#terminate when see null character	
	add $t0, $t0, 1
	addi $a1, $a1, 1
	j string_length_loop
string_length_loop_exit:
	jr $ra
