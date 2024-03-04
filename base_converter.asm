#####################################################################
# Programmer: Jacob St Lawrence
# Last Modified: 04.28.2023
#####################################################################
# Functional Description:
# This program prompts the user to select whether they want to
# enter a decimal, binary, or hex value, then prompts them to
# enter a value in the selected base. It then converts the value
# to the other two bases and displays the results.
#####################################################################
# Pseudocode:
# main:
#	print selection prompt
#	case 0; exit
#	case 1; decimal input
#	case 2; binary input
#	case 3; hex input
# decimal input:
#	prompt for int
#	cin >> int
#	if not 0 <= int <= 999; error
#	b	decimal to binary
# binary input:
#	prompt for string
#	cin >> binary
#	b	binary to decimal
# hex input:
#	prompt for string
#	cin >> hex
#	b	hex to decimal
# decimal to binary:
#	s2 = pointer to binary
#	do
#	{t2 = int % 2
#	t0 = int / 2
#	t2 += 48
#	(s2) = t2
#	s2 ++}
#	while t0 > 1
#	t0 += 48
#	(s2) = t0
# reverse binary:
#	do
#	{s3 = pointer to binary
#	swap s2 and s3
#	s3 ++; s2 --}
#	while s3 < s2
# 	if int input, branch to decimal to hex
# 	else branch to results
# decimal to hex:
#	s4 = pointer to hex
#	do
# 	{t0 = int / 16
#	t2 = int % 16
#	(s4) = hexValues offset by t2
#	s4 ++}
#	while t0 > 15
#	(s4) = hexValues offset by t0
#	swap first and last character
# 	branch to results
# binary to decimal:
#	s2 = pointer to binary
# binary loop:
#	if (s2) != 0 or 1, error
#	if (s2) == terminating char, done1
#	(s2) -= 48
#	int = (int * 2) + (s2)
#	s2 ++
#	b	binary loop
# done1:
#	if binary input, branch to decimal to hex
#	else branch to results
# hex to decimal:
#	s4 = pointer to hex
# hex loop:
#	if (s4) == terminating char, done2
#	(s4) -= 48
#	if (s4) > 9, check upper letter
#	int = (int * 4) + (s4)
#	s4 ++
#	b	hex loop
# Upper Check:
#	(s4) -= 7
#	if (s4) > 15, check lower letter
#	int = (int * 4) + (s4)
#	s4 ++
#	b	hex loop
# Lower Check:
#	(s4) -= 32
#	int = (int * 4) + (s4)
#	s4 ++
#	b	hexloop
# done2:
#	if hex input, branch to decimal to binary
#	else branch to results
# results:
#	display formatted results
#	b	main
# exit:
#	terminate program
#####################################################################
# Register Usage:
# $s0: Base Selection
# $s1: Integer Value
# $s2: Binary Pointer 1
# $s3: Binary Pointer 2
# $s4: Hex Pointer 1
# $s5: Hex Pointer 2
# $s6: Hex Values Pointer
#####################################################################

	.data
menu:		.asciiz	"\n\nMENU:\n1. Decimal\n2. Binary\n3. Hexadecimal\n0. EXIT\n"
basePrompt:	.asciiz	"Please enter the number for your choice from the options above: "
error1:		.asciiz	"\nInvalid selection. Please choose from the options provided.\n\n"
numPrompt:	.asciiz	"Please enter a 3-digit value in your selected base: "
error2	:	.asciiz	"\nInvalid number entered. Please try again."
hexValues:	.asciiz	"0123456789ABCDEF"
outOriginal:	.asciiz	"\n----Original Value----"
outConvert:	.asciiz	"\n\n---Converted Values---"
decOut:		.asciiz	"\nDecimal: "
binOut:		.asciiz	"\nBinary: "
hexOut:		.asciiz	"\nHexadecimal: "
bye:		.asciiz	"\nGoodbye!"
binary:		.space	11
hexadecimal:	.space	4

	.text
