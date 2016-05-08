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
_printBoard:
	sub $sp, $sp, 184
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl57
_BeginOfFunctionDecl57:
#	$78 = move 0
	li $t0, 0
	move $t3, $t0
#	%ForLoop63
_ForLoop63:
#	$1 = slt $78 $74
	lw $t1, global_74
	slt $t1, $t3, $t1
	sw $t1, 164($sp)
#	br $1 %ForBody0 %OutOfFor1
	lw $t0, 164($sp)
	beqz $t0, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$79 = move 0
	li $t0, 0
	sw $t0, 180($sp)
#	%ForLoop65
_ForLoop65:
#	$3 = slt $79 $74
	lw $t0, 180($sp)
	lw $t1, global_74
	slt $t2, $t0, $t1
#	br $3 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$5 = mul $78 4
	li $t1, 4
	mul $t2, $t3, $t1
#	$6 = add $76 $5
	lw $t0, global_76
	add $t2, $t0, $t2
#	$7 = load 4 $6 0
	lw $t2, 0($t2)
#	$4 = seq $7 $79
	lw $t1, 180($sp)
	seq $t2, $t2, $t1
#	br $4 %consequence4 %alternative5
	beqz $t2, _alternative5
#	%consequence4
_consequence4:
#	nullcall print " O"
	la $a0, string_8
	jal func__print
	move $t2, $v0
#	jump %OutOfIf6
	b _OutOfIf6
#	%alternative5
_alternative5:
#	nullcall print " ."
	la $a0, string_10
	jal func__print
	move $t2, $v0
#	jump %OutOfIf6
	b _OutOfIf6
#	%OutOfIf6
_OutOfIf6:
#	jump %continueFor66
	b _continueFor66
#	%continueFor66
_continueFor66:
#	$12 = move $79
	lw $t0, 180($sp)
	move $t2, $t0
