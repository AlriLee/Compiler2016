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
_check:
	sub $sp, $sp, 148
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl72
_BeginOfFunctionDecl72:
#	$1 = slt $149 $150
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t2, $t0, $t1
#	br $1 %logicalTrue0 %logicalFalse1
	beqz $t2, _logicalFalse1
#	%logicalTrue0
_logicalTrue0:
#	$2 = sge $149 0
	lw $t0, 140($sp)
	li $t1, 0
	sge $t2, $t0, $t1
#	$0 = move $2
#	jump %logicalMerge2
	b _logicalMerge2
#	%logicalFalse1
_logicalFalse1:
#	$0 = move 0
	li $t0, 0
	move $t2, $t0
#	jump %logicalMerge2
	b _logicalMerge2
#	%logicalMerge2
_logicalMerge2:
#	ret $0
	move $v0, $t2
#	jump %EndOfFunctionDecl73
	b _EndOfFunctionDecl73
#	%EndOfFunctionDecl73
_EndOfFunctionDecl73:
	lw $t2, 40($sp)
	add $sp, $sp, 148
	jr $ra
main:
	sub $sp, $sp, 1576
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
#	%BeginOfFunctionDecl74
_BeginOfFunctionDecl74:
#	$4 = call getInt
	jal func__getInt
	move $t2, $v0
#	$151 = move $4
#	$154 = move 0
	li $t0, 0
	move $s0, $t0
#	$153 = move $154
	move $s2, $s0
#	$157 = move $153
	sw $s2, 1460($sp)
#	$152 = move $157
	lw $t0, 1460($sp)
	move $s4, $t0
#	$11 = sub $151 1
	li $t1, 1
	sub $t3, $t2, $t1
#	$156 = move $11
	move $t5, $t3
#	$155 = move $156
	move $t6, $t5
#	$161 = move 0
	li $t0, 0
	move $k0, $t0
#	$160 = move $161
	move $s7, $k0
#	$158 = move 0
	li $t0, 0
	move $s3, $t0
#	$159 = move $158
	move $s5, $s3
#	$19 = mul $151 $151
	mul $t3, $t2, $t2
#	$20 = mul $19 4
	li $t1, 4
	mul $t4, $t3, $t1
#	$20 = add $20 4
	li $t1, 4
	add $t4, $t4, $t1
#	$18 = alloc $20
	move $a0, $t4
	li $v0, 9
	syscall
	move $t4, $v0
#	store 4 $18 $19 0
	sw $t3, 0($t4)
#	$18 = add $18 4
	li $t1, 4
	add $t4, $t4, $t1
#	$17 = move $18
	move $t3, $t4
#	$162 = move $17
	move $t4, $t3
#	$165 = move 0
	li $t0, 0
	move $t7, $t0
#	%ForLoop76
_ForLoop76:
#	$23 = mul $151 $151
	mul $t3, $t2, $t2
#	$22 = slt $165 $23
	slt $t3, $t7, $t3
#	br $22 %ForBody3 %OutOfFor4
	beqz $t3, _OutOfFor4
#	%ForBody3
_ForBody3:
#	$25 = mul $165 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$26 = add $162 $25
	add $t3, $t4, $t3
#	store 4 $26 0 0
	li $t0, 0
	sw $t0, 0($t3)
#	%continueFor77
_continueFor77:
#	$27 = move $165
	move $t3, $t7
#	$165 = add $165 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop76
	b _ForLoop76
#	%OutOfFor4
_OutOfFor4:
#	$31 = mul $151 $151
	mul $t3, $t2, $t2
#	$32 = mul $31 4
	li $t1, 4
	mul $t7, $t3, $t1
#	$32 = add $32 4
	li $t1, 4
	add $t7, $t7, $t1
#	$30 = alloc $32
	move $a0, $t7
	li $v0, 9
	syscall
	move $t7, $v0
#	store 4 $30 $31 0
	sw $t3, 0($t7)
#	$30 = add $30 4
	li $t1, 4
	add $t7, $t7, $t1
#	$29 = move $30
	move $t3, $t7
#	$163 = move $29
	move $t8, $t3
#	$165 = move 0
	li $t0, 0
	move $t7, $t0
#	%ForLoop78
_ForLoop78:
#	$35 = mul $151 $151
	mul $t3, $t2, $t2
#	$34 = slt $165 $35
	slt $t3, $t7, $t3
#	br $34 %ForBody5 %OutOfFor6
	beqz $t3, _OutOfFor6
#	%ForBody5
_ForBody5:
#	$37 = mul $165 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$38 = add $163 $37
	add $t3, $t8, $t3
#	store 4 $38 0 0
	li $t0, 0
	sw $t0, 0($t3)
#	%continueFor79
_continueFor79:
#	$39 = move $165
	move $t3, $t7
#	$165 = add $165 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop78
	b _ForLoop78
#	%OutOfFor6
_OutOfFor6:
#	$43 = mul $151 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$43 = add $43 4
	li $t1, 4
	add $t3, $t3, $t1
#	$42 = alloc $43
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $42 $151 0
	sw $t2, 0($t3)
#	$42 = add $42 4
	li $t1, 4
	add $t3, $t3, $t1
#	$41 = move $42
#	$164 = move $41
	move $s6, $t3
#	$165 = move 0
	li $t0, 0
	move $t7, $t0