main:
	li	$v0, 4			# syscall call code to print string
	la	$a0, menu		# load address of menu into argument
	syscall				# print menu

	li	$v0, 4			# system call code to print string
	la	$a0, basePrompt		# load address of basePrompt into argument
	syscall				# print basePrompt

	li	$v0, 5			# system call code to read integer
	syscall				# read integer input
	move	$s0, $v0		# move integer input into s0

	beqz	$s0, exit		# if selection 0, branch to exit program
	blt	$s0, 0, selError	# if selection less than 0, branch to display error
	bgt	$s0, 3, selError	# if selection greater than 3, branch to display error

	li	$v0, 4			# system call code to print string
	la	$a0, numPrompt		# load address of numPrompt into argument
	syscall				# print numPrompt

	beq	$s0, 1, inDecimal	# if selection 1, branch to read in decimal input
	beq	$s0, 2, inBinary	# if selection 2, branch to read in binary input
	beq	$s0, 3, inHex		# if selection 3, branch to read in hex input

inDecimal:
	li	$v0, 5			# system call code to read integer
	syscall				# read integer input
	move	$s1, $v0		# move integer input to s1

	bgt	$s1, 999, numError	# if value is more than 3 digits, branch to display error
	blt	$s1, 0, numError	# if value is negative, branch to display error
	b	decimal_binary		# branch to convert decimal to binary

inBinary:
	li	$v0, 8			# system call code to read string
	la	$a0, binary		# load address of binary string to read into
	la	$a1, 11			# load max size of string
	syscall				# read input string into binary string

	b	binary_decimal		# branch to convert binary to decimal

inHex:
	li	$v0, 8			# system call code to read string
	la	$a0, hexadecimal	# load address of hexadecimal string to read into
	la	$a1, 4			# load max size of string
	syscall				# read input string into hexadecimal string

	b	hex_decimal		# branch to convert hex to decimal

decimal_binary:
	move	$t0, $s1		# move integer value into t0
	addi	$t1, $zero, 2		# load value of 2 into t1
	la	$s2, binary		# make s2 pointer to binary string
loopBinary:
	div	$t0, $t1		# divide integer value by 2
	mflo	$t0			# move quotient into t0
	mfhi	$t2			# move remainder into t2
	addi	$t2, $t2, 48		# add 48 to remainder to get ascii equivalent
	sb	$t2, 0($s2)		# store remainder in byte at binary pointer
	addi	$s2, $s2, 1		# increment revBinary pointer
	blt	$t0, $t1, exitLoopBin	# if quotient is less than 2, exit loopBin

	b	loopBinary		# branch to loopBin for next iteration
exitLoopBin:
	addi	$t0, $t0, 48		# add 48 to quotient to get ascii equivalent
	sb	$t0, 0($s2)		# store quotient in byte at binary pointer
	la	$s3, binary		# make s3 pointer to beginnning of binary string
binaryReverse:
	lb	$t1, 0($s3)		# load byte from address of beginning binary pointer
	lb	$t2, 0($s2)		# load byte from address of end binary pointer
	sb	$t1, 0($s2)		# store byte from beginning of string to end of string
	sb	$t2, 0($s3)		# store byte from end of string to beginning of string

	addi	$s3, $s3, 1		# increment beginning pointer
	subi	$s2, $s2, 1		# decrement end pointer

	ble	$s2, $s3, revBinDone	# if end pointer meets or crosses beginning pointer, done
	b	binaryReverse		# branch to binaryReverse for next iteration
revBinDone:
	beq	$s0, 1, decimal_hex	# if selection 1, branch to convert decimal to hex
	beq	$s0, 3, results		# if selection 3, branch to display results

decimal_hex:
	move	$t0, $s1		# move integer value into t0
	la	$s4, hexadecimal	# make s4 pointer to hexadecimal string
	addi	$t1, $zero, 16		# load value of 16 into t1
loopHex:
	div	$t0, $t1		# divide input integer by 16
	mflo	$t0			# move quotient into t0
	mfhi	$t2			# move remainder into t2

	lb	$t3, hexValues($t2)	# load byte from hexValues string offset by remainder
	sb	$t3, 0($s4)		# store byte from hexValues into address of hex pointer

	addi	$s4, $s4, 1		# increment hex pointer

	blt	$t0, $t1, exitLoopHex	# if quotient is less than 16, exit loopHex
	b	loopHex			# branch to loopHex for next iteration
