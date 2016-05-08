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
#	%BeginOfFunctionDecl38
_BeginOfFunctionDecl38:
#	$3 = mul $35 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$3 = add $3 4
	li $t1, 4
	add $t2, $t2, $t1
#	$2 = alloc $3
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $2 $35 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$2 = add $2 4
	li $t1, 4
	add $t2, $t2, $t1
#	$1 = move $2
#	$30 = move $1
	sw $t2, global_30
#	$33 = move 0
	li $t0, 0
	sw $t0, global_33
#	%ForLoop44
_ForLoop44:
#	$5 = slt $33 $35
	lw $t0, global_33
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $5 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$7 = mul $33 4
	lw $t0, global_33
	li $t1, 4
	mul $t2, $t0, $t1
#	$8 = add $30 $7
	lw $t0, global_30
	add $t2, $t0, $t2
#	$11 = mul $35 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$11 = add $11 4
	li $t1, 4
	add $t3, $t3, $t1
#	$10 = alloc $11
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $10 $35 0
	lw $t0, 196($sp)
	sw $t0, 0($t3)
#	$10 = add $10 4
	li $t1, 4
	add $t3, $t3, $t1
#	$9 = move $10
	sw $t3, 168($sp)
#	store 4 $8 $9 0
	lw $t0, 168($sp)
	sw $t0, 0($t2)
#	$34 = move 0
	li $t0, 0
	sw $t0, global_34
#	%ForLoop46
_ForLoop46:
#	$13 = slt $34 $35
	lw $t0, global_34
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $13 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$15 = mul $33 4
	lw $t0, global_33
	li $t1, 4
	mul $t2, $t0, $t1
#	$16 = add $30 $15
	lw $t0, global_30
	add $t2, $t0, $t2
#	$17 = load 4 $16 0
	lw $t2, 0($t2)
#	$18 = mul $34 4
	lw $t0, global_34
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
#	$19 = add $17 $18
	lw $t1, 180($sp)
	add $t2, $t2, $t1
#	store 4 $19 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor47
_continueFor47:
#	$20 = move $34
	lw $t0, global_34
	move $t2, $t0
#	$34 = add $34 1
	lw $t0, global_34
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_34
#	jump %ForLoop46
	b _ForLoop46
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor45
	b _continueFor45
#	%continueFor45
_continueFor45:
#	$21 = move $33
	lw $t0, global_33
	move $t2, $t0
#	$33 = add $33 1
	lw $t0, global_33
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_33
#	jump %ForLoop44
	b _ForLoop44
#	%OutOfFor1
_OutOfFor1:
#	jump %EndOfFunctionDecl39
	b _EndOfFunctionDecl39
#	%EndOfFunctionDecl39
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
#	%BeginOfFunctionDecl40
_BeginOfFunctionDecl40:
#	$25 = sgt $37 0
	lw $t0, 1508($sp)
	li $t1, 0
	sgt $t2, $t0, $t1
#	br $25 %logicalTrue7 %logicalFalse8
	beqz $t2, _logicalFalse8
#	%logicalTrue7
_logicalTrue7:
#	$24 = move 1
	li $t0, 1
	move $t6, $t0
#	jump %logicalMerge9
	b _logicalMerge9
#	%logicalFalse8
_logicalFalse8:
#	$26 = slt $37 0
	lw $t0, 1508($sp)
	li $t1, 0
	slt $t2, $t0, $t1
#	$24 = move $26
	move $t6, $t2
#	jump %logicalMerge9
	b _logicalMerge9
#	%logicalMerge9
_logicalMerge9:
#	br $24 %logicalTrue10 %logicalFalse11
	beqz $t6, _logicalFalse11
#	%logicalTrue10
_logicalTrue10:
#	$23 = move 1
	li $t0, 1
	move $t7, $t0
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalFalse11
_logicalFalse11:
#	$27 = seq $36 0
	lw $t0, 1504($sp)
	li $t1, 0
	seq $t2, $t0, $t1
#	$23 = move $27
	move $t7, $t2
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalMerge12
_logicalMerge12:
#	br $23 %logicalTrue13 %logicalFalse14
	beqz $t7, _logicalFalse14
