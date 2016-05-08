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
_printNum:
	sub $sp, $sp, 140
	sw $t2, 40($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl72
_BeginOfFunctionDecl72:
#	$0 = call toString $173
	lw $a0, 136($sp)
	jal func__toString
	move $t2, $v0
#	nullcall println $0
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	%EndOfFunctionDecl73
_EndOfFunctionDecl73:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	add $sp, $sp, 140
	jr $ra
main:
	sub $sp, $sp, 520
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl74
_BeginOfFunctionDecl74:
#	$4 = mul 4 4
	li $t0, 4
	li $t1, 4
	mul $t2, $t0, $t1
#	$4 = add $4 4
	li $t1, 4
	add $t2, $t2, $t1
#	$3 = alloc $4
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $3 4 0
	li $t0, 4
	sw $t0, 0($t2)
#	$3 = add $3 4
	li $t1, 4
	add $t2, $t2, $t1
#	$2 = move $3
#	$169 = move $2
	sw $t2, global_169
#	$7 = mul 5 4
	li $t0, 5
	li $t1, 4
	mul $t2, $t0, $t1
#	$7 = add $7 4
	li $t1, 4
	add $t2, $t2, $t1
#	$6 = alloc $7
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $6 5 0
	li $t0, 5
	sw $t0, 0($t2)
#	$6 = add $6 4
	li $t1, 4
	add $t2, $t2, $t1
#	$5 = move $6
#	$172 = move $5
	sw $t2, global_172
#	$170 = move 0
	li $t0, 0
	sw $t0, global_170
#	%ForLoop76
_ForLoop76:
#	$9 = slt $170 4
	lw $t0, global_170
	li $t1, 4
	slt $t2, $t0, $t1
#	br $9 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$11 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$12 = add $169 $11
	lw $t0, global_169
	add $t2, $t0, $t2
#	$15 = mul 11 4
	li $t0, 11
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 448($sp)
#	$15 = add $15 4
	lw $t0, 448($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 448($sp)
#	$14 = alloc $15
	lw $a0, 448($sp)
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $14 11 0
	li $t0, 11
	sw $t0, 0($t3)
#	$14 = add $14 4
	li $t1, 4
	add $t3, $t3, $t1
#	$13 = move $14
#	store 4 $12 $13 0
	sw $t3, 0($t2)
#	%continueFor77
_continueFor77:
#	$16 = move $170
	lw $t0, global_170
	move $t2, $t0
#	$170 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_170
#	jump %ForLoop76
	b _ForLoop76
#	%OutOfFor1
_OutOfFor1:
#	$170 = move 0
	li $t0, 0
	sw $t0, global_170
#	%ForLoop78
_ForLoop78:
#	$18 = slt $170 4
	lw $t0, global_170
	li $t1, 4
	slt $t2, $t0, $t1
#	br $18 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$171 = move 0
	li $t0, 0
	sw $t0, global_171
#	%ForLoop80
_ForLoop80:
#	$20 = slt $171 10
	lw $t0, global_171
	li $t1, 10
	slt $t2, $t0, $t1
#	br $20 %ForBody4 %OutOfFor5
	beqz $t2, _OutOfFor5
#	%ForBody4
_ForBody4:
#	$22 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$23 = add $169 $22
	lw $t0, global_169
	add $t2, $t0, $t2
#	$24 = load 4 $23 0
	lw $t2, 0($t2)
#	$25 = mul $171 4
	lw $t0, global_171
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 308($sp)
#	$26 = add $24 $25
	lw $t1, 308($sp)
	add $t2, $t2, $t1
#	store 4 $26 888 0
	li $t0, 888
	sw $t0, 0($t2)
#	%continueFor81
_continueFor81:
#	$27 = move $171
	lw $t0, global_171
	move $t2, $t0
#	$171 = add $171 1
	lw $t0, global_171
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_171
#	jump %ForLoop80
	b _ForLoop80
#	%OutOfFor5
_OutOfFor5:
#	jump %continueFor79
	b _continueFor79
#	%continueFor79
_continueFor79:
#	$28 = move $170
	lw $t0, global_170
	move $t2, $t0
#	$170 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_170
#	jump %ForLoop78
	b _ForLoop78
#	%OutOfFor3
_OutOfFor3:
#	$170 = move 0
	li $t0, 0
	sw $t0, global_170
#	%ForLoop82
_ForLoop82:
#	$30 = slt $170 5
	lw $t0, global_170
	li $t1, 5
	slt $t2, $t0, $t1
#	br $30 %ForBody6 %OutOfFor7
	beqz $t2, _OutOfFor7
#	%ForBody6
_ForBody6:
#	$32 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$33 = add $172 $32
	lw $t0, global_172
	add $t2, $t0, $t2
#	$36 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 324($sp)
#	$35 = alloc $36
	lw $a0, 324($sp)
	li $v0, 9
	syscall
	sw $v0, 272($sp)
#	$34 = move $35
	lw $t0, 272($sp)
	sw $t0, 440($sp)
#	store 4 $33 $34 0
	lw $t0, 440($sp)
	sw $t0, 0($t2)
#	$38 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$39 = add $172 $38
	lw $t0, global_172
	add $t2, $t0, $t2
#	$40 = load 4 $39 0
	lw $t2, 0($t2)
#	$41 = neg 1
	li $t0, 1
	neg $t1, $t0
	sw $t1, 420($sp)
#	store 4 $40 $41 0
	lw $t0, 420($sp)
	sw $t0, 0($t2)
#	%continueFor83
_continueFor83:
#	$42 = move $170
	lw $t0, global_170
	move $t2, $t0
#	$170 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_170
#	jump %ForLoop82
	b _ForLoop82
#	%OutOfFor7
_OutOfFor7:
#	$43 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$44 = add $169 $43
	lw $t0, global_169
	add $t2, $t0, $t2
#	$45 = load 4 $44 0
	lw $t0, 0($t2)
	sw $t0, 400($sp)
#	$46 = mul 9 4
	li $t0, 9
	li $t1, 4
	mul $t2, $t0, $t1
#	$47 = add $45 $46
	lw $t0, 400($sp)
	add $t2, $t0, $t2
#	$48 = load 4 $47 0
	lw $t2, 0($t2)
#	$49 = call printNum $48
	sw $t2, -4($sp)
	jal _printNum
	move $t2, $v0
#	$170 = move 0
	li $t0, 0
	sw $t0, global_170
#	%ForLoop84
_ForLoop84:
#	$51 = sle $170 3
	lw $t0, global_170
	li $t1, 3
	sle $t2, $t0, $t1
#	br $51 %ForBody8 %OutOfFor9
	beqz $t2, _OutOfFor9
#	%ForBody8
_ForBody8:
#	$171 = move 0
	li $t0, 0
	sw $t0, global_171
#	%ForLoop86
_ForLoop86:
#	$53 = sle $171 9
	lw $t0, global_171
	li $t1, 9
	sle $t2, $t0, $t1
#	br $53 %ForBody10 %OutOfFor11
	beqz $t2, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$55 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$56 = add $169 $55
	lw $t0, global_169
	add $t2, $t0, $t2
#	$57 = load 4 $56 0
	lw $t2, 0($t2)
#	$58 = mul $171 4
	lw $t0, global_171
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 356($sp)
#	$59 = add $57 $58
	lw $t1, 356($sp)
	add $t2, $t2, $t1
#	$61 = mul $170 10
	lw $t0, global_170
	li $t1, 10
	mul $t1, $t0, $t1
	sw $t1, 280($sp)
#	$60 = add $61 $171
	lw $t0, 280($sp)
	lw $t1, global_171
	add $t1, $t0, $t1
	sw $t1, 436($sp)
#	store 4 $59 $60 0
	lw $t0, 436($sp)
	sw $t0, 0($t2)
#	%continueFor87
_continueFor87:
#	$62 = move $171
	lw $t0, global_171
	move $t2, $t0
#	$171 = add $171 1
	lw $t0, global_171
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_171
#	jump %ForLoop86
	b _ForLoop86
#	%OutOfFor11
_OutOfFor11:
#	jump %continueFor85
	b _continueFor85
#	%continueFor85
_continueFor85:
#	$63 = move $170
	lw $t0, global_170
	move $t2, $t0
#	$170 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_170
#	jump %ForLoop84
	b _ForLoop84
#	%OutOfFor9
_OutOfFor9:
#	$170 = move 0
	li $t0, 0
	sw $t0, global_170
#	%ForLoop88
_ForLoop88:
#	$65 = sle $170 3
	lw $t0, global_170
	li $t1, 3
	sle $t2, $t0, $t1
#	br $65 %ForBody12 %OutOfFor13
	beqz $t2, _OutOfFor13
#	%ForBody12
_ForBody12:
#	$171 = move 0
	li $t0, 0
	sw $t0, global_171
#	%ForLoop90
_ForLoop90:
#	$67 = sle $171 9
	lw $t0, global_171
	li $t1, 9
	sle $t2, $t0, $t1
#	br $67 %ForBody14 %OutOfFor15
	beqz $t2, _OutOfFor15
#	%ForBody14
_ForBody14:
#	$68 = mul $170 4
	lw $t0, global_170
	li $t1, 4
	mul $t2, $t0, $t1
#	$69 = add $169 $68
	lw $t0, global_169
	add $t2, $t0, $t2
#	$70 = load 4 $69 0
	lw $t0, 0($t2)
	sw $t0, 428($sp)
#	$71 = mul $171 4
	lw $t0, global_171
	li $t1, 4
	mul $t2, $t0, $t1
#	$72 = add $70 $71
	lw $t0, 428($sp)
	add $t2, $t0, $t2
#	$73 = load 4 $72 0
	lw $t2, 0($t2)
#	$74 = call printNum $73
	sw $t2, -4($sp)
	jal _printNum
	move $t2, $v0
#	%continueFor91
_continueFor91:
#	$75 = move $171
	lw $t0, global_171
	move $t2, $t0
#	$171 = add $171 1
	lw $t0, global_171
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_171
#	jump %ForLoop90
	b _ForLoop90
#	%OutOfFor15
_OutOfFor15:
#	jump %continueFor89
	b _continueFor89
#	%continueFor89
_continueFor89:
#	$76 = move $170
	lw $t0, global_170
	move $t2, $t0
#	$170 = add $170 1
	lw $t0, global_170
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_170
#	jump %ForLoop88
	b _ForLoop88
#	%OutOfFor13
_OutOfFor13:
#	$78 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$79 = add $169 $78
	lw $t0, global_169
	add $t2, $t0, $t2
#	$80 = load 4 $79 0
	lw $t0, 0($t2)
	sw $t0, 300($sp)
#	$81 = mul 10 4
	li $t0, 10
	li $t1, 4
	mul $t2, $t0, $t1
#	$82 = add $80 $81
	lw $t0, 300($sp)
	add $t2, $t0, $t2
#	store 4 $82 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$83 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$84 = add $169 $83
	lw $t0, global_169
	add $t2, $t0, $t2
#	$85 = load 4 $84 0
	lw $t2, 0($t2)
#	$86 = mul 10 4
	li $t0, 10
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 508($sp)
#	$87 = add $85 $86
	lw $t1, 508($sp)
	add $t2, $t2, $t1
#	$88 = load 4 $87 0
	lw $t2, 0($t2)
#	$89 = call printNum $88
	sw $t2, -4($sp)
	jal _printNum
	move $t2, $v0
#	$91 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$92 = add $172 $91
	lw $t0, global_172
	add $t2, $t0, $t2
#	$93 = load 4 $92 0
	lw $t2, 0($t2)
#	$94 = neg 2
	li $t0, 2
	neg $t1, $t0
	sw $t1, 512($sp)
#	store 4 $93 $94 0
	lw $t0, 512($sp)
	sw $t0, 0($t2)
#	$96 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$97 = add $169 $96
	lw $t0, global_169
	add $t2, $t0, $t2
#	$98 = load 4 $97 0
	lw $t2, 0($t2)
#	$99 = mul 10 4
	li $t0, 10
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 192($sp)
#	$100 = add $98 $99
	lw $t1, 192($sp)
	add $t2, $t2, $t1
#	$101 = load 4 $100 0
	lw $t2, 0($t2)
#	$102 = mul $101 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$103 = add $172 $102
	lw $t0, global_172
	add $t2, $t0, $t2
#	$104 = load 4 $103 0
	lw $t0, 0($t2)
	sw $t0, 352($sp)
#	$105 = neg 10
	li $t0, 10
	neg $t2, $t0
#	store 4 $104 $105 0
	lw $t1, 352($sp)
	sw $t2, 0($t1)
#	$106 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$107 = add $172 $106
	lw $t0, global_172
	add $t2, $t0, $t2
#	$108 = load 4 $107 0
	lw $t2, 0($t2)
#	$109 = load 4 $108 0
	lw $t2, 0($t2)
#	$110 = call printNum $109
	sw $t2, -4($sp)
	jal _printNum
	move $t2, $v0
#	$111 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$112 = add $172 $111
	lw $t0, global_172
	add $t2, $t0, $t2
#	$113 = load 4 $112 0
	lw $t2, 0($t2)
#	$114 = load 4 $113 0
	lw $t2, 0($t2)
#	$115 = call printNum $114
	sw $t2, -4($sp)
	jal _printNum
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl75
	b _EndOfFunctionDecl75
#	%EndOfFunctionDecl75
_EndOfFunctionDecl75:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 520
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
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
