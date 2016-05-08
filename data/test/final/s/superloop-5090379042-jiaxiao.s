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
main:
	sub $sp, $sp, 540
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
#	%BeginOfFunctionDecl56
_BeginOfFunctionDecl56:
#	$50 = move 99
	li $t0, 99
	sw $t0, global_50
#	$51 = move 100
	li $t0, 100
	sw $t0, global_51
#	$52 = move 101
	li $t0, 101
	sw $t0, global_52
#	$53 = move 102
	li $t0, 102
	sw $t0, global_53
#	$54 = move 0
	li $t0, 0
	sw $t0, global_54
#	$1 = call getInt
	jal func__getInt
	move $t2, $v0
#	$49 = move $1
	sw $t2, global_49
#	$55 = move 1
	li $t0, 1
	move $t4, $t0
#	%ForLoop58
_ForLoop58:
#	$3 = sle $55 $49
	lw $t1, global_49
	sle $t2, $t4, $t1
#	br $3 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$56 = move 1
	li $t0, 1
	move $s5, $t0
#	%ForLoop60
_ForLoop60:
#	$5 = sle $56 $49
	lw $t1, global_49
	sle $t2, $s5, $t1
#	br $5 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$57 = move 1
	li $t0, 1
	move $t3, $t0
#	%ForLoop62
_ForLoop62:
#	$7 = sle $57 $49
	lw $t1, global_49
	sle $t2, $t3, $t1
#	br $7 %ForBody4 %OutOfFor5
	beqz $t2, _OutOfFor5
#	%ForBody4
_ForBody4:
#	$58 = move 1
	li $t0, 1
	move $t5, $t0
#	%ForLoop64
_ForLoop64:
#	$9 = sle $58 $49
	lw $t1, global_49
	sle $t2, $t5, $t1
#	br $9 %ForBody6 %OutOfFor7
	beqz $t2, _OutOfFor7
#	%ForBody6
_ForBody6:
#	$59 = move 1
	li $t0, 1
	move $t6, $t0
#	%ForLoop66
_ForLoop66:
#	$11 = sle $59 $49
	lw $t1, global_49
	sle $t2, $t6, $t1
#	br $11 %ForBody8 %OutOfFor9
	beqz $t2, _OutOfFor9
#	%ForBody8
_ForBody8:
#	$60 = move 1
	li $t0, 1
	move $t7, $t0
#	%ForLoop68
_ForLoop68:
#	$13 = sle $60 $49
	lw $t1, global_49
	sle $t2, $t7, $t1
#	br $13 %ForBody10 %OutOfFor11
	beqz $t2, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$54 = sne $55 $56
	sne $t2, $t4, $s5
#	br $54 %logicalTrue15 %logicalFalse16
	beqz $t2, _logicalFalse16
#	%logicalTrue15
_logicalTrue15:
#	$55 = sne $55 $57
	sne $t2, $t4, $t3
#	$53 = move $55
	move $s0, $t2
#	jump %logicalMerge17
	b _logicalMerge17
#	%logicalFalse16
_logicalFalse16:
#	$53 = move 0
	li $t0, 0
	move $s0, $t0
#	jump %logicalMerge17
	b _logicalMerge17
#	%logicalMerge17
_logicalMerge17:
#	br $53 %logicalTrue18 %logicalFalse19
	beqz $s0, _logicalFalse19
#	%logicalTrue18
_logicalTrue18:
#	$56 = sne $55 $58
	sne $t2, $t4, $t5
#	$52 = move $56
	move $s1, $t2
#	jump %logicalMerge20
	b _logicalMerge20
#	%logicalFalse19
_logicalFalse19:
#	$52 = move 0
	li $t0, 0
	move $s1, $t0
#	jump %logicalMerge20
	b _logicalMerge20
#	%logicalMerge20
_logicalMerge20:
#	br $52 %logicalTrue21 %logicalFalse22
	beqz $s1, _logicalFalse22
#	%logicalTrue21
_logicalTrue21:
#	$57 = sne $55 $59
	sne $t2, $t4, $t6
#	$51 = move $57
	move $s2, $t2
#	jump %logicalMerge23
	b _logicalMerge23
#	%logicalFalse22
_logicalFalse22:
#	$51 = move 0
	li $t0, 0
	move $s2, $t0
#	jump %logicalMerge23
	b _logicalMerge23
