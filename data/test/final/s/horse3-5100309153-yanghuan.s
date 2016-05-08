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
#	%BeginOfFunctionDecl177
_BeginOfFunctionDecl177:
#	$449 = move 0
	li $t0, 0
	sw $t0, global_449
#	$458 = move 0
	li $t0, 0
	sw $t0, global_458
#	$5 = mul $466 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$5 = add $5 4
	li $t1, 4
	add $t2, $t2, $t1
#	$4 = alloc $5
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $4 $466 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$4 = add $4 4
	li $t1, 4
	add $t2, $t2, $t1
#	$3 = move $4
#	$463 = move $3
	sw $t2, global_463
#	$464 = move 0
	li $t0, 0
	sw $t0, global_464
#	%ForLoop185
_ForLoop185:
#	$7 = slt $464 $466
	lw $t0, global_464
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $7 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$9 = mul $464 4
	lw $t0, global_464
	li $t1, 4
	mul $t2, $t0, $t1
#	$10 = add $463 $9
	lw $t0, global_463
	add $t1, $t0, $t2
	sw $t1, 184($sp)
#	$13 = mul $466 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$13 = add $13 4
	li $t1, 4
	add $t2, $t2, $t1
#	$12 = alloc $13
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $12 $466 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$12 = add $12 4
	li $t1, 4
	add $t2, $t2, $t1
#	$11 = move $12
#	store 4 $10 $11 0
	lw $t1, 184($sp)
	sw $t2, 0($t1)
#	$465 = move 0
	li $t0, 0
	sw $t0, global_465
#	%ForLoop187
_ForLoop187:
#	$15 = slt $465 $466
	lw $t0, global_465
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $15 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$17 = mul $464 4
	lw $t0, global_464
	li $t1, 4
	mul $t2, $t0, $t1
#	$18 = add $463 $17
	lw $t0, global_463
	add $t2, $t0, $t2
#	$19 = load 4 $18 0
	lw $t0, 0($t2)
	sw $t0, 188($sp)
#	$20 = mul $465 4
	lw $t0, global_465
	li $t1, 4
	mul $t2, $t0, $t1
#	$21 = add $19 $20
	lw $t0, 188($sp)
	add $t2, $t0, $t2
#	store 4 $21 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor188
_continueFor188:
#	$22 = move $465
	lw $t0, global_465
	move $t2, $t0
#	$465 = add $465 1
	lw $t0, global_465
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_465
#	jump %ForLoop187
	b _ForLoop187
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor186
	b _continueFor186
#	%continueFor186
_continueFor186:
#	$23 = move $464
	lw $t0, global_464
	move $t2, $t0
#	$464 = add $464 1
	lw $t0, global_464
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_464
#	jump %ForLoop185
	b _ForLoop185
#	%OutOfFor1
_OutOfFor1:
#	jump %EndOfFunctionDecl178
	b _EndOfFunctionDecl178
#	%EndOfFunctionDecl178
_EndOfFunctionDecl178:
	lw $t2, 40($sp)
	add $sp, $sp, 200
	jr $ra
_check:
	sub $sp, $sp, 144
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl179
_BeginOfFunctionDecl179:
#	$25 = slt $467 $448
	lw $t0, 140($sp)
	lw $t1, global_448
	slt $t2, $t0, $t1
#	br $25 %logicalTrue4 %logicalFalse5
	beqz $t2, _logicalFalse5
#	%logicalTrue4
_logicalTrue4:
#	$26 = sge $467 0
	lw $t0, 140($sp)
	li $t1, 0
	sge $t2, $t0, $t1
#	$24 = move $26
#	jump %logicalMerge6
	b _logicalMerge6
#	%logicalFalse5
_logicalFalse5:
#	$24 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge6
	b _logicalMerge6
#	%logicalMerge6
_logicalMerge6:
#	ret $24
	move $v0, $t2
#	jump %EndOfFunctionDecl180
	b _EndOfFunctionDecl180
#	%EndOfFunctionDecl180
_EndOfFunctionDecl180:
	lw $t2, 40($sp)
	add $sp, $sp, 144
	jr $ra
