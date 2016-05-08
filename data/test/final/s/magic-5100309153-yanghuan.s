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
_origin:
	sub $sp, $sp, 200
	sw $t2, 40($sp)
	sw $t3, 44($sp)
_BeginOfFunctionDecl38:
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	sw $t2, global_30
	li $t0, 0
	sw $t0, global_33
_ForLoop44:
	lw $t0, global_33
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
	beqz $t2, _OutOfFor1
_ForBody0:
	lw $t0, global_33
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t0, 196($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	li $t1, 4
	add $t3, $t3, $t1
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
	lw $t0, 196($sp)
	sw $t0, 0($t3)
	li $t1, 4
	add $t3, $t3, $t1
	sw $t3, 168($sp)
	lw $t0, 168($sp)
	sw $t0, 0($t2)
	li $t0, 0
	sw $t0, global_34
_ForLoop46:
	lw $t0, global_34
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
	beqz $t2, _OutOfFor3
_ForBody2:
	lw $t0, global_33
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, global_34
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t1, 180($sp)
	add $t2, $t2, $t1
	li $t0, 0
	sw $t0, 0($t2)
_continueFor47:
	lw $t0, global_34
	move $t2, $t0
	lw $t0, global_34
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_34
	b _ForLoop46
_OutOfFor3:
	b _continueFor45
_continueFor45:
	lw $t0, global_33
	move $t2, $t0
	lw $t0, global_33
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_33
	b _ForLoop44
_OutOfFor1:
	b _EndOfFunctionDecl39
_EndOfFunctionDecl39:
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 200
	jr $ra
_search:
	sub $sp, $sp, 1516
	sw $s0, 64($sp)
	sw $t8, 96($sp)
	sw $t6, 56($sp)
	sw $s7, 92($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t9, 100($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $t4, 48($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $k0, 104($sp)
	sw $t5, 52($sp)
	sw $s4, 80($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl40:
	lw $t0, 1508($sp)
	li $t1, 0
	sgt $t2, $t0, $t1
	beqz $t2, _logicalFalse8
_logicalTrue7:
	li $t0, 1
	move $t6, $t0
	b _logicalMerge9
_logicalFalse8:
	lw $t0, 1508($sp)
	li $t1, 0
	slt $t2, $t0, $t1
	move $t6, $t2
	b _logicalMerge9
_logicalMerge9:
	beqz $t6, _logicalFalse11
_logicalTrue10:
	li $t0, 1
	move $t7, $t0
	b _logicalMerge12
_logicalFalse11:
	lw $t0, 1504($sp)
	li $t1, 0
	seq $t2, $t0, $t1
	move $t7, $t2
	b _logicalMerge12
_logicalMerge12:
	beqz $t7, _logicalFalse14
_logicalTrue13:
	li $t0, 1
	move $s0, $t0
	b _logicalMerge15
_logicalFalse14:
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t2, $t0, $t1
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t2, 0($t2)
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	li $t1, 15
	seq $t2, $t2, $t1
	move $s0, $t2
	b _logicalMerge15
_logicalMerge15:
	beqz $s0, _alternative5
_consequence4:
	lw $t0, 1504($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _logicalFalse20
_logicalTrue19:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	move $s1, $t2
	b _logicalMerge21
_logicalFalse20:
	li $t0, 0
	move $s1, $t0
	b _logicalMerge21
_logicalMerge21:
	beqz $s1, _alternative17
_consequence16:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 45
	lw $t1, 1512($sp)
	sub $t2, $t0, $t1
	sw $t2, 0($t3)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t0, 2
	li $t1, 4
	mul $t4, $t0, $t1
	add $t3, $t3, $t4
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	move $s2, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	add $t4, $t4, $t3
	lw $t3, 0($t2)
	lw $t2, 0($t4)
	add $t3, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	beqz $t2, _logicalFalse26
_logicalTrue25:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t4, $t2, $t3
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	lw $t2, 0($t4)
	lw $t3, 0($t3)
	add $t3, $t2, $t3
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s3, $t2
	b _logicalMerge27
_logicalFalse26:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge27
_logicalMerge27:
	beqz $s3, _logicalFalse29
_logicalTrue28:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t3, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s4, $t2
	b _logicalMerge30
_logicalFalse29:
	li $t0, 0
	move $s4, $t0
	b _logicalMerge30
_logicalMerge30:
	beqz $s4, _logicalFalse32
_logicalTrue31:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t4, $t3, $t4
	lw $t3, 0($t2)
	lw $t2, 0($t4)
	add $t3, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s5, $t2
	b _logicalMerge33
_logicalFalse32:
	li $t0, 0
	move $s5, $t0
	b _logicalMerge33
_logicalMerge33:
	beqz $s5, _logicalFalse35
_logicalTrue34:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t4, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	lw $t2, 0($t4)
	lw $t3, 0($t3)
	add $t4, $t2, $t3
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	move $s6, $t2
	b _logicalMerge36
_logicalFalse35:
	li $t0, 0
	move $s6, $t0
	b _logicalMerge36
_logicalMerge36:
	beqz $s6, _logicalFalse38
_logicalTrue37:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t4, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	move $s7, $t2
	b _logicalMerge39
_logicalFalse38:
	li $t0, 0
	move $s7, $t0
	b _logicalMerge39
_logicalMerge39:
	beqz $s7, _logicalFalse41
_logicalTrue40:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t4, $t3, $t2
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	move $t8, $t2
	b _logicalMerge42
_logicalFalse41:
	li $t0, 0
	move $t8, $t0
	b _logicalMerge42
_logicalMerge42:
	beqz $t8, _alternative23
_consequence22:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_32
	add $t3, $t0, $t2
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_32
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 1
	add $t2, $t2, $t1
	sw $t2, 0($t3)
	li $t0, 0
	move $t4, $t0
_ForLoop48:
	li $t1, 2
	sle $t2, $t4, $t1
	beqz $t2, _OutOfFor44
_ForBody43:
	li $t0, 0
	move $t9, $t0
_ForLoop50:
	li $t1, 2
	sle $t2, $t9, $t1
	beqz $t2, _OutOfFor46
_ForBody45:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 4
	mul $t3, $t9, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	move $a0, $t2
	jal func__toString
	move $t2, $v0
	move $a0, $t2
	jal func__print
	move $t2, $v0
	la $a0, string_255
	jal func__print
	move $t2, $v0
_continueFor51:
	move $t2, $t9
	li $t1, 1
	add $t9, $t9, $t1
	b _ForLoop50
_OutOfFor46:
	la $a0, string_258
	jal func__print
	move $t2, $v0
_continueFor49:
	move $t2, $t4
	li $t1, 1
	add $t4, $t4, $t1
	b _ForLoop48
_OutOfFor44:
	la $a0, string_261
	jal func__print
	move $t2, $v0
	b _OutOfIf24
_alternative23:
	b _OutOfIf24
_OutOfIf24:
	b _OutOfIf18
_alternative17:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative48
_consequence47:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t2, $t3
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	li $t0, 15
	sub $t5, $t0, $t2
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	sub $t2, $t5, $t2
	sw $t2, 0($t3)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 0
	sgt $t2, $t2, $t1
	beqz $t2, _logicalFalse54
_logicalTrue53:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 10
	slt $t2, $t2, $t1
	move $t5, $t2
	b _logicalMerge55
_logicalFalse54:
	li $t0, 0
	move $t5, $t0
	b _logicalMerge55
_logicalMerge55:
	beqz $t5, _logicalFalse57
_logicalTrue56:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 0
	seq $t2, $t2, $t1
	move $k0, $t2
	b _logicalMerge58
_logicalFalse57:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge58
_logicalMerge58:
	beqz $k0, _alternative51
_consequence50:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 1
	sw $t0, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative60
_consequence59:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t2, $t0, $t1
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	lw $t0, 1512($sp)
	add $t3, $t0, $t3
	sw $t2, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t3, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf61
_alternative60:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t4, $t0, $t1
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	lw $t0, 1512($sp)
	add $t2, $t0, $t2
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t4, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf61
_OutOfIf61:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 0
	sw $t0, 0($t2)
	b _OutOfIf52
_alternative51:
	b _OutOfIf52
_OutOfIf52:
	b _OutOfIf49
_alternative48:
	li $t0, 1
	move $t4, $t0
_ForLoop52:
	li $t1, 9
	sle $t2, $t4, $t1
	beqz $t2, _OutOfFor63
_ForBody62:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 0
	seq $t2, $t2, $t1
	beqz $t2, _alternative65
_consequence64:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 1
	sw $t0, 0($t2)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	sw $t4, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative68
_consequence67:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t3, $t0, $t1
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
	sw $t3, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf69
_alternative68:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t3, $t0, $t1
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t3, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf69
_OutOfIf69:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	li $t0, 0
	sw $t0, 0($t2)
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 0
	sw $t0, 0($t2)
	b _OutOfIf66
_alternative65:
	b _OutOfIf66
_OutOfIf66:
	b _continueFor53
_continueFor53:
	move $t2, $t4
	li $t1, 1
	add $t4, $t4, $t1
	b _ForLoop52
_OutOfFor63:
	b _OutOfIf49
_OutOfIf49:
	b _OutOfIf18
_OutOfIf18:
	b _OutOfIf6
_alternative5:
	b _OutOfIf6
_OutOfIf6:
	b _EndOfFunctionDecl41
_EndOfFunctionDecl41:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t8, 96($sp)
	lw $t6, 56($sp)
	lw $s7, 92($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t9, 100($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $t4, 48($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $k0, 104($sp)
	lw $t5, 52($sp)
	lw $s4, 80($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 1516
	jr $ra
main:
	sub $sp, $sp, 180
	sw $t2, 40($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl42:
	li $t0, 10
	li $t1, 4
	mul $t2, $t0, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	li $t0, 10
	sw $t0, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	sw $t2, global_31
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	li $t0, 1
	sw $t0, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	sw $t2, global_32
	li $t0, 3
	sw $t0, -4($sp)
	jal _origin
	move $t2, $v0
	li $t0, 0
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	move $t2, $v0
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_32
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	move $a0, $t2
	jal func__toString
	move $t2, $v0
	move $a0, $t2
	jal func__println
	move $t2, $v0
	li $v0, 0
	b _EndOfFunctionDecl43
_EndOfFunctionDecl43:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 180
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_30:
.space 4
.align 2
global_31:
.space 4
.align 2
global_32:
.space 4
.align 2
global_33:
.space 4
.align 2
global_34:
.space 4
.align 2
.word 1
string_255:
.asciiz " "
.align 2
.word 1
string_258:
.asciiz "\n"
.align 2
.word 1
string_261:
.asciiz "\n"
.align 2