#	%logicalMerge23
_logicalMerge23:
#	br $51 %logicalTrue24 %logicalFalse25
	beqz $s2, _logicalFalse25
#	%logicalTrue24
_logicalTrue24:
#	$58 = sne $55 $60
	sne $t2, $t4, $t7
#	$50 = move $58
	move $s3, $t2
#	jump %logicalMerge26
	b _logicalMerge26
#	%logicalFalse25
_logicalFalse25:
#	$50 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge26
	b _logicalMerge26
#	%logicalMerge26
_logicalMerge26:
#	br $50 %logicalTrue27 %logicalFalse28
	beqz $s3, _logicalFalse28
#	%logicalTrue27
_logicalTrue27:
#	$59 = sne $55 $50
	lw $t1, global_50
	sne $t2, $t4, $t1
#	$49 = move $59
	move $s4, $t2
#	jump %logicalMerge29
	b _logicalMerge29
#	%logicalFalse28
_logicalFalse28:
#	$49 = move 0
	li $t0, 0
	move $s4, $t0
#	jump %logicalMerge29
	b _logicalMerge29
#	%logicalMerge29
_logicalMerge29:
#	br $49 %logicalTrue30 %logicalFalse31
	beqz $s4, _logicalFalse31
#	%logicalTrue30
_logicalTrue30:
#	$60 = sne $55 $51
	lw $t1, global_51
	sne $t2, $t4, $t1
#	$48 = move $60
#	jump %logicalMerge32
	b _logicalMerge32
#	%logicalFalse31
_logicalFalse31:
#	$48 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge32
	b _logicalMerge32
#	%logicalMerge32
_logicalMerge32:
#	br $48 %logicalTrue33 %logicalFalse34
	beqz $t2, _logicalFalse34
#	%logicalTrue33
_logicalTrue33:
#	$61 = sne $55 $52
	lw $t1, global_52
	sne $s6, $t4, $t1
#	$47 = move $61
	move $s7, $s6
#	jump %logicalMerge35
	b _logicalMerge35
#	%logicalFalse34
_logicalFalse34:
#	$47 = move 0
	li $t0, 0
	move $s7, $t0
#	jump %logicalMerge35
	b _logicalMerge35
#	%logicalMerge35
_logicalMerge35:
#	br $47 %logicalTrue36 %logicalFalse37
	beqz $s7, _logicalFalse37
#	%logicalTrue36
_logicalTrue36:
#	$62 = sne $55 $53
	lw $t1, global_53
	sne $s6, $t4, $t1
#	$46 = move $62
	move $t8, $s6
#	jump %logicalMerge38
	b _logicalMerge38
#	%logicalFalse37
_logicalFalse37:
#	$46 = move 0
	li $t0, 0
	move $t8, $t0
#	jump %logicalMerge38
	b _logicalMerge38
#	%logicalMerge38
_logicalMerge38:
#	br $46 %logicalTrue39 %logicalFalse40
	beqz $t8, _logicalFalse40
#	%logicalTrue39
_logicalTrue39:
#	$63 = sne $56 $57
	sne $s6, $s5, $t3
#	$45 = move $63
#	jump %logicalMerge41
	b _logicalMerge41
#	%logicalFalse40
_logicalFalse40:
#	$45 = move 0
	li $t0, 0
	move $s6, $t0
#	jump %logicalMerge41
	b _logicalMerge41
#	%logicalMerge41
_logicalMerge41:
#	br $45 %logicalTrue42 %logicalFalse43
	beqz $s6, _logicalFalse43
#	%logicalTrue42
_logicalTrue42:
#	$64 = sne $56 $58
	sne $t9, $s5, $t5
#	$44 = move $64
#	jump %logicalMerge44
	b _logicalMerge44
#	%logicalFalse43
_logicalFalse43:
#	$44 = move 0
	li $t0, 0
	move $t9, $t0
#	jump %logicalMerge44
	b _logicalMerge44
#	%logicalMerge44
_logicalMerge44:
#	br $44 %logicalTrue45 %logicalFalse46
	beqz $t9, _logicalFalse46
#	%logicalTrue45
_logicalTrue45:
#	$65 = sne $56 $59
	sne $k0, $s5, $t6
#	$43 = move $65
	move $k1, $k0
#	jump %logicalMerge47
	b _logicalMerge47
#	%logicalFalse46
_logicalFalse46:
#	$43 = move 0
	li $t0, 0
	move $k1, $t0