#	$79 = add $79 1
	lw $t0, 180($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 180($sp)
#	jump %ForLoop65
	b _ForLoop65
#	%OutOfFor3
_OutOfFor3:
#	nullcall println ""
	la $a0, string_13
	jal func__println
	move $t2, $v0
#	%continueFor64
_continueFor64:
#	$15 = move $78
	move $t2, $t3
#	$78 = add $78 1
	li $t1, 1
	add $t3, $t3, $t1
#	jump %ForLoop63
	b _ForLoop63
#	%OutOfFor1
_OutOfFor1:
#	nullcall println ""
	la $a0, string_16
	jal func__println
	move $t2, $v0
#	%EndOfFunctionDecl58
_EndOfFunctionDecl58:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 184
	jr $ra
_search:
	sub $sp, $sp, 408
	sw $s0, 64($sp)
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $s1, 68($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl59
_BeginOfFunctionDecl59:
#	$18 = seq $80 $74
	lw $t0, 404($sp)
	lw $t1, global_74
	seq $t2, $t0, $t1
#	br $18 %consequence7 %alternative8
	beqz $t2, _alternative8
#	%consequence7
_consequence7:
#	nullcall printBoard
	jal _printBoard
	move $t2, $v0
#	jump %OutOfIf9
	b _OutOfIf9
#	%alternative8
_alternative8:
#	$81 = move 0
	li $t0, 0
	move $t6, $t0
#	%ForLoop67
_ForLoop67:
#	$21 = slt $81 $74
	lw $t1, global_74
	slt $t2, $t6, $t1
#	br $21 %ForBody10 %OutOfFor11
	beqz $t2, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$25 = mul $81 4
	li $t1, 4
	mul $t2, $t6, $t1
#	$26 = add $75 $25
	lw $t0, global_75
	add $t2, $t0, $t2
#	$27 = load 4 $26 0
	lw $t2, 0($t2)
#	$24 = seq $27 0
	li $t1, 0
	seq $t2, $t2, $t1
#	br $24 %logicalTrue15 %logicalFalse16
	beqz $t2, _logicalFalse16
#	%logicalTrue15
_logicalTrue15:
#	$29 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$30 = add $77 $29
	lw $t0, global_77
	add $t2, $t0, $t2
#	$31 = load 4 $30 0
	lw $t2, 0($t2)
#	$32 = add $81 $80
	lw $t1, 404($sp)
	add $t3, $t6, $t1
#	$33 = mul $32 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$34 = add $31 $33
	add $t2, $t2, $t3
#	$35 = load 4 $34 0
	lw $t2, 0($t2)
#	$28 = seq $35 0
	li $t1, 0
	seq $t2, $t2, $t1
#	$23 = move $28
#	jump %logicalMerge17
	b _logicalMerge17
#	%logicalFalse16
_logicalFalse16:
#	$23 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge17
	b _logicalMerge17
#	%logicalMerge17
_logicalMerge17:
#	br $23 %logicalTrue18 %logicalFalse19
	beqz $t2, _logicalFalse19
#	%logicalTrue18
_logicalTrue18:
#	$37 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$38 = add $77 $37
	lw $t0, global_77
	add $t3, $t0, $t3
#	$39 = load 4 $38 0
	lw $t3, 0($t3)
#	$42 = add $81 $74
	lw $t1, global_74
	add $t4, $t6, $t1
#	$41 = sub $42 1
	li $t1, 1
	sub $t4, $t4, $t1
#	$40 = sub $41 $80
	lw $t1, 404($sp)
	sub $t4, $t4, $t1
#	$43 = mul $40 4
	li $t1, 4
	mul $t4, $t4, $t1
#	$44 = add $39 $43
	add $t3, $t3, $t4
#	$45 = load 4 $44 0
	lw $t3, 0($t3)
#	$36 = seq $45 0
	li $t1, 0
	seq $t3, $t3, $t1
#	$22 = move $36
	move $s0, $t3
#	jump %logicalMerge20
	b _logicalMerge20
#	%logicalFalse19
_logicalFalse19:
#	$22 = move 0
	li $t0, 0
	move $s0, $t0
#	jump %logicalMerge20
	b _logicalMerge20
#	%logicalMerge20
_logicalMerge20:
#	br $22 %consequence12 %alternative13
	beqz $s0, _alternative13
#	%consequence12
_consequence12:
#	$47 = mul $81 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$48 = add $75 $47
	lw $t0, global_75
	add $t4, $t0, $t3
#	$50 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$51 = add $77 $50
	lw $t0, global_77
	add $t3, $t0, $t3
#	$52 = load 4 $51 0
	lw $t3, 0($t3)
#	$53 = add $81 $80
	lw $t1, 404($sp)
	add $t5, $t6, $t1
#	$54 = mul $53 4
	li $t1, 4
	mul $t5, $t5, $t1
#	$55 = add $52 $54
	add $t7, $t3, $t5
#	$57 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$58 = add $77 $57
	lw $t0, global_77
	add $t3, $t0, $t3
#	$59 = load 4 $58 0
	lw $t5, 0($t3)
#	$62 = add $81 $74
	lw $t1, global_74
	add $t3, $t6, $t1
#	$61 = sub $62 1
	li $t1, 1
	sub $t3, $t3, $t1
#	$60 = sub $61 $80
	lw $t1, 404($sp)
	sub $t3, $t3, $t1
#	$63 = mul $60 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$64 = add $59 $63
	add $t3, $t5, $t3
#	store 4 $64 1 0
	li $t0, 1
	sw $t0, 0($t3)
#	$65 = load 4 $64 0
	lw $t3, 0($t3)
#	store 4 $55 $65 0
	sw $t3, 0($t7)
#	$66 = load 4 $55 0
	lw $t3, 0($t7)
#	store 4 $48 $66 0
	sw $t3, 0($t4)
#	$68 = mul $80 4
	lw $t0, 404($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$69 = add $76 $68
	lw $t0, global_76
	add $t3, $t0, $t3
#	store 4 $69 $81 0
	sw $t6, 0($t3)
#	$70 = add $80 1
	lw $t0, 404($sp)
	li $t1, 1
	add $t3, $t0, $t1
#	nullcall search $70
	sw $t3, -4($sp)
	jal _search
	move $t3, $v0
#	$73 = mul $81 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$74 = add $75 $73
	lw $t0, global_75
	add $t5, $t0, $t3
#	$76 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$77 = add $77 $76
	lw $t0, global_77
	add $t3, $t0, $t3
#	$78 = load 4 $77 0
	lw $t3, 0($t3)
#	$79 = add $81 $80
	lw $t1, 404($sp)
	add $t4, $t6, $t1
#	$80 = mul $79 4
	li $t1, 4
	mul $t4, $t4, $t1
#	$81 = add $78 $80
	add $t4, $t3, $t4
#	$83 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
#	$84 = add $77 $83
	lw $t0, global_77
	add $t3, $t0, $t3
#	$85 = load 4 $84 0
	lw $t7, 0($t3)
#	$88 = add $81 $74
	lw $t1, global_74
	add $t3, $t6, $t1
#	$87 = sub $88 1
	li $t1, 1
	sub $t3, $t3, $t1
#	$86 = sub $87 $80
	lw $t1, 404($sp)
	sub $t3, $t3, $t1
#	$89 = mul $86 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$90 = add $85 $89
	add $t3, $t7, $t3
#	store 4 $90 0 0
	li $t0, 0
	sw $t0, 0($t3)
#	$91 = load 4 $90 0
	lw $t3, 0($t3)
#	store 4 $81 $91 0
	sw $t3, 0($t4)
#	$92 = load 4 $81 0
	lw $t3, 0($t4)
#	store 4 $74 $92 0
	sw $t3, 0($t5)
#	jump %OutOfIf14
	b _OutOfIf14
#	%alternative13
_alternative13:
#	jump %OutOfIf14
	b _OutOfIf14
#	%OutOfIf14
_OutOfIf14:
#	jump %continueFor68
	b _continueFor68
#	%continueFor68
_continueFor68:
#	$93 = move $81
	move $t3, $t6
#	$81 = add $81 1
	li $t1, 1
	add $t6, $t6, $t1
#	jump %ForLoop67
	b _ForLoop67
#	%OutOfFor11
_OutOfFor11:
#	jump %OutOfIf9
	b _OutOfIf9
#	%OutOfIf9
_OutOfIf9:
#	jump %EndOfFunctionDecl60
	b _EndOfFunctionDecl60
#	%EndOfFunctionDecl60
_EndOfFunctionDecl60:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $s1, 68($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 408
	jr $ra
main:
	sub $sp, $sp, 208
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl61
_BeginOfFunctionDecl61:
#	$74 = move 8
	li $t0, 8
	sw $t0, global_74
#	$96 = mul 8 4
	li $t0, 8
	li $t1, 4
	mul $t2, $t0, $t1
#	$96 = add $96 4
	li $t1, 4
	add $t2, $t2, $t1
#	$95 = alloc $96
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $95 8 0
	li $t0, 8
	sw $t0, 0($t2)
#	$95 = add $95 4
	li $t1, 4
	add $t2, $t2, $t1
#	$94 = move $95
#	$75 = move $94
	sw $t2, global_75
#	$99 = mul 8 4
	li $t0, 8
	li $t1, 4
	mul $t2, $t0, $t1
#	$99 = add $99 4
	li $t1, 4
	add $t2, $t2, $t1
#	$98 = alloc $99
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $98 8 0
	li $t0, 8
	sw $t0, 0($t2)
#	$98 = add $98 4
	li $t1, 4
	add $t2, $t2, $t1
#	$97 = move $98
#	$76 = move $97
	sw $t2, global_76
#	$102 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$102 = add $102 4
	li $t1, 4
	add $t2, $t2, $t1
#	$101 = alloc $102
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $101 2 0
	li $t0, 2
	sw $t0, 0($t2)
#	$101 = add $101 4
	li $t1, 4
	add $t2, $t2, $t1
#	$100 = move $101
#	$77 = move $100
	sw $t2, global_77
#	$82 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop69
_ForLoop69:
#	$104 = slt $82 2
	li $t1, 2
	slt $t1, $t2, $t1
	sw $t1, 184($sp)
#	br $104 %ForBody21 %OutOfFor22
	lw $t0, 184($sp)
	beqz $t0, _OutOfFor22
#	%ForBody21
_ForBody21:
#	$106 = mul $82 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 164($sp)
#	$107 = add $77 $106
	lw $t0, global_77
	lw $t1, 164($sp)
	add $t4, $t0, $t1
#	$111 = add 8 8
	li $t0, 8
	li $t1, 8
	add $t1, $t0, $t1
	sw $t1, 172($sp)
#	$110 = sub $111 1
	lw $t0, 172($sp)
	li $t1, 1
	sub $t5, $t0, $t1
#	$112 = mul $110 4
	li $t1, 4
	mul $t3, $t5, $t1
#	$112 = add $112 4
	li $t1, 4
	add $t3, $t3, $t1
#	$109 = alloc $112
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $109 $110 0
	sw $t5, 0($t3)
#	$109 = add $109 4
	li $t1, 4
	add $t3, $t3, $t1
#	$108 = move $109
	sw $t3, 192($sp)
#	store 4 $107 $108 0
	lw $t0, 192($sp)
	sw $t0, 0($t4)
#	%continueFor70
_continueFor70:
#	$113 = move $82
	sw $t2, 204($sp)
#	$82 = add $82 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop69
	b _ForLoop69
#	%OutOfFor22
_OutOfFor22:
#	nullcall search 0
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	move $t3, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl62
	b _EndOfFunctionDecl62
#	%EndOfFunctionDecl62
_EndOfFunctionDecl62:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 208
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_74:
.space 4
.align 2
global_75:
.space 4
.align 2
global_76:
.space 4
.align 2
global_77:
.space 4
.align 2
.word 2
string_8:
.asciiz " O"
.align 2
.word 2
string_10:
.asciiz " ."
.align 2
.word 0
string_13:
.asciiz ""
.align 2
.word 0
string_16:
.asciiz ""
.align 2
