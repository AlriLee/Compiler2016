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
#	%BeginOfFunctionDecl50
_BeginOfFunctionDecl50:
#	$3 = mul $69 4
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
#	store 4 $2 $69 0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
#	$2 = add $2 4
	li $t1, 4
	add $t2, $t2, $t1
#	$1 = move $2
#	$68 = move $1
	sw $t2, global_68
#	$60 = move 0
	li $t0, 0
	sw $t0, global_60
#	%ForLoop60
_ForLoop60:
#	$5 = slt $60 $69
	lw $t0, global_60
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $5 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$7 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$8 = add $68 $7
	lw $t0, global_68
	add $t2, $t0, $t2
#	$11 = mul $69 4
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
#	store 4 $10 $69 0
	lw $t0, 196($sp)
	sw $t0, 0($t3)
#	$10 = add $10 4
	li $t1, 4
	add $t3, $t3, $t1
#	$9 = move $10
	sw $t3, 180($sp)
#	store 4 $8 $9 0
	lw $t0, 180($sp)
	sw $t0, 0($t2)
#	$61 = move 0
	li $t0, 0
	sw $t0, global_61
#	%ForLoop62
_ForLoop62:
#	$13 = slt $61 $69
	lw $t0, global_61
	lw $t1, 196($sp)
	slt $t2, $t0, $t1
#	br $13 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$15 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$16 = add $68 $15
	lw $t0, global_68
	add $t2, $t0, $t2
#	$17 = load 4 $16 0
	lw $t0, 0($t2)
	sw $t0, 160($sp)
#	$18 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
#	$19 = add $17 $18
	lw $t0, 160($sp)
	add $t2, $t0, $t2
#	store 4 $19 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor63
_continueFor63:
#	$20 = move $61
	lw $t0, global_61
	move $t2, $t0
#	$61 = add $61 1
	lw $t0, global_61
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_61
#	jump %ForLoop62
	b _ForLoop62
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor61
	b _continueFor61
#	%continueFor61
_continueFor61:
#	$21 = move $60
	lw $t0, global_60
	move $t2, $t0
#	$60 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_60
#	jump %ForLoop60
	b _ForLoop60
#	%OutOfFor1
_OutOfFor1:
#	jump %EndOfFunctionDecl51
	b _EndOfFunctionDecl51
#	%EndOfFunctionDecl51
_EndOfFunctionDecl51:
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 200
	jr $ra
_getPrime:
	sub $sp, $sp, 252
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
#	%BeginOfFunctionDecl52
_BeginOfFunctionDecl52:
#	$71 = move 2
	li $t0, 2
	sw $t0, 136($sp)
#	$72 = move 2
	li $t0, 2
	move $t3, $t0
#	%ForLoop64
_ForLoop64:
#	$24 = sle $72 $70
	lw $t1, 248($sp)
	sle $t2, $t3, $t1
#	br $24 %ForBody4 %OutOfFor5
	beqz $t2, _OutOfFor5
#	%ForBody4
_ForBody4:
#	$26 = mul $72 4
	li $t1, 4
	mul $t2, $t3, $t1
#	$27 = add $64 $26
	lw $t0, global_64
	add $t2, $t0, $t2
#	$28 = load 4 $27 0
	lw $t2, 0($t2)
#	$25 = seq $28 1
	li $t1, 1
	seq $t2, $t2, $t1
#	br $25 %consequence6 %alternative7
	beqz $t2, _alternative7
#	%consequence6
_consequence6:
#	$30 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$31 = add $67 $30
	lw $t0, global_67
	add $t2, $t0, $t2
#	$33 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
#	$34 = add $67 $33
	lw $t0, global_67
	add $t4, $t0, $t4
#	$35 = load 4 $34 0
	lw $t4, 0($t4)
#	$32 = add $35 1
	li $t1, 1
	add $t4, $t4, $t1
#	store 4 $31 $32 0
	sw $t4, 0($t2)
#	$37 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$38 = add $67 $37
	lw $t0, global_67
	add $t2, $t0, $t2