#	%ForLoop80
_ForLoop80:
#	$45 = slt $165 $151
	slt $t3, $t7, $t2
#	br $45 %ForBody7 %OutOfFor8
	beqz $t3, _OutOfFor8
#	%ForBody7
_ForBody7:
#	$47 = mul $165 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$48 = add $164 $47
	add $t3, $s6, $t3
#	$51 = mul $151 4
	li $t1, 4
	mul $s1, $t2, $t1
#	$51 = add $51 4
	li $t1, 4
	add $s1, $s1, $t1
#	$50 = alloc $51
	move $a0, $s1
	li $v0, 9
	syscall
	move $s1, $v0
#	store 4 $50 $151 0
	sw $t2, 0($s1)
#	$50 = add $50 4
	li $t1, 4
	add $s1, $s1, $t1
#	$49 = move $50
#	store 4 $48 $49 0
	sw $s1, 0($t3)
#	$166 = move 0
	li $t0, 0
	move $t9, $t0
#	%ForLoop82
_ForLoop82:
#	$53 = slt $166 $151
	slt $t3, $t9, $t2
#	br $53 %ForBody9 %OutOfFor10
	beqz $t3, _OutOfFor10
#	%ForBody9
_ForBody9:
#	$55 = mul $165 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$56 = add $164 $55
	add $t3, $s6, $t3
#	$57 = load 4 $56 0
	lw $s1, 0($t3)
#	$58 = mul $166 4
	li $t1, 4
	mul $t3, $t9, $t1
#	$59 = add $57 $58
	add $s1, $s1, $t3
#	$60 = neg 1
	li $t0, 1
	neg $t3, $t0
#	store 4 $59 $60 0
	sw $t3, 0($s1)
#	%continueFor83
_continueFor83:
#	$61 = move $166
	move $t3, $t9
#	$166 = add $166 1
	li $t1, 1
	add $t9, $t9, $t1
#	jump %ForLoop82
	b _ForLoop82
#	%OutOfFor10
_OutOfFor10:
#	jump %continueFor81
	b _continueFor81
#	%continueFor81
_continueFor81:
#	$62 = move $165
	move $t3, $t7
#	$165 = add $165 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop80
	b _ForLoop80
#	%OutOfFor8
_OutOfFor8:
#	$64 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$65 = add $162 $64
	add $t3, $t4, $t3
#	store 4 $65 $153 0
	sw $s2, 0($t3)
#	$67 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
#	$68 = add $163 $67
	add $t3, $t8, $t3
#	store 4 $68 $154 0
	sw $s0, 0($t3)
#	$70 = mul $153 4
	li $t1, 4
	mul $t3, $s2, $t1
#	$71 = add $164 $70
	add $t3, $s6, $t3
#	$72 = load 4 $71 0
	lw $s1, 0($t3)
#	$73 = mul $154 4
	li $t1, 4
	mul $t3, $s0, $t1
#	$74 = add $72 $73
	add $t3, $s1, $t3
#	$75 = load 4 $74 0
	lw $t3, 0($t3)
#	$69 = seq $75 0
	li $t1, 0
	seq $t3, $t3, $t1
#	%WhileLoop84
_WhileLoop84:
#	$76 = sle $152 $157
	lw $t1, 1460($sp)
	sle $t3, $s4, $t1
#	br $76 %WhileBody11 %OutOfWhile12
	beqz $t3, _OutOfWhile12
#	%WhileBody11
_WhileBody11:
#	$78 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$79 = add $162 $78
	add $t3, $t4, $t3
#	$80 = load 4 $79 0
	lw $t3, 0($t3)
#	$81 = mul $80 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$82 = add $164 $81
	add $t3, $s6, $t3
#	$83 = load 4 $82 0
	lw $s1, 0($t3)
#	$84 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$85 = add $163 $84
	add $t3, $t8, $t3
#	$86 = load 4 $85 0
	lw $t3, 0($t3)
#	$87 = mul $86 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$88 = add $83 $87
	add $t3, $s1, $t3
#	$89 = load 4 $88 0
	lw $t3, 0($t3)
#	$159 = move $89
	move $s5, $t3
#	$92 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$93 = add $162 $92
	add $t3, $t4, $t3
#	$94 = load 4 $93 0
	lw $t3, 0($t3)
#	$91 = sub $94 1
	li $t1, 1
	sub $t3, $t3, $t1
#	$160 = move $91
	move $s7, $t3
#	$97 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$98 = add $163 $97
	add $t3, $t8, $t3
#	$99 = load 4 $98 0
	lw $t3, 0($t3)
#	$96 = sub $99 2
	li $t1, 2
	sub $t3, $t3, $t1
#	$161 = move $96
	move $k0, $t3
#	$102 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
#	br $102 %logicalTrue16 %logicalFalse17
	beqz $t3, _logicalFalse17
#	%logicalTrue16
_logicalTrue16:
#	$103 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
#	$101 = move $103
	move $k1, $t3
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalFalse17
_logicalFalse17:
#	$101 = move 0
	li $t0, 0
	move $k1, $t0
#	jump %logicalMerge18
	b _logicalMerge18
#	%logicalMerge18
_logicalMerge18:
#	br $101 %logicalTrue19 %logicalFalse20
	beqz $k1, _logicalFalse20
#	%logicalTrue19
_logicalTrue19:
#	$105 = mul $160 4
	li $t1, 4
	mul $t3, $s7, $t1
