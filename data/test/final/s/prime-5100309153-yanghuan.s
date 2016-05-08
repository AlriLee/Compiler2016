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
_BeginOfFunctionDecl1612:
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $a0, 140($sp)
	li $v0, 9
	syscall
	sw $v0, 192($sp)
	lw $t0, 196($sp)
	lw $t1, 192($sp)
	sw $t0, 0($t1)
	lw $t0, 192($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 192($sp)
	sw $t0, 176($sp)
	lw $t0, 176($sp)
	sw $t0, global_68
	li $t0, 0
	sw $t0, global_60
_ForLoop1622:
	lw $t0, global_60
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _OutOfFor1643
_ForBody1642:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, global_68
	lw $t1, 180($sp)
	add $t2, $t0, $t1
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $a0, 164($sp)
	li $v0, 9
	syscall
	sw $v0, 152($sp)
	lw $t0, 196($sp)
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	sw $t0, 0($t2)
	li $t0, 0
	sw $t0, global_61
_ForLoop1624:
	lw $t0, global_61
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	beqz $t0, _OutOfFor1645
_ForBody1644:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, global_68
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t1, 172($sp)
	lw $t0, 0($t1)
	sw $t0, 188($sp)
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, 188($sp)
	add $t1, $t0, $t2
	sw $t1, 156($sp)
	li $t0, 0
	lw $t1, 156($sp)
	sw $t0, 0($t1)
_continueFor1625:
	lw $t0, global_61
	sw $t0, 132($sp)
	lw $t0, global_61
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_61
	b _ForLoop1624
_OutOfFor1645:
	b _continueFor1623
_continueFor1623:
	lw $t0, global_60
	sw $t0, 148($sp)
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_60
	b _ForLoop1622
_OutOfFor1643:
	b _EndOfFunctionDecl1613
_EndOfFunctionDecl1613:
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
	add $sp, $sp, 200
	jr $ra
_getPrime:
	sub $sp, $sp, 252
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
_BeginOfFunctionDecl1614:
	li $t0, 2
	move $t2, $t0
	li $t0, 2
	move $t4, $t0
_ForLoop1626:
	lw $t1, 248($sp)
	sle $t3, $t4, $t1
	beqz $t3, _OutOfFor1647
_ForBody1646:
	li $t1, 4
	mul $t3, $t4, $t1
	lw $t0, global_64
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t1, 1
	seq $t3, $t3, $t1
	beqz $t3, _alternative1649
_consequence1648:
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_67
	add $t5, $t0, $t3
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, global_67
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t1, 236($sp)
	lw $t3, 0($t1)
	li $t1, 1
	add $t3, $t3, $t1
	sw $t3, 0($t5)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_67
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_65
	add $t3, $t0, $t3
	sw $t4, 0($t3)
	li $t1, 4
	mul $t3, $t4, $t1
	lw $t0, global_66
	add $t5, $t0, $t3
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, global_67
	lw $t1, 244($sp)
	add $t3, $t0, $t1
	lw $t3, 0($t3)
	sw $t3, 0($t5)
	b _OutOfIf1650
_alternative1649:
	b _OutOfIf1650
_OutOfIf1650:
	b _WhileLoop1628
_WhileLoop1628:
	mul $t3, $t4, $t2
	lw $t1, 248($sp)
	sle $t3, $t3, $t1
	beqz $t3, _OutOfWhile1652
_WhileBody1651:
	mul $t3, $t4, $t2
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_64
	add $t3, $t0, $t3
	li $t0, 0
	sw $t0, 0($t3)
	li $t1, 1
	add $t2, $t2, $t1
	move $t2, $t2
	b _WhileLoop1628
_OutOfWhile1652:
	li $t0, 2
	move $t2, $t0
_continueFor1627:
	li $t1, 1
	add $t3, $t4, $t1
	move $t4, $t3
	b _ForLoop1626
_OutOfFor1647:
	b _EndOfFunctionDecl1615
_EndOfFunctionDecl1615:
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
	add $sp, $sp, 252
	jr $ra
_getResult:
	sub $sp, $sp, 404
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
_BeginOfFunctionDecl1616:
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, global_68
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t1, 156($sp)
	lw $t2, 0($t1)
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t1, 380($sp)
	add $t1, $t2, $t1
	sw $t1, 304($sp)
	li $t0, 1
	neg $t2, $t0
	lw $t1, 304($sp)
	lw $t0, 0($t1)
	sw $t0, 308($sp)
	lw $t0, 308($sp)
	seq $t1, $t0, $t2
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _alternative1654
_consequence1653:
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, global_65
	lw $t1, 312($sp)
	add $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t1, 316($sp)
	lw $t0, 0($t1)
	sw $t0, 328($sp)
	lw $t0, 328($sp)
	li $t1, 2
	mul $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_65
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 232($sp)
	sub $t1, $t0, $t2
	sw $t1, 320($sp)
	lw $t0, 320($sp)
	lw $t1, 392($sp)
	sle $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	beqz $t0, _alternative1657
_consequence1656:
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, global_65
	lw $t1, 264($sp)
	add $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t1, 348($sp)
	lw $t0, 0($t1)
	sw $t0, 384($sp)
	lw $t0, 384($sp)
	li $t1, 2
	mul $t2, $t0, $t1
	lw $t0, 396($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_65
	add $t1, $t0, $t3
	sw $t1, 376($sp)
	lw $t1, 376($sp)
	lw $t0, 0($t1)
	sw $t0, 324($sp)
	lw $t1, 324($sp)
	sub $t1, $t2, $t1
	sw $t1, 236($sp)
	lw $t0, 236($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t0, global_64
	lw $t1, 276($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
	lw $t0, 220($sp)
	li $t1, 0
	sne $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 176($sp)
	beqz $t0, _alternative1660
_consequence1659:
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, global_68
	lw $t1, 144($sp)
	add $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t1, 256($sp)
	lw $t2, 0($t1)
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t1, 188($sp)
	add $t3, $t2, $t1
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_65
	add $t1, $t0, $t2
	sw $t1, 208($sp)
	lw $t1, 208($sp)
	lw $t0, 0($t1)
	sw $t0, 364($sp)
	lw $t0, 364($sp)
	li $t1, 2
	mul $t2, $t0, $t1
	lw $t0, 396($sp)
	li $t1, 4
	mul $t4, $t0, $t1
	lw $t0, global_65
	add $t1, $t0, $t4
	sw $t1, 336($sp)
	lw $t1, 336($sp)
	lw $t0, 0($t1)
	sw $t0, 332($sp)
	lw $t1, 332($sp)
	sub $t1, $t2, $t1
	sw $t1, 224($sp)
	lw $t0, 224($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_66
	add $t1, $t0, $t2
	sw $t1, 344($sp)
	lw $t1, 344($sp)
	lw $t2, 0($t1)
	lw $t0, 392($sp)
	sw $t0, -12($sp)
	lw $t0, 400($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _getResult
	sw $v0, 192($sp)
	lw $t0, 192($sp)
	li $t1, 1
	add $t2, $t0, $t1
	sw $t2, 0($t3)
	b _OutOfIf1661
_alternative1660:
	b _OutOfIf1661
_OutOfIf1661:
	b _OutOfIf1658
_alternative1657:
	b _OutOfIf1658
_OutOfIf1658:
	b _OutOfIf1655
_alternative1654:
	b _OutOfIf1655
_OutOfIf1655:
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, global_68
	lw $t1, 200($sp)
	add $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t1, 368($sp)
	lw $t0, 0($t1)
	sw $t0, 352($sp)
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, 352($sp)
	add $t2, $t0, $t2
	li $t0, 1
	neg $t1, $t0
	sw $t1, 356($sp)
	lw $t2, 0($t2)
	lw $t1, 356($sp)
	seq $t1, $t2, $t1
	sw $t1, 216($sp)
	lw $t0, 216($sp)
	beqz $t0, _alternative1663
_consequence1662:
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, global_68
	lw $t1, 296($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t1, 196($sp)
	lw $t2, 0($t1)
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t1, 388($sp)
	add $t1, $t2, $t1
	sw $t1, 260($sp)
	li $t0, 1
	lw $t1, 260($sp)
	sw $t0, 0($t1)
	b _OutOfIf1664
_alternative1663:
	b _OutOfIf1664
_OutOfIf1664:
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, global_68
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 292($sp)
	lw $t1, 292($sp)
	lw $t2, 0($t1)
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t1, 360($sp)
	add $t1, $t2, $t1
	sw $t1, 372($sp)
	lw $t1, 372($sp)
	lw $t0, 0($t1)
	sw $t0, 248($sp)
	lw $v0, 248($sp)
	b _EndOfFunctionDecl1617
_EndOfFunctionDecl1617:
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
	add $sp, $sp, 404
	jr $ra
_printF:
	sub $sp, $sp, 188
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
_BeginOfFunctionDecl1618:
	lw $a0, 176($sp)
	jal func__toString
	sw $v0, 152($sp)
	lw $a0, 152($sp)
	jal func__print
	sw $v0, 156($sp)
_WhileLoop1629:
	lw $t0, 184($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	beqz $t0, _OutOfWhile1666
_WhileBody1665:
	la $a0, string_130
	jal func__print
	sw $v0, 136($sp)
	lw $a0, 180($sp)
	jal func__toString
	sw $v0, 140($sp)
	lw $a0, 140($sp)
	jal func__print
	sw $v0, 128($sp)
	lw $t0, 180($sp)
	li $t1, 2
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	lw $t1, 176($sp)
	sub $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	sw $t0, 180($sp)
	lw $t0, 176($sp)
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	li $t1, 2
	div $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	sw $t0, 176($sp)
	lw $t0, 184($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	sw $t0, 184($sp)
	b _WhileLoop1629
_OutOfWhile1666:
	la $a0, string_142
	jal func__print
	sw $v0, 164($sp)
_EndOfFunctionDecl1619:
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
	add $sp, $sp, 188
	jr $ra
main:
	sub $sp, $sp, 468
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
_BeginOfFunctionDecl1620:
	li $t0, 1001
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, 360($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $a0, 360($sp)
	li $v0, 9
	syscall
	sw $v0, 264($sp)
	li $t0, 1001
	lw $t1, 264($sp)
	sw $t0, 0($t1)
	lw $t0, 264($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, 264($sp)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	sw $t0, global_64
	li $t0, 170
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $a0, 168($sp)
	li $v0, 9
	syscall
	sw $v0, 244($sp)
	li $t0, 170
	lw $t1, 244($sp)
	sw $t0, 0($t1)
	lw $t0, 244($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 244($sp)
	sw $t0, 420($sp)
	lw $t0, 420($sp)
	sw $t0, global_65
	li $t0, 1001
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, 248($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $a0, 248($sp)
	li $v0, 9
	syscall
	sw $v0, 400($sp)
	li $t0, 1001
	lw $t1, 400($sp)
	sw $t0, 0($t1)
	lw $t0, 400($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 400($sp)
	lw $t0, 400($sp)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_66
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $a0, 128($sp)
	li $v0, 9
	syscall
	sw $v0, 332($sp)
	li $t0, 1
	lw $t1, 332($sp)
	sw $t0, 0($t1)
	lw $t0, 332($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	lw $t0, 332($sp)
	sw $t0, 280($sp)
	lw $t0, 280($sp)
	sw $t0, global_67
	li $t0, 170
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 192($sp)
	li $t0, 1000
	sw $t0, global_58
	jal func__getInt
	sw $v0, 316($sp)
	lw $t0, 316($sp)
	sw $t0, global_59
	li $t0, 0
	sw $t0, global_62
	li $t0, 0
	sw $t0, global_63
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 328($sp)
	lw $t0, global_67
	lw $t1, 328($sp)
	add $t1, $t0, $t1
	sw $t1, 352($sp)
	li $t0, 0
	lw $t1, 352($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, global_60
_ForLoop1630:
	lw $t0, global_58
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 456($sp)
	lw $t0, global_60
	lw $t1, 456($sp)
	slt $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t0, 376($sp)
	beqz $t0, _OutOfFor1668
_ForBody1667:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, global_64
	lw $t1, 324($sp)
	add $t1, $t0, $t1
	sw $t1, 396($sp)
	li $t0, 1
	lw $t1, 396($sp)
	sw $t0, 0($t1)
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, global_66
	lw $t1, 356($sp)
	add $t1, $t0, $t1
	sw $t1, 284($sp)
	li $t0, 0
	lw $t1, 284($sp)
	sw $t0, 0($t1)
_continueFor1631:
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	sw $t0, global_60
	b _ForLoop1630
_OutOfFor1668:
	li $t0, 0
	sw $t0, global_60
_ForLoop1632:
	lw $t0, global_59
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, global_60
	lw $t1, 176($sp)
	slt $t1, $t0, $t1
	sw $t1, 392($sp)
	lw $t0, 392($sp)
	beqz $t0, _OutOfFor1670
_ForBody1669:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 408($sp)
	lw $t0, global_65
	lw $t1, 408($sp)
	add $t1, $t0, $t1
	sw $t1, 380($sp)
	li $t0, 0
	lw $t1, 380($sp)
	sw $t0, 0($t1)
_continueFor1633:
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 212($sp)
	sw $t0, global_60
	b _ForLoop1632
_OutOfFor1670:
	li $t0, 0
	sw $t0, global_60
_ForLoop1634:
	lw $t0, global_60
	lw $t1, global_59
	sle $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, 312($sp)
	beqz $t0, _OutOfFor1672
_ForBody1671:
	li $t0, 0
	sw $t0, global_61
_ForLoop1636:
	lw $t0, global_61
	lw $t1, global_59
	sle $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _OutOfFor1674
_ForBody1673:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t0, global_68
	lw $t1, 424($sp)
	add $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t1, 368($sp)
	lw $t2, 0($t1)
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t1, 404($sp)
	add $t1, $t2, $t1
	sw $t1, 216($sp)
	li $t0, 1
	neg $t2, $t0
	lw $t1, 216($sp)
	sw $t2, 0($t1)
_continueFor1637:
	lw $t0, global_61
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, 296($sp)
	sw $t0, global_61
	b _ForLoop1636
_OutOfFor1674:
	b _continueFor1635
_continueFor1635:
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, 432($sp)
	sw $t0, global_60
	b _ForLoop1634
_OutOfFor1672:
	lw $t0, global_58
	sw $t0, -4($sp)
	jal _getPrime
	sw $v0, 224($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, global_67
	lw $t1, 444($sp)
	add $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t1, 348($sp)
	lw $t0, 0($t1)
	sw $t0, 436($sp)
	lw $t0, 436($sp)
	sw $t0, global_62
	li $t0, 1
	sw $t0, global_60
_ForLoop1638:
	lw $t0, global_60
	lw $t1, global_62
	slt $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 252($sp)
	beqz $t0, _OutOfFor1676
_ForBody1675:
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	sw $t0, global_61
_ForLoop1640:
	lw $t0, global_61
	lw $t1, global_62
	sle $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, 208($sp)
	beqz $t0, _OutOfFor1678
_ForBody1677:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t0, global_68
	lw $t1, 228($sp)
	add $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t1, 256($sp)
	lw $t2, 0($t1)
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t1, 320($sp)
	add $t1, $t2, $t1
	sw $t1, 300($sp)
	li $t0, 1
	neg $t2, $t0
	lw $t1, 300($sp)
	lw $t0, 0($t1)
	sw $t0, 440($sp)
	lw $t0, 440($sp)
	seq $t1, $t0, $t2
	sw $t1, 260($sp)
	lw $t0, 260($sp)
	beqz $t0, _alternative1680
_consequence1679:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, global_68
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t2, 0($t1)
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $t1, 412($sp)
	add $t2, $t2, $t1
	lw $t0, global_58
	sw $t0, -12($sp)
	lw $t0, global_60
	sw $t0, -8($sp)
	lw $t0, global_61
	sw $t0, -4($sp)
	jal _getResult
	sw $v0, 276($sp)
	lw $t0, 276($sp)
	sw $t0, 0($t2)
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, global_68
	lw $t1, 160($sp)
	add $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t1, 344($sp)
	lw $t0, 0($t1)
	sw $t0, 200($sp)
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, 200($sp)
	add $t1, $t0, $t2
	sw $t1, 292($sp)
	lw $t1, 292($sp)
	lw $t0, 0($t1)
	sw $t0, 304($sp)
	lw $t0, 304($sp)
	li $t1, 1
	sgt $t1, $t0, $t1
	sw $t1, 308($sp)
	lw $t0, 308($sp)
	beqz $t0, _alternative1683
_consequence1682:
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, global_65
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t1, 388($sp)
	lw $t4, 0($t1)
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, global_65
	lw $t1, 220($sp)
	add $t1, $t0, $t1
	sw $t1, 464($sp)
	lw $t1, 464($sp)
	lw $t2, 0($t1)
	lw $t0, global_60
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 452($sp)
	lw $t0, global_68
	lw $t1, 452($sp)
	add $t3, $t0, $t1
	lw $t0, 0($t3)
	sw $t0, 448($sp)
	lw $t0, global_61
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, 448($sp)
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	sw $t4, -12($sp)
	sw $t2, -8($sp)
	sw $t3, -4($sp)
	jal _printF
	sw $v0, 416($sp)
	lw $t0, global_63
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 428($sp)
	sw $t0, global_63
	b _OutOfIf1684
_alternative1683:
	b _OutOfIf1684
_OutOfIf1684:
	b _OutOfIf1681
_alternative1680:
	b _OutOfIf1681
_OutOfIf1681:
	b _continueFor1641
_continueFor1641:
	lw $t0, global_61
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 272($sp)
	sw $t0, global_61
	b _ForLoop1640
_OutOfFor1678:
	b _continueFor1639
_continueFor1639:
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, 268($sp)
	sw $t0, global_60
	b _ForLoop1638
_OutOfFor1676:
	la $a0, string_250
	jal func__print
	sw $v0, 340($sp)
	lw $a0, global_63
	jal func__toString
	sw $v0, 460($sp)
	lw $a0, 460($sp)
	jal func__println
	sw $v0, 372($sp)
	li $v0, 0
	b _EndOfFunctionDecl1621
_EndOfFunctionDecl1621:
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
	add $sp, $sp, 468
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_58:
.space 4
.align 2
global_59:
.space 4
.align 2
global_60:
.space 4
.align 2
global_61:
.space 4
.align 2
global_62:
.space 4
.align 2
global_63:
.space 4
.align 2
global_64:
.space 4
.align 2
global_65:
.space 4
.align 2
global_66:
.space 4
.align 2
global_67:
.space 4
.align 2
global_68:
.space 4
.align 2
.word 1
string_130:
.asciiz " "
.align 2
.word 1
string_142:
.asciiz "\n"
.align 2
.word 7
string_250:
.asciiz "Total: "
.align 2
