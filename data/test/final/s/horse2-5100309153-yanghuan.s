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
_BeginOfFunctionDecl72:
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _logicalFalse1
_logicalTrue0:
	lw $t0, 140($sp)
	li $t1, 0
	sge $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	sw $t0, 128($sp)
	b _logicalMerge2
_logicalFalse1:
	li $t0, 0
	sw $t0, 128($sp)
	b _logicalMerge2
_logicalMerge2:
	lw $v0, 128($sp)
	b _EndOfFunctionDecl73
_EndOfFunctionDecl73:
	add $sp, $sp, 148
	jr $ra
main:
	sub $sp, $sp, 1576
	sw $ra, 120($sp)
_BeginOfFunctionDecl74:
	jal func__getInt
	sw $v0, 348($sp)
	lw $t0, 348($sp)
	sw $t0, 440($sp)
	li $t0, 0
	sw $t0, 860($sp)
	lw $t0, 860($sp)
	sw $t0, 772($sp)
	lw $t0, 772($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	sw $t0, 1376($sp)
	lw $t0, 440($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 628($sp)
	lw $t0, 628($sp)
	sw $t0, 692($sp)
	lw $t0, 692($sp)
	sw $t0, 1496($sp)
	li $t0, 0
	sw $t0, 560($sp)
	lw $t0, 560($sp)
	sw $t0, 376($sp)
	li $t0, 0
	sw $t0, 1168($sp)
	lw $t0, 1168($sp)
	sw $t0, 1028($sp)
	lw $t0, 440($sp)
	lw $t1, 440($sp)
	mul $t1, $t0, $t1
	sw $t1, 740($sp)
	lw $t0, 740($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1328($sp)
	lw $t0, 1328($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1328($sp)
	lw $a0, 1328($sp)
	li $v0, 9
	syscall
	sw $v0, 572($sp)
	lw $t0, 740($sp)
	lw $t1, 572($sp)
	sw $t0, 0($t1)
	lw $t0, 572($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 572($sp)
	lw $t0, 572($sp)
	sw $t0, 1316($sp)
	lw $t0, 1316($sp)
	sw $t0, 508($sp)
	li $t0, 0
	sw $t0, 788($sp)
_ForLoop76:
	lw $t0, 440($sp)
	lw $t1, 440($sp)
	mul $t1, $t0, $t1
	sw $t1, 568($sp)
	lw $t0, 788($sp)
	lw $t1, 568($sp)
	slt $t1, $t0, $t1
	sw $t1, 1412($sp)
	lw $t0, 1412($sp)
	beqz $t0, _OutOfFor4
_ForBody3:
	lw $t0, 788($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1332($sp)
	lw $t0, 508($sp)
	lw $t1, 1332($sp)
	add $t1, $t0, $t1
	sw $t1, 1392($sp)
	li $t0, 0
	lw $t1, 1392($sp)
	sw $t0, 0($t1)
_continueFor77:
	lw $t0, 788($sp)
	sw $t0, 532($sp)
	lw $t0, 788($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 788($sp)
	b _ForLoop76
_OutOfFor4:
	lw $t0, 440($sp)
	lw $t1, 440($sp)
	mul $t1, $t0, $t1
	sw $t1, 1524($sp)
	lw $t0, 1524($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $t0, 1080($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $a0, 1080($sp)
	li $v0, 9
	syscall
	sw $v0, 176($sp)
	lw $t0, 1524($sp)
	lw $t1, 176($sp)
	sw $t0, 0($t1)
	lw $t0, 176($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 176($sp)
	sw $t0, 1544($sp)
	lw $t0, 1544($sp)
	sw $t0, 144($sp)
	li $t0, 0
	sw $t0, 788($sp)
_ForLoop78:
	lw $t0, 440($sp)
	lw $t1, 440($sp)
	mul $t1, $t0, $t1
	sw $t1, 1352($sp)
	lw $t0, 788($sp)
	lw $t1, 1352($sp)
	slt $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 184($sp)
	beqz $t0, _OutOfFor6
_ForBody5:
	lw $t0, 788($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1252($sp)
	lw $t0, 144($sp)
	lw $t1, 1252($sp)
	add $t1, $t0, $t1
	sw $t1, 912($sp)
	li $t0, 0
	lw $t1, 912($sp)
	sw $t0, 0($t1)
_continueFor79:
	lw $t0, 788($sp)
	sw $t0, 456($sp)
	lw $t0, 788($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 788($sp)
	b _ForLoop78
_OutOfFor6:
	lw $t0, 440($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $t0, 412($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $a0, 412($sp)
	li $v0, 9
	syscall
	sw $v0, 200($sp)
	lw $t0, 440($sp)
	lw $t1, 200($sp)
	sw $t0, 0($t1)
	lw $t0, 200($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	sw $t0, 320($sp)
	lw $t0, 320($sp)
	sw $t0, 744($sp)
	li $t0, 0
	sw $t0, 788($sp)
_ForLoop80:
	lw $t0, 788($sp)
	lw $t1, 440($sp)
	slt $t1, $t0, $t1
	sw $t1, 460($sp)
	lw $t0, 460($sp)
	beqz $t0, _OutOfFor8
_ForBody7:
	lw $t0, 788($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1124($sp)
	lw $t0, 744($sp)
	lw $t1, 1124($sp)
	add $t1, $t0, $t1
	sw $t1, 1336($sp)
	lw $t0, 440($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 988($sp)
	lw $t0, 988($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 988($sp)
	lw $a0, 988($sp)
	li $v0, 9
	syscall
	sw $v0, 1192($sp)
	lw $t0, 440($sp)
	lw $t1, 1192($sp)
	sw $t0, 0($t1)
	lw $t0, 1192($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1192($sp)
	lw $t0, 1192($sp)
	sw $t0, 392($sp)
	lw $t0, 392($sp)
	lw $t1, 1336($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, 1272($sp)
_ForLoop82:
	lw $t0, 1272($sp)
	lw $t1, 440($sp)
	slt $t1, $t0, $t1
	sw $t1, 1092($sp)
	lw $t0, 1092($sp)
	beqz $t0, _OutOfFor10
_ForBody9:
	lw $t0, 788($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1176($sp)
	lw $t0, 744($sp)
	lw $t1, 1176($sp)
	add $t1, $t0, $t1
	sw $t1, 1036($sp)
	lw $t1, 1036($sp)
	lw $t0, 0($t1)
	sw $t0, 1116($sp)
	lw $t0, 1272($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, 1116($sp)
	lw $t1, 312($sp)
	add $t1, $t0, $t1
	sw $t1, 1360($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1424($sp)
	lw $t0, 1424($sp)
	lw $t1, 1360($sp)
	sw $t0, 0($t1)
_continueFor83:
	lw $t0, 1272($sp)
	sw $t0, 236($sp)
	lw $t0, 1272($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1272($sp)
	b _ForLoop82
_OutOfFor10:
	b _continueFor81
_continueFor81:
	lw $t0, 788($sp)
	sw $t0, 952($sp)
	lw $t0, 788($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 788($sp)
	b _ForLoop80
_OutOfFor8:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1284($sp)
	lw $t0, 508($sp)
	lw $t1, 1284($sp)
	add $t1, $t0, $t1
	sw $t1, 488($sp)
	lw $t0, 772($sp)
	lw $t1, 488($sp)
	sw $t0, 0($t1)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 496($sp)
	lw $t0, 144($sp)
	lw $t1, 496($sp)
	add $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, 860($sp)
	lw $t1, 216($sp)
	sw $t0, 0($t1)
	lw $t0, 772($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 920($sp)
	lw $t0, 744($sp)
	lw $t1, 920($sp)
	add $t1, $t0, $t1
	sw $t1, 512($sp)
	lw $t1, 512($sp)
	lw $t0, 0($t1)
	sw $t0, 1356($sp)
	lw $t0, 860($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1488($sp)
	lw $t0, 1356($sp)
	lw $t1, 1488($sp)
	add $t1, $t0, $t1
	sw $t1, 1548($sp)
	lw $t1, 1548($sp)
	lw $t0, 0($t1)
	sw $t0, 792($sp)
	lw $t0, 792($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 708($sp)
_WhileLoop84:
	lw $t0, 1376($sp)
	lw $t1, 140($sp)
	sle $t1, $t0, $t1
	sw $t1, 1552($sp)
	lw $t0, 1552($sp)
	beqz $t0, _OutOfWhile12
_WhileBody11:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $t0, 508($sp)
	lw $t1, 1200($sp)
	add $t1, $t0, $t1
	sw $t1, 704($sp)
	lw $t1, 704($sp)
	lw $t0, 0($t1)
	sw $t0, 936($sp)
	lw $t0, 936($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 600($sp)
	lw $t0, 744($sp)
	lw $t1, 600($sp)
	add $t1, $t0, $t1
	sw $t1, 1428($sp)
	lw $t1, 1428($sp)
	lw $t0, 0($t1)
	sw $t0, 1320($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1340($sp)
	lw $t0, 144($sp)
	lw $t1, 1340($sp)
	add $t1, $t0, $t1
	sw $t1, 924($sp)
	lw $t1, 924($sp)
	lw $t0, 0($t1)
	sw $t0, 160($sp)
	lw $t0, 160($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1476($sp)
	lw $t0, 1320($sp)
	lw $t1, 1476($sp)
	add $t1, $t0, $t1
	sw $t1, 736($sp)
	lw $t1, 736($sp)
	lw $t0, 0($t1)
	sw $t0, 1172($sp)
	lw $t0, 1172($sp)
	sw $t0, 1028($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 564($sp)
	lw $t0, 508($sp)
	lw $t1, 564($sp)
	add $t1, $t0, $t1
	sw $t1, 1220($sp)
	lw $t1, 1220($sp)
	lw $t0, 0($t1)
	sw $t0, 280($sp)
	lw $t0, 280($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 964($sp)
	lw $t0, 964($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1120($sp)
	lw $t0, 144($sp)
	lw $t1, 1120($sp)
	add $t1, $t0, $t1
	sw $t1, 1288($sp)
	lw $t1, 1288($sp)
	lw $t0, 0($t1)
	sw $t0, 128($sp)
	lw $t0, 128($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 1364($sp)
	lw $t0, 1364($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 796($sp)
	lw $t0, 796($sp)
	beqz $t0, _logicalFalse17
_logicalTrue16:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 876($sp)
	lw $t0, 876($sp)
	beqz $t0, _logicalFalse20
_logicalTrue19:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1060($sp)
	lw $t0, 744($sp)
	lw $t1, 1060($sp)
	add $t1, $t0, $t1
	sw $t1, 1084($sp)
	lw $t1, 1084($sp)
	lw $t0, 0($t1)
	sw $t0, 1244($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 416($sp)
	lw $t0, 1244($sp)
	lw $t1, 416($sp)
	add $t1, $t0, $t1
	sw $t1, 656($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 800($sp)
	lw $t1, 656($sp)
	lw $t0, 0($t1)
	sw $t0, 1276($sp)
	lw $t0, 1276($sp)
	lw $t1, 800($sp)
	seq $t1, $t0, $t1
	sw $t1, 588($sp)
	lw $t0, 588($sp)
	sw $t0, 1492($sp)
	b _logicalMerge21
_logicalFalse20:
	li $t0, 0
	sw $t0, 1492($sp)
	b _logicalMerge21
_logicalMerge21:
	lw $t0, 1492($sp)
	sw $t0, 492($sp)
	b _logicalMerge18
_logicalFalse17:
	li $t0, 0
	sw $t0, 492($sp)
	b _logicalMerge18
_logicalMerge18:
	lw $t0, 492($sp)
	beqz $t0, _alternative14
_consequence13:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 880($sp)
	lw $t0, 880($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 680($sp)
	lw $t0, 508($sp)
	lw $t1, 680($sp)
	add $t1, $t0, $t1
	sw $t1, 1048($sp)
	lw $t0, 376($sp)
	lw $t1, 1048($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 832($sp)
	lw $t0, 144($sp)
	lw $t1, 832($sp)
	add $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, 560($sp)
	lw $t1, 356($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 744($sp)
	lw $t1, 132($sp)
	add $t1, $t0, $t1
	sw $t1, 520($sp)
	lw $t1, 520($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 220($sp)
	lw $t1, 272($sp)
	add $t1, $t0, $t1
	sw $t1, 716($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 820($sp)
	lw $t0, 820($sp)
	lw $t1, 716($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 1532($sp)
	lw $t0, 1532($sp)
	beqz $t0, _logicalFalse26
_logicalTrue25:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 812($sp)
	lw $t0, 812($sp)
	sw $t0, 840($sp)
	b _logicalMerge27
_logicalFalse26:
	li $t0, 0
	sw $t0, 840($sp)
	b _logicalMerge27
_logicalMerge27:
	lw $t0, 840($sp)
	beqz $t0, _alternative23
_consequence22:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf24
_alternative23:
	b _OutOfIf24
_OutOfIf24:
	b _OutOfIf15
_alternative14:
	b _OutOfIf15
_OutOfIf15:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, 508($sp)
	lw $t1, 432($sp)
	add $t1, $t0, $t1
	sw $t1, 1020($sp)
	lw $t1, 1020($sp)
	lw $t0, 0($t1)
	sw $t0, 1556($sp)
	lw $t0, 1556($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 916($sp)
	lw $t0, 916($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1460($sp)
	lw $t0, 144($sp)
	lw $t1, 1460($sp)
	add $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t1, 288($sp)
	lw $t0, 0($t1)
	sw $t0, 212($sp)
	lw $t0, 212($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 1132($sp)
	lw $t0, 1132($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1016($sp)
	lw $t0, 1016($sp)
	beqz $t0, _logicalFalse32
_logicalTrue31:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 652($sp)
	lw $t0, 652($sp)
	beqz $t0, _logicalFalse35
_logicalTrue34:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 500($sp)
	lw $t0, 744($sp)
	lw $t1, 500($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t1, 224($sp)
	lw $t0, 0($t1)
	sw $t0, 1064($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 352($sp)
	lw $t0, 1064($sp)
	lw $t1, 352($sp)
	add $t1, $t0, $t1
	sw $t1, 1248($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1196($sp)
	lw $t1, 1248($sp)
	lw $t0, 0($t1)
	sw $t0, 892($sp)
	lw $t0, 892($sp)
	lw $t1, 1196($sp)
	seq $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t0, 300($sp)
	sw $t0, 904($sp)
	b _logicalMerge36
_logicalFalse35:
	li $t0, 0
	sw $t0, 904($sp)
	b _logicalMerge36
_logicalMerge36:
	lw $t0, 904($sp)
	sw $t0, 1144($sp)
	b _logicalMerge33
_logicalFalse32:
	li $t0, 0
	sw $t0, 1144($sp)
	b _logicalMerge33
_logicalMerge33:
	lw $t0, 1144($sp)
	beqz $t0, _alternative29
_consequence28:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1560($sp)
	lw $t0, 1560($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1512($sp)
	lw $t0, 508($sp)
	lw $t1, 1512($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, 376($sp)
	lw $t1, 208($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1052($sp)
	lw $t0, 144($sp)
	lw $t1, 1052($sp)
	add $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t0, 560($sp)
	lw $t1, 260($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1280($sp)
	lw $t0, 744($sp)
	lw $t1, 1280($sp)
	add $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t1, 380($sp)
	lw $t0, 0($t1)
	sw $t0, 1304($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, 1304($sp)
	lw $t1, 444($sp)
	add $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 688($sp)
	lw $t0, 688($sp)
	lw $t1, 240($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 1396($sp)
	lw $t0, 1396($sp)
	beqz $t0, _logicalFalse41
_logicalTrue40:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t0, 344($sp)
	sw $t0, 1044($sp)
	b _logicalMerge42
_logicalFalse41:
	li $t0, 0
	sw $t0, 1044($sp)
	b _logicalMerge42
_logicalMerge42:
	lw $t0, 1044($sp)
	beqz $t0, _alternative38
_consequence37:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf39
_alternative38:
	b _OutOfIf39
_OutOfIf39:
	b _OutOfIf30
_alternative29:
	b _OutOfIf30
_OutOfIf30:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1456($sp)
	lw $t0, 508($sp)
	lw $t1, 1456($sp)
	add $t1, $t0, $t1
	sw $t1, 484($sp)
	lw $t1, 484($sp)
	lw $t0, 0($t1)
	sw $t0, 848($sp)
	lw $t0, 848($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1068($sp)
	lw $t0, 1068($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1228($sp)
	lw $t0, 144($sp)
	lw $t1, 1228($sp)
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t1, 164($sp)
	lw $t0, 0($t1)
	sw $t0, 816($sp)
	lw $t0, 816($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 328($sp)
	lw $t0, 328($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1180($sp)
	lw $t0, 1180($sp)
	beqz $t0, _logicalFalse47
_logicalTrue46:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1148($sp)
	lw $t0, 1148($sp)
	beqz $t0, _logicalFalse50
_logicalTrue49:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 664($sp)
	lw $t0, 744($sp)
	lw $t1, 664($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t1, 136($sp)
	lw $t0, 0($t1)
	sw $t0, 596($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1528($sp)
	lw $t0, 596($sp)
	lw $t1, 1528($sp)
	add $t1, $t0, $t1
	sw $t1, 1484($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 684($sp)
	lw $t1, 1484($sp)
	lw $t0, 0($t1)
	sw $t0, 804($sp)
	lw $t0, 804($sp)
	lw $t1, 684($sp)
	seq $t1, $t0, $t1
	sw $t1, 968($sp)
	lw $t0, 968($sp)
	sw $t0, 668($sp)
	b _logicalMerge51
_logicalFalse50:
	li $t0, 0
	sw $t0, 668($sp)
	b _logicalMerge51
_logicalMerge51:
	lw $t0, 668($sp)
	sw $t0, 1452($sp)
	b _logicalMerge48
_logicalFalse47:
	li $t0, 0
	sw $t0, 1452($sp)
	b _logicalMerge48
_logicalMerge48:
	lw $t0, 1452($sp)
	beqz $t0, _alternative44
_consequence43:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1240($sp)
	lw $t0, 1240($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1444($sp)
	lw $t0, 508($sp)
	lw $t1, 1444($sp)
	add $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 376($sp)
	lw $t1, 168($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 756($sp)
	lw $t0, 144($sp)
	lw $t1, 756($sp)
	add $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t0, 560($sp)
	lw $t1, 404($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 576($sp)
	lw $t0, 744($sp)
	lw $t1, 576($sp)
	add $t1, $t0, $t1
	sw $t1, 864($sp)
	lw $t1, 864($sp)
	lw $t0, 0($t1)
	sw $t0, 1504($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1372($sp)
	lw $t0, 1504($sp)
	lw $t1, 1372($sp)
	add $t1, $t0, $t1
	sw $t1, 480($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	lw $t0, 332($sp)
	lw $t1, 480($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 1008($sp)
	lw $t0, 1008($sp)
	beqz $t0, _logicalFalse56
_logicalTrue55:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 888($sp)
	lw $t0, 888($sp)
	sw $t0, 956($sp)
	b _logicalMerge57
_logicalFalse56:
	li $t0, 0
	sw $t0, 956($sp)
	b _logicalMerge57
_logicalMerge57:
	lw $t0, 956($sp)
	beqz $t0, _alternative53
_consequence52:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf54
_alternative53:
	b _OutOfIf54
_OutOfIf54:
	b _OutOfIf45
_alternative44:
	b _OutOfIf45
_OutOfIf45:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t0, 508($sp)
	lw $t1, 364($sp)
	add $t1, $t0, $t1
	sw $t1, 940($sp)
	lw $t1, 940($sp)
	lw $t0, 0($t1)
	sw $t0, 148($sp)
	lw $t0, 148($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1128($sp)
	lw $t0, 1128($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1072($sp)
	lw $t0, 144($sp)
	lw $t1, 1072($sp)
	add $t1, $t0, $t1
	sw $t1, 624($sp)
	lw $t1, 624($sp)
	lw $t0, 0($t1)
	sw $t0, 172($sp)
	lw $t0, 172($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 872($sp)
	lw $t0, 872($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1564($sp)
	lw $t0, 1564($sp)
	beqz $t0, _logicalFalse62
_logicalTrue61:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 836($sp)
	lw $t0, 836($sp)
	beqz $t0, _logicalFalse65
_logicalTrue64:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 468($sp)
	lw $t0, 744($sp)
	lw $t1, 468($sp)
	add $t1, $t0, $t1
	sw $t1, 436($sp)
	lw $t1, 436($sp)
	lw $t0, 0($t1)
	sw $t0, 1212($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1156($sp)
	lw $t0, 1212($sp)
	lw $t1, 1156($sp)
	add $t1, $t0, $t1
	sw $t1, 448($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 424($sp)
	lw $t1, 448($sp)
	lw $t0, 0($t1)
	sw $t0, 980($sp)
	lw $t0, 980($sp)
	lw $t1, 424($sp)
	seq $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, 196($sp)
	sw $t0, 728($sp)
	b _logicalMerge66
_logicalFalse65:
	li $t0, 0
	sw $t0, 728($sp)
	b _logicalMerge66
_logicalMerge66:
	lw $t0, 728($sp)
	sw $t0, 396($sp)
	b _logicalMerge63
_logicalFalse62:
	li $t0, 0
	sw $t0, 396($sp)
	b _logicalMerge63
_logicalMerge63:
	lw $t0, 396($sp)
	beqz $t0, _alternative59
_consequence58:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1256($sp)
	lw $t0, 1256($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 608($sp)
	lw $t0, 508($sp)
	lw $t1, 608($sp)
	add $t1, $t0, $t1
	sw $t1, 1500($sp)
	lw $t0, 376($sp)
	lw $t1, 1500($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1264($sp)
	lw $t0, 144($sp)
	lw $t1, 1264($sp)
	add $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, 560($sp)
	lw $t1, 324($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t0, 744($sp)
	lw $t1, 336($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t1, 264($sp)
	lw $t0, 0($t1)
	sw $t0, 556($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1032($sp)
	lw $t0, 556($sp)
	lw $t1, 1032($sp)
	add $t1, $t0, $t1
	sw $t1, 1540($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1100($sp)
	lw $t0, 1100($sp)
	lw $t1, 1540($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 760($sp)
	lw $t0, 760($sp)
	beqz $t0, _logicalFalse71
_logicalTrue70:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 648($sp)
	lw $t0, 648($sp)
	sw $t0, 1160($sp)
	b _logicalMerge72
_logicalFalse71:
	li $t0, 0
	sw $t0, 1160($sp)
	b _logicalMerge72
_logicalMerge72:
	lw $t0, 1160($sp)
	beqz $t0, _alternative68
_consequence67:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf69
_alternative68:
	b _OutOfIf69
_OutOfIf69:
	b _OutOfIf60
_alternative59:
	b _OutOfIf60
_OutOfIf60:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 808($sp)
	lw $t0, 508($sp)
	lw $t1, 808($sp)
	add $t1, $t0, $t1
	sw $t1, 928($sp)
	lw $t1, 928($sp)
	lw $t0, 0($t1)
	sw $t0, 1464($sp)
	lw $t0, 1464($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 524($sp)
	lw $t0, 524($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1224($sp)
	lw $t0, 144($sp)
	lw $t1, 1224($sp)
	add $t1, $t0, $t1
	sw $t1, 620($sp)
	lw $t1, 620($sp)
	lw $t0, 0($t1)
	sw $t0, 672($sp)
	lw $t0, 672($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 244($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1468($sp)
	lw $t0, 1468($sp)
	beqz $t0, _logicalFalse77
_logicalTrue76:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1312($sp)
	lw $t0, 1312($sp)
	beqz $t0, _logicalFalse80
_logicalTrue79:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 420($sp)
	lw $t0, 744($sp)
	lw $t1, 420($sp)
	add $t1, $t0, $t1
	sw $t1, 884($sp)
	lw $t1, 884($sp)
	lw $t0, 0($t1)
	sw $t0, 1520($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 1520($sp)
	lw $t1, 204($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 516($sp)
	lw $t1, 228($sp)
	lw $t0, 0($t1)
	sw $t0, 360($sp)
	lw $t0, 360($sp)
	lw $t1, 516($sp)
	seq $t1, $t0, $t1
	sw $t1, 868($sp)
	lw $t0, 868($sp)
	sw $t0, 632($sp)
	b _logicalMerge81
_logicalFalse80:
	li $t0, 0
	sw $t0, 632($sp)
	b _logicalMerge81
_logicalMerge81:
	lw $t0, 632($sp)
	sw $t0, 296($sp)
	b _logicalMerge78
_logicalFalse77:
	li $t0, 0
	sw $t0, 296($sp)
	b _logicalMerge78
_logicalMerge78:
	lw $t0, 296($sp)
	beqz $t0, _alternative74
_consequence73:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1232($sp)
	lw $t0, 1232($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1260($sp)
	lw $t0, 508($sp)
	lw $t1, 1260($sp)
	add $t1, $t0, $t1
	sw $t1, 580($sp)
	lw $t0, 376($sp)
	lw $t1, 580($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1416($sp)
	lw $t0, 144($sp)
	lw $t1, 1416($sp)
	add $t1, $t0, $t1
	sw $t1, 696($sp)
	lw $t0, 560($sp)
	lw $t1, 696($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 472($sp)
	lw $t0, 744($sp)
	lw $t1, 472($sp)
	add $t1, $t0, $t1
	sw $t1, 464($sp)
	lw $t1, 464($sp)
	lw $t0, 0($t1)
	sw $t0, 1208($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 1208($sp)
	lw $t1, 232($sp)
	add $t1, $t0, $t1
	sw $t1, 960($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 636($sp)
	lw $t0, 636($sp)
	lw $t1, 960($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 504($sp)
	lw $t0, 504($sp)
	beqz $t0, _logicalFalse86
_logicalTrue85:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	sw $t0, 712($sp)
	b _logicalMerge87
_logicalFalse86:
	li $t0, 0
	sw $t0, 712($sp)
	b _logicalMerge87
_logicalMerge87:
	lw $t0, 712($sp)
	beqz $t0, _alternative83
_consequence82:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf84
_alternative83:
	b _OutOfIf84
_OutOfIf84:
	b _OutOfIf75
_alternative74:
	b _OutOfIf75
_OutOfIf75:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 552($sp)
	lw $t0, 508($sp)
	lw $t1, 552($sp)
	add $t1, $t0, $t1
	sw $t1, 1184($sp)
	lw $t1, 1184($sp)
	lw $t0, 0($t1)
	sw $t0, 156($sp)
	lw $t0, 156($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 1056($sp)
	lw $t0, 1056($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 824($sp)
	lw $t0, 144($sp)
	lw $t1, 824($sp)
	add $t1, $t0, $t1
	sw $t1, 1040($sp)
	lw $t1, 1040($sp)
	lw $t0, 0($t1)
	sw $t0, 764($sp)
	lw $t0, 764($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 284($sp)
	lw $t0, 284($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1216($sp)
	lw $t0, 1216($sp)
	beqz $t0, _logicalFalse92
_logicalTrue91:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 720($sp)
	lw $t0, 720($sp)
	beqz $t0, _logicalFalse95
_logicalTrue94:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1188($sp)
	lw $t0, 744($sp)
	lw $t1, 1188($sp)
	add $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t1, 268($sp)
	lw $t0, 0($t1)
	sw $t0, 256($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1204($sp)
	lw $t0, 256($sp)
	lw $t1, 1204($sp)
	add $t1, $t0, $t1
	sw $t1, 408($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 540($sp)
	lw $t1, 408($sp)
	lw $t0, 0($t1)
	sw $t0, 768($sp)
	lw $t0, 768($sp)
	lw $t1, 540($sp)
	seq $t1, $t0, $t1
	sw $t1, 1004($sp)
	lw $t0, 1004($sp)
	sw $t0, 972($sp)
	b _logicalMerge96
_logicalFalse95:
	li $t0, 0
	sw $t0, 972($sp)
	b _logicalMerge96
_logicalMerge96:
	lw $t0, 972($sp)
	sw $t0, 776($sp)
	b _logicalMerge93
_logicalFalse92:
	li $t0, 0
	sw $t0, 776($sp)
	b _logicalMerge93
_logicalMerge93:
	lw $t0, 776($sp)
	beqz $t0, _alternative89
_consequence88:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 544($sp)
	lw $t0, 544($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t0, 508($sp)
	lw $t1, 316($sp)
	add $t1, $t0, $t1
	sw $t1, 1400($sp)
	lw $t0, 376($sp)
	lw $t1, 1400($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 948($sp)
	lw $t0, 144($sp)
	lw $t1, 948($sp)
	add $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 560($sp)
	lw $t1, 252($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1076($sp)
	lw $t0, 744($sp)
	lw $t1, 1076($sp)
	add $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t1, 304($sp)
	lw $t0, 0($t1)
	sw $t0, 996($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1300($sp)
	lw $t0, 996($sp)
	lw $t1, 1300($sp)
	add $t1, $t0, $t1
	sw $t1, 724($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 700($sp)
	lw $t0, 700($sp)
	lw $t1, 724($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 180($sp)
	beqz $t0, _logicalFalse101
_logicalTrue100:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 640($sp)
	lw $t0, 640($sp)
	sw $t0, 660($sp)
	b _logicalMerge102
_logicalFalse101:
	li $t0, 0
	sw $t0, 660($sp)
	b _logicalMerge102
_logicalMerge102:
	lw $t0, 660($sp)
	beqz $t0, _alternative98
_consequence97:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf99
_alternative98:
	b _OutOfIf99
_OutOfIf99:
	b _OutOfIf90
_alternative89:
	b _OutOfIf90
_OutOfIf90:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 476($sp)
	lw $t0, 508($sp)
	lw $t1, 476($sp)
	add $t1, $t0, $t1
	sw $t1, 308($sp)
	lw $t1, 308($sp)
	lw $t0, 0($t1)
	sw $t0, 536($sp)
	lw $t0, 536($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 844($sp)
	lw $t0, 844($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1344($sp)
	lw $t0, 144($sp)
	lw $t1, 1344($sp)
	add $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t1, 276($sp)
	lw $t0, 0($t1)
	sw $t0, 428($sp)
	lw $t0, 428($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1440($sp)
	lw $t0, 1440($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1136($sp)
	lw $t0, 1136($sp)
	beqz $t0, _logicalFalse107
_logicalTrue106:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 944($sp)
	lw $t0, 944($sp)
	beqz $t0, _logicalFalse110
_logicalTrue109:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 744($sp)
	lw $t1, 368($sp)
	add $t1, $t0, $t1
	sw $t1, 592($sp)
	lw $t1, 592($sp)
	lw $t0, 0($t1)
	sw $t0, 1268($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 780($sp)
	lw $t0, 1268($sp)
	lw $t1, 780($sp)
	add $t1, $t0, $t1
	sw $t1, 388($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 372($sp)
	lw $t1, 388($sp)
	lw $t0, 0($t1)
	sw $t0, 1236($sp)
	lw $t0, 1236($sp)
	lw $t1, 372($sp)
	seq $t1, $t0, $t1
	sw $t1, 1164($sp)
	lw $t0, 1164($sp)
	sw $t0, 292($sp)
	b _logicalMerge111
_logicalFalse110:
	li $t0, 0
	sw $t0, 292($sp)
	b _logicalMerge111
_logicalMerge111:
	lw $t0, 292($sp)
	sw $t0, 1404($sp)
	b _logicalMerge108
_logicalFalse107:
	li $t0, 0
	sw $t0, 1404($sp)
	b _logicalMerge108
_logicalMerge108:
	lw $t0, 1404($sp)
	beqz $t0, _alternative104
_consequence103:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1324($sp)
	lw $t0, 1324($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1472($sp)
	lw $t0, 508($sp)
	lw $t1, 1472($sp)
	add $t1, $t0, $t1
	sw $t1, 676($sp)
	lw $t0, 376($sp)
	lw $t1, 676($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 612($sp)
	lw $t0, 144($sp)
	lw $t1, 612($sp)
	add $t1, $t0, $t1
	sw $t1, 1388($sp)
	lw $t0, 560($sp)
	lw $t1, 1388($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1432($sp)
	lw $t0, 744($sp)
	lw $t1, 1432($sp)
	add $t1, $t0, $t1
	sw $t1, 732($sp)
	lw $t1, 732($sp)
	lw $t0, 0($t1)
	sw $t0, 340($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 908($sp)
	lw $t0, 340($sp)
	lw $t1, 908($sp)
	add $t1, $t0, $t1
	sw $t1, 1088($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1568($sp)
	lw $t0, 1568($sp)
	lw $t1, 1088($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 1096($sp)
	lw $t0, 1096($sp)
	beqz $t0, _logicalFalse116
_logicalTrue115:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 584($sp)
	lw $t0, 584($sp)
	sw $t0, 748($sp)
	b _logicalMerge117
_logicalFalse116:
	li $t0, 0
	sw $t0, 748($sp)
	b _logicalMerge117
_logicalMerge117:
	lw $t0, 748($sp)
	beqz $t0, _alternative113
_consequence112:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf114
_alternative113:
	b _OutOfIf114
_OutOfIf114:
	b _OutOfIf105
_alternative104:
	b _OutOfIf105
_OutOfIf105:
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1308($sp)
	lw $t0, 508($sp)
	lw $t1, 1308($sp)
	add $t1, $t0, $t1
	sw $t1, 604($sp)
	lw $t1, 604($sp)
	lw $t0, 0($t1)
	sw $t0, 976($sp)
	lw $t0, 976($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 1384($sp)
	lw $t0, 1384($sp)
	sw $t0, 376($sp)
	lw $t0, 1376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1104($sp)
	lw $t0, 144($sp)
	lw $t1, 1104($sp)
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t1, 192($sp)
	lw $t0, 0($t1)
	sw $t0, 384($sp)
	lw $t0, 384($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 644($sp)
	lw $t0, 644($sp)
	sw $t0, 560($sp)
	lw $t0, 376($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1408($sp)
	lw $t0, 1408($sp)
	beqz $t0, _logicalFalse122
_logicalTrue121:
	lw $t0, 560($sp)
	sw $t0, -8($sp)
	lw $t0, 440($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 784($sp)
	lw $t0, 784($sp)
	beqz $t0, _logicalFalse125
_logicalTrue124:
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 616($sp)
	lw $t0, 744($sp)
	lw $t1, 616($sp)
	add $t1, $t0, $t1
	sw $t1, 752($sp)
	lw $t1, 752($sp)
	lw $t0, 0($t1)
	sw $t0, 528($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 900($sp)
	lw $t0, 528($sp)
	lw $t1, 900($sp)
	add $t1, $t0, $t1
	sw $t1, 1448($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1516($sp)
	lw $t1, 1448($sp)
	lw $t0, 0($t1)
	sw $t0, 1368($sp)
	lw $t0, 1368($sp)
	lw $t1, 1516($sp)
	seq $t1, $t0, $t1
	sw $t1, 856($sp)
	lw $t0, 856($sp)
	sw $t0, 1420($sp)
	b _logicalMerge126
_logicalFalse125:
	li $t0, 0
	sw $t0, 1420($sp)
	b _logicalMerge126
_logicalMerge126:
	lw $t0, 1420($sp)
	sw $t0, 1380($sp)
	b _logicalMerge123
_logicalFalse122:
	li $t0, 0
	sw $t0, 1380($sp)
	b _logicalMerge123
_logicalMerge123:
	lw $t0, 1380($sp)
	beqz $t0, _alternative119
_consequence118:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 896($sp)
	lw $t0, 896($sp)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, 508($sp)
	lw $t1, 248($sp)
	add $t1, $t0, $t1
	sw $t1, 1536($sp)
	lw $t0, 376($sp)
	lw $t1, 1536($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1292($sp)
	lw $t0, 144($sp)
	lw $t1, 1292($sp)
	add $t1, $t0, $t1
	sw $t1, 1012($sp)
	lw $t0, 560($sp)
	lw $t1, 1012($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1140($sp)
	lw $t0, 744($sp)
	lw $t1, 1140($sp)
	add $t1, $t0, $t1
	sw $t1, 1296($sp)
	lw $t1, 1296($sp)
	lw $t0, 0($t1)
	sw $t0, 1000($sp)
	lw $t0, 560($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1348($sp)
	lw $t0, 1000($sp)
	lw $t1, 1348($sp)
	add $t1, $t0, $t1
	sw $t1, 1572($sp)
	lw $t0, 1028($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1508($sp)
	lw $t0, 1508($sp)
	lw $t1, 1572($sp)
	sw $t0, 0($t1)
	lw $t0, 376($sp)
	lw $t1, 1496($sp)
	seq $t1, $t0, $t1
	sw $t1, 828($sp)
	lw $t0, 828($sp)
	beqz $t0, _logicalFalse131
_logicalTrue130:
	lw $t0, 560($sp)
	lw $t1, 692($sp)
	seq $t1, $t0, $t1
	sw $t1, 548($sp)
	lw $t0, 548($sp)
	sw $t0, 1108($sp)
	b _logicalMerge132
_logicalFalse131:
	li $t0, 0
	sw $t0, 1108($sp)
	b _logicalMerge132
_logicalMerge132:
	lw $t0, 1108($sp)
	beqz $t0, _alternative128
_consequence127:
	li $t0, 1
	sw $t0, 1168($sp)
	b _OutOfIf129
_alternative128:
	b _OutOfIf129
_OutOfIf129:
	b _OutOfIf120
_alternative119:
	b _OutOfIf120
_OutOfIf120:
	lw $t0, 1168($sp)
	li $t1, 1
	seq $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _alternative134
_consequence133:
	b _OutOfWhile12
	b _OutOfIf135
_alternative134:
	b _OutOfIf135
_OutOfIf135:
	lw $t0, 1376($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1024($sp)
	lw $t0, 1024($sp)
	sw $t0, 1376($sp)
	b _WhileLoop84
_OutOfWhile12:
	lw $t0, 1168($sp)
	li $t1, 1
	seq $t1, $t0, $t1
	sw $t1, 932($sp)
	lw $t0, 932($sp)
	beqz $t0, _alternative137
_consequence136:
	lw $t0, 1496($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1112($sp)
	lw $t0, 744($sp)
	lw $t1, 1112($sp)
	add $t1, $t0, $t1
	sw $t1, 452($sp)
	lw $t1, 452($sp)
	lw $t0, 0($t1)
	sw $t0, 400($sp)
	lw $t0, 692($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 852($sp)
	lw $t0, 400($sp)
	lw $t1, 852($sp)
	add $t1, $t0, $t1
	sw $t1, 1436($sp)
	lw $t1, 1436($sp)
	lw $t0, 0($t1)
	sw $t0, 1480($sp)
	lw $a0, 1480($sp)
	jal func__toString
	sw $v0, 1152($sp)
	lw $a0, 1152($sp)
	jal func__println
	sw $v0, 984($sp)
	b _OutOfIf138
_alternative137:
	la $a0, string_430
	jal func__print
	sw $v0, 992($sp)
	b _OutOfIf138
_OutOfIf138:
	li $v0, 0
	b _EndOfFunctionDecl75
_EndOfFunctionDecl75:
	lw $ra, 120($sp)
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
