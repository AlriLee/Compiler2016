	.text
# _buffer_init:
# 	li $a0, 256
# 	li $v0, 9
# 	syscall
# 	sw $v0, _buffer
# 	jr $ra

# copy the string in $a0 to buffer in $a1, with putting '\0' in the end of the buffer
###### Checked ######
# used $v0, $a0, $a1
_string_copy:
	_begin_string_copy:
	lb $v0, 0($a0)
	beqz $v0, _exit_string_copy
	sb $v0, 0($a1)
	add $a0, $a0, 1
	add $a1, $a1, 1
	j _begin_string_copy
	_exit_string_copy:
	sb $zero, 0($a1)
	jr $ra

# string arg in $a0
###### Checked ######
# Change(5/4): you don't need to preserve reg before calling it
func__print:
	li $v0, 4
	syscall
	jr $ra

# string arg in $a0
###### Checked ######
# Change(5/4): you don't need to preserve reg before calling it
func__println:
	li $v0, 4
	syscall
	la $a0, _end
	syscall
	jr $ra

# count the length of given string in $a0
###### Checked ######
# used $v0, $v1, $a0
_count_string_length:
	move $v0, $a0

	_begin_count_string_length:
	lb $v1, 0($a0)
	beqz $v1, _exit_count_string_length
	add $a0, $a0, 1
	j _begin_count_string_length

	_exit_count_string_length:
	sub $v0, $a0, $v0
	jr $ra

# non arg, string in $v0
###### Checked ######
# used $a0, $a1, $t0, $v0, (used in _count_string_length) $v1
func__getString:
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	la $a0, _buffer
	li $a1, 255
	li $v0, 8
	syscall

	jal _count_string_length

	move $a1, $v0			# now $a1 contains the length of the string
	add $a0, $v0, 5			# total required space = length + 1('\0') + 1 word(record the length of the string)
	li $v0, 9
	syscall
	sw $a1, 0($v0)
	add $v0, $v0, 4
	la $a0, _buffer
	move $a1, $v0
	move $t0, $v0
	jal _string_copy
	move $v0, $t0

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

# non arg, int in $v0
###### Checked ######
# Change(5/4): you don't need to preserve reg before calling it
func__getInt:
	li $v0, 5
	syscall
	jr $ra

# int arg in $a0
###### Checked ######
# Bug fixed(5/2): when the arg is a neg number
# Change(5/4): use less regs, you don't need to preserve reg before calling it
# used $v0, $v1
func__toString:
	subu $sp, $sp, 24
	sw $a0, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)
	sw $t3, 16($sp)
	sw $t5, 20($sp)

	# first count the #digits
	li $t0, 0			# $t0 = 0 if the number is a negnum
	bgez $a0, _skip_set_less_than_zero
	li $t0, 1			# now $t0 must be 1
	neg $a0, $a0
	_skip_set_less_than_zero:
	beqz $a0, _set_zero

	li $t1, 0			# the #digits is in $t1
	move $t2, $a0
	move $t3, $a0
	li $t5, 10

	_begin_count_digit:
	div $t2, $t5
	mflo $v0			# get the quotient
	mfhi $v1			# get the remainder
	bgtz $v0 _not_yet
	bgtz $v1 _not_yet
	j _yet
	_not_yet:
	add $t1, $t1, 1
	move $t2, $v0
	j _begin_count_digit

	_yet:
	beqz $t0, _skip_reserve_neg
	add $t1, $t1, 1
	_skip_reserve_neg:
	add $a0, $t1, 5
	li $v0, 9
	syscall
	sw $t1, 0($v0)
	add $v0, $v0, 4
	add $t1, $t1, $v0
	sb $zero, 0($t1)
	sub $t1, $t1, 1

	_continue_toString:
	div $t3, $t5
	mfhi $v1
	add $v1, $v1, 48	# in ascii 48 = '0'
	sb $v1, 0($t1)
	sub $t1, $t1, 1
	mflo $t3
	# bge $t1, $v0, _continue_toString
	bnez $t3, _continue_toString

	beqz $t0, _skip_place_neg
	li $v1, 45
	sb $v1, 0($t1)
	_skip_place_neg:
	# lw $ra, 0($sp)
	# addu $sp, $sp, 4

	lw $a0, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t5, 20($sp)

	addu $sp, $sp, 24
	jr $ra

	_set_zero:
	li $a0, 6
	li $v0, 9
	syscall
	li $a0, 1
	sw $a0, 0($v0)
	add $v0, $v0, 4
	li $a0, 48
	sb $a0, 0($v0)

	lw $a0, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	lw $t3, 16($sp)
	lw $t5, 20($sp)

	addu $sp, $sp, 24
	jr $ra


# string arg in $a0
# the zero in the end of the string will not be counted
###### Checked ######
# you don't need to preserve reg before calling it
func__length:
	lw $v0, -4($a0)
	jr $ra

# string arg in $a0, left in $a1, right in $a2
###### Checked ######
# used $a0, $a1, $t0, $t1, $t2, $v1, $v0
func__substring:
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	move $t0, $a0

	sub $t1, $a2, $a1
	add $t1, $t1, 1		# $t1 is the length of the substring
	add $a0, $t1, 5
	li $v0, 9
	syscall
	sw $t1, 0($v0)
	add $v1, $v0, 4

	add $a0, $t0, $a1
	add $t2, $t0, $a2
	lb $t1, 1($t2)		# store the ori_begin + right + 1 char in $t1
	sb $zero, 1($t2)	# change it to 0 for the convenience of copying
	move $a1, $v1
	jal _string_copy
	move $v0, $v1
	sb $t1, 1($t2)

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

# string arg in
###### Checked ######
# 16/5/4 Fixed a serious bug: can not parse negtive number
# used $v0, $v1
func__parseInt:
	subu $sp, $sp, 16
	sw $a0, 0($sp)
	sw $t0, 4($sp)
	sw $t1, 8($sp)
	sw $t2, 12($sp)

	li $v0, 0

	lb $t1, 0($a0)
	li $t2, 45
	bne $t1, $t2, _skip_parse_neg
	li $t1, 1			#if there is a '-' sign, $t1 = 1
	add $a0, $a0, 1
	j _skip_set_t1_zero

	_skip_parse_neg:
	li $t1, 0
	_skip_set_t1_zero:
	move $t0, $a0
	li $t2, 1

	_count_number_pos:
	lb $v1, 0($t0)
	bgt $v1, 57, _begin_parse_int
	blt $v1, 48, _begin_parse_int
	add $t0, $t0, 1
	j _count_number_pos

	_begin_parse_int:
	sub $t0, $t0, 1

	_parsing_int:
	blt $t0, $a0, _finish_parse_int
	lb $v1, 0($t0)
	sub $v1, $v1, 48
	mul $v1, $v1, $t2
	add $v0, $v0, $v1
	mul $t2, $t2, 10
	sub $t0, $t0, 1
	j _parsing_int

	_finish_parse_int:
	beqz $t1, _skip_neg
	neg $v0, $v0
	_skip_neg:

	lw $a0, 0($sp)
	lw $t0, 4($sp)
	lw $t1, 8($sp)
	lw $t2, 12($sp)
	addu $sp, $sp, 16
	jr $ra

# string arg in $a0, pos in $a1
###### Checked ######
# used $v0, $v1
func__ord:
	add $v1, $a0, $a1
	lb $v0, 0($v1)
	jr $ra

# array arg in $a0
# used $v0
func__size:
	lw $v0, -4($a0)
	jr $ra

# string1 in $a0, string2 in $a1
###### Checked ######
# change(16/5/4): use less regs, you don't need to preserve reg before calling it
# used $v0, $v1
func__stringConcatenate:

	subu $sp, $sp, 24
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $t0, 12($sp)
	sw $t1, 16($sp)
	sw $t2, 20($sp)

	lw $t0, -4($a0)		# $t0 is the length of lhs
	lw $t1, -4($a1)		# $t1 is the length of rhs
	add $t2, $t0, $t1

	move $t1, $a0

	add $a0, $t2, 5
	li $v0, 9
	syscall

	sw $t2, 0($v0)
	move $t2, $a1

	add $v0, $v0, 4
	move $v1, $v0

	move $a0, $t1
	move $a1, $v1
	jal _string_copy

	move $a0, $t2
	add $a1, $v1, $t0
	# add $a1, $a1, 1
	jal _string_copy

	move $v0, $v1
	lw $ra, 0($sp)
	lw $a0, 4($sp)
	lw $a1, 8($sp)
	lw $t0, 12($sp)
	lw $t1, 16($sp)
	lw $t2, 20($sp)
	addu $sp, $sp, 24
	jr $ra

# string1 in $a0, string2 in $a1
###### Checked ######
# change(16/5/4): use less regs, you don't need to preserve reg before calling it
# used $a0, $a1, $v0, $v1
func__stringIsEqual:
	# subu $sp, $sp, 8
	# sw $a0, 0($sp)
	# sw $a1, 4($sp)

	lw $v0, -4($a0)
	lw $v1, -4($a1)
	bne $v0, $v1, _not_equal

	_continue_compare_equal:
	lb $v0, 0($a0)
	lb $v1, 0($a1)
	beqz $v0, _equal
	bne $v0, $v1, _not_equal
	add $a0, $a0, 1
	add $a1, $a1, 1
	j _continue_compare_equal

	_not_equal:
	li $v0, 0
	j _compare_final

	_equal:
	li $v0, 1

	_compare_final:
	# lw $a0, 0($sp)
	# lw $a1, 4($sp)
	# addu $sp, $sp, 8
	jr $ra


# string1 in $a0, string2 in $a1
###### Checked ######
# change(16/5/4): use less regs, you don't need to preserve reg before calling it
# used $a0, $a1, $v0, $v1
func__stringLess:
	# subu $sp, $sp, 8
	# sw $a0, 0($sp)
	# sw $a1, 4($sp)

	_begin_compare_less:
	lb $v0, 0($a0)
	lb $v1, 0($a1)
	blt $v0, $v1, _less_correct
	bgt $v0, $v1, _less_false
	beqz $v0, _less_false
	add $a0, $a0, 1
	add $a1, $a1, 1
	j _begin_compare_less

	_less_correct:
	li $v0, 1
	j _less_compare_final

	_less_false:
	li $v0, 0

	_less_compare_final:

	# lw $a0, 0($sp)
	# lw $a1, 4($sp)
	# addu $sp, $sp, 8
	jr $ra

# string1 in $a0, string2 in $a1
# used $a0, $a1, $v0, $v1
func__stringLarge:
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	jal func__stringLess

	xor $v0, $v0, 1

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra

# string1 in $a0, string2 in $a1
# used $a0, $a1, $v0, $v1
func__stringLeq:
	subu $sp, $sp, 12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)

	jal func__stringLess

	bnez $v0, _skip_compare_equal_in_Leq

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	jal func__stringIsEqual

	_skip_compare_equal_in_Leq:
	lw $ra, 0($sp)
	addu $sp, $sp, 12
	jr $ra

# string1 in $a0, string2 in $a1
# used $a0, $a1, $v0, $v1
func__stringGeq:
	subu $sp, $sp, 12
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)

	jal func__stringLess

	beqz $v0, _skip_compare_equal_in_Geq

	lw $a0, 4($sp)
	lw $a1, 8($sp)
	jal func__stringIsEqual
	xor $v0, $v0, 1

	_skip_compare_equal_in_Geq:
	xor $v0, $v0, 1
	lw $ra, 0($sp)
	addu $sp, $sp, 12
	jr $ra

# string1 in $a0, string2 in $a1
# used $a0, $a1, $v0, $v1
func__stringNeq:
	subu $sp, $sp, 4
	sw $ra, 0($sp)

	jal func__stringIsEqual

	xor $v0, $v0, 1

	lw $ra, 0($sp)
	addu $sp, $sp, 4
	jr $ra
_getcount:
	sub $sp, $sp, 144
	sw $ra, 120($sp)
_BeginOfFunctionDecl1866:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 140($sp)
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t1, 136($sp)
	lw $t0, 0($t1)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	lw $t1, 136($sp)
	sw $t0, 0($t1)
	lw $v0, 132($sp)
	b _EndOfFunctionDecl1867
_EndOfFunctionDecl1867:
	lw $ra, 120($sp)
	add $sp, $sp, 144
	jr $ra
main:
	sub $sp, $sp, 10404
	sw $ra, 120($sp)
