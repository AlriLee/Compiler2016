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
_BeginOfFunctionDecl38:
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $a0, 172($sp)
	li $v0, 9
	syscall
	sw $v0, 148($sp)
	lw $t0, 196($sp)
	lw $t1, 148($sp)
	sw $t0, 0($t1)
	lw $t0, 148($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	sw $t0, global_30
	li $t0, 0
	sw $t0, global_33
_ForLoop44:
	lw $t0, global_33
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _OutOfFor1
_ForBody0:
	lw $t0, global_33
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, global_30
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $a0, 188($sp)
	li $v0, 9
	syscall
	sw $v0, 136($sp)
	lw $t0, 196($sp)
	lw $t1, 136($sp)
	sw $t0, 0($t1)
	lw $t0, 136($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	sw $t0, 192($sp)
	lw $t0, 192($sp)
	lw $t1, 184($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, global_34
_ForLoop46:
	lw $t0, global_34
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	beqz $t0, _OutOfFor3
_ForBody2:
	lw $t0, global_33
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, global_30
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t1, 132($sp)
	lw $t0, 0($t1)
	sw $t0, 176($sp)
	lw $t0, global_34
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 176($sp)
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	li $t0, 0
	lw $t1, 156($sp)
	sw $t0, 0($t1)
_continueFor47:
	lw $t0, global_34
	sw $t0, 160($sp)
	lw $t0, global_34
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_34
	b _ForLoop46
_OutOfFor3:
	b _continueFor45
_continueFor45:
	lw $t0, global_33
	sw $t0, 140($sp)
	lw $t0, global_33
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_33
	b _ForLoop44
_OutOfFor1:
	b _EndOfFunctionDecl39
_EndOfFunctionDecl39:
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
_search:
	sub $sp, $sp, 1516
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
_BeginOfFunctionDecl40:
	lw $t0, 1508($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 860($sp)
	lw $t0, 860($sp)
	beqz $t0, _logicalFalse8
_logicalTrue7:
	li $t0, 1
	sw $t0, 452($sp)
	b _logicalMerge9
_logicalFalse8:
	lw $t0, 1508($sp)
	li $t1, 0
	slt $t1, $t0, $t1
	sw $t1, 1304($sp)
	lw $t0, 1304($sp)
	sw $t0, 452($sp)
	b _logicalMerge9
_logicalMerge9:
	lw $t0, 452($sp)
	beqz $t0, _logicalFalse11
_logicalTrue10:
	li $t0, 1
	sw $t0, 1036($sp)
	b _logicalMerge12
_logicalFalse11:
	lw $t0, 1504($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 904($sp)
	lw $t0, 904($sp)
	sw $t0, 1036($sp)
	b _logicalMerge12
_logicalMerge12:
	lw $t0, 1036($sp)
	beqz $t0, _logicalFalse14
_logicalTrue13:
	li $t0, 1
	sw $t0, 1496($sp)
	b _logicalMerge15
_logicalFalse14:
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 368($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, global_30
	lw $t1, 248($sp)
	add $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t1, 424($sp)
	lw $t0, 0($t1)
	sw $t0, 1364($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 932($sp)
	lw $t0, 1364($sp)
	lw $t1, 932($sp)
	add $t1, $t0, $t1
	sw $t1, 1452($sp)
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 592($sp)
	lw $t0, 592($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 540($sp)
	lw $t0, global_30
	lw $t1, 540($sp)
	add $t1, $t0, $t1
	sw $t1, 1028($sp)
	lw $t1, 1028($sp)
	lw $t0, 0($t1)
	sw $t0, 468($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 548($sp)
	lw $t0, 468($sp)
	lw $t1, 548($sp)
	add $t1, $t0, $t1
	sw $t1, 1280($sp)
	lw $t1, 1452($sp)
	lw $t0, 0($t1)
	sw $t0, 360($sp)
	lw $t1, 1280($sp)
	lw $t0, 0($t1)
	sw $t0, 252($sp)
	lw $t0, 360($sp)
	lw $t1, 252($sp)
	add $t1, $t0, $t1
	sw $t1, 1216($sp)
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1208($sp)
	lw $t0, 1208($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 920($sp)
	lw $t0, global_30
	lw $t1, 920($sp)
	add $t1, $t0, $t1
	sw $t1, 1008($sp)
	lw $t1, 1008($sp)
	lw $t0, 0($t1)
	sw $t0, 580($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1100($sp)
	lw $t0, 580($sp)
	lw $t1, 1100($sp)
	add $t1, $t0, $t1
	sw $t1, 708($sp)
	lw $t1, 708($sp)
	lw $t0, 0($t1)
	sw $t0, 596($sp)
	lw $t0, 1216($sp)
	lw $t1, 596($sp)
	add $t1, $t0, $t1
	sw $t1, 1408($sp)
	lw $t0, 1408($sp)
	li $t1, 15
	seq $t1, $t0, $t1
	sw $t1, 572($sp)
	lw $t0, 572($sp)
	sw $t0, 1496($sp)
	b _logicalMerge15
_logicalMerge15:
	lw $t0, 1496($sp)
	beqz $t0, _alternative5
_consequence4:
	lw $t0, 1504($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 460($sp)
	lw $t0, 460($sp)
	beqz $t0, _logicalFalse20
_logicalTrue19:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 1412($sp)
	lw $t0, 1412($sp)
	sw $t0, 612($sp)
	b _logicalMerge21
_logicalFalse20:
	li $t0, 0
	sw $t0, 612($sp)
	b _logicalMerge21
_logicalMerge21:
	lw $t0, 612($sp)
	beqz $t0, _alternative17
_consequence16:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, global_30
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 1136($sp)
	lw $t1, 1136($sp)
	lw $t0, 0($t1)
	sw $t0, 584($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1380($sp)
	lw $t0, 584($sp)
	lw $t1, 1380($sp)
	add $t1, $t0, $t1
	sw $t1, 420($sp)
	li $t0, 45
	lw $t1, 1512($sp)
	sub $t1, $t0, $t1
	sw $t1, 1084($sp)
	lw $t0, 1084($sp)
	lw $t1, 420($sp)
	sw $t0, 0($t1)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, global_30
	lw $t1, 216($sp)
	add $t1, $t0, $t1
	sw $t1, 1032($sp)
	lw $t1, 1032($sp)
	lw $t0, 0($t1)
	sw $t0, 968($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, 968($sp)
	lw $t1, 384($sp)
	add $t1, $t0, $t1
	sw $t1, 1176($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 520($sp)
	lw $t0, global_30
	lw $t1, 520($sp)
	add $t1, $t0, $t1
	sw $t1, 532($sp)
	lw $t1, 532($sp)
	lw $t0, 0($t1)
	sw $t0, 1332($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $t0, 1332($sp)
	lw $t1, 1080($sp)
	add $t1, $t0, $t1
	sw $t1, 456($sp)
	lw $t1, 1176($sp)
	lw $t0, 0($t1)
	sw $t0, 516($sp)
	lw $t1, 456($sp)
	lw $t0, 0($t1)
	sw $t0, 1440($sp)
	lw $t0, 516($sp)
	lw $t1, 1440($sp)
	add $t1, $t0, $t1
	sw $t1, 1420($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 848($sp)
	lw $t0, global_30
	lw $t1, 848($sp)
	add $t1, $t0, $t1
	sw $t1, 1480($sp)
	lw $t1, 1480($sp)
	lw $t0, 0($t1)
	sw $t0, 808($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1252($sp)
	lw $t0, 808($sp)
	lw $t1, 1252($sp)
	add $t1, $t0, $t1
	sw $t1, 940($sp)
	lw $t1, 940($sp)
	lw $t0, 0($t1)
	sw $t0, 1104($sp)
	lw $t0, 1420($sp)
	lw $t1, 1104($sp)
	add $t1, $t0, $t1
	sw $t1, 976($sp)
	lw $t0, 976($sp)
	sw $t0, 640($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 668($sp)
	lw $t0, global_30
	lw $t1, 668($sp)
	add $t1, $t0, $t1
	sw $t1, 1048($sp)
	lw $t1, 1048($sp)
	lw $t0, 0($t1)
	sw $t0, 684($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 684($sp)
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 492($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1424($sp)
	lw $t0, global_30
	lw $t1, 1424($sp)
	add $t1, $t0, $t1
	sw $t1, 1388($sp)
	lw $t1, 1388($sp)
	lw $t0, 0($t1)
	sw $t0, 1192($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1140($sp)
	lw $t0, 1192($sp)
	lw $t1, 1140($sp)
	add $t1, $t0, $t1
	sw $t1, 484($sp)
	lw $t1, 492($sp)
	lw $t0, 0($t1)
	sw $t0, 1164($sp)
	lw $t1, 484($sp)
	lw $t0, 0($t1)
	sw $t0, 284($sp)
	lw $t0, 1164($sp)
	lw $t1, 284($sp)
	add $t1, $t0, $t1
	sw $t1, 1316($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1356($sp)
	lw $t0, global_30
	lw $t1, 1356($sp)
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t1, 132($sp)
	lw $t0, 0($t1)
	sw $t0, 300($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 300($sp)
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 1124($sp)
	lw $t1, 1124($sp)
	lw $t0, 0($t1)
	sw $t0, 556($sp)
	lw $t0, 1316($sp)
	lw $t1, 556($sp)
	add $t1, $t0, $t1
	sw $t1, 952($sp)
	lw $t0, 952($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 1284($sp)
	lw $t0, 1284($sp)
	beqz $t0, _logicalFalse26
_logicalTrue25:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 372($sp)
	lw $t0, global_30
	lw $t1, 372($sp)
	add $t1, $t0, $t1
	sw $t1, 1224($sp)
	lw $t1, 1224($sp)
	lw $t0, 0($t1)
	sw $t0, 1360($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 632($sp)
	lw $t0, 1360($sp)
	lw $t1, 632($sp)
	add $t1, $t0, $t1
	sw $t1, 1416($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 504($sp)
	lw $t0, global_30
	lw $t1, 504($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t1, 196($sp)
	lw $t0, 0($t1)
	sw $t0, 332($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1312($sp)
	lw $t0, 332($sp)
	lw $t1, 1312($sp)
	add $t1, $t0, $t1
	sw $t1, 488($sp)
	lw $t1, 1416($sp)
	lw $t0, 0($t1)
	sw $t0, 620($sp)
	lw $t1, 488($sp)
	lw $t0, 0($t1)
	sw $t0, 1144($sp)
	lw $t0, 620($sp)
	lw $t1, 1144($sp)
	add $t1, $t0, $t1
	sw $t1, 1020($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1244($sp)
	lw $t0, global_30
	lw $t1, 1244($sp)
	add $t1, $t0, $t1
	sw $t1, 884($sp)
	lw $t1, 884($sp)
	lw $t0, 0($t1)
	sw $t0, 1368($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 624($sp)
	lw $t0, 1368($sp)
	lw $t1, 624($sp)
	add $t1, $t0, $t1
	sw $t1, 980($sp)
	lw $t1, 980($sp)
	lw $t0, 0($t1)
	sw $t0, 872($sp)
	lw $t0, 1020($sp)
	lw $t1, 872($sp)
	add $t1, $t0, $t1
	sw $t1, 1344($sp)
	lw $t0, 1344($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 840($sp)
	lw $t0, 840($sp)
	sw $t0, 180($sp)
	b _logicalMerge27
_logicalFalse26:
	li $t0, 0
	sw $t0, 180($sp)
	b _logicalMerge27
_logicalMerge27:
	lw $t0, 180($sp)
	beqz $t0, _logicalFalse29
_logicalTrue28:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 636($sp)
	lw $t0, global_30
	lw $t1, 636($sp)
	add $t1, $t0, $t1
	sw $t1, 1376($sp)
	lw $t1, 1376($sp)
	lw $t0, 0($t1)
	sw $t0, 724($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 724($sp)
	lw $t1, 212($sp)
	add $t1, $t0, $t1
	sw $t1, 1264($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1464($sp)
	lw $t0, global_30
	lw $t1, 1464($sp)
	add $t1, $t0, $t1
	sw $t1, 700($sp)
	lw $t1, 700($sp)
	lw $t0, 0($t1)
	sw $t0, 716($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 800($sp)
	lw $t0, 716($sp)
	lw $t1, 800($sp)
	add $t1, $t0, $t1
	sw $t1, 972($sp)
	lw $t1, 1264($sp)
	lw $t0, 0($t1)
	sw $t0, 272($sp)
	lw $t1, 972($sp)
	lw $t0, 0($t1)
	sw $t0, 1120($sp)
	lw $t0, 272($sp)
	lw $t1, 1120($sp)
	add $t1, $t0, $t1
	sw $t1, 688($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1240($sp)
	lw $t0, global_30
	lw $t1, 1240($sp)
	add $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t1, 336($sp)
	lw $t0, 0($t1)
	sw $t0, 896($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 776($sp)
	lw $t0, 896($sp)
	lw $t1, 776($sp)
	add $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t1, 388($sp)
	lw $t0, 0($t1)
	sw $t0, 692($sp)
	lw $t0, 688($sp)
	lw $t1, 692($sp)
	add $t1, $t0, $t1
	sw $t1, 392($sp)
	lw $t0, 392($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 672($sp)
	lw $t0, 672($sp)
	sw $t0, 524($sp)
	b _logicalMerge30
_logicalFalse29:
	li $t0, 0
	sw $t0, 524($sp)
	b _logicalMerge30
_logicalMerge30:
	lw $t0, 524($sp)
	beqz $t0, _logicalFalse32
_logicalTrue31:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1300($sp)
	lw $t0, global_30
	lw $t1, 1300($sp)
	add $t1, $t0, $t1
	sw $t1, 1404($sp)
	lw $t1, 1404($sp)
	lw $t0, 0($t1)
	sw $t0, 728($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 544($sp)
	lw $t0, 728($sp)
	lw $t1, 544($sp)
	add $t1, $t0, $t1
	sw $t1, 376($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, global_30
	lw $t1, 256($sp)
	add $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t1, 304($sp)
	lw $t0, 0($t1)
	sw $t0, 936($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $t0, 936($sp)
	lw $t1, 1200($sp)
	add $t1, $t0, $t1
	sw $t1, 780($sp)
	lw $t1, 376($sp)
	lw $t0, 0($t1)
	sw $t0, 1180($sp)
	lw $t1, 780($sp)
	lw $t0, 0($t1)
	sw $t0, 768($sp)
	lw $t0, 1180($sp)
	lw $t1, 768($sp)
	add $t1, $t0, $t1
	sw $t1, 1108($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 464($sp)
	lw $t0, global_30
	lw $t1, 464($sp)
	add $t1, $t0, $t1
	sw $t1, 804($sp)
	lw $t1, 804($sp)
	lw $t0, 0($t1)
	sw $t0, 588($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 784($sp)
	lw $t0, 588($sp)
	lw $t1, 784($sp)
	add $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t1, 348($sp)
	lw $t0, 0($t1)
	sw $t0, 428($sp)
	lw $t0, 1108($sp)
	lw $t1, 428($sp)
	add $t1, $t0, $t1
	sw $t1, 696($sp)
	lw $t0, 696($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 644($sp)
	lw $t0, 644($sp)
	sw $t0, 408($sp)
	b _logicalMerge33
_logicalFalse32:
	li $t0, 0
	sw $t0, 408($sp)
	b _logicalMerge33
_logicalMerge33:
	lw $t0, 408($sp)
	beqz $t0, _logicalFalse35
_logicalTrue34:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 828($sp)
	lw $t0, global_30
	lw $t1, 828($sp)
	add $t1, $t0, $t1
	sw $t1, 1428($sp)
	lw $t1, 1428($sp)
	lw $t0, 0($t1)
	sw $t0, 412($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1340($sp)
	lw $t0, 412($sp)
	lw $t1, 1340($sp)
	add $t1, $t0, $t1
	sw $t1, 1336($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, global_30
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 1044($sp)
	lw $t1, 1044($sp)
	lw $t0, 0($t1)
	sw $t0, 160($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 160($sp)
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 400($sp)
	lw $t1, 1336($sp)
	lw $t0, 0($t1)
	sw $t0, 1204($sp)
	lw $t1, 400($sp)
	lw $t0, 0($t1)
	sw $t0, 964($sp)
	lw $t0, 1204($sp)
	lw $t1, 964($sp)
	add $t1, $t0, $t1
	sw $t1, 1328($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 680($sp)
	lw $t0, global_30
	lw $t1, 680($sp)
	add $t1, $t0, $t1
	sw $t1, 792($sp)
	lw $t1, 792($sp)
	lw $t0, 0($t1)
	sw $t0, 1092($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 1092($sp)
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 820($sp)
	lw $t1, 820($sp)
	lw $t0, 0($t1)
	sw $t0, 1024($sp)
	lw $t0, 1328($sp)
	lw $t1, 1024($sp)
	add $t1, $t0, $t1
	sw $t1, 788($sp)
	lw $t0, 788($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 712($sp)
	lw $t0, 712($sp)
	sw $t0, 260($sp)
	b _logicalMerge36
_logicalFalse35:
	li $t0, 0
	sw $t0, 260($sp)
	b _logicalMerge36
_logicalMerge36:
	lw $t0, 260($sp)
	beqz $t0, _logicalFalse38
_logicalTrue37:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 988($sp)
	lw $t0, global_30
	lw $t1, 988($sp)
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t1, 200($sp)
	lw $t0, 0($t1)
	sw $t0, 1184($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 740($sp)
	lw $t0, 1184($sp)
	lw $t1, 740($sp)
	add $t1, $t0, $t1
	sw $t1, 1392($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1436($sp)
	lw $t0, global_30
	lw $t1, 1436($sp)
	add $t1, $t0, $t1
	sw $t1, 676($sp)
	lw $t1, 676($sp)
	lw $t0, 0($t1)
	sw $t0, 1288($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1268($sp)
	lw $t0, 1288($sp)
	lw $t1, 1268($sp)
	add $t1, $t0, $t1
	sw $t1, 1320($sp)
	lw $t1, 1392($sp)
	lw $t0, 0($t1)
	sw $t0, 560($sp)
	lw $t1, 1320($sp)
	lw $t0, 0($t1)
	sw $t0, 328($sp)
	lw $t0, 560($sp)
	lw $t1, 328($sp)
	add $t1, $t0, $t1
	sw $t1, 312($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 928($sp)
	lw $t0, global_30
	lw $t1, 928($sp)
	add $t1, $t0, $t1
	sw $t1, 500($sp)
	lw $t1, 500($sp)
	lw $t0, 0($t1)
	sw $t0, 1248($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, 1248($sp)
	lw $t1, 444($sp)
	add $t1, $t0, $t1
	sw $t1, 476($sp)
	lw $t1, 476($sp)
	lw $t0, 0($t1)
	sw $t0, 244($sp)
	lw $t0, 312($sp)
	lw $t1, 244($sp)
	add $t1, $t0, $t1
	sw $t1, 912($sp)
	lw $t0, 912($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	sw $t0, 704($sp)
	b _logicalMerge39
_logicalFalse38:
	li $t0, 0
	sw $t0, 704($sp)
	b _logicalMerge39
_logicalMerge39:
	lw $t0, 704($sp)
	beqz $t0, _logicalFalse41
_logicalTrue40:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1068($sp)
	lw $t0, global_30
	lw $t1, 1068($sp)
	add $t1, $t0, $t1
	sw $t1, 956($sp)
	lw $t1, 956($sp)
	lw $t0, 0($t1)
	sw $t0, 1220($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 832($sp)
	lw $t0, 1220($sp)
	lw $t1, 832($sp)
	add $t1, $t0, $t1
	sw $t1, 1188($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1156($sp)
	lw $t0, global_30
	lw $t1, 1156($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t1, 264($sp)
	lw $t0, 0($t1)
	sw $t0, 1148($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1228($sp)
	lw $t0, 1148($sp)
	lw $t1, 1228($sp)
	add $t1, $t0, $t1
	sw $t1, 720($sp)
	lw $t1, 1188($sp)
	lw $t0, 0($t1)
	sw $t0, 824($sp)
	lw $t1, 720($sp)
	lw $t0, 0($t1)
	sw $t0, 344($sp)
	lw $t0, 824($sp)
	lw $t1, 344($sp)
	add $t1, $t0, $t1
	sw $t1, 1292($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, global_30
	lw $t1, 324($sp)
	add $t1, $t0, $t1
	sw $t1, 880($sp)
	lw $t1, 880($sp)
	lw $t0, 0($t1)
	sw $t0, 472($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1484($sp)
	lw $t0, 472($sp)
	lw $t1, 1484($sp)
	add $t1, $t0, $t1
	sw $t1, 396($sp)
	lw $t1, 396($sp)
	lw $t0, 0($t1)
	sw $t0, 1236($sp)
	lw $t0, 1292($sp)
	lw $t1, 1236($sp)
	add $t1, $t0, $t1
	sw $t1, 868($sp)
	lw $t0, 868($sp)
	lw $t1, 640($sp)
	seq $t1, $t0, $t1
	sw $t1, 1476($sp)
	lw $t0, 1476($sp)
	sw $t0, 1348($sp)
	b _logicalMerge42
_logicalFalse41:
	li $t0, 0
	sw $t0, 1348($sp)
	b _logicalMerge42
_logicalMerge42:
	lw $t0, 1348($sp)
	beqz $t0, _alternative23
_consequence22:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1324($sp)
	lw $t0, global_32
	lw $t1, 1324($sp)
	add $t1, $t0, $t1
	sw $t1, 984($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 772($sp)
	lw $t0, global_32
	lw $t1, 772($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 1064($sp)
	lw $t0, 1064($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 576($sp)
	lw $t0, 576($sp)
	lw $t1, 984($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, 1400($sp)
_ForLoop48:
	lw $t0, 1400($sp)
	li $t1, 2
	sle $t1, $t0, $t1
	sw $t1, 664($sp)
	lw $t0, 664($sp)
	beqz $t0, _OutOfFor44
_ForBody43:
	li $t0, 0
	sw $t0, 232($sp)
_ForLoop50:
	lw $t0, 232($sp)
	li $t1, 2
	sle $t1, $t0, $t1
	sw $t1, 648($sp)
	lw $t0, 648($sp)
	beqz $t0, _OutOfFor46
_ForBody45:
	lw $t0, 1400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 552($sp)
	lw $t0, global_30
	lw $t1, 552($sp)
	add $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t1, 404($sp)
	lw $t0, 0($t1)
	sw $t0, 1296($sp)
	lw $t0, 232($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 564($sp)
	lw $t0, 1296($sp)
	lw $t1, 564($sp)
	add $t1, $t0, $t1
	sw $t1, 992($sp)
	lw $t1, 992($sp)
	lw $t0, 0($t1)
	sw $t0, 1396($sp)
	lw $a0, 1396($sp)
	jal func__toString
	sw $v0, 496($sp)
	lw $a0, 496($sp)
	jal func__print
	sw $v0, 188($sp)
	la $a0, string_255
	jal func__print
	sw $v0, 1168($sp)
_continueFor51:
	lw $t0, 232($sp)
	sw $t0, 1352($sp)
	lw $t0, 232($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 232($sp)
	b _ForLoop50
_OutOfFor46:
	la $a0, string_258
	jal func__print
	sw $v0, 916($sp)
_continueFor49:
	lw $t0, 1400($sp)
	sw $t0, 308($sp)
	lw $t0, 1400($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1400($sp)
	b _ForLoop48
_OutOfFor44:
	la $a0, string_261
	jal func__print
	sw $v0, 432($sp)
	b _OutOfIf24
_alternative23:
	b _OutOfIf24
_OutOfIf24:
	b _OutOfIf18
_alternative17:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	beqz $t0, _alternative48
_consequence47:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1448($sp)
	lw $t0, global_30
	lw $t1, 1448($sp)
	add $t1, $t0, $t1
	sw $t1, 1076($sp)
	lw $t1, 1076($sp)
	lw $t0, 0($t1)
	sw $t0, 280($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1012($sp)
	lw $t0, 280($sp)
	lw $t1, 1012($sp)
	add $t1, $t0, $t1
	sw $t1, 608($sp)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 888($sp)
	lw $t0, global_30
	lw $t1, 888($sp)
	add $t1, $t0, $t1
	sw $t1, 1096($sp)
	lw $t1, 1096($sp)
	lw $t0, 0($t1)
	sw $t0, 276($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1444($sp)
	lw $t0, 276($sp)
	lw $t1, 1444($sp)
	add $t1, $t0, $t1
	sw $t1, 1152($sp)
	lw $t1, 1152($sp)
	lw $t0, 0($t1)
	sw $t0, 836($sp)
	li $t0, 15
	lw $t1, 836($sp)
	sub $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, global_30
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 996($sp)
	lw $t1, 996($sp)
	lw $t0, 0($t1)
	sw $t0, 752($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 760($sp)
	lw $t0, 752($sp)
	lw $t1, 760($sp)
	add $t1, $t0, $t1
	sw $t1, 528($sp)
	lw $t1, 528($sp)
	lw $t0, 0($t1)
	sw $t0, 764($sp)
	lw $t0, 316($sp)
	lw $t1, 764($sp)
	sub $t1, $t0, $t1
	sw $t1, 1072($sp)
	lw $t0, 1072($sp)
	lw $t1, 608($sp)
	sw $t0, 0($t1)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, global_30
	lw $t1, 268($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t1, 208($sp)
	lw $t0, 0($t1)
	sw $t0, 1000($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1308($sp)
	lw $t0, 1000($sp)
	lw $t1, 1308($sp)
	add $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t1, 364($sp)
	lw $t0, 0($t1)
	sw $t0, 744($sp)
	lw $t0, 744($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 852($sp)
	lw $t0, 852($sp)
	beqz $t0, _logicalFalse54
_logicalTrue53:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 924($sp)
	lw $t0, global_30
	lw $t1, 924($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t1, 136($sp)
	lw $t0, 0($t1)
	sw $t0, 856($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1468($sp)
	lw $t0, 856($sp)
	lw $t1, 1468($sp)
	add $t1, $t0, $t1
	sw $t1, 796($sp)
	lw $t1, 796($sp)
	lw $t0, 0($t1)
	sw $t0, 1456($sp)
	lw $t0, 1456($sp)
	li $t1, 10
	slt $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t0, 320($sp)
	sw $t0, 228($sp)
	b _logicalMerge55
_logicalFalse54:
	li $t0, 0
	sw $t0, 228($sp)
	b _logicalMerge55
_logicalMerge55:
	lw $t0, 228($sp)
	beqz $t0, _logicalFalse57
_logicalTrue56:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 844($sp)
	lw $t0, global_30
	lw $t1, 844($sp)
	add $t1, $t0, $t1
	sw $t1, 352($sp)
	lw $t1, 352($sp)
	lw $t0, 0($t1)
	sw $t0, 568($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 536($sp)
	lw $t0, 568($sp)
	lw $t1, 536($sp)
	add $t1, $t0, $t1
	sw $t1, 944($sp)
	lw $t1, 944($sp)
	lw $t0, 0($t1)
	sw $t0, 1232($sp)
	lw $t0, 1232($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1052($sp)
	lw $t0, global_31
	lw $t1, 1052($sp)
	add $t1, $t0, $t1
	sw $t1, 864($sp)
	lw $t1, 864($sp)
	lw $t0, 0($t1)
	sw $t0, 1488($sp)
	lw $t0, 1488($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 192($sp)
	sw $t0, 1276($sp)
	b _logicalMerge58
_logicalFalse57:
	li $t0, 0
	sw $t0, 1276($sp)
	b _logicalMerge58
_logicalMerge58:
	lw $t0, 1276($sp)
	beqz $t0, _alternative51
_consequence50:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1500($sp)
	lw $t0, global_30
	lw $t1, 1500($sp)
	add $t1, $t0, $t1
	sw $t1, 908($sp)
	lw $t1, 908($sp)
	lw $t0, 0($t1)
	sw $t0, 144($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 416($sp)
	lw $t0, 144($sp)
	lw $t1, 416($sp)
	add $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t1, 448($sp)
	lw $t0, 0($t1)
	sw $t0, 892($sp)
	lw $t0, 892($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 876($sp)
	lw $t0, global_31
	lw $t1, 876($sp)
	add $t1, $t0, $t1
	sw $t1, 1112($sp)
	li $t0, 1
	lw $t1, 1112($sp)
	sw $t0, 0($t1)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, 356($sp)
	beqz $t0, _alternative60
_consequence59:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 948($sp)
	lw $t0, global_30
	lw $t1, 948($sp)
	add $t1, $t0, $t1
	sw $t1, 340($sp)
	lw $t1, 340($sp)
	lw $t0, 0($t1)
	sw $t0, 1272($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 1272($sp)
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 660($sp)
	lw $t1, 660($sp)
	lw $t0, 0($t1)
	sw $t0, 736($sp)
	lw $t0, 1512($sp)
	lw $t1, 736($sp)
	add $t1, $t0, $t1
	sw $t1, 960($sp)
	lw $t0, 220($sp)
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	lw $t0, 960($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 296($sp)
	b _OutOfIf61
_alternative60:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1060($sp)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, global_30
	lw $t1, 236($sp)
	add $t1, $t0, $t1
	sw $t1, 512($sp)
	lw $t1, 512($sp)
	lw $t0, 0($t1)
	sw $t0, 1432($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1116($sp)
	lw $t0, 1432($sp)
	lw $t1, 1116($sp)
	add $t1, $t0, $t1
	sw $t1, 292($sp)
	lw $t1, 292($sp)
	lw $t0, 0($t1)
	sw $t0, 436($sp)
	lw $t0, 1512($sp)
	lw $t1, 436($sp)
	add $t1, $t0, $t1
	sw $t1, 1160($sp)
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1160($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 156($sp)
	b _OutOfIf61
_OutOfIf61:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1128($sp)
	lw $t0, global_30
	lw $t1, 1128($sp)
	add $t1, $t0, $t1
	sw $t1, 748($sp)
	lw $t1, 748($sp)
	lw $t0, 0($t1)
	sw $t0, 1016($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1172($sp)
	lw $t0, 1016($sp)
	lw $t1, 1172($sp)
	add $t1, $t0, $t1
	sw $t1, 1256($sp)
	lw $t1, 1256($sp)
	lw $t0, 0($t1)
	sw $t0, 732($sp)
	lw $t0, 732($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1384($sp)
	lw $t0, global_31
	lw $t1, 1384($sp)
	add $t1, $t0, $t1
	sw $t1, 1088($sp)
	li $t0, 0
	lw $t1, 1088($sp)
	sw $t0, 0($t1)
	b _OutOfIf52
_alternative51:
	b _OutOfIf52
_OutOfIf52:
	b _OutOfIf49
_alternative48:
	li $t0, 1
	sw $t0, 1400($sp)
_ForLoop52:
	lw $t0, 1400($sp)
	li $t1, 9
	sle $t1, $t0, $t1
	sw $t1, 480($sp)
	lw $t0, 480($sp)
	beqz $t0, _OutOfFor63
_ForBody62:
	lw $t0, 1400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1132($sp)
	lw $t0, global_31
	lw $t1, 1132($sp)
	add $t1, $t0, $t1
	sw $t1, 1212($sp)
	lw $t1, 1212($sp)
	lw $t0, 0($t1)
	sw $t0, 616($sp)
	lw $t0, 616($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 1472($sp)
	lw $t0, 1472($sp)
	beqz $t0, _alternative65
_consequence64:
	lw $t0, 1400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 508($sp)
	lw $t0, global_31
	lw $t1, 508($sp)
	add $t1, $t0, $t1
	sw $t1, 1460($sp)
	li $t0, 1
	lw $t1, 1460($sp)
	sw $t0, 0($t1)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1260($sp)
	lw $t0, global_30
	lw $t1, 1260($sp)
	add $t1, $t0, $t1
	sw $t1, 756($sp)
	lw $t1, 756($sp)
	lw $t0, 0($t1)
	sw $t0, 148($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1372($sp)
	lw $t0, 148($sp)
	lw $t1, 1372($sp)
	add $t1, $t0, $t1
	sw $t1, 1196($sp)
	lw $t0, 1400($sp)
	lw $t1, 1196($sp)
	sw $t0, 0($t1)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 812($sp)
	lw $t0, 812($sp)
	beqz $t0, _alternative68
_consequence67:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1492($sp)
	lw $t0, 1512($sp)
	lw $t1, 1400($sp)
	add $t1, $t0, $t1
	sw $t1, 440($sp)
	lw $t0, 1492($sp)
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 1040($sp)
	b _OutOfIf69
_alternative68:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 1512($sp)
	lw $t1, 1400($sp)
	add $t1, $t0, $t1
	sw $t1, 600($sp)
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	lw $t0, 380($sp)
	sw $t0, -8($sp)
	lw $t0, 600($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 900($sp)
	b _OutOfIf69
_OutOfIf69:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 652($sp)
	lw $t0, global_30
	lw $t1, 652($sp)
	add $t1, $t0, $t1
	sw $t1, 604($sp)
	lw $t1, 604($sp)
	lw $t0, 0($t1)
	sw $t0, 1004($sp)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 628($sp)
	lw $t0, 1004($sp)
	lw $t1, 628($sp)
	add $t1, $t0, $t1
	sw $t1, 656($sp)
	li $t0, 0
	lw $t1, 656($sp)
	sw $t0, 0($t1)
	lw $t0, 1400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1056($sp)
	lw $t0, global_31
	lw $t1, 1056($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	li $t0, 0
	lw $t1, 224($sp)
	sw $t0, 0($t1)
	b _OutOfIf66
_alternative65:
	b _OutOfIf66
_OutOfIf66:
	b _continueFor53
_continueFor53:
	lw $t0, 1400($sp)
	sw $t0, 816($sp)
	lw $t0, 1400($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1400($sp)
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
	add $sp, $sp, 1516
	jr $ra
main:
	sub $sp, $sp, 180
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
_BeginOfFunctionDecl42:
	li $t0, 10
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
	sw $v0, 152($sp)
	li $t0, 10
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 176($sp)
	lw $t0, 176($sp)
	sw $t0, global_31
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $a0, 172($sp)
	li $v0, 9
	syscall
	sw $v0, 132($sp)
	li $t0, 1
	lw $t1, 132($sp)
	sw $t0, 0($t1)
	lw $t0, 132($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	sw $t0, 136($sp)
	lw $t0, 136($sp)
	sw $t0, global_32
	li $t0, 3
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 156($sp)
	li $t0, 0
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	sw $v0, 144($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, global_32
	lw $t1, 160($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t1, 128($sp)
	lw $t0, 0($t1)
	sw $t0, 140($sp)
	lw $a0, 140($sp)
	jal func__toString
	sw $v0, 148($sp)
	lw $a0, 148($sp)
	jal func__println
	sw $v0, 164($sp)
	li $v0, 0
	b _EndOfFunctionDecl43
_EndOfFunctionDecl43:
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
