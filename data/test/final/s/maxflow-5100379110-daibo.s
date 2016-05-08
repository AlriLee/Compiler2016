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
#	%BeginOfFunctionDecl38
_BeginOfFunctionDecl38:
#	$3 = mul $43 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
#	$3 = add $3 4
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
#	$2 = alloc $3
	lw $a0, 152($sp)
	li $v0, 9
	syscall
	sw $v0, 136($sp)
#	store 4 $2 $43 0
	lw $t0, 196($sp)
	lw $t1, 136($sp)
	sw $t0, 0($t1)
#	$2 = add $2 4
	lw $t0, 136($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 136($sp)
#	$1 = move $2
	lw $t0, 136($sp)
	sw $t0, 144($sp)
#	$34 = move $1
	lw $t0, 144($sp)
	sw $t0, global_34
#	$39 = move 0
	li $t0, 0
	sw $t0, global_39
#	%ForLoop48
_ForLoop48:
#	$5 = slt $39 $43
	lw $t0, global_39
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 160($sp)
#	br $5 %ForBody0 %OutOfFor1
	lw $t0, 160($sp)
	beqz $t0, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$7 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
#	$8 = add $34 $7
	lw $t0, global_34
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 140($sp)
#	$11 = mul $43 4
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
#	$11 = add $11 4
	lw $t0, 172($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 172($sp)
#	$10 = alloc $11
	lw $a0, 172($sp)
	li $v0, 9
	syscall
	sw $v0, 164($sp)
#	store 4 $10 $43 0
	lw $t0, 196($sp)
	lw $t1, 164($sp)
	sw $t0, 0($t1)
#	$10 = add $10 4
	lw $t0, 164($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 164($sp)
#	$9 = move $10
	lw $t0, 164($sp)
	sw $t0, 184($sp)
#	store 4 $8 $9 0
	lw $t0, 184($sp)
	lw $t1, 140($sp)
	sw $t0, 0($t1)
#	$40 = move 0
	li $t0, 0
	sw $t0, global_40
#	%ForLoop50
_ForLoop50:
#	$13 = slt $40 $43
	lw $t0, global_40
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 156($sp)
#	br $13 %ForBody2 %OutOfFor3
	lw $t0, 156($sp)
	beqz $t0, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$15 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
#	$16 = add $34 $15
	lw $t0, global_34
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
#	$17 = load 4 $16 0
	lw $t1, 176($sp)
	lw $t0, 0($t1)
	sw $t0, 180($sp)
#	$18 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 192($sp)
#	$19 = add $17 $18
	lw $t0, 180($sp)
	lw $t1, 192($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
#	store 4 $19 0 0
	li $t0, 0
	lw $t1, 188($sp)
	sw $t0, 0($t1)
#	%continueFor51
_continueFor51:
#	$20 = move $40
	lw $t0, global_40
	sw $t0, 132($sp)
#	$40 = add $40 1
	lw $t0, global_40
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_40
#	jump %ForLoop50
	b _ForLoop50
#	%OutOfFor3
_OutOfFor3:
#	jump %continueFor49
	b _continueFor49
#	%continueFor49
_continueFor49:
#	$21 = move $39
	lw $t0, global_39
	sw $t0, 168($sp)
#	$39 = add $39 1
	lw $t0, global_39
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_39
#	jump %ForLoop48
	b _ForLoop48
#	%OutOfFor1
_OutOfFor1:
#	jump %EndOfFunctionDecl39
	b _EndOfFunctionDecl39
#	%EndOfFunctionDecl39
_EndOfFunctionDecl39:
	add $sp, $sp, 200
	jr $ra
_build:
	sub $sp, $sp, 236
#	%BeginOfFunctionDecl40
_BeginOfFunctionDecl40:
#	$39 = move 1
	li $t0, 1
	sw $t0, global_39
#	%ForLoop52
_ForLoop52:
#	$23 = sle $39 49
	lw $t0, global_39
	li $t1, 49
	sle $t1, $t0, $t1
	sw $t1, 208($sp)
#	br $23 %ForBody4 %OutOfFor5
	lw $t0, 208($sp)
	beqz $t0, _OutOfFor5
#	%ForBody4
_ForBody4:
#	$40 = move 50
	li $t0, 50
	sw $t0, global_40
#	%ForLoop54
_ForLoop54:
#	$27 = sub 98 $39
	li $t0, 98
	lw $t1, global_39
	sub $t1, $t0, $t1
	sw $t1, 140($sp)
#	$26 = add $27 1
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 212($sp)
#	$25 = sle $40 $26
	lw $t0, global_40
	lw $t1, 212($sp)
	sle $t1, $t0, $t1
	sw $t1, 216($sp)
#	br $25 %ForBody6 %OutOfFor7
	lw $t0, 216($sp)
	beqz $t0, _OutOfFor7
#	%ForBody6
_ForBody6:
#	$29 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
#	$30 = add $34 $29
	lw $t0, global_34
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
#	$31 = load 4 $30 0
	lw $t1, 128($sp)
	lw $t0, 0($t1)
	sw $t0, 132($sp)
#	$32 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
#	$33 = add $31 $32
	lw $t0, 132($sp)
	lw $t1, 160($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
#	store 4 $33 1 0
	li $t0, 1
	lw $t1, 224($sp)
	sw $t0, 0($t1)
#	%continueFor55
_continueFor55:
#	$34 = move $40
	lw $t0, global_40
	sw $t0, 136($sp)
#	$40 = add $40 1
	lw $t0, global_40
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_40
#	jump %ForLoop54
	b _ForLoop54
#	%OutOfFor7
_OutOfFor7:
#	jump %continueFor53
	b _continueFor53
#	%continueFor53
_continueFor53:
#	$35 = move $39
	lw $t0, global_39
	sw $t0, 180($sp)
#	$39 = add $39 1
	lw $t0, global_39
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_39
#	jump %ForLoop52
	b _ForLoop52
#	%OutOfFor5
_OutOfFor5:
#	$39 = move 1
	li $t0, 1
	sw $t0, global_39
#	%ForLoop56
_ForLoop56:
#	$37 = sle $39 49
	lw $t0, global_39
	li $t1, 49
	sle $t1, $t0, $t1
	sw $t1, 164($sp)
#	br $37 %ForBody8 %OutOfFor9
	lw $t0, 164($sp)
	beqz $t0, _OutOfFor9
#	%ForBody8
_ForBody8:
#	$39 = mul $44 4
	lw $t0, 228($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
#	$40 = add $34 $39
	lw $t0, global_34
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 152($sp)
#	$41 = load 4 $40 0
	lw $t1, 152($sp)
	lw $t0, 0($t1)
	sw $t0, 200($sp)
#	$42 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 144($sp)
#	$43 = add $41 $42
	lw $t0, 200($sp)
	lw $t1, 144($sp)
	add $t1, $t0, $t1
	sw $t1, 192($sp)
#	store 4 $43 1 0
	li $t0, 1
	lw $t1, 192($sp)
	sw $t0, 0($t1)
#	%continueFor57
_continueFor57:
#	$44 = move $39
	lw $t0, global_39
	sw $t0, 204($sp)
#	$39 = add $39 1
	lw $t0, global_39
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_39
#	jump %ForLoop56
	b _ForLoop56
#	%OutOfFor9
_OutOfFor9:
#	$39 = move 50
	li $t0, 50
	sw $t0, global_39
#	%ForLoop58
_ForLoop58:
#	$46 = sle $39 98
	lw $t0, global_39
	li $t1, 98
	sle $t1, $t0, $t1
	sw $t1, 168($sp)
#	br $46 %ForBody10 %OutOfFor11
	lw $t0, 168($sp)
	beqz $t0, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$48 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
#	$49 = add $34 $48
	lw $t0, global_34
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
#	$50 = load 4 $49 0
	lw $t1, 176($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
#	$51 = mul $45 4
	lw $t0, 232($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 196($sp)
#	$52 = add $50 $51
	lw $t0, 220($sp)
	lw $t1, 196($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
#	store 4 $52 1 0
	li $t0, 1
	lw $t1, 156($sp)
	sw $t0, 0($t1)
#	%continueFor59
_continueFor59:
#	$53 = move $39
	lw $t0, global_39
	sw $t0, 188($sp)
#	$39 = add $39 1
	lw $t0, global_39
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_39
#	jump %ForLoop58
	b _ForLoop58
#	%OutOfFor11
_OutOfFor11:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl41
	b _EndOfFunctionDecl41
#	%EndOfFunctionDecl41
_EndOfFunctionDecl41:
	add $sp, $sp, 236
	jr $ra
_find:
	sub $sp, $sp, 296
#	%BeginOfFunctionDecl42
_BeginOfFunctionDecl42:
#	$41 = move 0
	li $t0, 0
	sw $t0, global_41
#	$42 = move 1
	li $t0, 1
	sw $t0, global_42
#	$39 = move 1
	li $t0, 1
	sw $t0, global_39
#	%ForLoop60
_ForLoop60:
#	$57 = sle $39 $46
	lw $t0, global_39
	lw $t1, 284($sp)
	sle $t1, $t0, $t1
	sw $t1, 232($sp)
#	br $57 %ForBody12 %OutOfFor13
	lw $t0, 232($sp)
	beqz $t0, _OutOfFor13
#	%ForBody12
_ForBody12:
#	$59 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 260($sp)
#	$60 = add $36 $59
	lw $t0, global_36
	lw $t1, 260($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
#	store 4 $60 0 0
	li $t0, 0
	lw $t1, 156($sp)
	sw $t0, 0($t1)
#	%continueFor61
_continueFor61:
#	$61 = move $39
	lw $t0, global_39
	sw $t0, 216($sp)
#	$39 = add $39 1
	lw $t0, global_39
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_39
#	jump %ForLoop60
	b _ForLoop60
#	%OutOfFor13
_OutOfFor13:
#	$63 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
#	$64 = add $38 $63
	lw $t0, global_38
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
#	store 4 $64 $47 0
	lw $t0, 288($sp)
	lw $t1, 188($sp)
	sw $t0, 0($t1)
#	$66 = mul $47 4
	lw $t0, 288($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
#	$67 = add $36 $66
	lw $t0, global_36
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
#	store 4 $67 1 0
	li $t0, 1
	lw $t1, 176($sp)
	sw $t0, 0($t1)
#	$69 = mul $47 4
	lw $t0, 288($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
#	$70 = add $37 $69
	lw $t0, global_37
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
#	store 4 $70 0 0
	li $t0, 0
	lw $t1, 196($sp)
	sw $t0, 0($t1)
#	$48 = move 0
	li $t0, 0
	sw $t0, 292($sp)
#	%WhileLoop62
_WhileLoop62:
#	$73 = slt $41 $42
	lw $t0, global_41
	lw $t1, global_42
	slt $t1, $t0, $t1
	sw $t1, 132($sp)
#	br $73 %logicalTrue16 %logicalFalse17
	lw $t0, 132($sp)
	beqz $t0, _logicalFalse17
#	%logicalTrue16
_logicalTrue16:
#	$74 = seq $48 0
	lw $t0, 292($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 144($sp)
#	$72 = move $74
	lw $t0, 144($sp)
	sw $t0, 236($sp)
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalFalse17
_logicalFalse17:
#	$72 = move 0
	li $t0, 0
	sw $t0, 236($sp)
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalMerge18
_logicalMerge18:
#	br $72 %WhileBody14 %OutOfWhile15
	lw $t0, 236($sp)
	beqz $t0, _OutOfWhile15
#	%WhileBody14
_WhileBody14:
#	$75 = move $41
	lw $t0, global_41
	sw $t0, 172($sp)
#	$41 = add $41 1
	lw $t0, global_41
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_41
#	$77 = mul $41 4
	lw $t0, global_41
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 248($sp)
#	$78 = add $38 $77
	lw $t0, global_38
	lw $t1, 248($sp)
	add $t1, $t0, $t1
	sw $t1, 148($sp)
#	$79 = load 4 $78 0
	lw $t1, 148($sp)
	lw $t0, 0($t1)
	sw $t0, 192($sp)
#	$39 = move $79
	lw $t0, 192($sp)
	sw $t0, global_39
#	$40 = move 1
	li $t0, 1
	sw $t0, global_40
#	%ForLoop63
_ForLoop63:
#	$81 = sle $40 $46
	lw $t0, global_40
	lw $t1, 284($sp)
	sle $t1, $t0, $t1
	sw $t1, 208($sp)
#	br $81 %ForBody19 %OutOfFor20
	lw $t0, 208($sp)
	beqz $t0, _OutOfFor20
#	%ForBody19
_ForBody19:
#	$84 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 220($sp)
#	$85 = add $34 $84
	lw $t0, global_34
	lw $t1, 220($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
#	$86 = load 4 $85 0
	lw $t1, 224($sp)
	lw $t0, 0($t1)
	sw $t0, 272($sp)
#	$87 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 228($sp)
#	$88 = add $86 $87
	lw $t0, 272($sp)
	lw $t1, 228($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
#	$89 = load 4 $88 0
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 280($sp)
#	$83 = sgt $89 0
	lw $t0, 280($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 256($sp)
#	br $83 %logicalTrue24 %logicalFalse25
	lw $t0, 256($sp)
	beqz $t0, _logicalFalse25
#	%logicalTrue24
_logicalTrue24:
#	$91 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
#	$92 = add $36 $91
	lw $t0, global_36
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 200($sp)
#	$93 = load 4 $92 0
	lw $t1, 200($sp)
	lw $t0, 0($t1)
	sw $t0, 212($sp)
#	$90 = seq $93 0
	lw $t0, 212($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 244($sp)
#	$82 = move $90
	lw $t0, 244($sp)
	sw $t0, 160($sp)
#	jump %logicalMerge26
	b _logicalMerge26
#	%logicalFalse25
_logicalFalse25:
#	$82 = move 0
	li $t0, 0
	sw $t0, 160($sp)
#	jump %logicalMerge26
	b _logicalMerge26
#	%logicalMerge26
_logicalMerge26:
#	br $82 %consequence21 %alternative22
	lw $t0, 160($sp)
	beqz $t0, _alternative22
#	%consequence21
_consequence21:
#	$95 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
#	$96 = add $36 $95
	lw $t0, global_36
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
#	store 4 $96 1 0
	li $t0, 1
	lw $t1, 264($sp)
	sw $t0, 0($t1)
#	$97 = move $42
	lw $t0, global_42
	sw $t0, 276($sp)
#	$42 = add $42 1
	lw $t0, global_42
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_42
#	$99 = mul $42 4
	lw $t0, global_42
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
#	$100 = add $38 $99
	lw $t0, global_38
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 204($sp)
#	store 4 $100 $40 0
	lw $t0, global_40
	lw $t1, 204($sp)
	sw $t0, 0($t1)
#	$102 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
#	$103 = add $37 $102
	lw $t0, global_37
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 180($sp)
#	store 4 $103 $39 0
	lw $t0, global_39
	lw $t1, 180($sp)
	sw $t0, 0($t1)
#	$104 = seq $42 $46
	lw $t0, global_42
	lw $t1, 284($sp)
	seq $t1, $t0, $t1
	sw $t1, 252($sp)
#	br $104 %consequence27 %alternative28
	lw $t0, 252($sp)
	beqz $t0, _alternative28
#	%consequence27
_consequence27:
#	$48 = move 1
	li $t0, 1
	sw $t0, 292($sp)
#	jump %OutOfIf29
	b _OutOfIf29
#	%alternative28
_alternative28:
#	jump %OutOfIf29
	b _OutOfIf29
#	%OutOfIf29
_OutOfIf29:
#	jump %OutOfIf23
	b _OutOfIf23
#	%alternative22
_alternative22:
#	jump %OutOfIf23
	b _OutOfIf23
#	%OutOfIf23
_OutOfIf23:
#	jump %continueFor64
	b _continueFor64
#	%continueFor64
_continueFor64:
#	$106 = move $40
	lw $t0, global_40
	sw $t0, 268($sp)
#	$40 = add $40 1
	lw $t0, global_40
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_40
#	jump %ForLoop63
	b _ForLoop63
#	%OutOfFor20
_OutOfFor20:
#	jump %WhileLoop62
	b _WhileLoop62
#	%OutOfWhile15
_OutOfWhile15:
#	ret $48
	lw $v0, 292($sp)
#	jump %EndOfFunctionDecl43
	b _EndOfFunctionDecl43
#	%EndOfFunctionDecl43
_EndOfFunctionDecl43:
	add $sp, $sp, 296
	jr $ra
_improve:
	sub $sp, $sp, 228
#	%BeginOfFunctionDecl44
_BeginOfFunctionDecl44:
#	$39 = move $49
	lw $t0, 224($sp)
	sw $t0, global_39
#	$108 = move $35
	lw $t0, global_35
	sw $t0, 132($sp)
#	$35 = add $35 1
	lw $t0, global_35
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_35
#	%WhileLoop65
_WhileLoop65:
#	$110 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
#	$111 = add $37 $110
	lw $t0, global_37
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
#	$112 = load 4 $111 0
	lw $t1, 188($sp)
	lw $t0, 0($t1)
	sw $t0, 184($sp)
#	$109 = sgt $112 0
	lw $t0, 184($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 208($sp)
#	br $109 %WhileBody30 %OutOfWhile31
	lw $t0, 208($sp)
	beqz $t0, _OutOfWhile31
#	%WhileBody30
_WhileBody30:
#	$114 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
#	$115 = add $37 $114
	lw $t0, global_37
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 164($sp)
#	$116 = load 4 $115 0
	lw $t1, 164($sp)
	lw $t0, 0($t1)
	sw $t0, 144($sp)
#	$40 = move $116
	lw $t0, 144($sp)
	sw $t0, global_40
#	$117 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
#	$118 = add $34 $117
	lw $t0, global_34
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 212($sp)
#	$119 = load 4 $118 0
	lw $t1, 212($sp)
	lw $t0, 0($t1)
	sw $t0, 192($sp)
#	$120 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
#	$121 = add $119 $120
	lw $t0, 192($sp)
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 168($sp)
#	$123 = load 4 $121 0
	lw $t1, 168($sp)
	lw $t0, 0($t1)
	sw $t0, 200($sp)
#	$122 = move 4 $121 0
	sw $t0, 204($sp)
#	$124 = sub $122 1
	lw $t0, 204($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 156($sp)
#	store 4 $121 $124 0
	lw $t0, 156($sp)
	lw $t1, 168($sp)
	sw $t0, 0($t1)
#	$125 = mul $39 4
	lw $t0, global_39
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
#	$126 = add $34 $125
	lw $t0, global_34
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 216($sp)
#	$127 = load 4 $126 0
	lw $t1, 216($sp)
	lw $t0, 0($t1)
	sw $t0, 196($sp)
#	$128 = mul $40 4
	lw $t0, global_40
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
#	$129 = add $127 $128
	lw $t0, 196($sp)
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 220($sp)
#	$131 = load 4 $129 0
	lw $t1, 220($sp)
	lw $t0, 0($t1)
	sw $t0, 160($sp)
#	$130 = move 4 $129 0
	sw $t0, 136($sp)
#	$132 = add $130 1
	lw $t0, 136($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 176($sp)
#	store 4 $129 $132 0
	lw $t0, 176($sp)
	lw $t1, 220($sp)
	sw $t0, 0($t1)
#	$39 = move $40
	lw $t0, global_40
	sw $t0, global_39
#	jump %WhileLoop65
	b _WhileLoop65
#	%OutOfWhile31
_OutOfWhile31:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl45
	b _EndOfFunctionDecl45
#	%EndOfFunctionDecl45
_EndOfFunctionDecl45:
	add $sp, $sp, 228
	jr $ra
main:
	sub $sp, $sp, 208
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl46
_BeginOfFunctionDecl46:
#	$35 = move 0
	li $t0, 0
	sw $t0, global_35
#	$136 = mul 110 4
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
#	$136 = add $136 4
	lw $t0, 164($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 164($sp)
#	$135 = alloc $136
	lw $a0, 164($sp)
	li $v0, 9
	syscall
	sw $v0, 160($sp)
#	store 4 $135 110 0
	li $t0, 110
	lw $t1, 160($sp)
	sw $t0, 0($t1)
#	$135 = add $135 4
	lw $t0, 160($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 160($sp)
#	$134 = move $135
	lw $t0, 160($sp)
	sw $t0, 184($sp)
#	$36 = move $134
	lw $t0, 184($sp)
	sw $t0, global_36
#	$139 = mul 110 4
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 144($sp)
#	$139 = add $139 4
	lw $t0, 144($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 144($sp)
#	$138 = alloc $139
	lw $a0, 144($sp)
	li $v0, 9
	syscall
	sw $v0, 128($sp)
#	store 4 $138 110 0
	li $t0, 110
	lw $t1, 128($sp)
	sw $t0, 0($t1)
#	$138 = add $138 4
	lw $t0, 128($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 128($sp)
#	$137 = move $138
	lw $t0, 128($sp)
	sw $t0, 168($sp)
#	$37 = move $137
	lw $t0, 168($sp)
	sw $t0, global_37
#	$142 = mul 110 4
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
#	$142 = add $142 4
	lw $t0, 204($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 204($sp)
#	$141 = alloc $142
	lw $a0, 204($sp)
	li $v0, 9
	syscall
	sw $v0, 136($sp)
#	store 4 $141 110 0
	li $t0, 110
	lw $t1, 136($sp)
	sw $t0, 0($t1)
#	$141 = add $141 4
	lw $t0, 136($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 136($sp)
#	$140 = move $141
	lw $t0, 136($sp)
	sw $t0, 192($sp)
#	$38 = move $140
	lw $t0, 192($sp)
	sw $t0, global_38
#	nullcall origin 110
	li $t0, 110
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 172($sp)
#	$50 = move 0
	li $t0, 0
	sw $t0, 152($sp)
#	$51 = move 99
	li $t0, 99
	sw $t0, 148($sp)
#	$52 = move 100
	li $t0, 100
	sw $t0, 140($sp)
#	$53 = move 0
	li $t0, 0
	sw $t0, 156($sp)
#	$148 = call build $51 $52
	lw $t0, 148($sp)
	sw $t0, -8($sp)
	lw $t0, 140($sp)
	sw $t0, -4($sp)
	jal _build
	sw $v0, 132($sp)
#	%WhileLoop66
_WhileLoop66:
#	$150 = call find $52 $51 $53
	lw $t0, 140($sp)
	sw $t0, -12($sp)
	lw $t0, 148($sp)
	sw $t0, -8($sp)
	lw $t0, 156($sp)
	sw $t0, -4($sp)
	jal _find
	sw $v0, 196($sp)
#	$149 = sgt $150 0
	lw $t0, 196($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 180($sp)
#	br $149 %WhileBody32 %OutOfWhile33
	lw $t0, 180($sp)
	beqz $t0, _OutOfWhile33
#	%WhileBody32
_WhileBody32:
#	$151 = call improve $52
	lw $t0, 140($sp)
	sw $t0, -4($sp)
	jal _improve
	sw $v0, 200($sp)
#	jump %WhileLoop66
	b _WhileLoop66
#	%OutOfWhile33
_OutOfWhile33:
#	$152 = call toString $35
	lw $a0, global_35
	jal func__toString
	sw $v0, 188($sp)
#	nullcall println $152
	lw $a0, 188($sp)
	jal func__println
	sw $v0, 176($sp)
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl47
	b _EndOfFunctionDecl47
#	%EndOfFunctionDecl47
_EndOfFunctionDecl47:
	lw $ra, 120($sp)
	add $sp, $sp, 208
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_34:
.space 4
.align 2
global_35:
.space 4
.align 2
global_36:
.space 4
.align 2
global_37:
.space 4
.align 2
global_38:
.space 4
.align 2
global_39:
.space 4
.align 2
global_40:
.space 4
.align 2
global_41:
.space 4
.align 2
global_42:
.space 4
.align 2