#	$106 = add $164 $105
	add $t3, $s6, $t3
#	$107 = load 4 $106 0
	lw $s1, 0($t3)
#	$108 = mul $161 4
	li $t1, 4
	mul $t3, $k0, $t1
#	$109 = add $107 $108
	add $t3, $s1, $t3
#	$110 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$111 = load 4 $109 0
	lw $t3, 0($t3)
#	$104 = seq $111 $110
	seq $t3, $t3, $s1
#	$100 = move $104
	move $gp, $t3
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalFalse20
_logicalFalse20:
#	$100 = move 0
	li $t0, 0
	move $gp, $t0
#	jump %logicalMerge21
	b _logicalMerge21
#	%logicalMerge21
_logicalMerge21:
#	br $100 %consequence13 %alternative14
	beqz $gp, _alternative14
#	%consequence13
_consequence13:
#	$113 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $t3, $t0, $t1
#	$157 = move $113
	sw $t3, 1460($sp)
#	$115 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$116 = add $162 $115
	add $t3, $t4, $t3
#	store 4 $116 $160 0
	sw $s7, 0($t3)
#	$118 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$119 = add $163 $118
	add $t3, $t8, $t3
#	store 4 $119 $161 0
	sw $k0, 0($t3)
#	$121 = mul $160 4
	li $t1, 4
	mul $t3, $s7, $t1
#	$122 = add $164 $121
	add $t3, $s6, $t3
#	$123 = load 4 $122 0
	lw $t3, 0($t3)
#	$124 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$125 = add $123 $124
	add $s1, $t3, $s1
#	$126 = add $159 1
	li $t1, 1
	add $t3, $s5, $t1
#	store 4 $125 $126 0
	sw $t3, 0($s1)
#	$128 = seq $160 $155
	seq $t3, $s7, $t6
#	br $128 %logicalTrue25 %logicalFalse26
	beqz $t3, _logicalFalse26
#	%logicalTrue25
_logicalTrue25:
#	$129 = seq $161 $156
	seq $t3, $k0, $t5
#	$127 = move $129
	move $fp, $t3
#	jump %logicalMerge27
	b _logicalMerge27
#	%logicalFalse26
_logicalFalse26:
#	$127 = move 0
	li $t0, 0
	move $fp, $t0
#	jump %logicalMerge27
	b _logicalMerge27
#	%logicalMerge27
_logicalMerge27:
#	br $127 %consequence22 %alternative23
	beqz $fp, _alternative23
#	%consequence22
_consequence22:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf24
	b _OutOfIf24
#	%alternative23
_alternative23:
#	jump %OutOfIf24
	b _OutOfIf24
#	%OutOfIf24
_OutOfIf24:
#	jump %OutOfIf15
	b _OutOfIf15
#	%alternative14
_alternative14:
#	jump %OutOfIf15
	b _OutOfIf15
#	%OutOfIf15
_OutOfIf15:
#	$133 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$134 = add $162 $133
	add $t3, $t4, $t3
#	$135 = load 4 $134 0
	lw $t3, 0($t3)
#	$132 = sub $135 1
	li $t1, 1
	sub $t3, $t3, $t1
#	$160 = move $132
	move $s7, $t3
#	$138 = mul $152 4
	li $t1, 4
	mul $t3, $s4, $t1
#	$139 = add $163 $138
	add $t3, $t8, $t3
#	$140 = load 4 $139 0
	lw $t3, 0($t3)
#	$137 = add $140 2
	li $t1, 2
	add $t3, $t3, $t1
#	$161 = move $137
	move $k0, $t3
#	$143 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
#	br $143 %logicalTrue31 %logicalFalse32
	beqz $t3, _logicalFalse32
#	%logicalTrue31
_logicalTrue31:
#	$144 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $t3, $v0
#	$142 = move $144
#	jump %logicalMerge33
	b _logicalMerge33
#	%logicalFalse32
_logicalFalse32:
#	$142 = move 0
	li $t0, 0
	move $t3, $t0
#	jump %logicalMerge33
	b _logicalMerge33
#	%logicalMerge33
_logicalMerge33:
#	br $142 %logicalTrue34 %logicalFalse35
	beqz $t3, _logicalFalse35
#	%logicalTrue34
_logicalTrue34:
#	$146 = mul $160 4
	li $t1, 4
	mul $s1, $s7, $t1
#	$147 = add $164 $146
	add $s1, $s6, $s1
#	$148 = load 4 $147 0
	lw $s1, 0($s1)
#	$149 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$150 = add $148 $149
	add $s3, $s1, $s3
#	$151 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$152 = load 4 $150 0
	lw $s3, 0($s3)
#	$145 = seq $152 $151
	seq $s1, $s3, $s1
#	$141 = move $145
#	jump %logicalMerge36
	b _logicalMerge36
#	%logicalFalse35
_logicalFalse35:
#	$141 = move 0
	li $t0, 0
	move $s1, $t0
#	jump %logicalMerge36
	b _logicalMerge36
#	%logicalMerge36
_logicalMerge36:
#	br $141 %consequence28 %alternative29
	beqz $s1, _alternative29
#	%consequence28
_consequence28:
#	$154 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $154
	sw $s3, 1460($sp)
#	$156 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$157 = add $162 $156
	add $s3, $t4, $s3
#	store 4 $157 $160 0
	sw $s7, 0($s3)
#	$159 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$160 = add $163 $159
	add $s3, $t8, $s3