#	%logicalTrue13
_logicalTrue13:
#	$22 = move 1
	li $t0, 1
	move $s0, $t0
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalFalse14
_logicalFalse14:
#	$31 = sub $36 1
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t2, $t0, $t1
#	$32 = mul $31 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$33 = add $30 $32
	lw $t0, global_30
	add $t2, $t0, $t2
#	$34 = load 4 $33 0
	lw $t2, 0($t2)
#	$35 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$36 = add $34 $35
	add $t2, $t2, $t3
#	$37 = sub $36 1
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
#	$38 = mul $37 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$39 = add $30 $38
	lw $t0, global_30
	add $t3, $t0, $t3
#	$40 = load 4 $39 0
	lw $t4, 0($t3)
#	$41 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$42 = add $40 $41
	add $t3, $t4, $t3
#	$43 = load 4 $36 0
	lw $t2, 0($t2)
#	$44 = load 4 $42 0
	lw $t3, 0($t3)
#	$30 = add $43 $44
	add $t2, $t2, $t3
#	$45 = sub $36 1
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
#	$46 = mul $45 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$47 = add $30 $46
	lw $t0, global_30
	add $t3, $t0, $t3
#	$48 = load 4 $47 0
	lw $t4, 0($t3)
#	$49 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
#	$50 = add $48 $49
	add $t3, $t4, $t3
#	$51 = load 4 $50 0
	lw $t3, 0($t3)
#	$29 = add $30 $51
	add $t2, $t2, $t3
#	$28 = seq $29 15
	li $t1, 15
	seq $t2, $t2, $t1
#	$22 = move $28
	move $s0, $t2
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalMerge15
_logicalMerge15:
#	br $22 %consequence4 %alternative5
	beqz $s0, _alternative5
#	%consequence4
_consequence4:
#	$53 = seq $36 2
	lw $t0, 1504($sp)
	li $t1, 2
	seq $t2, $t0, $t1
#	br $53 %logicalTrue19 %logicalFalse20
	beqz $t2, _logicalFalse20
#	%logicalTrue19
_logicalTrue19:
#	$54 = seq $37 2
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
#	$52 = move $54
	move $s1, $t2
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalFalse20
_logicalFalse20:
#	$52 = move 0
	li $t0, 0
	move $s1, $t0
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalMerge21
_logicalMerge21:
#	br $52 %consequence16 %alternative17
	beqz $s1, _alternative17
#	%consequence16
_consequence16:
#	$56 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$57 = add $30 $56
	lw $t0, global_30
	add $t2, $t0, $t2
#	$58 = load 4 $57 0
	lw $t3, 0($t2)
#	$59 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$60 = add $58 $59
	add $t3, $t3, $t2
#	$61 = sub 45 $38
	li $t0, 45
	lw $t1, 1512($sp)
	sub $t2, $t0, $t1
#	store 4 $60 $61 0
	sw $t2, 0($t3)
#	$65 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$66 = add $30 $65
	lw $t0, global_30
	add $t2, $t0, $t2
#	$67 = load 4 $66 0
	lw $t3, 0($t2)
#	$68 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$69 = add $67 $68
	add $t3, $t3, $t2
#	$70 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$71 = add $30 $70
	lw $t0, global_30
	add $t2, $t0, $t2
#	$72 = load 4 $71 0
	lw $t4, 0($t2)
#	$73 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$74 = add $72 $73
	add $t2, $t4, $t2
#	$75 = load 4 $69 0
	lw $t3, 0($t3)
#	$76 = load 4 $74 0
	lw $t2, 0($t2)
#	$64 = add $75 $76
	add $t2, $t3, $t2
#	$77 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$78 = add $30 $77
	lw $t0, global_30
	add $t3, $t0, $t3
#	$79 = load 4 $78 0
	lw $t3, 0($t3)
#	$80 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t4, $t0, $t1
#	$81 = add $79 $80
	add $t3, $t3, $t4
#	$82 = load 4 $81 0
	lw $t3, 0($t3)
#	$63 = add $64 $82
	add $t2, $t2, $t3
#	$39 = move $63
	move $s2, $t2
#	$92 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$93 = add $30 $92
	lw $t0, global_30
	add $t2, $t0, $t2
#	$94 = load 4 $93 0
	lw $t2, 0($t2)
#	$95 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$96 = add $94 $95
	add $t2, $t2, $t3
#	$97 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$98 = add $30 $97
	lw $t0, global_30
	add $t3, $t0, $t3
