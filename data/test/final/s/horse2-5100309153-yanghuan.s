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
_check:
	sub $sp, $sp, 148
_BeginOfFunctionDecl72:
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	beqz $t0, _logicalFalse1
_logicalTrue0:
	lw $t0, 140($sp)
	li $t1, 0
	sge $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	sw $t0, 136($sp)
	b _logicalMerge2
_logicalFalse1:
	li $t0, 0
	sw $t0, 136($sp)
	b _logicalMerge2
_logicalMerge2:
	lw $v0, 136($sp)
	b _EndOfFunctionDecl73
_EndOfFunctionDecl73:
	add $sp, $sp, 148
	jr $ra
main:
	sub $sp, $sp, 1576
	sw $s0, 64($sp)
	sw $t8, 96($sp)
	sw $fp, 124($sp)
	sw $t6, 56($sp)
	sw $s7, 92($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t9, 100($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $t4, 48($sp)
	sw $gp, 112($sp)
	sw $k1, 108($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $k0, 104($sp)
	sw $t5, 52($sp)
	sw $s4, 80($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl74:
	jal func__getInt
	sw $v0, 1420($sp)
	lw $t0, 1420($sp)
	move $t2, $t0
	li $t0, 0
	move $s0, $t0
	move $s2, $s0
	sw $s2, 1460($sp)
	lw $t0, 1460($sp)
	move $s4, $t0
	li $t1, 1
	sub $t3, $t2, $t1
	move $t5, $t3
	move $t6, $t5
	li $t0, 0
	move $k0, $t0
	move $s7, $k0
	li $t0, 0
	move $s3, $t0
	move $s5, $s3
	mul $t3, $t2, $t2
	li $t1, 4
	mul $t4, $t3, $t1
	li $t1, 4
	add $t4, $t4, $t1
	move $a0, $t4
	li $v0, 9
	syscall
	move $t4, $v0
	sw $t3, 0($t4)
	li $t1, 4
	add $t4, $t4, $t1
	move $t3, $t4
	move $t4, $t3
	li $t0, 0
	move $t7, $t0
_ForLoop76:
	mul $t3, $t2, $t2
	slt $t3, $t7, $t3
	beqz $t3, _OutOfFor4
_ForBody3:
	li $t1, 4
	mul $t3, $t7, $t1
	add $t3, $t4, $t3
	li $t0, 0
	sw $t0, 0($t3)
_continueFor77:
	move $t3, $t7
	li $t1, 1
	add $t7, $t7, $t1
	b _ForLoop76
_OutOfFor4:
	mul $t3, $t2, $t2
	li $t1, 4
	mul $t7, $t3, $t1
	li $t1, 4
	add $t7, $t7, $t1
	move $a0, $t7
	li $v0, 9
	syscall
	move $t7, $v0
	sw $t3, 0($t7)
	li $t1, 4
	add $t7, $t7, $t1
	move $t3, $t7
	move $t8, $t3
	li $t0, 0
	move $t7, $t0
_ForLoop78:
	mul $t3, $t2, $t2
	slt $t3, $t7, $t3
	beqz $t3, _OutOfFor6
_ForBody5:
	li $t1, 4
	mul $t3, $t7, $t1
	add $t3, $t8, $t3
	li $t0, 0
	sw $t0, 0($t3)
_continueFor79:
	move $t3, $t7
	li $t1, 1
	add $t7, $t7, $t1
	b _ForLoop78
_OutOfFor6:
	li $t1, 4
	mul $t3, $t2, $t1
	li $t1, 4
	add $t3, $t3, $t1
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
	sw $t2, 0($t3)
	li $t1, 4
	add $t3, $t3, $t1
	move $s6, $t3
	li $t0, 0
	move $t7, $t0
_ForLoop80:
	slt $t3, $t7, $t2
	beqz $t3, _OutOfFor8
_ForBody7:
	li $t1, 4
	mul $t3, $t7, $t1
	add $t3, $s6, $t3
	li $t1, 4
	mul $s1, $t2, $t1
	li $t1, 4
	add $s1, $s1, $t1
	move $a0, $s1
	li $v0, 9
	syscall
	move $s1, $v0
	sw $t2, 0($s1)
	li $t1, 4
	add $s1, $s1, $t1
	sw $s1, 0($t3)
	li $t0, 0
	move $t9, $t0
_ForLoop82:
	slt $t3, $t9, $t2
	beqz $t3, _OutOfFor10
_ForBody9:
	li $t1, 4
	mul $t3, $t7, $t1
	add $t3, $s6, $t3
	lw $s1, 0($t3)
	li $t1, 4
	mul $t3, $t9, $t1
	add $s1, $s1, $t3
	li $t0, 1
	neg $t3, $t0
	sw $t3, 0($s1)
_continueFor83:
	move $t3, $t9
	li $t1, 1
	add $t9, $t9, $t1
	b _ForLoop82
_OutOfFor10:
	b _continueFor81
_continueFor81:
	move $t3, $t7
	li $t1, 1
	add $t7, $t7, $t1
	b _ForLoop80
_OutOfFor8:
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	sw $s2, 0($t3)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t8, $t3
	sw $s0, 0($t3)
	li $t1, 4
	mul $t3, $s2, $t1
	add $t3, $s6, $t3
	lw $s1, 0($t3)
	li $t1, 4
	mul $t3, $s0, $t1
	add $t3, $s1, $t3
	lw $t3, 0($t3)
	li $t1, 0
	seq $t3, $t3, $t1
_WhileLoop84:
	lw $t1, 1460($sp)
	sle $t3, $s4, $t1
	beqz $t3, _OutOfWhile12
_WhileBody11:
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t3, $t3, $t1
	add $t3, $s6, $t3
	lw $s1, 0($t3)
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t3, $t3, $t1
	add $t3, $s1, $t3
	lw $t3, 0($t3)
	move $s5, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	li $t1, 1
	sub $t3, $t3, $t1
	move $s7, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 2
	sub $t3, $t3, $t1
	move $k0, $t3
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
	beqz $t3, _logicalFalse17
_logicalTrue16:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
	move $k1, $t3
	b _logicalMerge18
_logicalFalse17:
	li $t0, 0
	move $k1, $t0
	b _logicalMerge18
_logicalMerge18:
	beqz $k1, _logicalFalse20
_logicalTrue19:
	li $t1, 4
	mul $t3, $s7, $t1
	add $t3, $s6, $t3
	lw $s1, 0($t3)
	li $t1, 4
	mul $t3, $k0, $t1
	add $t3, $s1, $t3
	li $t0, 1
	neg $s1, $t0
	lw $t3, 0($t3)
	seq $t3, $t3, $s1
	move $gp, $t3
	b _logicalMerge21
_logicalFalse20:
	li $t0, 0
	move $gp, $t0
	b _logicalMerge21
_logicalMerge21:
	beqz $gp, _alternative14
_consequence13:
	lw $t0, 1460($sp)
	li $t1, 1
	add $t3, $t0, $t1
	sw $t3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	sw $s7, 0($t3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t8, $t3
	sw $k0, 0($t3)
	li $t1, 4
	mul $t3, $s7, $t1
	add $t3, $s6, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s1, $t3, $s1
	li $t1, 1
	add $t3, $s5, $t1
	sw $t3, 0($s1)
	seq $t3, $s7, $t6
	beqz $t3, _logicalFalse26
_logicalTrue25:
	seq $t3, $k0, $t5
	move $fp, $t3
	b _logicalMerge27
_logicalFalse26:
	li $t0, 0
	move $fp, $t0
	b _logicalMerge27
_logicalMerge27:
	beqz $fp, _alternative23
_consequence22:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf24
_alternative23:
	b _OutOfIf24
_OutOfIf24:
	b _OutOfIf15
_alternative14:
	b _OutOfIf15
_OutOfIf15:
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	li $t1, 1
	sub $t3, $t3, $t1
	move $s7, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 2
	add $t3, $t3, $t1
	move $k0, $t3
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
	beqz $t3, _logicalFalse32
_logicalTrue31:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
	b _logicalMerge33
_logicalFalse32:
	li $t0, 0
	move $t3, $t0
	b _logicalMerge33
_logicalMerge33:
	beqz $t3, _logicalFalse35
_logicalTrue34:
	li $t1, 4
	mul $s1, $s7, $t1
	add $s1, $s6, $s1
	lw $s1, 0($s1)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s1, $s3, $s1
	b _logicalMerge36
_logicalFalse35:
	li $t0, 0
	move $s1, $t0
	b _logicalMerge36
_logicalMerge36:
	beqz $s1, _alternative29
_consequence28:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s3, $s3, $s1
	li $t1, 1
	add $s1, $s5, $t1
	sw $s1, 0($s3)
	seq $s3, $s7, $t6
	beqz $s3, _logicalFalse41
_logicalTrue40:
	seq $s3, $k0, $t5
	b _logicalMerge42
_logicalFalse41:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge42
_logicalMerge42:
	beqz $s3, _alternative38
_consequence37:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf39
_alternative38:
	b _OutOfIf39
_OutOfIf39:
	b _OutOfIf30
_alternative29:
	b _OutOfIf30
_OutOfIf30:
	li $t1, 4
	mul $s7, $s4, $t1
	add $s7, $t4, $s7
	lw $s7, 0($s7)
	li $t1, 1
	add $s7, $s7, $t1
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 2
	sub $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse47
_logicalTrue46:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge48
_logicalFalse47:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge48
_logicalMerge48:
	beqz $s3, _logicalFalse50
_logicalTrue49:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge51
_logicalFalse50:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge51
_logicalMerge51:
	beqz $s3, _alternative44
_consequence43:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s3, $s3, $s1
	li $t1, 1
	add $s1, $s5, $t1
	sw $s1, 0($s3)
	seq $s7, $s7, $t6
	beqz $s7, _logicalFalse56
_logicalTrue55:
	seq $s7, $k0, $t5
	b _logicalMerge57
_logicalFalse56:
	li $t0, 0
	move $s7, $t0
	b _logicalMerge57
_logicalMerge57:
	beqz $s7, _alternative53
_consequence52:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf54
_alternative53:
	b _OutOfIf54
_OutOfIf54:
	b _OutOfIf45
_alternative44:
	b _OutOfIf45
_OutOfIf45:
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t4, $k0
	lw $k0, 0($k0)
	li $t1, 1
	add $k0, $k0, $t1
	move $s7, $k0
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 2
	add $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse62
_logicalTrue61:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge63
_logicalFalse62:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge63
_logicalMerge63:
	beqz $s3, _logicalFalse65
_logicalTrue64:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge66
_logicalFalse65:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge66
_logicalMerge66:
	beqz $s3, _alternative59
_consequence58:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s1, $s1, $s3
	li $t1, 1
	add $s3, $s5, $t1
	sw $s3, 0($s1)
	seq $s7, $s7, $t6
	beqz $s7, _logicalFalse71
_logicalTrue70:
	seq $k0, $k0, $t5
	b _logicalMerge72
_logicalFalse71:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge72
_logicalMerge72:
	beqz $k0, _alternative68
_consequence67:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf69
_alternative68:
	b _OutOfIf69
_OutOfIf69:
	b _OutOfIf60
_alternative59:
	b _OutOfIf60
_OutOfIf60:
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t4, $k0
	lw $k0, 0($k0)
	li $t1, 2
	sub $k0, $k0, $t1
	move $s7, $k0
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 1
	sub $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse77
_logicalTrue76:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge78
_logicalFalse77:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge78
_logicalMerge78:
	beqz $s3, _logicalFalse80
_logicalTrue79:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s3, $s3, $s1
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge81
_logicalFalse80:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge81
_logicalMerge81:
	beqz $s3, _alternative74
_consequence73:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s3, $s3, $s1
	li $t1, 1
	add $s1, $s5, $t1
	sw $s1, 0($s3)
	seq $s7, $s7, $t6
	beqz $s7, _logicalFalse86
_logicalTrue85:
	seq $k0, $k0, $t5
	b _logicalMerge87
_logicalFalse86:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge87
_logicalMerge87:
	beqz $k0, _alternative83
_consequence82:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf84
_alternative83:
	b _OutOfIf84
_OutOfIf84:
	b _OutOfIf75
_alternative74:
	b _OutOfIf75
_OutOfIf75:
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t4, $k0
	lw $s7, 0($k0)
	li $t1, 2
	sub $k0, $s7, $t1
	move $s7, $k0
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 1
	add $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse92
_logicalTrue91:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge93
_logicalFalse92:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge93
_logicalMerge93:
	beqz $s3, _logicalFalse95
_logicalTrue94:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge96
_logicalFalse95:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge96
_logicalMerge96:
	beqz $s3, _alternative89
_consequence88:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s1, $s3, $s1
	li $t1, 1
	add $s3, $s5, $t1
	sw $s3, 0($s1)
	seq $s7, $s7, $t6
	beqz $s7, _logicalFalse101
_logicalTrue100:
	seq $k0, $k0, $t5
	b _logicalMerge102
_logicalFalse101:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge102
_logicalMerge102:
	beqz $k0, _alternative98
_consequence97:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf99
_alternative98:
	b _OutOfIf99
_OutOfIf99:
	b _OutOfIf90
_alternative89:
	b _OutOfIf90
_OutOfIf90:
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t4, $k0
	lw $k0, 0($k0)
	li $t1, 2
	add $k0, $k0, $t1
	move $s7, $k0
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 1
	sub $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse107
_logicalTrue106:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge108
_logicalFalse107:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge108
_logicalMerge108:
	beqz $s3, _logicalFalse110
_logicalTrue109:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge111
_logicalFalse110:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge111
_logicalMerge111:
	beqz $s3, _alternative104
_consequence103:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t1, 1
	add $s1, $s5, $t1
	sw $s1, 0($s3)
	seq $s7, $s7, $t6
	beqz $s7, _logicalFalse116
_logicalTrue115:
	seq $k0, $k0, $t5
	b _logicalMerge117
_logicalFalse116:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge117
_logicalMerge117:
	beqz $k0, _alternative113
_consequence112:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf114
_alternative113:
	b _OutOfIf114
_OutOfIf114:
	b _OutOfIf105
_alternative104:
	b _OutOfIf105
_OutOfIf105:
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t4, $k0
	lw $k0, 0($k0)
	li $t1, 2
	add $k0, $k0, $t1
	move $s7, $k0
	li $t1, 4
	mul $k0, $s4, $t1
	add $k0, $t8, $k0
	lw $k0, 0($k0)
	li $t1, 1
	add $k0, $k0, $t1
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	beqz $s3, _logicalFalse122
_logicalTrue121:
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
	b _logicalMerge123
_logicalFalse122:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge123
_logicalMerge123:
	beqz $s3, _logicalFalse125
_logicalTrue124:
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s1, 0($s3)
	li $t1, 4
	mul $s3, $k0, $t1
	add $s3, $s1, $s3
	li $t0, 1
	neg $s1, $t0
	lw $s3, 0($s3)
	seq $s3, $s3, $s1
	b _logicalMerge126
_logicalFalse125:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge126
_logicalMerge126:
	beqz $s3, _alternative119
_consequence118:
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
	sw $s3, 1460($sp)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t4, $s3
	sw $s7, 0($s3)
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
	add $s3, $t8, $s3
	sw $k0, 0($s3)
	li $t1, 4
	mul $s3, $s7, $t1
	add $s3, $s6, $s3
	lw $s3, 0($s3)
	li $t1, 4
	mul $s1, $k0, $t1
	add $s3, $s3, $s1
	li $t1, 1
	add $s1, $s5, $t1
	sw $s1, 0($s3)
	seq $s3, $s7, $t6
	beqz $s3, _logicalFalse131
_logicalTrue130:
	seq $s3, $k0, $t5
	b _logicalMerge132
_logicalFalse131:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge132
_logicalMerge132:
	beqz $s3, _alternative128
_consequence127:
	li $t0, 1
	move $s3, $t0
	b _OutOfIf129
_alternative128:
	b _OutOfIf129
_OutOfIf129:
	b _OutOfIf120
_alternative119:
	b _OutOfIf120
_OutOfIf120:
	li $t1, 1
	seq $s1, $s3, $t1
	beqz $s1, _alternative134
_consequence133:
	b _OutOfWhile12
	b _OutOfIf135
_alternative134:
	b _OutOfIf135
_OutOfIf135:
	li $t1, 1
	add $s4, $s4, $t1
	b _WhileLoop84
_OutOfWhile12:
	li $t1, 1
	seq $s1, $s3, $t1
	beqz $s1, _alternative137
_consequence136:
	li $t1, 4
	mul $s1, $t6, $t1
	add $s1, $s6, $s1
	lw $t3, 0($s1)
	li $t1, 4
	mul $s1, $t5, $t1
	add $s1, $t3, $s1
	lw $s1, 0($s1)
	move $a0, $s1
	jal func__toString
	move $s1, $v0
	move $a0, $s1
	jal func__println
	move $s1, $v0
	b _OutOfIf138
_alternative137:
	la $a0, string_430
	jal func__print
	move $s1, $v0
	b _OutOfIf138
_OutOfIf138:
	li $v0, 0
	b _EndOfFunctionDecl75
_EndOfFunctionDecl75:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t8, 96($sp)
	lw $fp, 124($sp)
	lw $t6, 56($sp)
	lw $s7, 92($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t9, 100($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $t4, 48($sp)
	lw $gp, 112($sp)
	lw $k1, 108($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $k0, 104($sp)
	lw $t5, 52($sp)
	lw $s4, 80($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 1576
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
.word 13
string_430:
.asciiz "no solution!\n"
.align 2
