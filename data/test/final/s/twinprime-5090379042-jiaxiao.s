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
	sub $sp, $sp, 272
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl41
_BeginOfFunctionDecl41:
#	$31 = move 15000
	li $t0, 15000
	sw $t0, global_31
#	$2 = mul 15001 4
	li $t0, 15001
	li $t1, 4
	mul $t2, $t0, $t1
#	$2 = add $2 4
	li $t1, 4
	add $t2, $t2, $t1
#	$1 = alloc $2
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $1 15001 0
	li $t0, 15001
	sw $t0, 0($t2)
#	$1 = add $1 4
	li $t1, 4
	add $t2, $t2, $t1
#	$0 = move $1
#	$32 = move $0
	sw $t2, global_32
#	$33 = move 0
	li $t0, 0
	sw $t0, global_33
#	$34 = move 1
	li $t0, 1
	move $t2, $t0
#	%ForLoop43
_ForLoop43:
#	$4 = sle $34 $31
	lw $t1, global_31
	sle $t3, $t2, $t1
#	br $4 %ForBody0 %OutOfFor1
	beqz $t3, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$6 = mul $34 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$7 = add $32 $6
	lw $t0, global_32
	add $t3, $t0, $t3
#	store 4 $7 1 0
	li $t0, 1
	sw $t0, 0($t3)
#	%continueFor44
_continueFor44:
#	$8 = move $34
	move $t3, $t2
#	$34 = add $34 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop43
	b _ForLoop43
#	%OutOfFor1
_OutOfFor1:
#	$34 = move 2
	li $t0, 2
	move $t2, $t0
#	%ForLoop45
_ForLoop45:
#	$10 = sle $34 $31
	lw $t1, global_31
	sle $t1, $t2, $t1
	sw $t1, 248($sp)
#	br $10 %ForBody2 %OutOfFor3
	lw $t0, 248($sp)
	beqz $t0, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$11 = mul $34 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$12 = add $32 $11
	lw $t0, global_32
	add $t3, $t0, $t3
#	$13 = load 4 $12 0
	lw $t0, 0($t3)
	sw $t0, 252($sp)
#	br $13 %consequence4 %alternative5
	lw $t0, 252($sp)
	beqz $t0, _alternative5
#	%consequence4
_consequence4:
#	$35 = move 2
	li $t0, 2
	move $t4, $t0
#	$15 = sgt $34 3
	li $t1, 3
	sgt $t3, $t2, $t1
#	br $15 %logicalTrue10 %logicalFalse11
	beqz $t3, _logicalFalse11
#	%logicalTrue10
_logicalTrue10:
#	$16 = sub $34 2
	li $t1, 2
	sub $t3, $t2, $t1
#	$17 = mul $16 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$18 = add $32 $17
	lw $t0, global_32
	add $t3, $t0, $t3
#	$19 = load 4 $18 0
	lw $t3, 0($t3)
#	$14 = move $19
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalFalse11
_logicalFalse11:
#	$14 = move 0
	li $t0, 0
	move $t3, $t0
#	jump %logicalMerge12
	b _logicalMerge12
#	%logicalMerge12
_logicalMerge12:
#	br $14 %consequence7 %alternative8
	beqz $t3, _alternative8
#	%consequence7
_consequence7:
#	$20 = move $33
	lw $t0, global_33
	move $t5, $t0
#	$33 = add $33 1
	lw $t0, global_33
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_33
#	$21 = sub $34 2
	li $t1, 2
	sub $t5, $t2, $t1
#	$22 = call toString $21
	move $a0, $t5
	jal func__toString
	move $t5, $v0
#	$24 = call stringConcatenate $22 " "
	move $a0, $t5
	la $a1, string_23
	jal func__stringConcatenate
	move $t5, $v0
#	$25 = call toString $34
	move $a0, $t2
	jal func__toString
	move $t6, $v0
#	$26 = call stringConcatenate $24 $25
	move $a0, $t5
	move $a1, $t6
	jal func__stringConcatenate
	move $t5, $v0
#	nullcall println $26
	move $a0, $t5
	jal func__println
	move $t5, $v0
#	jump %OutOfIf9
	b _OutOfIf9
#	%alternative8
_alternative8:
#	jump %OutOfIf9
	b _OutOfIf9
#	%OutOfIf9
_OutOfIf9:
#	jump %WhileLoop47
	b _WhileLoop47
#	%WhileLoop47
_WhileLoop47:
#	$29 = mul $34 $35
	mul $t5, $t2, $t4
#	$28 = sle $29 $31
	lw $t1, global_31
	sle $t5, $t5, $t1
#	br $28 %WhileBody13 %OutOfWhile14
	beqz $t5, _OutOfWhile14
#	%WhileBody13
_WhileBody13:
#	$31 = mul $34 $35
	mul $t5, $t2, $t4
#	$32 = mul $31 4
	li $t1, 4
	mul $t5, $t5, $t1
#	$33 = add $32 $32
	lw $t0, global_32
	add $t5, $t0, $t5
#	store 4 $33 0 0
	li $t0, 0
	sw $t0, 0($t5)
#	$34 = move $35
	move $t5, $t4
#	$35 = add $35 1
	li $t1, 1
	add $t4, $t4, $t1
#	jump %WhileLoop47
	b _WhileLoop47
#	%OutOfWhile14
_OutOfWhile14:
#	jump %OutOfIf6
	b _OutOfIf6
#	%alternative5
_alternative5:
#	jump %OutOfIf6
	b _OutOfIf6
#	%OutOfIf6
_OutOfIf6:
#	jump %continueFor46
	b _continueFor46
#	%continueFor46
_continueFor46:
#	$35 = move $34
	move $t5, $t2
#	$34 = add $34 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop45
	b _ForLoop45
#	%OutOfFor3
_OutOfFor3:
#	$37 = call toString $33
	lw $a0, global_33
	jal func__toString
	move $t5, $v0
#	$38 = call stringConcatenate "Total: " $37
	la $a0, string_36
	move $a1, $t5
	jal func__stringConcatenate
	move $t5, $v0
#	nullcall println $38
	move $a0, $t5
	jal func__println
	move $t5, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl42
	b _EndOfFunctionDecl42
#	%EndOfFunctionDecl42
_EndOfFunctionDecl42:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 272
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
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
.word 1
string_23:
.asciiz " "
.align 2
.word 7
string_36:
.asciiz "Total: "
.align 2
