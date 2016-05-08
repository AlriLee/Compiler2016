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
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl890:
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _logicalFalse904
_logicalTrue903:
	lw $t0, 140($sp)
	li $t1, 0
	sge $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	sw $t0, 132($sp)
	b _logicalMerge905
_logicalFalse904:
	li $t0, 0
	sw $t0, 132($sp)
	b _logicalMerge905
_logicalMerge905:
	lw $v0, 132($sp)
	b _EndOfFunctionDecl891
_EndOfFunctionDecl891:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
	add $sp, $sp, 148
	jr $ra
main:
	sub $sp, $sp, 1576
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl892:
	jal func__getInt
	sw $v0, 1092($sp)
	lw $t0, 1092($sp)
	move $s0, $t0
	li $t0, 0
	move $s7, $t0
	move $t4, $s7
	move $t5, $t4
	move $s4, $t5
	li $t1, 1
	sub $t2, $s0, $t1
	move $t7, $t2
	move $s1, $t7
	li $t0, 0
	sw $t0, 1456($sp)
	lw $t0, 1456($sp)
	move $s3, $t0
	li $t0, 0
	move $s2, $t0
	move $k0, $s2
	mul $t3, $s0, $s0
	li $t1, 4
	mul $t2, $t3, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	sw $t3, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	move $t2, $t2
	move $s5, $t2
	li $t0, 0
	move $t2, $t0
_ForLoop894:
	mul $t3, $s0, $s0
	slt $t3, $t2, $t3
	beqz $t3, _OutOfFor907
_ForBody906:
	li $t1, 4
	mul $t3, $t2, $t1
	add $t3, $s5, $t3
	li $t0, 0
	sw $t0, 0($t3)
_continueFor895:
	move $t3, $t2
	li $t1, 1
	add $t2, $t2, $t1
	b _ForLoop894
_OutOfFor907:
	mul $t3, $s0, $s0
	li $t1, 4
	mul $t2, $t3, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	sw $t3, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	move $t2, $t2
	move $t8, $t2
	li $t0, 0
	move $t2, $t0
_ForLoop896:
	mul $t3, $s0, $s0
	slt $t3, $t2, $t3
	beqz $t3, _OutOfFor909
_ForBody908:
	li $t1, 4
	mul $t3, $t2, $t1
	add $t3, $t8, $t3
	li $t0, 0
	sw $t0, 0($t3)
_continueFor897:
	move $t3, $t2
	li $t1, 1
	add $t2, $t2, $t1
	b _ForLoop896
_OutOfFor909:
	li $t1, 4
	mul $t2, $s0, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	sw $s0, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	move $t2, $t2
	move $s6, $t2
	li $t0, 0
	move $t2, $t0
_ForLoop898:
	slt $t3, $t2, $s0
	beqz $t3, _OutOfFor911
_ForBody910:
	li $t1, 4
	mul $t3, $t2, $t1
	add $t3, $s6, $t3
	li $t1, 4
	mul $t6, $s0, $t1
	li $t1, 4
	add $t6, $t6, $t1
	move $a0, $t6
	li $v0, 9
	syscall
	move $t6, $v0
	sw $s0, 0($t6)
	li $t1, 4
	add $t6, $t6, $t1
	move $t6, $t6
	sw $t6, 0($t3)
	li $t0, 0
	move $t9, $t0
_ForLoop900:
	slt $t3, $t9, $s0
	beqz $t3, _OutOfFor913
_ForBody912:
	li $t1, 4
	mul $t3, $t2, $t1
	add $t3, $s6, $t3
	lw $t6, 0($t3)
	li $t1, 4
	mul $t3, $t9, $t1
	add $t3, $t6, $t3
	li $t0, 1
	neg $t6, $t0
	sw $t6, 0($t3)
_continueFor901:
	move $t3, $t9
	li $t1, 1
	add $t9, $t9, $t1
	b _ForLoop900
_OutOfFor913:
	b _continueFor899
_continueFor899:
	move $t3, $t2
	li $t1, 1
	add $t2, $t2, $t1
	b _ForLoop898
_OutOfFor911:
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $s5, $t3
	sw $t4, 0($t3)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t8, $t3
	sw $s7, 0($t3)
	li $t1, 4
	mul $t3, $t4, $t1
	add $t3, $s6, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t6, $s7, $t1
	add $t3, $t3, $t6
	lw $t3, 0($t3)
	li $t1, 0
	seq $t3, $t3, $t1
_WhileLoop902:
	sle $t3, $s4, $t5
	beqz $t3, _OutOfWhile915