#	jump %logicalMerge47
	b _logicalMerge47
#	%logicalMerge47
_logicalMerge47:
#	br $43 %logicalTrue48 %logicalFalse49
	beqz $k1, _logicalFalse49
#	%logicalTrue48
_logicalTrue48:
#	$66 = sne $56 $60
	sne $k0, $s5, $t7
#	$42 = move $66
	move $gp, $k0
#	jump %logicalMerge50
	b _logicalMerge50
#	%logicalFalse49
_logicalFalse49:
#	$42 = move 0
	li $t0, 0
	move $gp, $t0
#	jump %logicalMerge50
	b _logicalMerge50
#	%logicalMerge50
_logicalMerge50:
#	br $42 %logicalTrue51 %logicalFalse52
	beqz $gp, _logicalFalse52
#	%logicalTrue51
_logicalTrue51:
#	$67 = sne $56 $50
	lw $t1, global_50
	sne $k0, $s5, $t1
#	$41 = move $67
	move $fp, $k0
#	jump %logicalMerge53
	b _logicalMerge53
#	%logicalFalse52
_logicalFalse52:
#	$41 = move 0
	li $t0, 0
	move $fp, $t0
#	jump %logicalMerge53
	b _logicalMerge53
#	%logicalMerge53
_logicalMerge53:
#	br $41 %logicalTrue54 %logicalFalse55
	beqz $fp, _logicalFalse55
#	%logicalTrue54
_logicalTrue54:
#	$68 = sne $56 $51
	lw $t1, global_51
	sne $k0, $s5, $t1
#	$40 = move $68
#	jump %logicalMerge56
	b _logicalMerge56
#	%logicalFalse55
_logicalFalse55:
#	$40 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge56
	b _logicalMerge56
#	%logicalMerge56
_logicalMerge56:
#	br $40 %logicalTrue57 %logicalFalse58
	beqz $k0, _logicalFalse58
#	%logicalTrue57
_logicalTrue57:
#	$69 = sne $56 $52
	lw $t1, global_52
	sne $k0, $s5, $t1
#	$39 = move $69
#	jump %logicalMerge59
	b _logicalMerge59
#	%logicalFalse58
_logicalFalse58:
#	$39 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge59
	b _logicalMerge59
#	%logicalMerge59
_logicalMerge59:
#	br $39 %logicalTrue60 %logicalFalse61
	beqz $k0, _logicalFalse61
#	%logicalTrue60
_logicalTrue60:
#	$70 = sne $56 $53
	lw $t1, global_53
	sne $k0, $s5, $t1
#	$38 = move $70
#	jump %logicalMerge62
	b _logicalMerge62
#	%logicalFalse61
_logicalFalse61:
#	$38 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge62
	b _logicalMerge62
#	%logicalMerge62
_logicalMerge62:
#	br $38 %logicalTrue63 %logicalFalse64
	beqz $k0, _logicalFalse64
#	%logicalTrue63
_logicalTrue63:
#	$71 = sne $57 $58
	sne $k0, $t3, $t5
#	$37 = move $71
#	jump %logicalMerge65
	b _logicalMerge65
#	%logicalFalse64
_logicalFalse64:
#	$37 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge65
	b _logicalMerge65
#	%logicalMerge65
_logicalMerge65:
#	br $37 %logicalTrue66 %logicalFalse67
	beqz $k0, _logicalFalse67
#	%logicalTrue66
_logicalTrue66:
#	$72 = sne $57 $59
	sne $k0, $t3, $t6
#	$36 = move $72
#	jump %logicalMerge68
	b _logicalMerge68
#	%logicalFalse67
_logicalFalse67:
#	$36 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge68
	b _logicalMerge68
#	%logicalMerge68
_logicalMerge68:
#	br $36 %logicalTrue69 %logicalFalse70
	beqz $k0, _logicalFalse70
#	%logicalTrue69
_logicalTrue69:
#	$73 = sne $57 $60
	sne $k0, $t3, $t7
#	$35 = move $73
#	jump %logicalMerge71
	b _logicalMerge71
#	%logicalFalse70
_logicalFalse70:
#	$35 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge71
	b _logicalMerge71
#	%logicalMerge71
_logicalMerge71:
#	br $35 %logicalTrue72 %logicalFalse73
	beqz $k0, _logicalFalse73
#	%logicalTrue72
_logicalTrue72:
#	$74 = sne $57 $50
	lw $t1, global_50
	sne $k0, $t3, $t1
