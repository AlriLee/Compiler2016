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
_exchange:
	sub $sp, $sp, 180
	sw $t3, 44($sp)
	sw $t2, 40($sp)
	sw $t4, 48($sp)
#	%BeginOfFunctionDecl38
_BeginOfFunctionDecl38:
#	$0 = mul $19 4
	lw $t0, 172($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$1 = add $18 $0
	lw $t0, global_18
	add $t2, $t0, $t2
#	$2 = load 4 $1 0
	lw $t2, 0($t2)
#	$21 = move $2
#	$4 = mul $19 4
	lw $t0, 172($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$5 = add $18 $4
	lw $t0, global_18
	add $t4, $t0, $t3
#	$6 = mul $20 4
	lw $t0, 176($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$7 = add $18 $6
	lw $t0, global_18
	add $t3, $t0, $t3
#	$8 = load 4 $7 0
	lw $t3, 0($t3)
#	store 4 $5 $8 0
	sw $t3, 0($t4)
#	$10 = mul $20 4
	lw $t0, 176($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$11 = add $18 $10
	lw $t0, global_18
	add $t3, $t0, $t3
#	store 4 $11 $21 0
	sw $t2, 0($t3)
#	%EndOfFunctionDecl39
_EndOfFunctionDecl39:
	lw $t3, 44($sp)
	lw $t2, 40($sp)
	lw $t4, 48($sp)
	add $sp, $sp, 180
	jr $ra
_makeHeap:
	sub $sp, $sp, 256
	sw $t3, 44($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t7, 60($sp)
	sw $t4, 48($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl40
_BeginOfFunctionDecl40:
#	$14 = sub $17 1
	lw $t0, global_17
	li $t1, 1
	sub $t2, $t0, $t1
#	$13 = div $14 2
	li $t1, 2
	div $t2, $t2, $t1
#	$22 = move $13
	move $t4, $t2
#	$24 = move 0
	li $t0, 0
	move $t6, $t0
#	$23 = move $24
	move $t2, $t6
#	%WhileLoop48
_WhileLoop48:
#	$17 = sge $22 0
	li $t1, 0
	sge $t1, $t4, $t1
	sw $t1, 252($sp)
#	br $17 %WhileBody0 %OutOfWhile1
	lw $t0, 252($sp)
	beqz $t0, _OutOfWhile1
#	%WhileBody0
_WhileBody0:
#	$19 = mul $22 2
	li $t1, 2
	mul $t2, $t4, $t1
#	$24 = move $19
	move $t6, $t2
#	$23 = mul $22 2
	li $t1, 2
	mul $t2, $t4, $t1
#	$22 = add $23 1
	li $t1, 1
	add $t2, $t2, $t1
#	$21 = slt $22 $17
	lw $t1, global_17
	slt $t1, $t2, $t1
	sw $t1, 244($sp)
#	br $21 %logicalTrue5 %logicalFalse6
	lw $t0, 244($sp)
	beqz $t0, _logicalFalse6
#	%logicalTrue5
_logicalTrue5:
#	$26 = mul $22 2
	li $t1, 2
	mul $t2, $t4, $t1
#	$25 = add $26 1
	li $t1, 1
	add $t2, $t2, $t1
#	$27 = mul $25 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$28 = add $18 $27
	lw $t0, global_18
	add $t2, $t0, $t2
#	$29 = mul $22 2
	li $t1, 2
	mul $t1, $t4, $t1
	sw $t1, 216($sp)
#	$30 = mul $29 4
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 228($sp)
#	$31 = add $18 $30
	lw $t0, global_18
	lw $t1, 228($sp)
	add $t3, $t0, $t1
#	$32 = load 4 $28 0
	lw $t2, 0($t2)
#	$33 = load 4 $31 0
	lw $t0, 0($t3)
	sw $t0, 240($sp)
#	$24 = slt $32 $33
	lw $t1, 240($sp)
	slt $t1, $t2, $t1
	sw $t1, 236($sp)
#	$20 = move $24
	lw $t0, 236($sp)
	move $t2, $t0
#	jump %logicalMerge7
	b _logicalMerge7
#	%logicalFalse6
_logicalFalse6:
#	$20 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge7
	b _logicalMerge7
#	%logicalMerge7
_logicalMerge7:
#	br $20 %consequence2 %alternative3
	beqz $t2, _alternative3
#	%consequence2
_consequence2:
#	$36 = mul $22 2
	li $t1, 2
	mul $t3, $t4, $t1
#	$35 = add $36 1
	li $t1, 1
	add $t1, $t3, $t1
	sw $t1, 248($sp)
#	$24 = move $35
	lw $t0, 248($sp)
	move $t6, $t0
#	jump %OutOfIf4
	b _OutOfIf4
#	%alternative3
_alternative3:
#	jump %OutOfIf4
	b _OutOfIf4
#	%OutOfIf4
_OutOfIf4:
#	$38 = mul $22 4
	li $t1, 4
	mul $t3, $t4, $t1
#	$39 = add $18 $38
	lw $t0, global_18
	add $t5, $t0, $t3
#	$40 = mul $24 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$41 = add $18 $40
	lw $t0, global_18
	add $t3, $t0, $t3
#	$42 = load 4 $39 0
	lw $t5, 0($t5)
#	$43 = load 4 $41 0
	lw $t3, 0($t3)
#	$37 = sgt $42 $43
	sgt $t1, $t5, $t3
	sw $t1, 232($sp)
#	br $37 %consequence8 %alternative9
	lw $t0, 232($sp)
	beqz $t0, _alternative9
#	%consequence8
_consequence8:
#	nullcall exchange $22 $24
	sw $t4, -8($sp)
	sw $t6, -4($sp)
	jal _exchange
	move $t3, $v0
#	jump %OutOfIf10
	b _OutOfIf10
#	%alternative9
_alternative9:
#	jump %OutOfIf10
	b _OutOfIf10
#	%OutOfIf10
_OutOfIf10:
#	$46 = sub $22 1
	li $t1, 1
	sub $t3, $t4, $t1
#	$22 = move $46
	move $t4, $t3
#	jump %WhileLoop48
	b _WhileLoop48
#	%OutOfWhile1
_OutOfWhile1:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl41
	b _EndOfFunctionDecl41
#	%EndOfFunctionDecl41
_EndOfFunctionDecl41:
	lw $ra, 120($sp)
	lw $t3, 44($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t7, 60($sp)
	lw $t4, 48($sp)
	add $sp, $sp, 256
	jr $ra
_adjustHeap:
	sub $sp, $sp, 292
	sw $t3, 44($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t4, 48($sp)
#	%BeginOfFunctionDecl42
_BeginOfFunctionDecl42:
#	$28 = move 0
	li $t0, 0
	move $t2, $t0
#	$27 = move $28
	move $t5, $t2
#	$26 = move $27
	sw $t5, 140($sp)
#	%WhileLoop49
_WhileLoop49:
#	$51 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$50 = slt $51 $25
	lw $t1, 288($sp)
	slt $t2, $t2, $t1
#	br $50 %WhileBody11 %OutOfWhile12
	beqz $t2, _OutOfWhile12
#	%WhileBody11
_WhileBody11:
#	$53 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$27 = move $53
	move $t5, $t2
#	$57 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$56 = add $57 1
	li $t1, 1
	add $t2, $t2, $t1
#	$55 = slt $56 $25
	lw $t1, 288($sp)
	slt $t2, $t2, $t1
#	br $55 %logicalTrue16 %logicalFalse17
	beqz $t2, _logicalFalse17
#	%logicalTrue16
_logicalTrue16:
#	$60 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$59 = add $60 1
	li $t1, 1
	add $t2, $t2, $t1
#	$61 = mul $59 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$62 = add $18 $61
	lw $t0, global_18
	add $t3, $t0, $t2
#	$63 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$64 = mul $63 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$65 = add $18 $64
	lw $t0, global_18
	add $t2, $t0, $t2
#	$66 = load 4 $62 0
	lw $t3, 0($t3)
#	$67 = load 4 $65 0
	lw $t2, 0($t2)
#	$58 = slt $66 $67
	slt $t2, $t3, $t2
#	$54 = move $58
	move $t6, $t2
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalFalse17
_logicalFalse17:
#	$54 = move 0
	li $t0, 0
	move $t6, $t0
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalMerge18
_logicalMerge18:
#	br $54 %consequence13 %alternative14
	beqz $t6, _alternative14
#	%consequence13
_consequence13:
#	$70 = mul $26 2
	lw $t0, 140($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$69 = add $70 1
	li $t1, 1
	add $t2, $t2, $t1
#	$27 = move $69
	move $t5, $t2
#	jump %OutOfIf15
	b _OutOfIf15
#	%alternative14
_alternative14:
#	jump %OutOfIf15
	b _OutOfIf15
#	%OutOfIf15
_OutOfIf15:
#	$72 = mul $26 4
	lw $t0, 140($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$73 = add $18 $72
	lw $t0, global_18
	add $t3, $t0, $t2
#	$74 = mul $27 4
	li $t1, 4
	mul $t2, $t5, $t1
#	$75 = add $18 $74
	lw $t0, global_18
	add $t2, $t0, $t2
#	$76 = load 4 $73 0
	lw $t3, 0($t3)
#	$77 = load 4 $75 0
	lw $t2, 0($t2)
#	$71 = sgt $76 $77
	sgt $t2, $t3, $t2
#	br $71 %consequence19 %alternative20
	beqz $t2, _alternative20
#	%consequence19
_consequence19:
#	$78 = mul $26 4
	lw $t0, 140($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$79 = add $18 $78
	lw $t0, global_18
	add $t2, $t0, $t2
#	$80 = load 4 $79 0
	lw $t2, 0($t2)
#	$29 = move $80
	move $t3, $t2
#	$82 = mul $26 4
	lw $t0, 140($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$83 = add $18 $82
	lw $t0, global_18
	add $t2, $t0, $t2
#	$84 = mul $27 4
	li $t1, 4
	mul $t4, $t5, $t1
#	$85 = add $18 $84
	lw $t0, global_18
	add $t4, $t0, $t4
#	$86 = load 4 $85 0
	lw $t0, 0($t4)
	sw $t0, 268($sp)
#	store 4 $83 $86 0
	lw $t0, 268($sp)
	sw $t0, 0($t2)
#	$88 = mul $27 4
	li $t1, 4
	mul $t1, $t5, $t1
	sw $t1, 284($sp)
#	$89 = add $18 $88
	lw $t0, global_18
	lw $t1, 284($sp)
	add $t2, $t0, $t1
#	store 4 $89 $29 0
	sw $t3, 0($t2)
#	$26 = move $27
	sw $t5, 140($sp)
#	jump %OutOfIf21
	b _OutOfIf21
#	%alternative20
_alternative20:
#	jump %OutOfWhile12
	b _OutOfWhile12
#	jump %OutOfIf21
	b _OutOfIf21
#	%OutOfIf21
_OutOfIf21:
#	jump %WhileLoop49
	b _WhileLoop49
#	%OutOfWhile12
_OutOfWhile12:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl43
	b _EndOfFunctionDecl43
#	%EndOfFunctionDecl43
_EndOfFunctionDecl43:
	lw $t3, 44($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t4, 48($sp)
	add $sp, $sp, 292
	jr $ra
_heapSort:
	sub $sp, $sp, 212
	sw $t3, 44($sp)
	sw $t2, 40($sp)
	sw $t4, 48($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl44
_BeginOfFunctionDecl44:
#	$30 = move 0
	li $t0, 0
	move $t4, $t0
#	$31 = move 0
	li $t0, 0
	move $t3, $t0
#	%ForLoop50
_ForLoop50:
#	$93 = slt $31 $17
	lw $t1, global_17
	slt $t1, $t3, $t1
	sw $t1, 204($sp)
#	br $93 %ForBody22 %OutOfFor23
	lw $t0, 204($sp)
	beqz $t0, _OutOfFor23
#	%ForBody22
_ForBody22:
#	$95 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
#	$96 = add $18 $95
	lw $t0, global_18
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 180($sp)
#	$97 = load 4 $96 0
	lw $t1, 180($sp)
	lw $t0, 0($t1)
	sw $t0, 188($sp)
#	$30 = move $97
	lw $t0, 188($sp)
	move $t4, $t0
#	$99 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$100 = add $18 $99
	lw $t0, global_18
	add $t1, $t0, $t2
	sw $t1, 208($sp)
#	$102 = sub $17 $31
	lw $t0, global_17
	sub $t2, $t0, $t3
#	$101 = sub $102 1
	li $t1, 1
	sub $t2, $t2, $t1
#	$103 = mul $101 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$104 = add $18 $103
	lw $t0, global_18
	add $t2, $t0, $t2
#	$105 = load 4 $104 0
	lw $t2, 0($t2)
#	store 4 $100 $105 0
	lw $t1, 208($sp)
	sw $t2, 0($t1)
#	$108 = sub $17 $31
	lw $t0, global_17
	sub $t2, $t0, $t3
#	$107 = sub $108 1
	li $t1, 1
	sub $t1, $t2, $t1
	sw $t1, 156($sp)
#	$109 = mul $107 4
	lw $t0, 156($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
#	$110 = add $18 $109
	lw $t0, global_18
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 192($sp)
#	store 4 $110 $30 0
	lw $t1, 192($sp)
	sw $t4, 0($t1)
#	$112 = sub $17 $31
	lw $t0, global_17
	sub $t1, $t0, $t3
	sw $t1, 164($sp)
#	$111 = sub $112 1
	lw $t0, 164($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 148($sp)
#	$113 = call adjustHeap $111
	lw $t0, 148($sp)
	sw $t0, -4($sp)
	jal _adjustHeap
	sw $v0, 184($sp)
#	%continueFor51
_continueFor51:
#	$115 = add $31 1
	li $t1, 1
	add $t2, $t3, $t1
#	$31 = move $115
	move $t3, $t2
#	jump %ForLoop50
	b _ForLoop50
#	%OutOfFor23
_OutOfFor23:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl45
	b _EndOfFunctionDecl45
#	%EndOfFunctionDecl45
_EndOfFunctionDecl45:
	lw $ra, 120($sp)
	lw $t3, 44($sp)
	lw $t2, 40($sp)
	lw $t4, 48($sp)
	add $sp, $sp, 212
	jr $ra
main:
	sub $sp, $sp, 220
	sw $t3, 44($sp)
	sw $t2, 40($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl46
_BeginOfFunctionDecl46:
#	$117 = call getString
	jal func__getString
	move $t2, $v0
#	$118 = call parseInt $117
	move $a0, $t2
	jal func__parseInt
	move $t2, $v0
#	$17 = move $118
	sw $t2, global_17
#	$122 = mul $17 4
	lw $t0, global_17
	li $t1, 4
	mul $t2, $t0, $t1
#	$122 = add $122 4
	li $t1, 4
	add $t2, $t2, $t1
#	$121 = alloc $122
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $121 $17 0
	lw $t0, global_17
	sw $t0, 0($t2)
#	$121 = add $121 4
	li $t1, 4
	add $t2, $t2, $t1
#	$120 = move $121
#	$18 = move $120
	sw $t2, global_18
#	$32 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop52
_ForLoop52:
#	$125 = call size $18
	lw $a0, global_18
	jal func__size
	move $t3, $v0
#	$124 = slt $32 $125
	slt $t3, $t2, $t3
#	br $124 %ForBody24 %OutOfFor25
	beqz $t3, _OutOfFor25
#	%ForBody24
_ForBody24:
#	$127 = mul $32 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$128 = add $18 $127
	lw $t0, global_18
	add $t3, $t0, $t3
#	store 4 $128 $32 0
	sw $t2, 0($t3)
#	%continueFor53
_continueFor53:
#	$130 = add $32 1
	li $t1, 1
	add $t2, $t2, $t1
#	$32 = move $130
#	jump %ForLoop52
	b _ForLoop52
#	%OutOfFor25
_OutOfFor25:
#	$131 = call makeHeap
	jal _makeHeap
	move $t2, $v0
#	$132 = call heapSort
	jal _heapSort
	move $t2, $v0
#	$32 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop54
_ForLoop54:
#	$135 = call size $18
	lw $a0, global_18
	jal func__size
	sw $v0, 216($sp)
#	$134 = slt $32 $135
	lw $t1, 216($sp)
	slt $t1, $t2, $t1
	sw $t1, 188($sp)
#	br $134 %ForBody26 %OutOfFor27
	lw $t0, 188($sp)
	beqz $t0, _OutOfFor27
#	%ForBody26
_ForBody26:
#	$136 = mul $32 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$137 = add $18 $136
	lw $t0, global_18
	add $t3, $t0, $t3
#	$138 = load 4 $137 0
	lw $t0, 0($t3)
	sw $t0, 184($sp)
#	$139 = call toString $138
	lw $a0, 184($sp)
	jal func__toString
	move $t3, $v0
#	$141 = call stringConcatenate $139 " "
	move $a0, $t3
	la $a1, string_140
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $141
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	%continueFor55
_continueFor55:
#	$144 = add $32 1
	li $t1, 1
	add $t2, $t2, $t1
#	$32 = move $144
#	jump %ForLoop54
	b _ForLoop54
#	%OutOfFor27
_OutOfFor27:
#	nullcall print "\n"
	la $a0, string_145
	jal func__print
	sw $v0, 212($sp)
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl47
	b _EndOfFunctionDecl47
#	%EndOfFunctionDecl47
_EndOfFunctionDecl47:
	lw $ra, 120($sp)
	lw $t3, 44($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 220
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_17:
.space 4
.align 2
global_18:
.space 4
.align 2
.word 1
string_140:
.asciiz " "
.align 2
.word 1
string_145:
.asciiz "\n"
.align 2