#	$99 = load 4 $98 0
	lw $t4, 0($t3)
#	$100 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$101 = add $99 $100
	add $t4, $t4, $t3
#	$102 = load 4 $96 0
	lw $t3, 0($t2)
#	$103 = load 4 $101 0
	lw $t2, 0($t4)
#	$91 = add $102 $103
	add $t3, $t3, $t2
#	$104 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$105 = add $30 $104
	lw $t0, global_30
	add $t2, $t0, $t2
#	$106 = load 4 $105 0
	lw $t2, 0($t2)
#	$107 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t4, $t0, $t1
#	$108 = add $106 $107
	add $t2, $t2, $t4
#	$109 = load 4 $108 0
	lw $t2, 0($t2)
#	$90 = add $91 $109
	add $t2, $t3, $t2
#	$89 = seq $90 $39
	seq $t2, $t2, $s2
#	br $89 %logicalTrue25 %logicalFalse26
	beqz $t2, _logicalFalse26
#	%logicalTrue25
_logicalTrue25:
#	$113 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$114 = add $30 $113
	lw $t0, global_30
	add $t2, $t0, $t2
#	$115 = load 4 $114 0
	lw $t2, 0($t2)
#	$116 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$117 = add $115 $116
	add $t4, $t2, $t3
#	$118 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$119 = add $30 $118
	lw $t0, global_30
	add $t2, $t0, $t2
#	$120 = load 4 $119 0
	lw $t3, 0($t2)
#	$121 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$122 = add $120 $121
	add $t3, $t3, $t2
#	$123 = load 4 $117 0
	lw $t2, 0($t4)
#	$124 = load 4 $122 0
	lw $t3, 0($t3)
#	$112 = add $123 $124
	add $t3, $t2, $t3
#	$125 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$126 = add $30 $125
	lw $t0, global_30
	add $t2, $t0, $t2
#	$127 = load 4 $126 0
	lw $t4, 0($t2)
#	$128 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$129 = add $127 $128
	add $t2, $t4, $t2
#	$130 = load 4 $129 0
	lw $t2, 0($t2)
#	$111 = add $112 $130
	add $t2, $t3, $t2
#	$110 = seq $111 $39
	seq $t2, $t2, $s2
#	$88 = move $110
	move $s3, $t2
#	jump %logicalMerge27
	b _logicalMerge27
#	%logicalFalse26
_logicalFalse26:
#	$88 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge27
	b _logicalMerge27
#	%logicalMerge27
_logicalMerge27:
#	br $88 %logicalTrue28 %logicalFalse29
	beqz $s3, _logicalFalse29
#	%logicalTrue28
_logicalTrue28:
#	$134 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$135 = add $30 $134
	lw $t0, global_30
	add $t2, $t0, $t2
#	$136 = load 4 $135 0
	lw $t2, 0($t2)
#	$137 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$138 = add $136 $137
	add $t3, $t2, $t3
#	$139 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$140 = add $30 $139
	lw $t0, global_30
	add $t2, $t0, $t2
#	$141 = load 4 $140 0
	lw $t4, 0($t2)
#	$142 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$143 = add $141 $142
	add $t2, $t4, $t2
#	$144 = load 4 $138 0
	lw $t3, 0($t3)
#	$145 = load 4 $143 0
	lw $t2, 0($t2)
#	$133 = add $144 $145
	add $t3, $t3, $t2
#	$146 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$147 = add $30 $146
	lw $t0, global_30
	add $t2, $t0, $t2
#	$148 = load 4 $147 0
	lw $t2, 0($t2)
#	$149 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
#	$150 = add $148 $149
	add $t2, $t2, $t4
#	$151 = load 4 $150 0
	lw $t2, 0($t2)
#	$132 = add $133 $151
	add $t2, $t3, $t2
#	$131 = seq $132 $39
	seq $t2, $t2, $s2
#	$87 = move $131
	move $s4, $t2
#	jump %logicalMerge30
	b _logicalMerge30
#	%logicalFalse29
_logicalFalse29:
#	$87 = move 0
	li $t0, 0
	move $s4, $t0
#	jump %logicalMerge30
	b _logicalMerge30
#	%logicalMerge30
_logicalMerge30:
#	br $87 %logicalTrue31 %logicalFalse32
	beqz $s4, _logicalFalse32