#	store 4 $160 $161 0
	sw $k0, 0($s3)
#	$162 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$163 = add $164 $162
	add $s3, $s6, $s3
#	$164 = load 4 $163 0
	lw $s3, 0($s3)
#	$165 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$166 = add $164 $165
	add $s3, $s3, $s1
#	$167 = add $159 1
	li $t1, 1
	add $s1, $s5, $t1
#	store 4 $166 $167 0
	sw $s1, 0($s3)
#	$169 = seq $160 $155
	seq $s3, $s7, $t6
#	br $169 %logicalTrue40 %logicalFalse41
	beqz $s3, _logicalFalse41
#	%logicalTrue40
_logicalTrue40:
#	$170 = seq $161 $156
	seq $s3, $k0, $t5
#	$168 = move $170
#	jump %logicalMerge42
	b _logicalMerge42
#	%logicalFalse41
_logicalFalse41:
#	$168 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge42
	b _logicalMerge42
#	%logicalMerge42
_logicalMerge42:
#	br $168 %consequence37 %alternative38
	beqz $s3, _alternative38
#	%consequence37
_consequence37:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf39
	b _OutOfIf39
#	%alternative38
_alternative38:
#	jump %OutOfIf39
	b _OutOfIf39
#	%OutOfIf39
_OutOfIf39:
#	jump %OutOfIf30
	b _OutOfIf30
#	%alternative29
_alternative29:
#	jump %OutOfIf30
	b _OutOfIf30
#	%OutOfIf30
_OutOfIf30:
#	$174 = mul $152 4
	li $t1, 4
	mul $s7, $s4, $t1
#	$175 = add $162 $174
	add $s7, $t4, $s7
#	$176 = load 4 $175 0
	lw $s7, 0($s7)
#	$173 = add $176 1
	li $t1, 1
	add $s7, $s7, $t1
#	$160 = move $173
#	$179 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$180 = add $163 $179
	add $k0, $t8, $k0
#	$181 = load 4 $180 0
	lw $k0, 0($k0)
#	$178 = sub $181 2
	li $t1, 2
	sub $k0, $k0, $t1
#	$161 = move $178
#	$184 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $184 %logicalTrue46 %logicalFalse47
	beqz $s3, _logicalFalse47
#	%logicalTrue46
_logicalTrue46:
#	$185 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$183 = move $185
#	jump %logicalMerge48
	b _logicalMerge48
#	%logicalFalse47
_logicalFalse47:
#	$183 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge48
	b _logicalMerge48
#	%logicalMerge48
_logicalMerge48:
#	br $183 %logicalTrue49 %logicalFalse50
	beqz $s3, _logicalFalse50
#	%logicalTrue49
_logicalTrue49:
#	$187 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$188 = add $164 $187
	add $s3, $s6, $s3
#	$189 = load 4 $188 0
	lw $s1, 0($s3)
#	$190 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$191 = add $189 $190
	add $s3, $s1, $s3
#	$192 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$193 = load 4 $191 0
	lw $s3, 0($s3)
#	$186 = seq $193 $192
	seq $s3, $s3, $s1
#	$182 = move $186
#	jump %logicalMerge51
	b _logicalMerge51
#	%logicalFalse50
_logicalFalse50:
#	$182 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge51
	b _logicalMerge51
#	%logicalMerge51
_logicalMerge51:
#	br $182 %consequence43 %alternative44
	beqz $s3, _alternative44
#	%consequence43
_consequence43:
#	$195 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $195
	sw $s3, 1460($sp)
#	$197 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$198 = add $162 $197
	add $s3, $t4, $s3
#	store 4 $198 $160 0
	sw $s7, 0($s3)
#	$200 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$201 = add $163 $200
	add $s3, $t8, $s3
#	store 4 $201 $161 0
	sw $k0, 0($s3)
#	$203 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$204 = add $164 $203
	add $s3, $s6, $s3
#	$205 = load 4 $204 0
	lw $s3, 0($s3)
#	$206 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$207 = add $205 $206
	add $s3, $s3, $s1
#	$208 = add $159 1
	li $t1, 1
	add $s1, $s5, $t1
#	store 4 $207 $208 0
	sw $s1, 0($s3)
#	$210 = seq $160 $155
	seq $s7, $s7, $t6
#	br $210 %logicalTrue55 %logicalFalse56
	beqz $s7, _logicalFalse56
#	%logicalTrue55
_logicalTrue55:
#	$211 = seq $161 $156
	seq $s7, $k0, $t5
#	$209 = move $211
#	jump %logicalMerge57
	b _logicalMerge57
#	%logicalFalse56
_logicalFalse56:
#	$209 = move 0
	li $t0, 0
	move $s7, $t0
#	jump %logicalMerge57
	b _logicalMerge57
#	%logicalMerge57
_logicalMerge57:
#	br $209 %consequence52 %alternative53
	beqz $s7, _alternative53
#	%consequence52
_consequence52:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf54
	b _OutOfIf54
#	%alternative53
_alternative53:
#	jump %OutOfIf54
	b _OutOfIf54
#	%OutOfIf54
_OutOfIf54:
#	jump %OutOfIf45
	b _OutOfIf45
#	%alternative44
_alternative44:
#	jump %OutOfIf45
	b _OutOfIf45
#	%OutOfIf45
_OutOfIf45:
#	$215 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$216 = add $162 $215
	add $k0, $t4, $k0
