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
#	%BeginOfFunctionDecl66
_BeginOfFunctionDecl66:
#	$3 = mul $179 4
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
#	store 4 $2 $179 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$2 = add $2 4
	li $t1, 4
	add $t2, $t2, $t1
#	$1 = move $2
#	$176 = move $1
	sw $t2, global_176
#	$177 = move 0
	li $t0, 0
	sw $t0, global_177
#	%ForLoop74
_ForLoop74:
#	$5 = slt $177 $179
	lw $t0, global_177
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $5 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$7 = mul $177 4
	lw $t0, global_177
	li $t1, 4
	mul $t2, $t0, $t1
#	$8 = add $176 $7
	lw $t0, global_176
	add $t1, $t0, $t2
	sw $t1, 180($sp)
#	$11 = mul $179 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$11 = add $11 4
	li $t1, 4
	add $t2, $t2, $t1
#	$10 = alloc $11
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $10 $179 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$10 = add $10 4
	li $t1, 4
	add $t2, $t2, $t1
#	$9 = move $10
#	store 4 $8 $9 0
	lw $t1, 180($sp)
	sw $t2, 0($t1)
#	$178 = move 0
	li $t0, 0
	sw $t0, global_178
#	%ForLoop76
_ForLoop76:
#	$13 = slt $178 $179
	lw $t0, global_178
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $13 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$15 = mul $177 4
	lw $t0, global_177
	li $t1, 4
	mul $t2, $t0, $t1
#	$16 = add $176 $15
	lw $t0, global_176
	add $t2, $t0, $t2
#	$17 = load 4 $16 0
	lw $t2, 0($t2)
#	$18 = mul $178 4
	lw $t0, global_178
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
#	$19 = add $17 $18
	lw $t1, 156($sp)
	add $t2, $t2, $t1
#	store 4 $19 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor77
_continueFor77:
#	$20 = move $178
	lw $t0, global_178
	move $t2, $t0
#	$178 = add $178 1
	lw $t0, global_178
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_178
#	jump %ForLoop76
	b _ForLoop76
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor75
	b _continueFor75
#	%continueFor75
_continueFor75:
#	$21 = move $177
	lw $t0, global_177
	move $t2, $t0
#	$177 = add $177 1
	lw $t0, global_177
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_177
#	jump %ForLoop74
	b _ForLoop74
#	%OutOfFor1
_OutOfFor1:
#	jump %EndOfFunctionDecl67
	b _EndOfFunctionDecl67
#	%EndOfFunctionDecl67
_EndOfFunctionDecl67:
	lw $t2, 40($sp)
	add $sp, $sp, 200
	jr $ra
_check:
	sub $sp, $sp, 148
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl68
_BeginOfFunctionDecl68:
#	$23 = slt $180 $181
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t2, $t0, $t1
#	br $23 %logicalTrue4 %logicalFalse5
	beqz $t2, _logicalFalse5
#	%logicalTrue4
_logicalTrue4:
#	$24 = sge $180 0
	lw $t0, 140($sp)
	li $t1, 0
	sge $t2, $t0, $t1
#	$22 = move $24
#	jump %logicalMerge6
	b _logicalMerge6
#	%logicalFalse5
_logicalFalse5:
#	$22 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge6
	b _logicalMerge6
#	%logicalMerge6
_logicalMerge6:
#	ret $22
	move $v0, $t2
#	jump %EndOfFunctionDecl69
	b _EndOfFunctionDecl69
#	%EndOfFunctionDecl69
_EndOfFunctionDecl69:
	lw $t2, 40($sp)
	add $sp, $sp, 148
	jr $ra
_addList:
	sub $sp, $sp, 240
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl70
_BeginOfFunctionDecl70:
#	$27 = call check $182 $163
	lw $t0, 232($sp)
	sw $t0, -8($sp)
	lw $t0, global_163
	sw $t0, -4($sp)
	jal _check
	move $t2, $v0
#	br $27 %logicalTrue10 %logicalFalse11
	beqz $t2, _logicalFalse11
#	%logicalTrue10
_logicalTrue10:
#	$28 = call check $183 $163
	lw $t0, 236($sp)
	sw $t0, -8($sp)
	lw $t0, global_163
	sw $t0, -4($sp)
	jal _check
	move $t2, $v0
#	$26 = move $28
	move $t3, $t2
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalFalse11
_logicalFalse11:
#	$26 = move 0
	li $t0, 0
	move $t3, $t0
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalMerge12
_logicalMerge12:
#	br $26 %logicalTrue13 %logicalFalse14
	beqz $t3, _logicalFalse14