exitLoopHex:
	lb	$t3, hexValues($t0)	# load byte from hexValues string offset by quotient
	sb	$t3, 0($s4)		# store byte from hexValues into address of hex pointer
	la	$s5, hexadecimal	# make s5 pointer to beginning of hexadecimal

	lb	$t1, 0($s5)		# load byte from address of beginning hex pointer
	lb	$t2, 0($s4)		# load byte from address of end hex pointer
	sb	$t1, 0($s4)		# store byte from beginning of string in end of string
	sb	$t2, 0($s5)		# store byte from end of string in beginning of string

	b	results			# branch to display results

binary_decimal:
	addi	$s1, $zero, 0		# load value 0 into s1
	la	$s2, binary		# make s2 pointer to binary string
loopBinDec:
	lb	$t0, 0($s2)		# load byte from address of pointer into t0
	beq	$t0, '\n', endLoopBD	# if byte is newline character, end loop
	beqz	$t0, endLoopBD		# if byte is terminating character, end loop
	bgt	$t0, '1', numError	# if character is greater than '1', branch to display error
	blt	$t0, '0', numError	# if character is less than '0', branch to display error

	subi	$t0, $t0, 48		# subtract 48 from character to get integer equivalent
	sll	$s1, $s1, 1		# multiply integer value by 2
	add	$s1, $s1, $t0		# add the byte to the integer value
	addi	$s2, $s2, 1		# increment binary pointer

	b	loopBinDec		# branch to loopBinDec for next iteration
endLoopBD:
	bgt	$s1, 999, numError	# if integer value is more than 3 digits, branch to display error
	beq	$s0, 2, decimal_hex	# if selection 2, branch to convert decimal to hex
	b	results			# else branch to display results

hex_decimal:
	addi	$s1, $zero, 0		# load value 0 into s1
	la	$s4, hexadecimal	# make s4 pointer to hexadecimal string
loopHexDec:
	lb	$t0, 0($s4)		# load byte from address of hex pointer to t0
	beq	$t0, '\n', endLoopHD	# if byte is newline character, end loopHexDec
	beqz	$t0, endLoopHD		# if byte is terminating character, end loopHexDec

	subi	$t0, $t0, 48		# subtract 48 from character to get integer equivalent if numeric character

	bgtu 	$t0, 9, letterCharUC	# if byte is greater than 9, branch to check for upper case letter character
	sll	$s1, $s1, 4		# multiply integer value by 16
	add	$s1, $s1, $t0		# add value to the integer register
	addi	$s4, $s4, 1		# increment hex pointer

	b	loopHexDec		# branch to loopHexDec for next iteration
letterCharUC:
	subi	$t0, $t0, 7		# subtract 7 more from character to get integer equivalent if upper case letter character

	blt	$t0, 10, numError	# if result is less than 10, branch to display error
	bgtu	$t0, 15, letterCharLC	# if result is greater than 15, branch to check for lower case letter character
	sll	$s1, $s1, 4		# multiply the integer value by 16
	add	$s1, $s1, $t0		# add value to the integer register
	addi	$s4, $s4, 1		# increment hex pointer
	b	loopHexDec		# branch to loopHexDec for next iteration
letterCharLC:
	subi	$t0, $t0, 32		# subtract 32 more from character to get integer equivalent if lower case letter character

	blt	$t0, 10, numError	# if result is less than 0, branch to display error
	bgt	$t0, 15, numError	# if result is still greater than 15, branch to display error
	sll	$s1, $s1, 4		# multiply the integer value by 16
	add	$s1, $s1, $t0		# add value to the integer register
	addi	$s4, $s4, 1		# increment hex pointer
	b	loopHexDec		# branch to loopHexDec for next iteration