#	$217 = load 4 $216 0
	lw $k0, 0($k0)
#	$214 = add $217 1
	li $t1, 1
	add $k0, $k0, $t1
#	$160 = move $214
	move $s7, $k0
#	$220 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$221 = add $163 $220
	add $k0, $t8, $k0
#	$222 = load 4 $221 0
	lw $k0, 0($k0)
#	$219 = add $222 2
	li $t1, 2
	add $k0, $k0, $t1
#	$161 = move $219
#	$225 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $225 %logicalTrue61 %logicalFalse62
	beqz $s3, _logicalFalse62
#	%logicalTrue61
_logicalTrue61:
#	$226 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$224 = move $226
#	jump %logicalMerge63
	b _logicalMerge63
#	%logicalFalse62
_logicalFalse62:
#	$224 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge63
	b _logicalMerge63
#	%logicalMerge63
_logicalMerge63:
#	br $224 %logicalTrue64 %logicalFalse65
	beqz $s3, _logicalFalse65
#	%logicalTrue64
_logicalTrue64:
#	$228 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$229 = add $164 $228
	add $s3, $s6, $s3
#	$230 = load 4 $229 0
	lw $s1, 0($s3)
#	$231 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$232 = add $230 $231
	add $s3, $s1, $s3
#	$233 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$234 = load 4 $232 0
	lw $s3, 0($s3)
#	$227 = seq $234 $233
	seq $s3, $s3, $s1
#	$223 = move $227
#	jump %logicalMerge66
	b _logicalMerge66
#	%logicalFalse65
_logicalFalse65:
#	$223 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge66
	b _logicalMerge66
#	%logicalMerge66
_logicalMerge66:
#	br $223 %consequence58 %alternative59
	beqz $s3, _alternative59
#	%consequence58
_consequence58:
#	$236 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $236
	sw $s3, 1460($sp)
#	$238 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$239 = add $162 $238
	add $s3, $t4, $s3
#	store 4 $239 $160 0
	sw $s7, 0($s3)
#	$241 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$242 = add $163 $241
	add $s3, $t8, $s3
#	store 4 $242 $161 0
	sw $k0, 0($s3)
#	$244 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$245 = add $164 $244
	add $s3, $s6, $s3
#	$246 = load 4 $245 0
	lw $s1, 0($s3)
#	$247 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$248 = add $246 $247
	add $s1, $s1, $s3
#	$249 = add $159 1
	li $t1, 1
	add $s3, $s5, $t1
#	store 4 $248 $249 0
	sw $s3, 0($s1)
#	$251 = seq $160 $155
	seq $s7, $s7, $t6
#	br $251 %logicalTrue70 %logicalFalse71
	beqz $s7, _logicalFalse71
#	%logicalTrue70
_logicalTrue70:
#	$252 = seq $161 $156
	seq $k0, $k0, $t5
#	$250 = move $252
#	jump %logicalMerge72
	b _logicalMerge72
#	%logicalFalse71
_logicalFalse71:
#	$250 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge72
	b _logicalMerge72
#	%logicalMerge72
_logicalMerge72:
#	br $250 %consequence67 %alternative68
	beqz $k0, _alternative68
#	%consequence67
_consequence67:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf69
	b _OutOfIf69
#	%alternative68
_alternative68:
#	jump %OutOfIf69
	b _OutOfIf69
#	%OutOfIf69
_OutOfIf69:
#	jump %OutOfIf60
	b _OutOfIf60
#	%alternative59
_alternative59:
#	jump %OutOfIf60
	b _OutOfIf60
#	%OutOfIf60
_OutOfIf60:
#	$256 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$257 = add $162 $256
	add $k0, $t4, $k0
#	$258 = load 4 $257 0
	lw $k0, 0($k0)
#	$255 = sub $258 2
	li $t1, 2
	sub $k0, $k0, $t1
#	$160 = move $255
	move $s7, $k0
#	$261 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$262 = add $163 $261
	add $k0, $t8, $k0
#	$263 = load 4 $262 0
	lw $k0, 0($k0)
#	$260 = sub $263 1
	li $t1, 1
	sub $k0, $k0, $t1
#	$161 = move $260
#	$266 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $266 %logicalTrue76 %logicalFalse77
	beqz $s3, _logicalFalse77
#	%logicalTrue76
_logicalTrue76:
#	$267 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$265 = move $267
#	jump %logicalMerge78
	b _logicalMerge78
#	%logicalFalse77
_logicalFalse77:
#	$265 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge78
	b _logicalMerge78
#	%logicalMerge78
_logicalMerge78:
#	br $265 %logicalTrue79 %logicalFalse80
	beqz $s3, _logicalFalse80
#	%logicalTrue79
_logicalTrue79:
#	$269 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$270 = add $164 $269
	add $s3, $s6, $s3
#	$271 = load 4 $270 0
	lw $s3, 0($s3)
#	$272 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$273 = add $271 $272
	add $s3, $s3, $s1
#	$274 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$275 = load 4 $273 0
	lw $s3, 0($s3)
#	$268 = seq $275 $274
	seq $s3, $s3, $s1
#	$264 = move $268
#	jump %logicalMerge81
	b _logicalMerge81
#	%logicalFalse80
_logicalFalse80:
#	$264 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge81
	b _logicalMerge81
