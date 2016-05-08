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
_qsrt:
	sub $sp, $sp, 284
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl81
_BeginOfFunctionDecl81:
#	$272 = move $270
	lw $t0, 276($sp)
	move $t2, $t0
#	$273 = move $271
	lw $t0, 280($sp)
	move $t4, $t0
#	$1 = add $270 $271
	lw $t0, 276($sp)
	lw $t1, 280($sp)
	add $t3, $t0, $t1
#	$0 = div $1 2
	li $t1, 2
	div $t3, $t3, $t1
#	$2 = mul $0 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$3 = add $268 $2
	lw $t0, global_268
	add $t3, $t0, $t3
#	$4 = load 4 $3 0
	lw $t3, 0($t3)
#	$274 = move $4
	sw $t3, 148($sp)
#	%WhileLoop85
_WhileLoop85:
#	$5 = sle $272 $273
	sle $t3, $t2, $t4
#	br $5 %WhileBody0 %OutOfWhile1
	beqz $t3, _OutOfWhile1
#	%WhileBody0
_WhileBody0:
#	jump %WhileLoop86
	b _WhileLoop86
#	%WhileLoop86
_WhileLoop86:
#	$7 = mul $272 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$8 = add $268 $7
	lw $t0, global_268
	add $t3, $t0, $t3
#	$9 = load 4 $8 0
	lw $t3, 0($t3)
#	$6 = slt $9 $274
	lw $t1, 148($sp)
	slt $t3, $t3, $t1
#	br $6 %WhileBody2 %OutOfWhile3
	beqz $t3, _OutOfWhile3
#	%WhileBody2
_WhileBody2:
#	$10 = move $272
	move $t3, $t2
#	$272 = add $272 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %WhileLoop86
	b _WhileLoop86
#	%OutOfWhile3
_OutOfWhile3:
#	jump %WhileLoop87
	b _WhileLoop87
#	%WhileLoop87
_WhileLoop87:
#	$12 = mul $273 4
	li $t1, 4
	mul $t3, $t4, $t1
#	$13 = add $268 $12
	lw $t0, global_268
	add $t3, $t0, $t3
#	$14 = load 4 $13 0
	lw $t3, 0($t3)
#	$11 = sgt $14 $274
	lw $t1, 148($sp)
	sgt $t3, $t3, $t1
#	br $11 %WhileBody4 %OutOfWhile5
	beqz $t3, _OutOfWhile5
#	%WhileBody4
_WhileBody4:
#	$15 = move $273
	move $t3, $t4
#	$273 = sub $273 1
	li $t1, 1
	sub $t4, $t4, $t1
#	jump %WhileLoop87
	b _WhileLoop87
#	%OutOfWhile5
_OutOfWhile5:
#	$16 = sle $272 $273
	sle $t3, $t2, $t4
#	br $16 %consequence6 %alternative7
	beqz $t3, _alternative7
#	%consequence6
_consequence6:
#	$17 = mul $272 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$18 = add $268 $17
	lw $t0, global_268
	add $t3, $t0, $t3
#	$19 = load 4 $18 0
	lw $t3, 0($t3)
#	$275 = move $19
	move $t6, $t3
#	$21 = mul $272 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$22 = add $268 $21
	lw $t0, global_268
	add $t5, $t0, $t3
#	$23 = mul $273 4
	li $t1, 4
	mul $t3, $t4, $t1
#	$24 = add $268 $23
	lw $t0, global_268
	add $t3, $t0, $t3
#	$25 = load 4 $24 0
	lw $t3, 0($t3)
#	store 4 $22 $25 0
	sw $t3, 0($t5)
#	$27 = mul $273 4
	li $t1, 4
	mul $t3, $t4, $t1
#	$28 = add $268 $27
	lw $t0, global_268
	add $t3, $t0, $t3
#	store 4 $28 $275 0
	sw $t6, 0($t3)
#	$29 = move $272
	move $t3, $t2
#	$272 = add $272 1
	li $t1, 1
	add $t2, $t2, $t1
#	$30 = move $273
	move $t3, $t4
#	$273 = sub $273 1
	li $t1, 1
	sub $t4, $t4, $t1
#	jump %OutOfIf8
	b _OutOfIf8
#	%alternative7
_alternative7:
#	jump %OutOfIf8
	b _OutOfIf8
#	%OutOfIf8
_OutOfIf8:
#	jump %WhileLoop85
	b _WhileLoop85
#	%OutOfWhile1
_OutOfWhile1:
#	$31 = slt $270 $273
	lw $t0, 276($sp)
	slt $t3, $t0, $t4
#	br $31 %consequence9 %alternative10
	beqz $t3, _alternative10