#	$39 = load 4 $38 0
	lw $t2, 0($t2)
#	$40 = mul $39 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$41 = add $65 $40
	lw $t0, global_65
	add $t2, $t0, $t2
#	store 4 $41 $72 0
	sw $t3, 0($t2)
#	$43 = mul $72 4
	li $t1, 4
	mul $t2, $t3, $t1
#	$44 = add $66 $43
	lw $t0, global_66
	add $t4, $t0, $t2
#	$45 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$46 = add $67 $45
	lw $t0, global_67
	add $t2, $t0, $t2
#	$47 = load 4 $46 0
	lw $t2, 0($t2)
#	store 4 $44 $47 0
	sw $t2, 0($t4)
#	jump %OutOfIf8
	b _OutOfIf8
#	%alternative7
_alternative7:
#	jump %OutOfIf8
	b _OutOfIf8
#	%OutOfIf8
_OutOfIf8:
#	jump %WhileLoop66
	b _WhileLoop66
#	%WhileLoop66
_WhileLoop66:
#	$49 = mul $72 $71
	lw $t1, 136($sp)
	mul $t2, $t3, $t1
#	$48 = sle $49 $70
	lw $t1, 248($sp)
	sle $t2, $t2, $t1
#	br $48 %WhileBody9 %OutOfWhile10
	beqz $t2, _OutOfWhile10
#	%WhileBody9
_WhileBody9:
#	$51 = mul $72 $71
	lw $t1, 136($sp)
	mul $t2, $t3, $t1
#	$52 = mul $51 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$53 = add $64 $52
	lw $t0, global_64
	add $t2, $t0, $t2
#	store 4 $53 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$55 = add $71 1
	lw $t0, 136($sp)
	li $t1, 1
	add $t2, $t0, $t1
#	$71 = move $55
	sw $t2, 136($sp)
#	jump %WhileLoop66
	b _WhileLoop66
#	%OutOfWhile10
_OutOfWhile10:
#	$71 = move 2
	li $t0, 2
	sw $t0, 136($sp)
#	%continueFor65
_continueFor65:
#	$58 = add $72 1
	li $t1, 1
	add $t2, $t3, $t1
#	$72 = move $58
	move $t3, $t2
#	jump %ForLoop64
	b _ForLoop64
#	%OutOfFor5
_OutOfFor5:
#	jump %EndOfFunctionDecl53
	b _EndOfFunctionDecl53
#	%EndOfFunctionDecl53
_EndOfFunctionDecl53:
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 252
	jr $ra
_getResult:
	sub $sp, $sp, 404
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl54
_BeginOfFunctionDecl54:
#	$60 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$61 = add $68 $60
	lw $t0, global_68
	add $t2, $t0, $t2
#	$62 = load 4 $61 0
	lw $t0, 0($t2)
	sw $t0, 384($sp)
#	$63 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$64 = add $62 $63
	lw $t0, 384($sp)
	add $t1, $t0, $t2
	sw $t1, 380($sp)
#	$65 = neg 1
	li $t0, 1
	neg $t2, $t0
#	$66 = load 4 $64 0
	lw $t1, 380($sp)
	lw $t3, 0($t1)
#	$59 = seq $66 $65
	seq $t2, $t3, $t2
#	br $59 %consequence11 %alternative12
	beqz $t2, _alternative12
#	%consequence11
_consequence11:
#	$70 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$71 = add $65 $70
	lw $t0, global_65
	add $t2, $t0, $t2
#	$72 = load 4 $71 0
	lw $t2, 0($t2)
#	$69 = mul $72 2
	li $t1, 2
	mul $t2, $t2, $t1
#	$73 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 264($sp)
#	$74 = add $65 $73
	lw $t0, global_65
	lw $t1, 264($sp)
	add $t1, $t0, $t1
	sw $t1, 292($sp)
#	$75 = load 4 $74 0
	lw $t1, 292($sp)
	lw $t0, 0($t1)
	sw $t0, 172($sp)