#	%logicalTrue31
_logicalTrue31:
#	$155 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$156 = add $30 $155
	lw $t0, global_30
	add $t2, $t0, $t2
#	$157 = load 4 $156 0
	lw $t2, 0($t2)
#	$158 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$159 = add $157 $158
	add $t2, $t2, $t3
#	$160 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$161 = add $30 $160
	lw $t0, global_30
	add $t3, $t0, $t3
#	$162 = load 4 $161 0
	lw $t3, 0($t3)
#	$163 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
#	$164 = add $162 $163
	add $t4, $t3, $t4
#	$165 = load 4 $159 0
	lw $t3, 0($t2)
#	$166 = load 4 $164 0
	lw $t2, 0($t4)
#	$154 = add $165 $166
	add $t3, $t3, $t2
#	$167 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$168 = add $30 $167
	lw $t0, global_30
	add $t2, $t0, $t2
#	$169 = load 4 $168 0
	lw $t4, 0($t2)
#	$170 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$171 = add $169 $170
	add $t2, $t4, $t2
#	$172 = load 4 $171 0
	lw $t2, 0($t2)
#	$153 = add $154 $172
	add $t2, $t3, $t2
#	$152 = seq $153 $39
	seq $t2, $t2, $s2
#	$86 = move $152
	move $s5, $t2
#	jump %logicalMerge33
	b _logicalMerge33
#	%logicalFalse32
_logicalFalse32:
#	$86 = move 0
	li $t0, 0
	move $s5, $t0
#	jump %logicalMerge33
	b _logicalMerge33
#	%logicalMerge33
_logicalMerge33:
#	br $86 %logicalTrue34 %logicalFalse35
	beqz $s5, _logicalFalse35
#	%logicalTrue34
_logicalTrue34:
#	$176 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$177 = add $30 $176
	lw $t0, global_30
	add $t2, $t0, $t2
#	$178 = load 4 $177 0
	lw $t3, 0($t2)
#	$179 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$180 = add $178 $179
	add $t4, $t3, $t2
#	$181 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$182 = add $30 $181
	lw $t0, global_30
	add $t2, $t0, $t2
#	$183 = load 4 $182 0
	lw $t3, 0($t2)
#	$184 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$185 = add $183 $184
	add $t3, $t3, $t2
#	$186 = load 4 $180 0
	lw $t2, 0($t4)
#	$187 = load 4 $185 0
	lw $t3, 0($t3)
#	$175 = add $186 $187
	add $t4, $t2, $t3
#	$188 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$189 = add $30 $188
	lw $t0, global_30
	add $t2, $t0, $t2
#	$190 = load 4 $189 0
	lw $t3, 0($t2)
#	$191 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$192 = add $190 $191
	add $t2, $t3, $t2
#	$193 = load 4 $192 0
	lw $t2, 0($t2)
#	$174 = add $175 $193
	add $t2, $t4, $t2
#	$173 = seq $174 $39
	seq $t2, $t2, $s2
#	$85 = move $173
	move $s6, $t2
#	jump %logicalMerge36
	b _logicalMerge36
#	%logicalFalse35
_logicalFalse35:
#	$85 = move 0
	li $t0, 0
	move $s6, $t0
#	jump %logicalMerge36
	b _logicalMerge36
#	%logicalMerge36
_logicalMerge36:
#	br $85 %logicalTrue37 %logicalFalse38
	beqz $s6, _logicalFalse38
#	%logicalTrue37
_logicalTrue37:
#	$197 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$198 = add $30 $197
	lw $t0, global_30
	add $t2, $t0, $t2
#	$199 = load 4 $198 0
	lw $t3, 0($t2)
#	$200 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$201 = add $199 $200
	add $t3, $t3, $t2
#	$202 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$203 = add $30 $202
	lw $t0, global_30
	add $t2, $t0, $t2
#	$204 = load 4 $203 0
	lw $t4, 0($t2)
#	$205 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$206 = add $204 $205
	add $t2, $t4, $t2
#	$207 = load 4 $201 0
	lw $t3, 0($t3)
#	$208 = load 4 $206 0
	lw $t2, 0($t2)
#	$196 = add $207 $208
	add $t4, $t3, $t2
#	$209 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$210 = add $30 $209
	lw $t0, global_30
	add $t2, $t0, $t2
#	$211 = load 4 $210 0
	lw $t2, 0($t2)