#	%consequence9
_consequence9:
#	$32 = call qsrt $270 $273
	lw $t0, 276($sp)
	sw $t0, -8($sp)
	sw $t4, -4($sp)
	jal _qsrt
	move $t3, $v0
#	jump %OutOfIf11
	b _OutOfIf11
#	%alternative10
_alternative10:
#	jump %OutOfIf11
	b _OutOfIf11
#	%OutOfIf11
_OutOfIf11:
#	$33 = slt $272 $271
	lw $t1, 280($sp)
	slt $t3, $t2, $t1
#	br $33 %consequence12 %alternative13
	beqz $t3, _alternative13
#	%consequence12
_consequence12:
#	$34 = call qsrt $272 $271
	sw $t2, -8($sp)
	lw $t0, 280($sp)
	sw $t0, -4($sp)
	jal _qsrt
	move $t3, $v0
#	jump %OutOfIf14
	b _OutOfIf14
#	%alternative13
_alternative13:
#	jump %OutOfIf14
	b _OutOfIf14
#	%OutOfIf14
_OutOfIf14:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl82
	b _EndOfFunctionDecl82
#	%EndOfFunctionDecl82
_EndOfFunctionDecl82:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 284
	jr $ra
main:
	sub $sp, $sp, 208
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl83
_BeginOfFunctionDecl83:
#	$37 = mul 10100 4
	li $t0, 10100
	li $t1, 4
	mul $t2, $t0, $t1
#	$37 = add $37 4
	li $t1, 4
	add $t2, $t2, $t1
#	$36 = alloc $37
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $36 10100 0
	li $t0, 10100
	sw $t0, 0($t2)
#	$36 = add $36 4
	li $t1, 4
	add $t2, $t2, $t1
#	$35 = move $36
#	$268 = move $35
	sw $t2, global_268
#	$269 = move 10000
	li $t0, 10000
	sw $t0, global_269
#	$276 = move 1
	li $t0, 1
	move $t2, $t0
#	%ForLoop88
_ForLoop88:
#	$39 = sle $276 $269
	lw $t1, global_269
	sle $t3, $t2, $t1
#	br $39 %ForBody15 %OutOfFor16
	beqz $t3, _OutOfFor16
#	%ForBody15
_ForBody15:
#	$41 = mul $276 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 184($sp)
#	$42 = add $268 $41
	lw $t0, global_268
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 200($sp)
#	$44 = add $269 1
	lw $t0, global_269
	li $t1, 1
	add $t3, $t0, $t1
#	$43 = sub $44 $276
	sub $t3, $t3, $t2
#	store 4 $42 $43 0
	lw $t1, 200($sp)
	sw $t3, 0($t1)
#	%continueFor89
_continueFor89:
#	$45 = move $276
	move $t3, $t2
#	$276 = add $276 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop88
	b _ForLoop88
#	%OutOfFor16
_OutOfFor16:
#	$46 = call qsrt 1 $269
	li $t0, 1
	sw $t0, -8($sp)
	lw $t0, global_269
	sw $t0, -4($sp)
	jal _qsrt
	move $t2, $v0
#	$276 = move 1
	li $t0, 1
	move $t2, $t0
#	%ForLoop90
_ForLoop90:
#	$48 = sle $276 $269
	lw $t1, global_269
	sle $t1, $t2, $t1
	sw $t1, 156($sp)
#	br $48 %ForBody17 %OutOfFor18
	lw $t0, 156($sp)
	beqz $t0, _OutOfFor18
#	%ForBody17
_ForBody17:
#	$49 = mul $276 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$50 = add $268 $49
	lw $t0, global_268
	add $t1, $t0, $t3
	sw $t1, 164($sp)
#	$51 = load 4 $50 0
	lw $t1, 164($sp)
	lw $t0, 0($t1)
	sw $t0, 168($sp)
#	$52 = call toString $51
	lw $a0, 168($sp)
	jal func__toString
	sw $v0, 204($sp)
#	nullcall print $52
	lw $a0, 204($sp)
	jal func__print
	sw $v0, 172($sp)
#	nullcall print " "
	la $a0, string_54
	jal func__print
	sw $v0, 188($sp)
#	%continueFor91
_continueFor91:
#	$56 = move $276
	sw $t2, 180($sp)
#	$276 = add $276 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop90
	b _ForLoop90
#	%OutOfFor18
_OutOfFor18:
#	nullcall print "\n"
	la $a0, string_57
	jal func__print
	move $t3, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl84
	b _EndOfFunctionDecl84
#	%EndOfFunctionDecl84
_EndOfFunctionDecl84:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 208
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_268:
.space 4
.align 2
global_269:
.space 4
.align 2
.word 1
string_54:
.asciiz " "
.align 2
.word 1
string_57:
.asciiz "\n"
.align 2
