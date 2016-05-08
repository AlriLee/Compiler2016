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
	sub $sp, $sp, 3208
	sw $s0, 64($sp)
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $s1, 68($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl41
_BeginOfFunctionDecl41:
#	$52 = move 1
	li $t0, 1
	sw $t0, global_52
#	$53 = move 1
	li $t0, 1
	sw $t0, global_53
#	$54 = move 1
	li $t0, 1
	sw $t0, global_54
#	%WhileLoop43
_WhileLoop43:
#	$2 = shl 1 29
	li $t0, 1
	li $t1, 29
	sll $t2, $t0, $t1
#	$1 = slt $54 $2
	lw $t0, global_54
	slt $t2, $t0, $t2
#	br $1 %logicalTrue2 %logicalFalse3
	beqz $t2, _logicalFalse3
#	%logicalTrue2
_logicalTrue2:
#	$4 = shl 1 29
	li $t0, 1
	li $t1, 29
	sll $t2, $t0, $t1
#	$5 = neg $4
	neg $t2, $t2
#	$3 = sgt $54 $5
	lw $t0, global_54
	sgt $t2, $t0, $t2
#	$0 = move $3
	move $s1, $t2
#	jump %logicalMerge4
	b _logicalMerge4
#	%logicalFalse3
_logicalFalse3:
#	$0 = move 0
	li $t0, 0
	move $s1, $t0
#	jump %logicalMerge4
	b _logicalMerge4
#	%logicalMerge4
_logicalMerge4:
#	br $0 %WhileBody0 %OutOfWhile1
	beqz $s1, _OutOfWhile1
#	%WhileBody0
_WhileBody0:
#	$15 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$14 = add $15 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$16 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$13 = sub $14 $16
	sub $t4, $t2, $t3
#	$19 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$18 = add $19 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$20 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$17 = sub $18 $20
	sub $t2, $t3, $t2
#	$12 = add $13 $17
	add $t3, $t4, $t2
#	$24 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$23 = add $24 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$25 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$22 = sub $23 $25
	sub $t4, $t4, $t2
#	$27 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$26 = add $27 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$21 = add $22 $26
	add $t2, $t4, $t2
#	$11 = add $12 $21
	add $t3, $t3, $t2
#	$31 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$33 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$32 = add $33 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$30 = add $31 $32
	add $t2, $t2, $t4
#	$34 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$29 = sub $30 $34
	sub $t5, $t2, $t4
#	$38 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$37 = add $38 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$39 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$36 = sub $37 $39
	sub $t2, $t4, $t2
#	$41 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$40 = add $41 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$35 = add $36 $40
	add $t2, $t2, $t4
#	$28 = add $29 $35
	add $t2, $t5, $t2
#	$10 = sub $11 $28
	sub $t3, $t3, $t2
#	$46 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$48 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$47 = add $48 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$45 = add $46 $47
	add $t4, $t2, $t4
#	$50 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$52 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t5, $t0, $t1
#	$51 = add $52 $53
	lw $t1, global_53
	add $t5, $t5, $t1
#	$49 = add $50 $51
	add $t2, $t2, $t5
#	$44 = sub $45 $49
	sub $t4, $t4, $t2
#	$55 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$57 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$56 = add $57 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$54 = add $55 $56
	add $t2, $t5, $t2
#	$58 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$53 = sub $54 $58
	sub $t2, $t2, $t5
#	$43 = sub $44 $53
	sub $t4, $t4, $t2
#	$63 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$62 = add $63 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$64 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$61 = sub $62 $64
	sub $t2, $t2, $t5
#	$66 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t5, $t0, $t1
#	$65 = add $66 $53
	lw $t1, global_53
	add $t5, $t5, $t1
#	$60 = add $61 $65
	add $t5, $t2, $t5
#	$69 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t6, $t0, $t1
#	$71 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$70 = add $71 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$68 = add $69 $70
	add $t6, $t6, $t2
#	$72 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$67 = sub $68 $72
	sub $t2, $t6, $t2
#	$59 = sub $60 $67
	sub $t2, $t5, $t2
#	$42 = add $43 $59
	add $t2, $t4, $t2
#	$9 = sub $10 $42
	sub $t3, $t3, $t2
#	$79 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$78 = add $79 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$80 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$77 = sub $78 $80
	sub $t5, $t4, $t2
#	$83 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$82 = add $83 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$84 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$81 = sub $82 $84
	sub $t2, $t4, $t2
#	$76 = add $77 $81
	add $t4, $t5, $t2
#	$88 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$87 = add $88 $53
	lw $t1, global_53
	add $t5, $t2, $t1
#	$89 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$86 = sub $87 $89
	sub $t2, $t5, $t2
#	$91 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t5, $t0, $t1
#	$90 = add $91 $53
	lw $t1, global_53
	add $t5, $t5, $t1
#	$85 = add $86 $90
	add $t2, $t2, $t5
#	$75 = add $76 $85
	add $t6, $t4, $t2
#	$95 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$97 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$96 = add $97 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$94 = add $95 $96
	add $t2, $t4, $t2
#	$98 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$93 = sub $94 $98
	sub $t4, $t2, $t4
#	$102 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$101 = add $102 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$103 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$100 = sub $101 $103
	sub $t5, $t2, $t5
#	$105 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$104 = add $105 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$99 = add $100 $104
	add $t2, $t5, $t2
#	$92 = add $93 $99
	add $t2, $t4, $t2
#	$74 = sub $75 $92
	sub $t7, $t6, $t2
#	$110 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$112 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$111 = add $112 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$109 = add $110 $111
	add $t4, $t2, $t4
#	$113 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$108 = sub $109 $113
	sub $t5, $t4, $t2
#	$117 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$116 = add $117 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$118 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$115 = sub $116 $118
	sub $t4, $t4, $t2
#	$120 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$119 = add $120 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$114 = add $115 $119
	add $t2, $t4, $t2
#	$107 = add $108 $114
	add $t4, $t5, $t2
#	$124 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$126 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$125 = add $126 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$123 = add $124 $125
	add $t5, $t5, $t2
#	$127 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$122 = sub $123 $127
	sub $t6, $t5, $t2
#	$131 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$130 = add $131 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$132 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$129 = sub $130 $132
	sub $t5, $t2, $t5
#	$134 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$133 = add $134 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$128 = add $129 $133
	add $t2, $t5, $t2
#	$121 = add $122 $128
	add $t2, $t6, $t2
#	$106 = sub $107 $121
	sub $t2, $t4, $t2
#	$73 = sub $74 $106
	sub $t2, $t7, $t2
#	$8 = add $9 $73
	add $t7, $t3, $t2
#	$141 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$143 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$142 = add $143 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$140 = add $141 $142
	add $t4, $t2, $t3
#	$145 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$147 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$146 = add $147 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$144 = add $145 $146
	add $t2, $t2, $t3
#	$139 = sub $140 $144
	sub $t3, $t4, $t2
#	$150 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$152 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$151 = add $152 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$149 = add $150 $151
	add $t2, $t4, $t2
#	$153 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$148 = sub $149 $153
	sub $t2, $t2, $t4
#	$138 = sub $139 $148
	sub $t4, $t3, $t2
#	$158 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$157 = add $158 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$159 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$156 = sub $157 $159
	sub $t3, $t2, $t3
#	$161 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$160 = add $161 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$155 = add $156 $160
	add $t5, $t3, $t2
#	$164 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$166 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$165 = add $166 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$163 = add $164 $165
	add $t2, $t3, $t2
#	$167 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$162 = sub $163 $167
	sub $t2, $t2, $t3
#	$154 = sub $155 $162
	sub $t2, $t5, $t2
#	$137 = add $138 $154
	add $t3, $t4, $t2
#	$173 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$172 = add $173 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$174 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$171 = sub $172 $174
	sub $t2, $t2, $t4
#	$176 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$175 = add $176 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$170 = add $171 $175
	add $t4, $t2, $t4
#	$179 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$181 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t5, $t0, $t1
#	$180 = add $181 $53
	lw $t1, global_53
	add $t5, $t5, $t1
#	$178 = add $179 $180
	add $t5, $t2, $t5
#	$182 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$177 = sub $178 $182
	sub $t2, $t5, $t2
#	$169 = sub $170 $177
	sub $t6, $t4, $t2
#	$187 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$186 = add $187 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$188 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$185 = sub $186 $188
	sub $t4, $t4, $t2
#	$190 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$189 = add $190 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$184 = add $185 $189
	add $t5, $t4, $t2
#	$193 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$195 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$194 = add $195 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$192 = add $193 $194
	add $t2, $t4, $t2
#	$196 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$191 = sub $192 $196
	sub $t2, $t2, $t4
#	$183 = sub $184 $191
	sub $t2, $t5, $t2
#	$168 = add $169 $183
	add $t2, $t6, $t2
#	$136 = add $137 $168
	add $s0, $t3, $t2
#	$203 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$202 = add $203 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$204 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$201 = sub $202 $204
	sub $t4, $t3, $t2
#	$207 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$206 = add $207 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$208 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$205 = sub $206 $208
	sub $t2, $t3, $t2
#	$200 = add $201 $205
	add $t4, $t4, $t2
#	$212 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$211 = add $212 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$213 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$210 = sub $211 $213
	sub $t3, $t2, $t3
#	$215 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$214 = add $215 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$209 = add $210 $214
	add $t2, $t3, $t2
#	$199 = add $200 $209
	add $t5, $t4, $t2
#	$219 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$221 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$220 = add $221 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$218 = add $219 $220
	add $t3, $t3, $t2
#	$222 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$217 = sub $218 $222
	sub $t4, $t3, $t2
#	$226 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$225 = add $226 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$227 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$224 = sub $225 $227
	sub $t3, $t3, $t2
#	$229 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$228 = add $229 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$223 = add $224 $228
	add $t2, $t3, $t2
#	$216 = add $217 $223
	add $t2, $t4, $t2
#	$198 = sub $199 $216
	sub $t5, $t5, $t2
#	$234 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$236 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$235 = add $236 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$233 = add $234 $235
	add $t2, $t3, $t2
#	$237 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$232 = sub $233 $237
	sub $t4, $t2, $t3
#	$241 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$240 = add $241 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$242 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$239 = sub $240 $242
	sub $t3, $t3, $t2
#	$244 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$243 = add $244 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$238 = add $239 $243
	add $t2, $t3, $t2
#	$231 = add $232 $238
	add $t6, $t4, $t2
#	$248 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$250 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$249 = add $250 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$247 = add $248 $249
	add $t2, $t3, $t2
#	$251 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$246 = sub $247 $251
	sub $t4, $t2, $t3
#	$255 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$254 = add $255 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$256 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$253 = sub $254 $256
	sub $t3, $t2, $t3
#	$258 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$257 = add $258 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$252 = add $253 $257
	add $t2, $t3, $t2
#	$245 = add $246 $252
	add $t2, $t4, $t2
#	$230 = sub $231 $245
	sub $t2, $t6, $t2
#	$197 = sub $198 $230
	sub $t2, $t5, $t2
#	$135 = add $136 $197
	add $t2, $s0, $t2
#	$7 = sub $8 $135
	sub $t2, $t7, $t2
#	$52 = move $7
	sw $t2, global_52
#	$268 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$267 = add $268 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$269 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$266 = sub $267 $269
	sub $t2, $t2, $t3
#	$272 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$271 = add $272 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$273 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$270 = sub $271 $273
	sub $t3, $t3, $t4
#	$265 = add $266 $270
	add $t3, $t2, $t3
#	$277 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$276 = add $277 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$278 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$275 = sub $276 $278
	sub $t4, $t4, $t2
#	$280 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$279 = add $280 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$274 = add $275 $279
	add $t2, $t4, $t2
#	$264 = add $265 $274
	add $t2, $t3, $t2
#	$284 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$286 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$285 = add $286 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$283 = add $284 $285
	add $t3, $t4, $t3
#	$287 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$282 = sub $283 $287
	sub $t5, $t3, $t4
#	$291 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$290 = add $291 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$292 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$289 = sub $290 $292
	sub $t4, $t3, $t4
#	$294 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$293 = add $294 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$288 = add $289 $293
	add $t3, $t4, $t3
#	$281 = add $282 $288
	add $t3, $t5, $t3
#	$263 = sub $264 $281
	sub $t4, $t2, $t3
#	$299 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$301 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$300 = add $301 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$298 = add $299 $300
	add $t5, $t2, $t3
#	$303 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$305 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$304 = add $305 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$302 = add $303 $304
	add $t2, $t3, $t2
#	$297 = sub $298 $302
	sub $t2, $t5, $t2
#	$308 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$310 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$309 = add $310 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$307 = add $308 $309
	add $t5, $t5, $t3
#	$311 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$306 = sub $307 $311
	sub $t3, $t5, $t3
#	$296 = sub $297 $306
	sub $t5, $t2, $t3
#	$316 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$315 = add $316 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$317 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$314 = sub $315 $317
	sub $t3, $t2, $t3
#	$319 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$318 = add $319 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$313 = add $314 $318
	add $t2, $t3, $t2
#	$322 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$324 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t6, $t0, $t1
#	$323 = add $324 $53
	lw $t1, global_53
	add $t6, $t6, $t1
#	$321 = add $322 $323
	add $t6, $t3, $t6
#	$325 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$320 = sub $321 $325
	sub $t3, $t6, $t3
#	$312 = sub $313 $320
	sub $t2, $t2, $t3
#	$295 = add $296 $312
	add $t2, $t5, $t2
#	$262 = sub $263 $295
	sub $t4, $t4, $t2
#	$332 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$331 = add $332 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$333 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$330 = sub $331 $333
	sub $t2, $t3, $t2
#	$336 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$335 = add $336 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$337 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$334 = sub $335 $337
	sub $t3, $t3, $t5
#	$329 = add $330 $334
	add $t3, $t2, $t3
#	$341 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$340 = add $341 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$342 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$339 = sub $340 $342
	sub $t5, $t2, $t5
#	$344 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$343 = add $344 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$338 = add $339 $343
	add $t2, $t5, $t2
#	$328 = add $329 $338
	add $t6, $t3, $t2
#	$348 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$350 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$349 = add $350 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$347 = add $348 $349
	add $t2, $t3, $t2
#	$351 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$346 = sub $347 $351
	sub $t2, $t2, $t3
#	$355 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$354 = add $355 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$356 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$353 = sub $354 $356
	sub $t5, $t3, $t5
#	$358 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$357 = add $358 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$352 = add $353 $357
	add $t3, $t5, $t3
#	$345 = add $346 $352
	add $t2, $t2, $t3
#	$327 = sub $328 $345
	sub $t7, $t6, $t2
#	$363 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$365 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$364 = add $365 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$362 = add $363 $364
	add $t3, $t3, $t2
#	$366 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$361 = sub $362 $366
	sub $t3, $t3, $t2
#	$370 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$369 = add $370 $53
	lw $t1, global_53
	add $t5, $t2, $t1
#	$371 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$368 = sub $369 $371
	sub $t5, $t5, $t2
#	$373 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$372 = add $373 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$367 = add $368 $372
	add $t2, $t5, $t2
#	$360 = add $361 $367
	add $t5, $t3, $t2
#	$377 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$379 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$378 = add $379 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$376 = add $377 $378
	add $t3, $t2, $t3
#	$380 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$375 = sub $376 $380
	sub $t2, $t3, $t2
#	$384 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$383 = add $384 $53
	lw $t1, global_53
	add $t6, $t3, $t1
#	$385 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$382 = sub $383 $385
	sub $t3, $t6, $t3
#	$387 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t6, $t0, $t1
#	$386 = add $387 $53
	lw $t1, global_53
	add $t6, $t6, $t1
#	$381 = add $382 $386
	add $t3, $t3, $t6
#	$374 = add $375 $381
	add $t2, $t2, $t3
#	$359 = sub $360 $374
	sub $t2, $t5, $t2
#	$326 = sub $327 $359
	sub $t2, $t7, $t2
#	$261 = add $262 $326
	add $t3, $t4, $t2
#	$394 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$396 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$395 = add $396 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$393 = add $394 $395
	add $t4, $t4, $t2
#	$398 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$400 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t5, $t0, $t1
#	$399 = add $400 $53
	lw $t1, global_53
	add $t5, $t5, $t1
#	$397 = add $398 $399
	add $t2, $t2, $t5
#	$392 = sub $393 $397
	sub $t4, $t4, $t2
#	$403 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$405 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$404 = add $405 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$402 = add $403 $404
	add $t2, $t5, $t2
#	$406 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$401 = sub $402 $406
	sub $t2, $t2, $t5
#	$391 = sub $392 $401
	sub $t6, $t4, $t2
#	$411 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$410 = add $411 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$412 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$409 = sub $410 $412
	sub $t2, $t4, $t2
#	$414 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$413 = add $414 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$408 = add $409 $413
	add $t5, $t2, $t4
#	$417 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$419 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$418 = add $419 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$416 = add $417 $418
	add $t4, $t2, $t4
#	$420 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$415 = sub $416 $420
	sub $t2, $t4, $t2
#	$407 = sub $408 $415
	sub $t2, $t5, $t2
#	$390 = add $391 $407
	add $t5, $t6, $t2
#	$426 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$425 = add $426 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$427 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$424 = sub $425 $427
	sub $t2, $t4, $t2
#	$429 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$428 = add $429 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$423 = add $424 $428
	add $t6, $t2, $t4
#	$432 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$434 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$433 = add $434 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$431 = add $432 $433
	add $t4, $t4, $t2
#	$435 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$430 = sub $431 $435
	sub $t2, $t4, $t2
#	$422 = sub $423 $430
	sub $t7, $t6, $t2
#	$440 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$439 = add $440 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$441 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$438 = sub $439 $441
	sub $t4, $t2, $t4
#	$443 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$442 = add $443 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$437 = add $438 $442
	add $t4, $t4, $t2
#	$446 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$448 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t6, $t0, $t1
#	$447 = add $448 $53
	lw $t1, global_53
	add $t6, $t6, $t1
#	$445 = add $446 $447
	add $t2, $t2, $t6
#	$449 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t6, $t0, $t1
#	$444 = sub $445 $449
	sub $t2, $t2, $t6
#	$436 = sub $437 $444
	sub $t2, $t4, $t2
#	$421 = add $422 $436
	add $t2, $t7, $t2
#	$389 = add $390 $421
	add $s0, $t5, $t2
#	$456 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$455 = add $456 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$457 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$454 = sub $455 $457
	sub $t2, $t2, $t4
#	$460 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$459 = add $460 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$461 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t5, $t0, $t1
#	$458 = sub $459 $461
	sub $t4, $t4, $t5
#	$453 = add $454 $458
	add $t5, $t2, $t4
#	$465 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$464 = add $465 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$466 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$463 = sub $464 $466
	sub $t4, $t2, $t4
#	$468 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$467 = add $468 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$462 = add $463 $467
	add $t2, $t4, $t2
#	$452 = add $453 $462
	add $t5, $t5, $t2
#	$472 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$474 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$473 = add $474 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$471 = add $472 $473
	add $t2, $t4, $t2
#	$475 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$470 = sub $471 $475
	sub $t2, $t2, $t4
#	$479 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$478 = add $479 $53
	lw $t1, global_53
	add $t6, $t4, $t1
#	$480 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$477 = sub $478 $480
	sub $t6, $t6, $t4
#	$482 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$481 = add $482 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$476 = add $477 $481
	add $t4, $t6, $t4
#	$469 = add $470 $476
	add $t2, $t2, $t4
#	$451 = sub $452 $469
	sub $t6, $t5, $t2
#	$487 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$489 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$488 = add $489 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$486 = add $487 $488
	add $t2, $t4, $t2
#	$490 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$485 = sub $486 $490
	sub $t5, $t2, $t4
#	$494 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$493 = add $494 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$495 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$492 = sub $493 $495
	sub $t4, $t2, $t4
#	$497 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$496 = add $497 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$491 = add $492 $496
	add $t2, $t4, $t2
#	$484 = add $485 $491
	add $t7, $t5, $t2
#	$501 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$503 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$502 = add $503 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$500 = add $501 $502
	add $t2, $t4, $t2
#	$504 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$499 = sub $500 $504
	sub $t5, $t2, $t4
#	$508 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$507 = add $508 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$509 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$506 = sub $507 $509
	sub $t2, $t4, $t2
#	$511 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$510 = add $511 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$505 = add $506 $510
	add $t2, $t2, $t4
#	$498 = add $499 $505
	add $t2, $t5, $t2
#	$483 = sub $484 $498
	sub $t2, $t7, $t2
#	$450 = sub $451 $483
	sub $t2, $t6, $t2
#	$388 = add $389 $450
	add $t2, $s0, $t2
#	$260 = sub $261 $388
	sub $t2, $t3, $t2
#	$53 = move $260
	sw $t2, global_53
#	$521 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$520 = add $521 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$522 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$519 = sub $520 $522
	sub $t2, $t2, $t3
#	$525 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$524 = add $525 $53
	lw $t1, global_53
	add $t4, $t3, $t1
#	$526 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$523 = sub $524 $526
	sub $t3, $t4, $t3
#	$518 = add $519 $523
	add $t3, $t2, $t3
#	$530 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$529 = add $530 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$531 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$528 = sub $529 $531
	sub $t4, $t2, $t4
#	$533 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$532 = add $533 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$527 = add $528 $532
	add $t2, $t4, $t2
#	$517 = add $518 $527
	add $t4, $t3, $t2
#	$537 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$539 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$538 = add $539 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$536 = add $537 $538
	add $t2, $t2, $t3
#	$540 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$535 = sub $536 $540
	sub $t5, $t2, $t3
#	$544 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$543 = add $544 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$545 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$542 = sub $543 $545
	sub $t2, $t3, $t2
#	$547 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$546 = add $547 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$541 = add $542 $546
	add $t2, $t2, $t3
#	$534 = add $535 $541
	add $t2, $t5, $t2
#	$516 = sub $517 $534
	sub $t6, $t4, $t2
#	$552 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$554 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$553 = add $554 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$551 = add $552 $553
	add $t2, $t3, $t2
#	$556 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$558 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$557 = add $558 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$555 = add $556 $557
	add $t3, $t4, $t3
#	$550 = sub $551 $555
	sub $t4, $t2, $t3
#	$561 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$563 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$562 = add $563 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$560 = add $561 $562
	add $t2, $t2, $t3
#	$564 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$559 = sub $560 $564
	sub $t2, $t2, $t3
#	$549 = sub $550 $559
	sub $t5, $t4, $t2
#	$569 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$568 = add $569 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$570 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$567 = sub $568 $570
	sub $t3, $t3, $t2
#	$572 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$571 = add $572 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$566 = add $567 $571
	add $t3, $t3, $t2
#	$575 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$577 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$576 = add $577 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$574 = add $575 $576
	add $t4, $t4, $t2
#	$578 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$573 = sub $574 $578
	sub $t2, $t4, $t2
#	$565 = sub $566 $573
	sub $t2, $t3, $t2
#	$548 = add $549 $565
	add $t2, $t5, $t2
#	$515 = sub $516 $548
	sub $t7, $t6, $t2
#	$585 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$584 = add $585 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$586 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$583 = sub $584 $586
	sub $t3, $t2, $t3
#	$589 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$588 = add $589 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$590 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$587 = sub $588 $590
	sub $t2, $t4, $t2
#	$582 = add $583 $587
	add $t4, $t3, $t2
#	$594 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$593 = add $594 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$595 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$592 = sub $593 $595
	sub $t3, $t2, $t3
#	$597 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$596 = add $597 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$591 = add $592 $596
	add $t2, $t3, $t2
#	$581 = add $582 $591
	add $t5, $t4, $t2
#	$601 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$603 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$602 = add $603 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$600 = add $601 $602
	add $t3, $t3, $t2
#	$604 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$599 = sub $600 $604
	sub $t4, $t3, $t2
#	$608 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$607 = add $608 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$609 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$606 = sub $607 $609
	sub $t3, $t3, $t2
#	$611 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$610 = add $611 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$605 = add $606 $610
	add $t2, $t3, $t2
#	$598 = add $599 $605
	add $t2, $t4, $t2
#	$580 = sub $581 $598
	sub $t5, $t5, $t2
#	$616 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$618 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$617 = add $618 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$615 = add $616 $617
	add $t2, $t3, $t2
#	$619 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$614 = sub $615 $619
	sub $t3, $t2, $t3
#	$623 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$622 = add $623 $53
	lw $t1, global_53
	add $t4, $t2, $t1
#	$624 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$621 = sub $622 $624
	sub $t4, $t4, $t2
#	$626 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$625 = add $626 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$620 = add $621 $625
	add $t2, $t4, $t2
#	$613 = add $614 $620
	add $t4, $t3, $t2
#	$630 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$632 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$631 = add $632 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$629 = add $630 $631
	add $t3, $t3, $t2
#	$633 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$628 = sub $629 $633
	sub $t6, $t3, $t2
#	$637 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$636 = add $637 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$638 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$635 = sub $636 $638
	sub $t3, $t3, $t2
#	$640 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$639 = add $640 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$634 = add $635 $639
	add $t2, $t3, $t2
#	$627 = add $628 $634
	add $t2, $t6, $t2
#	$612 = sub $613 $627
	sub $t2, $t4, $t2
#	$579 = sub $580 $612
	sub $t2, $t5, $t2
#	$514 = add $515 $579
	add $s0, $t7, $t2
#	$647 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$649 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$648 = add $649 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$646 = add $647 $648
	add $t3, $t3, $t2
#	$651 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$653 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$652 = add $653 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$650 = add $651 $652
	add $t2, $t4, $t2
#	$645 = sub $646 $650
	sub $t4, $t3, $t2
#	$656 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$658 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$657 = add $658 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$655 = add $656 $657
	add $t3, $t3, $t2
#	$659 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$654 = sub $655 $659
	sub $t2, $t3, $t2
#	$644 = sub $645 $654
	sub $t4, $t4, $t2
#	$664 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$663 = add $664 $53
	lw $t1, global_53
	add $t3, $t2, $t1
#	$665 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$662 = sub $663 $665
	sub $t3, $t3, $t2
#	$667 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$666 = add $667 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$661 = add $662 $666
	add $t5, $t3, $t2
#	$670 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$672 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$671 = add $672 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$669 = add $670 $671
	add $t3, $t3, $t2
#	$673 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$668 = sub $669 $673
	sub $t2, $t3, $t2
#	$660 = sub $661 $668
	sub $t2, $t5, $t2
#	$643 = add $644 $660
	add $t5, $t4, $t2
#	$679 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$678 = add $679 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$680 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$677 = sub $678 $680
	sub $t3, $t2, $t3
#	$682 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$681 = add $682 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$676 = add $677 $681
	add $t3, $t3, $t2
#	$685 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$687 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$686 = add $687 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$684 = add $685 $686
	add $t2, $t2, $t4
#	$688 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$683 = sub $684 $688
	sub $t2, $t2, $t4
#	$675 = sub $676 $683
	sub $t4, $t3, $t2
#	$693 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$692 = add $693 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$694 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$691 = sub $692 $694
	sub $t3, $t2, $t3
#	$696 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$695 = add $696 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$690 = add $691 $695
	add $t6, $t3, $t2
#	$699 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$701 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t2, $t0, $t1
#	$700 = add $701 $53
	lw $t1, global_53
	add $t2, $t2, $t1
#	$698 = add $699 $700
	add $t3, $t3, $t2
#	$702 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t2, $t0, $t1
#	$697 = sub $698 $702
	sub $t2, $t3, $t2
#	$689 = sub $690 $697
	sub $t2, $t6, $t2
#	$674 = add $675 $689
	add $t2, $t4, $t2
#	$642 = add $643 $674
	add $t2, $t5, $t2
#	$709 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$708 = add $709 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$710 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$707 = sub $708 $710
	sub $t3, $t3, $t4
#	$713 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$712 = add $713 $53
	lw $t1, global_53
	add $t5, $t4, $t1
#	$714 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$711 = sub $712 $714
	sub $t4, $t5, $t4
#	$706 = add $707 $711
	add $t5, $t3, $t4
#	$718 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$717 = add $718 $53
	lw $t1, global_53
	add $t4, $t3, $t1
#	$719 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$716 = sub $717 $719
	sub $t4, $t4, $t3
#	$721 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$720 = add $721 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$715 = add $716 $720
	add $t3, $t4, $t3
#	$705 = add $706 $715
	add $t5, $t5, $t3
#	$725 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$727 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$726 = add $727 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$724 = add $725 $726
	add $t3, $t3, $t4
#	$728 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$723 = sub $724 $728
	sub $t6, $t3, $t4
#	$732 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$731 = add $732 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$733 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$730 = sub $731 $733
	sub $t3, $t3, $t4
#	$735 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$734 = add $735 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$729 = add $730 $734
	add $t3, $t3, $t4
#	$722 = add $723 $729
	add $t3, $t6, $t3
#	$704 = sub $705 $722
	sub $t7, $t5, $t3
#	$740 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t3, $t0, $t1
#	$742 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t4, $t0, $t1
#	$741 = add $742 $53
	lw $t1, global_53
	add $t4, $t4, $t1
#	$739 = add $740 $741
	add $t3, $t3, $t4
#	$743 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$738 = sub $739 $743
	sub $t5, $t3, $t4
#	$747 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$746 = add $747 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$748 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$745 = sub $746 $748
	sub $t4, $t3, $t4
#	$750 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$749 = add $750 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$744 = add $745 $749
	add $t3, $t4, $t3
#	$737 = add $738 $744
	add $t6, $t5, $t3
#	$754 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$756 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$755 = add $756 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$753 = add $754 $755
	add $t3, $t4, $t3
#	$757 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$752 = sub $753 $757
	sub $t5, $t3, $t4
#	$761 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$760 = add $761 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$762 = add $52 $53
	lw $t0, global_52
	lw $t1, global_53
	add $t4, $t0, $t1
#	$759 = sub $760 $762
	sub $t4, $t3, $t4
#	$764 = sub $54 $52
	lw $t0, global_54
	lw $t1, global_52
	sub $t3, $t0, $t1
#	$763 = add $764 $53
	lw $t1, global_53
	add $t3, $t3, $t1
#	$758 = add $759 $763
	add $t3, $t4, $t3
#	$751 = add $752 $758
	add $t3, $t5, $t3
#	$736 = sub $737 $751
	sub $t3, $t6, $t3
#	$703 = sub $704 $736
	sub $t3, $t7, $t3
#	$641 = add $642 $703
	add $t2, $t2, $t3
#	$513 = sub $514 $641
	sub $t2, $s0, $t2
#	$54 = move $513
	sw $t2, global_54
#	jump %WhileLoop43
	b _WhileLoop43
#	%OutOfWhile1
_OutOfWhile1:
#	$765 = call toString $52
	lw $a0, global_52
	jal func__toString
	move $t2, $v0
#	$767 = call stringConcatenate $765 " "
	move $a0, $t2
	la $a1, string_766
	jal func__stringConcatenate
	move $t2, $v0
#	$768 = call toString $53
	lw $a0, global_53
	jal func__toString
	move $t3, $v0
#	$769 = call stringConcatenate $767 $768
	move $a0, $t2
	move $a1, $t3
	jal func__stringConcatenate
	move $t2, $v0
#	$771 = call stringConcatenate $769 " "
	move $a0, $t2
	la $a1, string_770
	jal func__stringConcatenate
	move $t2, $v0
#	$772 = call toString $54
	lw $a0, global_54
	jal func__toString
	move $t3, $v0
#	$773 = call stringConcatenate $771 $772
	move $a0, $t2
	move $a1, $t3
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall println $773
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl42
	b _EndOfFunctionDecl42
#	%EndOfFunctionDecl42
_EndOfFunctionDecl42:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $s1, 68($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 3208
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_52:
.space 4
.align 2
global_53:
.space 4
.align 2
global_54:
.space 4
.align 2
.word 1
string_766:
.asciiz " "
.align 2
.word 1
string_770:
.asciiz " "
.align 2