#	$34 = move $74
#	jump %logicalMerge74
	b _logicalMerge74
#	%logicalFalse73
_logicalFalse73:
#	$34 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge74
	b _logicalMerge74
#	%logicalMerge74
_logicalMerge74:
#	br $34 %logicalTrue75 %logicalFalse76
	beqz $k0, _logicalFalse76
#	%logicalTrue75
_logicalTrue75:
#	$75 = sne $57 $51
	lw $t1, global_51
	sne $k0, $t3, $t1
#	$33 = move $75
#	jump %logicalMerge77
	b _logicalMerge77
#	%logicalFalse76
_logicalFalse76:
#	$33 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge77
	b _logicalMerge77
#	%logicalMerge77
_logicalMerge77:
#	br $33 %logicalTrue78 %logicalFalse79
	beqz $k0, _logicalFalse79
#	%logicalTrue78
_logicalTrue78:
#	$76 = sne $57 $52
	lw $t1, global_52
	sne $k0, $t3, $t1
#	$32 = move $76
#	jump %logicalMerge80
	b _logicalMerge80
#	%logicalFalse79
_logicalFalse79:
#	$32 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge80
	b _logicalMerge80
#	%logicalMerge80
_logicalMerge80:
#	br $32 %logicalTrue81 %logicalFalse82
	beqz $k0, _logicalFalse82
#	%logicalTrue81
_logicalTrue81:
#	$77 = sne $57 $53
	lw $t1, global_53
	sne $k0, $t3, $t1
#	$31 = move $77
#	jump %logicalMerge83
	b _logicalMerge83
#	%logicalFalse82
_logicalFalse82:
#	$31 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge83
	b _logicalMerge83
#	%logicalMerge83
_logicalMerge83:
#	br $31 %logicalTrue84 %logicalFalse85
	beqz $k0, _logicalFalse85
#	%logicalTrue84
_logicalTrue84:
#	$78 = sne $58 $59
	sne $k0, $t5, $t6
#	$30 = move $78
#	jump %logicalMerge86
	b _logicalMerge86
#	%logicalFalse85
_logicalFalse85:
#	$30 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge86
	b _logicalMerge86
#	%logicalMerge86
_logicalMerge86:
#	br $30 %logicalTrue87 %logicalFalse88
	beqz $k0, _logicalFalse88
#	%logicalTrue87
_logicalTrue87:
#	$79 = sne $58 $60
	sne $k0, $t5, $t7
#	$29 = move $79
#	jump %logicalMerge89
	b _logicalMerge89
#	%logicalFalse88
_logicalFalse88:
#	$29 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge89
	b _logicalMerge89
#	%logicalMerge89
_logicalMerge89:
#	br $29 %logicalTrue90 %logicalFalse91
	beqz $k0, _logicalFalse91
#	%logicalTrue90
_logicalTrue90:
#	$80 = sne $58 $50
	lw $t1, global_50
	sne $k0, $t5, $t1
#	$28 = move $80
#	jump %logicalMerge92
	b _logicalMerge92
#	%logicalFalse91
_logicalFalse91:
#	$28 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge92
	b _logicalMerge92
#	%logicalMerge92
_logicalMerge92:
#	br $28 %logicalTrue93 %logicalFalse94
	beqz $k0, _logicalFalse94
#	%logicalTrue93
_logicalTrue93:
#	$81 = sne $58 $51
	lw $t1, global_51
	sne $k0, $t5, $t1
#	$27 = move $81
#	jump %logicalMerge95
	b _logicalMerge95
#	%logicalFalse94
_logicalFalse94:
#	$27 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge95
	b _logicalMerge95
#	%logicalMerge95
_logicalMerge95:
#	br $27 %logicalTrue96 %logicalFalse97
	beqz $k0, _logicalFalse97
#	%logicalTrue96
_logicalTrue96:
#	$82 = sne $58 $52
	lw $t1, global_52
	sne $k0, $t5, $t1
#	$26 = move $82
#	jump %logicalMerge98
	b _logicalMerge98
#	%logicalFalse97
_logicalFalse97:
#	$26 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge98
	b _logicalMerge98
#	%logicalMerge98
_logicalMerge98:
#	br $26 %logicalTrue99 %logicalFalse100
	beqz $k0, _logicalFalse100