_WhileBody914:
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $s5, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t3, $t3, $t1
	add $t3, $s6, $t3
	lw $t6, 0($t3)
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t3, $t3, $t1
	add $t3, $t6, $t3
	lw $t3, 0($t3)
	move $k0, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $s5, $t3
	lw $t3, 0($t3)
	li $t1, 1
	sub $t3, $t3, $t1
	move $s3, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 2
	sub $t3, $t3, $t1
	sw $t3, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $t3, $v0
	beqz $t3, _logicalFalse920
_logicalTrue919:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $t3, $v0
	move $k1, $t3
	b _logicalMerge921
_logicalFalse920:
	li $t0, 0
	move $k1, $t0
	b _logicalMerge921
_logicalMerge921:
	beqz $k1, _logicalFalse923
_logicalTrue922:
	li $t1, 4
	mul $t3, $s3, $t1
	add $t3, $s6, $t3
	lw $t6, 0($t3)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t6, $t3
	li $t0, 1
	neg $t6, $t0
	lw $t3, 0($t3)
	seq $t3, $t3, $t6
	move $gp, $t3
	b _logicalMerge924
_logicalFalse923:
	li $t0, 0
	move $gp, $t0
	b _logicalMerge924
_logicalMerge924:
	beqz $gp, _alternative917
_consequence916:
	li $t1, 1
	add $t3, $t5, $t1
	move $t5, $t3
	li $t1, 4
	mul $t3, $t5, $t1
	add $t3, $s5, $t3
	sw $s3, 0($t3)
	li $t1, 4
	mul $t3, $t5, $t1
	add $t3, $t8, $t3
	lw $t0, 1456($sp)
	sw $t0, 0($t3)
	li $t1, 4
	mul $t3, $s3, $t1
	add $t3, $s6, $t3
	lw $t6, 0($t3)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t6, $t3
	li $t1, 1
	add $t6, $k0, $t1
	sw $t6, 0($t3)
	seq $t3, $s3, $s1
	beqz $t3, _logicalFalse929
_logicalTrue928:
	lw $t0, 1456($sp)
	seq $t3, $t0, $t7
	move $fp, $t3
	b _logicalMerge930
_logicalFalse929:
	li $t0, 0
	move $fp, $t0
	b _logicalMerge930
_logicalMerge930:
	beqz $fp, _alternative926
_consequence925:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf927
_alternative926:
	b _OutOfIf927
_OutOfIf927:
	b _OutOfIf918
_alternative917:
	b _OutOfIf918
_OutOfIf918:
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $s5, $t3
	lw $t3, 0($t3)
	li $t1, 1
	sub $t3, $t3, $t1
	move $s3, $t3
	li $t1, 4
	mul $t3, $s4, $t1
	add $t3, $t8, $t3
	lw $t3, 0($t3)
	li $t1, 2
	add $t3, $t3, $t1
	sw $t3, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $t3, $v0
	beqz $t3, _logicalFalse935
_logicalTrue934:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $t3, $v0
	move $t3, $t3
	b _logicalMerge936
_logicalFalse935:
	li $t0, 0
	move $t3, $t0
	b _logicalMerge936
_logicalMerge936:
	beqz $t3, _logicalFalse938
_logicalTrue937:
	li $t1, 4
	mul $t6, $s3, $t1
	add $t6, $s6, $t6
	lw $s2, 0($t6)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t6, $t0, $t1
	add $s2, $s2, $t6
	li $t0, 1
	neg $t6, $t0
	lw $s2, 0($s2)
	seq $t6, $s2, $t6
	move $t6, $t6
	b _logicalMerge939
_logicalFalse938:
	li $t0, 0
	move $t6, $t0
	b _logicalMerge939
_logicalMerge939:
	beqz $t6, _alternative932
_consequence931:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $s2, $t6, $s2
	li $t1, 1
	add $t6, $k0, $t1
	sw $t6, 0($s2)
	seq $s2, $s3, $s1
	beqz $s2, _logicalFalse944
_logicalTrue943:
	lw $t0, 1456($sp)
	seq $s2, $t0, $t7
	move $s2, $s2
	b _logicalMerge945
_logicalFalse944:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge945
_logicalMerge945:
	beqz $s2, _alternative941
_consequence940:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf942
_alternative941:
	b _OutOfIf942
_OutOfIf942:
	b _OutOfIf933
_alternative932:
	b _OutOfIf933
_OutOfIf933:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 1
	add $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 2
	sub $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse950
_logicalTrue949:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge951
_logicalFalse950:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge951
_logicalMerge951:
	beqz $s2, _logicalFalse953
_logicalTrue952:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $s2, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t6, $t0, $t1
	add $t6, $s2, $t6
	li $t0, 1
	neg $s2, $t0
	lw $t6, 0($t6)
	seq $s2, $t6, $s2
	move $s2, $s2
	b _logicalMerge954