endLoopHD:
	bgt	$s1, 999, numError	# if integer value is more than 3 digits, branch to display error
	blt	$s1, 0, numError	# if integer value is less than 0, branch to display error
	beq	$s0, 3, decimal_binary	# if selection 3, branch to convert decimal to binary
	b	results			# else branch to display results

selError:
	li	$v0, 4			# system call code to print string
	la	$a0, error1		# load address of error1 into argument
	syscall				# print error1

	b	main			# branch to main to try again

numError:
	li	$v0, 4			# system call code to print string
	la	$a0, error2		# load address of error2 into argument
	syscall				# print error2

	b	main			# branch to main to try again

results:
	li	$v0, 4			# system call code to print string
	la	$a0, outOriginal	# load address of outOriginal into argument
	syscall				# print outOriginal

	beq	$s0, 2, binResults	# if selection 2, branch to display results of binary input
	beq	$s0, 3, hexResults	# if selection 3, branch to display results of hex input
					# else it was decimal input
	li	$v0, 4			# system call code to print string
	la	$a0, decOut		# load address of decOut into argument
	syscall				# print decOut

	li	$v0, 1			# system call code to print integer
	move	$a0, $s1		# move integer value into argument
	syscall				# print integer value

	li	$v0, 4			# system call code to print string
	la	$a0, outConvert		# load address of outConvert to argument to print
	syscall				# print outConvert

	li	$v0, 4			# system call code to print string
	la	$a0, binOut		# load address of binOut to argument to print
	syscall				# print binOut

	li	$v0, 4			# system call code to print string
	la	$a0, binary		# load address of binary to argument to print
	syscall 			# print binary

	li	$v0, 4			# system call code to print string
	la	$a0, hexOut		# load address of hexOut to argument to print
	syscall				# print hexOut

	li	$v0, 4			# system call code to print string
	la	$a0, hexadecimal	# load address of hexadecimal to argument to print
	syscall				# print hexadecimal

	b	main			# branch to main for menu

binResults:
	li	$v0, 4			# system call code to print string
	la	$a0, binOut		# load address of binOut to argument to print
	syscall				# print binOut

	li	$v0, 4			# system call code to print string
	la	$a0, binary		# load address of binary to argument to print
	syscall				# print binary

	li	$v0, 4			# system call code to print string
	la	$a0, outConvert		# load address of outConvert to argument to print
	syscall				# print outConvert

	li	$v0, 4			# system call code to print string
	la	$a0, decOut		# load address of decOut to argument to print
	syscall				# print decOut

	li	$v0, 1			# system call code to print integer
	move	$a0, $s1		# move integer value into argument
	syscall				# print integer value

	li	$v0, 4			# system call code to print string
	la	$a0, hexOut		# load address of hexOut to argument to print
	syscall				# print hexOut

	li	$v0, 4			# system call code to print string
	la	$a0, hexadecimal	# load address of hexadecimal to argument to print
	syscall				# print hexadecimal

	b	main			# branch to main for menu

hexResults:
	li	$v0, 4			# system call code to print string
	la	$a0, hexOut		# load address of hexOut to argument to print
	syscall				# print hexOut

	li	$v0, 4			# system call code to print string
	la	$a0, hexadecimal	# load address of hexadecimal to argument to print
	syscall				# print hexadecimal

	li	$v0, 4			# system call code to print string
	la	$a0, outConvert		# load address of outConvert to argument to print
	syscall

	li	$v0, 4			# system call code to print string
	la	$a0, decOut		# load address of decOut to argument to print
	syscall				# print decOut

	li	$v0, 1			# system call code to print integer
	move	$a0, $s1		# move integer value into argument
	syscall				# print integer value

	li	$v0, 4			# system call code to print string
	la	$a0, binOut		# load address of binOut to argument to print
	syscall				# print binOut

	li	$v0, 4			# system call code to print string
	la	$a0, binary		# load address of binary to argument to print
	syscall				# print binary

	b	main			# branch to main for menu

exit:
	li	$v0, 4			# system call code to print string
	la	$a0, bye		# load address of bye to argument to print
	syscall				# print bye

	li	$v0, 10			# system call code to terminate program
	syscall				# terminate program

					# END OF PROGRAM