#	%logicalTrue99
_logicalTrue99:
#	$83 = sne $58 $53
	lw $t1, global_53
	sne $k0, $t5, $t1
#	$25 = move $83
#	jump %logicalMerge101
	b _logicalMerge101
#	%logicalFalse100
_logicalFalse100:
#	$25 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge101
	b _logicalMerge101
#	%logicalMerge101
_logicalMerge101:
#	br $25 %logicalTrue102 %logicalFalse103
	beqz $k0, _logicalFalse103
#	%logicalTrue102
_logicalTrue102:
#	$84 = sne $59 $60
	sne $k0, $t6, $t7
#	$24 = move $84
#	jump %logicalMerge104
	b _logicalMerge104
#	%logicalFalse103
_logicalFalse103:
#	$24 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge104
	b _logicalMerge104
#	%logicalMerge104
_logicalMerge104:
#	br $24 %logicalTrue105 %logicalFalse106
	beqz $k0, _logicalFalse106
#	%logicalTrue105
_logicalTrue105:
#	$85 = sne $59 $50
	lw $t1, global_50
	sne $k0, $t6, $t1
#	$23 = move $85
#	jump %logicalMerge107
	b _logicalMerge107
#	%logicalFalse106
_logicalFalse106:
#	$23 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge107
	b _logicalMerge107
#	%logicalMerge107
_logicalMerge107:
#	br $23 %logicalTrue108 %logicalFalse109
	beqz $k0, _logicalFalse109
#	%logicalTrue108
_logicalTrue108:
#	$86 = sne $59 $51
	lw $t1, global_51
	sne $k0, $t6, $t1
#	$22 = move $86
#	jump %logicalMerge110
	b _logicalMerge110
#	%logicalFalse109
_logicalFalse109:
#	$22 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge110
	b _logicalMerge110
#	%logicalMerge110
_logicalMerge110:
#	br $22 %logicalTrue111 %logicalFalse112
	beqz $k0, _logicalFalse112
#	%logicalTrue111
_logicalTrue111:
#	$87 = sne $59 $52
	lw $t1, global_52
	sne $k0, $t6, $t1
#	$21 = move $87
#	jump %logicalMerge113
	b _logicalMerge113
#	%logicalFalse112
_logicalFalse112:
#	$21 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge113
	b _logicalMerge113
#	%logicalMerge113
_logicalMerge113:
#	br $21 %logicalTrue114 %logicalFalse115
	beqz $k0, _logicalFalse115
#	%logicalTrue114
_logicalTrue114:
#	$88 = sne $59 $53
	lw $t1, global_53
	sne $k0, $t6, $t1
#	$20 = move $88
#	jump %logicalMerge116
	b _logicalMerge116
#	%logicalFalse115
_logicalFalse115:
#	$20 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge116
	b _logicalMerge116
#	%logicalMerge116
_logicalMerge116:
#	br $20 %logicalTrue117 %logicalFalse118
	beqz $k0, _logicalFalse118
#	%logicalTrue117
_logicalTrue117:
#	$89 = sne $60 $50
	lw $t1, global_50
	sne $k0, $t7, $t1
#	$19 = move $89
#	jump %logicalMerge119
	b _logicalMerge119
#	%logicalFalse118
_logicalFalse118:
#	$19 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge119
	b _logicalMerge119
#	%logicalMerge119
_logicalMerge119:
#	br $19 %logicalTrue120 %logicalFalse121
	beqz $k0, _logicalFalse121
#	%logicalTrue120
_logicalTrue120:
#	$90 = sne $60 $51
	lw $t1, global_51
	sne $k0, $t7, $t1
#	$18 = move $90
#	jump %logicalMerge122
	b _logicalMerge122
#	%logicalFalse121
_logicalFalse121:
#	$18 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge122
	b _logicalMerge122
#	%logicalMerge122
_logicalMerge122:
#	br $18 %logicalTrue123 %logicalFalse124
	beqz $k0, _logicalFalse124
#	%logicalTrue123
_logicalTrue123:
#	$91 = sne $60 $52
	lw $t1, global_52
	sne $k0, $t7, $t1
#	$17 = move $91
#	jump %logicalMerge125
	b _logicalMerge125
#	%logicalFalse124
_logicalFalse124:
#	$17 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge125
	b _logicalMerge125
#	%logicalMerge125
_logicalMerge125:
#	br $17 %logicalTrue126 %logicalFalse127
	beqz $k0, _logicalFalse127