#	$212 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
#	$213 = add $211 $212
	add $t2, $t2, $t3
#	$214 = load 4 $213 0
	lw $t2, 0($t2)
#	$195 = add $196 $214
	add $t2, $t4, $t2
#	$194 = seq $195 $39
	seq $t2, $t2, $s2
#	$84 = move $194
	move $s7, $t2
#	jump %logicalMerge39
	b _logicalMerge39
#	%logicalFalse38
_logicalFalse38:
#	$84 = move 0
	li $t0, 0
	move $s7, $t0
#	jump %logicalMerge39
	b _logicalMerge39
#	%logicalMerge39
_logicalMerge39:
#	br $84 %logicalTrue40 %logicalFalse41
	beqz $s7, _logicalFalse41
#	%logicalTrue40
_logicalTrue40:
#	$218 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$219 = add $30 $218
	lw $t0, global_30
	add $t2, $t0, $t2
#	$220 = load 4 $219 0
	lw $t2, 0($t2)
#	$221 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$222 = add $220 $221
	add $t3, $t2, $t3
#	$223 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$224 = add $30 $223
	lw $t0, global_30
	add $t2, $t0, $t2
#	$225 = load 4 $224 0
	lw $t4, 0($t2)
#	$226 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$227 = add $225 $226
	add $t2, $t4, $t2
#	$228 = load 4 $222 0
	lw $t3, 0($t3)
#	$229 = load 4 $227 0
	lw $t2, 0($t2)
#	$217 = add $228 $229
	add $t4, $t3, $t2
#	$230 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$231 = add $30 $230
	lw $t0, global_30
	add $t2, $t0, $t2
#	$232 = load 4 $231 0
	lw $t3, 0($t2)
#	$233 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$234 = add $232 $233
	add $t2, $t3, $t2
#	$235 = load 4 $234 0
	lw $t2, 0($t2)
#	$216 = add $217 $235
	add $t2, $t4, $t2
#	$215 = seq $216 $39
	seq $t2, $t2, $s2
#	$83 = move $215
	move $t8, $t2
#	jump %logicalMerge42
	b _logicalMerge42
#	%logicalFalse41
_logicalFalse41:
#	$83 = move 0
	li $t0, 0
	move $t8, $t0
#	jump %logicalMerge42
	b _logicalMerge42
#	%logicalMerge42
_logicalMerge42:
#	br $83 %consequence22 %alternative23
	beqz $t8, _alternative23
#	%consequence22
_consequence22:
#	$237 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$238 = add $32 $237
	lw $t0, global_32
	add $t3, $t0, $t2
#	$240 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$241 = add $32 $240
	lw $t0, global_32
	add $t2, $t0, $t2
#	$242 = load 4 $241 0
	lw $t2, 0($t2)
#	$239 = add $242 1
	li $t1, 1
	add $t2, $t2, $t1
#	store 4 $238 $239 0
	sw $t2, 0($t3)
#	$40 = move 0
	li $t0, 0
	move $t4, $t0
#	%ForLoop48
_ForLoop48:
#	$244 = sle $40 2
	li $t1, 2
	sle $t2, $t4, $t1
#	br $244 %ForBody43 %OutOfFor44
	beqz $t2, _OutOfFor44
#	%ForBody43
_ForBody43:
#	$41 = move 0
	li $t0, 0
	move $t9, $t0
#	%ForLoop50
_ForLoop50:
#	$246 = sle $41 2
	li $t1, 2
	sle $t2, $t9, $t1
#	br $246 %ForBody45 %OutOfFor46
	beqz $t2, _OutOfFor46
#	%ForBody45
_ForBody45:
#	$247 = mul $40 4
	li $t1, 4
	mul $t2, $t4, $t1
#	$248 = add $30 $247
	lw $t0, global_30
	add $t2, $t0, $t2
#	$249 = load 4 $248 0
	lw $t2, 0($t2)
#	$250 = mul $41 4
	li $t1, 4
	mul $t3, $t9, $t1
#	$251 = add $249 $250
	add $t2, $t2, $t3
#	$252 = load 4 $251 0
	lw $t2, 0($t2)
#	$253 = call toString $252
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall print $253
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	nullcall print " "
	la $a0, string_255
	jal func__print
	move $t2, $v0
#	%continueFor51
_continueFor51:
#	$257 = move $41
	move $t2, $t9