#	$68 = sub $69 $75
	lw $t1, 172($sp)
	sub $t2, $t2, $t1
#	$67 = sle $68 $73
	lw $t1, 392($sp)
	sle $t2, $t2, $t1
#	br $67 %consequence14 %alternative15
	beqz $t2, _alternative15
#	%consequence14
_consequence14:
#	$79 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$80 = add $65 $79
	lw $t0, global_65
	add $t2, $t0, $t2
#	$81 = load 4 $80 0
	lw $t2, 0($t2)
#	$78 = mul $81 2
	li $t1, 2
	mul $t1, $t2, $t1
	sw $t1, 340($sp)
#	$82 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$83 = add $65 $82
	lw $t0, global_65
	add $t2, $t0, $t2
#	$84 = load 4 $83 0
	lw $t2, 0($t2)
#	$77 = sub $78 $84
	lw $t0, 340($sp)
	sub $t2, $t0, $t2
#	$85 = mul $77 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$86 = add $64 $85
	lw $t0, global_64
	add $t2, $t0, $t2
#	$87 = load 4 $86 0
	lw $t2, 0($t2)
#	$76 = sne $87 0
	li $t1, 0
	sne $t2, $t2, $t1
#	br $76 %consequence17 %alternative18
	beqz $t2, _alternative18
#	%consequence17
_consequence17:
#	$89 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$90 = add $68 $89
	lw $t0, global_68
	add $t2, $t0, $t2
#	$91 = load 4 $90 0
	lw $t2, 0($t2)
#	$92 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
#	$93 = add $91 $92
	lw $t1, 156($sp)
	add $t2, $t2, $t1
#	$97 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$98 = add $65 $97
	lw $t0, global_65
	add $t3, $t0, $t3
#	$99 = load 4 $98 0
	lw $t3, 0($t3)
#	$96 = mul $99 2
	li $t1, 2
	mul $t4, $t3, $t1
#	$100 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$101 = add $65 $100
	lw $t0, global_65
	add $t1, $t0, $t3
	sw $t1, 388($sp)
#	$102 = load 4 $101 0
	lw $t1, 388($sp)
	lw $t3, 0($t1)
#	$95 = sub $96 $102
	sub $t3, $t4, $t3
#	$103 = mul $95 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$104 = add $66 $103
	lw $t0, global_66
	add $t3, $t0, $t3
#	$105 = load 4 $104 0
	lw $t3, 0($t3)
#	$106 = call getResult $73 $75 $105
	lw $t0, 392($sp)
	sw $t0, -12($sp)
	lw $t0, 400($sp)
	sw $t0, -8($sp)
	sw $t3, -4($sp)
	jal _getResult
	sw $v0, 372($sp)
#	$94 = add $106 1
	lw $t0, 372($sp)
	li $t1, 1
	add $t3, $t0, $t1
#	store 4 $93 $94 0
	sw $t3, 0($t2)
#	jump %OutOfIf19
	b _OutOfIf19
#	%alternative18
_alternative18:
#	jump %OutOfIf19
	b _OutOfIf19
#	%OutOfIf19
_OutOfIf19:
#	jump %OutOfIf16
	b _OutOfIf16
#	%alternative15
_alternative15:
#	jump %OutOfIf16
	b _OutOfIf16
#	%OutOfIf16
_OutOfIf16:
#	jump %OutOfIf13
	b _OutOfIf13
#	%alternative12
_alternative12:
#	jump %OutOfIf13
	b _OutOfIf13
#	%OutOfIf13
_OutOfIf13:
#	$108 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$109 = add $68 $108
	lw $t0, global_68
	add $t2, $t0, $t2
#	$110 = load 4 $109 0
	lw $t0, 0($t2)
	sw $t0, 244($sp)
#	$111 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$112 = add $110 $111
	lw $t0, 244($sp)
	add $t2, $t0, $t2
#	$113 = neg 1
	li $t0, 1
	neg $t1, $t0
	sw $t1, 300($sp)