#	%logicalTrue126
_logicalTrue126:
#	$92 = sne $60 $53
	lw $t1, global_53
	sne $k0, $t7, $t1
#	$16 = move $92
#	jump %logicalMerge128
	b _logicalMerge128
#	%logicalFalse127
_logicalFalse127:
#	$16 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge128
	b _logicalMerge128
#	%logicalMerge128
_logicalMerge128:
#	br $16 %logicalTrue129 %logicalFalse130
	beqz $k0, _logicalFalse130
#	%logicalTrue129
_logicalTrue129:
#	$93 = sne $51 $52
	lw $t0, global_51
	lw $t1, global_52
	sne $k0, $t0, $t1
#	$15 = move $93
#	jump %logicalMerge131
	b _logicalMerge131
#	%logicalFalse130
_logicalFalse130:
#	$15 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge131
	b _logicalMerge131
#	%logicalMerge131
_logicalMerge131:
#	br $15 %logicalTrue132 %logicalFalse133
	beqz $k0, _logicalFalse133
#	%logicalTrue132
_logicalTrue132:
#	$94 = sne $50 $53
	lw $t0, global_50
	lw $t1, global_53
	sne $k0, $t0, $t1
#	$14 = move $94
#	jump %logicalMerge134
	b _logicalMerge134
#	%logicalFalse133
_logicalFalse133:
#	$14 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge134
	b _logicalMerge134
#	%logicalMerge134
_logicalMerge134:
#	br $14 %consequence12 %alternative13
	beqz $k0, _alternative13
#	%consequence12
_consequence12:
#	$95 = move $54
	lw $t0, global_54
	move $k0, $t0
#	$54 = add $54 1
	lw $t0, global_54
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_54
#	jump %OutOfIf14
	b _OutOfIf14
#	%alternative13
_alternative13:
#	jump %OutOfIf14
	b _OutOfIf14
#	%OutOfIf14
_OutOfIf14:
#	jump %continueFor69
	b _continueFor69
#	%continueFor69
_continueFor69:
#	$96 = move $60
	move $k0, $t7
#	$60 = add $60 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop68
	b _ForLoop68
#	%OutOfFor11
_OutOfFor11:
#	jump %continueFor67
	b _continueFor67
#	%continueFor67
_continueFor67:
#	$97 = move $59
	move $k0, $t6
#	$59 = add $59 1
	li $t1, 1
	add $t6, $t6, $t1
#	jump %ForLoop66
	b _ForLoop66
#	%OutOfFor9
_OutOfFor9:
#	jump %continueFor65
	b _continueFor65
#	%continueFor65
_continueFor65:
#	$98 = move $58
	move $k0, $t5
#	$58 = add $58 1
	li $t1, 1
	add $t5, $t5, $t1
#	jump %ForLoop64
	b _ForLoop64
#	%OutOfFor7
_OutOfFor7:
#	jump %continueFor63
	b _continueFor63
#	%continueFor63
_continueFor63:
#	$99 = move $57
	move $k0, $t3
#	$57 = add $57 1
	li $t1, 1
	add $t3, $t3, $t1
#	jump %ForLoop62
	b _ForLoop62
#	%OutOfFor5
_OutOfFor5:
#	jump %continueFor61
	b _continueFor61
#	%continueFor61
_continueFor61:
#	$100 = move $56
	move $k0, $s5
#	$56 = add $56 1
	li $t1, 1
	add $s5, $s5, $t1
#	jump %ForLoop60
	b _ForLoop60
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor59
	b _continueFor59
#	%continueFor59
_continueFor59:
#	$101 = move $55
	move $k0, $t4
#	$55 = add $55 1
	li $t1, 1
	add $t4, $t4, $t1
#	jump %ForLoop58
	b _ForLoop58
#	%OutOfFor1
_OutOfFor1:
#	$102 = call toString $54
	lw $a0, global_54
	jal func__toString
	move $k0, $v0
#	nullcall println $102
	move $a0, $k0
	jal func__println
	move $k0, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl57
	b _EndOfFunctionDecl57
#	%EndOfFunctionDecl57
_EndOfFunctionDecl57:
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
	add $sp, $sp, 540
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_49:
.space 4
.align 2
global_50:
.space 4
.align 2
global_51:
.space 4
.align 2
global_52:
.space 4
.align 2
global_53:
.space 4
.align 2
global_54:
.space 4
.align 2
