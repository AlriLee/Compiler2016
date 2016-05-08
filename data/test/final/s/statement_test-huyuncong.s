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
	sub $sp, $sp, 456
	sw $s0, 64($sp)
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl38
_BeginOfFunctionDecl38:
#	$2588 = move 0
	li $t0, 0
	sw $t0, global_2588
#	$1 = call getInt
	jal func__getInt
	move $t2, $v0
#	$2587 = move $1
	sw $t2, global_2587
#	$5 = add $2587 5
	lw $t0, global_2587
	li $t1, 5
	add $t2, $t0, $t1
#	$6 = mul $5 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 332($sp)
#	$6 = add $6 4
	lw $t0, 332($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 332($sp)
#	$4 = alloc $6
	lw $a0, 332($sp)
	li $v0, 9
	syscall
	sw $v0, 344($sp)
#	store 4 $4 $5 0
	lw $t1, 344($sp)
	sw $t2, 0($t1)
#	$4 = add $4 4
	lw $t0, 344($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 344($sp)
#	$3 = move $4
	lw $t0, 344($sp)
	move $t2, $t0
#	$2589 = move $3
	sw $t2, global_2589
#	$2590 = move 0
	li $t0, 0
	sw $t0, 280($sp)
#	%WhileLoop40
_WhileLoop40:
#	$7 = sle $2590 $2587
	lw $t0, 280($sp)
	lw $t1, global_2587
	sle $t2, $t0, $t1
#	br $7 %WhileBody0 %OutOfWhile1
	beqz $t2, _OutOfWhile1
#	%WhileBody0
_WhileBody0:
#	$9 = move $2590
	lw $t0, 280($sp)
	move $t2, $t0
#	$2590 = add $2590 1
	lw $t0, 280($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 280($sp)
#	$10 = mul $9 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$11 = add $2589 $10
	lw $t0, global_2589
	add $t2, $t0, $t2
#	store 4 $11 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	jump %WhileLoop40
	b _WhileLoop40
#	%OutOfWhile1
_OutOfWhile1:
#	$14 = add $2587 5
	lw $t0, global_2587
	li $t1, 5
	add $t2, $t0, $t1
#	$15 = mul $14 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$15 = add $15 4
	li $t1, 4
	add $t3, $t3, $t1
#	$13 = alloc $15
	move $a0, $t3
	li $v0, 9
	syscall
	sw $v0, 444($sp)
#	store 4 $13 $14 0
	lw $t1, 444($sp)
	sw $t2, 0($t1)
#	$13 = add $13 4
	lw $t0, 444($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 444($sp)
#	$12 = move $13
	lw $t0, 444($sp)
	move $t2, $t0
#	$2591 = move $12
	move $t3, $t2
#	$18 = add $2587 5
	lw $t0, global_2587
	li $t1, 5
	add $t2, $t0, $t1
#	$19 = mul $18 4
	li $t1, 4
	mul $t4, $t2, $t1
#	$19 = add $19 4
	li $t1, 4
	add $t4, $t4, $t1
#	$17 = alloc $19
	move $a0, $t4
	li $v0, 9
	syscall
	move $t4, $v0
#	store 4 $17 $18 0
	sw $t2, 0($t4)
#	$17 = add $17 4
	li $t1, 4
	add $t4, $t4, $t1
#	$16 = move $17
	move $t2, $t4
#	$2592 = move $16
	move $s0, $t2
#	$21 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$22 = add $2591 $21
	add $t2, $t3, $t2
#	store 4 $22 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$2590 = move 2
	li $t0, 2
	sw $t0, 280($sp)
#	%ForLoop41
_ForLoop41:
#	jump %ForBody2
	b _ForBody2
#	%ForBody2
_ForBody2:
#	$24 = sgt $2590 $2587
	lw $t0, 280($sp)
	lw $t1, global_2587
	sgt $t2, $t0, $t1
#	br $24 %consequence4 %alternative5
	beqz $t2, _alternative5
#	%consequence4
_consequence4:
#	jump %OutOfFor3
	b _OutOfFor3
#	jump %OutOfIf6
	b _OutOfIf6
#	%alternative5
_alternative5:
#	jump %OutOfIf6
	b _OutOfIf6
#	%OutOfIf6
_OutOfIf6:
#	$25 = mul $2590 4
	lw $t0, 280($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$26 = add $2589 $25
	lw $t0, global_2589
	add $t2, $t0, $t2
#	$27 = load 4 $26 0
	lw $t2, 0($t2)
#	br $27 %consequence7 %alternative8
	beqz $t2, _alternative8
#	%consequence7
_consequence7:
#	$2588 = add $2588 1
	lw $t0, global_2588
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_2588
#	$29 = mul $2588 4
	lw $t0, global_2588
	li $t1, 4
	mul $t2, $t0, $t1
#	$30 = add $2592 $29
	add $t2, $s0, $t2
#	store 4 $30 $2590 0
	lw $t0, 280($sp)
	sw $t0, 0($t2)
#	$32 = mul $2590 4
	lw $t0, 280($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$33 = add $2591 $32
	add $t2, $t3, $t2
#	$34 = sub $2590 1
	lw $t0, 280($sp)
	li $t1, 1
	sub $t4, $t0, $t1
#	store 4 $33 $34 0
	sw $t4, 0($t2)
#	jump %OutOfIf9
	b _OutOfIf9
#	%alternative8
_alternative8:
#	jump %OutOfIf9
	b _OutOfIf9
#	%OutOfIf9
_OutOfIf9:
#	$2593 = move $2590
	lw $t0, 280($sp)
	move $t7, $t0
#	$2594 = move 1
	li $t0, 1
	move $t5, $t0
#	%ForLoop43
_ForLoop43:
#	$37 = sle $2594 $2588
	lw $t1, global_2588
	sle $t2, $t5, $t1
#	br $37 %logicalTrue12 %logicalFalse13
	beqz $t2, _logicalFalse13
#	%logicalTrue12
_logicalTrue12:
#	$40 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$41 = add $2592 $40
	add $t2, $s0, $t2
#	$42 = load 4 $41 0
	lw $t2, 0($t2)
#	$39 = mul $2593 $42
	mul $t2, $t7, $t2
#	$38 = sle $39 $2587
	lw $t1, global_2587
	sle $t2, $t2, $t1
#	$36 = move $38
	move $s2, $t2
#	jump %logicalMerge14
	b _logicalMerge14
#	%logicalFalse13
_logicalFalse13:
#	$36 = move 0
	li $t0, 0
	move $s2, $t0
#	jump %logicalMerge14
	b _logicalMerge14
#	%logicalMerge14
_logicalMerge14:
#	br $36 %ForBody10 %OutOfFor11
	beqz $s2, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$44 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$45 = add $2592 $44
	add $t2, $s0, $t2
#	$46 = load 4 $45 0
	lw $t2, 0($t2)
#	$43 = mul $2593 $46
	mul $t2, $t7, $t2
#	$2595 = move $43
	move $s3, $t2
#	$47 = sgt $2595 $2587
	lw $t1, global_2587
	sgt $t2, $s3, $t1
#	br $47 %consequence15 %alternative16
	beqz $t2, _alternative16
#	%consequence15
_consequence15:
#	jump %continueFor44
	b _continueFor44
#	jump %OutOfIf17
	b _OutOfIf17
#	%alternative16
_alternative16:
#	jump %OutOfIf17
	b _OutOfIf17
#	%OutOfIf17
_OutOfIf17:
#	$49 = mul $2595 4
	li $t1, 4
	mul $t2, $s3, $t1
#	$50 = add $2589 $49
	lw $t0, global_2589
	add $t2, $t0, $t2
#	store 4 $50 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$53 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$54 = add $2592 $53
	add $t2, $s0, $t2
#	$55 = load 4 $54 0
	lw $t2, 0($t2)
#	$52 = rem $2593 $55
	rem $t2, $t7, $t2
#	$51 = seq $52 0
	li $t1, 0
	seq $t2, $t2, $t1
#	br $51 %consequence18 %alternative19
	beqz $t2, _alternative19
#	%consequence18
_consequence18:
#	$57 = mul $2595 4
	li $t1, 4
	mul $t2, $s3, $t1
#	$58 = add $2591 $57
	add $t4, $t3, $t2
#	$60 = mul $2593 4
	li $t1, 4
	mul $t2, $t7, $t1
#	$61 = add $2591 $60
	add $t6, $t3, $t2
#	$62 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$63 = add $2592 $62
	add $t2, $s0, $t2
#	$64 = load 4 $61 0
	lw $t6, 0($t6)
#	$65 = load 4 $63 0
	lw $t2, 0($t2)
#	$59 = mul $64 $65
	mul $t2, $t6, $t2
#	store 4 $58 $59 0
	sw $t2, 0($t4)
#	jump %OutOfFor11
	b _OutOfFor11
#	jump %OutOfIf20
	b _OutOfIf20
#	%alternative19
_alternative19:
#	$68 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$69 = add $2592 $68
	add $t2, $s0, $t2
#	$70 = load 4 $69 0
	lw $t2, 0($t2)
#	$67 = mul $2593 $70
	mul $t2, $t7, $t2
#	$71 = mul $67 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$72 = add $2591 $71
	add $t4, $t3, $t2
#	$74 = mul $2593 4
	li $t1, 4
	mul $t2, $t7, $t1
#	$75 = add $2591 $74
	add $t6, $t3, $t2
#	$77 = mul $2594 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$78 = add $2592 $77
	add $t2, $s0, $t2
#	$79 = load 4 $78 0
	lw $t2, 0($t2)
#	$76 = sub $79 1
	li $t1, 1
	sub $s1, $t2, $t1
#	$80 = load 4 $75 0
	lw $t2, 0($t6)
#	$73 = mul $80 $76
	mul $t2, $t2, $s1
#	store 4 $72 $73 0
	sw $t2, 0($t4)
#	jump %OutOfIf20
	b _OutOfIf20
#	%OutOfIf20
_OutOfIf20:
#	jump %continueFor44
	b _continueFor44
#	%continueFor44
_continueFor44:
#	$81 = move $2594
	move $t2, $t5
#	$2594 = add $2594 1
	li $t1, 1
	add $t5, $t5, $t1
#	jump %ForLoop43
	b _ForLoop43
#	%OutOfFor11
_OutOfFor11:
#	$82 = mul $2593 4
	li $t1, 4
	mul $t2, $t7, $t1
#	$83 = add $2591 $82
	add $t2, $t3, $t2
#	$84 = load 4 $83 0
	lw $t2, 0($t2)
#	$85 = call toString $84
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $85
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	%continueFor42
_continueFor42:
#	$2590 = add $2590 1
	lw $t0, 280($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 280($sp)
#	jump %ForLoop41
	b _ForLoop41
#	%OutOfFor3
_OutOfFor3:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl39
	b _EndOfFunctionDecl39
#	%EndOfFunctionDecl39
_EndOfFunctionDecl39:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 456
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_2587:
.space 4
.align 2
global_2588:
.space 4
.align 2
global_2589:
.space 4
.align 2