#	$114 = load 4 $112 0
	lw $t2, 0($t2)
#	$107 = seq $114 $113
	lw $t1, 300($sp)
	seq $t2, $t2, $t1
#	br $107 %consequence20 %alternative21
	beqz $t2, _alternative21
#	%consequence20
_consequence20:
#	$116 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$117 = add $68 $116
	lw $t0, global_68
	add $t2, $t0, $t2
#	$118 = load 4 $117 0
	lw $t2, 0($t2)
#	$119 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 304($sp)
#	$120 = add $118 $119
	lw $t1, 304($sp)
	add $t2, $t2, $t1
#	store 4 $120 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	jump %OutOfIf22
	b _OutOfIf22
#	%alternative21
_alternative21:
#	jump %OutOfIf22
	b _OutOfIf22
#	%OutOfIf22
_OutOfIf22:
#	$121 = mul $74 4
	lw $t0, 396($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$122 = add $68 $121
	lw $t0, global_68
	add $t2, $t0, $t2
#	$123 = load 4 $122 0
	lw $t0, 0($t2)
	sw $t0, 228($sp)
#	$124 = mul $75 4
	lw $t0, 400($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$125 = add $123 $124
	lw $t0, 228($sp)
	add $t2, $t0, $t2
#	$126 = load 4 $125 0
	lw $t2, 0($t2)
#	ret $126
	move $v0, $t2
#	jump %EndOfFunctionDecl55
	b _EndOfFunctionDecl55
#	%EndOfFunctionDecl55
_EndOfFunctionDecl55:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 404
	jr $ra
_printF:
	sub $sp, $sp, 188
	sw $t2, 40($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl56
_BeginOfFunctionDecl56:
#	$127 = call toString $76
	lw $a0, 176($sp)
	jal func__toString
	move $t2, $v0
#	nullcall print $127
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	%WhileLoop67
_WhileLoop67:
#	$129 = sgt $78 0
	lw $t0, 184($sp)
	li $t1, 0
	sgt $t2, $t0, $t1
#	br $129 %WhileBody23 %OutOfWhile24
	beqz $t2, _OutOfWhile24
#	%WhileBody23
_WhileBody23:
#	nullcall print " "
	la $a0, string_130
	jal func__print
	move $t2, $v0
#	$132 = call toString $77
	lw $a0, 180($sp)
	jal func__toString
	move $t2, $v0
#	nullcall print $132
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$136 = mul $77 2
	lw $t0, 180($sp)
	li $t1, 2
	mul $t2, $t0, $t1
#	$135 = sub $136 $76
	lw $t1, 176($sp)
	sub $t2, $t2, $t1
#	$77 = move $135
	sw $t2, 180($sp)
#	$139 = add $76 $77
	lw $t0, 176($sp)
	lw $t1, 180($sp)
	add $t2, $t0, $t1
#	$138 = div $139 2
	li $t1, 2
	div $t2, $t2, $t1
#	$76 = move $138
	sw $t2, 176($sp)
#	$141 = sub $78 1
	lw $t0, 184($sp)
	li $t1, 1
	sub $t2, $t0, $t1
#	$78 = move $141
	sw $t2, 184($sp)
#	jump %WhileLoop67
	b _WhileLoop67
#	%OutOfWhile24
_OutOfWhile24:
#	nullcall print "\n"
	la $a0, string_142
	jal func__print
	move $t2, $v0
#	%EndOfFunctionDecl57
_EndOfFunctionDecl57:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 188
	jr $ra
main:
	sub $sp, $sp, 468
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl58
_BeginOfFunctionDecl58:
#	$146 = mul 1001 4
	li $t0, 1001
	li $t1, 4
	mul $t2, $t0, $t1
#	$146 = add $146 4
	li $t1, 4
	add $t2, $t2, $t1
#	$145 = alloc $146
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $145 1001 0
	li $t0, 1001
	sw $t0, 0($t2)
#	$145 = add $145 4
	li $t1, 4
	add $t2, $t2, $t1
#	$144 = move $145
#	$64 = move $144
	sw $t2, global_64
#	$149 = mul 170 4
	li $t0, 170
	li $t1, 4
	mul $t2, $t0, $t1
#	$149 = add $149 4
	li $t1, 4
	add $t2, $t2, $t1
#	$148 = alloc $149
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $148 170 0
	li $t0, 170
	sw $t0, 0($t2)
#	$148 = add $148 4
	li $t1, 4
	add $t2, $t2, $t1
#	$147 = move $148
#	$65 = move $147
	sw $t2, global_65
#	$152 = mul 1001 4
	li $t0, 1001
	li $t1, 4
	mul $t2, $t0, $t1
#	$152 = add $152 4
	li $t1, 4
	add $t2, $t2, $t1
#	$151 = alloc $152
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $151 1001 0
	li $t0, 1001
	sw $t0, 0($t2)
#	$151 = add $151 4
	li $t1, 4
	add $t2, $t2, $t1
#	$150 = move $151
#	$66 = move $150
	sw $t2, global_66
#	$155 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$155 = add $155 4
	li $t1, 4
	add $t2, $t2, $t1
#	$154 = alloc $155
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $154 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$154 = add $154 4
	li $t1, 4
	add $t2, $t2, $t1
#	$153 = move $154
#	$67 = move $153
	sw $t2, global_67
#	nullcall origin 170
	li $t0, 170
	sw $t0, -4($sp)
	jal _origin
	move $t2, $v0
#	$58 = move 1000
	li $t0, 1000
	sw $t0, global_58
#	$159 = call getInt
	jal func__getInt
	move $t2, $v0
#	$59 = move $159
	sw $t2, global_59
#	$62 = move 0
	li $t0, 0
	sw $t0, global_62
#	$63 = move 0
	li $t0, 0
	sw $t0, global_63
#	$163 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$164 = add $67 $163
	lw $t0, global_67
	add $t2, $t0, $t2
#	store 4 $164 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$60 = move 0
	li $t0, 0
	sw $t0, global_60
#	%ForLoop68
_ForLoop68:
#	$167 = add $58 1
	lw $t0, global_58
	li $t1, 1
	add $t2, $t0, $t1
#	$166 = slt $60 $167
	lw $t0, global_60
	slt $t2, $t0, $t2
#	br $166 %ForBody25 %OutOfFor26
	beqz $t2, _OutOfFor26
#	%ForBody25
_ForBody25:
#	$169 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$170 = add $64 $169
	lw $t0, global_64
	add $t2, $t0, $t2
#	store 4 $170 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$172 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$173 = add $66 $172
	lw $t0, global_66
	add $t2, $t0, $t2
#	store 4 $173 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor69
_continueFor69:
#	$175 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t2, $t0, $t1
#	$60 = move $175
	sw $t2, global_60
#	jump %ForLoop68
	b _ForLoop68
#	%OutOfFor26
_OutOfFor26:
#	$60 = move 0
	li $t0, 0
	sw $t0, global_60
#	%ForLoop70
_ForLoop70:
#	$178 = add $59 1
	lw $t0, global_59
	li $t1, 1
	add $t2, $t0, $t1
#	$177 = slt $60 $178
	lw $t0, global_60
	slt $t2, $t0, $t2
#	br $177 %ForBody27 %OutOfFor28
	beqz $t2, _OutOfFor28
#	%ForBody27
_ForBody27:
#	$180 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$181 = add $65 $180
	lw $t0, global_65
	add $t2, $t0, $t2
#	store 4 $181 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor71
_continueFor71:
#	$183 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t2, $t0, $t1
#	$60 = move $183
	sw $t2, global_60
#	jump %ForLoop70
	b _ForLoop70
#	%OutOfFor28
_OutOfFor28:
#	$60 = move 0
	li $t0, 0
	sw $t0, global_60
#	%ForLoop72
_ForLoop72:
#	$185 = sle $60 $59
	lw $t0, global_60
	lw $t1, global_59
	sle $t2, $t0, $t1
#	br $185 %ForBody29 %OutOfFor30
	beqz $t2, _OutOfFor30
#	%ForBody29
_ForBody29:
#	$61 = move 0
	li $t0, 0
	sw $t0, global_61
#	%ForLoop74
_ForLoop74:
#	$187 = sle $61 $59
	lw $t0, global_61
	lw $t1, global_59
	sle $t2, $t0, $t1
#	br $187 %ForBody31 %OutOfFor32
	beqz $t2, _OutOfFor32
#	%ForBody31
_ForBody31:
#	$189 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$190 = add $68 $189
	lw $t0, global_68
	add $t2, $t0, $t2
#	$191 = load 4 $190 0
	lw $t0, 0($t2)
	sw $t0, 436($sp)
#	$192 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
#	$193 = add $191 $192
	lw $t0, 436($sp)
	add $t1, $t0, $t2
	sw $t1, 296($sp)
#	$194 = neg 1
	li $t0, 1
	neg $t2, $t0
#	store 4 $193 $194 0
	lw $t1, 296($sp)
	sw $t2, 0($t1)
#	%continueFor75
_continueFor75:
#	$196 = add $61 1
	lw $t0, global_61
	li $t1, 1
	add $t2, $t0, $t1
#	$61 = move $196
	sw $t2, global_61
#	jump %ForLoop74
	b _ForLoop74
#	%OutOfFor32
_OutOfFor32:
#	jump %continueFor73
	b _continueFor73
#	%continueFor73
_continueFor73:
#	$198 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t2, $t0, $t1
#	$60 = move $198
	sw $t2, global_60
#	jump %ForLoop72
	b _ForLoop72
#	%OutOfFor30
_OutOfFor30:
#	$199 = call getPrime $58
	lw $t0, global_58
	sw $t0, -4($sp)
	jal _getPrime
	move $t2, $v0
#	$201 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$202 = add $67 $201
	lw $t0, global_67
	add $t2, $t0, $t2
#	$203 = load 4 $202 0
	lw $t2, 0($t2)
#	$62 = move $203
	sw $t2, global_62
#	$60 = move 1
	li $t0, 1
	sw $t0, global_60
#	%ForLoop76
_ForLoop76:
#	$205 = slt $60 $62
	lw $t0, global_60
	lw $t1, global_62
	slt $t2, $t0, $t1
#	br $205 %ForBody33 %OutOfFor34
	beqz $t2, _OutOfFor34
#	%ForBody33
_ForBody33:
#	$207 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t2, $t0, $t1
#	$61 = move $207
	sw $t2, global_61
#	%ForLoop78
_ForLoop78:
#	$208 = sle $61 $62
	lw $t0, global_61
	lw $t1, global_62
	sle $t2, $t0, $t1
#	br $208 %ForBody35 %OutOfFor36
	beqz $t2, _OutOfFor36
#	%ForBody35
_ForBody35:
#	$210 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$211 = add $68 $210
	lw $t0, global_68
	add $t2, $t0, $t2
#	$212 = load 4 $211 0
	lw $t2, 0($t2)
#	$213 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 392($sp)
#	$214 = add $212 $213
	lw $t1, 392($sp)
	add $t3, $t2, $t1
#	$215 = neg 1
	li $t0, 1
	neg $t2, $t0
#	$216 = load 4 $214 0
	lw $t0, 0($t3)
	sw $t0, 464($sp)
#	$209 = seq $216 $215
	lw $t0, 464($sp)
	seq $t2, $t0, $t2
#	br $209 %consequence37 %alternative38
	beqz $t2, _alternative38
#	%consequence37
_consequence37:
#	$218 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$219 = add $68 $218
	lw $t0, global_68
	add $t2, $t0, $t2
#	$220 = load 4 $219 0
	lw $t0, 0($t2)
	sw $t0, 448($sp)
#	$221 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
#	$222 = add $220 $221
	lw $t0, 448($sp)
	add $t2, $t0, $t2
#	$223 = call getResult $58 $60 $61
	lw $t0, global_58
	sw $t0, -12($sp)
	lw $t0, global_60
	sw $t0, -8($sp)
	lw $t0, global_61
	sw $t0, -4($sp)
	jal _getResult
	sw $v0, 232($sp)
#	store 4 $222 $223 0
	lw $t0, 232($sp)
	sw $t0, 0($t2)
#	$225 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$226 = add $68 $225
	lw $t0, global_68
	add $t2, $t0, $t2
#	$227 = load 4 $226 0
	lw $t0, 0($t2)
	sw $t0, 260($sp)
#	$228 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t2, $t0, $t1
#	$229 = add $227 $228
	lw $t0, 260($sp)
	add $t2, $t0, $t2
#	$230 = load 4 $229 0
	lw $t2, 0($t2)
#	$224 = sgt $230 1
	li $t1, 1
	sgt $t2, $t2, $t1
#	br $224 %consequence40 %alternative41
	beqz $t2, _alternative41
#	%consequence40
_consequence40:
#	$231 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t2, $t0, $t1
#	$232 = add $65 $231
	lw $t0, global_65
	add $t2, $t0, $t2
#	$233 = load 4 $232 0
	lw $t2, 0($t2)
#	$234 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t3, $t0, $t1
#	$235 = add $65 $234
	lw $t0, global_65
	add $t3, $t0, $t3
#	$236 = load 4 $235 0
	lw $t3, 0($t3)
#	$237 = mul $60 4
	lw $t0, global_60
	li $t1, 4
	mul $t4, $t0, $t1
#	$238 = add $68 $237
	lw $t0, global_68
	add $t4, $t0, $t4
#	$239 = load 4 $238 0
	lw $t4, 0($t4)
#	$240 = mul $61 4
	lw $t0, global_61
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 372($sp)
#	$241 = add $239 $240
	lw $t1, 372($sp)
	add $t1, $t4, $t1
	sw $t1, 348($sp)
#	$242 = load 4 $241 0
	lw $t1, 348($sp)
	lw $t4, 0($t1)
#	$243 = call printF $233 $236 $242
	sw $t2, -12($sp)
	sw $t3, -8($sp)
	sw $t4, -4($sp)
	jal _printF
	move $t2, $v0
#	$245 = add $63 1
	lw $t0, global_63
	li $t1, 1
	add $t2, $t0, $t1
#	$63 = move $245
	sw $t2, global_63
#	jump %OutOfIf42
	b _OutOfIf42
#	%alternative41
_alternative41:
#	jump %OutOfIf42
	b _OutOfIf42
#	%OutOfIf42
_OutOfIf42:
#	jump %OutOfIf39
	b _OutOfIf39
#	%alternative38
_alternative38:
#	jump %OutOfIf39
	b _OutOfIf39
#	%OutOfIf39
_OutOfIf39:
#	jump %continueFor79
	b _continueFor79
#	%continueFor79
_continueFor79:
#	$247 = add $61 1
	lw $t0, global_61
	li $t1, 1
	add $t2, $t0, $t1
#	$61 = move $247
	sw $t2, global_61
#	jump %ForLoop78
	b _ForLoop78
#	%OutOfFor36
_OutOfFor36:
#	jump %continueFor77
	b _continueFor77
#	%continueFor77
_continueFor77:
#	$249 = add $60 1
	lw $t0, global_60
	li $t1, 1
	add $t2, $t0, $t1
#	$60 = move $249
	sw $t2, global_60
#	jump %ForLoop76
	b _ForLoop76
#	%OutOfFor34
_OutOfFor34:
#	nullcall print "Total: "
	la $a0, string_250
	jal func__print
	move $t2, $v0
#	$252 = call toString $63
	lw $a0, global_63
	jal func__toString
	move $t2, $v0
#	nullcall println $252
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl59
	b _EndOfFunctionDecl59
#	%EndOfFunctionDecl59
_EndOfFunctionDecl59:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
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