_BeginOfFunctionDecl1868:
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $t0, 1080($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $a0, 1080($sp)
	li $v0, 9
	syscall
	sw $v0, 6244($sp)
	li $t0, 1
	lw $t1, 6244($sp)
	sw $t0, 0($t1)
	lw $t0, 6244($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 6244($sp)
	lw $t0, 6244($sp)
	sw $t0, 9984($sp)
	lw $t0, 9984($sp)
	sw $t0, global_4145
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 3440($sp)
	lw $t0, global_4145
	lw $t1, 3440($sp)
	add $t1, $t0, $t1
	sw $t1, 628($sp)
	li $t0, 0
	lw $t1, 628($sp)
	sw $t0, 0($t1)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5464($sp)
	lw $t0, 5464($sp)
	sw $t0, 5080($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9388($sp)
	lw $t0, 9388($sp)
	sw $t0, 5784($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2680($sp)
	lw $t0, 2680($sp)
	sw $t0, 9216($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5164($sp)
	lw $t0, 5164($sp)
	sw $t0, 820($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6332($sp)
	lw $t0, 6332($sp)
	sw $t0, 9324($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 504($sp)
	lw $t0, 504($sp)
	sw $t0, 1572($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6704($sp)
	lw $t0, 6704($sp)
	sw $t0, 4080($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4700($sp)
	lw $t0, 4700($sp)
	sw $t0, 7356($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2812($sp)
	lw $t0, 2812($sp)
	sw $t0, 7420($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8608($sp)
	lw $t0, 8608($sp)
	sw $t0, 9112($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2516($sp)
	lw $t0, 2516($sp)
	sw $t0, 9792($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3300($sp)
	lw $t0, 3300($sp)
	sw $t0, 8284($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6000($sp)
	lw $t0, 6000($sp)
	sw $t0, 10384($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6932($sp)
	lw $t0, 6932($sp)
	sw $t0, 3288($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3200($sp)
	lw $t0, 3200($sp)
	sw $t0, 3356($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4316($sp)
	lw $t0, 4316($sp)
	sw $t0, 3220($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2444($sp)
	lw $t0, 2444($sp)
	sw $t0, 3240($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8756($sp)
	lw $t0, 8756($sp)
	sw $t0, 4780($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2340($sp)
	lw $t0, 2340($sp)
	sw $t0, 10340($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3244($sp)
	lw $t0, 3244($sp)
	sw $t0, 8064($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 780($sp)
	lw $t0, 780($sp)
	sw $t0, 6588($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9928($sp)
	lw $t0, 9928($sp)
	sw $t0, 7552($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9620($sp)
	lw $t0, 9620($sp)
	sw $t0, 9376($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7900($sp)
	lw $t0, 7900($sp)
	sw $t0, 10304($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1404($sp)
	lw $t0, 1404($sp)
	sw $t0, 3976($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3132($sp)
	lw $t0, 3132($sp)
	sw $t0, 2088($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3000($sp)
	lw $t0, 3000($sp)
	sw $t0, 6312($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4500($sp)
	lw $t0, 4500($sp)
	sw $t0, 8524($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3984($sp)
	lw $t0, 3984($sp)
	sw $t0, 2188($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7768($sp)
	lw $t0, 7768($sp)
	sw $t0, 1520($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 540($sp)
	lw $t0, 540($sp)
	sw $t0, 6540($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 380($sp)
	lw $t0, 380($sp)
	sw $t0, 8024($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2636($sp)
	lw $t0, 2636($sp)
	sw $t0, 9440($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5448($sp)
	lw $t0, 5448($sp)
	sw $t0, 8260($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9148($sp)
	lw $t0, 9148($sp)
	sw $t0, 2056($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4656($sp)
	lw $t0, 4656($sp)
	sw $t0, 3580($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5388($sp)
	lw $t0, 5388($sp)
	sw $t0, 6572($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9304($sp)
	lw $t0, 9304($sp)
	sw $t0, 3088($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 784($sp)
	lw $t0, 784($sp)
	sw $t0, 884($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4592($sp)
	lw $t0, 4592($sp)
	sw $t0, 5152($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5664($sp)
	lw $t0, 5664($sp)
	sw $t0, 9348($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9628($sp)
	lw $t0, 9628($sp)
	sw $t0, 8392($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7564($sp)
	lw $t0, 7564($sp)
	sw $t0, 3260($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9504($sp)
	lw $t0, 9504($sp)
	sw $t0, 4880($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2756($sp)
	lw $t0, 2756($sp)
	sw $t0, 5436($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9596($sp)
	lw $t0, 9596($sp)
	sw $t0, 996($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7884($sp)
	lw $t0, 7884($sp)
	sw $t0, 7476($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3768($sp)
	lw $t0, 3768($sp)
	sw $t0, 952($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2728($sp)
	lw $t0, 2728($sp)
	sw $t0, 7656($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3644($sp)
	lw $t0, 3644($sp)
	sw $t0, 9292($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6208($sp)
	lw $t0, 6208($sp)
	sw $t0, 9060($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2624($sp)
	lw $t0, 2624($sp)
	sw $t0, 9720($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5948($sp)
	lw $t0, 5948($sp)
	sw $t0, 5600($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 712($sp)
	lw $t0, 712($sp)
	sw $t0, 5172($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 688($sp)
	lw $t0, 688($sp)
	sw $t0, 4964($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1324($sp)
	lw $t0, 1324($sp)
	sw $t0, 7696($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9128($sp)
	lw $t0, 9128($sp)
	sw $t0, 8516($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2032($sp)
	lw $t0, 2032($sp)
	sw $t0, 4896($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8800($sp)
	lw $t0, 8800($sp)
	sw $t0, 10056($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 348($sp)
	lw $t0, 348($sp)
	sw $t0, 5252($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6884($sp)
	lw $t0, 6884($sp)
	sw $t0, 1344($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6080($sp)
	lw $t0, 6080($sp)
	sw $t0, 7928($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 856($sp)
	lw $t0, 856($sp)
	sw $t0, 4996($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4096($sp)
	lw $t0, 4096($sp)
	sw $t0, 3812($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9204($sp)
	lw $t0, 9204($sp)
	sw $t0, 6192($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7280($sp)
	lw $t0, 7280($sp)
	sw $t0, 3592($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6700($sp)
	lw $t0, 6700($sp)
	sw $t0, 7140($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4748($sp)
	lw $t0, 4748($sp)
	sw $t0, 4268($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3540($sp)
	lw $t0, 3540($sp)
	sw $t0, 9696($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2008($sp)
	lw $t0, 2008($sp)
	sw $t0, 8748($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5924($sp)
	lw $t0, 5924($sp)
	sw $t0, 9124($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1156($sp)
	lw $t0, 1156($sp)
	sw $t0, 2276($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 692($sp)
	lw $t0, 692($sp)
	sw $t0, 2332($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8540($sp)
	lw $t0, 8540($sp)
	sw $t0, 1796($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5824($sp)
	lw $t0, 5824($sp)
	sw $t0, 4724($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 888($sp)
	lw $t0, 888($sp)
	sw $t0, 10332($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4784($sp)
	lw $t0, 4784($sp)
	sw $t0, 3164($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2160($sp)
	lw $t0, 2160($sp)
	sw $t0, 7748($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1140($sp)
	lw $t0, 1140($sp)
	sw $t0, 3968($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5724($sp)
	lw $t0, 5724($sp)
	sw $t0, 3484($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2596($sp)
	lw $t0, 2596($sp)
	sw $t0, 7984($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6028($sp)
	lw $t0, 6028($sp)
	sw $t0, 3532($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7220($sp)
	lw $t0, 7220($sp)
	sw $t0, 5256($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2128($sp)
	lw $t0, 2128($sp)
	sw $t0, 3136($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 468($sp)
	lw $t0, 468($sp)
	sw $t0, 8508($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4012($sp)
	lw $t0, 4012($sp)
	sw $t0, 9892($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8004($sp)
	lw $t0, 8004($sp)
	sw $t0, 9604($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4900($sp)
	lw $t0, 4900($sp)
	sw $t0, 8120($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1064($sp)
	lw $t0, 1064($sp)
	sw $t0, 10040($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8908($sp)
	lw $t0, 8908($sp)
	sw $t0, 4948($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2572($sp)
	lw $t0, 2572($sp)
	sw $t0, 4924($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2536($sp)
	lw $t0, 2536($sp)
	sw $t0, 9660($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6460($sp)
	lw $t0, 6460($sp)
	sw $t0, 6400($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1412($sp)
	lw $t0, 1412($sp)
	sw $t0, 8420($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 532($sp)
	lw $t0, 532($sp)
	sw $t0, 1052($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2648($sp)
	lw $t0, 2648($sp)
	sw $t0, 5468($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4212($sp)
	lw $t0, 4212($sp)
	sw $t0, 2944($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6372($sp)
	lw $t0, 6372($sp)
	sw $t0, 7760($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5892($sp)
	lw $t0, 5892($sp)
	sw $t0, 6524($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8996($sp)
	lw $t0, 8996($sp)
	sw $t0, 9316($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2284($sp)
	lw $t0, 2284($sp)
	sw $t0, 7304($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5560($sp)
	lw $t0, 5560($sp)
	sw $t0, 4884($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6520($sp)
	lw $t0, 6520($sp)
	sw $t0, 1348($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3808($sp)
	lw $t0, 3808($sp)
	sw $t0, 6368($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6116($sp)
	lw $t0, 6116($sp)
	sw $t0, 5776($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4904($sp)
	lw $t0, 4904($sp)
	sw $t0, 7200($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5768($sp)
	lw $t0, 5768($sp)
	sw $t0, 1332($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6472($sp)
	lw $t0, 6472($sp)
	sw $t0, 9676($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 676($sp)
	lw $t0, 676($sp)
	sw $t0, 8816($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2236($sp)
	lw $t0, 2236($sp)
	sw $t0, 1336($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8628($sp)
	lw $t0, 8628($sp)
	sw $t0, 10116($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9136($sp)
	lw $t0, 9136($sp)
	sw $t0, 2892($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3724($sp)
	lw $t0, 3724($sp)
	sw $t0, 10252($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1028($sp)
	lw $t0, 1028($sp)
	sw $t0, 612($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9380($sp)
	lw $t0, 9380($sp)
	sw $t0, 3864($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7680($sp)
	lw $t0, 7680($sp)
	sw $t0, 9224($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4596($sp)
	lw $t0, 4596($sp)
	sw $t0, 6408($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6796($sp)
	lw $t0, 6796($sp)
	sw $t0, 4604($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1712($sp)
	lw $t0, 1712($sp)
	sw $t0, 9352($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5368($sp)
	lw $t0, 5368($sp)
	sw $t0, 7084($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4288($sp)
	lw $t0, 4288($sp)
	sw $t0, 7128($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9328($sp)
	lw $t0, 9328($sp)
	sw $t0, 3252($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1428($sp)
	lw $t0, 1428($sp)
	sw $t0, 7836($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3792($sp)
	lw $t0, 3792($sp)
	sw $t0, 2336($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6856($sp)
	lw $t0, 6856($sp)
	sw $t0, 164($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1172($sp)
	lw $t0, 1172($sp)
	sw $t0, 2768($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7636($sp)
	lw $t0, 7636($sp)
	sw $t0, 7392($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1848($sp)
	lw $t0, 1848($sp)
	sw $t0, 4252($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10188($sp)
	lw $t0, 10188($sp)
	sw $t0, 3880($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6868($sp)
	lw $t0, 6868($sp)
	sw $t0, 8552($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5220($sp)
	lw $t0, 5220($sp)
	sw $t0, 3256($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7404($sp)
	lw $t0, 7404($sp)
	sw $t0, 732($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5444($sp)
	lw $t0, 5444($sp)
	sw $t0, 1096($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3760($sp)
	lw $t0, 3760($sp)
	sw $t0, 7248($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5612($sp)
	lw $t0, 5612($sp)
	sw $t0, 8500($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6792($sp)
	lw $t0, 6792($sp)
	sw $t0, 2940($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10152($sp)
	lw $t0, 10152($sp)
	sw $t0, 5360($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5572($sp)
	lw $t0, 5572($sp)
	sw $t0, 3568($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9968($sp)
	lw $t0, 9968($sp)
	sw $t0, 4016($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4532($sp)
	lw $t0, 4532($sp)
	sw $t0, 1392($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7940($sp)
	lw $t0, 7940($sp)
	sw $t0, 160($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8492($sp)
	lw $t0, 8492($sp)
	sw $t0, 808($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3552($sp)
	lw $t0, 3552($sp)
	sw $t0, 1248($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8920($sp)
	lw $t0, 8920($sp)
	sw $t0, 4148($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1564($sp)
	lw $t0, 1564($sp)
	sw $t0, 6964($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9080($sp)
	lw $t0, 9080($sp)
	sw $t0, 6892($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3180($sp)
	lw $t0, 3180($sp)
	sw $t0, 8300($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4380($sp)
	lw $t0, 4380($sp)
	sw $t0, 2848($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1352($sp)
	lw $t0, 1352($sp)
	sw $t0, 6968($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4716($sp)
	lw $t0, 4716($sp)
	sw $t0, 1384($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4764($sp)
	lw $t0, 4764($sp)
	sw $t0, 3940($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6940($sp)
	lw $t0, 6940($sp)
	sw $t0, 788($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1780($sp)
	lw $t0, 1780($sp)
	sw $t0, 5616($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2824($sp)
	lw $t0, 2824($sp)
	sw $t0, 9708($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2752($sp)
	lw $t0, 2752($sp)
	sw $t0, 2920($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7096($sp)
	lw $t0, 7096($sp)
	sw $t0, 3248($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10048($sp)
	lw $t0, 10048($sp)
	sw $t0, 416($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3488($sp)
	lw $t0, 3488($sp)
	sw $t0, 2264($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6464($sp)
	lw $t0, 6464($sp)
	sw $t0, 8092($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4396($sp)
	lw $t0, 4396($sp)
	sw $t0, 1048($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2428($sp)
	lw $t0, 2428($sp)
	sw $t0, 7904($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2984($sp)
	lw $t0, 2984($sp)
	sw $t0, 8368($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9572($sp)
	lw $t0, 9572($sp)
	sw $t0, 4428($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3628($sp)
	lw $t0, 3628($sp)
	sw $t0, 10192($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1836($sp)
	lw $t0, 1836($sp)
	sw $t0, 2760($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7824($sp)
	lw $t0, 7824($sp)
	sw $t0, 3636($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5788($sp)
	lw $t0, 5788($sp)
	sw $t0, 9192($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1176($sp)
	lw $t0, 1176($sp)
	sw $t0, 2968($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1252($sp)
	lw $t0, 1252($sp)
	sw $t0, 220($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3404($sp)
	lw $t0, 3404($sp)
	sw $t0, 9196($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2956($sp)
	lw $t0, 2956($sp)
	sw $t0, 5248($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 136($sp)
	lw $t0, 136($sp)
	sw $t0, 488($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4400($sp)
	lw $t0, 4400($sp)
	sw $t0, 6772($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6612($sp)
	lw $t0, 6612($sp)
	sw $t0, 8168($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6136($sp)
	lw $t0, 6136($sp)
	sw $t0, 2476($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6432($sp)
	lw $t0, 6432($sp)
	sw $t0, 2772($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3688($sp)
	lw $t0, 3688($sp)
	sw $t0, 9424($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6836($sp)
	lw $t0, 6836($sp)
	sw $t0, 7224($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2308($sp)
	lw $t0, 2308($sp)
	sw $t0, 4184($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2908($sp)
	lw $t0, 2908($sp)
	sw $t0, 10168($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7108($sp)
	lw $t0, 7108($sp)
	sw $t0, 172($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8664($sp)
	lw $t0, 8664($sp)
	sw $t0, 5552($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1600($sp)
	lw $t0, 1600($sp)
	sw $t0, 5392($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10224($sp)
	lw $t0, 10224($sp)
	sw $t0, 5512($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6388($sp)
	lw $t0, 6388($sp)
	sw $t0, 6212($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8200($sp)
	lw $t0, 8200($sp)
	sw $t0, 9680($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8760($sp)
	lw $t0, 8760($sp)
	sw $t0, 1200($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3472($sp)
	lw $t0, 3472($sp)
	sw $t0, 6112($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10320($sp)
	lw $t0, 10320($sp)
	sw $t0, 9616($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1480($sp)
	lw $t0, 1480($sp)
	sw $t0, 2352($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3384($sp)
	lw $t0, 3384($sp)
	sw $t0, 4052($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3096($sp)
	lw $t0, 3096($sp)
	sw $t0, 8232($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1916($sp)
	lw $t0, 1916($sp)
	sw $t0, 5456($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3224($sp)
	lw $t0, 3224($sp)
	sw $t0, 10044($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6412($sp)
	lw $t0, 6412($sp)
	sw $t0, 4440($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4560($sp)
	lw $t0, 4560($sp)
	sw $t0, 7700($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 556($sp)
	lw $t0, 556($sp)
	sw $t0, 4620($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9024($sp)
	lw $t0, 9024($sp)
	sw $t0, 436($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9180($sp)
	lw $t0, 9180($sp)
	sw $t0, 9172($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6528($sp)
	lw $t0, 6528($sp)
	sw $t0, 9444($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9868($sp)
	lw $t0, 9868($sp)
	sw $t0, 1608($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4584($sp)
	lw $t0, 4584($sp)
	sw $t0, 9368($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1760($sp)
	lw $t0, 1760($sp)
	sw $t0, 3776($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5132($sp)
	lw $t0, 5132($sp)
	sw $t0, 9468($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3648($sp)
	lw $t0, 3648($sp)
	sw $t0, 5280($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3344($sp)
	lw $t0, 3344($sp)
	sw $t0, 6160($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4516($sp)
	lw $t0, 4516($sp)
	sw $t0, 2740($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 176($sp)
	lw $t0, 176($sp)
	sw $t0, 2808($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8888($sp)
	lw $t0, 8888($sp)
	sw $t0, 7352($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7568($sp)
	lw $t0, 7568($sp)
	sw $t0, 4100($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10232($sp)
	lw $t0, 10232($sp)
	sw $t0, 9332($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 6916($sp)
	lw $t0, 6916($sp)
	sw $t0, 8636($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10352($sp)
	lw $t0, 10352($sp)
	sw $t0, 3900($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7056($sp)
	lw $t0, 7056($sp)
	sw $t0, 2480($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7320($sp)
	lw $t0, 7320($sp)
	sw $t0, 8108($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7312($sp)
	lw $t0, 7312($sp)
	sw $t0, 1532($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 736($sp)
	lw $t0, 736($sp)
	sw $t0, 1232($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 224($sp)
	lw $t0, 224($sp)
	sw $t0, 6800($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10132($sp)
	lw $t0, 10132($sp)
	sw $t0, 8844($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1276($sp)
	lw $t0, 1276($sp)
	sw $t0, 4976($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2816($sp)
	lw $t0, 2816($sp)
	sw $t0, 292($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 3460($sp)
	lw $t0, 3460($sp)
	sw $t0, 6756($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2216($sp)
	lw $t0, 2216($sp)
	sw $t0, 7292($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8380($sp)
	lw $t0, 8380($sp)
	sw $t0, 9280($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 332($sp)
	lw $t0, 332($sp)
	sw $t0, 8272($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 552($sp)
	lw $t0, 552($sp)
	sw $t0, 3888($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 7996($sp)
	lw $t0, 7996($sp)
	sw $t0, 376($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 304($sp)
	lw $t0, 304($sp)
	sw $t0, 8724($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1692($sp)
	lw $t0, 1692($sp)
	sw $t0, 5272($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5984($sp)
	lw $t0, 5984($sp)
	sw $t0, 10400($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 828($sp)
	lw $t0, 828($sp)
	sw $t0, 10200($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8184($sp)
	lw $t0, 8184($sp)
	sw $t0, 592($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4368($sp)
	lw $t0, 4368($sp)
	sw $t0, 3092($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5112($sp)
	lw $t0, 5112($sp)
	sw $t0, 6604($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2652($sp)
	lw $t0, 2652($sp)
	sw $t0, 364($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 2296($sp)
	lw $t0, 2296($sp)
	sw $t0, 8384($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9036($sp)
	lw $t0, 9036($sp)
	sw $t0, 9408($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9940($sp)
	lw $t0, 9940($sp)
	sw $t0, 4180($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9920($sp)
	lw $t0, 9920($sp)
	sw $t0, 4908($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 316($sp)
	lw $t0, 316($sp)
	sw $t0, 6864($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8016($sp)
	lw $t0, 8016($sp)
	sw $t0, 3516($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9992($sp)
	lw $t0, 9992($sp)
	sw $t0, 5012($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1500($sp)
	lw $t0, 1500($sp)
	sw $t0, 1464($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4356($sp)
	lw $t0, 4356($sp)
	sw $t0, 6504($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4324($sp)
	lw $t0, 4324($sp)
	sw $t0, 2548($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8044($sp)
	lw $t0, 8044($sp)
	sw $t0, 8268($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9544($sp)
	lw $t0, 9544($sp)
	sw $t0, 4228($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5332($sp)
	lw $t0, 5332($sp)
	sw $t0, 9420($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 5352($sp)
	lw $t0, 5352($sp)
	sw $t0, 7724($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 928($sp)
	lw $t0, 928($sp)
	sw $t0, 5000($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 4508($sp)
	lw $t0, 4508($sp)
	sw $t0, 7908($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 1824($sp)
	lw $t0, 1824($sp)
	sw $t0, 2132($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 412($sp)
	lw $t0, 412($sp)
	sw $t0, 8140($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 9700($sp)
	lw $t0, 9700($sp)
	sw $t0, 840($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8440($sp)
	lw $t0, 8440($sp)
	sw $t0, 8976($sp)
	lw $t0, global_4145
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 10064($sp)
	lw $t0, 10064($sp)
	sw $t0, 9200($sp)
	lw $a0, 5080($sp)
	jal func__toString
	sw $v0, 9944($sp)
	lw $a0, 9944($sp)
	la $a1, string_4926
	jal func__stringConcatenate
	sw $v0, 1924($sp)
	lw $a0, 1924($sp)
	jal func__print
	sw $v0, 5452($sp)
	lw $a0, 5784($sp)
	jal func__toString
	sw $v0, 5640($sp)
	lw $a0, 5640($sp)
	la $a1, string_4930
	jal func__stringConcatenate
	sw $v0, 10092($sp)
	lw $a0, 10092($sp)
	jal func__print
	sw $v0, 964($sp)
	lw $a0, 9216($sp)
	jal func__toString
	sw $v0, 1744($sp)
	lw $a0, 1744($sp)
	la $a1, string_4934
	jal func__stringConcatenate
	sw $v0, 7496($sp)
	lw $a0, 7496($sp)
	jal func__print
	sw $v0, 724($sp)
	lw $a0, 820($sp)
	jal func__toString
	sw $v0, 5696($sp)
	lw $a0, 5696($sp)
	la $a1, string_4938
	jal func__stringConcatenate
	sw $v0, 6280($sp)
	lw $a0, 6280($sp)
	jal func__print
	sw $v0, 7776($sp)
	lw $a0, 9324($sp)
	jal func__toString
	sw $v0, 4536($sp)
	lw $a0, 4536($sp)
	la $a1, string_4942
	jal func__stringConcatenate
	sw $v0, 4824($sp)
	lw $a0, 4824($sp)
	jal func__print
	sw $v0, 6264($sp)
	lw $a0, 1572($sp)
	jal func__toString
	sw $v0, 7956($sp)
	lw $a0, 7956($sp)
	la $a1, string_4946
	jal func__stringConcatenate
	sw $v0, 8456($sp)
	lw $a0, 8456($sp)
	jal func__print
	sw $v0, 5040($sp)
	lw $a0, 4080($sp)
	jal func__toString
	sw $v0, 4276($sp)
	lw $a0, 4276($sp)
	la $a1, string_4950
	jal func__stringConcatenate
	sw $v0, 2524($sp)
	lw $a0, 2524($sp)
	jal func__print
	sw $v0, 4028($sp)
	lw $a0, 7356($sp)
	jal func__toString
	sw $v0, 5208($sp)
	lw $a0, 5208($sp)
	la $a1, string_4954
	jal func__stringConcatenate
	sw $v0, 1308($sp)
	lw $a0, 1308($sp)
	jal func__print
	sw $v0, 4384($sp)
	lw $a0, 7420($sp)
	jal func__toString
	sw $v0, 5524($sp)
	lw $a0, 5524($sp)
	la $a1, string_4958
	jal func__stringConcatenate
	sw $v0, 8812($sp)
	lw $a0, 8812($sp)
	jal func__print
	sw $v0, 7988($sp)
	lw $a0, 9112($sp)
	jal func__toString
	sw $v0, 9116($sp)
	lw $a0, 9116($sp)
	la $a1, string_4962
	jal func__stringConcatenate
	sw $v0, 2800($sp)
	lw $a0, 2800($sp)
	jal func__print
	sw $v0, 3596($sp)
	lw $a0, 9792($sp)
	jal func__toString
	sw $v0, 3576($sp)
	lw $a0, 3576($sp)
	la $a1, string_4966
	jal func__stringConcatenate
	sw $v0, 3928($sp)
	lw $a0, 3928($sp)
	jal func__print
	sw $v0, 2368($sp)
	lw $a0, 8284($sp)
	jal func__toString
	sw $v0, 5668($sp)
	lw $a0, 5668($sp)
	la $a1, string_4970
	jal func__stringConcatenate
	sw $v0, 6848($sp)
	lw $a0, 6848($sp)
	jal func__print
	sw $v0, 10228($sp)
	lw $a0, 10384($sp)
	jal func__toString
	sw $v0, 1236($sp)
	lw $a0, 1236($sp)
	la $a1, string_4974
	jal func__stringConcatenate
	sw $v0, 10292($sp)
	lw $a0, 10292($sp)
	jal func__print
	sw $v0, 2888($sp)
	lw $a0, 3288($sp)
	jal func__toString
	sw $v0, 4512($sp)
	lw $a0, 4512($sp)
	la $a1, string_4978
	jal func__stringConcatenate
	sw $v0, 7040($sp)
	lw $a0, 7040($sp)
	jal func__print
	sw $v0, 7388($sp)
	lw $a0, 3356($sp)
	jal func__toString
	sw $v0, 9828($sp)
	lw $a0, 9828($sp)
	la $a1, string_4982
	jal func__stringConcatenate
	sw $v0, 7804($sp)
	lw $a0, 7804($sp)
	jal func__print
	sw $v0, 8792($sp)
	lw $a0, 3220($sp)
	jal func__toString
	sw $v0, 8648($sp)
	lw $a0, 8648($sp)
	la $a1, string_4986
	jal func__stringConcatenate
	sw $v0, 9384($sp)
	lw $a0, 9384($sp)
	jal func__print
	sw $v0, 9520($sp)
	lw $a0, 3240($sp)
	jal func__toString
	sw $v0, 7004($sp)
	lw $a0, 7004($sp)
	la $a1, string_4990
	jal func__stringConcatenate
	sw $v0, 6004($sp)
	lw $a0, 6004($sp)
	jal func__print
	sw $v0, 7192($sp)
	lw $a0, 4780($sp)
	jal func__toString
	sw $v0, 5792($sp)
	lw $a0, 5792($sp)
	la $a1, string_4994
	jal func__stringConcatenate
	sw $v0, 5744($sp)
	lw $a0, 5744($sp)
	jal func__print
	sw $v0, 9184($sp)
	lw $a0, 10340($sp)
	jal func__toString
	sw $v0, 1700($sp)
	lw $a0, 1700($sp)
	la $a1, string_4998
	jal func__stringConcatenate
	sw $v0, 864($sp)
	lw $a0, 864($sp)
	jal func__print
	sw $v0, 3584($sp)
	lw $a0, 8064($sp)
	jal func__toString
	sw $v0, 1312($sp)
	lw $a0, 1312($sp)
	la $a1, string_5002
	jal func__stringConcatenate
	sw $v0, 6476($sp)
	lw $a0, 6476($sp)
	jal func__print
	sw $v0, 1948($sp)
	lw $a0, 6588($sp)
	jal func__toString
	sw $v0, 2916($sp)
	lw $a0, 2916($sp)
	la $a1, string_5006
	jal func__stringConcatenate
	sw $v0, 9644($sp)
	lw $a0, 9644($sp)
	jal func__print
	sw $v0, 2256($sp)
	lw $a0, 7552($sp)
	jal func__toString
	sw $v0, 4708($sp)
	lw $a0, 4708($sp)
	la $a1, string_5010
	jal func__stringConcatenate
	sw $v0, 4648($sp)
	lw $a0, 4648($sp)
	jal func__print
	sw $v0, 4852($sp)
	lw $a0, 9376($sp)
	jal func__toString
	sw $v0, 2288($sp)
	lw $a0, 2288($sp)
	la $a1, string_5014
	jal func__stringConcatenate
	sw $v0, 6344($sp)
	lw $a0, 6344($sp)
	jal func__print
	sw $v0, 7616($sp)
	lw $a0, 10304($sp)
	jal func__toString
	sw $v0, 9392($sp)
	lw $a0, 9392($sp)
	la $a1, string_5018
	jal func__stringConcatenate
	sw $v0, 7208($sp)
	lw $a0, 7208($sp)
	jal func__print
	sw $v0, 8468($sp)
	lw $a0, 3976($sp)
	jal func__toString
	sw $v0, 9752($sp)
	lw $a0, 9752($sp)
	la $a1, string_5022
	jal func__stringConcatenate
	sw $v0, 7264($sp)
	lw $a0, 7264($sp)
	jal func__print
	sw $v0, 7484($sp)
	lw $a0, 2088($sp)
	jal func__toString
	sw $v0, 1784($sp)
	lw $a0, 1784($sp)
	la $a1, string_5026
	jal func__stringConcatenate
	sw $v0, 6100($sp)
	lw $a0, 6100($sp)
	jal func__print
	sw $v0, 5488($sp)
	lw $a0, 6312($sp)
	jal func__toString
	sw $v0, 2928($sp)
	lw $a0, 2928($sp)
	la $a1, string_5030
	jal func__stringConcatenate
	sw $v0, 6656($sp)
	lw $a0, 6656($sp)
	jal func__print
	sw $v0, 7684($sp)
	lw $a0, 8524($sp)
	jal func__toString
	sw $v0, 6804($sp)
	lw $a0, 6804($sp)
	la $a1, string_5034
	jal func__stringConcatenate
	sw $v0, 6516($sp)
	lw $a0, 6516($sp)
	jal func__print
	sw $v0, 9472($sp)
	lw $a0, 2188($sp)
	jal func__toString
	sw $v0, 4328($sp)
	lw $a0, 4328($sp)
	la $a1, string_5038
	jal func__stringConcatenate
	sw $v0, 6812($sp)
	lw $a0, 6812($sp)
	jal func__print
	sw $v0, 2016($sp)
	lw $a0, 1520($sp)
	jal func__toString
	sw $v0, 7100($sp)
	lw $a0, 7100($sp)
	la $a1, string_5042
	jal func__stringConcatenate
	sw $v0, 5648($sp)
	lw $a0, 5648($sp)
	jal func__print
	sw $v0, 5024($sp)
	lw $a0, 6540($sp)
	jal func__toString
	sw $v0, 7116($sp)
	lw $a0, 7116($sp)
	la $a1, string_5046
	jal func__stringConcatenate
	sw $v0, 2644($sp)
	lw $a0, 2644($sp)
	jal func__print
	sw $v0, 8940($sp)
	lw $a0, 8024($sp)
	jal func__toString
	sw $v0, 4244($sp)
	lw $a0, 4244($sp)
	la $a1, string_5050
	jal func__stringConcatenate
	sw $v0, 768($sp)
	lw $a0, 768($sp)
	jal func__print
	sw $v0, 3876($sp)
	lw $a0, 9440($sp)
	jal func__toString
	sw $v0, 3408($sp)
	lw $a0, 3408($sp)
	la $a1, string_5054
	jal func__stringConcatenate
	sw $v0, 2632($sp)
	lw $a0, 2632($sp)
	jal func__print
	sw $v0, 4864($sp)
	lw $a0, 8260($sp)
	jal func__toString
	sw $v0, 796($sp)
	lw $a0, 796($sp)
	la $a1, string_5058
	jal func__stringConcatenate
	sw $v0, 1148($sp)
	lw $a0, 1148($sp)
	jal func__print
	sw $v0, 6360($sp)
	lw $a0, 2056($sp)
	jal func__toString
	sw $v0, 4248($sp)
	lw $a0, 4248($sp)
	la $a1, string_5062
	jal func__stringConcatenate
	sw $v0, 4308($sp)
	lw $a0, 4308($sp)
	jal func__print
	sw $v0, 6720($sp)
	lw $a0, 3580($sp)
	jal func__toString
	sw $v0, 2852($sp)
	lw $a0, 2852($sp)
	la $a1, string_5066
	jal func__stringConcatenate
	sw $v0, 6816($sp)
	lw $a0, 6816($sp)
	jal func__print
	sw $v0, 8160($sp)
	lw $a0, 6572($sp)
	jal func__toString
	sw $v0, 204($sp)
	lw $a0, 204($sp)
	la $a1, string_5070
	jal func__stringConcatenate
	sw $v0, 4520($sp)
	lw $a0, 4520($sp)
	jal func__print
	sw $v0, 4040($sp)
	lw $a0, 3088($sp)
	jal func__toString
	sw $v0, 5240($sp)
	lw $a0, 5240($sp)
	la $a1, string_5074
	jal func__stringConcatenate
	sw $v0, 8696($sp)
	lw $a0, 8696($sp)
	jal func__print
	sw $v0, 4720($sp)
	lw $a0, 884($sp)
	jal func__toString
	sw $v0, 5812($sp)
	lw $a0, 5812($sp)
	la $a1, string_5078
	jal func__stringConcatenate
	sw $v0, 2656($sp)
	lw $a0, 2656($sp)
	jal func__print
	sw $v0, 9744($sp)
	lw $a0, 5152($sp)
	jal func__toString
	sw $v0, 7780($sp)
	lw $a0, 7780($sp)
	la $a1, string_5082
	jal func__stringConcatenate
	sw $v0, 8348($sp)
	lw $a0, 8348($sp)
	jal func__print
	sw $v0, 3112($sp)
	lw $a0, 9348($sp)
	jal func__toString
	sw $v0, 5820($sp)
	lw $a0, 5820($sp)
	la $a1, string_5086
	jal func__stringConcatenate
	sw $v0, 3740($sp)
	lw $a0, 3740($sp)
	jal func__print
	sw $v0, 1208($sp)
	lw $a0, 8392($sp)
	jal func__toString
	sw $v0, 6452($sp)
	lw $a0, 6452($sp)
	la $a1, string_5090
	jal func__stringConcatenate
	sw $v0, 7456($sp)
	lw $a0, 7456($sp)
	jal func__print
	sw $v0, 7920($sp)
	lw $a0, 3260($sp)
	jal func__toString
	sw $v0, 2176($sp)
	lw $a0, 2176($sp)
	la $a1, string_5094
	jal func__stringConcatenate
	sw $v0, 9576($sp)
	lw $a0, 9576($sp)
	jal func__print
	sw $v0, 10156($sp)
	lw $a0, 4880($sp)
	jal func__toString
	sw $v0, 9844($sp)
	lw $a0, 9844($sp)
	la $a1, string_5098
	jal func__stringConcatenate
	sw $v0, 6296($sp)
	lw $a0, 6296($sp)
	jal func__print
	sw $v0, 3852($sp)
	lw $a0, 5436($sp)
	jal func__toString
	sw $v0, 4352($sp)
	lw $a0, 4352($sp)
	la $a1, string_5102
	jal func__stringConcatenate
	sw $v0, 2060($sp)
	lw $a0, 2060($sp)
	jal func__print
	sw $v0, 4296($sp)
	lw $a0, 996($sp)
	jal func__toString
	sw $v0, 2312($sp)
	lw $a0, 2312($sp)
	la $a1, string_5106
	jal func__stringConcatenate
	sw $v0, 3504($sp)
	lw $a0, 3504($sp)
	jal func__print
	sw $v0, 3228($sp)
	lw $a0, 7476($sp)
	jal func__toString
	sw $v0, 2748($sp)
	lw $a0, 2748($sp)
	la $a1, string_5110
	jal func__stringConcatenate
	sw $v0, 10144($sp)
	lw $a0, 10144($sp)
	jal func__print
	sw $v0, 8072($sp)
	lw $a0, 952($sp)
	jal func__toString
	sw $v0, 10216($sp)
	lw $a0, 10216($sp)
	la $a1, string_5114
	jal func__stringConcatenate
	sw $v0, 2168($sp)
	lw $a0, 2168($sp)
	jal func__print
	sw $v0, 1860($sp)
	lw $a0, 7656($sp)
	jal func__toString
	sw $v0, 2140($sp)
	lw $a0, 2140($sp)
	la $a1, string_5118
	jal func__stringConcatenate
	sw $v0, 4576($sp)
	lw $a0, 4576($sp)
	jal func__print
	sw $v0, 7480($sp)
	lw $a0, 9292($sp)
	jal func__toString
	sw $v0, 9880($sp)
	lw $a0, 9880($sp)
	la $a1, string_5122
	jal func__stringConcatenate
	sw $v0, 212($sp)
	lw $a0, 212($sp)
	jal func__print
	sw $v0, 564($sp)
	lw $a0, 9060($sp)
	jal func__toString
	sw $v0, 492($sp)
	lw $a0, 492($sp)
	la $a1, string_5126
	jal func__stringConcatenate
	sw $v0, 916($sp)
	lw $a0, 916($sp)
	jal func__print
	sw $v0, 4224($sp)
	lw $a0, 9720($sp)
	jal func__toString
	sw $v0, 4300($sp)
	lw $a0, 4300($sp)
	la $a1, string_5130
	jal func__stringConcatenate
	sw $v0, 5032($sp)
	lw $a0, 5032($sp)
	jal func__print
	sw $v0, 9052($sp)
	lw $a0, 5600($sp)
	jal func__toString
	sw $v0, 8992($sp)
	lw $a0, 8992($sp)
	la $a1, string_5134
	jal func__stringConcatenate
	sw $v0, 4036($sp)
	lw $a0, 4036($sp)
	jal func__print
	sw $v0, 7016($sp)
	lw $a0, 5172($sp)
	jal func__toString
	sw $v0, 6832($sp)
	lw $a0, 6832($sp)
	la $a1, string_5138
	jal func__stringConcatenate
	sw $v0, 3360($sp)
	lw $a0, 3360($sp)
	jal func__print
	sw $v0, 7152($sp)
	lw $a0, 4964($sp)
	jal func__toString
	sw $v0, 3376($sp)
	lw $a0, 3376($sp)
	la $a1, string_5142
	jal func__stringConcatenate
	sw $v0, 6952($sp)
	lw $a0, 6952($sp)
	jal func__print
	sw $v0, 5588($sp)
	lw $a0, 7696($sp)
	jal func__toString
	sw $v0, 6416($sp)
	lw $a0, 6416($sp)
	la $a1, string_5146
	jal func__stringConcatenate
	sw $v0, 3508($sp)
	lw $a0, 3508($sp)
	jal func__print
	sw $v0, 3480($sp)
	lw $a0, 8516($sp)
	jal func__toString
	sw $v0, 10100($sp)
	lw $a0, 10100($sp)
	la $a1, string_5150
	jal func__stringConcatenate
	sw $v0, 9244($sp)
	lw $a0, 9244($sp)
	jal func__print
	sw $v0, 3736($sp)
	lw $a0, 4896($sp)
	jal func__toString
	sw $v0, 1224($sp)
	lw $a0, 1224($sp)
	la $a1, string_5154
	jal func__stringConcatenate
	sw $v0, 600($sp)
	lw $a0, 600($sp)
	jal func__print
	sw $v0, 4372($sp)
	lw $a0, 10056($sp)
	jal func__toString
	sw $v0, 1688($sp)
	lw $a0, 1688($sp)
	la $a1, string_5158
	jal func__stringConcatenate
	sw $v0, 9652($sp)
	lw $a0, 9652($sp)
	jal func__print
	sw $v0, 10324($sp)
	lw $a0, 5252($sp)
	jal func__toString
	sw $v0, 6040($sp)
	lw $a0, 6040($sp)
	la $a1, string_5162
	jal func__stringConcatenate
	sw $v0, 6084($sp)
	lw $a0, 6084($sp)
	jal func__print
	sw $v0, 1528($sp)
	lw $a0, 1344($sp)
	jal func__toString
	sw $v0, 1940($sp)
	lw $a0, 1940($sp)
	la $a1, string_5166
	jal func__stringConcatenate
	sw $v0, 6008($sp)
	lw $a0, 6008($sp)
	jal func__print
	sw $v0, 8584($sp)
	lw $a0, 7928($sp)
	jal func__toString
	sw $v0, 2488($sp)
	lw $a0, 2488($sp)
	la $a1, string_5170
	jal func__stringConcatenate
	sw $v0, 7072($sp)
	lw $a0, 7072($sp)
	jal func__print
	sw $v0, 6924($sp)
	lw $a0, 4996($sp)
	jal func__toString
	sw $v0, 852($sp)
	lw $a0, 852($sp)
	la $a1, string_5174
	jal func__stringConcatenate
	sw $v0, 9900($sp)
	lw $a0, 9900($sp)
	jal func__print
	sw $v0, 9916($sp)
	lw $a0, 3812($sp)
	jal func__toString
	sw $v0, 10172($sp)
	lw $a0, 10172($sp)
	la $a1, string_5178
	jal func__stringConcatenate
	sw $v0, 1280($sp)
	lw $a0, 1280($sp)
	jal func__print
	sw $v0, 1180($sp)
	lw $a0, 6192($sp)
	jal func__toString
	sw $v0, 8956($sp)
	lw $a0, 8956($sp)
	la $a1, string_5182
	jal func__stringConcatenate
	sw $v0, 264($sp)
	lw $a0, 264($sp)
	jal func__print
	sw $v0, 912($sp)
	lw $a0, 3592($sp)
	jal func__toString
	sw $v0, 2104($sp)
	lw $a0, 2104($sp)
	la $a1, string_5186
	jal func__stringConcatenate
	sw $v0, 8252($sp)
	lw $a0, 8252($sp)
	jal func__print
	sw $v0, 2436($sp)
	lw $a0, 7140($sp)
	jal func__toString
	sw $v0, 7688($sp)
	lw $a0, 7688($sp)
	la $a1, string_5190
	jal func__stringConcatenate
	sw $v0, 824($sp)
	lw $a0, 824($sp)
	jal func__print
	sw $v0, 3432($sp)
	lw $a0, 4268($sp)
	jal func__toString
	sw $v0, 1812($sp)
	lw $a0, 1812($sp)
	la $a1, string_5194
	jal func__stringConcatenate
	sw $v0, 3048($sp)
	lw $a0, 3048($sp)
	jal func__print
	sw $v0, 8320($sp)
	lw $a0, 9696($sp)
	jal func__toString
	sw $v0, 236($sp)
	lw $a0, 236($sp)
	la $a1, string_5198
	jal func__stringConcatenate
	sw $v0, 5336($sp)
	lw $a0, 5336($sp)
	jal func__print
	sw $v0, 7384($sp)
	lw $a0, 8748($sp)
	jal func__toString
	sw $v0, 8656($sp)
	lw $a0, 8656($sp)
	la $a1, string_5202
	jal func__stringConcatenate
	sw $v0, 7596($sp)
	lw $a0, 7596($sp)
	jal func__print
	sw $v0, 9668($sp)
	lw $a0, 9124($sp)
	jal func__toString
	sw $v0, 4640($sp)
	lw $a0, 4640($sp)
	la $a1, string_5206
	jal func__stringConcatenate
	sw $v0, 9760($sp)
	lw $a0, 9760($sp)
	jal func__print
	sw $v0, 3588($sp)
	lw $a0, 2276($sp)
	jal func__toString
	sw $v0, 8596($sp)
	lw $a0, 8596($sp)
	la $a1, string_5210
	jal func__stringConcatenate
	sw $v0, 4008($sp)
	lw $a0, 4008($sp)
	jal func__print
	sw $v0, 5196($sp)
	lw $a0, 2332($sp)
	jal func__toString
	sw $v0, 6356($sp)
	lw $a0, 6356($sp)
	la $a1, string_5214
	jal func__stringConcatenate
	sw $v0, 1192($sp)
	lw $a0, 1192($sp)
	jal func__print
	sw $v0, 2416($sp)
	lw $a0, 1796($sp)
	jal func__toString
	sw $v0, 3032($sp)
	lw $a0, 3032($sp)
	la $a1, string_5218
	jal func__stringConcatenate
	sw $v0, 10388($sp)
	lw $a0, 10388($sp)
	jal func__print
	sw $v0, 3784($sp)
	lw $a0, 4724($sp)
	jal func__toString
	sw $v0, 9648($sp)
	lw $a0, 9648($sp)
	la $a1, string_5222
	jal func__stringConcatenate
	sw $v0, 3148($sp)
	lw $a0, 3148($sp)
	jal func__print
	sw $v0, 9848($sp)
	lw $a0, 10332($sp)
	jal func__toString
	sw $v0, 696($sp)
	lw $a0, 696($sp)
	la $a1, string_5226
	jal func__stringConcatenate
	sw $v0, 1732($sp)
	lw $a0, 1732($sp)
	jal func__print
	sw $v0, 472($sp)
	lw $a0, 3164($sp)
	jal func__toString
	sw $v0, 3276($sp)
	lw $a0, 3276($sp)
	la $a1, string_5230
	jal func__stringConcatenate
	sw $v0, 8620($sp)
	lw $a0, 8620($sp)
	jal func__print
	sw $v0, 1672($sp)
	lw $a0, 7748($sp)
	jal func__toString
	sw $v0, 3424($sp)
	lw $a0, 3424($sp)
	la $a1, string_5234
	jal func__stringConcatenate
	sw $v0, 8460($sp)
	lw $a0, 8460($sp)
	jal func__print
	sw $v0, 8328($sp)
	lw $a0, 3968($sp)
	jal func__toString
	sw $v0, 3668($sp)
	lw $a0, 3668($sp)
	la $a1, string_5238
	jal func__stringConcatenate
	sw $v0, 9816($sp)
	lw $a0, 9816($sp)
	jal func__print
	sw $v0, 1300($sp)
	lw $a0, 3484($sp)
	jal func__toString
	sw $v0, 2372($sp)
	lw $a0, 2372($sp)
	la $a1, string_5242
	jal func__stringConcatenate
	sw $v0, 1400($sp)
	lw $a0, 1400($sp)
	jal func__print
	sw $v0, 7300($sp)
	lw $a0, 7984($sp)
	jal func__toString
	sw $v0, 2720($sp)
	lw $a0, 2720($sp)
	la $a1, string_5246
	jal func__stringConcatenate
	sw $v0, 6444($sp)
	lw $a0, 6444($sp)
	jal func__print
	sw $v0, 5316($sp)
	lw $a0, 3532($sp)
	jal func__toString
	sw $v0, 9560($sp)
	lw $a0, 9560($sp)
	la $a1, string_5250
	jal func__stringConcatenate
	sw $v0, 2468($sp)
	lw $a0, 2468($sp)
	jal func__print
	sw $v0, 392($sp)
	lw $a0, 5256($sp)
	jal func__toString
	sw $v0, 3676($sp)
	lw $a0, 3676($sp)
	la $a1, string_5254
	jal func__stringConcatenate
	sw $v0, 568($sp)
	lw $a0, 568($sp)
	jal func__print
	sw $v0, 6732($sp)
	lw $a0, 3136($sp)
	jal func__toString
	sw $v0, 2552($sp)
	lw $a0, 2552($sp)
	la $a1, string_5258
	jal func__stringConcatenate
	sw $v0, 320($sp)
	lw $a0, 320($sp)
	jal func__print
	sw $v0, 7240($sp)
	lw $a0, 8508($sp)
	jal func__toString
	sw $v0, 4292($sp)
	lw $a0, 4292($sp)
	la $a1, string_5262
	jal func__stringConcatenate
	sw $v0, 7936($sp)
	lw $a0, 7936($sp)
	jal func__print
	sw $v0, 5180($sp)
	lw $a0, 9892($sp)
	jal func__toString
	sw $v0, 7548($sp)
	lw $a0, 7548($sp)
	la $a1, string_5266
	jal func__stringConcatenate
	sw $v0, 7536($sp)
	lw $a0, 7536($sp)
	jal func__print
	sw $v0, 5832($sp)
	lw $a0, 9604($sp)
	jal func__toString
	sw $v0, 8216($sp)
	lw $a0, 8216($sp)
	la $a1, string_5270
	jal func__stringConcatenate
	sw $v0, 6840($sp)
	lw $a0, 6840($sp)
	jal func__print
	sw $v0, 9664($sp)
	lw $a0, 8120($sp)
	jal func__toString
	sw $v0, 252($sp)
	lw $a0, 252($sp)
	la $a1, string_5274
	jal func__stringConcatenate
	sw $v0, 1772($sp)
	lw $a0, 1772($sp)
	jal func__print
	sw $v0, 8208($sp)
	lw $a0, 10040($sp)
	jal func__toString
	sw $v0, 2860($sp)
	lw $a0, 2860($sp)
	la $a1, string_5278
	jal func__stringConcatenate
	sw $v0, 8912($sp)
	lw $a0, 8912($sp)
	jal func__print
	sw $v0, 2108($sp)
	lw $a0, 4948($sp)
	jal func__toString
	sw $v0, 5780($sp)
	lw $a0, 5780($sp)
	la $a1, string_5282
	jal func__stringConcatenate
	sw $v0, 4968($sp)
	lw $a0, 4968($sp)
	jal func__print
	sw $v0, 6076($sp)
	lw $a0, 4924($sp)
	jal func__toString
	sw $v0, 1736($sp)
	lw $a0, 1736($sp)
	la $a1, string_5286
	jal func__stringConcatenate
	sw $v0, 9068($sp)
	lw $a0, 9068($sp)
	jal func__print
	sw $v0, 8504($sp)
	lw $a0, 9660($sp)
	jal func__toString
	sw $v0, 7644($sp)
	lw $a0, 7644($sp)
	la $a1, string_5290
	jal func__stringConcatenate
	sw $v0, 4456($sp)
	lw $a0, 4456($sp)
	jal func__print
	sw $v0, 3120($sp)
	lw $a0, 6400($sp)
	jal func__toString
	sw $v0, 6780($sp)
	lw $a0, 6780($sp)
	la $a1, string_5294
	jal func__stringConcatenate
	sw $v0, 3292($sp)
	lw $a0, 3292($sp)
	jal func__print
	sw $v0, 584($sp)
	lw $a0, 8420($sp)
	jal func__toString
	sw $v0, 2064($sp)
	lw $a0, 2064($sp)
	la $a1, string_5298
	jal func__stringConcatenate
	sw $v0, 1868($sp)
	lw $a0, 1868($sp)
	jal func__print
	sw $v0, 6620($sp)
	lw $a0, 1052($sp)
	jal func__toString
	sw $v0, 9492($sp)
	lw $a0, 9492($sp)
	la $a1, string_5302
	jal func__stringConcatenate
	sw $v0, 2896($sp)
	lw $a0, 2896($sp)
	jal func__print
	sw $v0, 1904($sp)
	lw $a0, 5468($sp)
	jal func__toString
	sw $v0, 2780($sp)
	lw $a0, 2780($sp)
	la $a1, string_5306
	jal func__stringConcatenate
	sw $v0, 1008($sp)
	lw $a0, 1008($sp)
	jal func__print
	sw $v0, 10084($sp)
	lw $a0, 2944($sp)
	jal func__toString
	sw $v0, 3660($sp)
	lw $a0, 3660($sp)
	la $a1, string_5310
	jal func__stringConcatenate
	sw $v0, 10108($sp)
	lw $a0, 10108($sp)
	jal func__print
	sw $v0, 5356($sp)
	lw $a0, 7760($sp)
	jal func__toString
	sw $v0, 5076($sp)
	lw $a0, 5076($sp)
	la $a1, string_5314
	jal func__stringConcatenate
	sw $v0, 6760($sp)
	lw $a0, 6760($sp)
	jal func__print
	sw $v0, 2568($sp)
	lw $a0, 6524($sp)
	jal func__toString
	sw $v0, 8660($sp)
	lw $a0, 8660($sp)
	la $a1, string_5318
	jal func__stringConcatenate
	sw $v0, 3412($sp)
	lw $a0, 3412($sp)
	jal func__print
	sw $v0, 2964($sp)
	lw $a0, 9316($sp)
	jal func__toString
	sw $v0, 988($sp)
	lw $a0, 988($sp)
	la $a1, string_5322
	jal func__stringConcatenate
	sw $v0, 2696($sp)
	lw $a0, 2696($sp)
	jal func__print
	sw $v0, 6108($sp)
	lw $a0, 7304($sp)
	jal func__toString
	sw $v0, 5760($sp)
	lw $a0, 5760($sp)
	la $a1, string_5326
	jal func__stringConcatenate
	sw $v0, 5992($sp)
	lw $a0, 5992($sp)
	jal func__print
	sw $v0, 6216($sp)
	lw $a0, 4884($sp)
	jal func__toString
	sw $v0, 924($sp)
	lw $a0, 924($sp)
	la $a1, string_5330
	jal func__stringConcatenate
	sw $v0, 3312($sp)
	lw $a0, 3312($sp)
	jal func__print
	sw $v0, 4236($sp)
	lw $a0, 1348($sp)
	jal func__toString
	sw $v0, 8668($sp)
	lw $a0, 8668($sp)
	la $a1, string_5334
	jal func__stringConcatenate
	sw $v0, 2400($sp)
	lw $a0, 2400($sp)
	jal func__print
	sw $v0, 868($sp)
	lw $a0, 6368($sp)
	jal func__toString
	sw $v0, 7808($sp)
	lw $a0, 7808($sp)
	la $a1, string_5338
	jal func__stringConcatenate
	sw $v0, 10308($sp)
	lw $a0, 10308($sp)
	jal func__print
	sw $v0, 4020($sp)
	lw $a0, 5776($sp)
	jal func__toString
	sw $v0, 1876($sp)
	lw $a0, 1876($sp)
	la $a1, string_5342
	jal func__stringConcatenate
	sw $v0, 8472($sp)
	lw $a0, 8472($sp)
	jal func__print
	sw $v0, 2716($sp)
	lw $a0, 7200($sp)
	jal func__toString
	sw $v0, 2556($sp)
	lw $a0, 2556($sp)
	la $a1, string_5346
	jal func__stringConcatenate
	sw $v0, 5056($sp)
	lw $a0, 5056($sp)
	jal func__print
	sw $v0, 8772($sp)
	lw $a0, 1332($sp)
	jal func__toString
	sw $v0, 3604($sp)
	lw $a0, 3604($sp)
	la $a1, string_5350
	jal func__stringConcatenate
	sw $v0, 2600($sp)
	lw $a0, 2600($sp)
	jal func__print
	sw $v0, 3684($sp)
	lw $a0, 9676($sp)
	jal func__toString
	sw $v0, 2744($sp)
	lw $a0, 2744($sp)
	la $a1, string_5354
	jal func__stringConcatenate
	sw $v0, 6092($sp)
	lw $a0, 6092($sp)
	jal func__print
	sw $v0, 1136($sp)
	lw $a0, 8816($sp)
	jal func__toString
	sw $v0, 9404($sp)
	lw $a0, 9404($sp)
	la $a1, string_5358
	jal func__stringConcatenate
	sw $v0, 8788($sp)
	lw $a0, 8788($sp)
	jal func__print
	sw $v0, 2272($sp)
	lw $a0, 1336($sp)
	jal func__toString
	sw $v0, 2224($sp)
	lw $a0, 2224($sp)
	la $a1, string_5362
	jal func__stringConcatenate
	sw $v0, 6396($sp)
	lw $a0, 6396($sp)
	jal func__print
	sw $v0, 9356($sp)
	lw $a0, 10116($sp)
	jal func__toString
	sw $v0, 4840($sp)
	lw $a0, 4840($sp)
	la $a1, string_5366
	jal func__stringConcatenate
	sw $v0, 8880($sp)
	lw $a0, 8880($sp)
	jal func__print
	sw $v0, 1696($sp)
	lw $a0, 2892($sp)
	jal func__toString
	sw $v0, 7628($sp)
	lw $a0, 7628($sp)
	la $a1, string_5370
	jal func__stringConcatenate
	sw $v0, 440($sp)
	lw $a0, 440($sp)
	jal func__print
	sw $v0, 5060($sp)
	lw $a0, 10252($sp)
	jal func__toString
	sw $v0, 9056($sp)
	lw $a0, 9056($sp)
	la $a1, string_5374
	jal func__stringConcatenate
	sw $v0, 7844($sp)
	lw $a0, 7844($sp)
	jal func__print
	sw $v0, 3236($sp)
	lw $a0, 612($sp)
	jal func__toString
	sw $v0, 1268($sp)
	lw $a0, 1268($sp)
	la $a1, string_5378
	jal func__stringConcatenate
	sw $v0, 2196($sp)
	lw $a0, 2196($sp)
	jal func__print
	sw $v0, 2664($sp)
	lw $a0, 3864($sp)
	jal func__toString
	sw $v0, 1900($sp)
	lw $a0, 1900($sp)
	la $a1, string_5382
	jal func__stringConcatenate
	sw $v0, 6912($sp)
	lw $a0, 6912($sp)
	jal func__print
	sw $v0, 1088($sp)
	lw $a0, 9224($sp)
	jal func__toString
	sw $v0, 1160($sp)
	lw $a0, 1160($sp)
	la $a1, string_5386
	jal func__stringConcatenate
	sw $v0, 5756($sp)
	lw $a0, 5756($sp)
	jal func__print
	sw $v0, 9712($sp)
	lw $a0, 6408($sp)
	jal func__toString
	sw $v0, 7328($sp)
	lw $a0, 7328($sp)
	la $a1, string_5390
	jal func__stringConcatenate
	sw $v0, 10244($sp)
	lw $a0, 10244($sp)
	jal func__print
	sw $v0, 5116($sp)
	lw $a0, 4604($sp)
	jal func__toString
	sw $v0, 4956($sp)
	lw $a0, 4956($sp)
	la $a1, string_5394
	jal func__stringConcatenate
	sw $v0, 2448($sp)
	lw $a0, 2448($sp)
	jal func__print
	sw $v0, 4788($sp)
	lw $a0, 9352($sp)
	jal func__toString
	sw $v0, 8576($sp)
	lw $a0, 8576($sp)
	la $a1, string_5398
	jal func__stringConcatenate
	sw $v0, 2012($sp)
	lw $a0, 2012($sp)
	jal func__print
	sw $v0, 5972($sp)
	lw $a0, 7084($sp)
	jal func__toString
	sw $v0, 992($sp)
	lw $a0, 992($sp)
	la $a1, string_5402
	jal func__stringConcatenate
	sw $v0, 7912($sp)
	lw $a0, 7912($sp)
	jal func__print
	sw $v0, 9692($sp)
	lw $a0, 7128($sp)
	jal func__toString
	sw $v0, 6708($sp)
	lw $a0, 6708($sp)
	la $a1, string_5406
	jal func__stringConcatenate
	sw $v0, 8892($sp)
	lw $a0, 8892($sp)
	jal func__print
	sw $v0, 7592($sp)
	lw $a0, 3252($sp)
	jal func__toString
	sw $v0, 1896($sp)
	lw $a0, 1896($sp)
	la $a1, string_5410
	jal func__stringConcatenate
	sw $v0, 636($sp)
	lw $a0, 636($sp)
	jal func__print
	sw $v0, 772($sp)
	lw $a0, 7836($sp)
	jal func__toString
	sw $v0, 7440($sp)
	lw $a0, 7440($sp)
	la $a1, string_5414
	jal func__stringConcatenate
	sw $v0, 7048($sp)
	lw $a0, 7048($sp)
	jal func__print
	sw $v0, 1568($sp)
	lw $a0, 2336($sp)
	jal func__toString
	sw $v0, 5608($sp)
	lw $a0, 5608($sp)
	la $a1, string_5418
	jal func__stringConcatenate
	sw $v0, 1104($sp)
	lw $a0, 1104($sp)
	jal func__print
	sw $v0, 3520($sp)
	lw $a0, 164($sp)
	jal func__toString
	sw $v0, 572($sp)
	lw $a0, 572($sp)
	la $a1, string_5422
	jal func__stringConcatenate
	sw $v0, 548($sp)
	lw $a0, 548($sp)
	jal func__print
	sw $v0, 1880($sp)
	lw $a0, 2768($sp)
	jal func__toString
	sw $v0, 6828($sp)
	lw $a0, 6828($sp)
	la $a1, string_5426
	jal func__stringConcatenate
	sw $v0, 704($sp)
	lw $a0, 704($sp)
	jal func__print
	sw $v0, 7888($sp)
	lw $a0, 7392($sp)
	jal func__toString
	sw $v0, 7488($sp)
	lw $a0, 7488($sp)
	la $a1, string_5430
	jal func__stringConcatenate
	sw $v0, 9212($sp)
	lw $a0, 9212($sp)
	jal func__print
	sw $v0, 140($sp)
	lw $a0, 4252($sp)
	jal func__toString
	sw $v0, 3464($sp)
	lw $a0, 3464($sp)
	la $a1, string_5434
	jal func__stringConcatenate
	sw $v0, 1448($sp)
	lw $a0, 1448($sp)
	jal func__print
	sw $v0, 9480($sp)
	lw $a0, 3880($sp)
	jal func__toString
	sw $v0, 5008($sp)
	lw $a0, 5008($sp)
	la $a1, string_5438
	jal func__stringConcatenate
	sw $v0, 1544($sp)
	lw $a0, 1544($sp)
	jal func__print
	sw $v0, 1316($sp)
	lw $a0, 8552($sp)
	jal func__toString
	sw $v0, 2396($sp)
	lw $a0, 2396($sp)
	la $a1, string_5442
	jal func__stringConcatenate
	sw $v0, 8980($sp)
	lw $a0, 8980($sp)
	jal func__print
	sw $v0, 9072($sp)
	lw $a0, 3256($sp)
	jal func__toString
	sw $v0, 2976($sp)
	lw $a0, 2976($sp)
	la $a1, string_5446
	jal func__stringConcatenate
	sw $v0, 7856($sp)
	lw $a0, 7856($sp)
	jal func__print
	sw $v0, 3944($sp)
	lw $a0, 732($sp)
	jal func__toString
	sw $v0, 10396($sp)
	lw $a0, 10396($sp)
	la $a1, string_5450
	jal func__stringConcatenate
	sw $v0, 5188($sp)
	lw $a0, 5188($sp)
	jal func__print
	sw $v0, 1652($sp)
	lw $a0, 1096($sp)
	jal func__toString
	sw $v0, 5800($sp)
	lw $a0, 5800($sp)
	la $a1, string_5454
	jal func__stringConcatenate
	sw $v0, 7608($sp)
	lw $a0, 7608($sp)
	jal func__print
	sw $v0, 3204($sp)
	lw $a0, 7248($sp)
	jal func__toString
	sw $v0, 240($sp)
	lw $a0, 240($sp)
	la $a1, string_5458
	jal func__stringConcatenate
	sw $v0, 3892($sp)
	lw $a0, 3892($sp)
	jal func__print
	sw $v0, 9764($sp)
	lw $a0, 8500($sp)
	jal func__toString
	sw $v0, 480($sp)
	lw $a0, 480($sp)
	la $a1, string_5462
	jal func__stringConcatenate
	sw $v0, 8512($sp)
	lw $a0, 8512($sp)
	jal func__print
	sw $v0, 968($sp)
	lw $a0, 2940($sp)
	jal func__toString
	sw $v0, 4572($sp)
	lw $a0, 4572($sp)
	la $a1, string_5466
	jal func__stringConcatenate
	sw $v0, 528($sp)
	lw $a0, 528($sp)
	jal func__print
	sw $v0, 5632($sp)
	lw $a0, 5360($sp)
	jal func__toString
	sw $v0, 1516($sp)
	lw $a0, 1516($sp)
	la $a1, string_5470
	jal func__stringConcatenate
	sw $v0, 4488($sp)
	lw $a0, 4488($sp)
	jal func__print
	sw $v0, 388($sp)
	lw $a0, 3568($sp)
	jal func__toString
	sw $v0, 5300($sp)
	lw $a0, 5300($sp)
	la $a1, string_5474
	jal func__stringConcatenate
	sw $v0, 4092($sp)
	lw $a0, 4092($sp)
	jal func__print
	sw $v0, 5504($sp)
	lw $a0, 4016($sp)
	jal func__toString
	sw $v0, 6648($sp)
	lw $a0, 6648($sp)
	la $a1, string_5478
	jal func__stringConcatenate
	sw $v0, 3616($sp)
	lw $a0, 3616($sp)
	jal func__print
	sw $v0, 6484($sp)
	lw $a0, 1392($sp)
	jal func__toString
	sw $v0, 4484($sp)
	lw $a0, 4484($sp)
	la $a1, string_5482
	jal func__stringConcatenate
	sw $v0, 9988($sp)
	lw $a0, 9988($sp)
	jal func__print
	sw $v0, 7640($sp)
	lw $a0, 160($sp)
	jal func__toString
	sw $v0, 6300($sp)
	lw $a0, 6300($sp)
	la $a1, string_5486
	jal func__stringConcatenate
	sw $v0, 5460($sp)
	lw $a0, 5460($sp)
	jal func__print
	sw $v0, 8532($sp)
	lw $a0, 808($sp)
	jal func__toString
	sw $v0, 5048($sp)
	lw $a0, 5048($sp)
	la $a1, string_5490
	jal func__stringConcatenate
	sw $v0, 9548($sp)
	lw $a0, 9548($sp)
	jal func__print
	sw $v0, 2040($sp)
	lw $a0, 1248($sp)
	jal func__toString
	sw $v0, 4600($sp)
	lw $a0, 4600($sp)
	la $a1, string_5494
	jal func__stringConcatenate
	sw $v0, 8804($sp)
	lw $a0, 8804($sp)
	jal func__print
	sw $v0, 5956($sp)
	lw $a0, 4148($sp)
	jal func__toString
	sw $v0, 5372($sp)
	lw $a0, 5372($sp)
	la $a1, string_5498
	jal func__stringConcatenate
	sw $v0, 2992($sp)
	lw $a0, 2992($sp)
	jal func__print
	sw $v0, 9776($sp)
	lw $a0, 6964($sp)
	jal func__toString
	sw $v0, 3012($sp)
	lw $a0, 3012($sp)
	la $a1, string_5502
	jal func__stringConcatenate
	sw $v0, 760($sp)
	lw $a0, 760($sp)
	jal func__print
	sw $v0, 9008($sp)
	lw $a0, 6892($sp)
	jal func__toString
	sw $v0, 4160($sp)
	lw $a0, 4160($sp)
	la $a1, string_5506
	jal func__stringConcatenate
	sw $v0, 5160($sp)
	lw $a0, 5160($sp)
	jal func__print
	sw $v0, 2144($sp)
	lw $a0, 8300($sp)
	jal func__toString
	sw $v0, 8316($sp)
	lw $a0, 8316($sp)
	la $a1, string_5510
	jal func__stringConcatenate
	sw $v0, 9624($sp)
	lw $a0, 9624($sp)
	jal func__print
	sw $v0, 7268($sp)
	lw $a0, 2848($sp)
	jal func__toString
	sw $v0, 2604($sp)
	lw $a0, 2604($sp)
	la $a1, string_5514
	jal func__stringConcatenate
	sw $v0, 748($sp)
	lw $a0, 748($sp)
	jal func__print
	sw $v0, 8188($sp)
	lw $a0, 6968($sp)
	jal func__toString
	sw $v0, 6920($sp)
	lw $a0, 6920($sp)
	la $a1, string_5518
	jal func__stringConcatenate
	sw $v0, 8924($sp)
	lw $a0, 8924($sp)
	jal func__print
	sw $v0, 7576($sp)
	lw $a0, 1384($sp)
	jal func__toString
	sw $v0, 5396($sp)
	lw $a0, 5396($sp)
	la $a1, string_5522
	jal func__stringConcatenate
	sw $v0, 2068($sp)
	lw $a0, 2068($sp)
	jal func__print
	sw $v0, 6556($sp)
	lw $a0, 3940($sp)
	jal func__toString
	sw $v0, 7332($sp)
	lw $a0, 7332($sp)
	la $a1, string_5526
	jal func__stringConcatenate
	sw $v0, 1952($sp)
	lw $a0, 1952($sp)
	jal func__print
	sw $v0, 5676($sp)
	lw $a0, 788($sp)
	jal func__toString
	sw $v0, 6480($sp)
	lw $a0, 6480($sp)
	la $a1, string_5530
	jal func__stringConcatenate
	sw $v0, 8452($sp)
	lw $a0, 8452($sp)
	jal func__print
	sw $v0, 8676($sp)
	lw $a0, 5616($sp)
	jal func__toString
	sw $v0, 1388($sp)
	lw $a0, 1388($sp)
	la $a1, string_5534
	jal func__stringConcatenate
	sw $v0, 2788($sp)
	lw $a0, 2788($sp)
	jal func__print
	sw $v0, 3972($sp)
	lw $a0, 9708($sp)
	jal func__toString
	sw $v0, 8828($sp)
	lw $a0, 8828($sp)
	la $a1, string_5538
	jal func__stringConcatenate
	sw $v0, 5092($sp)
	lw $a0, 5092($sp)
	jal func__print
	sw $v0, 5872($sp)
	lw $a0, 2920($sp)
	jal func__toString
	sw $v0, 4444($sp)
	lw $a0, 4444($sp)
	la $a1, string_5542
	jal func__stringConcatenate
	sw $v0, 4768($sp)
	lw $a0, 4768($sp)
	jal func__print
	sw $v0, 9160($sp)
	lw $a0, 3248($sp)
	jal func__toString
	sw $v0, 10068($sp)
	lw $a0, 10068($sp)
	la $a1, string_5546
	jal func__stringConcatenate
	sw $v0, 2960($sp)
	lw $a0, 2960($sp)
	jal func__print
	sw $v0, 1888($sp)
	lw $a0, 416($sp)
	jal func__toString
	sw $v0, 8684($sp)
	lw $a0, 8684($sp)
	la $a1, string_5550
	jal func__stringConcatenate
	sw $v0, 8028($sp)
	lw $a0, 8028($sp)
	jal func__print
	sw $v0, 5104($sp)
	lw $a0, 2264($sp)
	jal func__toString
	sw $v0, 4752($sp)
	lw $a0, 4752($sp)
	la $a1, string_5554
	jal func__stringConcatenate
	sw $v0, 10180($sp)
	lw $a0, 10180($sp)
	jal func__print
	sw $v0, 3064($sp)
	lw $a0, 8092($sp)
	jal func__toString
	sw $v0, 476($sp)
	lw $a0, 476($sp)
	la $a1, string_5558
	jal func__stringConcatenate
	sw $v0, 5228($sp)
	lw $a0, 5228($sp)
	jal func__print
	sw $v0, 1960($sp)
	lw $a0, 1048($sp)
	jal func__toString
	sw $v0, 8128($sp)
	lw $a0, 8128($sp)
	la $a1, string_5562
	jal func__stringConcatenate
	sw $v0, 5684($sp)
	lw $a0, 5684($sp)
	jal func__print
	sw $v0, 6564($sp)
	lw $a0, 7904($sp)
	jal func__toString
	sw $v0, 7176($sp)
	lw $a0, 7176($sp)
	la $a1, string_5566
	jal func__stringConcatenate
	sw $v0, 1908($sp)
	lw $a0, 1908($sp)
	jal func__print
	sw $v0, 6500($sp)
	lw $a0, 8368($sp)
	jal func__toString
	sw $v0, 3664($sp)
	lw $a0, 3664($sp)
	la $a1, string_5570
	jal func__stringConcatenate
	sw $v0, 6132($sp)
	lw $a0, 6132($sp)
	jal func__print
	sw $v0, 2348($sp)
	lw $a0, 4428($sp)
	jal func__toString
	sw $v0, 4136($sp)
	lw $a0, 4136($sp)
	la $a1, string_5574
	jal func__stringConcatenate
	sw $v0, 1748($sp)
	lw $a0, 1748($sp)
	jal func__print
	sw $v0, 8052($sp)
	lw $a0, 10192($sp)
	jal func__toString
	sw $v0, 8624($sp)
	lw $a0, 8624($sp)
	la $a1, string_5578
	jal func__stringConcatenate
	sw $v0, 8192($sp)
	lw $a0, 8192($sp)
	jal func__print
	sw $v0, 7068($sp)
	lw $a0, 2760($sp)
	jal func__toString
	sw $v0, 6888($sp)
	lw $a0, 6888($sp)
	la $a1, string_5582
	jal func__stringConcatenate
	sw $v0, 8404($sp)
	lw $a0, 8404($sp)
	jal func__print
	sw $v0, 8836($sp)
	lw $a0, 3636($sp)
	jal func__toString
	sw $v0, 9508($sp)
	lw $a0, 9508($sp)
	la $a1, string_5586
	jal func__stringConcatenate
	sw $v0, 1976($sp)
	lw $a0, 1976($sp)
	jal func__print
	sw $v0, 1620($sp)
	lw $a0, 9192($sp)
	jal func__toString
	sw $v0, 6532($sp)
	lw $a0, 6532($sp)
	la $a1, string_5590
	jal func__stringConcatenate
	sw $v0, 8100($sp)
	lw $a0, 8100($sp)
	jal func__print
	sw $v0, 5108($sp)
	lw $a0, 2968($sp)
	jal func__toString
	sw $v0, 9832($sp)
	lw $a0, 9832($sp)
	la $a1, string_5594
	jal func__stringConcatenate
	sw $v0, 6304($sp)
	lw $a0, 6304($sp)
	jal func__print
	sw $v0, 6048($sp)
	lw $a0, 220($sp)
	jal func__toString
	sw $v0, 3052($sp)
	lw $a0, 3052($sp)
	la $a1, string_5598
	jal func__stringConcatenate
	sw $v0, 9736($sp)
	lw $a0, 9736($sp)
	jal func__print
	sw $v0, 7284($sp)
	lw $a0, 9196($sp)
	jal func__toString
	sw $v0, 8048($sp)
	lw $a0, 8048($sp)
	la $a1, string_5602
	jal func__stringConcatenate
	sw $v0, 6544($sp)
	lw $a0, 6544($sp)
	jal func__print
	sw $v0, 4668($sp)
	lw $a0, 5248($sp)
	jal func__toString
	sw $v0, 5200($sp)
	lw $a0, 5200($sp)
	la $a1, string_5606
	jal func__stringConcatenate
	sw $v0, 660($sp)
	lw $a0, 660($sp)
	jal func__print
	sw $v0, 4360($sp)
	lw $a0, 488($sp)
	jal func__toString
	sw $v0, 420($sp)
	lw $a0, 420($sp)
	la $a1, string_5610
	jal func__stringConcatenate
	sw $v0, 8224($sp)
	lw $a0, 8224($sp)
	jal func__print
	sw $v0, 5376($sp)
	lw $a0, 6772($sp)
	jal func__toString
	sw $v0, 5528($sp)
	lw $a0, 5528($sp)
	la $a1, string_5614
	jal func__stringConcatenate
	sw $v0, 5124($sp)
	lw $a0, 5124($sp)
	jal func__print
	sw $v0, 1284($sp)
	lw $a0, 8168($sp)
	jal func__toString
	sw $v0, 9188($sp)
	lw $a0, 9188($sp)
	la $a1, string_5618
	jal func__stringConcatenate
	sw $v0, 3060($sp)
	lw $a0, 3060($sp)
	jal func__print
	sw $v0, 876($sp)
	lw $a0, 2476($sp)
	jal func__toString
	sw $v0, 7796($sp)
	lw $a0, 7796($sp)
	la $a1, string_5622
	jal func__stringConcatenate
	sw $v0, 1484($sp)
	lw $a0, 1484($sp)
	jal func__print
	sw $v0, 1488($sp)
	lw $a0, 2772($sp)
	jal func__toString
	sw $v0, 5596($sp)
	lw $a0, 5596($sp)
	la $a1, string_5626
	jal func__stringConcatenate
	sw $v0, 940($sp)
	lw $a0, 940($sp)
	jal func__print
	sw $v0, 6268($sp)
	lw $a0, 9424($sp)
	jal func__toString
	sw $v0, 2988($sp)
	lw $a0, 2988($sp)
	la $a1, string_5630
	jal func__stringConcatenate
	sw $v0, 5804($sp)
	lw $a0, 5804($sp)
	jal func__print
	sw $v0, 2240($sp)
	lw $a0, 7224($sp)
	jal func__toString
	sw $v0, 9340($sp)
	lw $a0, 9340($sp)
	la $a1, string_5634
	jal func__stringConcatenate
	sw $v0, 8164($sp)
	lw $a0, 8164($sp)
	jal func__print
	sw $v0, 368($sp)
	lw $a0, 4184($sp)
	jal func__toString
	sw $v0, 10328($sp)
	lw $a0, 10328($sp)
	la $a1, string_5638
	jal func__stringConcatenate
	sw $v0, 9364($sp)
	lw $a0, 9364($sp)
	jal func__print
	sw $v0, 8132($sp)
	lw $a0, 10168($sp)
	jal func__toString
	sw $v0, 4000($sp)
	lw $a0, 4000($sp)
	la $a1, string_5642
	jal func__stringConcatenate
	sw $v0, 1680($sp)
	lw $a0, 1680($sp)
	jal func__print
	sw $v0, 9552($sp)
	lw $a0, 172($sp)
	jal func__toString
	sw $v0, 8112($sp)
	lw $a0, 8112($sp)
	la $a1, string_5646
	jal func__stringConcatenate
	sw $v0, 2832($sp)
	lw $a0, 2832($sp)
	jal func__print
	sw $v0, 8572($sp)
	lw $a0, 5552($sp)
	jal func__toString
	sw $v0, 4168($sp)
	lw $a0, 4168($sp)
	la $a1, string_5650
	jal func__stringConcatenate
	sw $v0, 3308($sp)
	lw $a0, 3308($sp)
	jal func__print
	sw $v0, 9336($sp)
	lw $a0, 5392($sp)
	jal func__toString
	sw $v0, 7964($sp)
	lw $a0, 7964($sp)
	la $a1, string_5654
	jal func__stringConcatenate
	sw $v0, 4608($sp)
	lw $a0, 4608($sp)
	jal func__print
	sw $v0, 812($sp)
	lw $a0, 5512($sp)
	jal func__toString
	sw $v0, 3524($sp)
	lw $a0, 3524($sp)
	la $a1, string_5658
	jal func__stringConcatenate
	sw $v0, 4084($sp)
	lw $a0, 4084($sp)
	jal func__print
	sw $v0, 3988($sp)
	lw $a0, 6212($sp)
	jal func__toString
	sw $v0, 5916($sp)
	lw $a0, 5916($sp)
	la $a1, string_5662
	jal func__stringConcatenate
	sw $v0, 10380($sp)
	lw $a0, 10380($sp)
	jal func__print
	sw $v0, 4200($sp)
	lw $a0, 9680($sp)
	jal func__toString
	sw $v0, 872($sp)
	lw $a0, 872($sp)
	la $a1, string_5666
	jal func__stringConcatenate
	sw $v0, 9812($sp)
	lw $a0, 9812($sp)
	jal func__print
	sw $v0, 6876($sp)
	lw $a0, 1200($sp)
	jal func__toString
	sw $v0, 3748($sp)
	lw $a0, 3748($sp)
	la $a1, string_5670
	jal func__stringConcatenate
	sw $v0, 6664($sp)
	lw $a0, 6664($sp)
	jal func__print
	sw $v0, 8720($sp)
	lw $a0, 6112($sp)
	jal func__toString
	sw $v0, 4424($sp)
	lw $a0, 4424($sp)
	la $a1, string_5674
	jal func__stringConcatenate
	sw $v0, 5184($sp)
	lw $a0, 5184($sp)
	jal func__print
	sw $v0, 132($sp)
	lw $a0, 9616($sp)
	jal func__toString
	sw $v0, 1676($sp)
	lw $a0, 1676($sp)
	la $a1, string_5678
	jal func__stringConcatenate
	sw $v0, 7296($sp)
	lw $a0, 7296($sp)
	jal func__print
	sw $v0, 3008($sp)
	lw $a0, 2352($sp)
	jal func__toString
	sw $v0, 3708($sp)
	lw $a0, 3708($sp)
	la $a1, string_5682
	jal func__stringConcatenate
	sw $v0, 5848($sp)
	lw $a0, 5848($sp)
	jal func__print
	sw $v0, 8312($sp)
	lw $a0, 4052($sp)
	jal func__toString
	sw $v0, 148($sp)
	lw $a0, 148($sp)
	la $a1, string_5686
	jal func__stringConcatenate
	sw $v0, 1108($sp)
	lw $a0, 1108($sp)
	jal func__print
	sw $v0, 5620($sp)
	lw $a0, 8232($sp)
	jal func__toString
	sw $v0, 2376($sp)
	lw $a0, 2376($sp)
	la $a1, string_5690
	jal func__stringConcatenate
	sw $v0, 460($sp)
	lw $a0, 460($sp)
	jal func__print
	sw $v0, 7104($sp)
	lw $a0, 5456($sp)
	jal func__toString
	sw $v0, 7816($sp)
	lw $a0, 7816($sp)
	la $a1, string_5694
	jal func__stringConcatenate
	sw $v0, 1992($sp)
	lw $a0, 1992($sp)
	jal func__print
	sw $v0, 7020($sp)
	lw $a0, 10044($sp)
	jal func__toString
	sw $v0, 1756($sp)
	lw $a0, 1756($sp)
	la $a1, string_5698
	jal func__stringConcatenate
	sw $v0, 7492($sp)
	lw $a0, 7492($sp)
	jal func__print
	sw $v0, 6096($sp)
	lw $a0, 4440($sp)
	jal func__toString
	sw $v0, 3068($sp)
	lw $a0, 3068($sp)
	la $a1, string_5702
	jal func__stringConcatenate
	sw $v0, 4064($sp)
	lw $a0, 4064($sp)
	jal func__print
	sw $v0, 7772($sp)
	lw $a0, 7700($sp)
	jal func__toString
	sw $v0, 1584($sp)
	lw $a0, 1584($sp)
	la $a1, string_5706
	jal func__stringConcatenate
	sw $v0, 4260($sp)
	lw $a0, 4260($sp)
	jal func__print
	sw $v0, 4952($sp)
	lw $a0, 4620($sp)
	jal func__toString
	sw $v0, 3072($sp)
	lw $a0, 3072($sp)
	la $a1, string_5710
	jal func__stringConcatenate
	sw $v0, 4376($sp)
	lw $a0, 4376($sp)
	jal func__print
	sw $v0, 6144($sp)
	lw $a0, 436($sp)
	jal func__toString
	sw $v0, 9412($sp)
	lw $a0, 9412($sp)
	la $a1, string_5714
	jal func__stringConcatenate
	sw $v0, 6152($sp)
	lw $a0, 6152($sp)
	jal func__print
	sw $v0, 10392($sp)
	lw $a0, 9172($sp)
	jal func__toString
	sw $v0, 8688($sp)
	lw $a0, 8688($sp)
	la $a1, string_5718
	jal func__stringConcatenate
	sw $v0, 2388($sp)
	lw $a0, 2388($sp)
	jal func__print
	sw $v0, 9208($sp)
	lw $a0, 9444($sp)
	jal func__toString
	sw $v0, 1508($sp)
	lw $a0, 1508($sp)
	la $a1, string_5722
	jal func__stringConcatenate
	sw $v0, 6176($sp)
	lw $a0, 6176($sp)
	jal func__print
	sw $v0, 2576($sp)
	lw $a0, 1608($sp)
	jal func__toString
	sw $v0, 9248($sp)
	lw $a0, 9248($sp)
	la $a1, string_5726
	jal func__stringConcatenate
	sw $v0, 6808($sp)
	lw $a0, 6808($sp)
	jal func__print
	sw $v0, 6976($sp)
	lw $a0, 9368($sp)
	jal func__toString
	sw $v0, 8740($sp)
	lw $a0, 8740($sp)
	la $a1, string_5730
	jal func__stringConcatenate
	sw $v0, 3040($sp)
	lw $a0, 3040($sp)
	jal func__print
	sw $v0, 2392($sp)
	lw $a0, 3776($sp)
	jal func__toString
	sw $v0, 2472($sp)
	lw $a0, 2472($sp)
	la $a1, string_5734
	jal func__stringConcatenate
	sw $v0, 4108($sp)
	lw $a0, 4108($sp)
	jal func__print
	sw $v0, 2404($sp)
	lw $a0, 9468($sp)
	jal func__toString
	sw $v0, 7848($sp)
	lw $a0, 7848($sp)
	la $a1, string_5738
	jal func__stringConcatenate
	sw $v0, 7024($sp)
	lw $a0, 7024($sp)
	jal func__print
	sw $v0, 3476($sp)
	lw $a0, 5280($sp)
	jal func__toString
	sw $v0, 6204($sp)
	lw $a0, 6204($sp)
	la $a1, string_5742
	jal func__stringConcatenate
	sw $v0, 4672($sp)
	lw $a0, 4672($sp)
	jal func__print
	sw $v0, 8708($sp)
	lw $a0, 6160($sp)
	jal func__toString
	sw $v0, 6788($sp)
	lw $a0, 6788($sp)
	la $a1, string_5746
	jal func__stringConcatenate
	sw $v0, 5688($sp)
	lw $a0, 5688($sp)
	jal func__print
	sw $v0, 7436($sp)
	lw $a0, 2740($sp)
	jal func__toString
	sw $v0, 2904($sp)
	lw $a0, 2904($sp)
	la $a1, string_5750
	jal func__stringConcatenate
	sw $v0, 5440($sp)
	lw $a0, 5440($sp)
	jal func__print
	sw $v0, 10136($sp)
	lw $a0, 2808($sp)
	jal func__toString
	sw $v0, 3436($sp)
	lw $a0, 3436($sp)
	la $a1, string_5754
	jal func__stringConcatenate
	sw $v0, 2424($sp)
	lw $a0, 2424($sp)
	jal func__print
	sw $v0, 8796($sp)
	lw $a0, 7352($sp)
	jal func__toString
	sw $v0, 4240($sp)
	lw $a0, 4240($sp)
	la $a1, string_5758
	jal func__stringConcatenate
	sw $v0, 288($sp)
	lw $a0, 288($sp)
	jal func__print
	sw $v0, 6052($sp)
	lw $a0, 4100($sp)
	jal func__toString
	sw $v0, 8360($sp)
	lw $a0, 8360($sp)
	la $a1, string_5762
	jal func__stringConcatenate
	sw $v0, 7508($sp)
	lw $a0, 7508($sp)
	jal func__print
	sw $v0, 5656($sp)
	lw $a0, 9332($sp)
	jal func__toString
	sw $v0, 8752($sp)
	lw $a0, 8752($sp)
	la $a1, string_5766
	jal func__stringConcatenate
	sw $v0, 356($sp)
	lw $a0, 356($sp)
	jal func__print
	sw $v0, 336($sp)
	lw $a0, 8636($sp)
	jal func__toString
	sw $v0, 4128($sp)
	lw $a0, 4128($sp)
	la $a1, string_5770
	jal func__stringConcatenate
	sw $v0, 3380($sp)
	lw $a0, 3380($sp)
	jal func__print
	sw $v0, 8336($sp)
	lw $a0, 3900($sp)
	jal func__toString
	sw $v0, 7396($sp)
	lw $a0, 7396($sp)
	la $a1, string_5774
	jal func__stringConcatenate
	sw $v0, 8728($sp)
	lw $a0, 8728($sp)
	jal func__print
	sw $v0, 9732($sp)
	lw $a0, 2480($sp)
	jal func__toString
	sw $v0, 3828($sp)
	lw $a0, 3828($sp)
	la $a1, string_5778
	jal func__stringConcatenate
	sw $v0, 9856($sp)
	lw $a0, 9856($sp)
	jal func__print
	sw $v0, 10004($sp)
	lw $a0, 8108($sp)
	jal func__toString
	sw $v0, 3692($sp)
	lw $a0, 3692($sp)
	la $a1, string_5782
	jal func__stringConcatenate
	sw $v0, 4216($sp)
	lw $a0, 4216($sp)
	jal func__print
	sw $v0, 4816($sp)
	lw $a0, 1532($sp)
	jal func__toString
	sw $v0, 1340($sp)
	lw $a0, 1340($sp)
	la $a1, string_5786
	jal func__stringConcatenate
	sw $v0, 3212($sp)
	lw $a0, 3212($sp)
	jal func__print
	sw $v0, 3192($sp)
	lw $a0, 1232($sp)
	jal func__toString
	sw $v0, 9272($sp)
	lw $a0, 9272($sp)
	la $a1, string_5790
	jal func__stringConcatenate
	sw $v0, 328($sp)
	lw $a0, 328($sp)
	jal func__print
	sw $v0, 2244($sp)
	lw $a0, 6800($sp)
	jal func__toString
	sw $v0, 7620($sp)
	lw $a0, 7620($sp)
	la $a1, string_5794
	jal func__stringConcatenate
	sw $v0, 7752($sp)
	lw $a0, 7752($sp)
	jal func__print
	sw $v0, 4944($sp)
	lw $a0, 8844($sp)
	jal func__toString
	sw $v0, 7764($sp)
	lw $a0, 7764($sp)
	la $a1, string_5798
	jal func__stringConcatenate
	sw $v0, 396($sp)
	lw $a0, 396($sp)
	jal func__print
	sw $v0, 4452($sp)
	lw $a0, 4976($sp)
	jal func__toString
	sw $v0, 10160($sp)
	lw $a0, 10160($sp)
	la $a1, string_5802
	jal func__stringConcatenate
	sw $v0, 1524($sp)
	lw $a0, 1524($sp)
	jal func__print
	sw $v0, 10016($sp)
	lw $a0, 292($sp)
	jal func__toString
	sw $v0, 3016($sp)
	lw $a0, 3016($sp)
	la $a1, string_5806
	jal func__stringConcatenate
	sw $v0, 4344($sp)
	lw $a0, 4344($sp)
	jal func__print
	sw $v0, 10260($sp)
	lw $a0, 6756($sp)
	jal func__toString
	sw $v0, 4412($sp)
	lw $a0, 4412($sp)
	la $a1, string_5810
	jal func__stringConcatenate
	sw $v0, 5052($sp)
	lw $a0, 5052($sp)
	jal func__print
	sw $v0, 4564($sp)
	lw $a0, 7292($sp)
	jal func__toString
	sw $v0, 8144($sp)
	lw $a0, 8144($sp)
	la $a1, string_5814
	jal func__stringConcatenate
	sw $v0, 2936($sp)
	lw $a0, 2936($sp)
	jal func__print
	sw $v0, 268($sp)
	lw $a0, 9280($sp)
	jal func__toString
	sw $v0, 10220($sp)
	lw $a0, 10220($sp)
	la $a1, string_5818
	jal func__stringConcatenate
	sw $v0, 8000($sp)
	lw $a0, 8000($sp)
	jal func__print
	sw $v0, 8292($sp)
	lw $a0, 8272($sp)
	jal func__toString
	sw $v0, 10336($sp)
	lw $a0, 10336($sp)
	la $a1, string_5822
	jal func__stringConcatenate
	sw $v0, 5888($sp)
	lw $a0, 5888($sp)
	jal func__print
	sw $v0, 4256($sp)
	lw $a0, 3888($sp)
	jal func__toString
	sw $v0, 1892($sp)
	lw $a0, 1892($sp)
	la $a1, string_5826
	jal func__stringConcatenate
	sw $v0, 2684($sp)
	lw $a0, 2684($sp)
	jal func__print
	sw $v0, 5844($sp)
	lw $a0, 376($sp)
	jal func__toString
	sw $v0, 6860($sp)
	lw $a0, 6860($sp)
	la $a1, string_5830
	jal func__stringConcatenate
	sw $v0, 4464($sp)
	lw $a0, 4464($sp)
	jal func__print
	sw $v0, 308($sp)
	lw $a0, 8724($sp)
	jal func__toString
	sw $v0, 3948($sp)
	lw $a0, 3948($sp)
	la $a1, string_5834
	jal func__stringConcatenate
	sw $v0, 6248($sp)
	lw $a0, 6248($sp)
	jal func__print
	sw $v0, 1928($sp)
	lw $a0, 5272($sp)
	jal func__toString
	sw $v0, 6468($sp)
	lw $a0, 6468($sp)
	la $a1, string_5838
	jal func__stringConcatenate
	sw $v0, 2248($sp)
	lw $a0, 2248($sp)
	jal func__print
	sw $v0, 8264($sp)
	lw $a0, 10400($sp)
	jal func__toString
	sw $v0, 2844($sp)
	lw $a0, 2844($sp)
	la $a1, string_5842
	jal func__stringConcatenate
	sw $v0, 232($sp)
	lw $a0, 232($sp)
	jal func__print
	sw $v0, 5064($sp)
	lw $a0, 10200($sp)
	jal func__toString
	sw $v0, 10256($sp)
	lw $a0, 10256($sp)
	la $a1, string_5846
	jal func__stringConcatenate
	sw $v0, 484($sp)
	lw $a0, 484($sp)
	jal func__print
	sw $v0, 1752($sp)
	lw $a0, 592($sp)
	jal func__toString
	sw $v0, 8824($sp)
	lw $a0, 8824($sp)
	la $a1, string_5850
	jal func__stringConcatenate
	sw $v0, 2924($sp)
	lw $a0, 2924($sp)
	jal func__print
	sw $v0, 1000($sp)
	lw $a0, 3092($sp)
	jal func__toString
	sw $v0, 1460($sp)
	lw $a0, 1460($sp)
	la $a1, string_5854
	jal func__stringConcatenate
	sw $v0, 4612($sp)
	lw $a0, 4612($sp)
	jal func__print
	sw $v0, 10296($sp)
	lw $a0, 6604($sp)
	jal func__toString
	sw $v0, 10272($sp)
	lw $a0, 10272($sp)
	la $a1, string_5858
	jal func__stringConcatenate
	sw $v0, 7372($sp)
	lw $a0, 7372($sp)
	jal func__print
	sw $v0, 1456($sp)
	lw $a0, 364($sp)
	jal func__toString
	sw $v0, 10204($sp)
	lw $a0, 10204($sp)
	la $a1, string_5862
	jal func__stringConcatenate
	sw $v0, 3036($sp)
	lw $a0, 3036($sp)
	jal func__print
	sw $v0, 9252($sp)
	lw $a0, 8384($sp)
	jal func__toString
	sw $v0, 10208($sp)
	lw $a0, 10208($sp)
	la $a1, string_5866
	jal func__stringConcatenate
	sw $v0, 10300($sp)
	lw $a0, 10300($sp)
	jal func__print
	sw $v0, 2280($sp)
	lw $a0, 9408($sp)
	jal func__toString
	sw $v0, 9636($sp)
	lw $a0, 9636($sp)
	la $a1, string_5870
	jal func__stringConcatenate
	sw $v0, 6740($sp)
	lw $a0, 6740($sp)
	jal func__print
	sw $v0, 8776($sp)
	lw $a0, 4180($sp)
	jal func__toString
	sw $v0, 2952($sp)
	lw $a0, 2952($sp)
	la $a1, string_5874
	jal func__stringConcatenate
	sw $v0, 5740($sp)
	lw $a0, 5740($sp)
	jal func__print
	sw $v0, 920($sp)
	lw $a0, 4908($sp)
	jal func__toString
	sw $v0, 9044($sp)
	lw $a0, 9044($sp)
	la $a1, string_5878
	jal func__stringConcatenate
	sw $v0, 7252($sp)
	lw $a0, 7252($sp)
	jal func__print
	sw $v0, 4772($sp)
	lw $a0, 6864($sp)
	jal func__toString
	sw $v0, 5120($sp)
	lw $a0, 5120($sp)
	la $a1, string_5882
	jal func__stringConcatenate
	sw $v0, 7860($sp)
	lw $a0, 7860($sp)
	jal func__print
	sw $v0, 1016($sp)
	lw $a0, 3516($sp)
	jal func__toString
	sw $v0, 5920($sp)
	lw $a0, 5920($sp)
	la $a1, string_5886
	jal func__stringConcatenate
	sw $v0, 6064($sp)
	lw $a0, 6064($sp)
	jal func__print
	sw $v0, 9012($sp)
	lw $a0, 5012($sp)
	jal func__toString
	sw $v0, 3840($sp)
	lw $a0, 3840($sp)
	la $a1, string_5890
	jal func__stringConcatenate
	sw $v0, 6384($sp)
	lw $a0, 6384($sp)
	jal func__print
	sw $v0, 5712($sp)
	lw $a0, 1464($sp)
	jal func__toString
	sw $v0, 7008($sp)
	lw $a0, 7008($sp)
	la $a1, string_5894
	jal func__stringConcatenate
	sw $v0, 5364($sp)
	lw $a0, 5364($sp)
	jal func__print
	sw $v0, 1504($sp)
	lw $a0, 6504($sp)
	jal func__toString
	sw $v0, 4692($sp)
	lw $a0, 4692($sp)
	la $a1, string_5898
	jal func__stringConcatenate
	sw $v0, 312($sp)
	lw $a0, 312($sp)
	jal func__print
	sw $v0, 3640($sp)
	lw $a0, 2548($sp)
	jal func__toString
	sw $v0, 2828($sp)
	lw $a0, 2828($sp)
	la $a1, string_5902
	jal func__stringConcatenate
	sw $v0, 1828($sp)
	lw $a0, 1828($sp)
	jal func__print
	sw $v0, 2732($sp)
	lw $a0, 8268($sp)
	jal func__toString
	sw $v0, 8592($sp)
	lw $a0, 8592($sp)
	la $a1, string_5906
	jal func__stringConcatenate
	sw $v0, 9300($sp)
	lw $a0, 9300($sp)
	jal func__print
	sw $v0, 7184($sp)
	lw $a0, 4228($sp)
	jal func__toString
	sw $v0, 2532($sp)
	lw $a0, 2532($sp)
	la $a1, string_5910
	jal func__stringConcatenate
	sw $v0, 4628($sp)
	lw $a0, 4628($sp)
	jal func__print
	sw $v0, 404($sp)
	lw $a0, 9420($sp)
	jal func__toString
	sw $v0, 4088($sp)
	lw $a0, 4088($sp)
	la $a1, string_5914
	jal func__stringConcatenate
	sw $v0, 7580($sp)
	lw $a0, 7580($sp)
	jal func__print
	sw $v0, 3572($sp)
	lw $a0, 7724($sp)
	jal func__toString
	sw $v0, 4144($sp)
	lw $a0, 4144($sp)
	la $a1, string_5918
	jal func__stringConcatenate
	sw $v0, 9256($sp)
	lw $a0, 9256($sp)
	jal func__print
	sw $v0, 3744($sp)
	lw $a0, 5000($sp)
	jal func__toString
	sw $v0, 452($sp)
	lw $a0, 452($sp)
	la $a1, string_5922
	jal func__stringConcatenate
	sw $v0, 7872($sp)
	lw $a0, 7872($sp)
	jal func__print
	sw $v0, 9460($sp)
	lw $a0, 7908($sp)
	jal func__toString
	sw $v0, 192($sp)
	lw $a0, 192($sp)
	la $a1, string_5926
	jal func__stringConcatenate
	sw $v0, 1092($sp)
	lw $a0, 1092($sp)
	jal func__print
	sw $v0, 10176($sp)
	lw $a0, 2132($sp)
	jal func__toString
	sw $v0, 1668($sp)
	lw $a0, 1668($sp)
	la $a1, string_5930
	jal func__stringConcatenate
	sw $v0, 1728($sp)
	lw $a0, 1728($sp)
	jal func__print
	sw $v0, 2868($sp)
	lw $a0, 8140($sp)
	jal func__toString
	sw $v0, 6220($sp)
	lw $a0, 6220($sp)
	la $a1, string_5934
	jal func__stringConcatenate
	sw $v0, 296($sp)
	lw $a0, 296($sp)
	jal func__print
	sw $v0, 9956($sp)
	lw $a0, 840($sp)
	jal func__toString
	sw $v0, 2560($sp)
	lw $a0, 2560($sp)
	la $a1, string_5938
	jal func__stringConcatenate
	sw $v0, 1684($sp)
	lw $a0, 1684($sp)
	jal func__print
	sw $v0, 8012($sp)
	lw $a0, 8976($sp)
	jal func__toString
	sw $v0, 7136($sp)
	lw $a0, 7136($sp)
	la $a1, string_5942
	jal func__stringConcatenate
	sw $v0, 10096($sp)
	lw $a0, 10096($sp)
	jal func__print
	sw $v0, 7716($sp)
	lw $a0, 9200($sp)
	jal func__toString
	sw $v0, 3156($sp)
	lw $a0, 3156($sp)
	la $a1, string_5946
	jal func__stringConcatenate
	sw $v0, 8388($sp)
	lw $a0, 8388($sp)
	jal func__print
	sw $v0, 2116($sp)
	la $a0, string_5949
	jal func__println
	sw $v0, 7732($sp)
	lw $a0, 5080($sp)
	jal func__toString
	sw $v0, 8096($sp)
	lw $a0, 8096($sp)
	la $a1, string_5952
	jal func__stringConcatenate
	sw $v0, 4112($sp)
	lw $a0, 4112($sp)
	jal func__print
	sw $v0, 8840($sp)
	lw $a0, 5784($sp)
	jal func__toString
	sw $v0, 9476($sp)
	lw $a0, 9476($sp)
	la $a1, string_5956
	jal func__stringConcatenate
	sw $v0, 5100($sp)
	lw $a0, 5100($sp)
	jal func__print
	sw $v0, 4336($sp)
	lw $a0, 9216($sp)
	jal func__toString
	sw $v0, 9108($sp)
	lw $a0, 9108($sp)
	la $a1, string_5960
	jal func__stringConcatenate
	sw $v0, 7160($sp)
	lw $a0, 7160($sp)
	jal func__print
	sw $v0, 3632($sp)
	lw $a0, 820($sp)
	jal func__toString
	sw $v0, 8984($sp)
	lw $a0, 8984($sp)
	la $a1, string_5964
	jal func__stringConcatenate
	sw $v0, 904($sp)
	lw $a0, 904($sp)
	jal func__print
	sw $v0, 8672($sp)
	lw $a0, 9324($sp)
	jal func__toString
	sw $v0, 5532($sp)
	lw $a0, 5532($sp)
	la $a1, string_5968
	jal func__stringConcatenate
	sw $v0, 5700($sp)
	lw $a0, 5700($sp)
	jal func__print
	sw $v0, 2876($sp)
	lw $a0, 1572($sp)
	jal func__toString
	sw $v0, 5536($sp)
	lw $a0, 5536($sp)
	la $a1, string_5972
	jal func__stringConcatenate
	sw $v0, 3024($sp)
	lw $a0, 3024($sp)
	jal func__print
	sw $v0, 3980($sp)
	lw $a0, 4080($sp)
	jal func__toString
	sw $v0, 9372($sp)
	lw $a0, 9372($sp)
	la $a1, string_5976
	jal func__stringConcatenate
	sw $v0, 2640($sp)
	lw $a0, 2640($sp)
	jal func__print
	sw $v0, 9152($sp)
	lw $a0, 7356($sp)
	jal func__toString
	sw $v0, 1596($sp)
	lw $a0, 1596($sp)
	la $a1, string_5980
	jal func__stringConcatenate
	sw $v0, 8344($sp)
	lw $a0, 8344($sp)
	jal func__print
	sw $v0, 1980($sp)
	lw $a0, 7420($sp)
	jal func__toString
	sw $v0, 832($sp)
	lw $a0, 832($sp)
	la $a1, string_5984
	jal func__stringConcatenate
	sw $v0, 7784($sp)
	lw $a0, 7784($sp)
	jal func__print
	sw $v0, 3232($sp)
	lw $a0, 9112($sp)
	jal func__toString
	sw $v0, 3912($sp)
	lw $a0, 3912($sp)
	la $a1, string_5988
	jal func__stringConcatenate
	sw $v0, 7444($sp)
	lw $a0, 7444($sp)
	jal func__print
	sw $v0, 8084($sp)
	lw $a0, 9792($sp)
	jal func__toString
	sw $v0, 8616($sp)
	lw $a0, 8616($sp)
	la $a1, string_5992
	jal func__stringConcatenate
	sw $v0, 6568($sp)
	lw $a0, 6568($sp)
	jal func__print
	sw $v0, 7708($sp)
	lw $a0, 8284($sp)
	jal func__toString
	sw $v0, 7916($sp)
	lw $a0, 7916($sp)
	la $a1, string_5996
	jal func__stringConcatenate
	sw $v0, 1420($sp)
	lw $a0, 1420($sp)
	jal func__print
	sw $v0, 5136($sp)
	lw $a0, 10384($sp)
	jal func__toString
	sw $v0, 7232($sp)
	lw $a0, 7232($sp)
	la $a1, string_6000
	jal func__stringConcatenate
	sw $v0, 9040($sp)
	lw $a0, 9040($sp)
	jal func__print
	sw $v0, 1132($sp)
	lw $a0, 3288($sp)
	jal func__toString
	sw $v0, 2736($sp)
	lw $a0, 2736($sp)
	la $a1, string_6004
	jal func__stringConcatenate
	sw $v0, 9276($sp)
	lw $a0, 9276($sp)
	jal func__print
	sw $v0, 5508($sp)
	lw $a0, 3356($sp)
	jal func__toString
	sw $v0, 4580($sp)
	lw $a0, 4580($sp)
	la $a1, string_6008
	jal func__stringConcatenate
	sw $v0, 5156($sp)
	lw $a0, 5156($sp)
	jal func__print
	sw $v0, 2268($sp)
	lw $a0, 3220($sp)
	jal func__toString
	sw $v0, 6404($sp)
	lw $a0, 6404($sp)
	la $a1, string_6012
	jal func__stringConcatenate
	sw $v0, 4660($sp)
	lw $a0, 4660($sp)
	jal func__print
	sw $v0, 2672($sp)
	lw $a0, 3240($sp)
	jal func__toString
	sw $v0, 7340($sp)
	lw $a0, 7340($sp)
	la $a1, string_6016
	jal func__stringConcatenate
	sw $v0, 6592($sp)
	lw $a0, 6592($sp)
	jal func__print
	sw $v0, 804($sp)
	lw $a0, 4780($sp)
	jal func__toString
	sw $v0, 3656($sp)
	lw $a0, 3656($sp)
	la $a1, string_6020
	jal func__stringConcatenate
	sw $v0, 9360($sp)
	lw $a0, 9360($sp)
	jal func__print
	sw $v0, 2356($sp)
	lw $a0, 10340($sp)
	jal func__toString
	sw $v0, 1724($sp)
	lw $a0, 1724($sp)
	la $a1, string_6024
	jal func__stringConcatenate
	sw $v0, 1556($sp)
	lw $a0, 1556($sp)
	jal func__print
	sw $v0, 9704($sp)
	lw $a0, 8064($sp)
	jal func__toString
	sw $v0, 1496($sp)
	lw $a0, 1496($sp)
	la $a1, string_6028
	jal func__stringConcatenate
	sw $v0, 2792($sp)
	lw $a0, 2792($sp)
	jal func__print
	sw $v0, 4960($sp)
	lw $a0, 6588($sp)
	jal func__toString
	sw $v0, 2220($sp)
	lw $a0, 2220($sp)
	la $a1, string_6032
	jal func__stringConcatenate
	sw $v0, 2584($sp)
	lw $a0, 2584($sp)
	jal func__print
	sw $v0, 5192($sp)
	lw $a0, 7552($sp)
	jal func__toString
	sw $v0, 8220($sp)
	lw $a0, 8220($sp)
	la $a1, string_6036
	jal func__stringConcatenate
	sw $v0, 2212($sp)
	lw $a0, 2212($sp)
	jal func__print
	sw $v0, 6068($sp)
	lw $a0, 9376($sp)
	jal func__toString
	sw $v0, 456($sp)
	lw $a0, 456($sp)
	la $a1, string_6040
	jal func__stringConcatenate
	sw $v0, 8768($sp)
	lw $a0, 8768($sp)
	jal func__print
	sw $v0, 2456($sp)
	lw $a0, 10304($sp)
	jal func__toString
	sw $v0, 980($sp)
	lw $a0, 980($sp)
	la $a1, string_6044
	jal func__stringConcatenate
	sw $v0, 3332($sp)
	lw $a0, 3332($sp)
	jal func__print
	sw $v0, 1912($sp)
	lw $a0, 3976($sp)
	jal func__toString
	sw $v0, 5408($sp)
	lw $a0, 5408($sp)
	la $a1, string_6048
	jal func__stringConcatenate
	sw $v0, 8832($sp)
	lw $a0, 8832($sp)
	jal func__print
	sw $v0, 7376($sp)
	lw $a0, 2088($sp)
	jal func__toString
	sw $v0, 184($sp)
	lw $a0, 184($sp)
	la $a1, string_6052
	jal func__stringConcatenate
	sw $v0, 5704($sp)
	lw $a0, 5704($sp)
	jal func__print
	sw $v0, 8204($sp)
	lw $a0, 6312($sp)
	jal func__toString
	sw $v0, 3788($sp)
	lw $a0, 3788($sp)
	la $a1, string_6056
	jal func__stringConcatenate
	sw $v0, 2328($sp)
	lw $a0, 2328($sp)
	jal func__print
	sw $v0, 8240($sp)
	lw $a0, 8524($sp)
	jal func__toString
	sw $v0, 4728($sp)
	lw $a0, 4728($sp)
	la $a1, string_6060
	jal func__stringConcatenate
	sw $v0, 8948($sp)
	lw $a0, 8948($sp)
	jal func__print
	sw $v0, 8172($sp)
	lw $a0, 2188($sp)
	jal func__toString
	sw $v0, 9396($sp)
	lw $a0, 9396($sp)
	la $a1, string_6064
	jal func__stringConcatenate
	sw $v0, 6492($sp)
	lw $a0, 6492($sp)
	jal func__print
	sw $v0, 7840($sp)
	lw $a0, 1520($sp)
	jal func__toString
	sw $v0, 8412($sp)
	lw $a0, 8412($sp)
	la $a1, string_6068
	jal func__stringConcatenate
	sw $v0, 1364($sp)
	lw $a0, 1364($sp)
	jal func__print
	sw $v0, 6128($sp)
	lw $a0, 6540($sp)
	jal func__toString
	sw $v0, 3184($sp)
	lw $a0, 3184($sp)
	la $a1, string_6072
	jal func__stringConcatenate
	sw $v0, 4416($sp)
	lw $a0, 4416($sp)
	jal func__print
	sw $v0, 7800($sp)
	lw $a0, 8024($sp)
	jal func__toString
	sw $v0, 3832($sp)
	lw $a0, 3832($sp)
	la $a1, string_6076
	jal func__stringConcatenate
	sw $v0, 4680($sp)
	lw $a0, 4680($sp)
	jal func__print
	sw $v0, 7196($sp)
	lw $a0, 9440($sp)
	jal func__toString
	sw $v0, 4124($sp)
	lw $a0, 4124($sp)
	la $a1, string_6080
	jal func__stringConcatenate
	sw $v0, 8308($sp)
	lw $a0, 8308($sp)
	jal func__print
	sw $v0, 2764($sp)
	lw $a0, 8260($sp)
	jal func__toString
	sw $v0, 7212($sp)
	lw $a0, 7212($sp)
	la $a1, string_6084
	jal func__stringConcatenate
	sw $v0, 7156($sp)
	lw $a0, 7156($sp)
	jal func__print
	sw $v0, 424($sp)
	lw $a0, 2056($sp)
	jal func__toString
	sw $v0, 3388($sp)
	lw $a0, 3388($sp)
	la $a1, string_6088
	jal func__stringConcatenate
	sw $v0, 7472($sp)
	lw $a0, 7472($sp)
	jal func__print
	sw $v0, 6944($sp)
	lw $a0, 3580($sp)
	jal func__toString
	sw $v0, 2324($sp)
	lw $a0, 2324($sp)
	la $a1, string_6092
	jal func__stringConcatenate
	sw $v0, 3316($sp)
	lw $a0, 3316($sp)
	jal func__print
	sw $v0, 6852($sp)
	lw $a0, 6572($sp)
	jal func__toString
	sw $v0, 7652($sp)
	lw $a0, 7652($sp)
	la $a1, string_6096
	jal func__stringConcatenate
	sw $v0, 4284($sp)
	lw $a0, 4284($sp)
	jal func__print
	sw $v0, 2028($sp)
	lw $a0, 3088($sp)
	jal func__toString
	sw $v0, 10124($sp)
	lw $a0, 10124($sp)
	la $a1, string_6100
	jal func__stringConcatenate
	sw $v0, 8432($sp)
	lw $a0, 8432($sp)
	jal func__print
	sw $v0, 2252($sp)
	lw $a0, 884($sp)
	jal func__toString
	sw $v0, 8712($sp)
	lw $a0, 8712($sp)
	la $a1, string_6104
	jal func__stringConcatenate
	sw $v0, 6140($sp)
	lw $a0, 6140($sp)
	jal func__print
	sw $v0, 1188($sp)
	lw $a0, 5152($sp)
	jal func__toString
	sw $v0, 464($sp)
	lw $a0, 464($sp)
	la $a1, string_6108
	jal func__stringConcatenate
	sw $v0, 6764($sp)
	lw $a0, 6764($sp)
	jal func__print
	sw $v0, 10060($sp)
	lw $a0, 9348($sp)
	jal func__toString
	sw $v0, 8116($sp)
	lw $a0, 8116($sp)
	la $a1, string_6112
	jal func__stringConcatenate
	sw $v0, 6624($sp)
	lw $a0, 6624($sp)
	jal func__print
	sw $v0, 4552($sp)
	lw $a0, 8392($sp)
	jal func__toString
	sw $v0, 9608($sp)
	lw $a0, 9608($sp)
	la $a1, string_6116
	jal func__stringConcatenate
	sw $v0, 6328($sp)
	lw $a0, 6328($sp)
	jal func__print
	sw $v0, 5412($sp)
	lw $a0, 3260($sp)
	jal func__toString
	sw $v0, 6376($sp)
	lw $a0, 6376($sp)
	la $a1, string_6120
	jal func__stringConcatenate
	sw $v0, 2492($sp)
	lw $a0, 2492($sp)
	jal func__print
	sw $v0, 1112($sp)
	lw $a0, 4880($sp)
	jal func__toString
	sw $v0, 4688($sp)
	lw $a0, 4688($sp)
	la $a1, string_6124
	jal func__stringConcatenate
	sw $v0, 9672($sp)
	lw $a0, 9672($sp)
	jal func__print
	sw $v0, 2676($sp)
	lw $a0, 5436($sp)
	jal func__toString
	sw $v0, 9600($sp)
	lw $a0, 9600($sp)
	la $a1, string_6128
	jal func__stringConcatenate
	sw $v0, 9532($sp)
	lw $a0, 9532($sp)
	jal func__print
	sw $v0, 6752($sp)
	lw $a0, 996($sp)
	jal func__toString
	sw $v0, 7756($sp)
	lw $a0, 7756($sp)
	la $a1, string_6132
	jal func__stringConcatenate
	sw $v0, 656($sp)
	lw $a0, 656($sp)
	jal func__print
	sw $v0, 6020($sp)
	lw $a0, 7476($sp)
	jal func__toString
	sw $v0, 7168($sp)
	lw $a0, 7168($sp)
	la $a1, string_6136
	jal func__stringConcatenate
	sw $v0, 3416($sp)
	lw $a0, 3416($sp)
	jal func__print
	sw $v0, 4432($sp)
	lw $a0, 952($sp)
	jal func__toString
	sw $v0, 4172($sp)
	lw $a0, 4172($sp)
	la $a1, string_6140
	jal func__stringConcatenate
	sw $v0, 524($sp)
	lw $a0, 524($sp)
	jal func__print
	sw $v0, 7952($sp)
	lw $a0, 7656($sp)
	jal func__toString
	sw $v0, 156($sp)
	lw $a0, 156($sp)
	la $a1, string_6144
	jal func__stringConcatenate
	sw $v0, 6288($sp)
	lw $a0, 6288($sp)
	jal func__print
	sw $v0, 2460($sp)
	lw $a0, 9292($sp)
	jal func__toString
	sw $v0, 8088($sp)
	lw $a0, 8088($sp)
	la $a1, string_6148
	jal func__stringConcatenate
	sw $v0, 4856($sp)
	lw $a0, 4856($sp)
	jal func__print
	sw $v0, 4492($sp)
	lw $a0, 9060($sp)
	jal func__toString
	sw $v0, 4320($sp)
	lw $a0, 4320($sp)
	la $a1, string_6152
	jal func__stringConcatenate
	sw $v0, 9756($sp)
	lw $a0, 9756($sp)
	jal func__print
	sw $v0, 8068($sp)
	lw $a0, 9720($sp)
	jal func__toString
	sw $v0, 4804($sp)
	lw $a0, 4804($sp)
	la $a1, string_6156
	jal func__stringConcatenate
	sw $v0, 4636($sp)
	lw $a0, 4636($sp)
	jal func__print
	sw $v0, 9236($sp)
	lw $a0, 5600($sp)
	jal func__toString
	sw $v0, 3196($sp)
	lw $a0, 3196($sp)
	la $a1, string_6160
	jal func__stringConcatenate
	sw $v0, 8548($sp)
	lw $a0, 8548($sp)
	jal func__print
	sw $v0, 7600($sp)
	lw $a0, 5172($sp)
	jal func__toString
	sw $v0, 8056($sp)
	lw $a0, 8056($sp)
	la $a1, string_6164
	jal func__stringConcatenate
	sw $v0, 5624($sp)
	lw $a0, 5624($sp)
	jal func__print
	sw $v0, 1256($sp)
	lw $a0, 4964($sp)
	jal func__toString
	sw $v0, 7540($sp)
	lw $a0, 7540($sp)
	la $a1, string_6168
	jal func__stringConcatenate
	sw $v0, 4732($sp)
	lw $a0, 4732($sp)
	jal func__print
	sw $v0, 1272($sp)
	lw $a0, 7696($sp)
	jal func__toString
	sw $v0, 8632($sp)
	lw $a0, 8632($sp)
	la $a1, string_6172
	jal func__stringConcatenate
	sw $v0, 8356($sp)
	lw $a0, 8356($sp)
	jal func__print
	sw $v0, 8428($sp)
	lw $a0, 8516($sp)
	jal func__toString
	sw $v0, 7932($sp)
	lw $a0, 7932($sp)
	la $a1, string_6176
	jal func__stringConcatenate
	sw $v0, 1616($sp)
	lw $a0, 1616($sp)
	jal func__print
	sw $v0, 7360($sp)
	lw $a0, 4896($sp)
	jal func__toString
	sw $v0, 1468($sp)
	lw $a0, 1468($sp)
	la $a1, string_6180
	jal func__stringConcatenate
	sw $v0, 3564($sp)
	lw $a0, 3564($sp)
	jal func__print
	sw $v0, 6776($sp)
	lw $a0, 10056($sp)
	jal func__toString
	sw $v0, 1548($sp)
	lw $a0, 1548($sp)
	la $a1, string_6184
	jal func__stringConcatenate
	sw $v0, 8396($sp)
	lw $a0, 8396($sp)
	jal func__print
	sw $v0, 2164($sp)
	lw $a0, 5252($sp)
	jal func__toString
	sw $v0, 3512($sp)
	lw $a0, 3512($sp)
	la $a1, string_6188
	jal func__stringConcatenate
	sw $v0, 1068($sp)
	lw $a0, 1068($sp)
	jal func__print
	sw $v0, 2100($sp)
	lw $a0, 1344($sp)
	jal func__toString
	sw $v0, 3964($sp)
	lw $a0, 3964($sp)
	la $a1, string_6192
	jal func__stringConcatenate
	sw $v0, 8856($sp)
	lw $a0, 8856($sp)
	jal func__print
	sw $v0, 4820($sp)
	lw $a0, 7928($sp)
	jal func__toString
	sw $v0, 7120($sp)
	lw $a0, 7120($sp)
	la $a1, string_6196
	jal func__stringConcatenate
	sw $v0, 7400($sp)
	lw $a0, 7400($sp)
	jal func__print
	sw $v0, 9796($sp)
	lw $a0, 4996($sp)
	jal func__toString
	sw $v0, 4736($sp)
	lw $a0, 4736($sp)
	la $a1, string_6200
	jal func__stringConcatenate
	sw $v0, 576($sp)
	lw $a0, 576($sp)
	jal func__print
	sw $v0, 1576($sp)
	lw $a0, 3812($sp)
	jal func__toString
	sw $v0, 2260($sp)
	lw $a0, 2260($sp)
	la $a1, string_6204
	jal func__stringConcatenate
	sw $v0, 324($sp)
	lw $a0, 324($sp)
	jal func__print
	sw $v0, 9452($sp)
	lw $a0, 6192($sp)
	jal func__toString
	sw $v0, 4556($sp)
	lw $a0, 4556($sp)
	la $a1, string_6208
	jal func__stringConcatenate
	sw $v0, 7408($sp)
	lw $a0, 7408($sp)
	jal func__print
	sw $v0, 10264($sp)
	lw $a0, 3592($sp)
	jal func__toString
	sw $v0, 5496($sp)
	lw $a0, 5496($sp)
	la $a1, string_6212
	jal func__stringConcatenate
	sw $v0, 5020($sp)
	lw $a0, 5020($sp)
	jal func__print
	sw $v0, 10316($sp)
	lw $a0, 7140($sp)
	jal func__toString
	sw $v0, 3848($sp)
	lw $a0, 3848($sp)
	la $a1, string_6216
	jal func__stringConcatenate
	sw $v0, 340($sp)
	lw $a0, 340($sp)
	jal func__print
	sw $v0, 9980($sp)
	lw $a0, 4268($sp)
	jal func__toString
	sw $v0, 8944($sp)
	lw $a0, 8944($sp)
	la $a1, string_6220
	jal func__stringConcatenate
	sw $v0, 1820($sp)
	lw $a0, 1820($sp)
	jal func__print
	sw $v0, 10088($sp)
	lw $a0, 9696($sp)
	jal func__toString
	sw $v0, 3932($sp)
	lw $a0, 3932($sp)
	la $a1, string_6224
	jal func__stringConcatenate
	sw $v0, 5428($sp)
	lw $a0, 5428($sp)
	jal func__print
	sw $v0, 6200($sp)
	lw $a0, 8748($sp)
	jal func__toString
	sw $v0, 972($sp)
	lw $a0, 972($sp)
	la $a1, string_6228
	jal func__stringConcatenate
	sw $v0, 2980($sp)
	lw $a0, 2980($sp)
	jal func__print
	sw $v0, 9788($sp)
	lw $a0, 9124($sp)
	jal func__toString
	sw $v0, 2380($sp)
	lw $a0, 2380($sp)
	la $a1, string_6232
	jal func__stringConcatenate
	sw $v0, 5320($sp)
	lw $a0, 5320($sp)
	jal func__print
	sw $v0, 7604($sp)
	lw $a0, 2276($sp)
	jal func__toString
	sw $v0, 1624($sp)
	lw $a0, 1624($sp)
	la $a1, string_6236
	jal func__stringConcatenate
	sw $v0, 3140($sp)
	lw $a0, 3140($sp)
	jal func__print
	sw $v0, 1216($sp)
	lw $a0, 2332($sp)
	jal func__toString
	sw $v0, 3816($sp)
	lw $a0, 3816($sp)
	la $a1, string_6240
	jal func__stringConcatenate
	sw $v0, 9840($sp)
	lw $a0, 9840($sp)
	jal func__print
	sw $v0, 4032($sp)
	lw $a0, 1796($sp)
	jal func__toString
	sw $v0, 7148($sp)
	lw $a0, 7148($sp)
	la $a1, string_6244
	jal func__stringConcatenate
	sw $v0, 792($sp)
	lw $a0, 792($sp)
	jal func__print
	sw $v0, 5432($sp)
	lw $a0, 4724($sp)
	jal func__toString
	sw $v0, 7924($sp)
	lw $a0, 7924($sp)
	la $a1, string_6248
	jal func__stringConcatenate
	sw $v0, 5884($sp)
	lw $a0, 5884($sp)
	jal func__print
	sw $v0, 1604($sp)
	lw $a0, 10332($sp)
	jal func__toString
	sw $v0, 7424($sp)
	lw $a0, 7424($sp)
	la $a1, string_6252
	jal func__stringConcatenate
	sw $v0, 3652($sp)
	lw $a0, 3652($sp)
	jal func__print
	sw $v0, 9564($sp)
	lw $a0, 3164($sp)
	jal func__toString
	sw $v0, 1320($sp)
	lw $a0, 1320($sp)
	la $a1, string_6256
	jal func__stringConcatenate
	sw $v0, 7172($sp)
	lw $a0, 7172($sp)
	jal func__print
	sw $v0, 9772($sp)
	lw $a0, 7748($sp)
	jal func__toString
	sw $v0, 3364($sp)
	lw $a0, 3364($sp)
	la $a1, string_6260
	jal func__stringConcatenate
	sw $v0, 3352($sp)
	lw $a0, 3352($sp)
	jal func__print
	sw $v0, 5544($sp)
	lw $a0, 3968($sp)
	jal func__toString
	sw $v0, 8896($sp)
	lw $a0, 8896($sp)
	la $a1, string_6264
	jal func__stringConcatenate
	sw $v0, 3348($sp)
	lw $a0, 3348($sp)
	jal func__print
	sw $v0, 9164($sp)
	lw $a0, 3484($sp)
	jal func__toString
	sw $v0, 6496($sp)
	lw $a0, 6496($sp)
	la $a1, string_6268
	jal func__stringConcatenate
	sw $v0, 4156($sp)
	lw $a0, 4156($sp)
	jal func__print
	sw $v0, 8376($sp)
	lw $a0, 7984($sp)
	jal func__toString
	sw $v0, 9028($sp)
	lw $a0, 9028($sp)
	la $a1, string_6272
	jal func__stringConcatenate
	sw $v0, 8860($sp)
	lw $a0, 8860($sp)
	jal func__print
	sw $v0, 3428($sp)
	lw $a0, 3532($sp)
	jal func__toString
	sw $v0, 2004($sp)
	lw $a0, 2004($sp)
	la $a1, string_6276
	jal func__stringConcatenate
	sw $v0, 7672($sp)
	lw $a0, 7672($sp)
	jal func__print
	sw $v0, 6736($sp)
	lw $a0, 5256($sp)
	jal func__toString
	sw $v0, 7092($sp)
	lw $a0, 7092($sp)
	la $a1, string_6280
	jal func__stringConcatenate
	sw $v0, 1184($sp)
	lw $a0, 1184($sp)
	jal func__print
	sw $v0, 1640($sp)
	lw $a0, 3136($sp)
	jal func__toString
	sw $v0, 1716($sp)
	lw $a0, 1716($sp)
	la $a1, string_6284
	jal func__stringConcatenate
	sw $v0, 4072($sp)
	lw $a0, 4072($sp)
	jal func__print
	sw $v0, 200($sp)
	lw $a0, 8508($sp)
	jal func__toString
	sw $v0, 5380($sp)
	lw $a0, 5380($sp)
	la $a1, string_6288
	jal func__stringConcatenate
	sw $v0, 10000($sp)
	lw $a0, 10000($sp)
	jal func__print
	sw $v0, 1988($sp)
	lw $a0, 9892($sp)
	jal func__toString
	sw $v0, 5548($sp)
	lw $a0, 5548($sp)
	la $a1, string_6292
	jal func__stringConcatenate
	sw $v0, 960($sp)
	lw $a0, 960($sp)
	jal func__print
	sw $v0, 10356($sp)
	lw $a0, 9604($sp)
	jal func__toString
	sw $v0, 3372($sp)
	lw $a0, 3372($sp)
	la $a1, string_6296
	jal func__stringConcatenate
	sw $v0, 6336($sp)
	lw $a0, 6336($sp)
	jal func__print
	sw $v0, 1864($sp)
	lw $a0, 8120($sp)
	jal func__toString
	sw $v0, 7448($sp)
	lw $a0, 7448($sp)
	la $a1, string_6300
	jal func__stringConcatenate
	sw $v0, 2704($sp)
	lw $a0, 2704($sp)
	jal func__print
	sw $v0, 9780($sp)
	lw $a0, 10040($sp)
	jal func__toString
	sw $v0, 9144($sp)
	lw $a0, 9144($sp)
	la $a1, string_6304
	jal func__stringConcatenate
	sw $v0, 7348($sp)
	lw $a0, 7348($sp)
	jal func__print
	sw $v0, 5480($sp)
	lw $a0, 4948($sp)
	jal func__toString
	sw $v0, 8736($sp)
	lw $a0, 8736($sp)
	la $a1, string_6308
	jal func__stringConcatenate
	sw $v0, 6172($sp)
	lw $a0, 6172($sp)
	jal func__print
	sw $v0, 1872($sp)
	lw $a0, 4924($sp)
	jal func__toString
	sw $v0, 9432($sp)
	lw $a0, 9432($sp)
	la $a1, string_6312
	jal func__stringConcatenate
	sw $v0, 3700($sp)
	lw $a0, 3700($sp)
	jal func__print
	sw $v0, 9096($sp)
	lw $a0, 9660($sp)
	jal func__toString
	sw $v0, 7712($sp)
	lw $a0, 7712($sp)
	la $a1, string_6316
	jal func__stringConcatenate
	sw $v0, 3680($sp)
	lw $a0, 3680($sp)
	jal func__print
	sw $v0, 9588($sp)
	lw $a0, 6400($sp)
	jal func__toString
	sw $v0, 9964($sp)
	lw $a0, 9964($sp)
	la $a1, string_6320
	jal func__stringConcatenate
	sw $v0, 5140($sp)
	lw $a0, 5140($sp)
	jal func__print
	sw $v0, 9176($sp)
	lw $a0, 8420($sp)
	jal func__toString
	sw $v0, 9032($sp)
	lw $a0, 9032($sp)
	la $a1, string_6324
	jal func__stringConcatenate
	sw $v0, 8364($sp)
	lw $a0, 8364($sp)
	jal func__print
	sw $v0, 8556($sp)
	lw $a0, 1052($sp)
	jal func__toString
	sw $v0, 5516($sp)
	lw $a0, 5516($sp)
	la $a1, string_6328
	jal func__stringConcatenate
	sw $v0, 432($sp)
	lw $a0, 432($sp)
	jal func__print
	sw $v0, 1424($sp)
	lw $a0, 5468($sp)
	jal func__toString
	sw $v0, 956($sp)
	lw $a0, 956($sp)
	la $a1, string_6332
	jal func__stringConcatenate
	sw $v0, 6712($sp)
	lw $a0, 6712($sp)
	jal func__print
	sw $v0, 848($sp)
	lw $a0, 2944($sp)
	jal func__toString
	sw $v0, 5584($sp)
	lw $a0, 5584($sp)
	la $a1, string_6336
	jal func__stringConcatenate
	sw $v0, 1580($sp)
	lw $a0, 1580($sp)
	jal func__print
	sw $v0, 1168($sp)
	lw $a0, 7760($sp)
	jal func__toString
	sw $v0, 4196($sp)
	lw $a0, 4196($sp)
	la $a1, string_6340
	jal func__stringConcatenate
	sw $v0, 6364($sp)
	lw $a0, 6364($sp)
	jal func__print
	sw $v0, 4348($sp)
	lw $a0, 6524($sp)
	jal func__toString
	sw $v0, 5340($sp)
	lw $a0, 5340($sp)
	la $a1, string_6344
	jal func__stringConcatenate
	sw $v0, 7512($sp)
	lw $a0, 7512($sp)
	jal func__print
	sw $v0, 6508($sp)
	lw $a0, 9316($sp)
	jal func__toString
	sw $v0, 9716($sp)
	lw $a0, 9716($sp)
	la $a1, string_6348
	jal func__stringConcatenate
	sw $v0, 3956($sp)
	lw $a0, 3956($sp)
	jal func__print
	sw $v0, 5400($sp)
	lw $a0, 7304($sp)
	jal func__toString
	sw $v0, 3560($sp)
	lw $a0, 3560($sp)
	la $a1, string_6352
	jal func__stringConcatenate
	sw $v0, 10268($sp)
	lw $a0, 10268($sp)
	jal func__print
	sw $v0, 3144($sp)
	lw $a0, 4884($sp)
	jal func__toString
	sw $v0, 2660($sp)
	lw $a0, 2660($sp)
	la $a1, string_6356
	jal func__stringConcatenate
	sw $v0, 6024($sp)
	lw $a0, 6024($sp)
	jal func__print
	sw $v0, 3764($sp)
	lw $a0, 1348($sp)
	jal func__toString
	sw $v0, 3820($sp)
	lw $a0, 3820($sp)
	la $a1, string_6360
	jal func__stringConcatenate
	sw $v0, 2020($sp)
	lw $a0, 2020($sp)
	jal func__print
	sw $v0, 5828($sp)
	lw $a0, 6368($sp)
	jal func__toString
	sw $v0, 508($sp)
	lw $a0, 508($sp)
	la $a1, string_6364
	jal func__stringConcatenate
	sw $v0, 9908($sp)
	lw $a0, 9908($sp)
	jal func__print
	sw $v0, 1440($sp)
	lw $a0, 5776($sp)
	jal func__toString
	sw $v0, 216($sp)
	lw $a0, 216($sp)
	la $a1, string_6368
	jal func__stringConcatenate
	sw $v0, 1636($sp)
	lw $a0, 1636($sp)
	jal func__print
	sw $v0, 5852($sp)
	lw $a0, 7200($sp)
	jal func__toString
	sw $v0, 8884($sp)
	lw $a0, 8884($sp)
	la $a1, string_6372
	jal func__stringConcatenate
	sw $v0, 10284($sp)
	lw $a0, 10284($sp)
	jal func__print
	sw $v0, 1844($sp)
	lw $a0, 1332($sp)
	jal func__toString
	sw $v0, 8196($sp)
	lw $a0, 8196($sp)
	la $a1, string_6376
	jal func__stringConcatenate
	sw $v0, 1792($sp)
	lw $a0, 1792($sp)
	jal func__print
	sw $v0, 7880($sp)
	lw $a0, 9676($sp)
	jal func__toString
	sw $v0, 6044($sp)
	lw $a0, 6044($sp)
	la $a1, string_6380
	jal func__stringConcatenate
	sw $v0, 6948($sp)
	lw $a0, 6948($sp)
	jal func__print
	sw $v0, 5420($sp)
	lw $a0, 8816($sp)
	jal func__toString
	sw $v0, 6380($sp)
	lw $a0, 6380($sp)
	la $a1, string_6384
	jal func__stringConcatenate
	sw $v0, 2364($sp)
	lw $a0, 2364($sp)
	jal func__print
	sw $v0, 1368($sp)
	lw $a0, 1336($sp)
	jal func__toString
	sw $v0, 344($sp)
	lw $a0, 344($sp)
	la $a1, string_6388
	jal func__stringConcatenate
	sw $v0, 8876($sp)
	lw $a0, 8876($sp)
	jal func__print
	sw $v0, 4740($sp)
	lw $a0, 10116($sp)
	jal func__toString
	sw $v0, 2972($sp)
	lw $a0, 2972($sp)
	la $a1, string_6392
	jal func__stringConcatenate
	sw $v0, 1212($sp)
	lw $a0, 1212($sp)
	jal func__print
	sw $v0, 5988($sp)
	lw $a0, 2892($sp)
	jal func__toString
	sw $v0, 3960($sp)
	lw $a0, 3960($sp)
	la $a1, string_6396
	jal func__stringConcatenate
	sw $v0, 9568($sp)
	lw $a0, 9568($sp)
	jal func__print
	sw $v0, 4676($sp)
	lw $a0, 10252($sp)
	jal func__toString
	sw $v0, 9824($sp)
	lw $a0, 9824($sp)
	la $a1, string_6400
	jal func__stringConcatenate
	sw $v0, 5384($sp)
	lw $a0, 5384($sp)
	jal func__print
	sw $v0, 3152($sp)
	lw $a0, 612($sp)
	jal func__toString
	sw $v0, 1588($sp)
	lw $a0, 1588($sp)
	la $a1, string_6404
	jal func__stringConcatenate
	sw $v0, 2464($sp)
	lw $a0, 2464($sp)
	jal func__print
	sw $v0, 3868($sp)
	lw $a0, 3864($sp)
	jal func__toString
	sw $v0, 8032($sp)
	lw $a0, 8032($sp)
	la $a1, string_6408
	jal func__stringConcatenate
	sw $v0, 4164($sp)
	lw $a0, 4164($sp)
	jal func__print
	sw $v0, 3720($sp)
	lw $a0, 9224($sp)
	jal func__toString
	sw $v0, 2820($sp)
	lw $a0, 2820($sp)
	la $a1, string_6412
	jal func__stringConcatenate
	sw $v0, 6428($sp)
	lw $a0, 6428($sp)
	jal func__print
	sw $v0, 948($sp)
	lw $a0, 6408($sp)
	jal func__toString
	sw $v0, 7076($sp)
	lw $a0, 7076($sp)
	la $a1, string_6416
	jal func__stringConcatenate
	sw $v0, 4932($sp)
	lw $a0, 4932($sp)
	jal func__print
	sw $v0, 10072($sp)
	lw $a0, 4604($sp)
	jal func__toString
	sw $v0, 5652($sp)
	lw $a0, 5652($sp)
	la $a1, string_6420
	jal func__stringConcatenate
	sw $v0, 6716($sp)
	lw $a0, 6716($sp)
	jal func__print
	sw $v0, 816($sp)
	lw $a0, 9352($sp)
	jal func__toString
	sw $v0, 6072($sp)
	lw $a0, 6072($sp)
	la $a1, string_6424
	jal func__stringConcatenate
	sw $v0, 228($sp)
	lw $a0, 228($sp)
	jal func__print
	sw $v0, 3320($sp)
	lw $a0, 7084($sp)
	jal func__toString
	sw $v0, 10276($sp)
	lw $a0, 10276($sp)
	la $a1, string_6428
	jal func__stringConcatenate
	sw $v0, 6124($sp)
	lw $a0, 6124($sp)
	jal func__print
	sw $v0, 560($sp)
	lw $a0, 7128($sp)
	jal func__toString
	sw $v0, 7624($sp)
	lw $a0, 7624($sp)
	la $a1, string_6432
	jal func__stringConcatenate
	sw $v0, 7612($sp)
	lw $a0, 7612($sp)
	jal func__print
	sw $v0, 5856($sp)
	lw $a0, 3252($sp)
	jal func__toString
	sw $v0, 3400($sp)
	lw $a0, 3400($sp)
	la $a1, string_6436
	jal func__stringConcatenate
	sw $v0, 1540($sp)
	lw $a0, 1540($sp)
	jal func__print
	sw $v0, 7516($sp)
	lw $a0, 7836($sp)
	jal func__toString
	sw $v0, 2500($sp)
	lw $a0, 2500($sp)
	la $a1, string_6440
	jal func__stringConcatenate
	sw $v0, 10368($sp)
	lw $a0, 10368($sp)
	jal func__print
	sw $v0, 168($sp)
	lw $a0, 2336($sp)
	jal func__toString
	sw $v0, 8580($sp)
	lw $a0, 8580($sp)
	la $a1, string_6444
	jal func__stringConcatenate
	sw $v0, 8248($sp)
	lw $a0, 8248($sp)
	jal func__print
	sw $v0, 6228($sp)
	lw $a0, 164($sp)
	jal func__toString
	sw $v0, 4188($sp)
	lw $a0, 4188($sp)
	la $a1, string_6448
	jal func__stringConcatenate
	sw $v0, 3796($sp)
	lw $a0, 3796($sp)
	jal func__print
	sw $v0, 744($sp)
	lw $a0, 2768($sp)
	jal func__toString
	sw $v0, 9860($sp)
	lw $a0, 9860($sp)
	la $a1, string_6452
	jal func__stringConcatenate
	sw $v0, 3696($sp)
	lw $a0, 3696($sp)
	jal func__print
	sw $v0, 6768($sp)
	lw $a0, 7392($sp)
	jal func__toString
	sw $v0, 2360($sp)
	lw $a0, 2360($sp)
	la $a1, string_6456
	jal func__stringConcatenate
	sw $v0, 5680($sp)
	lw $a0, 5680($sp)
	jal func__print
	sw $v0, 8212($sp)
	lw $a0, 4252($sp)
	jal func__toString
	sw $v0, 6240($sp)
	lw $a0, 6240($sp)
	la $a1, string_6460
	jal func__stringConcatenate
	sw $v0, 7204($sp)
	lw $a0, 7204($sp)
	jal func__print
	sw $v0, 4652($sp)
	lw $a0, 3880($sp)
	jal func__toString
	sw $v0, 1120($sp)
	lw $a0, 1120($sp)
	la $a1, string_6464
	jal func__stringConcatenate
	sw $v0, 9016($sp)
	lw $a0, 9016($sp)
	jal func__print
	sw $v0, 9640($sp)
	lw $a0, 8552($sp)
	jal func__toString
	sw $v0, 4776($sp)
	lw $a0, 4776($sp)
	la $a1, string_6468
	jal func__stringConcatenate
	sw $v0, 1552($sp)
	lw $a0, 1552($sp)
	jal func__print
	sw $v0, 3936($sp)
	lw $a0, 3256($sp)
	jal func__toString
	sw $v0, 5244($sp)
	lw $a0, 5244($sp)
	la $a1, string_6472
	jal func__stringConcatenate
	sw $v0, 544($sp)
	lw $a0, 544($sp)
	jal func__print
	sw $v0, 7256($sp)
	lw $a0, 732($sp)
	jal func__toString
	sw $v0, 7544($sp)
	lw $a0, 7544($sp)
	la $a1, string_6476
	jal func__stringConcatenate
	sw $v0, 6908($sp)
	lw $a0, 6908($sp)
	jal func__print
	sw $v0, 4664($sp)
	lw $a0, 1096($sp)
	jal func__toString
	sw $v0, 6880($sp)
	lw $a0, 6880($sp)
	la $a1, string_6480
	jal func__stringConcatenate
	sw $v0, 2856($sp)
	lw $a0, 2856($sp)
	jal func__print
	sw $v0, 5016($sp)
	lw $a0, 7248($sp)
	jal func__toString
	sw $v0, 1244($sp)
	lw $a0, 1244($sp)
	la $a1, string_6484
	jal func__stringConcatenate
	sw $v0, 3076($sp)
	lw $a0, 3076($sp)
	jal func__print
	sw $v0, 2440($sp)
	lw $a0, 8500($sp)
	jal func__toString
	sw $v0, 5424($sp)
	lw $a0, 5424($sp)
	la $a1, string_6488
	jal func__stringConcatenate
	sw $v0, 6628($sp)
	lw $a0, 6628($sp)
	jal func__print
	sw $v0, 9684($sp)
	lw $a0, 2940($sp)
	jal func__toString
	sw $v0, 6984($sp)
	lw $a0, 6984($sp)
	la $a1, string_6492
	jal func__stringConcatenate
	sw $v0, 8932($sp)
	lw $a0, 8932($sp)
	jal func__print
	sw $v0, 9220($sp)
	lw $a0, 5360($sp)
	jal func__toString
	sw $v0, 4540($sp)
	lw $a0, 4540($sp)
	la $a1, string_6496
	jal func__stringConcatenate
	sw $v0, 3124($sp)
	lw $a0, 3124($sp)
	jal func__print
	sw $v0, 836($sp)
	lw $a0, 3568($sp)
	jal func__toString
	sw $v0, 5764($sp)
	lw $a0, 5764($sp)
	la $a1, string_6500
	jal func__stringConcatenate
	sw $v0, 8304($sp)
	lw $a0, 8304($sp)
	jal func__print
	sw $v0, 2052($sp)
	lw $a0, 4016($sp)
	jal func__toString
	sw $v0, 8852($sp)
	lw $a0, 8852($sp)
	la $a1, string_6504
	jal func__stringConcatenate
	sw $v0, 640($sp)
	lw $a0, 640($sp)
	jal func__print
	sw $v0, 10212($sp)
	lw $a0, 1392($sp)
	jal func__toString
	sw $v0, 9312($sp)
	lw $a0, 9312($sp)
	la $a1, string_6508
	jal func__stringConcatenate
	sw $v0, 9580($sp)
	lw $a0, 9580($sp)
	jal func__print
	sw $v0, 4704($sp)
	lw $a0, 160($sp)
	jal func__toString
	sw $v0, 3704($sp)
	lw $a0, 3704($sp)
	la $a1, string_6512
	jal func__stringConcatenate
	sw $v0, 1592($sp)
	lw $a0, 1592($sp)
	jal func__print
	sw $v0, 6180($sp)
	lw $a0, 808($sp)
	jal func__toString
	sw $v0, 9740($sp)
	lw $a0, 9740($sp)
	la $a1, string_6516
	jal func__stringConcatenate
	sw $v0, 8020($sp)
	lw $a0, 8020($sp)
	jal func__print
	sw $v0, 1776($sp)
	lw $a0, 1248($sp)
	jal func__toString
	sw $v0, 8560($sp)
	lw $a0, 8560($sp)
	la $a1, string_6520
	jal func__stringConcatenate
	sw $v0, 6668($sp)
	lw $a0, 6668($sp)
	jal func__print
	sw $v0, 1472($sp)
	lw $a0, 4148($sp)
	jal func__toString
	sw $v0, 2024($sp)
	lw $a0, 2024($sp)
	la $a1, string_6524
	jal func__stringConcatenate
	sw $v0, 2048($sp)
	lw $a0, 2048($sp)
	jal func__print
	sw $v0, 5168($sp)
	lw $a0, 6964($sp)
	jal func__toString
	sw $v0, 4912($sp)
	lw $a0, 4912($sp)
	la $a1, string_6528
	jal func__stringConcatenate
	sw $v0, 9820($sp)
	lw $a0, 9820($sp)
	jal func__print
	sw $v0, 7044($sp)
	lw $a0, 6892($sp)
	jal func__toString
	sw $v0, 6748($sp)
	lw $a0, 6748($sp)
	la $a1, string_6532
	jal func__stringConcatenate
	sw $v0, 6548($sp)
	lw $a0, 6548($sp)
	jal func__print
	sw $v0, 4524($sp)
	lw $a0, 8300($sp)
	jal func__toString
	sw $v0, 3216($sp)
	lw $a0, 3216($sp)
	la $a1, string_6536
	jal func__stringConcatenate
	sw $v0, 2072($sp)
	lw $a0, 2072($sp)
	jal func__print
	sw $v0, 4860($sp)
	lw $a0, 2848($sp)
	jal func__toString
	sw $v0, 6980($sp)
	lw $a0, 6980($sp)
	la $a1, string_6540
	jal func__stringConcatenate
	sw $v0, 9260($sp)
	lw $a0, 9260($sp)
	jal func__print
	sw $v0, 9092($sp)
	lw $a0, 6968($sp)
	jal func__toString
	sw $v0, 4340($sp)
	lw $a0, 4340($sp)
	la $a1, string_6544
	jal func__stringConcatenate
	sw $v0, 944($sp)
	lw $a0, 944($sp)
	jal func__print
	sw $v0, 1708($sp)
	lw $a0, 1384($sp)
	jal func__toString
	sw $v0, 3772($sp)
	lw $a0, 3772($sp)
	la $a1, string_6548
	jal func__stringConcatenate
	sw $v0, 2292($sp)
	lw $a0, 2292($sp)
	jal func__print
	sw $v0, 5644($sp)
	lw $a0, 3940($sp)
	jal func__toString
	sw $v0, 8704($sp)
	lw $a0, 8704($sp)
	la $a1, string_6552
	jal func__stringConcatenate
	sw $v0, 7740($sp)
	lw $a0, 7740($sp)
	jal func__print
	sw $v0, 6348($sp)
	lw $a0, 788($sp)
	jal func__toString
	sw $v0, 9584($sp)
	lw $a0, 9584($sp)
	la $a1, string_6556
	jal func__stringConcatenate
	sw $v0, 3908($sp)
	lw $a0, 3908($sp)
	jal func__print
	sw $v0, 6156($sp)
	lw $a0, 5616($sp)
	jal func__toString
	sw $v0, 9288($sp)
	lw $a0, 9288($sp)
	la $a1, string_6560
	jal func__stringConcatenate
	sw $v0, 1432($sp)
	lw $a0, 1432($sp)
	jal func__print
	sw $v0, 6236($sp)
	lw $a0, 9708($sp)
	jal func__toString
	sw $v0, 5568($sp)
	lw $a0, 5568($sp)
	la $a1, string_6564
	jal func__stringConcatenate
	sw $v0, 6272($sp)
	lw $a0, 6272($sp)
	jal func__print
	sw $v0, 9156($sp)
	lw $a0, 2920($sp)
	jal func__toString
	sw $v0, 3728($sp)
	lw $a0, 3728($sp)
	la $a1, string_6568
	jal func__stringConcatenate
	sw $v0, 144($sp)
	lw $a0, 144($sp)
	jal func__print
	sw $v0, 1056($sp)
	lw $a0, 3248($sp)
	jal func__toString
	sw $v0, 7968($sp)
	lw $a0, 7968($sp)
	la $a1, string_6572
	jal func__stringConcatenate
	sw $v0, 3992($sp)
	lw $a0, 3992($sp)
	jal func__print
	sw $v0, 2112($sp)
	lw $a0, 416($sp)
	jal func__toString
	sw $v0, 5692($sp)
	lw $a0, 5692($sp)
	la $a1, string_6576
	jal func__stringConcatenate
	sw $v0, 7132($sp)
	lw $a0, 7132($sp)
	jal func__print
	sw $v0, 2080($sp)
	lw $a0, 2264($sp)
	jal func__toString
	sw $v0, 2724($sp)
	lw $a0, 2724($sp)
	la $a1, string_6580
	jal func__stringConcatenate
	sw $v0, 3272($sp)
	lw $a0, 3272($sp)
	jal func__print
	sw $v0, 9976($sp)
	lw $a0, 8092($sp)
	jal func__toString
	sw $v0, 6820($sp)
	lw $a0, 6820($sp)
	la $a1, string_6584
	jal func__stringConcatenate
	sw $v0, 4132($sp)
	lw $a0, 4132($sp)
	jal func__print
	sw $v0, 6352($sp)
	lw $a0, 1048($sp)
	jal func__toString
	sw $v0, 9168($sp)
	lw $a0, 9168($sp)
	la $a1, string_6588
	jal func__stringConcatenate
	sw $v0, 360($sp)
	lw $a0, 360($sp)
	jal func__print
	sw $v0, 5876($sp)
	lw $a0, 7904($sp)
	jal func__toString
	sw $v0, 5148($sp)
	lw $a0, 5148($sp)
	la $a1, string_6592
	jal func__stringConcatenate
	sw $v0, 6608($sp)
	lw $a0, 6608($sp)
	jal func__print
	sw $v0, 9416($sp)
	lw $a0, 8368($sp)
	jal func__toString
	sw $v0, 9896($sp)
	lw $a0, 9896($sp)
	la $a1, string_6596
	jal func__stringConcatenate
	sw $v0, 7308($sp)
	lw $a0, 7308($sp)
	jal func__print
	sw $v0, 8588($sp)
	lw $a0, 4428($sp)
	jal func__toString
	sw $v0, 2076($sp)
	lw $a0, 2076($sp)
	la $a1, string_6600
	jal func__stringConcatenate
	sw $v0, 1220($sp)
	lw $a0, 1220($sp)
	jal func__print
	sw $v0, 7532($sp)
	lw $a0, 10192($sp)
	jal func__toString
	sw $v0, 1288($sp)
	lw $a0, 1288($sp)
	la $a1, string_6604
	jal func__stringConcatenate
	sw $v0, 7276($sp)
	lw $a0, 7276($sp)
	jal func__print
	sw $v0, 756($sp)
	lw $a0, 2760($sp)
	jal func__toString
	sw $v0, 6900($sp)
	lw $a0, 6900($sp)
	la $a1, string_6608
	jal func__stringConcatenate
	sw $v0, 1264($sp)
	lw $a0, 1264($sp)
	jal func__print
	sw $v0, 2708($sp)
	lw $a0, 3636($sp)
	jal func__toString
	sw $v0, 2452($sp)
	lw $a0, 2452($sp)
	la $a1, string_6612
	jal func__stringConcatenate
	sw $v0, 6680($sp)
	lw $a0, 6680($sp)
	jal func__print
	sw $v0, 1800($sp)
	lw $a0, 9192($sp)
	jal func__toString
	sw $v0, 9936($sp)
	lw $a0, 9936($sp)
	la $a1, string_6616
	jal func__stringConcatenate
	sw $v0, 9524($sp)
	lw $a0, 9524($sp)
	jal func__print
	sw $v0, 7288($sp)
	lw $a0, 2968($sp)
	jal func__toString
	sw $v0, 8236($sp)
	lw $a0, 8236($sp)
	la $a1, string_6620
	jal func__stringConcatenate
	sw $v0, 5904($sp)
	lw $a0, 5904($sp)
	jal func__print
	sw $v0, 9768($sp)
	lw $a0, 220($sp)
	jal func__toString
	sw $v0, 4984($sp)
	lw $a0, 4984($sp)
	la $a1, string_6624
	jal func__stringConcatenate
	sw $v0, 2840($sp)
	lw $a0, 2840($sp)
	jal func__print
	sw $v0, 4116($sp)
	lw $a0, 9196($sp)
	jal func__toString
	sw $v0, 4436($sp)
	lw $a0, 4436($sp)
	la $a1, string_6628
	jal func__stringConcatenate
	sw $v0, 1024($sp)
	lw $a0, 1024($sp)
	jal func__print
	sw $v0, 1628($sp)
	lw $a0, 5248($sp)
	jal func__toString
	sw $v0, 6996($sp)
	lw $a0, 6996($sp)
	la $a1, string_6632
	jal func__stringConcatenate
	sw $v0, 8496($sp)
	lw $a0, 8496($sp)
	jal func__print
	sw $v0, 2092($sp)
	lw $a0, 488($sp)
	jal func__toString
	sw $v0, 1304($sp)
	lw $a0, 1304($sp)
	la $a1, string_6636
	jal func__stringConcatenate
	sw $v0, 5808($sp)
	lw $a0, 5808($sp)
	jal func__print
	sw $v0, 2036($sp)
	lw $a0, 6772($sp)
	jal func__toString
	sw $v0, 2228($sp)
	lw $a0, 2228($sp)
	la $a1, string_6640
	jal func__stringConcatenate
	sw $v0, 2124($sp)
	lw $a0, 2124($sp)
	jal func__print
	sw $v0, 9808($sp)
	lw $a0, 8168($sp)
	jal func__toString
	sw $v0, 5028($sp)
	lw $a0, 5028($sp)
	la $a1, string_6644
	jal func__stringConcatenate
	sw $v0, 2096($sp)
	lw $a0, 2096($sp)
	jal func__print
	sw $v0, 1396($sp)
	lw $a0, 2476($sp)
	jal func__toString
	sw $v0, 9512($sp)
	lw $a0, 9512($sp)
	la $a1, string_6648
	jal func__stringConcatenate
	sw $v0, 4632($sp)
	lw $a0, 4632($sp)
	jal func__print
	sw $v0, 7720($sp)
	lw $a0, 2772($sp)
	jal func__toString
	sw $v0, 5772($sp)
	lw $a0, 5772($sp)
	la $a1, string_6652
	jal func__stringConcatenate
	sw $v0, 3116($sp)
	lw $a0, 3116($sp)
	jal func__print
	sw $v0, 8536($sp)
	lw $a0, 9424($sp)
	jal func__toString
	sw $v0, 1704($sp)
	lw $a0, 1704($sp)
	la $a1, string_6656
	jal func__stringConcatenate
	sw $v0, 1768($sp)
	lw $a0, 1768($sp)
	jal func__print
	sw $v0, 9100($sp)
	lw $a0, 7224($sp)
	jal func__toString
	sw $v0, 6552($sp)
	lw $a0, 6552($sp)
	la $a1, string_6660
	jal func__stringConcatenate
	sw $v0, 9960($sp)
	lw $a0, 9960($sp)
	jal func__print
	sw $v0, 5472($sp)
	lw $a0, 4184($sp)
	jal func__toString
	sw $v0, 7648($sp)
	lw $a0, 7648($sp)
	la $a1, string_6664
	jal func__stringConcatenate
	sw $v0, 5088($sp)
	lw $a0, 5088($sp)
	jal func__print
	sw $v0, 9784($sp)
	lw $a0, 10168($sp)
	jal func__toString
	sw $v0, 5968($sp)
	lw $a0, 5968($sp)
	la $a1, string_6668
	jal func__stringConcatenate
	sw $v0, 6928($sp)
	lw $a0, 6928($sp)
	jal func__print
	sw $v0, 8868($sp)
	lw $a0, 172($sp)
	jal func__toString
	sw $v0, 6436($sp)
	lw $a0, 6436($sp)
	la $a1, string_6672
	jal func__stringConcatenate
	sw $v0, 6660($sp)
	lw $a0, 6660($sp)
	jal func__print
	sw $v0, 7876($sp)
	lw $a0, 5552($sp)
	jal func__toString
	sw $v0, 7668($sp)
	lw $a0, 7668($sp)
	la $a1, string_6676
	jal func__stringConcatenate
	sw $v0, 5840($sp)
	lw $a0, 5840($sp)
	jal func__print
	sw $v0, 2508($sp)
	lw $a0, 5392($sp)
	jal func__toString
	sw $v0, 8060($sp)
	lw $a0, 8060($sp)
	la $a1, string_6680
	jal func__stringConcatenate
	sw $v0, 3856($sp)
	lw $a0, 3856($sp)
	jal func__print
	sw $v0, 9592($sp)
	lw $a0, 5512($sp)
	jal func__toString
	sw $v0, 3420($sp)
	lw $a0, 3420($sp)
	la $a1, string_6684
	jal func__stringConcatenate
	sw $v0, 8476($sp)
	lw $a0, 8476($sp)
	jal func__print
	sw $v0, 6256($sp)
	lw $a0, 6212($sp)
	jal func__toString
	sw $v0, 3084($sp)
	lw $a0, 3084($sp)
	la $a1, string_6688
	jal func__stringConcatenate
	sw $v0, 7012($sp)
	lw $a0, 7012($sp)
	jal func__print
	sw $v0, 4892($sp)
	lw $a0, 9680($sp)
	jal func__toString
	sw $v0, 5860($sp)
	lw $a0, 5860($sp)
	la $a1, string_6692
	jal func__stringConcatenate
	sw $v0, 2804($sp)
	lw $a0, 2804($sp)
	jal func__print
	sw $v0, 4980($sp)
	lw $a0, 1200($sp)
	jal func__toString
	sw $v0, 8680($sp)
	lw $a0, 8680($sp)
	la $a1, string_6696
	jal func__stringConcatenate
	sw $v0, 1964($sp)
	lw $a0, 1964($sp)
	jal func__print
	sw $v0, 8488($sp)
	lw $a0, 6112($sp)
	jal func__toString
	sw $v0, 5036($sp)
	lw $a0, 5036($sp)
	la $a1, string_6700
	jal func__stringConcatenate
	sw $v0, 2432($sp)
	lw $a0, 2432($sp)
	jal func__print
	sw $v0, 7468($sp)
	lw $a0, 9616($sp)
	jal func__toString
	sw $v0, 3952($sp)
	lw $a0, 3952($sp)
	la $a1, string_6704
	jal func__stringConcatenate
	sw $v0, 444($sp)
	lw $a0, 444($sp)
	jal func__print
	sw $v0, 1884($sp)
	lw $a0, 2352($sp)
	jal func__toString
	sw $v0, 6672($sp)
	lw $a0, 6672($sp)
	la $a1, string_6708
	jal func__stringConcatenate
	sw $v0, 6308($sp)
	lw $a0, 6308($sp)
	jal func__print
	sw $v0, 3544($sp)
	lw $a0, 4052($sp)
	jal func__toString
	sw $v0, 8464($sp)
	lw $a0, 8464($sp)
	la $a1, string_6712
	jal func__stringConcatenate
	sw $v0, 4760($sp)
	lw $a0, 4760($sp)
	jal func__print
	sw $v0, 2084($sp)
	lw $a0, 8232($sp)
	jal func__toString
	sw $v0, 7820($sp)
	lw $a0, 7820($sp)
	la $a1, string_6716
	jal func__stringConcatenate
	sw $v0, 7452($sp)
	lw $a0, 7452($sp)
	jal func__print
	sw $v0, 896($sp)
	lw $a0, 5456($sp)
	jal func__toString
	sw $v0, 5308($sp)
	lw $a0, 5308($sp)
	la $a1, string_6720
	jal func__stringConcatenate
	sw $v0, 5576($sp)
	lw $a0, 5576($sp)
	jal func__print
	sw $v0, 1356($sp)
	lw $a0, 10044($sp)
	jal func__toString
	sw $v0, 3800($sp)
	lw $a0, 3800($sp)
	la $a1, string_6724
	jal func__stringConcatenate
	sw $v0, 8436($sp)
	lw $a0, 8436($sp)
	jal func__print
	sw $v0, 9140($sp)
	lw $a0, 4440($sp)
	jal func__toString
	sw $v0, 7428($sp)
	lw $a0, 7428($sp)
	la $a1, string_6728
	jal func__stringConcatenate
	sw $v0, 2588($sp)
	lw $a0, 2588($sp)
	jal func__print
	sw $v0, 5292($sp)
	lw $a0, 7700($sp)
	jal func__toString
	sw $v0, 5928($sp)
	lw $a0, 5928($sp)
	la $a1, string_6732
	jal func__stringConcatenate
	sw $v0, 8324($sp)
	lw $a0, 8324($sp)
	jal func__print
	sw $v0, 5520($sp)
	lw $a0, 4620($sp)
	jal func__toString
	sw $v0, 6936($sp)
	lw $a0, 6936($sp)
	la $a1, string_6736
	jal func__stringConcatenate
	sw $v0, 624($sp)
	lw $a0, 624($sp)
	jal func__print
	sw $v0, 2180($sp)
	lw $a0, 436($sp)
	jal func__toString
	sw $v0, 2884($sp)
	lw $a0, 2884($sp)
	la $a1, string_6740
	jal func__stringConcatenate
	sw $v0, 7584($sp)
	lw $a0, 7584($sp)
	jal func__print
	sw $v0, 1720($sp)
	lw $a0, 9172($sp)
	jal func__toString
	sw $v0, 4624($sp)
	lw $a0, 4624($sp)
	la $a1, string_6744
	jal func__stringConcatenate
	sw $v0, 2912($sp)
	lw $a0, 2912($sp)
	jal func__print
	sw $v0, 2504($sp)
	lw $a0, 9444($sp)
	jal func__toString
	sw $v0, 4060($sp)
	lw $a0, 4060($sp)
	la $a1, string_6748
	jal func__stringConcatenate
	sw $v0, 668($sp)
	lw $a0, 668($sp)
	jal func__print
	sw $v0, 2932($sp)
	lw $a0, 1608($sp)
	jal func__toString
	sw $v0, 5284($sp)
	lw $a0, 5284($sp)
	la $a1, string_6752
	jal func__stringConcatenate
	sw $v0, 8036($sp)
	lw $a0, 8036($sp)
	jal func__print
	sw $v0, 7828($sp)
	lw $a0, 9368($sp)
	jal func__toString
	sw $v0, 8808($sp)
	lw $a0, 8808($sp)
	la $a1, string_6756
	jal func__stringConcatenate
	sw $v0, 3780($sp)
	lw $a0, 3780($sp)
	jal func__print
	sw $v0, 2200($sp)
	lw $a0, 3776($sp)
	jal func__toString
	sw $v0, 2784($sp)
	lw $a0, 2784($sp)
	la $a1, string_6760
	jal func__stringConcatenate
	sw $v0, 708($sp)
	lw $a0, 708($sp)
	jal func__print
	sw $v0, 1656($sp)
	lw $a0, 9468($sp)
	jal func__toString
	sw $v0, 6392($sp)
	lw $a0, 6392($sp)
	la $a1, string_6764
	jal func__stringConcatenate
	sw $v0, 9536($sp)
	lw $a0, 9536($sp)
	jal func__print
	sw $v0, 4304($sp)
	lw $a0, 5280($sp)
	jal func__toString
	sw $v0, 2880($sp)
	lw $a0, 2880($sp)
	la $a1, string_6768
	jal func__stringConcatenate
	sw $v0, 7504($sp)
	lw $a0, 7504($sp)
	jal func__print
	sw $v0, 7028($sp)
	lw $a0, 6160($sp)
	jal func__toString
	sw $v0, 1380($sp)
	lw $a0, 1380($sp)
	la $a1, string_6772
	jal func__stringConcatenate
	sw $v0, 3528($sp)
	lw $a0, 3528($sp)
	jal func__print
	sw $v0, 616($sp)
	lw $a0, 2740($sp)
	jal func__toString
	sw $v0, 8872($sp)
	lw $a0, 8872($sp)
	la $a1, string_6776
	jal func__stringConcatenate
	sw $v0, 4920($sp)
	lw $a0, 4920($sp)
	jal func__print
	sw $v0, 3328($sp)
	lw $a0, 2808($sp)
	jal func__toString
	sw $v0, 5936($sp)
	lw $a0, 5936($sp)
	la $a1, string_6780
	jal func__stringConcatenate
	sw $v0, 4476($sp)
	lw $a0, 4476($sp)
	jal func__print
	sw $v0, 5940($sp)
	lw $a0, 7352($sp)
	jal func__toString
	sw $v0, 1512($sp)
	lw $a0, 1512($sp)
	la $a1, string_6784
	jal func__stringConcatenate
	sw $v0, 8372($sp)
	lw $a0, 8372($sp)
	jal func__print
	sw $v0, 680($sp)
	lw $a0, 4100($sp)
	jal func__toString
	sw $v0, 4992($sp)
	lw $a0, 4992($sp)
	la $a1, string_6788
	jal func__stringConcatenate
	sw $v0, 8568($sp)
	lw $a0, 8568($sp)
	jal func__print
	sw $v0, 1740($sp)
	lw $a0, 9332($sp)
	jal func__toString
	sw $v0, 5944($sp)
	lw $a0, 5944($sp)
	la $a1, string_6792
	jal func__stringConcatenate
	sw $v0, 5096($sp)
	lw $a0, 5096($sp)
	jal func__print
	sw $v0, 1228($sp)
	lw $a0, 8636($sp)
	jal func__toString
	sw $v0, 4812($sp)
	lw $a0, 4812($sp)
	la $a1, string_6796
	jal func__stringConcatenate
	sw $v0, 728($sp)
	lw $a0, 728($sp)
	jal func__print
	sw $v0, 9088($sp)
	lw $a0, 3900($sp)
	jal func__toString
	sw $v0, 2836($sp)
	lw $a0, 2836($sp)
	la $a1, string_6800
	jal func__stringConcatenate
	sw $v0, 9120($sp)
	lw $a0, 9120($sp)
	jal func__print
	sw $v0, 4312($sp)
	lw $a0, 2480($sp)
	jal func__toString
	sw $v0, 3268($sp)
	lw $a0, 3268($sp)
	la $a1, string_6804
	jal func__stringConcatenate
	sw $v0, 8276($sp)
	lw $a0, 8276($sp)
	jal func__print
	sw $v0, 7832($sp)
	lw $a0, 8108($sp)
	jal func__toString
	sw $v0, 6232($sp)
	lw $a0, 6232($sp)
	la $a1, string_6808
	jal func__stringConcatenate
	sw $v0, 5236($sp)
	lw $a0, 5236($sp)
	jal func__print
	sw $v0, 1452($sp)
	lw $a0, 1532($sp)
	jal func__toString
	sw $v0, 880($sp)
	lw $a0, 880($sp)
	la $a1, string_6812
	jal func__stringConcatenate
	sw $v0, 2688($sp)
	lw $a0, 2688($sp)
	jal func__print
	sw $v0, 5232($sp)
	lw $a0, 1232($sp)
	jal func__toString
	sw $v0, 6644($sp)
	lw $a0, 6644($sp)
	la $a1, string_6816
	jal func__stringConcatenate
	sw $v0, 3496($sp)
	lw $a0, 3496($sp)
	jal func__print
	sw $v0, 2692($sp)
	lw $a0, 6800($sp)
	jal func__toString
	sw $v0, 6724($sp)
	lw $a0, 6724($sp)
	la $a1, string_6820
	jal func__stringConcatenate
	sw $v0, 9748($sp)
	lw $a0, 9748($sp)
	jal func__print
	sw $v0, 6744($sp)
	lw $a0, 8844($sp)
	jal func__toString
	sw $v0, 7412($sp)
	lw $a0, 7412($sp)
	la $a1, string_6824
	jal func__stringConcatenate
	sw $v0, 3844($sp)
	lw $a0, 3844($sp)
	jal func__print
	sw $v0, 1116($sp)
	lw $a0, 4976($sp)
	jal func__toString
	sw $v0, 4796($sp)
	lw $a0, 4796($sp)
	la $a1, string_6828
	jal func__stringConcatenate
	sw $v0, 4480($sp)
	lw $a0, 4480($sp)
	jal func__print
	sw $v0, 8280($sp)
	lw $a0, 292($sp)
	jal func__toString
	sw $v0, 588($sp)
	lw $a0, 588($sp)
	la $a1, string_6832
	jal func__stringConcatenate
	sw $v0, 4068($sp)
	lw $a0, 4068($sp)
	jal func__print
	sw $v0, 1560($sp)
	lw $a0, 6756($sp)
	jal func__toString
	sw $v0, 5556($sp)
	lw $a0, 5556($sp)
	la $a1, string_6836
	jal func__stringConcatenate
	sw $v0, 6424($sp)
	lw $a0, 6424($sp)
	jal func__print
	sw $v0, 5896($sp)
	lw $a0, 7292($sp)
	jal func__toString
	sw $v0, 2184($sp)
	lw $a0, 2184($sp)
	la $a1, string_6840
	jal func__stringConcatenate
	sw $v0, 1036($sp)
	lw $a0, 1036($sp)
	jal func__print
	sw $v0, 1436($sp)
	lw $a0, 9280($sp)
	jal func__toString
	sw $v0, 3324($sp)
	lw $a0, 3324($sp)
	la $a1, string_6844
	jal func__stringConcatenate
	sw $v0, 1164($sp)
	lw $a0, 1164($sp)
	jal func__print
	sw $v0, 1932($sp)
	lw $a0, 8272($sp)
	jal func__toString
	sw $v0, 4076($sp)
	lw $a0, 4076($sp)
	la $a1, string_6848
	jal func__stringConcatenate
	sw $v0, 2580($sp)
	lw $a0, 2580($sp)
	jal func__print
	sw $v0, 9400($sp)
	lw $a0, 3888($sp)
	jal func__toString
	sw $v0, 3756($sp)
	lw $a0, 3756($sp)
	la $a1, string_6852
	jal func__stringConcatenate
	sw $v0, 1044($sp)
	lw $a0, 1044($sp)
	jal func__print
	sw $v0, 8424($sp)
	lw $a0, 376($sp)
	jal func__toString
	sw $v0, 10104($sp)
	lw $a0, 10104($sp)
	la $a1, string_6856
	jal func__stringConcatenate
	sw $v0, 9516($sp)
	lw $a0, 9516($sp)
	jal func__print
	sw $v0, 2592($sp)
	lw $a0, 8724($sp)
	jal func__toString
	sw $v0, 5736($sp)
	lw $a0, 5736($sp)
	la $a1, string_6860
	jal func__stringConcatenate
	sw $v0, 10248($sp)
	lw $a0, 10248($sp)
	jal func__print
	sw $v0, 280($sp)
	lw $a0, 5272($sp)
	jal func__toString
	sw $v0, 2408($sp)
	lw $a0, 2408($sp)
	la $a1, string_6864
	jal func__stringConcatenate
	sw $v0, 9048($sp)
	lw $a0, 9048($sp)
	jal func__print
	sw $v0, 5296($sp)
	lw $a0, 10400($sp)
	jal func__toString
	sw $v0, 6844($sp)
	lw $a0, 6844($sp)
	la $a1, string_6868
	jal func__stringConcatenate
	sw $v0, 672($sp)
	lw $a0, 672($sp)
	jal func__print
	sw $v0, 3672($sp)
	lw $a0, 10200($sp)
	jal func__toString
	sw $v0, 2872($sp)
	lw $a0, 2872($sp)
	la $a1, string_6872
	jal func__stringConcatenate
	sw $v0, 4832($sp)
	lw $a0, 4832($sp)
	jal func__print
	sw $v0, 7236($sp)
	lw $a0, 592($sp)
	jal func__toString
	sw $v0, 6292($sp)
	lw $a0, 6292($sp)
	la $a1, string_6876
	jal func__stringConcatenate
	sw $v0, 5084($sp)
	lw $a0, 5084($sp)
	jal func__print
	sw $v0, 1660($sp)
	lw $a0, 3092($sp)
	jal func__toString
	sw $v0, 664($sp)
	lw $a0, 664($sp)
	la $a1, string_6880
	jal func__stringConcatenate
	sw $v0, 6512($sp)
	lw $a0, 6512($sp)
	jal func__print
	sw $v0, 580($sp)
	lw $a0, 6604($sp)
	jal func__toString
	sw $v0, 3176($sp)
	lw $a0, 3176($sp)
	la $a1, string_6884
	jal func__stringConcatenate
	sw $v0, 6688($sp)
	lw $a0, 6688($sp)
	jal func__print
	sw $v0, 5932($sp)
	lw $a0, 364($sp)
	jal func__toString
	sw $v0, 608($sp)
	lw $a0, 608($sp)
	la $a1, string_6888
	jal func__stringConcatenate
	sw $v0, 9104($sp)
	lw $a0, 9104($sp)
	jal func__print
	sw $v0, 8408($sp)
	lw $a0, 8384($sp)
	jal func__toString
	sw $v0, 8640($sp)
	lw $a0, 8640($sp)
	la $a1, string_6892
	jal func__stringConcatenate
	sw $v0, 6440($sp)
	lw $a0, 6440($sp)
	jal func__print
	sw $v0, 7188($sp)
	lw $a0, 9408($sp)
	jal func__toString
	sw $v0, 9500($sp)
	lw $a0, 9500($sp)
	la $a1, string_6896
	jal func__stringConcatenate
	sw $v0, 5492($sp)
	lw $a0, 5492($sp)
	jal func__print
	sw $v0, 4836($sp)
	lw $a0, 4180($sp)
	jal func__toString
	sw $v0, 2192($sp)
	lw $a0, 2192($sp)
	la $a1, string_6900
	jal func__stringConcatenate
	sw $v0, 3624($sp)
	lw $a0, 3624($sp)
	jal func__print
	sw $v0, 6632($sp)
	lw $a0, 4908($sp)
	jal func__toString
	sw $v0, 900($sp)
	lw $a0, 900($sp)
	la $a1, string_6904
	jal func__stringConcatenate
	sw $v0, 4468($sp)
	lw $a0, 4468($sp)
	jal func__print
	sw $v0, 3548($sp)
	lw $a0, 6864($sp)
	jal func__toString
	sw $v0, 1296($sp)
	lw $a0, 1296($sp)
	la $a1, string_6908
	jal func__stringConcatenate
	sw $v0, 9228($sp)
	lw $a0, 9228($sp)
	jal func__print
	sw $v0, 8960($sp)
	lw $a0, 3516($sp)
	jal func__toString
	sw $v0, 10344($sp)
	lw $a0, 10344($sp)
	la $a1, string_6912
	jal func__stringConcatenate
	sw $v0, 4872($sp)
	lw $a0, 4872($sp)
	jal func__print
	sw $v0, 3996($sp)
	lw $a0, 5012($sp)
	jal func__toString
	sw $v0, 1968($sp)
	lw $a0, 1968($sp)
	la $a1, string_6916
	jal func__stringConcatenate
	sw $v0, 7788($sp)
	lw $a0, 7788($sp)
	jal func__print
	sw $v0, 1832($sp)
	lw $a0, 1464($sp)
	jal func__toString
	sw $v0, 6904($sp)
	lw $a0, 6904($sp)
	la $a1, string_6920
	jal func__stringConcatenate
	sw $v0, 2204($sp)
	lw $a0, 2204($sp)
	jal func__print
	sw $v0, 3456($sp)
	lw $a0, 6504($sp)
	jal func__toString
	sw $v0, 8936($sp)
	lw $a0, 8936($sp)
	la $a1, string_6924
	jal func__stringConcatenate
	sw $v0, 7244($sp)
	lw $a0, 7244($sp)
	jal func__print
	sw $v0, 7980($sp)
	lw $a0, 2548($sp)
	jal func__toString
	sw $v0, 5348($sp)
	lw $a0, 5348($sp)
	la $a1, string_6928
	jal func__stringConcatenate
	sw $v0, 7864($sp)
	lw $a0, 7864($sp)
	jal func__print
	sw $v0, 9612($sp)
	lw $a0, 8268($sp)
	jal func__toString
	sw $v0, 496($sp)
	lw $a0, 496($sp)
	la $a1, string_6932
	jal func__stringConcatenate
	sw $v0, 3620($sp)
	lw $a0, 3620($sp)
	jal func__print
	sw $v0, 2608($sp)
	lw $a0, 4228($sp)
	jal func__toString
	sw $v0, 908($sp)
	lw $a0, 908($sp)
	la $a1, string_6936
	jal func__stringConcatenate
	sw $v0, 7000($sp)
	lw $a0, 7000($sp)
	jal func__print
	sw $v0, 5276($sp)
	lw $a0, 9420($sp)
	jal func__toString
	sw $v0, 8904($sp)
	lw $a0, 8904($sp)
	la $a1, string_6940
	jal func__stringConcatenate
	sw $v0, 2712($sp)
	lw $a0, 2712($sp)
	jal func__print
	sw $v0, 2948($sp)
	lw $a0, 7724($sp)
	jal func__toString
	sw $v0, 9436($sp)
	lw $a0, 9436($sp)
	la $a1, string_6944
	jal func__stringConcatenate
	sw $v0, 5604($sp)
	lw $a0, 5604($sp)
	jal func__print
	sw $v0, 8928($sp)
	lw $a0, 5000($sp)
	jal func__toString
	sw $v0, 8952($sp)
	lw $a0, 8952($sp)
	la $a1, string_6948
	jal func__stringConcatenate
	sw $v0, 7852($sp)
	lw $a0, 7852($sp)
	jal func__print
	sw $v0, 8040($sp)
	lw $a0, 7908($sp)
	jal func__toString
	sw $v0, 10164($sp)
	lw $a0, 10164($sp)
	la $a1, string_6952
	jal func__stringConcatenate
	sw $v0, 4744($sp)
	lw $a0, 4744($sp)
	jal func__print
	sw $v0, 3208($sp)
	lw $a0, 2132($sp)
	jal func__toString
	sw $v0, 984($sp)
	lw $a0, 984($sp)
	la $a1, string_6956
	jal func__stringConcatenate
	sw $v0, 1032($sp)
	lw $a0, 1032($sp)
	jal func__print
	sw $v0, 9232($sp)
	lw $a0, 8140($sp)
	jal func__toString
	sw $v0, 6224($sp)
	lw $a0, 6224($sp)
	la $a1, string_6960
	jal func__stringConcatenate
	sw $v0, 4848($sp)
	lw $a0, 4848($sp)
	jal func__print
	sw $v0, 9912($sp)
	lw $a0, 840($sp)
	jal func__toString
	sw $v0, 6972($sp)
	lw $a0, 6972($sp)
	la $a1, string_6964
	jal func__stringConcatenate
	sw $v0, 6652($sp)
	lw $a0, 6652($sp)
	jal func__print
	sw $v0, 2412($sp)
	lw $a0, 8976($sp)
	jal func__toString
	sw $v0, 4544($sp)
	lw $a0, 4544($sp)
	la $a1, string_6968
	jal func__stringConcatenate
	sw $v0, 2520($sp)
	lw $a0, 2520($sp)
	jal func__print
	sw $v0, 8916($sp)
	lw $a0, 9200($sp)
	jal func__toString
	sw $v0, 2208($sp)
	lw $a0, 2208($sp)
	la $a1, string_6972
	jal func__stringConcatenate
	sw $v0, 6168($sp)
	lw $a0, 6168($sp)
	jal func__print
	sw $v0, 2156($sp)
	la $a0, string_6975
	jal func__println
	sw $v0, 7032($sp)
	li $v0, 0
	b _EndOfFunctionDecl1869
_EndOfFunctionDecl1869:
	lw $ra, 120($sp)
	add $sp, $sp, 10404
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_4145:
.space 4
.align 2
.word 1
string_4926:
.asciiz " "
.align 2
.word 1
string_4930:
.asciiz " "
.align 2
.word 1
string_4934:
.asciiz " "
.align 2
.word 1
string_4938:
.asciiz " "
.align 2
.word 1
string_4942:
.asciiz " "
.align 2
.word 1
string_4946:
.asciiz " "
.align 2
.word 1
string_4950:
.asciiz " "
.align 2
.word 1
string_4954:
.asciiz " "
.align 2
.word 1
string_4958:
.asciiz " "
.align 2
.word 1
string_4962:
.asciiz " "
.align 2
.word 1
string_4966:
.asciiz " "
.align 2
.word 1
string_4970:
.asciiz " "
.align 2
.word 1
string_4974:
.asciiz " "
.align 2
.word 1
string_4978:
.asciiz " "
.align 2
.word 1
string_4982:
.asciiz " "
.align 2
.word 1
string_4986:
.asciiz " "
.align 2
.word 1
string_4990:
.asciiz " "
.align 2
.word 1
string_4994:
.asciiz " "
.align 2
.word 1
string_4998:
.asciiz " "
.align 2
.word 1
string_5002:
.asciiz " "
.align 2
.word 1
string_5006:
.asciiz " "
.align 2
.word 1
string_5010:
.asciiz " "
.align 2
.word 1
string_5014:
.asciiz " "
.align 2
.word 1
string_5018:
.asciiz " "
.align 2
.word 1
string_5022:
.asciiz " "
.align 2
.word 1
string_5026:
.asciiz " "
.align 2
.word 1
string_5030:
.asciiz " "
.align 2
.word 1
string_5034:
.asciiz " "
.align 2
.word 1
string_5038:
.asciiz " "
.align 2
.word 1
string_5042:
.asciiz " "
.align 2
.word 1
string_5046:
.asciiz " "
.align 2
.word 1
string_5050:
.asciiz " "
.align 2
.word 1
string_5054:
.asciiz " "
.align 2
.word 1
string_5058:
.asciiz " "
.align 2
.word 1
string_5062:
.asciiz " "
.align 2
.word 1
string_5066:
.asciiz " "
.align 2
.word 1
string_5070:
.asciiz " "
.align 2
.word 1
string_5074:
.asciiz " "
.align 2
.word 1
string_5078:
.asciiz " "
.align 2
.word 1
string_5082:
.asciiz " "
.align 2
.word 1
string_5086:
.asciiz " "
.align 2
.word 1
string_5090:
.asciiz " "
.align 2
.word 1
string_5094:
.asciiz " "
.align 2
.word 1
string_5098:
.asciiz " "
.align 2
.word 1
string_5102:
.asciiz " "
.align 2
.word 1
string_5106:
.asciiz " "
.align 2
.word 1
string_5110:
.asciiz " "
.align 2
.word 1
string_5114:
.asciiz " "
.align 2
.word 1
string_5118:
.asciiz " "
.align 2
.word 1
string_5122:
.asciiz " "
.align 2
.word 1
string_5126:
.asciiz " "
.align 2
.word 1
string_5130:
.asciiz " "
.align 2
.word 1
string_5134:
.asciiz " "
.align 2
.word 1
string_5138:
.asciiz " "
.align 2
.word 1
string_5142:
.asciiz " "
.align 2
.word 1
string_5146:
.asciiz " "
.align 2
.word 1
string_5150:
.asciiz " "
.align 2
.word 1
string_5154:
.asciiz " "
.align 2
.word 1
string_5158:
.asciiz " "
.align 2
.word 1
string_5162:
.asciiz " "
.align 2
.word 1
string_5166:
.asciiz " "
.align 2
.word 1
string_5170:
.asciiz " "
.align 2
.word 1
string_5174:
.asciiz " "
.align 2
.word 1
string_5178:
.asciiz " "
.align 2
.word 1
string_5182:
.asciiz " "
.align 2
.word 1
string_5186:
.asciiz " "
.align 2
.word 1
string_5190:
.asciiz " "
.align 2
.word 1
string_5194:
.asciiz " "
.align 2
.word 1
string_5198:
.asciiz " "
.align 2
.word 1
string_5202:
.asciiz " "
.align 2
.word 1
string_5206:
.asciiz " "
.align 2
.word 1
string_5210:
.asciiz " "
.align 2
.word 1
string_5214:
.asciiz " "
.align 2
.word 1
string_5218:
.asciiz " "
.align 2
.word 1
string_5222:
.asciiz " "
.align 2
.word 1
string_5226:
.asciiz " "
.align 2
.word 1
string_5230:
.asciiz " "
.align 2
.word 1
string_5234:
.asciiz " "
.align 2
.word 1
string_5238:
.asciiz " "
.align 2
.word 1
string_5242:
.asciiz " "
.align 2
.word 1
string_5246:
.asciiz " "
.align 2
.word 1
string_5250:
.asciiz " "
.align 2
.word 1
string_5254:
.asciiz " "
.align 2
.word 1
string_5258:
.asciiz " "
.align 2
.word 1
string_5262:
.asciiz " "
.align 2
.word 1
string_5266:
.asciiz " "
.align 2
.word 1
string_5270:
.asciiz " "
.align 2
.word 1
string_5274:
.asciiz " "
.align 2
.word 1
string_5278:
.asciiz " "
.align 2
.word 1
string_5282:
.asciiz " "
.align 2
.word 1
string_5286:
.asciiz " "
.align 2
.word 1
string_5290:
.asciiz " "
.align 2
.word 1
string_5294:
.asciiz " "
.align 2
.word 1
string_5298:
.asciiz " "
.align 2
.word 1
string_5302:
.asciiz " "
.align 2
.word 1
string_5306:
.asciiz " "
.align 2
.word 1
string_5310:
.asciiz " "
.align 2
.word 1
string_5314:
.asciiz " "
.align 2
.word 1
string_5318:
.asciiz " "
.align 2
.word 1
string_5322:
.asciiz " "
.align 2
.word 1
string_5326:
.asciiz " "
.align 2
.word 1
string_5330:
.asciiz " "
.align 2
.word 1
string_5334:
.asciiz " "
.align 2
.word 1
string_5338:
.asciiz " "
.align 2
.word 1
string_5342:
.asciiz " "
.align 2
.word 1
string_5346:
.asciiz " "
.align 2
.word 1
string_5350:
.asciiz " "
.align 2
.word 1
string_5354:
.asciiz " "
.align 2
.word 1
string_5358:
.asciiz " "
.align 2
.word 1
string_5362:
.asciiz " "
.align 2
.word 1
string_5366:
.asciiz " "
.align 2
.word 1
string_5370:
.asciiz " "
.align 2
.word 1
string_5374:
.asciiz " "
.align 2
.word 1
string_5378:
.asciiz " "
.align 2
.word 1
string_5382:
.asciiz " "
.align 2
.word 1
string_5386:
.asciiz " "
.align 2
.word 1
string_5390:
.asciiz " "
.align 2
.word 1
string_5394:
.asciiz " "
.align 2
.word 1
string_5398:
.asciiz " "
.align 2
.word 1
string_5402:
.asciiz " "
.align 2
.word 1
string_5406:
.asciiz " "
.align 2
.word 1
string_5410:
.asciiz " "
.align 2
.word 1
string_5414:
.asciiz " "
.align 2
.word 1
string_5418:
.asciiz " "
.align 2
.word 1
string_5422:
.asciiz " "
.align 2
.word 1
string_5426:
.asciiz " "
.align 2
.word 1
string_5430:
.asciiz " "
.align 2
.word 1
string_5434:
.asciiz " "
.align 2
.word 1
string_5438:
.asciiz " "
.align 2
.word 1
string_5442:
.asciiz " "
.align 2
.word 1
string_5446:
.asciiz " "
.align 2
.word 1
string_5450:
.asciiz " "
.align 2
.word 1
string_5454:
.asciiz " "
.align 2
.word 1
string_5458:
.asciiz " "
.align 2
.word 1
string_5462:
.asciiz " "
.align 2
.word 1
string_5466:
.asciiz " "
.align 2
.word 1
string_5470:
.asciiz " "
.align 2
.word 1
string_5474:
.asciiz " "
.align 2
.word 1
string_5478:
.asciiz " "
.align 2
.word 1
string_5482:
.asciiz " "
.align 2
.word 1
string_5486:
.asciiz " "
.align 2
.word 1
string_5490:
.asciiz " "
.align 2
.word 1
string_5494:
.asciiz " "
.align 2
.word 1
string_5498:
.asciiz " "
.align 2
.word 1
string_5502:
.asciiz " "
.align 2
.word 1
string_5506:
.asciiz " "
.align 2
.word 1
string_5510:
.asciiz " "
.align 2
.word 1
string_5514:
.asciiz " "
.align 2
.word 1
string_5518:
.asciiz " "
.align 2
.word 1
string_5522:
.asciiz " "
.align 2
.word 1
string_5526:
.asciiz " "
.align 2
.word 1
string_5530:
.asciiz " "
.align 2
.word 1
string_5534:
.asciiz " "
.align 2
.word 1
string_5538:
.asciiz " "
.align 2
.word 1
string_5542:
.asciiz " "
.align 2
.word 1
string_5546:
.asciiz " "
.align 2
.word 1
string_5550:
.asciiz " "
.align 2
.word 1
string_5554:
.asciiz " "
.align 2
.word 1
string_5558:
.asciiz " "
.align 2
.word 1
string_5562:
.asciiz " "
.align 2
.word 1
string_5566:
.asciiz " "
.align 2
.word 1
string_5570:
.asciiz " "
.align 2
.word 1
string_5574:
.asciiz " "
.align 2
.word 1
string_5578:
.asciiz " "
.align 2
.word 1
string_5582:
.asciiz " "
.align 2
.word 1
string_5586:
.asciiz " "
.align 2
.word 1
string_5590:
.asciiz " "
.align 2
.word 1
string_5594:
.asciiz " "
.align 2
.word 1
string_5598:
.asciiz " "
.align 2
.word 1
string_5602:
.asciiz " "
.align 2
.word 1
string_5606:
.asciiz " "
.align 2
.word 1
string_5610:
.asciiz " "
.align 2
.word 1
string_5614:
.asciiz " "
.align 2
.word 1
string_5618:
.asciiz " "
.align 2
.word 1
string_5622:
.asciiz " "
.align 2
.word 1
string_5626:
.asciiz " "
.align 2
.word 1
string_5630:
.asciiz " "
.align 2
.word 1
string_5634:
.asciiz " "
.align 2
.word 1
string_5638:
.asciiz " "
.align 2
.word 1
string_5642:
.asciiz " "
.align 2
.word 1
string_5646:
.asciiz " "
.align 2
.word 1
string_5650:
.asciiz " "
.align 2
.word 1
string_5654:
.asciiz " "
.align 2
.word 1
string_5658:
.asciiz " "
.align 2
.word 1
string_5662:
.asciiz " "
.align 2
.word 1
string_5666:
.asciiz " "
.align 2
.word 1
string_5670:
.asciiz " "
.align 2
.word 1
string_5674:
.asciiz " "
.align 2
.word 1
string_5678:
.asciiz " "
.align 2
.word 1
string_5682:
.asciiz " "
.align 2
.word 1
string_5686:
.asciiz " "
.align 2
.word 1
string_5690:
.asciiz " "
.align 2
.word 1
string_5694:
.asciiz " "
.align 2
.word 1
string_5698:
.asciiz " "
.align 2
.word 1
string_5702:
.asciiz " "
.align 2
.word 1
string_5706:
.asciiz " "
.align 2
.word 1
string_5710:
.asciiz " "
.align 2
.word 1
string_5714:
.asciiz " "
.align 2
.word 1
string_5718:
.asciiz " "
.align 2
.word 1
string_5722:
.asciiz " "
.align 2
.word 1
string_5726:
.asciiz " "
.align 2
.word 1
string_5730:
.asciiz " "
.align 2
.word 1
string_5734:
.asciiz " "
.align 2
.word 1
string_5738:
.asciiz " "
.align 2
.word 1
string_5742:
.asciiz " "
.align 2
.word 1
string_5746:
.asciiz " "
.align 2
.word 1
string_5750:
.asciiz " "
.align 2
.word 1
string_5754:
.asciiz " "
.align 2
.word 1
string_5758:
.asciiz " "
.align 2
.word 1
string_5762:
.asciiz " "
.align 2
.word 1
string_5766:
.asciiz " "
.align 2
.word 1
string_5770:
.asciiz " "
.align 2
.word 1
string_5774:
.asciiz " "
.align 2
.word 1
string_5778:
.asciiz " "
.align 2
.word 1
string_5782:
.asciiz " "
.align 2
.word 1
string_5786:
.asciiz " "
.align 2
.word 1
string_5790:
.asciiz " "
.align 2
.word 1
string_5794:
.asciiz " "
.align 2
.word 1
string_5798:
.asciiz " "
.align 2
.word 1
string_5802:
.asciiz " "
.align 2
.word 1
string_5806:
.asciiz " "
.align 2
.word 1
string_5810:
.asciiz " "
.align 2
.word 1
string_5814:
.asciiz " "
.align 2
.word 1
string_5818:
.asciiz " "
.align 2
.word 1
string_5822:
.asciiz " "
.align 2
.word 1
string_5826:
.asciiz " "
.align 2
.word 1
string_5830:
.asciiz " "
.align 2
.word 1
string_5834:
.asciiz " "
.align 2
.word 1
string_5838:
.asciiz " "
.align 2
.word 1
string_5842:
.asciiz " "
.align 2
.word 1
string_5846:
.asciiz " "
.align 2
.word 1
string_5850:
.asciiz " "
.align 2
.word 1
string_5854:
.asciiz " "
.align 2
.word 1
string_5858:
.asciiz " "
.align 2
.word 1
string_5862:
.asciiz " "
.align 2
.word 1
string_5866:
.asciiz " "
.align 2
.word 1
string_5870:
.asciiz " "
.align 2
.word 1
string_5874:
.asciiz " "
.align 2
.word 1
string_5878:
.asciiz " "
.align 2
.word 1
string_5882:
.asciiz " "
.align 2
.word 1
string_5886:
.asciiz " "
.align 2
.word 1
string_5890:
.asciiz " "
.align 2
.word 1
string_5894:
.asciiz " "
.align 2
.word 1
string_5898:
.asciiz " "
.align 2
.word 1
string_5902:
.asciiz " "
.align 2
.word 1
string_5906:
.asciiz " "
.align 2
.word 1
string_5910:
.asciiz " "
.align 2
.word 1
string_5914:
.asciiz " "
.align 2
.word 1
string_5918:
.asciiz " "
.align 2
.word 1
string_5922:
.asciiz " "
.align 2
.word 1
string_5926:
.asciiz " "
.align 2
.word 1
string_5930:
.asciiz " "
.align 2
.word 1
string_5934:
.asciiz " "
.align 2
.word 1
string_5938:
.asciiz " "
.align 2
.word 1
string_5942:
.asciiz " "
.align 2
.word 1
string_5946:
.asciiz " "
.align 2
.word 0
string_5949:
.asciiz ""
.align 2
.word 1
string_5952:
.asciiz " "
.align 2
.word 1
string_5956:
.asciiz " "
.align 2
.word 1
string_5960:
.asciiz " "
.align 2
.word 1
string_5964:
.asciiz " "
.align 2
.word 1
string_5968:
.asciiz " "
.align 2
.word 1
string_5972:
.asciiz " "
.align 2
.word 1
string_5976:
.asciiz " "
.align 2
.word 1
string_5980:
.asciiz " "
.align 2
.word 1
string_5984:
.asciiz " "
.align 2
.word 1
string_5988:
.asciiz " "
.align 2
.word 1
string_5992:
.asciiz " "
.align 2
.word 1
string_5996:
.asciiz " "
.align 2
.word 1
string_6000:
.asciiz " "
.align 2
.word 1
string_6004:
.asciiz " "
.align 2
.word 1
string_6008:
.asciiz " "
.align 2
.word 1
string_6012:
.asciiz " "
.align 2
.word 1
string_6016:
.asciiz " "
.align 2
.word 1
string_6020:
.asciiz " "
.align 2
.word 1
string_6024:
.asciiz " "
.align 2
.word 1
string_6028:
.asciiz " "
.align 2
.word 1
string_6032:
.asciiz " "
.align 2
.word 1
string_6036:
.asciiz " "
.align 2
.word 1
string_6040:
.asciiz " "
.align 2
.word 1
string_6044:
.asciiz " "
.align 2
.word 1
string_6048:
.asciiz " "
.align 2
.word 1
string_6052:
.asciiz " "
.align 2
.word 1
string_6056:
.asciiz " "
.align 2
.word 1
string_6060:
.asciiz " "
.align 2
.word 1
string_6064:
.asciiz " "
.align 2
.word 1
string_6068:
.asciiz " "
.align 2
.word 1
string_6072:
.asciiz " "
.align 2
.word 1
string_6076:
.asciiz " "
.align 2
.word 1
string_6080:
.asciiz " "
.align 2
.word 1
string_6084:
.asciiz " "
.align 2
.word 1
string_6088:
.asciiz " "
.align 2
.word 1
string_6092:
.asciiz " "
.align 2
.word 1
string_6096:
.asciiz " "
.align 2
.word 1
string_6100:
.asciiz " "
.align 2
.word 1
string_6104:
.asciiz " "
.align 2
.word 1
string_6108:
.asciiz " "
.align 2
.word 1
string_6112:
.asciiz " "
.align 2
.word 1
string_6116:
.asciiz " "
.align 2
.word 1
string_6120:
.asciiz " "
.align 2
.word 1
string_6124:
.asciiz " "
.align 2
.word 1
string_6128:
.asciiz " "
.align 2
.word 1
string_6132:
.asciiz " "
.align 2
.word 1
string_6136:
.asciiz " "
.align 2
.word 1
string_6140:
.asciiz " "
.align 2
.word 1
string_6144:
.asciiz " "
.align 2
.word 1
string_6148:
.asciiz " "
.align 2
.word 1
string_6152:
.asciiz " "
.align 2
.word 1
string_6156:
.asciiz " "
.align 2
.word 1
string_6160:
.asciiz " "
.align 2
.word 1
string_6164:
.asciiz " "
.align 2
.word 1
string_6168:
.asciiz " "
.align 2
.word 1
string_6172:
.asciiz " "
.align 2
.word 1
string_6176:
.asciiz " "
.align 2
.word 1
string_6180:
.asciiz " "
.align 2
.word 1
string_6184:
.asciiz " "
.align 2
.word 1
string_6188:
.asciiz " "
.align 2
.word 1
string_6192:
.asciiz " "
.align 2
.word 1
string_6196:
.asciiz " "
.align 2
.word 1
string_6200:
.asciiz " "
.align 2
.word 1
string_6204:
.asciiz " "
.align 2
.word 1
string_6208:
.asciiz " "
.align 2
.word 1
string_6212:
.asciiz " "
.align 2
.word 1
string_6216:
.asciiz " "
.align 2
.word 1
string_6220:
.asciiz " "
.align 2
.word 1
string_6224:
.asciiz " "
.align 2
.word 1
string_6228:
.asciiz " "
.align 2
.word 1
string_6232:
.asciiz " "
.align 2
.word 1
string_6236:
.asciiz " "
.align 2
.word 1
string_6240:
.asciiz " "
.align 2
.word 1
string_6244:
.asciiz " "
.align 2
.word 1
string_6248:
.asciiz " "
.align 2
.word 1
string_6252:
.asciiz " "
.align 2
.word 1
string_6256:
.asciiz " "
.align 2
.word 1
string_6260:
.asciiz " "
.align 2
.word 1
string_6264:
.asciiz " "
.align 2
.word 1
string_6268:
.asciiz " "
.align 2
.word 1
string_6272:
.asciiz " "
.align 2
.word 1
string_6276:
.asciiz " "
.align 2
.word 1
string_6280:
.asciiz " "
.align 2
.word 1
string_6284:
.asciiz " "
.align 2
.word 1
string_6288:
.asciiz " "
.align 2
.word 1
string_6292:
.asciiz " "
.align 2
.word 1
string_6296:
.asciiz " "
.align 2
.word 1
string_6300:
.asciiz " "
.align 2
.word 1
string_6304:
.asciiz " "
.align 2
.word 1
string_6308:
.asciiz " "
.align 2
.word 1
string_6312:
.asciiz " "
.align 2
.word 1
string_6316:
.asciiz " "
.align 2
.word 1
string_6320:
.asciiz " "
.align 2
.word 1
string_6324:
.asciiz " "
.align 2
.word 1
string_6328:
.asciiz " "
.align 2
.word 1
string_6332:
.asciiz " "
.align 2
.word 1
string_6336:
.asciiz " "
.align 2
.word 1
string_6340:
.asciiz " "
.align 2
.word 1
string_6344:
.asciiz " "
.align 2
.word 1
string_6348:
.asciiz " "
.align 2
.word 1
string_6352:
.asciiz " "
.align 2
.word 1
string_6356:
.asciiz " "
.align 2
.word 1
string_6360:
.asciiz " "
.align 2
.word 1
string_6364:
.asciiz " "
.align 2
.word 1
string_6368:
.asciiz " "
.align 2
.word 1
string_6372:
.asciiz " "
.align 2
.word 1
string_6376:
.asciiz " "
.align 2
.word 1
string_6380:
.asciiz " "
.align 2
.word 1
string_6384:
.asciiz " "
.align 2
.word 1
string_6388:
.asciiz " "
.align 2
.word 1
string_6392:
.asciiz " "
.align 2
.word 1
string_6396:
.asciiz " "
.align 2
.word 1
string_6400:
.asciiz " "
.align 2
.word 1
string_6404:
.asciiz " "
.align 2
.word 1
string_6408:
.asciiz " "
.align 2
.word 1
string_6412:
.asciiz " "
.align 2
.word 1
string_6416:
.asciiz " "
.align 2
.word 1
string_6420:
.asciiz " "
.align 2
.word 1
string_6424:
.asciiz " "
.align 2
.word 1
string_6428:
.asciiz " "
.align 2
.word 1
string_6432:
.asciiz " "
.align 2
.word 1
string_6436:
.asciiz " "
.align 2
.word 1
string_6440:
.asciiz " "
.align 2
.word 1
string_6444:
.asciiz " "
.align 2
.word 1
string_6448:
.asciiz " "
.align 2
.word 1
string_6452:
.asciiz " "
.align 2
.word 1
string_6456:
.asciiz " "
.align 2
.word 1
string_6460:
.asciiz " "
.align 2
.word 1
string_6464:
.asciiz " "
.align 2
.word 1
string_6468:
.asciiz " "
.align 2
.word 1
string_6472:
.asciiz " "
.align 2
.word 1
string_6476:
.asciiz " "
.align 2
.word 1
string_6480:
.asciiz " "
.align 2
.word 1
string_6484:
.asciiz " "
.align 2
.word 1
string_6488:
.asciiz " "
.align 2
.word 1
string_6492:
.asciiz " "
.align 2
.word 1
string_6496:
.asciiz " "
.align 2
.word 1
string_6500:
.asciiz " "
.align 2
.word 1
string_6504:
.asciiz " "
.align 2
.word 1
string_6508:
.asciiz " "
.align 2
.word 1
string_6512:
.asciiz " "
.align 2
.word 1
string_6516:
.asciiz " "
.align 2
.word 1
string_6520:
.asciiz " "
.align 2
.word 1
string_6524:
.asciiz " "
.align 2
.word 1
string_6528:
.asciiz " "
.align 2
.word 1
string_6532:
.asciiz " "
.align 2
.word 1
string_6536:
.asciiz " "
.align 2
.word 1
string_6540:
.asciiz " "
.align 2
.word 1
string_6544:
.asciiz " "
.align 2
.word 1
string_6548:
.asciiz " "
.align 2
.word 1
string_6552:
.asciiz " "
.align 2
.word 1
string_6556:
.asciiz " "
.align 2
.word 1
string_6560:
.asciiz " "
.align 2
.word 1
string_6564:
.asciiz " "
.align 2
.word 1
string_6568:
.asciiz " "
.align 2
.word 1
string_6572:
.asciiz " "
.align 2
.word 1
string_6576:
.asciiz " "
.align 2
.word 1
string_6580:
.asciiz " "
.align 2
.word 1
string_6584:
.asciiz " "
.align 2
.word 1
string_6588:
.asciiz " "
.align 2
.word 1
string_6592:
.asciiz " "
.align 2
.word 1
string_6596:
.asciiz " "
.align 2
.word 1
string_6600:
.asciiz " "
.align 2
.word 1
string_6604:
.asciiz " "
.align 2
.word 1
string_6608:
.asciiz " "
.align 2
.word 1
string_6612:
.asciiz " "
.align 2
.word 1
string_6616:
.asciiz " "
.align 2
.word 1
string_6620:
.asciiz " "
.align 2
.word 1
string_6624:
.asciiz " "
.align 2
.word 1
string_6628:
.asciiz " "
.align 2
.word 1
string_6632:
.asciiz " "
.align 2
.word 1
string_6636:
.asciiz " "
.align 2
.word 1
string_6640:
.asciiz " "
.align 2
.word 1
string_6644:
.asciiz " "
.align 2
.word 1
string_6648:
.asciiz " "
.align 2
.word 1
string_6652:
.asciiz " "
.align 2
.word 1
string_6656:
.asciiz " "
.align 2
.word 1
string_6660:
.asciiz " "
.align 2
.word 1
string_6664:
.asciiz " "
.align 2
.word 1
string_6668:
.asciiz " "
.align 2
.word 1
string_6672:
.asciiz " "
.align 2
.word 1
string_6676:
.asciiz " "
.align 2
.word 1
string_6680:
.asciiz " "
.align 2
.word 1
string_6684:
.asciiz " "
.align 2
.word 1
string_6688:
.asciiz " "
.align 2
.word 1
string_6692:
.asciiz " "
.align 2
.word 1
string_6696:
.asciiz " "
.align 2
.word 1
string_6700:
.asciiz " "
.align 2
.word 1
string_6704:
.asciiz " "
.align 2
.word 1
string_6708:
.asciiz " "
.align 2
.word 1
string_6712:
.asciiz " "
.align 2
.word 1
string_6716:
.asciiz " "
.align 2
.word 1
string_6720:
.asciiz " "
.align 2
.word 1
string_6724:
.asciiz " "
.align 2
.word 1
string_6728:
.asciiz " "
.align 2
.word 1
string_6732:
.asciiz " "
.align 2
.word 1
string_6736:
.asciiz " "
.align 2
.word 1
string_6740:
.asciiz " "
.align 2
.word 1
string_6744:
.asciiz " "
.align 2
.word 1
string_6748:
.asciiz " "
.align 2
.word 1
string_6752:
.asciiz " "
.align 2
.word 1
string_6756:
.asciiz " "
.align 2
.word 1
string_6760:
.asciiz " "
.align 2
.word 1
string_6764:
.asciiz " "
.align 2
.word 1
string_6768:
.asciiz " "
.align 2
.word 1
string_6772:
.asciiz " "
.align 2
.word 1
string_6776:
.asciiz " "
.align 2
.word 1
string_6780:
.asciiz " "
.align 2
.word 1
string_6784:
.asciiz " "
.align 2
.word 1
string_6788:
.asciiz " "
.align 2
.word 1
string_6792:
.asciiz " "
.align 2
.word 1
string_6796:
.asciiz " "
.align 2
.word 1
string_6800:
.asciiz " "
.align 2
.word 1
string_6804:
.asciiz " "
.align 2
.word 1
string_6808:
.asciiz " "
.align 2
.word 1
string_6812:
.asciiz " "
.align 2
.word 1
string_6816:
.asciiz " "
.align 2
.word 1
string_6820:
.asciiz " "
.align 2
.word 1
string_6824:
.asciiz " "
.align 2
.word 1
string_6828:
.asciiz " "
.align 2
.word 1
string_6832:
.asciiz " "
.align 2
.word 1
string_6836:
.asciiz " "
.align 2
.word 1
string_6840:
.asciiz " "
.align 2
.word 1
string_6844:
.asciiz " "
.align 2
.word 1
string_6848:
.asciiz " "
.align 2
.word 1
string_6852:
.asciiz " "
.align 2
.word 1
string_6856:
.asciiz " "
.align 2
.word 1
string_6860:
.asciiz " "
.align 2
.word 1
string_6864:
.asciiz " "
.align 2
.word 1
string_6868:
.asciiz " "
.align 2
.word 1
string_6872:
.asciiz " "
.align 2
.word 1
string_6876:
.asciiz " "
.align 2
.word 1
string_6880:
.asciiz " "
.align 2
.word 1
string_6884:
.asciiz " "
.align 2
.word 1
string_6888:
.asciiz " "
.align 2
.word 1
string_6892:
.asciiz " "
.align 2
.word 1
string_6896:
.asciiz " "
.align 2
.word 1
string_6900:
.asciiz " "
.align 2
.word 1
string_6904:
.asciiz " "
.align 2
.word 1
string_6908:
.asciiz " "
.align 2
.word 1
string_6912:
.asciiz " "
.align 2
.word 1
string_6916:
.asciiz " "
.align 2
.word 1
string_6920:
.asciiz " "
.align 2
.word 1
string_6924:
.asciiz " "
.align 2
.word 1
string_6928:
.asciiz " "
.align 2
.word 1
string_6932:
.asciiz " "
.align 2
.word 1
string_6936:
.asciiz " "
.align 2
.word 1
string_6940:
.asciiz " "
.align 2
.word 1
string_6944:
.asciiz " "
.align 2
.word 1
string_6948:
.asciiz " "
.align 2
.word 1
string_6952:
.asciiz " "
.align 2
.word 1
string_6956:
.asciiz " "
.align 2
.word 1
string_6960:
.asciiz " "
.align 2
.word 1
string_6964:
.asciiz " "
.align 2
.word 1
string_6968:
.asciiz " "
.align 2
.word 1
string_6972:
.asciiz " "
.align 2
.word 0
string_6975:
.asciiz ""
.align 2