#	$41 = add $41 1
	li $t1, 1
	add $t9, $t9, $t1
#	jump %ForLoop50
	b _ForLoop50
#	%OutOfFor46
_OutOfFor46:
#	nullcall print "\n"
	la $a0, string_258
	jal func__print
	move $t2, $v0
#	%continueFor49
_continueFor49:
#	$260 = move $40
	move $t2, $t4
#	$40 = add $40 1
	li $t1, 1
	add $t4, $t4, $t1
#	jump %ForLoop48
	b _ForLoop48
#	%OutOfFor44
_OutOfFor44:
#	nullcall print "\n"
	la $a0, string_261
	jal func__print
	move $t2, $v0
#	jump %OutOfIf24
	b _OutOfIf24
#	%alternative23
_alternative23:
#	jump %OutOfIf24
	b _OutOfIf24
#	%OutOfIf24
_OutOfIf24:
#	jump %OutOfIf18
	b _OutOfIf18
#	%alternative17
_alternative17:
#	$263 = seq $37 2
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
#	br $263 %consequence47 %alternative48
	beqz $t2, _alternative48
#	%consequence47
_consequence47:
#	$265 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$266 = add $30 $265
	lw $t0, global_30
	add $t2, $t0, $t2
#	$267 = load 4 $266 0
	lw $t2, 0($t2)
#	$268 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$269 = add $267 $268
	add $t3, $t2, $t3
#	$272 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$273 = add $30 $272
	lw $t0, global_30
	add $t2, $t0, $t2
#	$274 = load 4 $273 0
	lw $t2, 0($t2)
#	$275 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
#	$276 = add $274 $275
	add $t2, $t2, $t4
#	$277 = load 4 $276 0
	lw $t2, 0($t2)
#	$271 = sub 15 $277
	li $t0, 15
	sub $t5, $t0, $t2
#	$278 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$279 = add $30 $278
	lw $t0, global_30
	add $t2, $t0, $t2
#	$280 = load 4 $279 0
	lw $t4, 0($t2)
#	$281 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$282 = add $280 $281
	add $t2, $t4, $t2
#	$283 = load 4 $282 0
	lw $t2, 0($t2)
#	$270 = sub $271 $283
	sub $t2, $t5, $t2
#	store 4 $269 $270 0
	sw $t2, 0($t3)
#	$287 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$288 = add $30 $287
	lw $t0, global_30
	add $t2, $t0, $t2
#	$289 = load 4 $288 0
	lw $t2, 0($t2)
#	$290 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$291 = add $289 $290
	add $t2, $t2, $t3
#	$292 = load 4 $291 0
	lw $t2, 0($t2)
#	$286 = sgt $292 0
	li $t1, 0
	sgt $t2, $t2, $t1
#	br $286 %logicalTrue53 %logicalFalse54
	beqz $t2, _logicalFalse54
#	%logicalTrue53
_logicalTrue53:
#	$294 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$295 = add $30 $294
	lw $t0, global_30
	add $t2, $t0, $t2
#	$296 = load 4 $295 0
	lw $t2, 0($t2)
#	$297 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$298 = add $296 $297
	add $t2, $t2, $t3
#	$299 = load 4 $298 0
	lw $t2, 0($t2)
#	$293 = slt $299 10
	li $t1, 10
	slt $t2, $t2, $t1
#	$285 = move $293
	move $t5, $t2
#	jump %logicalMerge55
	b _logicalMerge55
#	%logicalFalse54
_logicalFalse54:
#	$285 = move 0
	li $t0, 0
	move $t5, $t0
#	jump %logicalMerge55
	b _logicalMerge55
#	%logicalMerge55
_logicalMerge55:
#	br $285 %logicalTrue56 %logicalFalse57
	beqz $t5, _logicalFalse57
#	%logicalTrue56
_logicalTrue56:
#	$301 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$302 = add $30 $301
	lw $t0, global_30
	add $t2, $t0, $t2
#	$303 = load 4 $302 0
	lw $t2, 0($t2)
#	$304 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$305 = add $303 $304
	add $t2, $t2, $t3
#	$306 = load 4 $305 0
	lw $t2, 0($t2)
#	$307 = mul $306 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$308 = add $31 $307
	lw $t0, global_31
	add $t2, $t0, $t2
#	$309 = load 4 $308 0
	lw $t2, 0($t2)