_logicalFalse953:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge954
_logicalMerge954:
	beqz $s2, _alternative947
_consequence946:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $s2, $t6, $s2
	li $t1, 1
	add $t6, $k0, $t1
	sw $t6, 0($s2)
	seq $s3, $s3, $s1
	beqz $s3, _logicalFalse959
_logicalTrue958:
	lw $t0, 1456($sp)
	seq $s3, $t0, $t7
	move $s3, $s3
	b _logicalMerge960
_logicalFalse959:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge960
_logicalMerge960:
	beqz $s3, _alternative956
_consequence955:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf957
_alternative956:
	b _OutOfIf957
_OutOfIf957:
	b _OutOfIf948
_alternative947:
	b _OutOfIf948
_OutOfIf948:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 1
	add $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 2
	add $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse965
_logicalTrue964:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge966
_logicalFalse965:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge966
_logicalMerge966:
	beqz $s2, _logicalFalse968
_logicalTrue967:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $t6, $t6, $s2
	li $t0, 1
	neg $s2, $t0
	lw $t6, 0($t6)
	seq $s2, $t6, $s2
	move $s2, $s2
	b _logicalMerge969
_logicalFalse968:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge969
_logicalMerge969:
	beqz $s2, _alternative962
_consequence961:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $s2, $t6, $s2
	li $t1, 1
	add $t6, $k0, $t1
	sw $t6, 0($s2)
	seq $s3, $s3, $s1
	beqz $s3, _logicalFalse974
_logicalTrue973:
	lw $t0, 1456($sp)
	seq $s3, $t0, $t7
	move $s3, $s3
	b _logicalMerge975
_logicalFalse974:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge975
_logicalMerge975:
	beqz $s3, _alternative971
_consequence970:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf972
_alternative971:
	b _OutOfIf972
_OutOfIf972:
	b _OutOfIf963
_alternative962:
	b _OutOfIf963
_OutOfIf963:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 2
	sub $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 1
	sub $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse980
_logicalTrue979:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge981
_logicalFalse980:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge981
_logicalMerge981:
	beqz $s2, _logicalFalse983
_logicalTrue982:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $s2, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t6, $t0, $t1
	add $s2, $s2, $t6
	li $t0, 1
	neg $t6, $t0
	lw $s2, 0($s2)
	seq $s2, $s2, $t6
	move $s2, $s2
	b _logicalMerge984
_logicalFalse983:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge984
_logicalMerge984:
	beqz $s2, _alternative977
_consequence976:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $t6, $t6, $s2
	li $t1, 1
	add $s2, $k0, $t1
	sw $s2, 0($t6)
	seq $s3, $s3, $s1
	beqz $s3, _logicalFalse989
_logicalTrue988:
	lw $t0, 1456($sp)
	seq $s3, $t0, $t7
	move $s3, $s3
	b _logicalMerge990
_logicalFalse989:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge990
_logicalMerge990:
	beqz $s3, _alternative986
_consequence985:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf987
_alternative986:
	b _OutOfIf987
_OutOfIf987:
	b _OutOfIf978
_alternative977:
	b _OutOfIf978
_OutOfIf978:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 2
	sub $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 1
	add $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse995
_logicalTrue994:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge996
_logicalFalse995:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge996
_logicalMerge996:
	beqz $s2, _logicalFalse998
_logicalTrue997:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $s2, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t6, $t0, $t1
	add $s2, $s2, $t6
	li $t0, 1
	neg $t6, $t0
	lw $s2, 0($s2)
	seq $s2, $s2, $t6
	move $s2, $s2
	b _logicalMerge999
_logicalFalse998:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge999
_logicalMerge999:
	beqz $s2, _alternative992
_consequence991:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $t6, $t6, $s2
	li $t1, 1
	add $s2, $k0, $t1
	sw $s2, 0($t6)
	seq $s3, $s3, $s1
	beqz $s3, _logicalFalse1004
_logicalTrue1003:
	lw $t0, 1456($sp)
	seq $s3, $t0, $t7
	move $s3, $s3
	b _logicalMerge1005
_logicalFalse1004:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge1005
_logicalMerge1005:
	beqz $s3, _alternative1001
_consequence1000:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf1002
_alternative1001:
	b _OutOfIf1002
_OutOfIf1002:
	b _OutOfIf993
_alternative992:
	b _OutOfIf993
_OutOfIf993:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 2
	add $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 1
	sub $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse1010
_logicalTrue1009:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge1011
_logicalFalse1010:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge1011
_logicalMerge1011:
	beqz $s2, _logicalFalse1013
