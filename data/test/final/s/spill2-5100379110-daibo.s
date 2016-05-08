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
_getcount:
	sub $sp, $sp, 144
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl61
_BeginOfFunctionDecl61:
#	$0 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$1 = add $130 $0
	lw $t0, 140($sp)
	add $t2, $t0, $t2
#	$2 = load 4 $1 0
	lw $t0, 0($t2)
	sw $t0, 136($sp)
#	$2 = add $2 1
	lw $t0, 136($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 136($sp)
#	store 4 $1 $2 0
	lw $t0, 136($sp)
	sw $t0, 0($t2)
#	ret $2
	lw $v0, 136($sp)
#	jump %EndOfFunctionDecl62
	b _EndOfFunctionDecl62
#	%EndOfFunctionDecl62
_EndOfFunctionDecl62:
	lw $t2, 40($sp)
	add $sp, $sp, 144
	jr $ra
main:
	sub $sp, $sp, 8348
	sw $s0, 64($sp)
	sw $t8, 96($sp)
	sw $fp, 124($sp)
	sw $t6, 56($sp)
	sw $s7, 92($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t9, 100($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $t4, 48($sp)
	sw $gp, 112($sp)
	sw $k1, 108($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $k0, 104($sp)
	sw $t5, 52($sp)
	sw $s4, 80($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl63
_BeginOfFunctionDecl63:
#	$6 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$6 = add $6 4
	li $t1, 4
	add $t2, $t2, $t1
#	$5 = alloc $6
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $5 1 0
	li $t0, 1
	sw $t0, 0($t2)
#	$5 = add $5 4
	li $t1, 4
	add $t2, $t2, $t1
#	$4 = move $5
#	$129 = move $4
	sw $t2, global_129
#	$8 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$9 = add $129 $8
	lw $t0, global_129
	add $t2, $t0, $t2
#	store 4 $9 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$11 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$131 = move $11
	sw $t2, 424($sp)
#	$13 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$132 = move $13
	sw $t2, 5352($sp)
#	$15 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$133 = move $15
	sw $t2, 3784($sp)
#	$17 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$134 = move $17
	sw $t2, 2252($sp)
#	$19 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$135 = move $19
	sw $t2, 6860($sp)
#	$21 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$136 = move $21
	sw $t2, 2028($sp)
#	$23 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$137 = move $23
	sw $t2, 2648($sp)
#	$25 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$138 = move $25
	sw $t2, 4848($sp)
#	$27 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$139 = move $27
	sw $t2, 5528($sp)
#	$29 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$140 = move $29
	sw $t2, 2560($sp)
#	$31 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$141 = move $31
	sw $t2, 3484($sp)
#	$33 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$142 = move $33
	sw $t2, 1972($sp)
#	$35 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$143 = move $35
	sw $t2, 6996($sp)
#	$37 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$144 = move $37
	sw $t2, 1888($sp)
#	$39 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$145 = move $39
	sw $t2, 2600($sp)
#	$41 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$146 = move $41
	sw $t2, 616($sp)
#	$43 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$147 = move $43
	move $t9, $t2
#	$45 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$148 = move $45
	sw $t2, 7696($sp)
#	$47 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$149 = move $47
	sw $t2, 6292($sp)
#	$49 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$150 = move $49
	sw $t2, 1128($sp)
#	$51 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$151 = move $51
	sw $t2, 2500($sp)
#	$53 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$152 = move $53
	sw $t2, 2400($sp)
#	$55 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$153 = move $55
	sw $t2, 3628($sp)
#	$57 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$154 = move $57
	sw $t2, 3216($sp)
#	$59 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$155 = move $59
	sw $t2, 6196($sp)
#	$61 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$156 = move $61
	sw $t2, 452($sp)
#	$63 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$157 = move $63
	sw $t2, 324($sp)
#	$65 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$158 = move $65
	sw $t2, 2120($sp)
#	$67 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$159 = move $67
	sw $t2, 4388($sp)
#	$69 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$160 = move $69
	sw $t2, 7304($sp)
#	$71 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$161 = move $71
	sw $t2, 3752($sp)
#	$73 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$162 = move $73
	sw $t2, 4336($sp)
#	$75 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$163 = move $75
	sw $t2, 7432($sp)
#	$77 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$164 = move $77
	sw $t2, 620($sp)
#	$79 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$165 = move $79
	sw $t2, 3712($sp)
#	$81 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$166 = move $81
	sw $t2, 4576($sp)
#	$83 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$167 = move $83
	move $fp, $t2
#	$85 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$168 = move $85
	sw $t2, 6024($sp)
#	$87 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$169 = move $87
	sw $t2, 7612($sp)
#	$89 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$170 = move $89
	sw $t2, 2208($sp)
#	$91 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$171 = move $91
	sw $t2, 7672($sp)
#	$93 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$172 = move $93
	sw $t2, 6276($sp)
#	$95 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$173 = move $95
	sw $t2, 3032($sp)
#	$97 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$174 = move $97
	sw $t2, 2180($sp)
#	$99 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$175 = move $99
	sw $t2, 2928($sp)
#	$101 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$176 = move $101
	sw $t2, 5000($sp)
#	$103 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$177 = move $103
	sw $t2, 2112($sp)
#	$105 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$178 = move $105
	sw $t2, 4800($sp)
#	$107 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$179 = move $107
	sw $t2, 564($sp)
#	$109 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$180 = move $109
	sw $t2, 548($sp)
#	$111 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$181 = move $111
	sw $t2, 1056($sp)
#	$113 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$182 = move $113
	sw $t2, 7284($sp)
#	$115 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$183 = move $115
	sw $t2, 1632($sp)
#	$117 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$184 = move $117
	sw $t2, 7032($sp)
#	$119 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8056($sp)
#	$185 = move $119
	lw $t0, 8056($sp)
	sw $t0, 300($sp)
#	$121 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$186 = move $121
	sw $t2, 5492($sp)
#	$123 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$187 = move $123
	sw $t2, 4912($sp)
#	$125 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$188 = move $125
	sw $t2, 684($sp)
#	$127 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$189 = move $127
	sw $t2, 3296($sp)
#	$129 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$190 = move $129
	sw $t2, 7360($sp)
#	$131 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$191 = move $131
	sw $t2, 5804($sp)
#	$133 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$192 = move $133
	sw $t2, 5348($sp)
#	$135 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$193 = move $135
	sw $t2, 3824($sp)
#	$137 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$194 = move $137
	sw $t2, 2836($sp)
#	$139 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$195 = move $139
	sw $t2, 1616($sp)
#	$141 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$196 = move $141
	sw $t2, 4776($sp)
#	$143 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$197 = move $143
	sw $t2, 920($sp)
#	$145 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$198 = move $145
	sw $t2, 552($sp)
#	$147 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$199 = move $147
	sw $t2, 6800($sp)
#	$149 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$200 = move $149
	sw $t2, 4696($sp)
#	$151 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$201 = move $151
	sw $t2, 712($sp)
#	$153 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8288($sp)
#	$202 = move $153
	lw $t0, 8288($sp)
	sw $t0, 3852($sp)
#	$155 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$203 = move $155
	sw $t2, 1736($sp)
#	$157 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$204 = move $157
	sw $t2, 908($sp)
#	$159 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$205 = move $159
	sw $t2, 4616($sp)
#	$161 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$206 = move $161
	sw $t2, 2088($sp)
#	$163 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$207 = move $163
	sw $t2, 4864($sp)
#	$165 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$208 = move $165
	sw $t2, 5760($sp)
#	$167 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$209 = move $167
	sw $t2, 1704($sp)
#	$169 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$210 = move $169
	sw $t2, 392($sp)
#	$171 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$211 = move $171
	sw $t2, 3236($sp)
#	$173 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$212 = move $173
	sw $t2, 6384($sp)
#	$175 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$213 = move $175
	sw $t2, 3948($sp)
#	$177 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$214 = move $177
	sw $t2, 848($sp)
#	$179 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8040($sp)
#	$215 = move $179
	lw $t0, 8040($sp)
	sw $t0, 7108($sp)
#	$181 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$216 = move $181
	sw $t2, 2076($sp)
#	$183 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$217 = move $183
	sw $t2, 2040($sp)
#	$185 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$218 = move $185
	sw $t2, 5180($sp)
#	$187 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$219 = move $187
	sw $t2, 1136($sp)
#	$189 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$220 = move $189
	sw $t2, 444($sp)
#	$191 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$221 = move $191
	sw $t2, 2124($sp)
#	$193 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$222 = move $193
	sw $t2, 3396($sp)
#	$195 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$223 = move $195
	sw $t2, 5116($sp)
#	$197 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$224 = move $197
	sw $t2, 4748($sp)
#	$199 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$225 = move $199
	sw $t2, 7176($sp)
#	$201 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$226 = move $201
	sw $t2, 1840($sp)
#	$203 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$227 = move $203
	sw $t2, 4488($sp)
#	$205 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$228 = move $205
	sw $t2, 5224($sp)
#	$207 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$229 = move $207
	sw $t2, 3064($sp)
#	$209 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$230 = move $209
	sw $t2, 4936($sp)
#	$211 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$231 = move $211
	sw $t2, 3952($sp)
#	$213 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$232 = move $213
	sw $t2, 4648($sp)
#	$215 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$233 = move $215
	sw $t2, 5192($sp)
#	$217 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$234 = move $217
	sw $t2, 536($sp)
#	$219 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$235 = move $219
	sw $t2, 1796($sp)
#	$221 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$236 = move $221
	sw $t2, 6876($sp)
#	$223 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8108($sp)
#	$237 = move $223
	lw $t0, 8108($sp)
	sw $t0, 7292($sp)
#	$225 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$238 = move $225
	sw $t2, 2992($sp)
#	$227 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8228($sp)
#	$239 = move $227
	lw $t0, 8228($sp)
	sw $t0, 824($sp)
#	$229 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$240 = move $229
	sw $t2, 7500($sp)
#	$231 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$241 = move $231
	sw $t2, 6116($sp)
#	$233 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$242 = move $233
	sw $t2, 3716($sp)
#	$235 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$243 = move $235
	sw $t2, 5424($sp)
#	$237 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$244 = move $237
	sw $t2, 1376($sp)
#	$239 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$245 = move $239
	sw $t2, 4320($sp)
#	$241 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$246 = move $241
	sw $t2, 3460($sp)
#	$243 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$247 = move $243
	sw $t2, 7456($sp)
#	$245 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$248 = move $245
	sw $t2, 1148($sp)
#	$247 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$249 = move $247
	sw $t2, 3052($sp)
#	$249 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$250 = move $249
	sw $t2, 5464($sp)
#	$251 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$251 = move $251
	sw $t2, 932($sp)
#	$253 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$252 = move $253
	sw $t2, 6076($sp)
#	$255 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$253 = move $255
	sw $t2, 1480($sp)
#	$257 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$254 = move $257
	move $t7, $t2
#	$259 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$255 = move $259
	sw $t2, 5476($sp)
#	$261 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$256 = move $261
	sw $t2, 4192($sp)
#	$263 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$257 = move $263
	sw $t2, 5908($sp)
#	$265 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$258 = move $265
	sw $t2, 4384($sp)
#	$267 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$259 = move $267
	sw $t2, 3024($sp)
#	$269 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$260 = move $269
	sw $t2, 4532($sp)
#	$271 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$261 = move $271
	sw $t2, 5420($sp)
#	$273 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$262 = move $273
	move $s0, $t2
#	$275 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$263 = move $275
	sw $t2, 4500($sp)
#	$277 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$264 = move $277
	move $s6, $t2
#	$279 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$265 = move $279
	sw $t2, 3656($sp)
#	$281 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$266 = move $281
	sw $t2, 6324($sp)
#	$283 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$267 = move $283
	sw $t2, 6756($sp)
#	$285 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$268 = move $285
	sw $t2, 2848($sp)
#	$287 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$269 = move $287
	sw $t2, 7116($sp)
#	$289 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$270 = move $289
	sw $t2, 1252($sp)
#	$291 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$271 = move $291
	sw $t2, 7244($sp)
#	$293 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$272 = move $293
	sw $t2, 2540($sp)
#	$295 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$273 = move $295
	sw $t2, 3536($sp)
#	$297 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$274 = move $297
	sw $t2, 1084($sp)
#	$299 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$275 = move $299
	sw $t2, 3800($sp)
#	$301 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$276 = move $301
	sw $t2, 3836($sp)
#	$303 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$277 = move $303
	sw $t2, 5536($sp)
#	$305 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$278 = move $305
	sw $t2, 1424($sp)
#	$307 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$279 = move $307
	sw $t2, 2264($sp)
#	$309 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$280 = move $309
	sw $t2, 2204($sp)
#	$311 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$281 = move $311
	sw $t2, 5660($sp)
#	$313 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$282 = move $313
	move $s4, $t2
#	$315 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$283 = move $315
	sw $t2, 2796($sp)
#	$317 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$284 = move $317
	sw $t2, 5184($sp)
#	$319 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$285 = move $319
	sw $t2, 3552($sp)
#	$321 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$286 = move $321
	sw $t2, 1960($sp)
#	$323 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$287 = move $323
	sw $t2, 2388($sp)
#	$325 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$288 = move $325
	sw $t2, 7656($sp)
#	$327 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$289 = move $327
	sw $t2, 2912($sp)
#	$329 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8176($sp)
#	$290 = move $329
	lw $t0, 8176($sp)
	sw $t0, 1468($sp)
#	$331 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$291 = move $331
	sw $t2, 6240($sp)
#	$333 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$292 = move $333
	sw $t2, 4668($sp)
#	$335 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$293 = move $335
	sw $t2, 936($sp)
#	$337 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$294 = move $337
	sw $t2, 996($sp)
#	$339 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$295 = move $339
	sw $t2, 2724($sp)
#	$341 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$296 = move $341
	sw $t2, 2368($sp)
#	$343 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$297 = move $343
	sw $t2, 136($sp)
#	$345 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$298 = move $345
	sw $t2, 3556($sp)
#	$347 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$299 = move $347
	sw $t2, 5296($sp)
#	$349 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$300 = move $349
	sw $t2, 4948($sp)
#	$351 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$301 = move $351
	sw $t2, 5160($sp)
#	$353 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$302 = move $353
	sw $t2, 2964($sp)
#	$355 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$303 = move $355
	sw $t2, 5452($sp)
#	$357 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$304 = move $357
	sw $t2, 1860($sp)
#	$359 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$305 = move $359
	sw $t2, 2332($sp)
#	$361 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$306 = move $361
	sw $t2, 5672($sp)
#	$363 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$307 = move $363
	sw $t2, 6912($sp)
#	$365 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$308 = move $365
	sw $t2, 1280($sp)
#	$367 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$309 = move $367
	move $t6, $t2
#	$369 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$310 = move $369
	sw $t2, 5128($sp)
#	$371 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$311 = move $371
	sw $t2, 6552($sp)
#	$373 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$312 = move $373
	sw $t2, 7000($sp)
#	$375 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$313 = move $375
	sw $t2, 2780($sp)
#	$377 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$314 = move $377
	move $t4, $t2
#	$379 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$315 = move $379
	sw $t2, 1192($sp)
#	$381 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$316 = move $381
	sw $t2, 2700($sp)
#	$383 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$317 = move $383
	sw $t2, 2472($sp)
#	$385 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$318 = move $385
	sw $t2, 1540($sp)
#	$387 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$319 = move $387
	sw $t2, 2580($sp)
#	$389 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$320 = move $389
	sw $t2, 5148($sp)
#	$391 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$321 = move $391
	sw $t2, 3684($sp)
#	$393 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$322 = move $393
	sw $t2, 460($sp)
#	$395 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$323 = move $395
	sw $t2, 7200($sp)
#	$397 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$324 = move $397
	sw $t2, 7336($sp)
#	$399 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$325 = move $399
	sw $t2, 5232($sp)
#	$401 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$326 = move $401
	move $k1, $t2
#	$403 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$327 = move $403
	sw $t2, 3704($sp)
#	$405 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$328 = move $405
	sw $t2, 1412($sp)
#	$407 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$329 = move $407
	sw $t2, 4128($sp)
#	$409 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$330 = move $409
	sw $t2, 2932($sp)
#	$411 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$331 = move $411
	sw $t2, 2676($sp)
#	$413 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$332 = move $413
	sw $t2, 3644($sp)
#	$415 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$333 = move $415
	sw $t2, 172($sp)
#	$417 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$334 = move $417
	sw $t2, 7092($sp)
#	$419 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$335 = move $419
	sw $t2, 6028($sp)
#	$421 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$336 = move $421
	move $t5, $t2
#	$423 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$337 = move $423
	sw $t2, 5516($sp)
#	$425 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t2, $v0
#	$338 = move $425
#	$427 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$339 = move $427
	sw $t3, 5624($sp)
#	$429 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$340 = move $429
	sw $t3, 5836($sp)
#	$431 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$341 = move $431
	sw $t3, 5828($sp)
#	$433 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$342 = move $433
	sw $t3, 584($sp)
#	$435 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$343 = move $435
	sw $t3, 216($sp)
#	$437 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$344 = move $437
	move $s1, $t3
#	$439 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$345 = move $439
	sw $t3, 1016($sp)
#	$441 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$346 = move $441
	sw $t3, 2256($sp)
#	$443 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$347 = move $443
	sw $t3, 2768($sp)
#	$445 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$348 = move $445
	sw $t3, 1776($sp)
#	$447 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$349 = move $447
	sw $t3, 6684($sp)
#	$449 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$350 = move $449
	sw $t3, 288($sp)
#	$451 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$351 = move $451
	sw $t3, 456($sp)
#	$453 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$352 = move $453
	sw $t3, 6380($sp)
#	$455 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$353 = move $455
	sw $t3, 276($sp)
#	$457 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$354 = move $457
	sw $t3, 1356($sp)
#	$459 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$355 = move $459
	sw $t3, 4836($sp)
#	$461 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	sw $v0, 8344($sp)
#	$356 = move $461
	lw $t0, 8344($sp)
	sw $t0, 656($sp)
#	$463 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$357 = move $463
	sw $t3, 6540($sp)
#	$465 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$358 = move $465
	sw $t3, 3528($sp)
#	$467 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$359 = move $467
	sw $t3, 4112($sp)
#	$469 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$360 = move $469
	sw $t3, 2128($sp)
#	$471 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$361 = move $471
	sw $t3, 1848($sp)
#	$473 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$362 = move $473
	sw $t3, 7212($sp)
#	$475 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$363 = move $475
	move $t8, $t3
#	$477 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$364 = move $477
	move $k0, $t3
#	$479 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$365 = move $479
	sw $t3, 284($sp)
#	$481 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$366 = move $481
	sw $t3, 6396($sp)
#	$483 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$367 = move $483
	move $s5, $t3
#	$485 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$368 = move $485
	sw $t3, 1208($sp)
#	$487 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$369 = move $487
	sw $t3, 3516($sp)
#	$489 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$370 = move $489
	sw $t3, 3492($sp)
#	$491 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$371 = move $491
	sw $t3, 6412($sp)
#	$493 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$372 = move $493
	sw $t3, 7636($sp)
#	$495 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$373 = move $495
	sw $t3, 4292($sp)
#	$497 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$374 = move $497
	sw $t3, 4308($sp)
#	$499 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$375 = move $499
	sw $t3, 744($sp)
#	$501 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$376 = move $501
	sw $t3, 3636($sp)
#	$503 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$377 = move $503
	sw $t3, 1460($sp)
#	$505 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$378 = move $505
	sw $t3, 352($sp)
#	$507 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$379 = move $507
	move $gp, $t3
#	$509 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$380 = move $509
	sw $t3, 6724($sp)
#	$511 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$381 = move $511
	move $s3, $t3
#	$513 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$382 = move $513
	move $s7, $t3
#	$515 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$383 = move $515
	sw $t3, 1548($sp)
#	$517 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$384 = move $517
	sw $t3, 4556($sp)
#	$519 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$385 = move $519
	move $s2, $t3
#	$521 = call getcount $129
	lw $t0, global_129
	sw $t0, -4($sp)
	jal _getcount
	move $t3, $v0
#	$386 = move $521
	sw $t3, 1400($sp)
#	$522 = call toString $131
	lw $a0, 424($sp)
	jal func__toString
	move $t3, $v0
#	$524 = call stringConcatenate $522 " "
	move $a0, $t3
	la $a1, string_523
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $524
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$526 = call toString $132
	lw $a0, 5352($sp)
	jal func__toString
	move $t3, $v0
#	$528 = call stringConcatenate $526 " "
	move $a0, $t3
	la $a1, string_527
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $528
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$530 = call toString $133
	lw $a0, 3784($sp)
	jal func__toString
	move $t3, $v0
#	$532 = call stringConcatenate $530 " "
	move $a0, $t3
	la $a1, string_531
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $532
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$534 = call toString $134
	lw $a0, 2252($sp)
	jal func__toString
	move $t3, $v0
#	$536 = call stringConcatenate $534 " "
	move $a0, $t3
	la $a1, string_535
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $536
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$538 = call toString $135
	lw $a0, 6860($sp)
	jal func__toString
	move $t3, $v0
#	$540 = call stringConcatenate $538 " "
	move $a0, $t3
	la $a1, string_539
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $540
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$542 = call toString $136
	lw $a0, 2028($sp)
	jal func__toString
	move $t3, $v0
#	$544 = call stringConcatenate $542 " "
	move $a0, $t3
	la $a1, string_543
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $544
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$546 = call toString $137
	lw $a0, 2648($sp)
	jal func__toString
	move $t3, $v0
#	$548 = call stringConcatenate $546 " "
	move $a0, $t3
	la $a1, string_547
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $548
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$550 = call toString $138
	lw $a0, 4848($sp)
	jal func__toString
	move $t3, $v0
#	$552 = call stringConcatenate $550 " "
	move $a0, $t3
	la $a1, string_551
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $552
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$554 = call toString $139
	lw $a0, 5528($sp)
	jal func__toString
	move $t3, $v0
#	$556 = call stringConcatenate $554 " "
	move $a0, $t3
	la $a1, string_555
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $556
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$558 = call toString $140
	lw $a0, 2560($sp)
	jal func__toString
	move $t3, $v0
#	$560 = call stringConcatenate $558 " "
	move $a0, $t3
	la $a1, string_559
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $560
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$562 = call toString $141
	lw $a0, 3484($sp)
	jal func__toString
	move $t3, $v0
#	$564 = call stringConcatenate $562 " "
	move $a0, $t3
	la $a1, string_563
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $564
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$566 = call toString $142
	lw $a0, 1972($sp)
	jal func__toString
	move $t3, $v0
#	$568 = call stringConcatenate $566 " "
	move $a0, $t3
	la $a1, string_567
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $568
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$570 = call toString $143
	lw $a0, 6996($sp)
	jal func__toString
	move $t3, $v0
#	$572 = call stringConcatenate $570 " "
	move $a0, $t3
	la $a1, string_571
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $572
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$574 = call toString $144
	lw $a0, 1888($sp)
	jal func__toString
	move $t3, $v0
#	$576 = call stringConcatenate $574 " "
	move $a0, $t3
	la $a1, string_575
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $576
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$578 = call toString $145
	lw $a0, 2600($sp)
	jal func__toString
	move $t3, $v0
#	$580 = call stringConcatenate $578 " "
	move $a0, $t3
	la $a1, string_579
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $580
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$582 = call toString $146
	lw $a0, 616($sp)
	jal func__toString
	move $t3, $v0
#	$584 = call stringConcatenate $582 " "
	move $a0, $t3
	la $a1, string_583
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $584
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$586 = call toString $147
	move $a0, $t9
	jal func__toString
	move $t3, $v0
#	$588 = call stringConcatenate $586 " "
	move $a0, $t3
	la $a1, string_587
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $588
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$590 = call toString $148
	lw $a0, 7696($sp)
	jal func__toString
	move $t3, $v0
#	$592 = call stringConcatenate $590 " "
	move $a0, $t3
	la $a1, string_591
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $592
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$594 = call toString $149
	lw $a0, 6292($sp)
	jal func__toString
	move $t3, $v0
#	$596 = call stringConcatenate $594 " "
	move $a0, $t3
	la $a1, string_595
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $596
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$598 = call toString $150
	lw $a0, 1128($sp)
	jal func__toString
	move $t3, $v0
#	$600 = call stringConcatenate $598 " "
	move $a0, $t3
	la $a1, string_599
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $600
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$602 = call toString $151
	lw $a0, 2500($sp)
	jal func__toString
	move $t3, $v0
#	$604 = call stringConcatenate $602 " "
	move $a0, $t3
	la $a1, string_603
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $604
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$606 = call toString $152
	lw $a0, 2400($sp)
	jal func__toString
	move $t3, $v0
#	$608 = call stringConcatenate $606 " "
	move $a0, $t3
	la $a1, string_607
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $608
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$610 = call toString $153
	lw $a0, 3628($sp)
	jal func__toString
	move $t3, $v0
#	$612 = call stringConcatenate $610 " "
	move $a0, $t3
	la $a1, string_611
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $612
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$614 = call toString $154
	lw $a0, 3216($sp)
	jal func__toString
	move $t3, $v0
#	$616 = call stringConcatenate $614 " "
	move $a0, $t3
	la $a1, string_615
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $616
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$618 = call toString $155
	lw $a0, 6196($sp)
	jal func__toString
	move $t3, $v0
#	$620 = call stringConcatenate $618 " "
	move $a0, $t3
	la $a1, string_619
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $620
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$622 = call toString $156
	lw $a0, 452($sp)
	jal func__toString
	move $t3, $v0
#	$624 = call stringConcatenate $622 " "
	move $a0, $t3
	la $a1, string_623
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $624
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$626 = call toString $157
	lw $a0, 324($sp)
	jal func__toString
	move $t3, $v0
#	$628 = call stringConcatenate $626 " "
	move $a0, $t3
	la $a1, string_627
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $628
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$630 = call toString $158
	lw $a0, 2120($sp)
	jal func__toString
	move $t3, $v0
#	$632 = call stringConcatenate $630 " "
	move $a0, $t3
	la $a1, string_631
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $632
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$634 = call toString $159
	lw $a0, 4388($sp)
	jal func__toString
	move $t3, $v0
#	$636 = call stringConcatenate $634 " "
	move $a0, $t3
	la $a1, string_635
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $636
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$638 = call toString $160
	lw $a0, 7304($sp)
	jal func__toString
	move $t3, $v0
#	$640 = call stringConcatenate $638 " "
	move $a0, $t3
	la $a1, string_639
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $640
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$642 = call toString $161
	lw $a0, 3752($sp)
	jal func__toString
	move $t3, $v0
#	$644 = call stringConcatenate $642 " "
	move $a0, $t3
	la $a1, string_643
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $644
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$646 = call toString $162
	lw $a0, 4336($sp)
	jal func__toString
	move $t3, $v0
#	$648 = call stringConcatenate $646 " "
	move $a0, $t3
	la $a1, string_647
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $648
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$650 = call toString $163
	lw $a0, 7432($sp)
	jal func__toString
	move $t3, $v0
#	$652 = call stringConcatenate $650 " "
	move $a0, $t3
	la $a1, string_651
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $652
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$654 = call toString $164
	lw $a0, 620($sp)
	jal func__toString
	move $t3, $v0
#	$656 = call stringConcatenate $654 " "
	move $a0, $t3
	la $a1, string_655
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $656
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$658 = call toString $165
	lw $a0, 3712($sp)
	jal func__toString
	move $t3, $v0
#	$660 = call stringConcatenate $658 " "
	move $a0, $t3
	la $a1, string_659
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $660
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$662 = call toString $166
	lw $a0, 4576($sp)
	jal func__toString
	move $t3, $v0
#	$664 = call stringConcatenate $662 " "
	move $a0, $t3
	la $a1, string_663
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $664
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$666 = call toString $167
	move $a0, $fp
	jal func__toString
	move $t3, $v0
#	$668 = call stringConcatenate $666 " "
	move $a0, $t3
	la $a1, string_667
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $668
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$670 = call toString $168
	lw $a0, 6024($sp)
	jal func__toString
	move $t3, $v0
#	$672 = call stringConcatenate $670 " "
	move $a0, $t3
	la $a1, string_671
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $672
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$674 = call toString $169
	lw $a0, 7612($sp)
	jal func__toString
	move $t3, $v0
#	$676 = call stringConcatenate $674 " "
	move $a0, $t3
	la $a1, string_675
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $676
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$678 = call toString $170
	lw $a0, 2208($sp)
	jal func__toString
	move $t3, $v0
#	$680 = call stringConcatenate $678 " "
	move $a0, $t3
	la $a1, string_679
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $680
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$682 = call toString $171
	lw $a0, 7672($sp)
	jal func__toString
	move $t3, $v0
#	$684 = call stringConcatenate $682 " "
	move $a0, $t3
	la $a1, string_683
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $684
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$686 = call toString $172
	lw $a0, 6276($sp)
	jal func__toString
	move $t3, $v0
#	$688 = call stringConcatenate $686 " "
	move $a0, $t3
	la $a1, string_687
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $688
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$690 = call toString $173
	lw $a0, 3032($sp)
	jal func__toString
	move $t3, $v0
#	$692 = call stringConcatenate $690 " "
	move $a0, $t3
	la $a1, string_691
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $692
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$694 = call toString $174
	lw $a0, 2180($sp)
	jal func__toString
	move $t3, $v0
#	$696 = call stringConcatenate $694 " "
	move $a0, $t3
	la $a1, string_695
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $696
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$698 = call toString $175
	lw $a0, 2928($sp)
	jal func__toString
	move $t3, $v0
#	$700 = call stringConcatenate $698 " "
	move $a0, $t3
	la $a1, string_699
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $700
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$702 = call toString $176
	lw $a0, 5000($sp)
	jal func__toString
	move $t3, $v0
#	$704 = call stringConcatenate $702 " "
	move $a0, $t3
	la $a1, string_703
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $704
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$706 = call toString $177
	lw $a0, 2112($sp)
	jal func__toString
	move $t3, $v0
#	$708 = call stringConcatenate $706 " "
	move $a0, $t3
	la $a1, string_707
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $708
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$710 = call toString $178
	lw $a0, 4800($sp)
	jal func__toString
	move $t3, $v0
#	$712 = call stringConcatenate $710 " "
	move $a0, $t3
	la $a1, string_711
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $712
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$714 = call toString $179
	lw $a0, 564($sp)
	jal func__toString
	move $t3, $v0
#	$716 = call stringConcatenate $714 " "
	move $a0, $t3
	la $a1, string_715
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $716
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$718 = call toString $180
	lw $a0, 548($sp)
	jal func__toString
	move $t3, $v0
#	$720 = call stringConcatenate $718 " "
	move $a0, $t3
	la $a1, string_719
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $720
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$722 = call toString $181
	lw $a0, 1056($sp)
	jal func__toString
	move $t3, $v0
#	$724 = call stringConcatenate $722 " "
	move $a0, $t3
	la $a1, string_723
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $724
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$726 = call toString $182
	lw $a0, 7284($sp)
	jal func__toString
	move $t3, $v0
#	$728 = call stringConcatenate $726 " "
	move $a0, $t3
	la $a1, string_727
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $728
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$730 = call toString $183
	lw $a0, 1632($sp)
	jal func__toString
	move $t3, $v0
#	$732 = call stringConcatenate $730 " "
	move $a0, $t3
	la $a1, string_731
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $732
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$734 = call toString $184
	lw $a0, 7032($sp)
	jal func__toString
	move $t3, $v0
#	$736 = call stringConcatenate $734 " "
	move $a0, $t3
	la $a1, string_735
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $736
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$738 = call toString $185
	lw $a0, 300($sp)
	jal func__toString
	move $t3, $v0
#	$740 = call stringConcatenate $738 " "
	move $a0, $t3
	la $a1, string_739
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $740
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$742 = call toString $186
	lw $a0, 5492($sp)
	jal func__toString
	move $t3, $v0
#	$744 = call stringConcatenate $742 " "
	move $a0, $t3
	la $a1, string_743
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $744
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$746 = call toString $187
	lw $a0, 4912($sp)
	jal func__toString
	move $t3, $v0
#	$748 = call stringConcatenate $746 " "
	move $a0, $t3
	la $a1, string_747
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $748
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$750 = call toString $188
	lw $a0, 684($sp)
	jal func__toString
	move $t3, $v0
#	$752 = call stringConcatenate $750 " "
	move $a0, $t3
	la $a1, string_751
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $752
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$754 = call toString $189
	lw $a0, 3296($sp)
	jal func__toString
	move $t3, $v0
#	$756 = call stringConcatenate $754 " "
	move $a0, $t3
	la $a1, string_755
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $756
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$758 = call toString $190
	lw $a0, 7360($sp)
	jal func__toString
	move $t3, $v0
#	$760 = call stringConcatenate $758 " "
	move $a0, $t3
	la $a1, string_759
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $760
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$762 = call toString $191
	lw $a0, 5804($sp)
	jal func__toString
	move $t3, $v0
#	$764 = call stringConcatenate $762 " "
	move $a0, $t3
	la $a1, string_763
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $764
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$766 = call toString $192
	lw $a0, 5348($sp)
	jal func__toString
	move $t3, $v0
#	$768 = call stringConcatenate $766 " "
	move $a0, $t3
	la $a1, string_767
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $768
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$770 = call toString $193
	lw $a0, 3824($sp)
	jal func__toString
	move $t3, $v0
#	$772 = call stringConcatenate $770 " "
	move $a0, $t3
	la $a1, string_771
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $772
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$774 = call toString $194
	lw $a0, 2836($sp)
	jal func__toString
	move $t3, $v0
#	$776 = call stringConcatenate $774 " "
	move $a0, $t3
	la $a1, string_775
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $776
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$778 = call toString $195
	lw $a0, 1616($sp)
	jal func__toString
	move $t3, $v0
#	$780 = call stringConcatenate $778 " "
	move $a0, $t3
	la $a1, string_779
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $780
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$782 = call toString $196
	lw $a0, 4776($sp)
	jal func__toString
	move $t3, $v0
#	$784 = call stringConcatenate $782 " "
	move $a0, $t3
	la $a1, string_783
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $784
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$786 = call toString $197
	lw $a0, 920($sp)
	jal func__toString
	move $t3, $v0
#	$788 = call stringConcatenate $786 " "
	move $a0, $t3
	la $a1, string_787
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $788
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$790 = call toString $198
	lw $a0, 552($sp)
	jal func__toString
	move $t3, $v0
#	$792 = call stringConcatenate $790 " "
	move $a0, $t3
	la $a1, string_791
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $792
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$794 = call toString $199
	lw $a0, 6800($sp)
	jal func__toString
	move $t3, $v0
#	$796 = call stringConcatenate $794 " "
	move $a0, $t3
	la $a1, string_795
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $796
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$798 = call toString $200
	lw $a0, 4696($sp)
	jal func__toString
	move $t3, $v0
#	$800 = call stringConcatenate $798 " "
	move $a0, $t3
	la $a1, string_799
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $800
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$802 = call toString $201
	lw $a0, 712($sp)
	jal func__toString
	move $t3, $v0
#	$804 = call stringConcatenate $802 " "
	move $a0, $t3
	la $a1, string_803
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $804
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$806 = call toString $202
	lw $a0, 3852($sp)
	jal func__toString
	move $t3, $v0
#	$808 = call stringConcatenate $806 " "
	move $a0, $t3
	la $a1, string_807
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $808
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$810 = call toString $203
	lw $a0, 1736($sp)
	jal func__toString
	move $t3, $v0
#	$812 = call stringConcatenate $810 " "
	move $a0, $t3
	la $a1, string_811
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $812
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$814 = call toString $204
	lw $a0, 908($sp)
	jal func__toString
	move $t3, $v0
#	$816 = call stringConcatenate $814 " "
	move $a0, $t3
	la $a1, string_815
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $816
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$818 = call toString $205
	lw $a0, 4616($sp)
	jal func__toString
	move $t3, $v0
#	$820 = call stringConcatenate $818 " "
	move $a0, $t3
	la $a1, string_819
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $820
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$822 = call toString $206
	lw $a0, 2088($sp)
	jal func__toString
	move $t3, $v0
#	$824 = call stringConcatenate $822 " "
	move $a0, $t3
	la $a1, string_823
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $824
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$826 = call toString $207
	lw $a0, 4864($sp)
	jal func__toString
	move $t3, $v0
#	$828 = call stringConcatenate $826 " "
	move $a0, $t3
	la $a1, string_827
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $828
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$830 = call toString $208
	lw $a0, 5760($sp)
	jal func__toString
	move $t3, $v0
#	$832 = call stringConcatenate $830 " "
	move $a0, $t3
	la $a1, string_831
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $832
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$834 = call toString $209
	lw $a0, 1704($sp)
	jal func__toString
	move $t3, $v0
#	$836 = call stringConcatenate $834 " "
	move $a0, $t3
	la $a1, string_835
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $836
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$838 = call toString $210
	lw $a0, 392($sp)
	jal func__toString
	move $t3, $v0
#	$840 = call stringConcatenate $838 " "
	move $a0, $t3
	la $a1, string_839
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $840
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$842 = call toString $211
	lw $a0, 3236($sp)
	jal func__toString
	move $t3, $v0
#	$844 = call stringConcatenate $842 " "
	move $a0, $t3
	la $a1, string_843
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $844
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$846 = call toString $212
	lw $a0, 6384($sp)
	jal func__toString
	move $t3, $v0
#	$848 = call stringConcatenate $846 " "
	move $a0, $t3
	la $a1, string_847
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $848
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$850 = call toString $213
	lw $a0, 3948($sp)
	jal func__toString
	move $t3, $v0
#	$852 = call stringConcatenate $850 " "
	move $a0, $t3
	la $a1, string_851
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $852
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$854 = call toString $214
	lw $a0, 848($sp)
	jal func__toString
	move $t3, $v0
#	$856 = call stringConcatenate $854 " "
	move $a0, $t3
	la $a1, string_855
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $856
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$858 = call toString $215
	lw $a0, 7108($sp)
	jal func__toString
	move $t3, $v0
#	$860 = call stringConcatenate $858 " "
	move $a0, $t3
	la $a1, string_859
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $860
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$862 = call toString $216
	lw $a0, 2076($sp)
	jal func__toString
	move $t3, $v0
#	$864 = call stringConcatenate $862 " "
	move $a0, $t3
	la $a1, string_863
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $864
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$866 = call toString $217
	lw $a0, 2040($sp)
	jal func__toString
	move $t3, $v0
#	$868 = call stringConcatenate $866 " "
	move $a0, $t3
	la $a1, string_867
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $868
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$870 = call toString $218
	lw $a0, 5180($sp)
	jal func__toString
	move $t3, $v0
#	$872 = call stringConcatenate $870 " "
	move $a0, $t3
	la $a1, string_871
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $872
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$874 = call toString $219
	lw $a0, 1136($sp)
	jal func__toString
	move $t3, $v0
#	$876 = call stringConcatenate $874 " "
	move $a0, $t3
	la $a1, string_875
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $876
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$878 = call toString $220
	lw $a0, 444($sp)
	jal func__toString
	move $t3, $v0
#	$880 = call stringConcatenate $878 " "
	move $a0, $t3
	la $a1, string_879
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $880
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$882 = call toString $221
	lw $a0, 2124($sp)
	jal func__toString
	move $t3, $v0
#	$884 = call stringConcatenate $882 " "
	move $a0, $t3
	la $a1, string_883
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $884
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$886 = call toString $222
	lw $a0, 3396($sp)
	jal func__toString
	move $t3, $v0
#	$888 = call stringConcatenate $886 " "
	move $a0, $t3
	la $a1, string_887
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $888
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$890 = call toString $223
	lw $a0, 5116($sp)
	jal func__toString
	move $t3, $v0
#	$892 = call stringConcatenate $890 " "
	move $a0, $t3
	la $a1, string_891
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $892
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$894 = call toString $224
	lw $a0, 4748($sp)
	jal func__toString
	move $t3, $v0
#	$896 = call stringConcatenate $894 " "
	move $a0, $t3
	la $a1, string_895
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $896
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$898 = call toString $225
	lw $a0, 7176($sp)
	jal func__toString
	move $t3, $v0
#	$900 = call stringConcatenate $898 " "
	move $a0, $t3
	la $a1, string_899
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $900
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$902 = call toString $226
	lw $a0, 1840($sp)
	jal func__toString
	move $t3, $v0
#	$904 = call stringConcatenate $902 " "
	move $a0, $t3
	la $a1, string_903
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $904
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$906 = call toString $227
	lw $a0, 4488($sp)
	jal func__toString
	move $t3, $v0
#	$908 = call stringConcatenate $906 " "
	move $a0, $t3
	la $a1, string_907
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $908
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$910 = call toString $228
	lw $a0, 5224($sp)
	jal func__toString
	move $t3, $v0
#	$912 = call stringConcatenate $910 " "
	move $a0, $t3
	la $a1, string_911
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $912
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$914 = call toString $229
	lw $a0, 3064($sp)
	jal func__toString
	move $t3, $v0
#	$916 = call stringConcatenate $914 " "
	move $a0, $t3
	la $a1, string_915
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $916
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$918 = call toString $230
	lw $a0, 4936($sp)
	jal func__toString
	move $t3, $v0
#	$920 = call stringConcatenate $918 " "
	move $a0, $t3
	la $a1, string_919
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $920
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$922 = call toString $231
	lw $a0, 3952($sp)
	jal func__toString
	move $t3, $v0
#	$924 = call stringConcatenate $922 " "
	move $a0, $t3
	la $a1, string_923
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $924
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$926 = call toString $232
	lw $a0, 4648($sp)
	jal func__toString
	move $t3, $v0
#	$928 = call stringConcatenate $926 " "
	move $a0, $t3
	la $a1, string_927
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $928
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$930 = call toString $233
	lw $a0, 5192($sp)
	jal func__toString
	move $t3, $v0
#	$932 = call stringConcatenate $930 " "
	move $a0, $t3
	la $a1, string_931
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $932
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$934 = call toString $234
	lw $a0, 536($sp)
	jal func__toString
	move $t3, $v0
#	$936 = call stringConcatenate $934 " "
	move $a0, $t3
	la $a1, string_935
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $936
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$938 = call toString $235
	lw $a0, 1796($sp)
	jal func__toString
	move $t3, $v0
#	$940 = call stringConcatenate $938 " "
	move $a0, $t3
	la $a1, string_939
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $940
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$942 = call toString $236
	lw $a0, 6876($sp)
	jal func__toString
	move $t3, $v0
#	$944 = call stringConcatenate $942 " "
	move $a0, $t3
	la $a1, string_943
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $944
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$946 = call toString $237
	lw $a0, 7292($sp)
	jal func__toString
	move $t3, $v0
#	$948 = call stringConcatenate $946 " "
	move $a0, $t3
	la $a1, string_947
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $948
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$950 = call toString $238
	lw $a0, 2992($sp)
	jal func__toString
	move $t3, $v0
#	$952 = call stringConcatenate $950 " "
	move $a0, $t3
	la $a1, string_951
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $952
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$954 = call toString $239
	lw $a0, 824($sp)
	jal func__toString
	move $t3, $v0
#	$956 = call stringConcatenate $954 " "
	move $a0, $t3
	la $a1, string_955
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $956
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$958 = call toString $240
	lw $a0, 7500($sp)
	jal func__toString
	move $t3, $v0
#	$960 = call stringConcatenate $958 " "
	move $a0, $t3
	la $a1, string_959
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $960
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$962 = call toString $241
	lw $a0, 6116($sp)
	jal func__toString
	move $t3, $v0
#	$964 = call stringConcatenate $962 " "
	move $a0, $t3
	la $a1, string_963
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $964
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$966 = call toString $242
	lw $a0, 3716($sp)
	jal func__toString
	move $t3, $v0
#	$968 = call stringConcatenate $966 " "
	move $a0, $t3
	la $a1, string_967
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $968
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$970 = call toString $243
	lw $a0, 5424($sp)
	jal func__toString
	move $t3, $v0
#	$972 = call stringConcatenate $970 " "
	move $a0, $t3
	la $a1, string_971
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $972
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$974 = call toString $244
	lw $a0, 1376($sp)
	jal func__toString
	move $t3, $v0
#	$976 = call stringConcatenate $974 " "
	move $a0, $t3
	la $a1, string_975
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $976
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$978 = call toString $245
	lw $a0, 4320($sp)
	jal func__toString
	move $t3, $v0
#	$980 = call stringConcatenate $978 " "
	move $a0, $t3
	la $a1, string_979
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $980
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$982 = call toString $246
	lw $a0, 3460($sp)
	jal func__toString
	move $t3, $v0
#	$984 = call stringConcatenate $982 " "
	move $a0, $t3
	la $a1, string_983
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $984
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$986 = call toString $247
	lw $a0, 7456($sp)
	jal func__toString
	move $t3, $v0
#	$988 = call stringConcatenate $986 " "
	move $a0, $t3
	la $a1, string_987
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $988
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$990 = call toString $248
	lw $a0, 1148($sp)
	jal func__toString
	move $t3, $v0
#	$992 = call stringConcatenate $990 " "
	move $a0, $t3
	la $a1, string_991
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $992
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$994 = call toString $249
	lw $a0, 3052($sp)
	jal func__toString
	move $t3, $v0
#	$996 = call stringConcatenate $994 " "
	move $a0, $t3
	la $a1, string_995
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $996
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$998 = call toString $250
	lw $a0, 5464($sp)
	jal func__toString
	move $t3, $v0
#	$1000 = call stringConcatenate $998 " "
	move $a0, $t3
	la $a1, string_999
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1000
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1002 = call toString $251
	lw $a0, 932($sp)
	jal func__toString
	move $t3, $v0
#	$1004 = call stringConcatenate $1002 " "
	move $a0, $t3
	la $a1, string_1003
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1004
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1006 = call toString $252
	lw $a0, 6076($sp)
	jal func__toString
	move $t3, $v0
#	$1008 = call stringConcatenate $1006 " "
	move $a0, $t3
	la $a1, string_1007
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1008
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1010 = call toString $253
	lw $a0, 1480($sp)
	jal func__toString
	move $t3, $v0
#	$1012 = call stringConcatenate $1010 " "
	move $a0, $t3
	la $a1, string_1011
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1012
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1014 = call toString $254
	move $a0, $t7
	jal func__toString
	move $t3, $v0
#	$1016 = call stringConcatenate $1014 " "
	move $a0, $t3
	la $a1, string_1015
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1016
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1018 = call toString $255
	lw $a0, 5476($sp)
	jal func__toString
	move $t3, $v0
#	$1020 = call stringConcatenate $1018 " "
	move $a0, $t3
	la $a1, string_1019
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1020
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1022 = call toString $256
	lw $a0, 4192($sp)
	jal func__toString
	move $t3, $v0
#	$1024 = call stringConcatenate $1022 " "
	move $a0, $t3
	la $a1, string_1023
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1024
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1026 = call toString $257
	lw $a0, 5908($sp)
	jal func__toString
	move $t3, $v0
#	$1028 = call stringConcatenate $1026 " "
	move $a0, $t3
	la $a1, string_1027
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1028
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1030 = call toString $258
	lw $a0, 4384($sp)
	jal func__toString
	move $t3, $v0
#	$1032 = call stringConcatenate $1030 " "
	move $a0, $t3
	la $a1, string_1031
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1032
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1034 = call toString $259
	lw $a0, 3024($sp)
	jal func__toString
	move $t3, $v0
#	$1036 = call stringConcatenate $1034 " "
	move $a0, $t3
	la $a1, string_1035
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1036
	move $a0, $t3
	jal func__print
	sw $v0, 8340($sp)
#	$1038 = call toString $260
	lw $a0, 4532($sp)
	jal func__toString
	move $t3, $v0
#	$1040 = call stringConcatenate $1038 " "
	move $a0, $t3
	la $a1, string_1039
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1040
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1042 = call toString $261
	lw $a0, 5420($sp)
	jal func__toString
	move $t3, $v0
#	$1044 = call stringConcatenate $1042 " "
	move $a0, $t3
	la $a1, string_1043
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1044
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1046 = call toString $262
	move $a0, $s0
	jal func__toString
	move $t3, $v0
#	$1048 = call stringConcatenate $1046 " "
	move $a0, $t3
	la $a1, string_1047
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1048
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1050 = call toString $263
	lw $a0, 4500($sp)
	jal func__toString
	move $t3, $v0
#	$1052 = call stringConcatenate $1050 " "
	move $a0, $t3
	la $a1, string_1051
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1052
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1054 = call toString $264
	move $a0, $s6
	jal func__toString
	move $t3, $v0
#	$1056 = call stringConcatenate $1054 " "
	move $a0, $t3
	la $a1, string_1055
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1056
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1058 = call toString $265
	lw $a0, 3656($sp)
	jal func__toString
	move $t3, $v0
#	$1060 = call stringConcatenate $1058 " "
	move $a0, $t3
	la $a1, string_1059
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1060
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1062 = call toString $266
	lw $a0, 6324($sp)
	jal func__toString
	move $t3, $v0
#	$1064 = call stringConcatenate $1062 " "
	move $a0, $t3
	la $a1, string_1063
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1064
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1066 = call toString $267
	lw $a0, 6756($sp)
	jal func__toString
	move $t3, $v0
#	$1068 = call stringConcatenate $1066 " "
	move $a0, $t3
	la $a1, string_1067
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1068
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1070 = call toString $268
	lw $a0, 2848($sp)
	jal func__toString
	move $t3, $v0
#	$1072 = call stringConcatenate $1070 " "
	move $a0, $t3
	la $a1, string_1071
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1072
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1074 = call toString $269
	lw $a0, 7116($sp)
	jal func__toString
	move $t3, $v0
#	$1076 = call stringConcatenate $1074 " "
	move $a0, $t3
	la $a1, string_1075
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1076
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1078 = call toString $270
	lw $a0, 1252($sp)
	jal func__toString
	move $t3, $v0
#	$1080 = call stringConcatenate $1078 " "
	move $a0, $t3
	la $a1, string_1079
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1080
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1082 = call toString $271
	lw $a0, 7244($sp)
	jal func__toString
	move $t3, $v0
#	$1084 = call stringConcatenate $1082 " "
	move $a0, $t3
	la $a1, string_1083
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1084
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1086 = call toString $272
	lw $a0, 2540($sp)
	jal func__toString
	move $t3, $v0
#	$1088 = call stringConcatenate $1086 " "
	move $a0, $t3
	la $a1, string_1087
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1088
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1090 = call toString $273
	lw $a0, 3536($sp)
	jal func__toString
	move $t3, $v0
#	$1092 = call stringConcatenate $1090 " "
	move $a0, $t3
	la $a1, string_1091
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1092
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1094 = call toString $274
	lw $a0, 1084($sp)
	jal func__toString
	move $t3, $v0
#	$1096 = call stringConcatenate $1094 " "
	move $a0, $t3
	la $a1, string_1095
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1096
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1098 = call toString $275
	lw $a0, 3800($sp)
	jal func__toString
	move $t3, $v0
#	$1100 = call stringConcatenate $1098 " "
	move $a0, $t3
	la $a1, string_1099
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1100
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1102 = call toString $276
	lw $a0, 3836($sp)
	jal func__toString
	move $t3, $v0
#	$1104 = call stringConcatenate $1102 " "
	move $a0, $t3
	la $a1, string_1103
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1104
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1106 = call toString $277
	lw $a0, 5536($sp)
	jal func__toString
	move $t3, $v0
#	$1108 = call stringConcatenate $1106 " "
	move $a0, $t3
	la $a1, string_1107
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1108
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1110 = call toString $278
	lw $a0, 1424($sp)
	jal func__toString
	move $t3, $v0
#	$1112 = call stringConcatenate $1110 " "
	move $a0, $t3
	la $a1, string_1111
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1112
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1114 = call toString $279
	lw $a0, 2264($sp)
	jal func__toString
	move $t3, $v0
#	$1116 = call stringConcatenate $1114 " "
	move $a0, $t3
	la $a1, string_1115
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1116
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1118 = call toString $280
	lw $a0, 2204($sp)
	jal func__toString
	move $t3, $v0
#	$1120 = call stringConcatenate $1118 " "
	move $a0, $t3
	la $a1, string_1119
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1120
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1122 = call toString $281
	lw $a0, 5660($sp)
	jal func__toString
	move $t3, $v0
#	$1124 = call stringConcatenate $1122 " "
	move $a0, $t3
	la $a1, string_1123
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1124
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1126 = call toString $282
	move $a0, $s4
	jal func__toString
	move $t3, $v0
#	$1128 = call stringConcatenate $1126 " "
	move $a0, $t3
	la $a1, string_1127
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1128
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1130 = call toString $283
	lw $a0, 2796($sp)
	jal func__toString
	move $t3, $v0
#	$1132 = call stringConcatenate $1130 " "
	move $a0, $t3
	la $a1, string_1131
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1132
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1134 = call toString $284
	lw $a0, 5184($sp)
	jal func__toString
	move $t3, $v0
#	$1136 = call stringConcatenate $1134 " "
	move $a0, $t3
	la $a1, string_1135
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1136
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1138 = call toString $285
	lw $a0, 3552($sp)
	jal func__toString
	move $t3, $v0
#	$1140 = call stringConcatenate $1138 " "
	move $a0, $t3
	la $a1, string_1139
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1140
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1142 = call toString $286
	lw $a0, 1960($sp)
	jal func__toString
	move $t3, $v0
#	$1144 = call stringConcatenate $1142 " "
	move $a0, $t3
	la $a1, string_1143
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1144
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1146 = call toString $287
	lw $a0, 2388($sp)
	jal func__toString
	move $t3, $v0
#	$1148 = call stringConcatenate $1146 " "
	move $a0, $t3
	la $a1, string_1147
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1148
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1150 = call toString $288
	lw $a0, 7656($sp)
	jal func__toString
	move $t3, $v0
#	$1152 = call stringConcatenate $1150 " "
	move $a0, $t3
	la $a1, string_1151
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1152
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1154 = call toString $289
	lw $a0, 2912($sp)
	jal func__toString
	move $t3, $v0
#	$1156 = call stringConcatenate $1154 " "
	move $a0, $t3
	la $a1, string_1155
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1156
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1158 = call toString $290
	lw $a0, 1468($sp)
	jal func__toString
	move $t3, $v0
#	$1160 = call stringConcatenate $1158 " "
	move $a0, $t3
	la $a1, string_1159
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1160
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1162 = call toString $291
	lw $a0, 6240($sp)
	jal func__toString
	move $t3, $v0
#	$1164 = call stringConcatenate $1162 " "
	move $a0, $t3
	la $a1, string_1163
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1164
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1166 = call toString $292
	lw $a0, 4668($sp)
	jal func__toString
	move $t3, $v0
#	$1168 = call stringConcatenate $1166 " "
	move $a0, $t3
	la $a1, string_1167
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1168
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1170 = call toString $293
	lw $a0, 936($sp)
	jal func__toString
	move $t3, $v0
#	$1172 = call stringConcatenate $1170 " "
	move $a0, $t3
	la $a1, string_1171
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1172
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1174 = call toString $294
	lw $a0, 996($sp)
	jal func__toString
	move $t3, $v0
#	$1176 = call stringConcatenate $1174 " "
	move $a0, $t3
	la $a1, string_1175
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1176
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1178 = call toString $295
	lw $a0, 2724($sp)
	jal func__toString
	move $t3, $v0
#	$1180 = call stringConcatenate $1178 " "
	move $a0, $t3
	la $a1, string_1179
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1180
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1182 = call toString $296
	lw $a0, 2368($sp)
	jal func__toString
	move $t3, $v0
#	$1184 = call stringConcatenate $1182 " "
	move $a0, $t3
	la $a1, string_1183
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1184
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1186 = call toString $297
	lw $a0, 136($sp)
	jal func__toString
	move $t3, $v0
#	$1188 = call stringConcatenate $1186 " "
	move $a0, $t3
	la $a1, string_1187
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1188
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1190 = call toString $298
	lw $a0, 3556($sp)
	jal func__toString
	move $t3, $v0
#	$1192 = call stringConcatenate $1190 " "
	move $a0, $t3
	la $a1, string_1191
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1192
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1194 = call toString $299
	lw $a0, 5296($sp)
	jal func__toString
	move $t3, $v0
#	$1196 = call stringConcatenate $1194 " "
	move $a0, $t3
	la $a1, string_1195
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1196
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1198 = call toString $300
	lw $a0, 4948($sp)
	jal func__toString
	move $t3, $v0
#	$1200 = call stringConcatenate $1198 " "
	move $a0, $t3
	la $a1, string_1199
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1200
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1202 = call toString $301
	lw $a0, 5160($sp)
	jal func__toString
	move $t3, $v0
#	$1204 = call stringConcatenate $1202 " "
	move $a0, $t3
	la $a1, string_1203
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1204
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1206 = call toString $302
	lw $a0, 2964($sp)
	jal func__toString
	move $t3, $v0
#	$1208 = call stringConcatenate $1206 " "
	move $a0, $t3
	la $a1, string_1207
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1208
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1210 = call toString $303
	lw $a0, 5452($sp)
	jal func__toString
	move $t3, $v0
#	$1212 = call stringConcatenate $1210 " "
	move $a0, $t3
	la $a1, string_1211
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1212
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1214 = call toString $304
	lw $a0, 1860($sp)
	jal func__toString
	move $t3, $v0
#	$1216 = call stringConcatenate $1214 " "
	move $a0, $t3
	la $a1, string_1215
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1216
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1218 = call toString $305
	lw $a0, 2332($sp)
	jal func__toString
	move $t3, $v0
#	$1220 = call stringConcatenate $1218 " "
	move $a0, $t3
	la $a1, string_1219
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1220
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1222 = call toString $306
	lw $a0, 5672($sp)
	jal func__toString
	move $t3, $v0
#	$1224 = call stringConcatenate $1222 " "
	move $a0, $t3
	la $a1, string_1223
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1224
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1226 = call toString $307
	lw $a0, 6912($sp)
	jal func__toString
	move $t3, $v0
#	$1228 = call stringConcatenate $1226 " "
	move $a0, $t3
	la $a1, string_1227
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1228
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1230 = call toString $308
	lw $a0, 1280($sp)
	jal func__toString
	move $t3, $v0
#	$1232 = call stringConcatenate $1230 " "
	move $a0, $t3
	la $a1, string_1231
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1232
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1234 = call toString $309
	move $a0, $t6
	jal func__toString
	move $t3, $v0
#	$1236 = call stringConcatenate $1234 " "
	move $a0, $t3
	la $a1, string_1235
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1236
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1238 = call toString $310
	lw $a0, 5128($sp)
	jal func__toString
	move $t3, $v0
#	$1240 = call stringConcatenate $1238 " "
	move $a0, $t3
	la $a1, string_1239
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1240
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1242 = call toString $311
	lw $a0, 6552($sp)
	jal func__toString
	move $t3, $v0
#	$1244 = call stringConcatenate $1242 " "
	move $a0, $t3
	la $a1, string_1243
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1244
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1246 = call toString $312
	lw $a0, 7000($sp)
	jal func__toString
	move $t3, $v0
#	$1248 = call stringConcatenate $1246 " "
	move $a0, $t3
	la $a1, string_1247
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1248
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1250 = call toString $313
	lw $a0, 2780($sp)
	jal func__toString
	move $t3, $v0
#	$1252 = call stringConcatenate $1250 " "
	move $a0, $t3
	la $a1, string_1251
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1252
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1254 = call toString $314
	move $a0, $t4
	jal func__toString
	sw $v0, 8324($sp)
#	$1256 = call stringConcatenate $1254 " "
	lw $a0, 8324($sp)
	la $a1, string_1255
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1256
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1258 = call toString $315
	lw $a0, 1192($sp)
	jal func__toString
	move $t3, $v0
#	$1260 = call stringConcatenate $1258 " "
	move $a0, $t3
	la $a1, string_1259
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1260
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1262 = call toString $316
	lw $a0, 2700($sp)
	jal func__toString
	move $t3, $v0
#	$1264 = call stringConcatenate $1262 " "
	move $a0, $t3
	la $a1, string_1263
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1264
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1266 = call toString $317
	lw $a0, 2472($sp)
	jal func__toString
	move $t3, $v0
#	$1268 = call stringConcatenate $1266 " "
	move $a0, $t3
	la $a1, string_1267
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1268
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1270 = call toString $318
	lw $a0, 1540($sp)
	jal func__toString
	move $t3, $v0
#	$1272 = call stringConcatenate $1270 " "
	move $a0, $t3
	la $a1, string_1271
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1272
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1274 = call toString $319
	lw $a0, 2580($sp)
	jal func__toString
	move $t3, $v0
#	$1276 = call stringConcatenate $1274 " "
	move $a0, $t3
	la $a1, string_1275
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1276
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1278 = call toString $320
	lw $a0, 5148($sp)
	jal func__toString
	move $t3, $v0
#	$1280 = call stringConcatenate $1278 " "
	move $a0, $t3
	la $a1, string_1279
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1280
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1282 = call toString $321
	lw $a0, 3684($sp)
	jal func__toString
	move $t3, $v0
#	$1284 = call stringConcatenate $1282 " "
	move $a0, $t3
	la $a1, string_1283
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1284
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1286 = call toString $322
	lw $a0, 460($sp)
	jal func__toString
	move $t3, $v0
#	$1288 = call stringConcatenate $1286 " "
	move $a0, $t3
	la $a1, string_1287
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1288
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1290 = call toString $323
	lw $a0, 7200($sp)
	jal func__toString
	move $t3, $v0
#	$1292 = call stringConcatenate $1290 " "
	move $a0, $t3
	la $a1, string_1291
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1292
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1294 = call toString $324
	lw $a0, 7336($sp)
	jal func__toString
	move $t3, $v0
#	$1296 = call stringConcatenate $1294 " "
	move $a0, $t3
	la $a1, string_1295
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1296
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1298 = call toString $325
	lw $a0, 5232($sp)
	jal func__toString
	move $t3, $v0
#	$1300 = call stringConcatenate $1298 " "
	move $a0, $t3
	la $a1, string_1299
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1300
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1302 = call toString $326
	move $a0, $k1
	jal func__toString
	move $t3, $v0
#	$1304 = call stringConcatenate $1302 " "
	move $a0, $t3
	la $a1, string_1303
	jal func__stringConcatenate
	sw $v0, 8336($sp)
#	nullcall print $1304
	lw $a0, 8336($sp)
	jal func__print
	move $t3, $v0
#	$1306 = call toString $327
	lw $a0, 3704($sp)
	jal func__toString
	move $t3, $v0
#	$1308 = call stringConcatenate $1306 " "
	move $a0, $t3
	la $a1, string_1307
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1308
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1310 = call toString $328
	lw $a0, 1412($sp)
	jal func__toString
	move $t3, $v0
#	$1312 = call stringConcatenate $1310 " "
	move $a0, $t3
	la $a1, string_1311
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1312
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1314 = call toString $329
	lw $a0, 4128($sp)
	jal func__toString
	move $t3, $v0
#	$1316 = call stringConcatenate $1314 " "
	move $a0, $t3
	la $a1, string_1315
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1316
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1318 = call toString $330
	lw $a0, 2932($sp)
	jal func__toString
	move $t3, $v0
#	$1320 = call stringConcatenate $1318 " "
	move $a0, $t3
	la $a1, string_1319
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1320
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1322 = call toString $331
	lw $a0, 2676($sp)
	jal func__toString
	move $t3, $v0
#	$1324 = call stringConcatenate $1322 " "
	move $a0, $t3
	la $a1, string_1323
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1324
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1326 = call toString $332
	lw $a0, 3644($sp)
	jal func__toString
	move $t3, $v0
#	$1328 = call stringConcatenate $1326 " "
	move $a0, $t3
	la $a1, string_1327
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1328
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1330 = call toString $333
	lw $a0, 172($sp)
	jal func__toString
	move $t3, $v0
#	$1332 = call stringConcatenate $1330 " "
	move $a0, $t3
	la $a1, string_1331
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1332
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1334 = call toString $334
	lw $a0, 7092($sp)
	jal func__toString
	move $t3, $v0
#	$1336 = call stringConcatenate $1334 " "
	move $a0, $t3
	la $a1, string_1335
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1336
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1338 = call toString $335
	lw $a0, 6028($sp)
	jal func__toString
	move $t3, $v0
#	$1340 = call stringConcatenate $1338 " "
	move $a0, $t3
	la $a1, string_1339
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1340
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1342 = call toString $336
	move $a0, $t5
	jal func__toString
	move $t3, $v0
#	$1344 = call stringConcatenate $1342 " "
	move $a0, $t3
	la $a1, string_1343
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1344
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1346 = call toString $337
	lw $a0, 5516($sp)
	jal func__toString
	move $t3, $v0
#	$1348 = call stringConcatenate $1346 " "
	move $a0, $t3
	la $a1, string_1347
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1348
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1350 = call toString $338
	move $a0, $t2
	jal func__toString
	move $t3, $v0
#	$1352 = call stringConcatenate $1350 " "
	move $a0, $t3
	la $a1, string_1351
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1352
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1354 = call toString $339
	lw $a0, 5624($sp)
	jal func__toString
	move $t3, $v0
#	$1356 = call stringConcatenate $1354 " "
	move $a0, $t3
	la $a1, string_1355
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1356
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1358 = call toString $340
	lw $a0, 5836($sp)
	jal func__toString
	move $t3, $v0
#	$1360 = call stringConcatenate $1358 " "
	move $a0, $t3
	la $a1, string_1359
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1360
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1362 = call toString $341
	lw $a0, 5828($sp)
	jal func__toString
	move $t3, $v0
#	$1364 = call stringConcatenate $1362 " "
	move $a0, $t3
	la $a1, string_1363
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1364
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1366 = call toString $342
	lw $a0, 584($sp)
	jal func__toString
	move $t3, $v0
#	$1368 = call stringConcatenate $1366 " "
	move $a0, $t3
	la $a1, string_1367
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1368
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1370 = call toString $343
	lw $a0, 216($sp)
	jal func__toString
	move $t3, $v0
#	$1372 = call stringConcatenate $1370 " "
	move $a0, $t3
	la $a1, string_1371
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1372
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1374 = call toString $344
	move $a0, $s1
	jal func__toString
	move $t3, $v0
#	$1376 = call stringConcatenate $1374 " "
	move $a0, $t3
	la $a1, string_1375
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1376
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1378 = call toString $345
	lw $a0, 1016($sp)
	jal func__toString
	move $t3, $v0
#	$1380 = call stringConcatenate $1378 " "
	move $a0, $t3
	la $a1, string_1379
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1380
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1382 = call toString $346
	lw $a0, 2256($sp)
	jal func__toString
	move $t3, $v0
#	$1384 = call stringConcatenate $1382 " "
	move $a0, $t3
	la $a1, string_1383
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1384
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1386 = call toString $347
	lw $a0, 2768($sp)
	jal func__toString
	move $t3, $v0
#	$1388 = call stringConcatenate $1386 " "
	move $a0, $t3
	la $a1, string_1387
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1388
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1390 = call toString $348
	lw $a0, 1776($sp)
	jal func__toString
	move $t3, $v0
#	$1392 = call stringConcatenate $1390 " "
	move $a0, $t3
	la $a1, string_1391
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1392
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1394 = call toString $349
	lw $a0, 6684($sp)
	jal func__toString
	move $t3, $v0
#	$1396 = call stringConcatenate $1394 " "
	move $a0, $t3
	la $a1, string_1395
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1396
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1398 = call toString $350
	lw $a0, 288($sp)
	jal func__toString
	move $t3, $v0
#	$1400 = call stringConcatenate $1398 " "
	move $a0, $t3
	la $a1, string_1399
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1400
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1402 = call toString $351
	lw $a0, 456($sp)
	jal func__toString
	move $t3, $v0
#	$1404 = call stringConcatenate $1402 " "
	move $a0, $t3
	la $a1, string_1403
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1404
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1406 = call toString $352
	lw $a0, 6380($sp)
	jal func__toString
	move $t3, $v0
#	$1408 = call stringConcatenate $1406 " "
	move $a0, $t3
	la $a1, string_1407
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1408
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1410 = call toString $353
	lw $a0, 276($sp)
	jal func__toString
	move $t3, $v0
#	$1412 = call stringConcatenate $1410 " "
	move $a0, $t3
	la $a1, string_1411
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1412
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1414 = call toString $354
	lw $a0, 1356($sp)
	jal func__toString
	move $t3, $v0
#	$1416 = call stringConcatenate $1414 " "
	move $a0, $t3
	la $a1, string_1415
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1416
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1418 = call toString $355
	lw $a0, 4836($sp)
	jal func__toString
	move $t3, $v0
#	$1420 = call stringConcatenate $1418 " "
	move $a0, $t3
	la $a1, string_1419
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1420
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1422 = call toString $356
	lw $a0, 656($sp)
	jal func__toString
	move $t3, $v0
#	$1424 = call stringConcatenate $1422 " "
	move $a0, $t3
	la $a1, string_1423
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1424
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1426 = call toString $357
	lw $a0, 6540($sp)
	jal func__toString
	move $t3, $v0
#	$1428 = call stringConcatenate $1426 " "
	move $a0, $t3
	la $a1, string_1427
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1428
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1430 = call toString $358
	lw $a0, 3528($sp)
	jal func__toString
	move $t3, $v0
#	$1432 = call stringConcatenate $1430 " "
	move $a0, $t3
	la $a1, string_1431
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1432
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1434 = call toString $359
	lw $a0, 4112($sp)
	jal func__toString
	move $t3, $v0
#	$1436 = call stringConcatenate $1434 " "
	move $a0, $t3
	la $a1, string_1435
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1436
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1438 = call toString $360
	lw $a0, 2128($sp)
	jal func__toString
	move $t3, $v0
#	$1440 = call stringConcatenate $1438 " "
	move $a0, $t3
	la $a1, string_1439
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1440
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1442 = call toString $361
	lw $a0, 1848($sp)
	jal func__toString
	move $t3, $v0
#	$1444 = call stringConcatenate $1442 " "
	move $a0, $t3
	la $a1, string_1443
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1444
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1446 = call toString $362
	lw $a0, 7212($sp)
	jal func__toString
	move $t3, $v0
#	$1448 = call stringConcatenate $1446 " "
	move $a0, $t3
	la $a1, string_1447
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1448
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1450 = call toString $363
	move $a0, $t8
	jal func__toString
	move $t3, $v0
#	$1452 = call stringConcatenate $1450 " "
	move $a0, $t3
	la $a1, string_1451
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1452
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1454 = call toString $364
	move $a0, $k0
	jal func__toString
	move $t3, $v0
#	$1456 = call stringConcatenate $1454 " "
	move $a0, $t3
	la $a1, string_1455
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1456
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1458 = call toString $365
	lw $a0, 284($sp)
	jal func__toString
	move $t3, $v0
#	$1460 = call stringConcatenate $1458 " "
	move $a0, $t3
	la $a1, string_1459
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1460
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1462 = call toString $366
	lw $a0, 6396($sp)
	jal func__toString
	move $t3, $v0
#	$1464 = call stringConcatenate $1462 " "
	move $a0, $t3
	la $a1, string_1463
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1464
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1466 = call toString $367
	move $a0, $s5
	jal func__toString
	move $t3, $v0
#	$1468 = call stringConcatenate $1466 " "
	move $a0, $t3
	la $a1, string_1467
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1468
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1470 = call toString $368
	lw $a0, 1208($sp)
	jal func__toString
	move $t3, $v0
#	$1472 = call stringConcatenate $1470 " "
	move $a0, $t3
	la $a1, string_1471
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1472
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1474 = call toString $369
	lw $a0, 3516($sp)
	jal func__toString
	move $t3, $v0
#	$1476 = call stringConcatenate $1474 " "
	move $a0, $t3
	la $a1, string_1475
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1476
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1478 = call toString $370
	lw $a0, 3492($sp)
	jal func__toString
	move $t3, $v0
#	$1480 = call stringConcatenate $1478 " "
	move $a0, $t3
	la $a1, string_1479
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1480
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1482 = call toString $371
	lw $a0, 6412($sp)
	jal func__toString
	move $t3, $v0
#	$1484 = call stringConcatenate $1482 " "
	move $a0, $t3
	la $a1, string_1483
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1484
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1486 = call toString $372
	lw $a0, 7636($sp)
	jal func__toString
	move $t3, $v0
#	$1488 = call stringConcatenate $1486 " "
	move $a0, $t3
	la $a1, string_1487
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1488
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1490 = call toString $373
	lw $a0, 4292($sp)
	jal func__toString
	move $t3, $v0
#	$1492 = call stringConcatenate $1490 " "
	move $a0, $t3
	la $a1, string_1491
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1492
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1494 = call toString $374
	lw $a0, 4308($sp)
	jal func__toString
	move $t3, $v0
#	$1496 = call stringConcatenate $1494 " "
	move $a0, $t3
	la $a1, string_1495
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1496
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1498 = call toString $375
	lw $a0, 744($sp)
	jal func__toString
	move $t3, $v0
#	$1500 = call stringConcatenate $1498 " "
	move $a0, $t3
	la $a1, string_1499
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1500
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1502 = call toString $376
	lw $a0, 3636($sp)
	jal func__toString
	move $t3, $v0
#	$1504 = call stringConcatenate $1502 " "
	move $a0, $t3
	la $a1, string_1503
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1504
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1506 = call toString $377
	lw $a0, 1460($sp)
	jal func__toString
	move $t3, $v0
#	$1508 = call stringConcatenate $1506 " "
	move $a0, $t3
	la $a1, string_1507
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1508
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1510 = call toString $378
	lw $a0, 352($sp)
	jal func__toString
	move $t3, $v0
#	$1512 = call stringConcatenate $1510 " "
	move $a0, $t3
	la $a1, string_1511
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1512
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1514 = call toString $379
	move $a0, $gp
	jal func__toString
	move $t3, $v0
#	$1516 = call stringConcatenate $1514 " "
	move $a0, $t3
	la $a1, string_1515
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1516
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1518 = call toString $380
	lw $a0, 6724($sp)
	jal func__toString
	move $t3, $v0
#	$1520 = call stringConcatenate $1518 " "
	move $a0, $t3
	la $a1, string_1519
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1520
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1522 = call toString $381
	move $a0, $s3
	jal func__toString
	move $t3, $v0
#	$1524 = call stringConcatenate $1522 " "
	move $a0, $t3
	la $a1, string_1523
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1524
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1526 = call toString $382
	move $a0, $s7
	jal func__toString
	move $t3, $v0
#	$1528 = call stringConcatenate $1526 " "
	move $a0, $t3
	la $a1, string_1527
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1528
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1530 = call toString $383
	lw $a0, 1548($sp)
	jal func__toString
	move $t3, $v0
#	$1532 = call stringConcatenate $1530 " "
	move $a0, $t3
	la $a1, string_1531
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1532
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1534 = call toString $384
	lw $a0, 4556($sp)
	jal func__toString
	move $t3, $v0
#	$1536 = call stringConcatenate $1534 " "
	move $a0, $t3
	la $a1, string_1535
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1536
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1538 = call toString $385
	move $a0, $s2
	jal func__toString
	move $t3, $v0
#	$1540 = call stringConcatenate $1538 " "
	move $a0, $t3
	la $a1, string_1539
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1540
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1542 = call toString $386
	lw $a0, 1400($sp)
	jal func__toString
	move $t3, $v0
#	$1544 = call stringConcatenate $1542 " "
	move $a0, $t3
	la $a1, string_1543
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1544
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	nullcall println ""
	la $a0, string_1546
	jal func__println
	move $t3, $v0
#	$1548 = call toString $131
	lw $a0, 424($sp)
	jal func__toString
	move $t3, $v0
#	$1550 = call stringConcatenate $1548 " "
	move $a0, $t3
	la $a1, string_1549
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1550
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1552 = call toString $132
	lw $a0, 5352($sp)
	jal func__toString
	move $t3, $v0
#	$1554 = call stringConcatenate $1552 " "
	move $a0, $t3
	la $a1, string_1553
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1554
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1556 = call toString $133
	lw $a0, 3784($sp)
	jal func__toString
	move $t3, $v0
#	$1558 = call stringConcatenate $1556 " "
	move $a0, $t3
	la $a1, string_1557
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1558
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1560 = call toString $134
	lw $a0, 2252($sp)
	jal func__toString
	move $t3, $v0
#	$1562 = call stringConcatenate $1560 " "
	move $a0, $t3
	la $a1, string_1561
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1562
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1564 = call toString $135
	lw $a0, 6860($sp)
	jal func__toString
	move $t3, $v0
#	$1566 = call stringConcatenate $1564 " "
	move $a0, $t3
	la $a1, string_1565
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1566
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1568 = call toString $136
	lw $a0, 2028($sp)
	jal func__toString
	move $t3, $v0
#	$1570 = call stringConcatenate $1568 " "
	move $a0, $t3
	la $a1, string_1569
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1570
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1572 = call toString $137
	lw $a0, 2648($sp)
	jal func__toString
	move $t3, $v0
#	$1574 = call stringConcatenate $1572 " "
	move $a0, $t3
	la $a1, string_1573
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1574
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1576 = call toString $138
	lw $a0, 4848($sp)
	jal func__toString
	move $t3, $v0
#	$1578 = call stringConcatenate $1576 " "
	move $a0, $t3
	la $a1, string_1577
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1578
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1580 = call toString $139
	lw $a0, 5528($sp)
	jal func__toString
	move $t3, $v0
#	$1582 = call stringConcatenate $1580 " "
	move $a0, $t3
	la $a1, string_1581
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1582
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1584 = call toString $140
	lw $a0, 2560($sp)
	jal func__toString
	move $t3, $v0
#	$1586 = call stringConcatenate $1584 " "
	move $a0, $t3
	la $a1, string_1585
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1586
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1588 = call toString $141
	lw $a0, 3484($sp)
	jal func__toString
	move $t3, $v0
#	$1590 = call stringConcatenate $1588 " "
	move $a0, $t3
	la $a1, string_1589
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1590
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1592 = call toString $142
	lw $a0, 1972($sp)
	jal func__toString
	move $t3, $v0
#	$1594 = call stringConcatenate $1592 " "
	move $a0, $t3
	la $a1, string_1593
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1594
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1596 = call toString $143
	lw $a0, 6996($sp)
	jal func__toString
	move $t3, $v0
#	$1598 = call stringConcatenate $1596 " "
	move $a0, $t3
	la $a1, string_1597
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1598
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1600 = call toString $144
	lw $a0, 1888($sp)
	jal func__toString
	move $t3, $v0
#	$1602 = call stringConcatenate $1600 " "
	move $a0, $t3
	la $a1, string_1601
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1602
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1604 = call toString $145
	lw $a0, 2600($sp)
	jal func__toString
	move $t3, $v0
#	$1606 = call stringConcatenate $1604 " "
	move $a0, $t3
	la $a1, string_1605
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1606
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1608 = call toString $146
	lw $a0, 616($sp)
	jal func__toString
	move $t3, $v0
#	$1610 = call stringConcatenate $1608 " "
	move $a0, $t3
	la $a1, string_1609
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1610
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1612 = call toString $147
	move $a0, $t9
	jal func__toString
	move $t3, $v0
#	$1614 = call stringConcatenate $1612 " "
	move $a0, $t3
	la $a1, string_1613
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1614
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1616 = call toString $148
	lw $a0, 7696($sp)
	jal func__toString
	move $t3, $v0
#	$1618 = call stringConcatenate $1616 " "
	move $a0, $t3
	la $a1, string_1617
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1618
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1620 = call toString $149
	lw $a0, 6292($sp)
	jal func__toString
	move $t3, $v0
#	$1622 = call stringConcatenate $1620 " "
	move $a0, $t3
	la $a1, string_1621
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1622
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1624 = call toString $150
	lw $a0, 1128($sp)
	jal func__toString
	move $t3, $v0
#	$1626 = call stringConcatenate $1624 " "
	move $a0, $t3
	la $a1, string_1625
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1626
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1628 = call toString $151
	lw $a0, 2500($sp)
	jal func__toString
	move $t3, $v0
#	$1630 = call stringConcatenate $1628 " "
	move $a0, $t3
	la $a1, string_1629
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1630
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1632 = call toString $152
	lw $a0, 2400($sp)
	jal func__toString
	move $t3, $v0
#	$1634 = call stringConcatenate $1632 " "
	move $a0, $t3
	la $a1, string_1633
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1634
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1636 = call toString $153
	lw $a0, 3628($sp)
	jal func__toString
	move $t3, $v0
#	$1638 = call stringConcatenate $1636 " "
	move $a0, $t3
	la $a1, string_1637
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1638
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1640 = call toString $154
	lw $a0, 3216($sp)
	jal func__toString
	move $t3, $v0
#	$1642 = call stringConcatenate $1640 " "
	move $a0, $t3
	la $a1, string_1641
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1642
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1644 = call toString $155
	lw $a0, 6196($sp)
	jal func__toString
	move $t3, $v0
#	$1646 = call stringConcatenate $1644 " "
	move $a0, $t3
	la $a1, string_1645
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1646
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1648 = call toString $156
	lw $a0, 452($sp)
	jal func__toString
	move $t3, $v0
#	$1650 = call stringConcatenate $1648 " "
	move $a0, $t3
	la $a1, string_1649
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1650
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1652 = call toString $157
	lw $a0, 324($sp)
	jal func__toString
	move $t3, $v0
#	$1654 = call stringConcatenate $1652 " "
	move $a0, $t3
	la $a1, string_1653
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1654
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1656 = call toString $158
	lw $a0, 2120($sp)
	jal func__toString
	move $t3, $v0
#	$1658 = call stringConcatenate $1656 " "
	move $a0, $t3
	la $a1, string_1657
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1658
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1660 = call toString $159
	lw $a0, 4388($sp)
	jal func__toString
	move $t3, $v0
#	$1662 = call stringConcatenate $1660 " "
	move $a0, $t3
	la $a1, string_1661
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1662
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1664 = call toString $160
	lw $a0, 7304($sp)
	jal func__toString
	move $t3, $v0
#	$1666 = call stringConcatenate $1664 " "
	move $a0, $t3
	la $a1, string_1665
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1666
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1668 = call toString $161
	lw $a0, 3752($sp)
	jal func__toString
	move $t3, $v0
#	$1670 = call stringConcatenate $1668 " "
	move $a0, $t3
	la $a1, string_1669
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1670
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1672 = call toString $162
	lw $a0, 4336($sp)
	jal func__toString
	move $t3, $v0
#	$1674 = call stringConcatenate $1672 " "
	move $a0, $t3
	la $a1, string_1673
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1674
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1676 = call toString $163
	lw $a0, 7432($sp)
	jal func__toString
	move $t3, $v0
#	$1678 = call stringConcatenate $1676 " "
	move $a0, $t3
	la $a1, string_1677
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1678
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1680 = call toString $164
	lw $a0, 620($sp)
	jal func__toString
	move $t3, $v0
#	$1682 = call stringConcatenate $1680 " "
	move $a0, $t3
	la $a1, string_1681
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1682
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1684 = call toString $165
	lw $a0, 3712($sp)
	jal func__toString
	move $t3, $v0
#	$1686 = call stringConcatenate $1684 " "
	move $a0, $t3
	la $a1, string_1685
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1686
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1688 = call toString $166
	lw $a0, 4576($sp)
	jal func__toString
	move $t3, $v0
#	$1690 = call stringConcatenate $1688 " "
	move $a0, $t3
	la $a1, string_1689
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1690
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1692 = call toString $167
	move $a0, $fp
	jal func__toString
	move $t3, $v0
#	$1694 = call stringConcatenate $1692 " "
	move $a0, $t3
	la $a1, string_1693
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1694
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1696 = call toString $168
	lw $a0, 6024($sp)
	jal func__toString
	move $t3, $v0
#	$1698 = call stringConcatenate $1696 " "
	move $a0, $t3
	la $a1, string_1697
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1698
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1700 = call toString $169
	lw $a0, 7612($sp)
	jal func__toString
	move $t3, $v0
#	$1702 = call stringConcatenate $1700 " "
	move $a0, $t3
	la $a1, string_1701
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1702
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1704 = call toString $170
	lw $a0, 2208($sp)
	jal func__toString
	move $t3, $v0
#	$1706 = call stringConcatenate $1704 " "
	move $a0, $t3
	la $a1, string_1705
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1706
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1708 = call toString $171
	lw $a0, 7672($sp)
	jal func__toString
	move $t3, $v0
#	$1710 = call stringConcatenate $1708 " "
	move $a0, $t3
	la $a1, string_1709
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1710
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1712 = call toString $172
	lw $a0, 6276($sp)
	jal func__toString
	move $t3, $v0
#	$1714 = call stringConcatenate $1712 " "
	move $a0, $t3
	la $a1, string_1713
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1714
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1716 = call toString $173
	lw $a0, 3032($sp)
	jal func__toString
	move $t3, $v0
#	$1718 = call stringConcatenate $1716 " "
	move $a0, $t3
	la $a1, string_1717
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1718
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1720 = call toString $174
	lw $a0, 2180($sp)
	jal func__toString
	move $t3, $v0
#	$1722 = call stringConcatenate $1720 " "
	move $a0, $t3
	la $a1, string_1721
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1722
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1724 = call toString $175
	lw $a0, 2928($sp)
	jal func__toString
	move $t3, $v0
#	$1726 = call stringConcatenate $1724 " "
	move $a0, $t3
	la $a1, string_1725
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1726
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1728 = call toString $176
	lw $a0, 5000($sp)
	jal func__toString
	move $t3, $v0
#	$1730 = call stringConcatenate $1728 " "
	move $a0, $t3
	la $a1, string_1729
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1730
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1732 = call toString $177
	lw $a0, 2112($sp)
	jal func__toString
	move $t3, $v0
#	$1734 = call stringConcatenate $1732 " "
	move $a0, $t3
	la $a1, string_1733
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1734
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1736 = call toString $178
	lw $a0, 4800($sp)
	jal func__toString
	sw $v0, 8316($sp)
#	$1738 = call stringConcatenate $1736 " "
	lw $a0, 8316($sp)
	la $a1, string_1737
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1738
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1740 = call toString $179
	lw $a0, 564($sp)
	jal func__toString
	move $t3, $v0
#	$1742 = call stringConcatenate $1740 " "
	move $a0, $t3
	la $a1, string_1741
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1742
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1744 = call toString $180
	lw $a0, 548($sp)
	jal func__toString
	move $t3, $v0
#	$1746 = call stringConcatenate $1744 " "
	move $a0, $t3
	la $a1, string_1745
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1746
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1748 = call toString $181
	lw $a0, 1056($sp)
	jal func__toString
	move $t3, $v0
#	$1750 = call stringConcatenate $1748 " "
	move $a0, $t3
	la $a1, string_1749
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1750
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1752 = call toString $182
	lw $a0, 7284($sp)
	jal func__toString
	move $t3, $v0
#	$1754 = call stringConcatenate $1752 " "
	move $a0, $t3
	la $a1, string_1753
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1754
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1756 = call toString $183
	lw $a0, 1632($sp)
	jal func__toString
	move $t3, $v0
#	$1758 = call stringConcatenate $1756 " "
	move $a0, $t3
	la $a1, string_1757
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1758
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1760 = call toString $184
	lw $a0, 7032($sp)
	jal func__toString
	sw $v0, 8320($sp)
#	$1762 = call stringConcatenate $1760 " "
	lw $a0, 8320($sp)
	la $a1, string_1761
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1762
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1764 = call toString $185
	lw $a0, 300($sp)
	jal func__toString
	sw $v0, 8328($sp)
#	$1766 = call stringConcatenate $1764 " "
	lw $a0, 8328($sp)
	la $a1, string_1765
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1766
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1768 = call toString $186
	lw $a0, 5492($sp)
	jal func__toString
	move $t3, $v0
#	$1770 = call stringConcatenate $1768 " "
	move $a0, $t3
	la $a1, string_1769
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1770
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1772 = call toString $187
	lw $a0, 4912($sp)
	jal func__toString
	move $t3, $v0
#	$1774 = call stringConcatenate $1772 " "
	move $a0, $t3
	la $a1, string_1773
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1774
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1776 = call toString $188
	lw $a0, 684($sp)
	jal func__toString
	move $t3, $v0
#	$1778 = call stringConcatenate $1776 " "
	move $a0, $t3
	la $a1, string_1777
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1778
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1780 = call toString $189
	lw $a0, 3296($sp)
	jal func__toString
	move $t3, $v0
#	$1782 = call stringConcatenate $1780 " "
	move $a0, $t3
	la $a1, string_1781
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1782
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1784 = call toString $190
	lw $a0, 7360($sp)
	jal func__toString
	move $t3, $v0
#	$1786 = call stringConcatenate $1784 " "
	move $a0, $t3
	la $a1, string_1785
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1786
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1788 = call toString $191
	lw $a0, 5804($sp)
	jal func__toString
	move $t3, $v0
#	$1790 = call stringConcatenate $1788 " "
	move $a0, $t3
	la $a1, string_1789
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1790
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1792 = call toString $192
	lw $a0, 5348($sp)
	jal func__toString
	move $t3, $v0
#	$1794 = call stringConcatenate $1792 " "
	move $a0, $t3
	la $a1, string_1793
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1794
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1796 = call toString $193
	lw $a0, 3824($sp)
	jal func__toString
	move $t3, $v0
#	$1798 = call stringConcatenate $1796 " "
	move $a0, $t3
	la $a1, string_1797
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1798
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1800 = call toString $194
	lw $a0, 2836($sp)
	jal func__toString
	move $t3, $v0
#	$1802 = call stringConcatenate $1800 " "
	move $a0, $t3
	la $a1, string_1801
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1802
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1804 = call toString $195
	lw $a0, 1616($sp)
	jal func__toString
	move $t3, $v0
#	$1806 = call stringConcatenate $1804 " "
	move $a0, $t3
	la $a1, string_1805
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1806
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1808 = call toString $196
	lw $a0, 4776($sp)
	jal func__toString
	move $t3, $v0
#	$1810 = call stringConcatenate $1808 " "
	move $a0, $t3
	la $a1, string_1809
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1810
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1812 = call toString $197
	lw $a0, 920($sp)
	jal func__toString
	move $t3, $v0
#	$1814 = call stringConcatenate $1812 " "
	move $a0, $t3
	la $a1, string_1813
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1814
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1816 = call toString $198
	lw $a0, 552($sp)
	jal func__toString
	move $t3, $v0
#	$1818 = call stringConcatenate $1816 " "
	move $a0, $t3
	la $a1, string_1817
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1818
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1820 = call toString $199
	lw $a0, 6800($sp)
	jal func__toString
	move $t3, $v0
#	$1822 = call stringConcatenate $1820 " "
	move $a0, $t3
	la $a1, string_1821
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1822
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1824 = call toString $200
	lw $a0, 4696($sp)
	jal func__toString
	move $t3, $v0
#	$1826 = call stringConcatenate $1824 " "
	move $a0, $t3
	la $a1, string_1825
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1826
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1828 = call toString $201
	lw $a0, 712($sp)
	jal func__toString
	move $t3, $v0
#	$1830 = call stringConcatenate $1828 " "
	move $a0, $t3
	la $a1, string_1829
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1830
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1832 = call toString $202
	lw $a0, 3852($sp)
	jal func__toString
	move $t3, $v0
#	$1834 = call stringConcatenate $1832 " "
	move $a0, $t3
	la $a1, string_1833
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1834
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1836 = call toString $203
	lw $a0, 1736($sp)
	jal func__toString
	move $t3, $v0
#	$1838 = call stringConcatenate $1836 " "
	move $a0, $t3
	la $a1, string_1837
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1838
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1840 = call toString $204
	lw $a0, 908($sp)
	jal func__toString
	move $t3, $v0
#	$1842 = call stringConcatenate $1840 " "
	move $a0, $t3
	la $a1, string_1841
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1842
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1844 = call toString $205
	lw $a0, 4616($sp)
	jal func__toString
	move $t3, $v0
#	$1846 = call stringConcatenate $1844 " "
	move $a0, $t3
	la $a1, string_1845
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1846
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1848 = call toString $206
	lw $a0, 2088($sp)
	jal func__toString
	move $t3, $v0
#	$1850 = call stringConcatenate $1848 " "
	move $a0, $t3
	la $a1, string_1849
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1850
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1852 = call toString $207
	lw $a0, 4864($sp)
	jal func__toString
	move $t3, $v0
#	$1854 = call stringConcatenate $1852 " "
	move $a0, $t3
	la $a1, string_1853
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1854
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1856 = call toString $208
	lw $a0, 5760($sp)
	jal func__toString
	move $t3, $v0
#	$1858 = call stringConcatenate $1856 " "
	move $a0, $t3
	la $a1, string_1857
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1858
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1860 = call toString $209
	lw $a0, 1704($sp)
	jal func__toString
	move $t3, $v0
#	$1862 = call stringConcatenate $1860 " "
	move $a0, $t3
	la $a1, string_1861
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1862
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1864 = call toString $210
	lw $a0, 392($sp)
	jal func__toString
	move $t3, $v0
#	$1866 = call stringConcatenate $1864 " "
	move $a0, $t3
	la $a1, string_1865
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1866
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1868 = call toString $211
	lw $a0, 3236($sp)
	jal func__toString
	move $t3, $v0
#	$1870 = call stringConcatenate $1868 " "
	move $a0, $t3
	la $a1, string_1869
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1870
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1872 = call toString $212
	lw $a0, 6384($sp)
	jal func__toString
	move $t3, $v0
#	$1874 = call stringConcatenate $1872 " "
	move $a0, $t3
	la $a1, string_1873
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1874
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1876 = call toString $213
	lw $a0, 3948($sp)
	jal func__toString
	move $t3, $v0
#	$1878 = call stringConcatenate $1876 " "
	move $a0, $t3
	la $a1, string_1877
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1878
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1880 = call toString $214
	lw $a0, 848($sp)
	jal func__toString
	move $t3, $v0
#	$1882 = call stringConcatenate $1880 " "
	move $a0, $t3
	la $a1, string_1881
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1882
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1884 = call toString $215
	lw $a0, 7108($sp)
	jal func__toString
	move $t3, $v0
#	$1886 = call stringConcatenate $1884 " "
	move $a0, $t3
	la $a1, string_1885
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1886
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1888 = call toString $216
	lw $a0, 2076($sp)
	jal func__toString
	move $t3, $v0
#	$1890 = call stringConcatenate $1888 " "
	move $a0, $t3
	la $a1, string_1889
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1890
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1892 = call toString $217
	lw $a0, 2040($sp)
	jal func__toString
	move $t3, $v0
#	$1894 = call stringConcatenate $1892 " "
	move $a0, $t3
	la $a1, string_1893
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1894
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1896 = call toString $218
	lw $a0, 5180($sp)
	jal func__toString
	move $t3, $v0
#	$1898 = call stringConcatenate $1896 " "
	move $a0, $t3
	la $a1, string_1897
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1898
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1900 = call toString $219
	lw $a0, 1136($sp)
	jal func__toString
	move $t3, $v0
#	$1902 = call stringConcatenate $1900 " "
	move $a0, $t3
	la $a1, string_1901
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1902
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1904 = call toString $220
	lw $a0, 444($sp)
	jal func__toString
	move $t3, $v0
#	$1906 = call stringConcatenate $1904 " "
	move $a0, $t3
	la $a1, string_1905
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1906
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1908 = call toString $221
	lw $a0, 2124($sp)
	jal func__toString
	move $t3, $v0
#	$1910 = call stringConcatenate $1908 " "
	move $a0, $t3
	la $a1, string_1909
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1910
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1912 = call toString $222
	lw $a0, 3396($sp)
	jal func__toString
	move $t3, $v0
#	$1914 = call stringConcatenate $1912 " "
	move $a0, $t3
	la $a1, string_1913
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1914
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1916 = call toString $223
	lw $a0, 5116($sp)
	jal func__toString
	move $t3, $v0
#	$1918 = call stringConcatenate $1916 " "
	move $a0, $t3
	la $a1, string_1917
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1918
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1920 = call toString $224
	lw $a0, 4748($sp)
	jal func__toString
	move $t3, $v0
#	$1922 = call stringConcatenate $1920 " "
	move $a0, $t3
	la $a1, string_1921
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1922
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1924 = call toString $225
	lw $a0, 7176($sp)
	jal func__toString
	move $t3, $v0
#	$1926 = call stringConcatenate $1924 " "
	move $a0, $t3
	la $a1, string_1925
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1926
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1928 = call toString $226
	lw $a0, 1840($sp)
	jal func__toString
	move $t3, $v0
#	$1930 = call stringConcatenate $1928 " "
	move $a0, $t3
	la $a1, string_1929
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1930
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1932 = call toString $227
	lw $a0, 4488($sp)
	jal func__toString
	move $t3, $v0
#	$1934 = call stringConcatenate $1932 " "
	move $a0, $t3
	la $a1, string_1933
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1934
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1936 = call toString $228
	lw $a0, 5224($sp)
	jal func__toString
	move $t3, $v0
#	$1938 = call stringConcatenate $1936 " "
	move $a0, $t3
	la $a1, string_1937
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1938
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1940 = call toString $229
	lw $a0, 3064($sp)
	jal func__toString
	move $t3, $v0
#	$1942 = call stringConcatenate $1940 " "
	move $a0, $t3
	la $a1, string_1941
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1942
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1944 = call toString $230
	lw $a0, 4936($sp)
	jal func__toString
	move $t3, $v0
#	$1946 = call stringConcatenate $1944 " "
	move $a0, $t3
	la $a1, string_1945
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1946
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1948 = call toString $231
	lw $a0, 3952($sp)
	jal func__toString
	move $t3, $v0
#	$1950 = call stringConcatenate $1948 " "
	move $a0, $t3
	la $a1, string_1949
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1950
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1952 = call toString $232
	lw $a0, 4648($sp)
	jal func__toString
	move $t3, $v0
#	$1954 = call stringConcatenate $1952 " "
	move $a0, $t3
	la $a1, string_1953
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1954
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1956 = call toString $233
	lw $a0, 5192($sp)
	jal func__toString
	move $t3, $v0
#	$1958 = call stringConcatenate $1956 " "
	move $a0, $t3
	la $a1, string_1957
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1958
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1960 = call toString $234
	lw $a0, 536($sp)
	jal func__toString
	move $t3, $v0
#	$1962 = call stringConcatenate $1960 " "
	move $a0, $t3
	la $a1, string_1961
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1962
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1964 = call toString $235
	lw $a0, 1796($sp)
	jal func__toString
	move $t3, $v0
#	$1966 = call stringConcatenate $1964 " "
	move $a0, $t3
	la $a1, string_1965
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1966
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1968 = call toString $236
	lw $a0, 6876($sp)
	jal func__toString
	move $t3, $v0
#	$1970 = call stringConcatenate $1968 " "
	move $a0, $t3
	la $a1, string_1969
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1970
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1972 = call toString $237
	lw $a0, 7292($sp)
	jal func__toString
	move $t3, $v0
#	$1974 = call stringConcatenate $1972 " "
	move $a0, $t3
	la $a1, string_1973
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1974
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1976 = call toString $238
	lw $a0, 2992($sp)
	jal func__toString
	move $t3, $v0
#	$1978 = call stringConcatenate $1976 " "
	move $a0, $t3
	la $a1, string_1977
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1978
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1980 = call toString $239
	lw $a0, 824($sp)
	jal func__toString
	move $t3, $v0
#	$1982 = call stringConcatenate $1980 " "
	move $a0, $t3
	la $a1, string_1981
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1982
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1984 = call toString $240
	lw $a0, 7500($sp)
	jal func__toString
	move $t3, $v0
#	$1986 = call stringConcatenate $1984 " "
	move $a0, $t3
	la $a1, string_1985
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1986
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1988 = call toString $241
	lw $a0, 6116($sp)
	jal func__toString
	move $t3, $v0
#	$1990 = call stringConcatenate $1988 " "
	move $a0, $t3
	la $a1, string_1989
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1990
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1992 = call toString $242
	lw $a0, 3716($sp)
	jal func__toString
	move $t3, $v0
#	$1994 = call stringConcatenate $1992 " "
	move $a0, $t3
	la $a1, string_1993
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1994
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$1996 = call toString $243
	lw $a0, 5424($sp)
	jal func__toString
	move $t3, $v0
#	$1998 = call stringConcatenate $1996 " "
	move $a0, $t3
	la $a1, string_1997
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $1998
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2000 = call toString $244
	lw $a0, 1376($sp)
	jal func__toString
	move $t3, $v0
#	$2002 = call stringConcatenate $2000 " "
	move $a0, $t3
	la $a1, string_2001
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2002
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2004 = call toString $245
	lw $a0, 4320($sp)
	jal func__toString
	move $t3, $v0
#	$2006 = call stringConcatenate $2004 " "
	move $a0, $t3
	la $a1, string_2005
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2006
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2008 = call toString $246
	lw $a0, 3460($sp)
	jal func__toString
	move $t3, $v0
#	$2010 = call stringConcatenate $2008 " "
	move $a0, $t3
	la $a1, string_2009
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2010
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2012 = call toString $247
	lw $a0, 7456($sp)
	jal func__toString
	move $t3, $v0
#	$2014 = call stringConcatenate $2012 " "
	move $a0, $t3
	la $a1, string_2013
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2014
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2016 = call toString $248
	lw $a0, 1148($sp)
	jal func__toString
	move $t3, $v0
#	$2018 = call stringConcatenate $2016 " "
	move $a0, $t3
	la $a1, string_2017
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2018
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2020 = call toString $249
	lw $a0, 3052($sp)
	jal func__toString
	move $t3, $v0
#	$2022 = call stringConcatenate $2020 " "
	move $a0, $t3
	la $a1, string_2021
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2022
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2024 = call toString $250
	lw $a0, 5464($sp)
	jal func__toString
	move $t3, $v0
#	$2026 = call stringConcatenate $2024 " "
	move $a0, $t3
	la $a1, string_2025
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2026
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2028 = call toString $251
	lw $a0, 932($sp)
	jal func__toString
	move $t3, $v0
#	$2030 = call stringConcatenate $2028 " "
	move $a0, $t3
	la $a1, string_2029
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2030
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2032 = call toString $252
	lw $a0, 6076($sp)
	jal func__toString
	move $t3, $v0
#	$2034 = call stringConcatenate $2032 " "
	move $a0, $t3
	la $a1, string_2033
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2034
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2036 = call toString $253
	lw $a0, 1480($sp)
	jal func__toString
	move $t3, $v0
#	$2038 = call stringConcatenate $2036 " "
	move $a0, $t3
	la $a1, string_2037
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2038
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2040 = call toString $254
	move $a0, $t7
	jal func__toString
	move $t3, $v0
#	$2042 = call stringConcatenate $2040 " "
	move $a0, $t3
	la $a1, string_2041
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2042
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2044 = call toString $255
	lw $a0, 5476($sp)
	jal func__toString
	move $t3, $v0
#	$2046 = call stringConcatenate $2044 " "
	move $a0, $t3
	la $a1, string_2045
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2046
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2048 = call toString $256
	lw $a0, 4192($sp)
	jal func__toString
	move $t3, $v0
#	$2050 = call stringConcatenate $2048 " "
	move $a0, $t3
	la $a1, string_2049
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2050
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2052 = call toString $257
	lw $a0, 5908($sp)
	jal func__toString
	move $t3, $v0
#	$2054 = call stringConcatenate $2052 " "
	move $a0, $t3
	la $a1, string_2053
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2054
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2056 = call toString $258
	lw $a0, 4384($sp)
	jal func__toString
	move $t3, $v0
#	$2058 = call stringConcatenate $2056 " "
	move $a0, $t3
	la $a1, string_2057
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2058
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2060 = call toString $259
	lw $a0, 3024($sp)
	jal func__toString
	move $t3, $v0
#	$2062 = call stringConcatenate $2060 " "
	move $a0, $t3
	la $a1, string_2061
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2062
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2064 = call toString $260
	lw $a0, 4532($sp)
	jal func__toString
	move $t3, $v0
#	$2066 = call stringConcatenate $2064 " "
	move $a0, $t3
	la $a1, string_2065
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2066
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2068 = call toString $261
	lw $a0, 5420($sp)
	jal func__toString
	move $t3, $v0
#	$2070 = call stringConcatenate $2068 " "
	move $a0, $t3
	la $a1, string_2069
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2070
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2072 = call toString $262
	move $a0, $s0
	jal func__toString
	move $t3, $v0
#	$2074 = call stringConcatenate $2072 " "
	move $a0, $t3
	la $a1, string_2073
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2074
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2076 = call toString $263
	lw $a0, 4500($sp)
	jal func__toString
	move $t3, $v0
#	$2078 = call stringConcatenate $2076 " "
	move $a0, $t3
	la $a1, string_2077
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2078
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2080 = call toString $264
	move $a0, $s6
	jal func__toString
	move $t3, $v0
#	$2082 = call stringConcatenate $2080 " "
	move $a0, $t3
	la $a1, string_2081
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2082
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2084 = call toString $265
	lw $a0, 3656($sp)
	jal func__toString
	move $t3, $v0
#	$2086 = call stringConcatenate $2084 " "
	move $a0, $t3
	la $a1, string_2085
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2086
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2088 = call toString $266
	lw $a0, 6324($sp)
	jal func__toString
	move $t3, $v0
#	$2090 = call stringConcatenate $2088 " "
	move $a0, $t3
	la $a1, string_2089
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2090
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2092 = call toString $267
	lw $a0, 6756($sp)
	jal func__toString
	move $t3, $v0
#	$2094 = call stringConcatenate $2092 " "
	move $a0, $t3
	la $a1, string_2093
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2094
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2096 = call toString $268
	lw $a0, 2848($sp)
	jal func__toString
	move $t3, $v0
#	$2098 = call stringConcatenate $2096 " "
	move $a0, $t3
	la $a1, string_2097
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2098
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2100 = call toString $269
	lw $a0, 7116($sp)
	jal func__toString
	move $t3, $v0
#	$2102 = call stringConcatenate $2100 " "
	move $a0, $t3
	la $a1, string_2101
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2102
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2104 = call toString $270
	lw $a0, 1252($sp)
	jal func__toString
	move $t3, $v0
#	$2106 = call stringConcatenate $2104 " "
	move $a0, $t3
	la $a1, string_2105
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2106
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2108 = call toString $271
	lw $a0, 7244($sp)
	jal func__toString
	move $t3, $v0
#	$2110 = call stringConcatenate $2108 " "
	move $a0, $t3
	la $a1, string_2109
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2110
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2112 = call toString $272
	lw $a0, 2540($sp)
	jal func__toString
	move $t3, $v0
#	$2114 = call stringConcatenate $2112 " "
	move $a0, $t3
	la $a1, string_2113
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2114
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2116 = call toString $273
	lw $a0, 3536($sp)
	jal func__toString
	move $t3, $v0
#	$2118 = call stringConcatenate $2116 " "
	move $a0, $t3
	la $a1, string_2117
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2118
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2120 = call toString $274
	lw $a0, 1084($sp)
	jal func__toString
	move $t3, $v0
#	$2122 = call stringConcatenate $2120 " "
	move $a0, $t3
	la $a1, string_2121
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2122
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2124 = call toString $275
	lw $a0, 3800($sp)
	jal func__toString
	move $t3, $v0
#	$2126 = call stringConcatenate $2124 " "
	move $a0, $t3
	la $a1, string_2125
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2126
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2128 = call toString $276
	lw $a0, 3836($sp)
	jal func__toString
	move $t3, $v0
#	$2130 = call stringConcatenate $2128 " "
	move $a0, $t3
	la $a1, string_2129
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2130
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2132 = call toString $277
	lw $a0, 5536($sp)
	jal func__toString
	move $t3, $v0
#	$2134 = call stringConcatenate $2132 " "
	move $a0, $t3
	la $a1, string_2133
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2134
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2136 = call toString $278
	lw $a0, 1424($sp)
	jal func__toString
	move $t3, $v0
#	$2138 = call stringConcatenate $2136 " "
	move $a0, $t3
	la $a1, string_2137
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2138
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2140 = call toString $279
	lw $a0, 2264($sp)
	jal func__toString
	move $t3, $v0
#	$2142 = call stringConcatenate $2140 " "
	move $a0, $t3
	la $a1, string_2141
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2142
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2144 = call toString $280
	lw $a0, 2204($sp)
	jal func__toString
	move $t3, $v0
#	$2146 = call stringConcatenate $2144 " "
	move $a0, $t3
	la $a1, string_2145
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2146
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2148 = call toString $281
	lw $a0, 5660($sp)
	jal func__toString
	move $t3, $v0
#	$2150 = call stringConcatenate $2148 " "
	move $a0, $t3
	la $a1, string_2149
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2150
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2152 = call toString $282
	move $a0, $s4
	jal func__toString
	move $t3, $v0
#	$2154 = call stringConcatenate $2152 " "
	move $a0, $t3
	la $a1, string_2153
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2154
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2156 = call toString $283
	lw $a0, 2796($sp)
	jal func__toString
	move $t3, $v0
#	$2158 = call stringConcatenate $2156 " "
	move $a0, $t3
	la $a1, string_2157
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2158
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2160 = call toString $284
	lw $a0, 5184($sp)
	jal func__toString
	move $t3, $v0
#	$2162 = call stringConcatenate $2160 " "
	move $a0, $t3
	la $a1, string_2161
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2162
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2164 = call toString $285
	lw $a0, 3552($sp)
	jal func__toString
	move $t3, $v0
#	$2166 = call stringConcatenate $2164 " "
	move $a0, $t3
	la $a1, string_2165
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2166
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2168 = call toString $286
	lw $a0, 1960($sp)
	jal func__toString
	move $t3, $v0
#	$2170 = call stringConcatenate $2168 " "
	move $a0, $t3
	la $a1, string_2169
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2170
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2172 = call toString $287
	lw $a0, 2388($sp)
	jal func__toString
	move $t3, $v0
#	$2174 = call stringConcatenate $2172 " "
	move $a0, $t3
	la $a1, string_2173
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2174
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2176 = call toString $288
	lw $a0, 7656($sp)
	jal func__toString
	move $t3, $v0
#	$2178 = call stringConcatenate $2176 " "
	move $a0, $t3
	la $a1, string_2177
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2178
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2180 = call toString $289
	lw $a0, 2912($sp)
	jal func__toString
	move $t3, $v0
#	$2182 = call stringConcatenate $2180 " "
	move $a0, $t3
	la $a1, string_2181
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2182
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2184 = call toString $290
	lw $a0, 1468($sp)
	jal func__toString
	move $t3, $v0
#	$2186 = call stringConcatenate $2184 " "
	move $a0, $t3
	la $a1, string_2185
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2186
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2188 = call toString $291
	lw $a0, 6240($sp)
	jal func__toString
	move $t3, $v0
#	$2190 = call stringConcatenate $2188 " "
	move $a0, $t3
	la $a1, string_2189
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2190
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2192 = call toString $292
	lw $a0, 4668($sp)
	jal func__toString
	move $t3, $v0
#	$2194 = call stringConcatenate $2192 " "
	move $a0, $t3
	la $a1, string_2193
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2194
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2196 = call toString $293
	lw $a0, 936($sp)
	jal func__toString
	move $t3, $v0
#	$2198 = call stringConcatenate $2196 " "
	move $a0, $t3
	la $a1, string_2197
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2198
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2200 = call toString $294
	lw $a0, 996($sp)
	jal func__toString
	move $t3, $v0
#	$2202 = call stringConcatenate $2200 " "
	move $a0, $t3
	la $a1, string_2201
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2202
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2204 = call toString $295
	lw $a0, 2724($sp)
	jal func__toString
	move $t3, $v0
#	$2206 = call stringConcatenate $2204 " "
	move $a0, $t3
	la $a1, string_2205
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2206
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2208 = call toString $296
	lw $a0, 2368($sp)
	jal func__toString
	move $t3, $v0
#	$2210 = call stringConcatenate $2208 " "
	move $a0, $t3
	la $a1, string_2209
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2210
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2212 = call toString $297
	lw $a0, 136($sp)
	jal func__toString
	move $t3, $v0
#	$2214 = call stringConcatenate $2212 " "
	move $a0, $t3
	la $a1, string_2213
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2214
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2216 = call toString $298
	lw $a0, 3556($sp)
	jal func__toString
	move $t3, $v0
#	$2218 = call stringConcatenate $2216 " "
	move $a0, $t3
	la $a1, string_2217
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2218
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2220 = call toString $299
	lw $a0, 5296($sp)
	jal func__toString
	move $t3, $v0
#	$2222 = call stringConcatenate $2220 " "
	move $a0, $t3
	la $a1, string_2221
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2222
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2224 = call toString $300
	lw $a0, 4948($sp)
	jal func__toString
	move $t3, $v0
#	$2226 = call stringConcatenate $2224 " "
	move $a0, $t3
	la $a1, string_2225
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2226
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2228 = call toString $301
	lw $a0, 5160($sp)
	jal func__toString
	move $t3, $v0
#	$2230 = call stringConcatenate $2228 " "
	move $a0, $t3
	la $a1, string_2229
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2230
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2232 = call toString $302
	lw $a0, 2964($sp)
	jal func__toString
	move $t3, $v0
#	$2234 = call stringConcatenate $2232 " "
	move $a0, $t3
	la $a1, string_2233
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2234
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2236 = call toString $303
	lw $a0, 5452($sp)
	jal func__toString
	move $t3, $v0
#	$2238 = call stringConcatenate $2236 " "
	move $a0, $t3
	la $a1, string_2237
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2238
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2240 = call toString $304
	lw $a0, 1860($sp)
	jal func__toString
	move $t3, $v0
#	$2242 = call stringConcatenate $2240 " "
	move $a0, $t3
	la $a1, string_2241
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2242
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2244 = call toString $305
	lw $a0, 2332($sp)
	jal func__toString
	move $t3, $v0
#	$2246 = call stringConcatenate $2244 " "
	move $a0, $t3
	la $a1, string_2245
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2246
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2248 = call toString $306
	lw $a0, 5672($sp)
	jal func__toString
	move $t3, $v0
#	$2250 = call stringConcatenate $2248 " "
	move $a0, $t3
	la $a1, string_2249
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2250
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2252 = call toString $307
	lw $a0, 6912($sp)
	jal func__toString
	move $t3, $v0
#	$2254 = call stringConcatenate $2252 " "
	move $a0, $t3
	la $a1, string_2253
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2254
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2256 = call toString $308
	lw $a0, 1280($sp)
	jal func__toString
	move $t3, $v0
#	$2258 = call stringConcatenate $2256 " "
	move $a0, $t3
	la $a1, string_2257
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2258
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2260 = call toString $309
	move $a0, $t6
	jal func__toString
	move $t3, $v0
#	$2262 = call stringConcatenate $2260 " "
	move $a0, $t3
	la $a1, string_2261
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2262
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2264 = call toString $310
	lw $a0, 5128($sp)
	jal func__toString
	move $t3, $v0
#	$2266 = call stringConcatenate $2264 " "
	move $a0, $t3
	la $a1, string_2265
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2266
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2268 = call toString $311
	lw $a0, 6552($sp)
	jal func__toString
	move $t3, $v0
#	$2270 = call stringConcatenate $2268 " "
	move $a0, $t3
	la $a1, string_2269
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2270
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2272 = call toString $312
	lw $a0, 7000($sp)
	jal func__toString
	move $t3, $v0
#	$2274 = call stringConcatenate $2272 " "
	move $a0, $t3
	la $a1, string_2273
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2274
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2276 = call toString $313
	lw $a0, 2780($sp)
	jal func__toString
	move $t3, $v0
#	$2278 = call stringConcatenate $2276 " "
	move $a0, $t3
	la $a1, string_2277
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2278
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2280 = call toString $314
	move $a0, $t4
	jal func__toString
	move $t3, $v0
#	$2282 = call stringConcatenate $2280 " "
	move $a0, $t3
	la $a1, string_2281
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2282
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2284 = call toString $315
	lw $a0, 1192($sp)
	jal func__toString
	move $t3, $v0
#	$2286 = call stringConcatenate $2284 " "
	move $a0, $t3
	la $a1, string_2285
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2286
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2288 = call toString $316
	lw $a0, 2700($sp)
	jal func__toString
	move $t3, $v0
#	$2290 = call stringConcatenate $2288 " "
	move $a0, $t3
	la $a1, string_2289
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2290
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2292 = call toString $317
	lw $a0, 2472($sp)
	jal func__toString
	move $t3, $v0
#	$2294 = call stringConcatenate $2292 " "
	move $a0, $t3
	la $a1, string_2293
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2294
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2296 = call toString $318
	lw $a0, 1540($sp)
	jal func__toString
	move $t3, $v0
#	$2298 = call stringConcatenate $2296 " "
	move $a0, $t3
	la $a1, string_2297
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2298
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2300 = call toString $319
	lw $a0, 2580($sp)
	jal func__toString
	move $t3, $v0
#	$2302 = call stringConcatenate $2300 " "
	move $a0, $t3
	la $a1, string_2301
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2302
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2304 = call toString $320
	lw $a0, 5148($sp)
	jal func__toString
	move $t3, $v0
#	$2306 = call stringConcatenate $2304 " "
	move $a0, $t3
	la $a1, string_2305
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2306
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2308 = call toString $321
	lw $a0, 3684($sp)
	jal func__toString
	move $t3, $v0
#	$2310 = call stringConcatenate $2308 " "
	move $a0, $t3
	la $a1, string_2309
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2310
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2312 = call toString $322
	lw $a0, 460($sp)
	jal func__toString
	move $t3, $v0
#	$2314 = call stringConcatenate $2312 " "
	move $a0, $t3
	la $a1, string_2313
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2314
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2316 = call toString $323
	lw $a0, 7200($sp)
	jal func__toString
	move $t3, $v0
#	$2318 = call stringConcatenate $2316 " "
	move $a0, $t3
	la $a1, string_2317
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2318
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2320 = call toString $324
	lw $a0, 7336($sp)
	jal func__toString
	move $t3, $v0
#	$2322 = call stringConcatenate $2320 " "
	move $a0, $t3
	la $a1, string_2321
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2322
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2324 = call toString $325
	lw $a0, 5232($sp)
	jal func__toString
	move $t3, $v0
#	$2326 = call stringConcatenate $2324 " "
	move $a0, $t3
	la $a1, string_2325
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2326
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2328 = call toString $326
	move $a0, $k1
	jal func__toString
	move $t3, $v0
#	$2330 = call stringConcatenate $2328 " "
	move $a0, $t3
	la $a1, string_2329
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2330
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2332 = call toString $327
	lw $a0, 3704($sp)
	jal func__toString
	move $t3, $v0
#	$2334 = call stringConcatenate $2332 " "
	move $a0, $t3
	la $a1, string_2333
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2334
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2336 = call toString $328
	lw $a0, 1412($sp)
	jal func__toString
	move $t3, $v0
#	$2338 = call stringConcatenate $2336 " "
	move $a0, $t3
	la $a1, string_2337
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2338
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2340 = call toString $329
	lw $a0, 4128($sp)
	jal func__toString
	move $t3, $v0
#	$2342 = call stringConcatenate $2340 " "
	move $a0, $t3
	la $a1, string_2341
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2342
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2344 = call toString $330
	lw $a0, 2932($sp)
	jal func__toString
	move $t3, $v0
#	$2346 = call stringConcatenate $2344 " "
	move $a0, $t3
	la $a1, string_2345
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2346
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2348 = call toString $331
	lw $a0, 2676($sp)
	jal func__toString
	move $t3, $v0
#	$2350 = call stringConcatenate $2348 " "
	move $a0, $t3
	la $a1, string_2349
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2350
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2352 = call toString $332
	lw $a0, 3644($sp)
	jal func__toString
	move $t3, $v0
#	$2354 = call stringConcatenate $2352 " "
	move $a0, $t3
	la $a1, string_2353
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2354
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2356 = call toString $333
	lw $a0, 172($sp)
	jal func__toString
	move $t3, $v0
#	$2358 = call stringConcatenate $2356 " "
	move $a0, $t3
	la $a1, string_2357
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2358
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2360 = call toString $334
	lw $a0, 7092($sp)
	jal func__toString
	move $t3, $v0
#	$2362 = call stringConcatenate $2360 " "
	move $a0, $t3
	la $a1, string_2361
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2362
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2364 = call toString $335
	lw $a0, 6028($sp)
	jal func__toString
	move $t3, $v0
#	$2366 = call stringConcatenate $2364 " "
	move $a0, $t3
	la $a1, string_2365
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2366
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2368 = call toString $336
	move $a0, $t5
	jal func__toString
	move $t3, $v0
#	$2370 = call stringConcatenate $2368 " "
	move $a0, $t3
	la $a1, string_2369
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2370
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2372 = call toString $337
	lw $a0, 5516($sp)
	jal func__toString
	move $t3, $v0
#	$2374 = call stringConcatenate $2372 " "
	move $a0, $t3
	la $a1, string_2373
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $2374
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	$2376 = call toString $338
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	$2378 = call stringConcatenate $2376 " "
	move $a0, $t2
	la $a1, string_2377
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2378
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2380 = call toString $339
	lw $a0, 5624($sp)
	jal func__toString
	move $t2, $v0
#	$2382 = call stringConcatenate $2380 " "
	move $a0, $t2
	la $a1, string_2381
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2382
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2384 = call toString $340
	lw $a0, 5836($sp)
	jal func__toString
	move $t2, $v0
#	$2386 = call stringConcatenate $2384 " "
	move $a0, $t2
	la $a1, string_2385
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2386
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2388 = call toString $341
	lw $a0, 5828($sp)
	jal func__toString
	move $t2, $v0
#	$2390 = call stringConcatenate $2388 " "
	move $a0, $t2
	la $a1, string_2389
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2390
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2392 = call toString $342
	lw $a0, 584($sp)
	jal func__toString
	move $t2, $v0
#	$2394 = call stringConcatenate $2392 " "
	move $a0, $t2
	la $a1, string_2393
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2394
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2396 = call toString $343
	lw $a0, 216($sp)
	jal func__toString
	move $t2, $v0
#	$2398 = call stringConcatenate $2396 " "
	move $a0, $t2
	la $a1, string_2397
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2398
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2400 = call toString $344
	move $a0, $s1
	jal func__toString
	move $t2, $v0
#	$2402 = call stringConcatenate $2400 " "
	move $a0, $t2
	la $a1, string_2401
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2402
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2404 = call toString $345
	lw $a0, 1016($sp)
	jal func__toString
	move $t2, $v0
#	$2406 = call stringConcatenate $2404 " "
	move $a0, $t2
	la $a1, string_2405
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2406
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2408 = call toString $346
	lw $a0, 2256($sp)
	jal func__toString
	move $t2, $v0
#	$2410 = call stringConcatenate $2408 " "
	move $a0, $t2
	la $a1, string_2409
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2410
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2412 = call toString $347
	lw $a0, 2768($sp)
	jal func__toString
	move $t2, $v0
#	$2414 = call stringConcatenate $2412 " "
	move $a0, $t2
	la $a1, string_2413
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2414
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2416 = call toString $348
	lw $a0, 1776($sp)
	jal func__toString
	move $t2, $v0
#	$2418 = call stringConcatenate $2416 " "
	move $a0, $t2
	la $a1, string_2417
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2418
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2420 = call toString $349
	lw $a0, 6684($sp)
	jal func__toString
	move $t2, $v0
#	$2422 = call stringConcatenate $2420 " "
	move $a0, $t2
	la $a1, string_2421
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2422
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2424 = call toString $350
	lw $a0, 288($sp)
	jal func__toString
	move $t2, $v0
#	$2426 = call stringConcatenate $2424 " "
	move $a0, $t2
	la $a1, string_2425
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2426
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2428 = call toString $351
	lw $a0, 456($sp)
	jal func__toString
	move $t2, $v0
#	$2430 = call stringConcatenate $2428 " "
	move $a0, $t2
	la $a1, string_2429
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2430
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2432 = call toString $352
	lw $a0, 6380($sp)
	jal func__toString
	move $t2, $v0
#	$2434 = call stringConcatenate $2432 " "
	move $a0, $t2
	la $a1, string_2433
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2434
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2436 = call toString $353
	lw $a0, 276($sp)
	jal func__toString
	move $t2, $v0
#	$2438 = call stringConcatenate $2436 " "
	move $a0, $t2
	la $a1, string_2437
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2438
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2440 = call toString $354
	lw $a0, 1356($sp)
	jal func__toString
	move $t2, $v0
#	$2442 = call stringConcatenate $2440 " "
	move $a0, $t2
	la $a1, string_2441
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2442
	move $a0, $t2
	jal func__print
	sw $v0, 8100($sp)
#	$2444 = call toString $355
	lw $a0, 4836($sp)
	jal func__toString
	move $t2, $v0
#	$2446 = call stringConcatenate $2444 " "
	move $a0, $t2
	la $a1, string_2445
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2446
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2448 = call toString $356
	lw $a0, 656($sp)
	jal func__toString
	move $t2, $v0
#	$2450 = call stringConcatenate $2448 " "
	move $a0, $t2
	la $a1, string_2449
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2450
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2452 = call toString $357
	lw $a0, 6540($sp)
	jal func__toString
	move $t2, $v0
#	$2454 = call stringConcatenate $2452 " "
	move $a0, $t2
	la $a1, string_2453
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2454
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2456 = call toString $358
	lw $a0, 3528($sp)
	jal func__toString
	move $t2, $v0
#	$2458 = call stringConcatenate $2456 " "
	move $a0, $t2
	la $a1, string_2457
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2458
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2460 = call toString $359
	lw $a0, 4112($sp)
	jal func__toString
	move $t2, $v0
#	$2462 = call stringConcatenate $2460 " "
	move $a0, $t2
	la $a1, string_2461
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2462
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2464 = call toString $360
	lw $a0, 2128($sp)
	jal func__toString
	move $t2, $v0
#	$2466 = call stringConcatenate $2464 " "
	move $a0, $t2
	la $a1, string_2465
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2466
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2468 = call toString $361
	lw $a0, 1848($sp)
	jal func__toString
	move $t2, $v0
#	$2470 = call stringConcatenate $2468 " "
	move $a0, $t2
	la $a1, string_2469
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2470
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2472 = call toString $362
	lw $a0, 7212($sp)
	jal func__toString
	move $t2, $v0
#	$2474 = call stringConcatenate $2472 " "
	move $a0, $t2
	la $a1, string_2473
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2474
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2476 = call toString $363
	move $a0, $t8
	jal func__toString
	move $t2, $v0
#	$2478 = call stringConcatenate $2476 " "
	move $a0, $t2
	la $a1, string_2477
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2478
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2480 = call toString $364
	move $a0, $k0
	jal func__toString
	move $t2, $v0
#	$2482 = call stringConcatenate $2480 " "
	move $a0, $t2
	la $a1, string_2481
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2482
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2484 = call toString $365
	lw $a0, 284($sp)
	jal func__toString
	sw $v0, 8180($sp)
#	$2486 = call stringConcatenate $2484 " "
	lw $a0, 8180($sp)
	la $a1, string_2485
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2486
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2488 = call toString $366
	lw $a0, 6396($sp)
	jal func__toString
	move $t2, $v0
#	$2490 = call stringConcatenate $2488 " "
	move $a0, $t2
	la $a1, string_2489
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2490
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2492 = call toString $367
	move $a0, $s5
	jal func__toString
	move $t2, $v0
#	$2494 = call stringConcatenate $2492 " "
	move $a0, $t2
	la $a1, string_2493
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2494
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2496 = call toString $368
	lw $a0, 1208($sp)
	jal func__toString
	move $t2, $v0
#	$2498 = call stringConcatenate $2496 " "
	move $a0, $t2
	la $a1, string_2497
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2498
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2500 = call toString $369
	lw $a0, 3516($sp)
	jal func__toString
	move $t2, $v0
#	$2502 = call stringConcatenate $2500 " "
	move $a0, $t2
	la $a1, string_2501
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2502
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2504 = call toString $370
	lw $a0, 3492($sp)
	jal func__toString
	move $t2, $v0
#	$2506 = call stringConcatenate $2504 " "
	move $a0, $t2
	la $a1, string_2505
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2506
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2508 = call toString $371
	lw $a0, 6412($sp)
	jal func__toString
	move $t2, $v0
#	$2510 = call stringConcatenate $2508 " "
	move $a0, $t2
	la $a1, string_2509
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2510
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2512 = call toString $372
	lw $a0, 7636($sp)
	jal func__toString
	move $t2, $v0
#	$2514 = call stringConcatenate $2512 " "
	move $a0, $t2
	la $a1, string_2513
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2514
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2516 = call toString $373
	lw $a0, 4292($sp)
	jal func__toString
	move $t2, $v0
#	$2518 = call stringConcatenate $2516 " "
	move $a0, $t2
	la $a1, string_2517
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2518
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2520 = call toString $374
	lw $a0, 4308($sp)
	jal func__toString
	move $t2, $v0
#	$2522 = call stringConcatenate $2520 " "
	move $a0, $t2
	la $a1, string_2521
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2522
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2524 = call toString $375
	lw $a0, 744($sp)
	jal func__toString
	move $t2, $v0
#	$2526 = call stringConcatenate $2524 " "
	move $a0, $t2
	la $a1, string_2525
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2526
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2528 = call toString $376
	lw $a0, 3636($sp)
	jal func__toString
	move $t2, $v0
#	$2530 = call stringConcatenate $2528 " "
	move $a0, $t2
	la $a1, string_2529
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2530
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2532 = call toString $377
	lw $a0, 1460($sp)
	jal func__toString
	move $t2, $v0
#	$2534 = call stringConcatenate $2532 " "
	move $a0, $t2
	la $a1, string_2533
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2534
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2536 = call toString $378
	lw $a0, 352($sp)
	jal func__toString
	move $t2, $v0
#	$2538 = call stringConcatenate $2536 " "
	move $a0, $t2
	la $a1, string_2537
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2538
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2540 = call toString $379
	move $a0, $gp
	jal func__toString
	move $t2, $v0
#	$2542 = call stringConcatenate $2540 " "
	move $a0, $t2
	la $a1, string_2541
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2542
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2544 = call toString $380
	lw $a0, 6724($sp)
	jal func__toString
	move $t2, $v0
#	$2546 = call stringConcatenate $2544 " "
	move $a0, $t2
	la $a1, string_2545
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2546
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2548 = call toString $381
	move $a0, $s3
	jal func__toString
	move $t2, $v0
#	$2550 = call stringConcatenate $2548 " "
	move $a0, $t2
	la $a1, string_2549
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2550
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2552 = call toString $382
	move $a0, $s7
	jal func__toString
	move $t2, $v0
#	$2554 = call stringConcatenate $2552 " "
	move $a0, $t2
	la $a1, string_2553
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2554
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2556 = call toString $383
	lw $a0, 1548($sp)
	jal func__toString
	move $t2, $v0
#	$2558 = call stringConcatenate $2556 " "
	move $a0, $t2
	la $a1, string_2557
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2558
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2560 = call toString $384
	lw $a0, 4556($sp)
	jal func__toString
	move $t2, $v0
#	$2562 = call stringConcatenate $2560 " "
	move $a0, $t2
	la $a1, string_2561
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2562
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2564 = call toString $385
	move $a0, $s2
	jal func__toString
	move $t2, $v0
#	$2566 = call stringConcatenate $2564 " "
	move $a0, $t2
	la $a1, string_2565
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2566
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	$2568 = call toString $386
	lw $a0, 1400($sp)
	jal func__toString
	move $t2, $v0
#	$2570 = call stringConcatenate $2568 " "
	move $a0, $t2
	la $a1, string_2569
	jal func__stringConcatenate
	move $t2, $v0
#	nullcall print $2570
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	nullcall println ""
	la $a0, string_2572
	jal func__println
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl64
	b _EndOfFunctionDecl64
#	%EndOfFunctionDecl64
_EndOfFunctionDecl64:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t8, 96($sp)
	lw $fp, 124($sp)
	lw $t6, 56($sp)
	lw $s7, 92($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t9, 100($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $t4, 48($sp)
	lw $gp, 112($sp)
	lw $k1, 108($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $k0, 104($sp)
	lw $t5, 52($sp)
	lw $s4, 80($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 8348
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_129:
.space 4
.align 2
.word 1
string_523:
.asciiz " "
.align 2
.word 1
string_527:
.asciiz " "
.align 2
.word 1
string_531:
.asciiz " "
.align 2
.word 1
string_535:
.asciiz " "
.align 2
.word 1
string_539:
.asciiz " "
.align 2
.word 1
string_543:
.asciiz " "
.align 2
.word 1
string_547:
.asciiz " "
.align 2
.word 1
string_551:
.asciiz " "
.align 2
.word 1
string_555:
.asciiz " "
.align 2
.word 1
string_559:
.asciiz " "
.align 2
.word 1
string_563:
.asciiz " "
.align 2
.word 1
string_567:
.asciiz " "
.align 2
.word 1
string_571:
.asciiz " "
.align 2
.word 1
string_575:
.asciiz " "
.align 2
.word 1
string_579:
.asciiz " "
.align 2
.word 1
string_583:
.asciiz " "
.align 2
.word 1
string_587:
.asciiz " "
.align 2
.word 1
string_591:
.asciiz " "
.align 2
.word 1
string_595:
.asciiz " "
.align 2
.word 1
string_599:
.asciiz " "
.align 2
.word 1
string_603:
.asciiz " "
.align 2
.word 1
string_607:
.asciiz " "
.align 2
.word 1
string_611:
.asciiz " "
.align 2
.word 1
string_615:
.asciiz " "
.align 2
.word 1
string_619:
.asciiz " "
.align 2
.word 1
string_623:
.asciiz " "
.align 2
.word 1
string_627:
.asciiz " "
.align 2
.word 1
string_631:
.asciiz " "
.align 2
.word 1
string_635:
.asciiz " "
.align 2
.word 1
string_639:
.asciiz " "
.align 2
.word 1
string_643:
.asciiz " "
.align 2
.word 1
string_647:
.asciiz " "
.align 2
.word 1
string_651:
.asciiz " "
.align 2
.word 1
string_655:
.asciiz " "
.align 2
.word 1
string_659:
.asciiz " "
.align 2
.word 1
string_663:
.asciiz " "
.align 2
.word 1
string_667:
.asciiz " "
.align 2
.word 1
string_671:
.asciiz " "
.align 2
.word 1
string_675:
.asciiz " "
.align 2
.word 1
string_679:
.asciiz " "
.align 2
.word 1
string_683:
.asciiz " "
.align 2
.word 1
string_687:
.asciiz " "
.align 2
.word 1
string_691:
.asciiz " "
.align 2
.word 1
string_695:
.asciiz " "
.align 2
.word 1
string_699:
.asciiz " "
.align 2
.word 1
string_703:
.asciiz " "
.align 2
.word 1
string_707:
.asciiz " "
.align 2
.word 1
string_711:
.asciiz " "
.align 2
.word 1
string_715:
.asciiz " "
.align 2
.word 1
string_719:
.asciiz " "
.align 2
.word 1
string_723:
.asciiz " "
.align 2
.word 1
string_727:
.asciiz " "
.align 2
.word 1
string_731:
.asciiz " "
.align 2
.word 1
string_735:
.asciiz " "
.align 2
.word 1
string_739:
.asciiz " "
.align 2
.word 1
string_743:
.asciiz " "
.align 2
.word 1
string_747:
.asciiz " "
.align 2
.word 1
string_751:
.asciiz " "
.align 2
.word 1
string_755:
.asciiz " "
.align 2
.word 1
string_759:
.asciiz " "
.align 2
.word 1
string_763:
.asciiz " "
.align 2
.word 1
string_767:
.asciiz " "
.align 2
.word 1
string_771:
.asciiz " "
.align 2
.word 1
string_775:
.asciiz " "
.align 2
.word 1
string_779:
.asciiz " "
.align 2
.word 1
string_783:
.asciiz " "
.align 2
.word 1
string_787:
.asciiz " "
.align 2
.word 1
string_791:
.asciiz " "
.align 2
.word 1
string_795:
.asciiz " "
.align 2
.word 1
string_799:
.asciiz " "
.align 2
.word 1
string_803:
.asciiz " "
.align 2
.word 1
string_807:
.asciiz " "
.align 2
.word 1
string_811:
.asciiz " "
.align 2
.word 1
string_815:
.asciiz " "
.align 2
.word 1
string_819:
.asciiz " "
.align 2
.word 1
string_823:
.asciiz " "
.align 2
.word 1
string_827:
.asciiz " "
.align 2
.word 1
string_831:
.asciiz " "
.align 2
.word 1
string_835:
.asciiz " "
.align 2
.word 1
string_839:
.asciiz " "
.align 2
.word 1
string_843:
.asciiz " "
.align 2
.word 1
string_847:
.asciiz " "
.align 2
.word 1
string_851:
.asciiz " "
.align 2
.word 1
string_855:
.asciiz " "
.align 2
.word 1
string_859:
.asciiz " "
.align 2
.word 1
string_863:
.asciiz " "
.align 2
.word 1
string_867:
.asciiz " "
.align 2
.word 1
string_871:
.asciiz " "
.align 2
.word 1
string_875:
.asciiz " "
.align 2
.word 1
string_879:
.asciiz " "
.align 2
.word 1
string_883:
.asciiz " "
.align 2
.word 1
string_887:
.asciiz " "
.align 2
.word 1
string_891:
.asciiz " "
.align 2
.word 1
string_895:
.asciiz " "
.align 2
.word 1
string_899:
.asciiz " "
.align 2
.word 1
string_903:
.asciiz " "
.align 2
.word 1
string_907:
.asciiz " "
.align 2
.word 1
string_911:
.asciiz " "
.align 2
.word 1
string_915:
.asciiz " "
.align 2
.word 1
string_919:
.asciiz " "
.align 2
.word 1
string_923:
.asciiz " "
.align 2
.word 1
string_927:
.asciiz " "
.align 2
.word 1
string_931:
.asciiz " "
.align 2
.word 1
string_935:
.asciiz " "
.align 2
.word 1
string_939:
.asciiz " "
.align 2
.word 1
string_943:
.asciiz " "
.align 2
.word 1
string_947:
.asciiz " "
.align 2
.word 1
string_951:
.asciiz " "
.align 2
.word 1
string_955:
.asciiz " "
.align 2
.word 1
string_959:
.asciiz " "
.align 2
.word 1
string_963:
.asciiz " "
.align 2
.word 1
string_967:
.asciiz " "
.align 2
.word 1
string_971:
.asciiz " "
.align 2
.word 1
string_975:
.asciiz " "
.align 2
.word 1
string_979:
.asciiz " "
.align 2
.word 1
string_983:
.asciiz " "
.align 2
.word 1
string_987:
.asciiz " "
.align 2
.word 1
string_991:
.asciiz " "
.align 2
.word 1
string_995:
.asciiz " "
.align 2
.word 1
string_999:
.asciiz " "
.align 2
.word 1
string_1003:
.asciiz " "
.align 2
.word 1
string_1007:
.asciiz " "
.align 2
.word 1
string_1011:
.asciiz " "
.align 2
.word 1
string_1015:
.asciiz " "
.align 2
.word 1
string_1019:
.asciiz " "
.align 2
.word 1
string_1023:
.asciiz " "
.align 2
.word 1
string_1027:
.asciiz " "
.align 2
.word 1
string_1031:
.asciiz " "
.align 2
.word 1
string_1035:
.asciiz " "
.align 2
.word 1
string_1039:
.asciiz " "
.align 2
.word 1
string_1043:
.asciiz " "
.align 2
.word 1
string_1047:
.asciiz " "
.align 2
.word 1
string_1051:
.asciiz " "
.align 2
.word 1
string_1055:
.asciiz " "
.align 2
.word 1
string_1059:
.asciiz " "
.align 2
.word 1
string_1063:
.asciiz " "
.align 2
.word 1
string_1067:
.asciiz " "
.align 2
.word 1
string_1071:
.asciiz " "
.align 2
.word 1
string_1075:
.asciiz " "
.align 2
.word 1
string_1079:
.asciiz " "
.align 2
.word 1
string_1083:
.asciiz " "
.align 2
.word 1
string_1087:
.asciiz " "
.align 2
.word 1
string_1091:
.asciiz " "
.align 2
.word 1
string_1095:
.asciiz " "
.align 2
.word 1
string_1099:
.asciiz " "
.align 2
.word 1
string_1103:
.asciiz " "
.align 2
.word 1
string_1107:
.asciiz " "
.align 2
.word 1
string_1111:
.asciiz " "
.align 2
.word 1
string_1115:
.asciiz " "
.align 2
.word 1
string_1119:
.asciiz " "
.align 2
.word 1
string_1123:
.asciiz " "
.align 2
.word 1
string_1127:
.asciiz " "
.align 2
.word 1
string_1131:
.asciiz " "
.align 2
.word 1
string_1135:
.asciiz " "
.align 2
.word 1
string_1139:
.asciiz " "
.align 2
.word 1
string_1143:
.asciiz " "
.align 2
.word 1
string_1147:
.asciiz " "
.align 2
.word 1
string_1151:
.asciiz " "
.align 2
.word 1
string_1155:
.asciiz " "
.align 2
.word 1
string_1159:
.asciiz " "
.align 2
.word 1
string_1163:
.asciiz " "
.align 2
.word 1
string_1167:
.asciiz " "
.align 2
.word 1
string_1171:
.asciiz " "
.align 2
.word 1
string_1175:
.asciiz " "
.align 2
.word 1
string_1179:
.asciiz " "
.align 2
.word 1
string_1183:
.asciiz " "
.align 2
.word 1
string_1187:
.asciiz " "
.align 2
.word 1
string_1191:
.asciiz " "
.align 2
.word 1
string_1195:
.asciiz " "
.align 2
.word 1
string_1199:
.asciiz " "
.align 2
.word 1
string_1203:
.asciiz " "
.align 2
.word 1
string_1207:
.asciiz " "
.align 2
.word 1
string_1211:
.asciiz " "
.align 2
.word 1
string_1215:
.asciiz " "
.align 2
.word 1
string_1219:
.asciiz " "
.align 2
.word 1
string_1223:
.asciiz " "
.align 2
.word 1
string_1227:
.asciiz " "
.align 2
.word 1
string_1231:
.asciiz " "
.align 2
.word 1
string_1235:
.asciiz " "
.align 2
.word 1
string_1239:
.asciiz " "
.align 2
.word 1
string_1243:
.asciiz " "
.align 2
.word 1
string_1247:
.asciiz " "
.align 2
.word 1
string_1251:
.asciiz " "
.align 2
.word 1
string_1255:
.asciiz " "
.align 2
.word 1
string_1259:
.asciiz " "
.align 2
.word 1
string_1263:
.asciiz " "
.align 2
.word 1
string_1267:
.asciiz " "
.align 2
.word 1
string_1271:
.asciiz " "
.align 2
.word 1
string_1275:
.asciiz " "
.align 2
.word 1
string_1279:
.asciiz " "
.align 2
.word 1
string_1283:
.asciiz " "
.align 2
.word 1
string_1287:
.asciiz " "
.align 2
.word 1
string_1291:
.asciiz " "
.align 2
.word 1
string_1295:
.asciiz " "
.align 2
.word 1
string_1299:
.asciiz " "
.align 2
.word 1
string_1303:
.asciiz " "
.align 2
.word 1
string_1307:
.asciiz " "
.align 2
.word 1
string_1311:
.asciiz " "
.align 2
.word 1
string_1315:
.asciiz " "
.align 2
.word 1
string_1319:
.asciiz " "
.align 2
.word 1
string_1323:
.asciiz " "
.align 2
.word 1
string_1327:
.asciiz " "
.align 2
.word 1
string_1331:
.asciiz " "
.align 2
.word 1
string_1335:
.asciiz " "
.align 2
.word 1
string_1339:
.asciiz " "
.align 2
.word 1
string_1343:
.asciiz " "
.align 2
.word 1
string_1347:
.asciiz " "
.align 2
.word 1
string_1351:
.asciiz " "
.align 2
.word 1
string_1355:
.asciiz " "
.align 2
.word 1
string_1359:
.asciiz " "
.align 2
.word 1
string_1363:
.asciiz " "
.align 2
.word 1
string_1367:
.asciiz " "
.align 2
.word 1
string_1371:
.asciiz " "
.align 2
.word 1
string_1375:
.asciiz " "
.align 2
.word 1
string_1379:
.asciiz " "
.align 2
.word 1
string_1383:
.asciiz " "
.align 2
.word 1
string_1387:
.asciiz " "
.align 2
.word 1
string_1391:
.asciiz " "
.align 2
.word 1
string_1395:
.asciiz " "
.align 2
.word 1
string_1399:
.asciiz " "
.align 2
.word 1
string_1403:
.asciiz " "
.align 2
.word 1
string_1407:
.asciiz " "
.align 2
.word 1
string_1411:
.asciiz " "
.align 2
.word 1
string_1415:
.asciiz " "
.align 2
.word 1
string_1419:
.asciiz " "
.align 2
.word 1
string_1423:
.asciiz " "
.align 2
.word 1
string_1427:
.asciiz " "
.align 2
.word 1
string_1431:
.asciiz " "
.align 2
.word 1
string_1435:
.asciiz " "
.align 2
.word 1
string_1439:
.asciiz " "
.align 2
.word 1
string_1443:
.asciiz " "
.align 2
.word 1
string_1447:
.asciiz " "
.align 2
.word 1
string_1451:
.asciiz " "
.align 2
.word 1
string_1455:
.asciiz " "
.align 2
.word 1
string_1459:
.asciiz " "
.align 2
.word 1
string_1463:
.asciiz " "
.align 2
.word 1
string_1467:
.asciiz " "
.align 2
.word 1
string_1471:
.asciiz " "
.align 2
.word 1
string_1475:
.asciiz " "
.align 2
.word 1
string_1479:
.asciiz " "
.align 2
.word 1
string_1483:
.asciiz " "
.align 2
.word 1
string_1487:
.asciiz " "
.align 2
.word 1
string_1491:
.asciiz " "
.align 2
.word 1
string_1495:
.asciiz " "
.align 2
.word 1
string_1499:
.asciiz " "
.align 2
.word 1
string_1503:
.asciiz " "
.align 2
.word 1
string_1507:
.asciiz " "
.align 2
.word 1
string_1511:
.asciiz " "
.align 2
.word 1
string_1515:
.asciiz " "
.align 2
.word 1
string_1519:
.asciiz " "
.align 2
.word 1
string_1523:
.asciiz " "
.align 2
.word 1
string_1527:
.asciiz " "
.align 2
.word 1
string_1531:
.asciiz " "
.align 2
.word 1
string_1535:
.asciiz " "
.align 2
.word 1
string_1539:
.asciiz " "
.align 2
.word 1
string_1543:
.asciiz " "
.align 2
.word 0
string_1546:
.asciiz ""
.align 2
.word 1
string_1549:
.asciiz " "
.align 2
.word 1
string_1553:
.asciiz " "
.align 2
.word 1
string_1557:
.asciiz " "
.align 2
.word 1
string_1561:
.asciiz " "
.align 2
.word 1
string_1565:
.asciiz " "
.align 2
.word 1
string_1569:
.asciiz " "
.align 2
.word 1
string_1573:
.asciiz " "
.align 2
.word 1
string_1577:
.asciiz " "
.align 2
.word 1
string_1581:
.asciiz " "
.align 2
.word 1
string_1585:
.asciiz " "
.align 2
.word 1
string_1589:
.asciiz " "
.align 2
.word 1
string_1593:
.asciiz " "
.align 2
.word 1
string_1597:
.asciiz " "
.align 2
.word 1
string_1601:
.asciiz " "
.align 2
.word 1
string_1605:
.asciiz " "
.align 2
.word 1
string_1609:
.asciiz " "
.align 2
.word 1
string_1613:
.asciiz " "
.align 2
.word 1
string_1617:
.asciiz " "
.align 2
.word 1
string_1621:
.asciiz " "
.align 2
.word 1
string_1625:
.asciiz " "
.align 2
.word 1
string_1629:
.asciiz " "
.align 2
.word 1
string_1633:
.asciiz " "
.align 2
.word 1
string_1637:
.asciiz " "
.align 2
.word 1
string_1641:
.asciiz " "
.align 2
.word 1
string_1645:
.asciiz " "
.align 2
.word 1
string_1649:
.asciiz " "
.align 2
.word 1
string_1653:
.asciiz " "
.align 2
.word 1
string_1657:
.asciiz " "
.align 2
.word 1
string_1661:
.asciiz " "
.align 2
.word 1
string_1665:
.asciiz " "
.align 2
.word 1
string_1669:
.asciiz " "
.align 2
.word 1
string_1673:
.asciiz " "
.align 2
.word 1
string_1677:
.asciiz " "
.align 2
.word 1
string_1681:
.asciiz " "
.align 2
.word 1
string_1685:
.asciiz " "
.align 2
.word 1
string_1689:
.asciiz " "
.align 2
.word 1
string_1693:
.asciiz " "
.align 2
.word 1
string_1697:
.asciiz " "
.align 2
.word 1
string_1701:
.asciiz " "
.align 2
.word 1
string_1705:
.asciiz " "
.align 2
.word 1
string_1709:
.asciiz " "
.align 2
.word 1
string_1713:
.asciiz " "
.align 2
.word 1
string_1717:
.asciiz " "
.align 2
.word 1
string_1721:
.asciiz " "
.align 2
.word 1
string_1725:
.asciiz " "
.align 2
.word 1
string_1729:
.asciiz " "
.align 2
.word 1
string_1733:
.asciiz " "
.align 2
.word 1
string_1737:
.asciiz " "
.align 2
.word 1
string_1741:
.asciiz " "
.align 2
.word 1
string_1745:
.asciiz " "
.align 2
.word 1
string_1749:
.asciiz " "
.align 2
.word 1
string_1753:
.asciiz " "
.align 2
.word 1
string_1757:
.asciiz " "
.align 2
.word 1
string_1761:
.asciiz " "
.align 2
.word 1
string_1765:
.asciiz " "
.align 2
.word 1
string_1769:
.asciiz " "
.align 2
.word 1
string_1773:
.asciiz " "
.align 2
.word 1
string_1777:
.asciiz " "
.align 2
.word 1
string_1781:
.asciiz " "
.align 2
.word 1
string_1785:
.asciiz " "
.align 2
.word 1
string_1789:
.asciiz " "
.align 2
.word 1
string_1793:
.asciiz " "
.align 2
.word 1
string_1797:
.asciiz " "
.align 2
.word 1
string_1801:
.asciiz " "
.align 2
.word 1
string_1805:
.asciiz " "
.align 2
.word 1
string_1809:
.asciiz " "
.align 2
.word 1
string_1813:
.asciiz " "
.align 2
.word 1
string_1817:
.asciiz " "
.align 2
.word 1
string_1821:
.asciiz " "
.align 2
.word 1
string_1825:
.asciiz " "
.align 2
.word 1
string_1829:
.asciiz " "
.align 2
.word 1
string_1833:
.asciiz " "
.align 2
.word 1
string_1837:
.asciiz " "
.align 2
.word 1
string_1841:
.asciiz " "
.align 2
.word 1
string_1845:
.asciiz " "
.align 2
.word 1
string_1849:
.asciiz " "
.align 2
.word 1
string_1853:
.asciiz " "
.align 2
.word 1
string_1857:
.asciiz " "
.align 2
.word 1
string_1861:
.asciiz " "
.align 2
.word 1
string_1865:
.asciiz " "
.align 2
.word 1
string_1869:
.asciiz " "
.align 2
.word 1
string_1873:
.asciiz " "
.align 2
.word 1
string_1877:
.asciiz " "
.align 2
.word 1
string_1881:
.asciiz " "
.align 2
.word 1
string_1885:
.asciiz " "
.align 2
.word 1
string_1889:
.asciiz " "
.align 2
.word 1
string_1893:
.asciiz " "
.align 2
.word 1
string_1897:
.asciiz " "
.align 2
.word 1
string_1901:
.asciiz " "
.align 2
.word 1
string_1905:
.asciiz " "
.align 2
.word 1
string_1909:
.asciiz " "
.align 2
.word 1
string_1913:
.asciiz " "
.align 2
.word 1
string_1917:
.asciiz " "
.align 2
.word 1
string_1921:
.asciiz " "
.align 2
.word 1
string_1925:
.asciiz " "
.align 2
.word 1
string_1929:
.asciiz " "
.align 2
.word 1
string_1933:
.asciiz " "
.align 2
.word 1
string_1937:
.asciiz " "
.align 2
.word 1
string_1941:
.asciiz " "
.align 2
.word 1
string_1945:
.asciiz " "
.align 2
.word 1
string_1949:
.asciiz " "
.align 2
.word 1
string_1953:
.asciiz " "
.align 2
.word 1
string_1957:
.asciiz " "
.align 2
.word 1
string_1961:
.asciiz " "
.align 2
.word 1
string_1965:
.asciiz " "
.align 2
.word 1
string_1969:
.asciiz " "
.align 2
.word 1
string_1973:
.asciiz " "
.align 2
.word 1
string_1977:
.asciiz " "
.align 2
.word 1
string_1981:
.asciiz " "
.align 2
.word 1
string_1985:
.asciiz " "
.align 2
.word 1
string_1989:
.asciiz " "
.align 2
.word 1
string_1993:
.asciiz " "
.align 2
.word 1
string_1997:
.asciiz " "
.align 2
.word 1
string_2001:
.asciiz " "
.align 2
.word 1
string_2005:
.asciiz " "
.align 2
.word 1
string_2009:
.asciiz " "
.align 2
.word 1
string_2013:
.asciiz " "
.align 2
.word 1
string_2017:
.asciiz " "
.align 2
.word 1
string_2021:
.asciiz " "
.align 2
.word 1
string_2025:
.asciiz " "
.align 2
.word 1
string_2029:
.asciiz " "
.align 2
.word 1
string_2033:
.asciiz " "
.align 2
.word 1
string_2037:
.asciiz " "
.align 2
.word 1
string_2041:
.asciiz " "
.align 2
.word 1
string_2045:
.asciiz " "
.align 2
.word 1
string_2049:
.asciiz " "
.align 2
.word 1
string_2053:
.asciiz " "
.align 2
.word 1
string_2057:
.asciiz " "
.align 2
.word 1
string_2061:
.asciiz " "
.align 2
.word 1
string_2065:
.asciiz " "
.align 2
.word 1
string_2069:
.asciiz " "
.align 2
.word 1
string_2073:
.asciiz " "
.align 2
.word 1
string_2077:
.asciiz " "
.align 2
.word 1
string_2081:
.asciiz " "
.align 2
.word 1
string_2085:
.asciiz " "
.align 2
.word 1
string_2089:
.asciiz " "
.align 2
.word 1
string_2093:
.asciiz " "
.align 2
.word 1
string_2097:
.asciiz " "
.align 2
.word 1
string_2101:
.asciiz " "
.align 2
.word 1
string_2105:
.asciiz " "
.align 2
.word 1
string_2109:
.asciiz " "
.align 2
.word 1
string_2113:
.asciiz " "
.align 2
.word 1
string_2117:
.asciiz " "
.align 2
.word 1
string_2121:
.asciiz " "
.align 2
.word 1
string_2125:
.asciiz " "
.align 2
.word 1
string_2129:
.asciiz " "
.align 2
.word 1
string_2133:
.asciiz " "
.align 2
.word 1
string_2137:
.asciiz " "
.align 2
.word 1
string_2141:
.asciiz " "
.align 2
.word 1
string_2145:
.asciiz " "
.align 2
.word 1
string_2149:
.asciiz " "
.align 2
.word 1
string_2153:
.asciiz " "
.align 2
.word 1
string_2157:
.asciiz " "
.align 2
.word 1
string_2161:
.asciiz " "
.align 2
.word 1
string_2165:
.asciiz " "
.align 2
.word 1
string_2169:
.asciiz " "
.align 2
.word 1
string_2173:
.asciiz " "
.align 2
.word 1
string_2177:
.asciiz " "
.align 2
.word 1
string_2181:
.asciiz " "
.align 2
.word 1
string_2185:
.asciiz " "
.align 2
.word 1
string_2189:
.asciiz " "
.align 2
.word 1
string_2193:
.asciiz " "
.align 2
.word 1
string_2197:
.asciiz " "
.align 2
.word 1
string_2201:
.asciiz " "
.align 2
.word 1
string_2205:
.asciiz " "
.align 2
.word 1
string_2209:
.asciiz " "
.align 2
.word 1
string_2213:
.asciiz " "
.align 2
.word 1
string_2217:
.asciiz " "
.align 2
.word 1
string_2221:
.asciiz " "
.align 2
.word 1
string_2225:
.asciiz " "
.align 2
.word 1
string_2229:
.asciiz " "
.align 2
.word 1
string_2233:
.asciiz " "
.align 2
.word 1
string_2237:
.asciiz " "
.align 2
.word 1
string_2241:
.asciiz " "
.align 2
.word 1
string_2245:
.asciiz " "
.align 2
.word 1
string_2249:
.asciiz " "
.align 2
.word 1
string_2253:
.asciiz " "
.align 2
.word 1
string_2257:
.asciiz " "
.align 2
.word 1
string_2261:
.asciiz " "
.align 2
.word 1
string_2265:
.asciiz " "
.align 2
.word 1
string_2269:
.asciiz " "
.align 2
.word 1
string_2273:
.asciiz " "
.align 2
.word 1
string_2277:
.asciiz " "
.align 2
.word 1
string_2281:
.asciiz " "
.align 2
.word 1
string_2285:
.asciiz " "
.align 2
.word 1
string_2289:
.asciiz " "
.align 2
.word 1
string_2293:
.asciiz " "
.align 2
.word 1
string_2297:
.asciiz " "
.align 2
.word 1
string_2301:
.asciiz " "
.align 2
.word 1
string_2305:
.asciiz " "
.align 2
.word 1
string_2309:
.asciiz " "
.align 2
.word 1
string_2313:
.asciiz " "
.align 2
.word 1
string_2317:
.asciiz " "
.align 2
.word 1
string_2321:
.asciiz " "
.align 2
.word 1
string_2325:
.asciiz " "
.align 2
.word 1
string_2329:
.asciiz " "
.align 2
.word 1
string_2333:
.asciiz " "
.align 2
.word 1
string_2337:
.asciiz " "
.align 2
.word 1
string_2341:
.asciiz " "
.align 2
.word 1
string_2345:
.asciiz " "
.align 2
.word 1
string_2349:
.asciiz " "
.align 2
.word 1
string_2353:
.asciiz " "
.align 2
.word 1
string_2357:
.asciiz " "
.align 2
.word 1
string_2361:
.asciiz " "
.align 2
.word 1
string_2365:
.asciiz " "
.align 2
.word 1
string_2369:
.asciiz " "
.align 2
.word 1
string_2373:
.asciiz " "
.align 2
.word 1
string_2377:
.asciiz " "
.align 2
.word 1
string_2381:
.asciiz " "
.align 2
.word 1
string_2385:
.asciiz " "
.align 2
.word 1
string_2389:
.asciiz " "
.align 2
.word 1
string_2393:
.asciiz " "
.align 2
.word 1
string_2397:
.asciiz " "
.align 2
.word 1
string_2401:
.asciiz " "
.align 2
.word 1
string_2405:
.asciiz " "
.align 2
.word 1
string_2409:
.asciiz " "
.align 2
.word 1
string_2413:
.asciiz " "
.align 2
.word 1
string_2417:
.asciiz " "
.align 2
.word 1
string_2421:
.asciiz " "
.align 2
.word 1
string_2425:
.asciiz " "
.align 2
.word 1
string_2429:
.asciiz " "
.align 2
.word 1
string_2433:
.asciiz " "
.align 2
.word 1
string_2437:
.asciiz " "
.align 2
.word 1
string_2441:
.asciiz " "
.align 2
.word 1
string_2445:
.asciiz " "
.align 2
.word 1
string_2449:
.asciiz " "
.align 2
.word 1
string_2453:
.asciiz " "
.align 2
.word 1
string_2457:
.asciiz " "
.align 2
.word 1
string_2461:
.asciiz " "
.align 2
.word 1
string_2465:
.asciiz " "
.align 2
.word 1
string_2469:
.asciiz " "
.align 2
.word 1
string_2473:
.asciiz " "
.align 2
.word 1
string_2477:
.asciiz " "
.align 2
.word 1
string_2481:
.asciiz " "
.align 2
.word 1
string_2485:
.asciiz " "
.align 2
.word 1
string_2489:
.asciiz " "
.align 2
.word 1
string_2493:
.asciiz " "
.align 2
.word 1
string_2497:
.asciiz " "
.align 2
.word 1
string_2501:
.asciiz " "
.align 2
.word 1
string_2505:
.asciiz " "
.align 2
.word 1
string_2509:
.asciiz " "
.align 2
.word 1
string_2513:
.asciiz " "
.align 2
.word 1
string_2517:
.asciiz " "
.align 2
.word 1
string_2521:
.asciiz " "
.align 2
.word 1
string_2525:
.asciiz " "
.align 2
.word 1
string_2529:
.asciiz " "
.align 2
.word 1
string_2533:
.asciiz " "
.align 2
.word 1
string_2537:
.asciiz " "
.align 2
.word 1
string_2541:
.asciiz " "
.align 2
.word 1
string_2545:
.asciiz " "
.align 2
.word 1
string_2549:
.asciiz " "
.align 2
.word 1
string_2553:
.asciiz " "
.align 2
.word 1
string_2557:
.asciiz " "
.align 2
.word 1
string_2561:
.asciiz " "
.align 2
.word 1
string_2565:
.asciiz " "
.align 2
.word 1
string_2569:
.asciiz " "
.align 2
.word 0
string_2572:
.asciiz ""
.align 2