#	%logicalMerge81
_logicalMerge81:
#	br $264 %consequence73 %alternative74
	beqz $s3, _alternative74
#	%consequence73
_consequence73:
#	$277 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $277
	sw $s3, 1460($sp)
#	$279 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$280 = add $162 $279
	add $s3, $t4, $s3
#	store 4 $280 $160 0
	sw $s7, 0($s3)
#	$282 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$283 = add $163 $282
	add $s3, $t8, $s3
#	store 4 $283 $161 0
	sw $k0, 0($s3)
#	$285 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$286 = add $164 $285
	add $s3, $s6, $s3
#	$287 = load 4 $286 0
	lw $s3, 0($s3)
#	$288 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$289 = add $287 $288
	add $s3, $s3, $s1
#	$290 = add $159 1
	li $t1, 1
	add $s1, $s5, $t1
#	store 4 $289 $290 0
	sw $s1, 0($s3)
#	$292 = seq $160 $155
	seq $s7, $s7, $t6
#	br $292 %logicalTrue85 %logicalFalse86
	beqz $s7, _logicalFalse86
#	%logicalTrue85
_logicalTrue85:
#	$293 = seq $161 $156
	seq $k0, $k0, $t5
#	$291 = move $293
#	jump %logicalMerge87
	b _logicalMerge87
#	%logicalFalse86
_logicalFalse86:
#	$291 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge87
	b _logicalMerge87
#	%logicalMerge87
_logicalMerge87:
#	br $291 %consequence82 %alternative83
	beqz $k0, _alternative83
#	%consequence82
_consequence82:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf84
	b _OutOfIf84
#	%alternative83
_alternative83:
#	jump %OutOfIf84
	b _OutOfIf84
#	%OutOfIf84
_OutOfIf84:
#	jump %OutOfIf75
	b _OutOfIf75
#	%alternative74
_alternative74:
#	jump %OutOfIf75
	b _OutOfIf75
#	%OutOfIf75
_OutOfIf75:
#	$297 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$298 = add $162 $297
	add $k0, $t4, $k0
#	$299 = load 4 $298 0
	lw $s7, 0($k0)
#	$296 = sub $299 2
	li $t1, 2
	sub $k0, $s7, $t1
#	$160 = move $296
	move $s7, $k0
#	$302 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$303 = add $163 $302
	add $k0, $t8, $k0
#	$304 = load 4 $303 0
	lw $k0, 0($k0)
#	$301 = add $304 1
	li $t1, 1
	add $k0, $k0, $t1
#	$161 = move $301
#	$307 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $307 %logicalTrue91 %logicalFalse92
	beqz $s3, _logicalFalse92
#	%logicalTrue91
_logicalTrue91:
#	$308 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$306 = move $308
#	jump %logicalMerge93
	b _logicalMerge93
#	%logicalFalse92
_logicalFalse92:
#	$306 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge93
	b _logicalMerge93
#	%logicalMerge93
_logicalMerge93:
#	br $306 %logicalTrue94 %logicalFalse95
	beqz $s3, _logicalFalse95
#	%logicalTrue94
_logicalTrue94:
#	$310 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$311 = add $164 $310
	add $s3, $s6, $s3
#	$312 = load 4 $311 0
	lw $s1, 0($s3)
#	$313 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$314 = add $312 $313
	add $s3, $s1, $s3
#	$315 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$316 = load 4 $314 0
	lw $s3, 0($s3)
#	$309 = seq $316 $315
	seq $s3, $s3, $s1
#	$305 = move $309
#	jump %logicalMerge96
	b _logicalMerge96
#	%logicalFalse95
_logicalFalse95:
#	$305 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge96
	b _logicalMerge96
#	%logicalMerge96
_logicalMerge96:
#	br $305 %consequence88 %alternative89
	beqz $s3, _alternative89
#	%consequence88
_consequence88:
#	$318 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $318
	sw $s3, 1460($sp)
#	$320 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$321 = add $162 $320
	add $s3, $t4, $s3
#	store 4 $321 $160 0
	sw $s7, 0($s3)
#	$323 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$324 = add $163 $323
	add $s3, $t8, $s3
#	store 4 $324 $161 0
	sw $k0, 0($s3)
#	$326 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$327 = add $164 $326
	add $s3, $s6, $s3
#	$328 = load 4 $327 0
	lw $s3, 0($s3)
#	$329 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$330 = add $328 $329
	add $s1, $s3, $s1
#	$331 = add $159 1
	li $t1, 1
	add $s3, $s5, $t1
#	store 4 $330 $331 0
	sw $s3, 0($s1)
#	$333 = seq $160 $155
	seq $s7, $s7, $t6
#	br $333 %logicalTrue100 %logicalFalse101
	beqz $s7, _logicalFalse101
#	%logicalTrue100
_logicalTrue100:
#	$334 = seq $161 $156
	seq $k0, $k0, $t5
#	$332 = move $334
#	jump %logicalMerge102
	b _logicalMerge102
#	%logicalFalse101
_logicalFalse101:
#	$332 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge102
	b _logicalMerge102
#	%logicalMerge102
_logicalMerge102:
#	br $332 %consequence97 %alternative98
	beqz $k0, _alternative98
#	%consequence97
_consequence97:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf99
	b _OutOfIf99
#	%alternative98
_alternative98:
#	jump %OutOfIf99
	b _OutOfIf99
#	%OutOfIf99
_OutOfIf99:
#	jump %OutOfIf90
	b _OutOfIf90