#	$300 = seq $309 0
	li $t1, 0
	seq $t2, $t2, $t1
#	$284 = move $300
	move $k0, $t2
#	jump %logicalMerge58
	b _logicalMerge58
#	%logicalFalse57
_logicalFalse57:
#	$284 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge58
	b _logicalMerge58
#	%logicalMerge58
_logicalMerge58:
#	br $284 %consequence50 %alternative51
	beqz $k0, _alternative51
#	%consequence50
_consequence50:
#	$311 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$312 = add $30 $311
	lw $t0, global_30
	add $t2, $t0, $t2
#	$313 = load 4 $312 0
	lw $t2, 0($t2)
#	$314 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$315 = add $313 $314
	add $t2, $t2, $t3
#	$316 = load 4 $315 0
	lw $t2, 0($t2)
#	$317 = mul $316 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$318 = add $31 $317
	lw $t0, global_31
	add $t2, $t0, $t2
#	store 4 $318 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$319 = seq $37 2
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
#	br $319 %consequence59 %alternative60
	beqz $t2, _alternative60
#	%consequence59
_consequence59:
#	$320 = add $36 1
	lw $t0, 1504($sp)
	li $t1, 1
	add $t2, $t0, $t1
#	$322 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$323 = add $30 $322
	lw $t0, global_30
	add $t3, $t0, $t3
#	$324 = load 4 $323 0
	lw $t4, 0($t3)
#	$325 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$326 = add $324 $325
	add $t3, $t4, $t3
#	$327 = load 4 $326 0
	lw $t3, 0($t3)
#	$321 = add $38 $327
	lw $t0, 1512($sp)
	add $t3, $t0, $t3
#	$328 = call search $320 0 $321
	sw $t2, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t3, -4($sp)
	jal _search
	move $t2, $v0
#	jump %OutOfIf61
	b _OutOfIf61
#	%alternative60
_alternative60:
#	$329 = add $37 1
	lw $t0, 1508($sp)
	li $t1, 1
	add $t4, $t0, $t1
#	$331 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$332 = add $30 $331
	lw $t0, global_30
	add $t2, $t0, $t2
#	$333 = load 4 $332 0
	lw $t2, 0($t2)
#	$334 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$335 = add $333 $334
	add $t2, $t2, $t3
#	$336 = load 4 $335 0
	lw $t2, 0($t2)
#	$330 = add $38 $336
	lw $t0, 1512($sp)
	add $t2, $t0, $t2
#	$337 = call search $36 $329 $330
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t4, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
#	jump %OutOfIf61
	b _OutOfIf61
#	%OutOfIf61
_OutOfIf61:
#	$339 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$340 = add $30 $339
	lw $t0, global_30
	add $t2, $t0, $t2
#	$341 = load 4 $340 0
	lw $t3, 0($t2)
#	$342 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$343 = add $341 $342
	add $t2, $t3, $t2
#	$344 = load 4 $343 0
	lw $t2, 0($t2)
#	$345 = mul $344 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$346 = add $31 $345
	lw $t0, global_31
	add $t2, $t0, $t2
#	store 4 $346 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	jump %OutOfIf52
	b _OutOfIf52
#	%alternative51
_alternative51:
#	jump %OutOfIf52
	b _OutOfIf52
#	%OutOfIf52
_OutOfIf52:
#	jump %OutOfIf49
	b _OutOfIf49
#	%alternative48
_alternative48:
#	$40 = move 1
	li $t0, 1
	move $t4, $t0
#	%ForLoop52
_ForLoop52:
#	$348 = sle $40 9
	li $t1, 9
	sle $t2, $t4, $t1
#	br $348 %ForBody62 %OutOfFor63
	beqz $t2, _OutOfFor63
#	%ForBody62
_ForBody62:
#	$350 = mul $40 4
	li $t1, 4
	mul $t2, $t4, $t1
#	$351 = add $31 $350
	lw $t0, global_31
	add $t2, $t0, $t2
#	$352 = load 4 $351 0
	lw $t2, 0($t2)
#	$349 = seq $352 0
	li $t1, 0
	seq $t2, $t2, $t1
#	br $349 %consequence64 %alternative65
	beqz $t2, _alternative65
#	%consequence64
_consequence64:
#	$354 = mul $40 4
	li $t1, 4
	mul $t2, $t4, $t1