_addList:
	sub $sp, $sp, 240
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl181
_BeginOfFunctionDecl181:
#	$29 = call check $468
	lw $t0, 232($sp)
	sw $t0, -4($sp)
	jal _check
	move $t2, $v0
#	br $29 %logicalTrue10 %logicalFalse11
	beqz $t2, _logicalFalse11
#	%logicalTrue10
_logicalTrue10:
#	$30 = call check $469
	lw $t0, 236($sp)
	sw $t0, -4($sp)
	jal _check
	move $t2, $v0
#	$28 = move $30
	move $t3, $t2
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalFalse11
_logicalFalse11:
#	$28 = move 0
	li $t0, 0
	move $t3, $t0
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalMerge12
_logicalMerge12:
#	br $28 %logicalTrue13 %logicalFalse14
	beqz $t3, _logicalFalse14
#	%logicalTrue13
_logicalTrue13:
#	$32 = mul $468 4
	lw $t0, 232($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$33 = add $463 $32
	lw $t0, global_463
	add $t2, $t0, $t2
#	$34 = load 4 $33 0
	lw $t2, 0($t2)
#	$35 = mul $469 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$36 = add $34 $35
	add $t2, $t2, $t4
#	$37 = neg 1
	li $t0, 1
	neg $t4, $t0
#	$38 = load 4 $36 0
	lw $t2, 0($t2)
#	$31 = seq $38 $37
	seq $t2, $t2, $t4
#	$27 = move $31
	move $t5, $t2
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalFalse14
_logicalFalse14:
#	$27 = move 0
	li $t0, 0
	move $t5, $t0
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalMerge15
_logicalMerge15:
#	br $27 %consequence7 %alternative8
	beqz $t5, _alternative8
#	%consequence7
_consequence7:
#	$39 = move $458
	lw $t0, global_458
	move $t2, $t0
#	$458 = add $458 1
	lw $t0, global_458
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_458
#	$41 = mul $458 4
	lw $t0, global_458
	li $t1, 4
	mul $t2, $t0, $t1
#	$42 = add $456 $41
	lw $t0, global_456
	add $t2, $t0, $t2
#	store 4 $42 $468 0
	lw $t0, 232($sp)
	sw $t0, 0($t2)
#	$44 = mul $458 4
	lw $t0, global_458
	li $t1, 4
	mul $t2, $t0, $t1
#	$45 = add $457 $44
	lw $t0, global_457
	add $t2, $t0, $t2
#	store 4 $45 $469 0
	lw $t0, 236($sp)
	sw $t0, 0($t2)
#	$47 = mul $468 4
	lw $t0, 232($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$48 = add $463 $47
	lw $t0, global_463
	add $t2, $t0, $t2
#	$49 = load 4 $48 0
	lw $t2, 0($t2)
#	$50 = mul $469 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$51 = add $49 $50
	add $t4, $t2, $t4
#	$52 = add $460 1
	lw $t0, global_460
	li $t1, 1
	add $t2, $t0, $t1
#	store 4 $51 $52 0
	sw $t2, 0($t4)
#	$54 = seq $468 $452
	lw $t0, 232($sp)
	lw $t1, global_452
	seq $t2, $t0, $t1
#	br $54 %logicalTrue19 %logicalFalse20
	beqz $t2, _logicalFalse20
#	%logicalTrue19
_logicalTrue19:
#	$55 = seq $469 $453
	lw $t0, 236($sp)
	lw $t1, global_453
	seq $t2, $t0, $t1
#	$53 = move $55
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalFalse20
_logicalFalse20:
#	$53 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalMerge21
_logicalMerge21:
#	br $53 %consequence16 %alternative17
	beqz $t2, _alternative17
#	%consequence16
_consequence16:
#	$459 = move 1
	li $t0, 1
	sw $t0, global_459
#	jump %OutOfIf18
	b _OutOfIf18
#	%alternative17
_alternative17:
#	jump %OutOfIf18
	b _OutOfIf18
#	%OutOfIf18
_OutOfIf18:
#	jump %OutOfIf9
	b _OutOfIf9
#	%alternative8
_alternative8:
#	jump %OutOfIf9
	b _OutOfIf9
#	%OutOfIf9
_OutOfIf9:
#	jump %EndOfFunctionDecl182
	b _EndOfFunctionDecl182
#	%EndOfFunctionDecl182
_EndOfFunctionDecl182:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 240
	jr $ra
main:
	sub $sp, $sp, 532
	sw $t2, 40($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl183
_BeginOfFunctionDecl183:
#	$59 = mul 12000 4
	li $t0, 12000
	li $t1, 4
	mul $t2, $t0, $t1
#	$59 = add $59 4
	li $t1, 4
	add $t2, $t2, $t1
#	$58 = alloc $59
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $58 12000 0
	li $t0, 12000
	sw $t0, 0($t2)
#	$58 = add $58 4
	li $t1, 4
	add $t2, $t2, $t1
#	$57 = move $58
#	$456 = move $57
	sw $t2, global_456
#	$62 = mul 12000 4
	li $t0, 12000
	li $t1, 4
	mul $t2, $t0, $t1
#	$62 = add $62 4
	li $t1, 4
	add $t2, $t2, $t1
#	$61 = alloc $62
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $61 12000 0
	li $t0, 12000
	sw $t0, 0($t2)
#	$61 = add $61 4
	li $t1, 4
	add $t2, $t2, $t1
#	$60 = move $61
#	$457 = move $60
	sw $t2, global_457
#	$65 = mul 8 4
	li $t0, 8
	li $t1, 4
	mul $t2, $t0, $t1
#	$65 = add $65 4
	li $t1, 4
	add $t2, $t2, $t1
#	$64 = alloc $65
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $64 8 0
	li $t0, 8
	sw $t0, 0($t2)
#	$64 = add $64 4
	li $t1, 4
	add $t2, $t2, $t1
#	$63 = move $64
#	$461 = move $63
	sw $t2, global_461
#	$68 = mul 9 4
	li $t0, 9
	li $t1, 4
	mul $t2, $t0, $t1
#	$68 = add $68 4
	li $t1, 4
	add $t2, $t2, $t1
#	$67 = alloc $68
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $67 9 0
	li $t0, 9
	sw $t0, 0($t2)
#	$67 = add $67 4
	li $t1, 4
	add $t2, $t2, $t1
#	$66 = move $67
#	$462 = move $66
	sw $t2, global_462
#	nullcall origin 106
	li $t0, 106
	sw $t0, -4($sp)
	jal _origin
	move $t2, $v0
#	$71 = call getInt
	jal func__getInt
	move $t2, $v0
#	$448 = move $71
	sw $t2, global_448
#	$74 = sub $448 1
	lw $t0, global_448
	li $t1, 1
	sub $t2, $t0, $t1
#	$453 = move $74
	sw $t2, global_453
#	$452 = move $453
	lw $t0, global_453
	sw $t0, global_452
#	$464 = move 0
	li $t0, 0
	sw $t0, global_464
#	%ForLoop189
_ForLoop189:
#	$76 = slt $464 $448
	lw $t0, global_464
	lw $t1, global_448
	slt $t2, $t0, $t1
#	br $76 %ForBody22 %OutOfFor23
	beqz $t2, _OutOfFor23
#	%ForBody22
_ForBody22:
#	$465 = move 0
	li $t0, 0
	sw $t0, global_465
#	%ForLoop191
_ForLoop191:
#	$78 = slt $465 $448
	lw $t0, global_465
	lw $t1, global_448
	slt $t2, $t0, $t1
#	br $78 %ForBody24 %OutOfFor25
	beqz $t2, _OutOfFor25
#	%ForBody24
_ForBody24:
#	$80 = mul $464 4
	lw $t0, global_464
	li $t1, 4
	mul $t2, $t0, $t1
#	$81 = add $463 $80
	lw $t0, global_463
	add $t2, $t0, $t2
#	$82 = load 4 $81 0
	lw $t2, 0($t2)
#	$83 = mul $465 4
	lw $t0, global_465
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 512($sp)
#	$84 = add $82 $83
	lw $t1, 512($sp)
	add $t1, $t2, $t1
	sw $t1, 428($sp)
#	$85 = neg 1
	li $t0, 1
	neg $t2, $t0
#	store 4 $84 $85 0
	lw $t1, 428($sp)
	sw $t2, 0($t1)
#	%continueFor192
_continueFor192:
#	$86 = move $465
	lw $t0, global_465
	move $t2, $t0
#	$465 = add $465 1
	lw $t0, global_465
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_465
#	jump %ForLoop191
	b _ForLoop191
#	%OutOfFor25
_OutOfFor25:
#	jump %continueFor190
	b _continueFor190
#	%continueFor190
_continueFor190:
#	$87 = move $464
	lw $t0, global_464
	move $t2, $t0
#	$464 = add $464 1
	lw $t0, global_464
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_464
#	jump %ForLoop189
	b _ForLoop189
#	%OutOfFor23
_OutOfFor23:
#	$89 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$90 = add $461 $89
	lw $t0, global_461
	add $t2, $t0, $t2
#	$91 = neg 2
	li $t0, 2
	neg $t1, $t0
	sw $t1, 380($sp)
#	store 4 $90 $91 0
	lw $t0, 380($sp)
	sw $t0, 0($t2)
#	$93 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$94 = add $462 $93
	lw $t0, global_462
	add $t2, $t0, $t2
#	$95 = neg 1
	li $t0, 1
	neg $t1, $t0
	sw $t1, 348($sp)
#	store 4 $94 $95 0
	lw $t0, 348($sp)
	sw $t0, 0($t2)
#	$97 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$98 = add $461 $97
	lw $t0, global_461
	add $t1, $t0, $t2
	sw $t1, 452($sp)
#	$99 = neg 2
	li $t0, 2
	neg $t2, $t0
#	store 4 $98 $99 0
	lw $t1, 452($sp)
	sw $t2, 0($t1)
#	$101 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$102 = add $462 $101
	lw $t0, global_462
	add $t2, $t0, $t2
#	store 4 $102 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$104 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$105 = add $461 $104
	lw $t0, global_461
	add $t2, $t0, $t2
#	store 4 $105 2 0
	li $t0, 2
	sw $t0, 0($t2)
#	$107 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$108 = add $462 $107
	lw $t0, global_462
	add $t1, $t0, $t2
	sw $t1, 440($sp)
#	$109 = neg 1
	li $t0, 1
	neg $t2, $t0
#	store 4 $108 $109 0
	lw $t1, 440($sp)
	sw $t2, 0($t1)
#	$111 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$112 = add $461 $111
	lw $t0, global_461
	add $t2, $t0, $t2
#	store 4 $112 2 0
	li $t0, 2
	sw $t0, 0($t2)
#	$114 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$115 = add $462 $114
	lw $t0, global_462
	add $t2, $t0, $t2
#	store 4 $115 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$117 = mul 4 4
	li $t0, 4
	li $t1, 4
	mul $t2, $t0, $t1
#	$118 = add $461 $117
	lw $t0, global_461
	add $t2, $t0, $t2
#	$119 = neg 1
	li $t0, 1
	neg $t1, $t0
	sw $t1, 468($sp)
#	store 4 $118 $119 0
	lw $t0, 468($sp)
	sw $t0, 0($t2)
#	$121 = mul 4 4
	li $t0, 4
	li $t1, 4
	mul $t2, $t0, $t1
#	$122 = add $462 $121
	lw $t0, global_462
	add $t1, $t0, $t2
	sw $t1, 508($sp)
#	$123 = neg 2
	li $t0, 2
	neg $t2, $t0
#	store 4 $122 $123 0
	lw $t1, 508($sp)
	sw $t2, 0($t1)
#	$125 = mul 5 4
	li $t0, 5
	li $t1, 4
	mul $t2, $t0, $t1
#	$126 = add $461 $125
	lw $t0, global_461
	add $t1, $t0, $t2
	sw $t1, 524($sp)
#	$127 = neg 1
	li $t0, 1
	neg $t2, $t0
#	store 4 $126 $127 0
	lw $t1, 524($sp)
	sw $t2, 0($t1)
#	$129 = mul 5 4
	li $t0, 5
	li $t1, 4
	mul $t2, $t0, $t1
#	$130 = add $462 $129
	lw $t0, global_462
	add $t2, $t0, $t2
#	store 4 $130 2 0
	li $t0, 2
	sw $t0, 0($t2)
#	$132 = mul 6 4
	li $t0, 6
	li $t1, 4
	mul $t2, $t0, $t1
#	$133 = add $461 $132
	lw $t0, global_461
	add $t2, $t0, $t2
#	store 4 $133 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$135 = mul 6 4
	li $t0, 6
	li $t1, 4
	mul $t2, $t0, $t1
#	$136 = add $462 $135
	lw $t0, global_462
	add $t1, $t0, $t2
	sw $t1, 292($sp)
#	$137 = neg 2
	li $t0, 2
	neg $t2, $t0
#	store 4 $136 $137 0
	lw $t1, 292($sp)
	sw $t2, 0($t1)
#	$139 = mul 7 4
	li $t0, 7
	li $t1, 4
	mul $t2, $t0, $t1
#	$140 = add $461 $139
	lw $t0, global_461
	add $t2, $t0, $t2
#	store 4 $140 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$142 = mul 7 4
	li $t0, 7
	li $t1, 4
	mul $t2, $t0, $t1
#	$143 = add $462 $142
	lw $t0, global_462
	add $t2, $t0, $t2
#	store 4 $143 2 0
	li $t0, 2
	sw $t0, 0($t2)
#	%WhileLoop193
_WhileLoop193:
#	$144 = sle $449 $458
	lw $t0, global_449
	lw $t1, global_458
	sle $t2, $t0, $t1
#	br $144 %WhileBody26 %OutOfWhile27
	beqz $t2, _OutOfWhile27
#	%WhileBody26
_WhileBody26:
#	$146 = mul $449 4
	lw $t0, global_449
	li $t1, 4
	mul $t2, $t0, $t1
#	$147 = add $456 $146
	lw $t0, global_456
	add $t2, $t0, $t2
#	$148 = load 4 $147 0
	lw $t2, 0($t2)
#	$454 = move $148
	sw $t2, global_454
#	$150 = mul $449 4
	lw $t0, global_449
	li $t1, 4
	mul $t2, $t0, $t1
#	$151 = add $457 $150
	lw $t0, global_457
	add $t2, $t0, $t2
#	$152 = load 4 $151 0
	lw $t2, 0($t2)
#	$455 = move $152
	sw $t2, global_455
#	$154 = mul $454 4
	lw $t0, global_454
	li $t1, 4
	mul $t2, $t0, $t1
#	$155 = add $463 $154
	lw $t0, global_463
	add $t2, $t0, $t2
#	$156 = load 4 $155 0
	lw $t0, 0($t2)
	sw $t0, 288($sp)
#	$157 = mul $455 4
	lw $t0, global_455
	li $t1, 4
	mul $t2, $t0, $t1
#	$158 = add $156 $157
	lw $t0, 288($sp)
	add $t2, $t0, $t2
#	$159 = load 4 $158 0
	lw $t2, 0($t2)
#	$460 = move $159
	sw $t2, global_460
#	$465 = move 0
	li $t0, 0
	sw $t0, global_465
#	%ForLoop194
_ForLoop194:
#	$161 = slt $465 8
	lw $t0, global_465
	li $t1, 8
	slt $t2, $t0, $t1
#	br $161 %ForBody28 %OutOfFor29
	beqz $t2, _OutOfFor29
#	%ForBody28
_ForBody28:
#	$163 = mul $465 4
	lw $t0, global_465
	li $t1, 4
	mul $t2, $t0, $t1
#	$164 = add $461 $163
	lw $t0, global_461
	add $t2, $t0, $t2
#	$165 = load 4 $164 0
	lw $t2, 0($t2)
#	$162 = add $454 $165
	lw $t0, global_454
	add $t2, $t0, $t2
#	$167 = mul $465 4
	lw $t0, global_465
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 244($sp)
#	$168 = add $462 $167
	lw $t0, global_462
	lw $t1, 244($sp)
	add $t1, $t0, $t1
	sw $t1, 320($sp)
#	$169 = load 4 $168 0
	lw $t1, 320($sp)
	lw $t0, 0($t1)
	sw $t0, 460($sp)
#	$166 = add $455 $169
	lw $t0, global_455
	lw $t1, 460($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
#	nullcall addList $162 $166
	sw $t2, -8($sp)
	lw $t0, 228($sp)
	sw $t0, -4($sp)
	jal _addList
	move $t2, $v0
#	%continueFor195
_continueFor195:
#	$171 = move $465
	lw $t0, global_465
	move $t2, $t0
#	$465 = add $465 1
	lw $t0, global_465
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_465
#	jump %ForLoop194
	b _ForLoop194
#	%OutOfFor29
_OutOfFor29:
#	$172 = seq $459 1
	lw $t0, global_459
	li $t1, 1
	seq $t2, $t0, $t1
#	br $172 %consequence30 %alternative31
	beqz $t2, _alternative31
#	%consequence30
_consequence30:
#	jump %OutOfWhile27
	b _OutOfWhile27
#	jump %OutOfIf32
	b _OutOfIf32
#	%alternative31
_alternative31:
#	jump %OutOfIf32
	b _OutOfIf32
#	%OutOfIf32
_OutOfIf32:
#	$173 = move $449
	lw $t0, global_449
	move $t2, $t0
#	$449 = add $449 1
	lw $t0, global_449
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_449
#	jump %WhileLoop193
	b _WhileLoop193
#	%OutOfWhile27
_OutOfWhile27:
#	$174 = seq $459 1
	lw $t0, global_459
	li $t1, 1
	seq $t2, $t0, $t1
#	br $174 %consequence33 %alternative34
	beqz $t2, _alternative34
#	%consequence33
_consequence33:
#	$175 = mul $452 4
	lw $t0, global_452
	li $t1, 4
	mul $t2, $t0, $t1
#	$176 = add $463 $175
	lw $t0, global_463
	add $t2, $t0, $t2
#	$177 = load 4 $176 0
	lw $t2, 0($t2)
#	$178 = mul $453 4
	lw $t0, global_453
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 296($sp)
#	$179 = add $177 $178
	lw $t1, 296($sp)
	add $t2, $t2, $t1
#	$180 = load 4 $179 0
	lw $t2, 0($t2)
#	$181 = call toString $180
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $181
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	jump %OutOfIf35
	b _OutOfIf35
#	%alternative34
_alternative34:
#	nullcall print "no solution!\n"
	la $a0, string_183
	jal func__print
	move $t2, $v0
#	jump %OutOfIf35
	b _OutOfIf35
#	%OutOfIf35
_OutOfIf35:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl184
	b _EndOfFunctionDecl184
#	%EndOfFunctionDecl184
_EndOfFunctionDecl184:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 532
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_448:
.space 4
.align 2
global_449:
.space 4
.align 2
global_450:
.space 4
.align 2
global_451:
.space 4
.align 2
global_452:
.space 4
.align 2
global_453:
.space 4
.align 2
global_454:
.space 4
.align 2
global_455:
.space 4
.align 2
global_456:
.space 4
.align 2
global_457:
.space 4
.align 2
global_458:
.space 4
.align 2
global_459:
.space 4
.align 2
global_460:
.space 4
.align 2
global_461:
.space 4
.align 2
global_462:
.space 4
.align 2
global_463:
.space 4
.align 2
global_464:
.space 4
.align 2
global_465:
.space 4
.align 2
.word 13
string_183:
.asciiz "no solution!\n"
.align 2