#	%alternative89
_alternative89:
#	jump %OutOfIf90
	b _OutOfIf90
#	%OutOfIf90
_OutOfIf90:
#	$338 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$339 = add $162 $338
	add $k0, $t4, $k0
#	$340 = load 4 $339 0
	lw $k0, 0($k0)
#	$337 = add $340 2
	li $t1, 2
	add $k0, $k0, $t1
#	$160 = move $337
	move $s7, $k0
#	$343 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$344 = add $163 $343
	add $k0, $t8, $k0
#	$345 = load 4 $344 0
	lw $k0, 0($k0)
#	$342 = sub $345 1
	li $t1, 1
	sub $k0, $k0, $t1
#	$161 = move $342
#	$348 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $348 %logicalTrue106 %logicalFalse107
	beqz $s3, _logicalFalse107
#	%logicalTrue106
_logicalTrue106:
#	$349 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$347 = move $349
#	jump %logicalMerge108
	b _logicalMerge108
#	%logicalFalse107
_logicalFalse107:
#	$347 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge108
	b _logicalMerge108
#	%logicalMerge108
_logicalMerge108:
#	br $347 %logicalTrue109 %logicalFalse110
	beqz $s3, _logicalFalse110
#	%logicalTrue109
_logicalTrue109:
#	$351 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$352 = add $164 $351
	add $s3, $s6, $s3
#	$353 = load 4 $352 0
	lw $s1, 0($s3)
#	$354 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$355 = add $353 $354
	add $s3, $s1, $s3
#	$356 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$357 = load 4 $355 0
	lw $s3, 0($s3)
#	$350 = seq $357 $356
	seq $s3, $s3, $s1
#	$346 = move $350
#	jump %logicalMerge111
	b _logicalMerge111
#	%logicalFalse110
_logicalFalse110:
#	$346 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge111
	b _logicalMerge111
#	%logicalMerge111
_logicalMerge111:
#	br $346 %consequence103 %alternative104
	beqz $s3, _alternative104
#	%consequence103
_consequence103:
#	$359 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $359
	sw $s3, 1460($sp)
#	$361 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$362 = add $162 $361
	add $s3, $t4, $s3
#	store 4 $362 $160 0
	sw $s7, 0($s3)
#	$364 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$365 = add $163 $364
	add $s3, $t8, $s3
#	store 4 $365 $161 0
	sw $k0, 0($s3)
#	$367 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$368 = add $164 $367
	add $s3, $s6, $s3
#	$369 = load 4 $368 0
	lw $s1, 0($s3)
#	$370 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$371 = add $369 $370
	add $s3, $s1, $s3
#	$372 = add $159 1
	li $t1, 1
	add $s1, $s5, $t1
#	store 4 $371 $372 0
	sw $s1, 0($s3)
#	$374 = seq $160 $155
	seq $s7, $s7, $t6
#	br $374 %logicalTrue115 %logicalFalse116
	beqz $s7, _logicalFalse116
#	%logicalTrue115
_logicalTrue115:
#	$375 = seq $161 $156
	seq $k0, $k0, $t5
#	$373 = move $375
#	jump %logicalMerge117
	b _logicalMerge117
#	%logicalFalse116
_logicalFalse116:
#	$373 = move 0
	li $t0, 0
	move $k0, $t0
#	jump %logicalMerge117
	b _logicalMerge117
#	%logicalMerge117
_logicalMerge117:
#	br $373 %consequence112 %alternative113
	beqz $k0, _alternative113
#	%consequence112
_consequence112:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf114
	b _OutOfIf114
#	%alternative113
_alternative113:
#	jump %OutOfIf114
	b _OutOfIf114
#	%OutOfIf114
_OutOfIf114:
#	jump %OutOfIf105
	b _OutOfIf105
#	%alternative104
_alternative104:
#	jump %OutOfIf105
	b _OutOfIf105
#	%OutOfIf105
_OutOfIf105:
#	$379 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$380 = add $162 $379
	add $k0, $t4, $k0
#	$381 = load 4 $380 0
	lw $k0, 0($k0)
#	$378 = add $381 2
	li $t1, 2
	add $k0, $k0, $t1
#	$160 = move $378
	move $s7, $k0
#	$384 = mul $152 4
	li $t1, 4
	mul $k0, $s4, $t1
#	$385 = add $163 $384
	add $k0, $t8, $k0
#	$386 = load 4 $385 0
	lw $k0, 0($k0)
#	$383 = add $386 1
	li $t1, 1
	add $k0, $k0, $t1
#	$161 = move $383
#	$389 = call check $160 $151
	sw $s7, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	br $389 %logicalTrue121 %logicalFalse122
	beqz $s3, _logicalFalse122
#	%logicalTrue121
_logicalTrue121:
#	$390 = call check $161 $151
	sw $k0, -8($sp)
	sw $t2, -4($sp)
	jal _check
	move $s3, $v0
#	$388 = move $390
#	jump %logicalMerge123
	b _logicalMerge123
#	%logicalFalse122
_logicalFalse122:
#	$388 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge123
	b _logicalMerge123
#	%logicalMerge123
_logicalMerge123:
#	br $388 %logicalTrue124 %logicalFalse125
	beqz $s3, _logicalFalse125
#	%logicalTrue124
_logicalTrue124:
#	$392 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$393 = add $164 $392
	add $s3, $s6, $s3