#	$355 = add $31 $354
	lw $t0, global_31
	add $t2, $t0, $t2
#	store 4 $355 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$357 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$358 = add $30 $357
	lw $t0, global_30
	add $t2, $t0, $t2
#	$359 = load 4 $358 0
	lw $t2, 0($t2)
#	$360 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$361 = add $359 $360
	add $t2, $t2, $t3
#	store 4 $361 $40 0
	sw $t4, 0($t2)
#	$362 = seq $37 2
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
#	br $362 %consequence67 %alternative68
	beqz $t2, _alternative68
#	%consequence67
_consequence67:
#	$363 = add $36 1
	lw $t0, 1504($sp)
	li $t1, 1
	add $t3, $t0, $t1
#	$364 = add $38 $40
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
#	$365 = call search $363 0 $364
	sw $t3, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
#	jump %OutOfIf69
	b _OutOfIf69
#	%alternative68
_alternative68:
#	$366 = add $37 1
	lw $t0, 1508($sp)
	li $t1, 1
	add $t3, $t0, $t1
#	$367 = add $38 $40
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
#	$368 = call search $36 $366 $367
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t3, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
#	jump %OutOfIf69
	b _OutOfIf69
#	%OutOfIf69
_OutOfIf69:
#	$370 = mul $36 4
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$371 = add $30 $370
	lw $t0, global_30
	add $t2, $t0, $t2
#	$372 = load 4 $371 0
	lw $t3, 0($t2)
#	$373 = mul $37 4
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$374 = add $372 $373
	add $t2, $t3, $t2
#	store 4 $374 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$376 = mul $40 4
	li $t1, 4
	mul $t2, $t4, $t1
#	$377 = add $31 $376
	lw $t0, global_31
	add $t2, $t0, $t2
#	store 4 $377 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	jump %OutOfIf66
	b _OutOfIf66
#	%alternative65
_alternative65:
#	jump %OutOfIf66
	b _OutOfIf66
#	%OutOfIf66
_OutOfIf66:
#	jump %continueFor53
	b _continueFor53
#	%continueFor53
_continueFor53:
#	$378 = move $40
	move $t2, $t4
#	$40 = add $40 1
	li $t1, 1
	add $t4, $t4, $t1
#	jump %ForLoop52
	b _ForLoop52
#	%OutOfFor63
_OutOfFor63:
#	jump %OutOfIf49
	b _OutOfIf49
#	%OutOfIf49
_OutOfIf49:
#	jump %OutOfIf18
	b _OutOfIf18
#	%OutOfIf18
_OutOfIf18:
#	jump %OutOfIf6
	b _OutOfIf6
#	%alternative5
_alternative5:
#	jump %OutOfIf6
	b _OutOfIf6
#	%OutOfIf6
_OutOfIf6:
#	jump %EndOfFunctionDecl41
	b _EndOfFunctionDecl41
#	%EndOfFunctionDecl41
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
#	%BeginOfFunctionDecl42
_BeginOfFunctionDecl42:
#	$381 = mul 10 4
	li $t0, 10
	li $t1, 4
	mul $t2, $t0, $t1
#	$381 = add $381 4
	li $t1, 4
	add $t2, $t2, $t1
#	$380 = alloc $381
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $380 10 0
	li $t0, 10
	sw $t0, 0($t2)
#	$380 = add $380 4
	li $t1, 4
	add $t2, $t2, $t1
#	$379 = move $380
#	$31 = move $379
	sw $t2, global_31
#	$384 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$384 = add $384 4
	li $t1, 4
	add $t2, $t2, $t1
#	$383 = alloc $384
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $383 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$383 = add $383 4
	li $t1, 4
	add $t2, $t2, $t1
#	$382 = move $383
#	$32 = move $382
	sw $t2, global_32
#	nullcall origin 3
	li $t0, 3
	sw $t0, -4($sp)
	jal _origin
	move $t2, $v0
#	$386 = call search 0 0 0
	li $t0, 0
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	move $t2, $v0
#	$387 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$388 = add $32 $387
	lw $t0, global_32
	add $t2, $t0, $t2
#	$389 = load 4 $388 0
	lw $t2, 0($t2)
#	$390 = call toString $389
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $390
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl43
	b _EndOfFunctionDecl43
#	%EndOfFunctionDecl43
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