#	%logicalTrue13
_logicalTrue13:
#	$30 = mul $182 4
	lw $t0, 232($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$31 = add $176 $30
	lw $t0, global_176
	add $t2, $t0, $t2
#	$32 = load 4 $31 0
	lw $t2, 0($t2)
#	$33 = mul $183 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$34 = add $32 $33
	add $t4, $t2, $t4
#	$35 = neg 1
	li $t0, 1
	neg $t2, $t0
#	$36 = load 4 $34 0
	lw $t4, 0($t4)
#	$29 = seq $36 $35
	seq $t2, $t4, $t2
#	$25 = move $29
	move $t5, $t2
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalFalse14
_logicalFalse14:
#	$25 = move 0
	li $t0, 0
	move $t5, $t0
#	jump %logicalMerge15
	b _logicalMerge15
#	%logicalMerge15
_logicalMerge15:
#	br $25 %consequence7 %alternative8
	beqz $t5, _alternative8
#	%consequence7
_consequence7:
#	$38 = add $173 1
	lw $t0, global_173
	li $t1, 1
	add $t2, $t0, $t1
#	$173 = move $38
	sw $t2, global_173
#	$40 = mul $173 4
	lw $t0, global_173
	li $t1, 4
	mul $t2, $t0, $t1
#	$41 = add $171 $40
	lw $t0, global_171
	add $t2, $t0, $t2
#	store 4 $41 $182 0
	lw $t0, 232($sp)
	sw $t0, 0($t2)
#	$43 = mul $173 4
	lw $t0, global_173
	li $t1, 4
	mul $t2, $t0, $t1
#	$44 = add $172 $43
	lw $t0, global_172
	add $t2, $t0, $t2
#	store 4 $44 $183 0
	lw $t0, 236($sp)
	sw $t0, 0($t2)
#	$46 = mul $182 4
	lw $t0, 232($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$47 = add $176 $46
	lw $t0, global_176
	add $t2, $t0, $t2
#	$48 = load 4 $47 0
	lw $t2, 0($t2)
#	$49 = mul $183 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$50 = add $48 $49
	add $t4, $t2, $t4
#	$51 = add $175 1
	lw $t0, global_175
	li $t1, 1
	add $t2, $t0, $t1
#	store 4 $50 $51 0
	sw $t2, 0($t4)
#	$53 = seq $182 $167
	lw $t0, 232($sp)
	lw $t1, global_167
	seq $t2, $t0, $t1
#	br $53 %logicalTrue19 %logicalFalse20
	beqz $t2, _logicalFalse20
#	%logicalTrue19
_logicalTrue19:
#	$54 = seq $183 $168
	lw $t0, 236($sp)
	lw $t1, global_168
	seq $t2, $t0, $t1
#	$52 = move $54
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalFalse20
_logicalFalse20:
#	$52 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalMerge21
_logicalMerge21:
#	br $52 %consequence16 %alternative17
	beqz $t2, _alternative17
#	%consequence16
_consequence16:
#	$174 = move 1
	li $t0, 1
	sw $t0, global_174
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
#	jump %EndOfFunctionDecl71
	b _EndOfFunctionDecl71
#	%EndOfFunctionDecl71
_EndOfFunctionDecl71:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 240
	jr $ra
main:
	sub $sp, $sp, 400
	sw $t2, 40($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl72
_BeginOfFunctionDecl72:
#	$58 = mul 12000 4
	li $t0, 12000
	li $t1, 4
	mul $t2, $t0, $t1
#	$58 = add $58 4
	li $t1, 4
	add $t2, $t2, $t1
#	$57 = alloc $58
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $57 12000 0
	li $t0, 12000
	sw $t0, 0($t2)
#	$57 = add $57 4
	li $t1, 4
	add $t2, $t2, $t1
#	$56 = move $57
#	$171 = move $56
	sw $t2, global_171
#	$61 = mul 12000 4
	li $t0, 12000
	li $t1, 4
	mul $t2, $t0, $t1
#	$61 = add $61 4
	li $t1, 4
	add $t2, $t2, $t1
#	$60 = alloc $61
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $60 12000 0
	li $t0, 12000
	sw $t0, 0($t2)
#	$60 = add $60 4
	li $t1, 4
	add $t2, $t2, $t1
#	$59 = move $60
#	$172 = move $59
	sw $t2, global_172
#	nullcall origin 106
	li $t0, 106
	sw $t0, -4($sp)
	jal _origin
	move $t2, $v0
#	$64 = call getInt
	jal func__getInt
	move $t2, $v0
#	$163 = move $64
	sw $t2, global_163
#	$67 = sub $163 1
	lw $t0, global_163
	li $t1, 1
	sub $t2, $t0, $t1
#	$168 = move $67
	sw $t2, global_168
#	$167 = move $168
	lw $t0, global_168
	sw $t0, global_167
#	$177 = move 0
	li $t0, 0
	sw $t0, global_177
#	%ForLoop78
_ForLoop78:
#	$69 = slt $177 $163
	lw $t0, global_177
	lw $t1, global_163
	slt $t2, $t0, $t1
#	br $69 %ForBody22 %OutOfFor23
	beqz $t2, _OutOfFor23
#	%ForBody22
_ForBody22:
#	$178 = move 0
	li $t0, 0
	sw $t0, global_178
#	%ForLoop80
_ForLoop80:
#	$71 = slt $178 $163
	lw $t0, global_178
	lw $t1, global_163
	slt $t2, $t0, $t1
#	br $71 %ForBody24 %OutOfFor25
	beqz $t2, _OutOfFor25
#	%ForBody24
_ForBody24:
#	$73 = mul $177 4
	lw $t0, global_177
	li $t1, 4
	mul $t2, $t0, $t1
#	$74 = add $176 $73
	lw $t0, global_176
	add $t2, $t0, $t2
#	$75 = load 4 $74 0
	lw $t0, 0($t2)
	sw $t0, 276($sp)
#	$76 = mul $178 4
	lw $t0, global_178
	li $t1, 4
	mul $t2, $t0, $t1
#	$77 = add $75 $76
	lw $t0, 276($sp)
	add $t1, $t0, $t2
	sw $t1, 348($sp)
#	$78 = neg 1
	li $t0, 1
	neg $t2, $t0
#	store 4 $77 $78 0
	lw $t1, 348($sp)
	sw $t2, 0($t1)
#	%continueFor81
_continueFor81:
#	$79 = move $178
	lw $t0, global_178
	move $t2, $t0
#	$178 = add $178 1
	lw $t0, global_178
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_178
#	jump %ForLoop80
	b _ForLoop80
#	%OutOfFor25
_OutOfFor25:
#	jump %continueFor79
	b _continueFor79
#	%continueFor79
_continueFor79:
#	$80 = move $177
	lw $t0, global_177
	move $t2, $t0
#	$177 = add $177 1
	lw $t0, global_177
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_177
#	jump %ForLoop78
	b _ForLoop78
#	%OutOfFor23
_OutOfFor23:
#	jump %WhileLoop82
	b _WhileLoop82
#	%WhileLoop82
_WhileLoop82:
#	$81 = sle $164 $173
	lw $t0, global_164
	lw $t1, global_173
	sle $t2, $t0, $t1
#	br $81 %WhileBody26 %OutOfWhile27
	beqz $t2, _OutOfWhile27
#	%WhileBody26
_WhileBody26:
#	$83 = mul $164 4
	lw $t0, global_164
	li $t1, 4
	mul $t2, $t0, $t1
#	$84 = add $171 $83
	lw $t0, global_171
	add $t2, $t0, $t2
#	$85 = load 4 $84 0
	lw $t2, 0($t2)
#	$169 = move $85
	sw $t2, global_169
#	$87 = mul $164 4
	lw $t0, global_164
	li $t1, 4
	mul $t2, $t0, $t1
#	$88 = add $172 $87
	lw $t0, global_172
	add $t2, $t0, $t2
#	$89 = load 4 $88 0
	lw $t2, 0($t2)
#	$170 = move $89
	sw $t2, global_170
#	$91 = mul $169 4
	lw $t0, global_169
	li $t1, 4
	mul $t2, $t0, $t1
#	$92 = add $176 $91
	lw $t0, global_176
	add $t2, $t0, $t2
#	$93 = load 4 $92 0
	lw $t0, 0($t2)
	sw $t0, 292($sp)
#	$94 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$95 = add $93 $94
	lw $t0, 292($sp)
	add $t2, $t0, $t2
#	$96 = load 4 $95 0
	lw $t2, 0($t2)
#	$175 = move $96
	sw $t2, global_175
#	$97 = sub $169 1
	lw $t0, global_169
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 324($sp)
#	$98 = sub $170 2
	lw $t0, global_170
	li $t1, 2
	sub $t2, $t0, $t1
#	nullcall addList $97 $98
	lw $t0, 324($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _addList
	move $t2, $v0
#	$100 = sub $169 1
	lw $t0, global_169
	li $t1, 1
	sub $t2, $t0, $t1
#	$101 = add $170 2
	lw $t0, global_170
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 380($sp)
#	nullcall addList $100 $101
	sw $t2, -8($sp)
	lw $t0, 380($sp)
	sw $t0, -4($sp)
	jal _addList
	move $t2, $v0
#	$103 = add $169 1
	lw $t0, global_169
	li $t1, 1
	add $t2, $t0, $t1
#	$104 = sub $170 2
	lw $t0, global_170
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 360($sp)
#	nullcall addList $103 $104
	sw $t2, -8($sp)
	lw $t0, 360($sp)
	sw $t0, -4($sp)
	jal _addList
	move $t2, $v0
#	$106 = add $169 1
	lw $t0, global_169
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 272($sp)
#	$107 = add $170 2
	lw $t0, global_170
	li $t1, 2
	add $t2, $t0, $t1
#	nullcall addList $106 $107
	lw $t0, 272($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _addList
	move $t2, $v0
#	$109 = sub $169 2
	lw $t0, global_169
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 308($sp)
#	$110 = sub $170 1
	lw $t0, global_170
	li $t1, 1
	sub $t2, $t0, $t1
#	nullcall addList $109 $110
	lw $t0, 308($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _addList
	move $t2, $v0
#	$112 = sub $169 2
	lw $t0, global_169
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 392($sp)
#	$113 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t2, $t0, $t1
#	nullcall addList $112 $113
	lw $t0, 392($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _addList
	move $t2, $v0
#	$115 = add $169 2
	lw $t0, global_169
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 240($sp)
#	$116 = sub $170 1
	lw $t0, global_170
	li $t1, 1
	sub $t2, $t0, $t1
#	nullcall addList $115 $116
	lw $t0, 240($sp)
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _addList
	move $t2, $v0
#	$118 = add $169 2
	lw $t0, global_169
	li $t1, 2
	add $t2, $t0, $t1
#	$119 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 184($sp)
#	nullcall addList $118 $119
	sw $t2, -8($sp)
	lw $t0, 184($sp)
	sw $t0, -4($sp)
	jal _addList
	move $t2, $v0
#	$121 = seq $174 1
	lw $t0, global_174
	li $t1, 1
	seq $t2, $t0, $t1
#	br $121 %consequence28 %alternative29
	beqz $t2, _alternative29
#	%consequence28
_consequence28:
#	jump %OutOfWhile27
	b _OutOfWhile27
#	jump %OutOfIf30
	b _OutOfIf30
#	%alternative29
_alternative29:
#	jump %OutOfIf30
	b _OutOfIf30
#	%OutOfIf30
_OutOfIf30:
#	$123 = add $164 1
	lw $t0, global_164
	li $t1, 1
	add $t2, $t0, $t1
#	$164 = move $123
	sw $t2, global_164
#	jump %WhileLoop82
	b _WhileLoop82
#	%OutOfWhile27
_OutOfWhile27:
#	$124 = seq $174 1
	lw $t0, global_174
	li $t1, 1
	seq $t2, $t0, $t1
#	br $124 %consequence31 %alternative32
	beqz $t2, _alternative32
#	%consequence31
_consequence31:
#	$125 = mul $167 4
	lw $t0, global_167
	li $t1, 4
	mul $t2, $t0, $t1
#	$126 = add $176 $125
	lw $t0, global_176
	add $t2, $t0, $t2
#	$127 = load 4 $126 0
	lw $t0, 0($t2)
	sw $t0, 372($sp)
#	$128 = mul $168 4
	lw $t0, global_168
	li $t1, 4
	mul $t2, $t0, $t1
#	$129 = add $127 $128
	lw $t0, 372($sp)
	add $t2, $t0, $t2
#	$130 = load 4 $129 0
	lw $t2, 0($t2)
#	$131 = call toString $130
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $131
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	jump %OutOfIf33
	b _OutOfIf33
#	%alternative32
_alternative32:
#	nullcall print "no solution!\n"
	la $a0, string_133
	jal func__print
	move $t2, $v0
#	jump %OutOfIf33
	b _OutOfIf33
#	%OutOfIf33
_OutOfIf33:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl73
	b _EndOfFunctionDecl73
#	%EndOfFunctionDecl73
_EndOfFunctionDecl73:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 400
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_163:
.space 4
.align 2
global_164:
.space 4
.align 2
global_165:
.space 4
.align 2
global_166:
.space 4
.align 2
global_167:
.space 4
.align 2
global_168:
.space 4
.align 2
global_169:
.space 4
.align 2
global_170:
.space 4
.align 2
global_171:
.space 4
.align 2
global_172:
.space 4
.align 2
global_173:
.space 4
.align 2
global_174:
.space 4
.align 2
global_175:
.space 4
.align 2
global_176:
.space 4
.align 2
global_177:
.space 4
.align 2
global_178:
.space 4
.align 2
.word 13
string_133:
.asciiz "no solution!\n"
.align 2