_logicalTrue1012:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $t6, $t6, $s2
	li $t0, 1
	neg $s2, $t0
	lw $t6, 0($t6)
	seq $s2, $t6, $s2
	move $s2, $s2
	b _logicalMerge1014
_logicalFalse1013:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge1014
_logicalMerge1014:
	beqz $s2, _alternative1007
_consequence1006:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $s2, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $t6, $t0, $t1
	add $s2, $s2, $t6
	li $t1, 1
	add $t6, $k0, $t1
	sw $t6, 0($s2)
	seq $s3, $s3, $s1
	beqz $s3, _logicalFalse1019
_logicalTrue1018:
	lw $t0, 1456($sp)
	seq $s3, $t0, $t7
	move $s3, $s3
	b _logicalMerge1020
_logicalFalse1019:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge1020
_logicalMerge1020:
	beqz $s3, _alternative1016
_consequence1015:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf1017
_alternative1016:
	b _OutOfIf1017
_OutOfIf1017:
	b _OutOfIf1008
_alternative1007:
	b _OutOfIf1008
_OutOfIf1008:
	li $t1, 4
	mul $s3, $s4, $t1
	add $s3, $s5, $s3
	lw $s3, 0($s3)
	li $t1, 2
	add $s3, $s3, $t1
	move $s3, $s3
	li $t1, 4
	mul $s2, $s4, $t1
	add $s2, $t8, $s2
	lw $s2, 0($s2)
	li $t1, 1
	add $s2, $s2, $t1
	sw $s2, 1456($sp)
	sw $s3, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	beqz $s2, _logicalFalse1025
_logicalTrue1024:
	lw $t0, 1456($sp)
	sw $t0, -8($sp)
	sw $s0, -4($sp)
	jal _check
	move $s2, $v0
	move $s2, $s2
	b _logicalMerge1026
_logicalFalse1025:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge1026
_logicalMerge1026:
	beqz $s2, _logicalFalse1028
_logicalTrue1027:
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $s2, $t6, $s2
	li $t0, 1
	neg $t6, $t0
	lw $s2, 0($s2)
	seq $s2, $s2, $t6
	move $s2, $s2
	b _logicalMerge1029
_logicalFalse1028:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge1029
_logicalMerge1029:
	beqz $s2, _alternative1022
_consequence1021:
	li $t1, 1
	add $t5, $t5, $t1
	move $t5, $t5
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $s5, $s2
	sw $s3, 0($s2)
	li $t1, 4
	mul $s2, $t5, $t1
	add $s2, $t8, $s2
	lw $t0, 1456($sp)
	sw $t0, 0($s2)
	li $t1, 4
	mul $s2, $s3, $t1
	add $s2, $s6, $s2
	lw $t6, 0($s2)
	lw $t0, 1456($sp)
	li $t1, 4
	mul $s2, $t0, $t1
	add $t6, $t6, $s2
	li $t1, 1
	add $s2, $k0, $t1
	sw $s2, 0($t6)
	seq $s2, $s3, $s1
	beqz $s2, _logicalFalse1034
_logicalTrue1033:
	lw $t0, 1456($sp)
	seq $s2, $t0, $t7
	move $s2, $s2
	b _logicalMerge1035
_logicalFalse1034:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge1035
_logicalMerge1035:
	beqz $s2, _alternative1031
_consequence1030:
	li $t0, 1
	move $s2, $t0
	b _OutOfIf1032
_alternative1031:
	b _OutOfIf1032
_OutOfIf1032:
	b _OutOfIf1023
_alternative1022:
	b _OutOfIf1023
_OutOfIf1023:
	li $t1, 1
	seq $t6, $s2, $t1
	beqz $t6, _alternative1037
_consequence1036:
	b _OutOfWhile915
	b _OutOfIf1038
_alternative1037:
	b _OutOfIf1038
_OutOfIf1038:
	li $t1, 1
	add $s4, $s4, $t1
	move $s4, $s4
	b _WhileLoop902
_OutOfWhile915:
	li $t1, 1
	seq $t6, $s2, $t1
	beqz $t6, _alternative1040
_consequence1039:
	li $t1, 4
	mul $t6, $s1, $t1
	add $t6, $s6, $t6
	lw $t6, 0($t6)
	li $t1, 4
	mul $t3, $t7, $t1
	add $t6, $t6, $t3
	lw $t6, 0($t6)
	move $a0, $t6
	jal func__toString
	move $t6, $v0
	move $a0, $t6
	jal func__println
	move $t6, $v0
	b _OutOfIf1041
_alternative1040:
	la $a0, string_430
	jal func__print
	move $t6, $v0
	b _OutOfIf1041
_OutOfIf1041:
	li $v0, 0
	b _EndOfFunctionDecl893
_EndOfFunctionDecl893:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
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