#	$394 = load 4 $393 0
	lw $s1, 0($s3)
#	$395 = mul $161 4
	li $t1, 4
	mul $s3, $k0, $t1
#	$396 = add $394 $395
	add $s3, $s1, $s3
#	$397 = neg 1
	li $t0, 1
	neg $s1, $t0
#	$398 = load 4 $396 0
	lw $s3, 0($s3)
#	$391 = seq $398 $397
	seq $s3, $s3, $s1
#	$387 = move $391
#	jump %logicalMerge126
	b _logicalMerge126
#	%logicalFalse125
_logicalFalse125:
#	$387 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge126
	b _logicalMerge126
#	%logicalMerge126
_logicalMerge126:
#	br $387 %consequence118 %alternative119
	beqz $s3, _alternative119
#	%consequence118
_consequence118:
#	$400 = add $157 1
	lw $t0, 1460($sp)
	li $t1, 1
	add $s3, $t0, $t1
#	$157 = move $400
	sw $s3, 1460($sp)
#	$402 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$403 = add $162 $402
	add $s3, $t4, $s3
#	store 4 $403 $160 0
	sw $s7, 0($s3)
#	$405 = mul $157 4
	lw $t0, 1460($sp)
	li $t1, 4
	mul $s3, $t0, $t1
#	$406 = add $163 $405
	add $s3, $t8, $s3
#	store 4 $406 $161 0
	sw $k0, 0($s3)
#	$408 = mul $160 4
	li $t1, 4
	mul $s3, $s7, $t1
#	$409 = add $164 $408
	add $s3, $s6, $s3
#	$410 = load 4 $409 0
	lw $s3, 0($s3)
#	$411 = mul $161 4
	li $t1, 4
	mul $s1, $k0, $t1
#	$412 = add $410 $411
	add $s3, $s3, $s1
#	$413 = add $159 1
	li $t1, 1
	add $s1, $s5, $t1
#	store 4 $412 $413 0
	sw $s1, 0($s3)
#	$415 = seq $160 $155
	seq $s3, $s7, $t6
#	br $415 %logicalTrue130 %logicalFalse131
	beqz $s3, _logicalFalse131
#	%logicalTrue130
_logicalTrue130:
#	$416 = seq $161 $156
	seq $s3, $k0, $t5
#	$414 = move $416
#	jump %logicalMerge132
	b _logicalMerge132
#	%logicalFalse131
_logicalFalse131:
#	$414 = move 0
	li $t0, 0
	move $s3, $t0
#	jump %logicalMerge132
	b _logicalMerge132
#	%logicalMerge132
_logicalMerge132:
#	br $414 %consequence127 %alternative128
	beqz $s3, _alternative128
#	%consequence127
_consequence127:
#	$158 = move 1
	li $t0, 1
	move $s3, $t0
#	jump %OutOfIf129
	b _OutOfIf129
#	%alternative128
_alternative128:
#	jump %OutOfIf129
	b _OutOfIf129
#	%OutOfIf129
_OutOfIf129:
#	jump %OutOfIf120
	b _OutOfIf120
#	%alternative119
_alternative119:
#	jump %OutOfIf120
	b _OutOfIf120
#	%OutOfIf120
_OutOfIf120:
#	$418 = seq $158 1
	li $t1, 1
	seq $s1, $s3, $t1
#	br $418 %consequence133 %alternative134
	beqz $s1, _alternative134
#	%consequence133
_consequence133:
#	jump %OutOfWhile12
	b _OutOfWhile12
#	jump %OutOfIf135
	b _OutOfIf135
#	%alternative134
_alternative134:
#	jump %OutOfIf135
	b _OutOfIf135
#	%OutOfIf135
_OutOfIf135:
#	$420 = add $152 1
	li $t1, 1
	add $s4, $s4, $t1
#	$152 = move $420
#	jump %WhileLoop84
	b _WhileLoop84
#	%OutOfWhile12
_OutOfWhile12:
#	$421 = seq $158 1
	li $t1, 1
	seq $s1, $s3, $t1
#	br $421 %consequence136 %alternative137
	beqz $s1, _alternative137
#	%consequence136
_consequence136:
#	$422 = mul $155 4
	li $t1, 4
	mul $s1, $t6, $t1
#	$423 = add $164 $422
	add $s1, $s6, $s1
#	$424 = load 4 $423 0
	lw $t3, 0($s1)
#	$425 = mul $156 4
	li $t1, 4
	mul $s1, $t5, $t1
#	$426 = add $424 $425
	add $s1, $t3, $s1
#	$427 = load 4 $426 0
	lw $s1, 0($s1)
#	$428 = call toString $427
	move $a0, $s1
	jal func__toString
	move $s1, $v0
#	nullcall println $428
	move $a0, $s1
	jal func__println
	move $s1, $v0
#	jump %OutOfIf138
	b _OutOfIf138
#	%alternative137
_alternative137:
#	nullcall print "no solution!\n"
	la $a0, string_430
	jal func__print
	move $s1, $v0
#	jump %OutOfIf138
	b _OutOfIf138
#	%OutOfIf138
_OutOfIf138:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl75
	b _EndOfFunctionDecl75
#	%EndOfFunctionDecl75
_EndOfFunctionDecl75:
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
	add $sp, $sp, 1576
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
.word 13
string_430:
.asciiz "no solution!\n"
.align 2
