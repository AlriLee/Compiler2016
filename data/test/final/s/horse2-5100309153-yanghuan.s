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
	sw $ra, 120($sp)
_BeginOfFunctionDecl890:
	lw $t0, 140($sp)
	lw $t1, 144($sp)
	slt $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	beqz $t0, _logicalFalse904
	b _logicalTrue903
_logicalTrue903:
	lw $t0, 140($sp)
	li $t1, 0
	sge $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	sw $t0, 136($sp)
	b _logicalMerge905
_logicalFalse904:
	li $t0, 0
	sw $t0, 136($sp)
	b _logicalMerge905
_logicalMerge905:
	lw $v0, 136($sp)
	b _EndOfFunctionDecl891
_EndOfFunctionDecl891:
	lw $ra, 120($sp)
	add $sp, $sp, 148
	jr $ra
main:
	sub $sp, $sp, 1580
	sw $ra, 120($sp)
_BeginOfFunctionDecl892:
	jal func__getInt
	sw $v0, 928($sp)
	lw $t0, 928($sp)
	sw $t0, 1424($sp)
	li $t0, 0
	sw $t0, 1072($sp)
	lw $t0, 1072($sp)
	sw $t0, 708($sp)
	lw $t0, 708($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	sw $t0, 1464($sp)
	lw $t0, 1424($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1428($sp)
	lw $t0, 1428($sp)
	sw $t0, 1064($sp)
	lw $t0, 1064($sp)
	sw $t0, 604($sp)
	li $t0, 0
	sw $t0, 1060($sp)
	lw $t0, 1060($sp)
	sw $t0, 1388($sp)
	li $t0, 0
	sw $t0, 520($sp)
	lw $t0, 520($sp)
	sw $t0, 340($sp)
	lw $t0, 1424($sp)
	lw $t1, 1424($sp)
	mul $t1, $t0, $t1
	sw $t1, 1316($sp)
	lw $t0, 1316($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1296($sp)
	lw $t0, 1296($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1296($sp)
	lw $a0, 1296($sp)
	li $v0, 9
	syscall
	sw $v0, 368($sp)
	lw $t0, 1316($sp)
	lw $t1, 368($sp)
	sw $t0, 0($t1)
	lw $t0, 368($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 368($sp)
	sw $t0, 896($sp)
	lw $t0, 896($sp)
	sw $t0, 544($sp)
	li $t0, 0
	sw $t0, 332($sp)
_ForLoop894:
	lw $t0, 1424($sp)
	lw $t1, 1424($sp)
	mul $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 332($sp)
	lw $t1, 428($sp)
	slt $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t0, 228($sp)
	beqz $t0, _OutOfFor907
	b _ForBody906
_ForBody906:
	lw $t0, 332($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1328($sp)
	lw $t0, 544($sp)
	lw $t1, 1328($sp)
	add $t1, $t0, $t1
	sw $t1, 308($sp)
	li $t0, 0
	lw $t1, 308($sp)
	sw $t0, 0($t1)
_continueFor895:
	lw $t0, 332($sp)
	sw $t0, 728($sp)
	lw $t0, 332($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	b _ForLoop894
_OutOfFor907:
	lw $t0, 1424($sp)
	lw $t1, 1424($sp)
	mul $t1, $t0, $t1
	sw $t1, 772($sp)
	lw $t0, 772($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1488($sp)
	lw $t0, 1488($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1488($sp)
	lw $a0, 1488($sp)
	li $v0, 9
	syscall
	sw $v0, 460($sp)
	lw $t0, 772($sp)
	lw $t1, 460($sp)
	sw $t0, 0($t1)
	lw $t0, 460($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 460($sp)
	lw $t0, 460($sp)
	sw $t0, 784($sp)
	lw $t0, 784($sp)
	sw $t0, 940($sp)
	li $t0, 0
	sw $t0, 332($sp)
_ForLoop896:
	lw $t0, 1424($sp)
	lw $t1, 1424($sp)
	mul $t1, $t0, $t1
	sw $t1, 1500($sp)
	lw $t0, 332($sp)
	lw $t1, 1500($sp)
	slt $t1, $t0, $t1
	sw $t1, 912($sp)
	lw $t0, 912($sp)
	beqz $t0, _OutOfFor909
	b _ForBody908
_ForBody908:
	lw $t0, 332($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 480($sp)
	lw $t0, 940($sp)
	lw $t1, 480($sp)
	add $t1, $t0, $t1
	sw $t1, 484($sp)
	li $t0, 0
	lw $t1, 484($sp)
	sw $t0, 0($t1)
_continueFor897:
	lw $t0, 332($sp)
	sw $t0, 1392($sp)
	lw $t0, 332($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	b _ForLoop896
_OutOfFor909:
	lw $t0, 1424($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 596($sp)
	lw $t0, 596($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 596($sp)
	lw $a0, 596($sp)
	li $v0, 9
	syscall
	sw $v0, 1168($sp)
	lw $t0, 1424($sp)
	lw $t1, 1168($sp)
	sw $t0, 0($t1)
	lw $t0, 1168($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1168($sp)
	lw $t0, 1168($sp)
	sw $t0, 1156($sp)
	lw $t0, 1156($sp)
	sw $t0, 1044($sp)
	li $t0, 0
	sw $t0, 332($sp)
_ForLoop898:
	lw $t0, 332($sp)
	lw $t1, 1424($sp)
	slt $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	beqz $t0, _OutOfFor911
	b _ForBody910
_ForBody910:
	lw $t0, 332($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t0, 1044($sp)
	lw $t1, 388($sp)
	add $t1, $t0, $t1
	sw $t1, 560($sp)
	lw $t0, 1424($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $t0, 1200($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $a0, 1200($sp)
	li $v0, 9
	syscall
	sw $v0, 720($sp)
	lw $t0, 1424($sp)
	lw $t1, 720($sp)
	sw $t0, 0($t1)
	lw $t0, 720($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 720($sp)
	lw $t0, 720($sp)
	sw $t0, 348($sp)
	lw $t0, 348($sp)
	lw $t1, 560($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, 808($sp)
_ForLoop900:
	lw $t0, 808($sp)
	lw $t1, 1424($sp)
	slt $t1, $t0, $t1
	sw $t1, 860($sp)
	lw $t0, 860($sp)
	beqz $t0, _OutOfFor913
	b _ForBody912
_ForBody912:
	lw $t0, 332($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 488($sp)
	lw $t0, 1044($sp)
	lw $t1, 488($sp)
	add $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t1, 260($sp)
	lw $t0, 0($t1)
	sw $t0, 624($sp)
	lw $t0, 808($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, 624($sp)
	lw $t1, 432($sp)
	add $t1, $t0, $t1
	sw $t1, 1576($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 276($sp)
	lw $t0, 276($sp)
	lw $t1, 1576($sp)
	sw $t0, 0($t1)
_continueFor901:
	lw $t0, 808($sp)
	sw $t0, 1520($sp)
	lw $t0, 808($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 808($sp)
	b _ForLoop900
_OutOfFor913:
	b _continueFor899
_continueFor899:
	lw $t0, 332($sp)
	sw $t0, 644($sp)
	lw $t0, 332($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	b _ForLoop898
_OutOfFor911:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1088($sp)
	lw $t0, 544($sp)
	lw $t1, 1088($sp)
	add $t1, $t0, $t1
	sw $t1, 712($sp)
	lw $t0, 708($sp)
	lw $t1, 712($sp)
	sw $t0, 0($t1)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 676($sp)
	lw $t0, 940($sp)
	lw $t1, 676($sp)
	add $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t0, 1072($sp)
	lw $t1, 448($sp)
	sw $t0, 0($t1)
	lw $t0, 708($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 692($sp)
	lw $t0, 1044($sp)
	lw $t1, 692($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t1, 208($sp)
	lw $t0, 0($t1)
	sw $t0, 1568($sp)
	lw $t0, 1072($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1248($sp)
	lw $t0, 1568($sp)
	lw $t1, 1248($sp)
	add $t1, $t0, $t1
	sw $t1, 1292($sp)
	lw $t1, 1292($sp)
	lw $t0, 0($t1)
	sw $t0, 1004($sp)
	lw $t0, 1004($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 1472($sp)
_WhileLoop902:
	lw $t0, 1464($sp)
	lw $t1, 1352($sp)
	sle $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	beqz $t0, _OutOfWhile915
	b _WhileBody914
_WhileBody914:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 544($sp)
	lw $t1, 380($sp)
	add $t1, $t0, $t1
	sw $t1, 588($sp)
	lw $t1, 588($sp)
	lw $t0, 0($t1)
	sw $t0, 1188($sp)
	lw $t0, 1188($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 864($sp)
	lw $t0, 1044($sp)
	lw $t1, 864($sp)
	add $t1, $t0, $t1
	sw $t1, 668($sp)
	lw $t1, 668($sp)
	lw $t0, 0($t1)
	sw $t0, 404($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 996($sp)
	lw $t0, 940($sp)
	lw $t1, 996($sp)
	add $t1, $t0, $t1
	sw $t1, 540($sp)
	lw $t1, 540($sp)
	lw $t0, 0($t1)
	sw $t0, 1032($sp)
	lw $t0, 1032($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 284($sp)
	lw $t0, 404($sp)
	lw $t1, 284($sp)
	add $t1, $t0, $t1
	sw $t1, 1028($sp)
	lw $t1, 1028($sp)
	lw $t0, 0($t1)
	sw $t0, 584($sp)
	lw $t0, 584($sp)
	sw $t0, 340($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1524($sp)
	lw $t0, 544($sp)
	lw $t1, 1524($sp)
	add $t1, $t0, $t1
	sw $t1, 468($sp)
	lw $t1, 468($sp)
	lw $t0, 0($t1)
	sw $t0, 1148($sp)
	lw $t0, 1148($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1340($sp)
	lw $t0, 1340($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, 940($sp)
	lw $t1, 312($sp)
	add $t1, $t0, $t1
	sw $t1, 776($sp)
	lw $t1, 776($sp)
	lw $t0, 0($t1)
	sw $t0, 1016($sp)
	lw $t0, 1016($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 1416($sp)
	lw $t0, 1416($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 756($sp)
	lw $t0, 756($sp)
	beqz $t0, _logicalFalse920
	b _logicalTrue919
_logicalTrue919:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1116($sp)
	lw $t0, 1116($sp)
	sw $t0, 1452($sp)
	b _logicalMerge921
_logicalFalse920:
	li $t0, 0
	sw $t0, 1452($sp)
	b _logicalMerge921
_logicalMerge921:
	lw $t0, 1452($sp)
	beqz $t0, _logicalFalse923
	b _logicalTrue922
_logicalTrue922:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1132($sp)
	lw $t0, 1044($sp)
	lw $t1, 1132($sp)
	add $t1, $t0, $t1
	sw $t1, 716($sp)
	lw $t1, 716($sp)
	lw $t0, 0($t1)
	sw $t0, 316($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, 316($sp)
	lw $t1, 248($sp)
	add $t1, $t0, $t1
	sw $t1, 1376($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 984($sp)
	lw $t1, 1376($sp)
	lw $t0, 0($t1)
	sw $t0, 344($sp)
	lw $t0, 344($sp)
	lw $t1, 984($sp)
	seq $t1, $t0, $t1
	sw $t1, 1260($sp)
	lw $t0, 1260($sp)
	sw $t0, 360($sp)
	b _logicalMerge924
_logicalFalse923:
	li $t0, 0
	sw $t0, 360($sp)
	b _logicalMerge924
_logicalMerge924:
	lw $t0, 360($sp)
	beqz $t0, _alternative917
	b _consequence916
_consequence916:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 764($sp)
	lw $t0, 764($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1204($sp)
	lw $t0, 544($sp)
	lw $t1, 1204($sp)
	add $t1, $t0, $t1
	sw $t1, 1272($sp)
	lw $t0, 1388($sp)
	lw $t1, 1272($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 732($sp)
	lw $t0, 940($sp)
	lw $t1, 732($sp)
	add $t1, $t0, $t1
	sw $t1, 1160($sp)
	lw $t0, 1060($sp)
	lw $t1, 1160($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1536($sp)
	lw $t0, 1044($sp)
	lw $t1, 1536($sp)
	add $t1, $t0, $t1
	sw $t1, 600($sp)
	lw $t1, 600($sp)
	lw $t0, 0($t1)
	sw $t0, 932($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1436($sp)
	lw $t0, 932($sp)
	lw $t1, 1436($sp)
	add $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 352($sp)
	lw $t0, 352($sp)
	lw $t1, 300($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 1264($sp)
	lw $t0, 1264($sp)
	beqz $t0, _logicalFalse929
	b _logicalTrue928
_logicalTrue928:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, 444($sp)
	sw $t0, 1492($sp)
	b _logicalMerge930
_logicalFalse929:
	li $t0, 0
	sw $t0, 1492($sp)
	b _logicalMerge930
_logicalMerge930:
	lw $t0, 1492($sp)
	beqz $t0, _alternative926
	b _consequence925
_consequence925:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf927
_alternative926:
	b _OutOfIf927
_OutOfIf927:
	b _OutOfIf918
_alternative917:
	b _OutOfIf918
_OutOfIf918:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 788($sp)
	lw $t0, 544($sp)
	lw $t1, 788($sp)
	add $t1, $t0, $t1
	sw $t1, 652($sp)
	lw $t1, 652($sp)
	lw $t0, 0($t1)
	sw $t0, 1532($sp)
	lw $t0, 1532($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1432($sp)
	lw $t0, 1432($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, 940($sp)
	lw $t1, 236($sp)
	add $t1, $t0, $t1
	sw $t1, 660($sp)
	lw $t1, 660($sp)
	lw $t0, 0($t1)
	sw $t0, 1572($sp)
	lw $t0, 1572($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 944($sp)
	lw $t0, 944($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 684($sp)
	lw $t0, 684($sp)
	beqz $t0, _logicalFalse935
	b _logicalTrue934
_logicalTrue934:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1364($sp)
	lw $t0, 1364($sp)
	sw $t0, 876($sp)
	b _logicalMerge936
_logicalFalse935:
	li $t0, 0
	sw $t0, 876($sp)
	b _logicalMerge936
_logicalMerge936:
	lw $t0, 876($sp)
	beqz $t0, _logicalFalse938
	b _logicalTrue937
_logicalTrue937:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 1044($sp)
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 696($sp)
	lw $t1, 696($sp)
	lw $t0, 0($t1)
	sw $t0, 964($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, 964($sp)
	lw $t1, 384($sp)
	add $t1, $t0, $t1
	sw $t1, 736($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1224($sp)
	lw $t1, 736($sp)
	lw $t0, 0($t1)
	sw $t0, 1052($sp)
	lw $t0, 1052($sp)
	lw $t1, 1224($sp)
	seq $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	sw $t0, 132($sp)
	b _logicalMerge939
_logicalFalse938:
	li $t0, 0
	sw $t0, 132($sp)
	b _logicalMerge939
_logicalMerge939:
	lw $t0, 132($sp)
	beqz $t0, _alternative932
	b _consequence931
_consequence931:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1356($sp)
	lw $t0, 1356($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1344($sp)
	lw $t0, 544($sp)
	lw $t1, 1344($sp)
	add $t1, $t0, $t1
	sw $t1, 1548($sp)
	lw $t0, 1388($sp)
	lw $t1, 1548($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1008($sp)
	lw $t0, 940($sp)
	lw $t1, 1008($sp)
	add $t1, $t0, $t1
	sw $t1, 1384($sp)
	lw $t0, 1060($sp)
	lw $t1, 1384($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 768($sp)
	lw $t0, 1044($sp)
	lw $t1, 768($sp)
	add $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t1, 324($sp)
	lw $t0, 0($t1)
	sw $t0, 1240($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1084($sp)
	lw $t0, 1240($sp)
	lw $t1, 1084($sp)
	add $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1220($sp)
	lw $t0, 1220($sp)
	lw $t1, 364($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 1112($sp)
	lw $t0, 1112($sp)
	beqz $t0, _logicalFalse944
	b _logicalTrue943
_logicalTrue943:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 568($sp)
	lw $t0, 568($sp)
	sw $t0, 396($sp)
	b _logicalMerge945
_logicalFalse944:
	li $t0, 0
	sw $t0, 396($sp)
	b _logicalMerge945
_logicalMerge945:
	lw $t0, 396($sp)
	beqz $t0, _alternative941
	b _consequence940
_consequence940:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf942
_alternative941:
	b _OutOfIf942
_OutOfIf942:
	b _OutOfIf933
_alternative932:
	b _OutOfIf933
_OutOfIf933:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t0, 544($sp)
	lw $t1, 336($sp)
	add $t1, $t0, $t1
	sw $t1, 972($sp)
	lw $t1, 972($sp)
	lw $t0, 0($t1)
	sw $t0, 252($sp)
	lw $t0, 252($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 636($sp)
	lw $t0, 636($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1284($sp)
	lw $t0, 940($sp)
	lw $t1, 1284($sp)
	add $t1, $t0, $t1
	sw $t1, 1480($sp)
	lw $t1, 1480($sp)
	lw $t0, 0($t1)
	sw $t0, 304($sp)
	lw $t0, 304($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 616($sp)
	lw $t0, 616($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 976($sp)
	lw $t0, 976($sp)
	beqz $t0, _logicalFalse950
	b _logicalTrue949
_logicalTrue949:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1232($sp)
	lw $t0, 1232($sp)
	sw $t0, 440($sp)
	b _logicalMerge951
_logicalFalse950:
	li $t0, 0
	sw $t0, 440($sp)
	b _logicalMerge951
_logicalMerge951:
	lw $t0, 440($sp)
	beqz $t0, _logicalFalse953
	b _logicalTrue952
_logicalTrue952:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 892($sp)
	lw $t0, 1044($sp)
	lw $t1, 892($sp)
	add $t1, $t0, $t1
	sw $t1, 1540($sp)
	lw $t1, 1540($sp)
	lw $t0, 0($t1)
	sw $t0, 1020($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1172($sp)
	lw $t0, 1020($sp)
	lw $t1, 1172($sp)
	add $t1, $t0, $t1
	sw $t1, 1332($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1256($sp)
	lw $t1, 1332($sp)
	lw $t0, 0($t1)
	sw $t0, 472($sp)
	lw $t0, 472($sp)
	lw $t1, 1256($sp)
	seq $t1, $t0, $t1
	sw $t1, 500($sp)
	lw $t0, 500($sp)
	sw $t0, 1208($sp)
	b _logicalMerge954
_logicalFalse953:
	li $t0, 0
	sw $t0, 1208($sp)
	b _logicalMerge954
_logicalMerge954:
	lw $t0, 1208($sp)
	beqz $t0, _alternative947
	b _consequence946
_consequence946:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 880($sp)
	lw $t0, 880($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 828($sp)
	lw $t0, 544($sp)
	lw $t1, 828($sp)
	add $t1, $t0, $t1
	sw $t1, 1136($sp)
	lw $t0, 1388($sp)
	lw $t1, 1136($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 292($sp)
	lw $t0, 940($sp)
	lw $t1, 292($sp)
	add $t1, $t0, $t1
	sw $t1, 740($sp)
	lw $t0, 1060($sp)
	lw $t1, 740($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1212($sp)
	lw $t0, 1044($sp)
	lw $t1, 1212($sp)
	add $t1, $t0, $t1
	sw $t1, 496($sp)
	lw $t1, 496($sp)
	lw $t0, 0($t1)
	sw $t0, 1096($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1100($sp)
	lw $t0, 1096($sp)
	lw $t1, 1100($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1504($sp)
	lw $t0, 1504($sp)
	lw $t1, 224($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 1176($sp)
	lw $t0, 1176($sp)
	beqz $t0, _logicalFalse959
	b _logicalTrue958
_logicalTrue958:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 1076($sp)
	lw $t0, 1076($sp)
	sw $t0, 156($sp)
	b _logicalMerge960
_logicalFalse959:
	li $t0, 0
	sw $t0, 156($sp)
	b _logicalMerge960
_logicalMerge960:
	lw $t0, 156($sp)
	beqz $t0, _alternative956
	b _consequence955
_consequence955:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf957
_alternative956:
	b _OutOfIf957
_OutOfIf957:
	b _OutOfIf948
_alternative947:
	b _OutOfIf948
_OutOfIf948:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1476($sp)
	lw $t0, 544($sp)
	lw $t1, 1476($sp)
	add $t1, $t0, $t1
	sw $t1, 1412($sp)
	lw $t1, 1412($sp)
	lw $t0, 0($t1)
	sw $t0, 820($sp)
	lw $t0, 820($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1228($sp)
	lw $t0, 1228($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 924($sp)
	lw $t0, 940($sp)
	lw $t1, 924($sp)
	add $t1, $t0, $t1
	sw $t1, 548($sp)
	lw $t1, 548($sp)
	lw $t0, 0($t1)
	sw $t0, 884($sp)
	lw $t0, 884($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 852($sp)
	lw $t0, 852($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 824($sp)
	lw $t0, 824($sp)
	beqz $t0, _logicalFalse965
	b _logicalTrue964
_logicalTrue964:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 512($sp)
	lw $t0, 512($sp)
	sw $t0, 1080($sp)
	b _logicalMerge966
_logicalFalse965:
	li $t0, 0
	sw $t0, 1080($sp)
	b _logicalMerge966
_logicalMerge966:
	lw $t0, 1080($sp)
	beqz $t0, _logicalFalse968
	b _logicalTrue967
_logicalTrue967:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 1044($sp)
	lw $t1, 160($sp)
	add $t1, $t0, $t1
	sw $t1, 1556($sp)
	lw $t1, 1556($sp)
	lw $t0, 0($t1)
	sw $t0, 700($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 700($sp)
	lw $t1, 192($sp)
	add $t1, $t0, $t1
	sw $t1, 1396($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1140($sp)
	lw $t1, 1396($sp)
	lw $t0, 0($t1)
	sw $t0, 136($sp)
	lw $t0, 136($sp)
	lw $t1, 1140($sp)
	seq $t1, $t0, $t1
	sw $t1, 1164($sp)
	lw $t0, 1164($sp)
	sw $t0, 832($sp)
	b _logicalMerge969
_logicalFalse968:
	li $t0, 0
	sw $t0, 832($sp)
	b _logicalMerge969
_logicalMerge969:
	lw $t0, 832($sp)
	beqz $t0, _alternative962
	b _consequence961
_consequence961:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1184($sp)
	lw $t0, 1184($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1192($sp)
	lw $t0, 544($sp)
	lw $t1, 1192($sp)
	add $t1, $t0, $t1
	sw $t1, 1012($sp)
	lw $t0, 1388($sp)
	lw $t1, 1012($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 504($sp)
	lw $t0, 940($sp)
	lw $t1, 504($sp)
	add $t1, $t0, $t1
	sw $t1, 888($sp)
	lw $t0, 1060($sp)
	lw $t1, 888($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1216($sp)
	lw $t0, 1044($sp)
	lw $t1, 1216($sp)
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t1, 172($sp)
	lw $t0, 0($t1)
	sw $t0, 948($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 836($sp)
	lw $t0, 948($sp)
	lw $t1, 836($sp)
	add $t1, $t0, $t1
	sw $t1, 1508($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 592($sp)
	lw $t0, 592($sp)
	lw $t1, 1508($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 812($sp)
	lw $t0, 812($sp)
	beqz $t0, _logicalFalse974
	b _logicalTrue973
_logicalTrue973:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, 220($sp)
	sw $t0, 272($sp)
	b _logicalMerge975
_logicalFalse974:
	li $t0, 0
	sw $t0, 272($sp)
	b _logicalMerge975
_logicalMerge975:
	lw $t0, 272($sp)
	beqz $t0, _alternative971
	b _consequence970
_consequence970:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf972
_alternative971:
	b _OutOfIf972
_OutOfIf972:
	b _OutOfIf963
_alternative962:
	b _OutOfIf963
_OutOfIf963:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 936($sp)
	lw $t0, 544($sp)
	lw $t1, 936($sp)
	add $t1, $t0, $t1
	sw $t1, 856($sp)
	lw $t1, 856($sp)
	lw $t0, 0($t1)
	sw $t0, 1484($sp)
	lw $t0, 1484($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 400($sp)
	lw $t0, 400($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 672($sp)
	lw $t0, 940($sp)
	lw $t1, 672($sp)
	add $t1, $t0, $t1
	sw $t1, 528($sp)
	lw $t1, 528($sp)
	lw $t0, 0($t1)
	sw $t0, 516($sp)
	lw $t0, 516($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 436($sp)
	lw $t0, 436($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1348($sp)
	lw $t0, 1348($sp)
	beqz $t0, _logicalFalse980
	b _logicalTrue979
_logicalTrue979:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 704($sp)
	lw $t0, 704($sp)
	sw $t0, 372($sp)
	b _logicalMerge981
_logicalFalse980:
	li $t0, 0
	sw $t0, 372($sp)
	b _logicalMerge981
_logicalMerge981:
	lw $t0, 372($sp)
	beqz $t0, _logicalFalse983
	b _logicalTrue982
_logicalTrue982:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1104($sp)
	lw $t0, 1044($sp)
	lw $t1, 1104($sp)
	add $t1, $t0, $t1
	sw $t1, 656($sp)
	lw $t1, 656($sp)
	lw $t0, 0($t1)
	sw $t0, 1456($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 416($sp)
	lw $t0, 1456($sp)
	lw $t1, 416($sp)
	add $t1, $t0, $t1
	sw $t1, 328($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 608($sp)
	lw $t1, 328($sp)
	lw $t0, 0($t1)
	sw $t0, 476($sp)
	lw $t0, 476($sp)
	lw $t1, 608($sp)
	seq $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, 296($sp)
	sw $t0, 800($sp)
	b _logicalMerge984
_logicalFalse983:
	li $t0, 0
	sw $t0, 800($sp)
	b _logicalMerge984
_logicalMerge984:
	lw $t0, 800($sp)
	beqz $t0, _alternative977
	b _consequence976
_consequence976:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 552($sp)
	lw $t0, 552($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1276($sp)
	lw $t0, 544($sp)
	lw $t1, 1276($sp)
	add $t1, $t0, $t1
	sw $t1, 1108($sp)
	lw $t0, 1388($sp)
	lw $t1, 1108($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 724($sp)
	lw $t0, 940($sp)
	lw $t1, 724($sp)
	add $t1, $t0, $t1
	sw $t1, 1512($sp)
	lw $t0, 1060($sp)
	lw $t1, 1512($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 1044($sp)
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 1036($sp)
	lw $t1, 1036($sp)
	lw $t0, 0($t1)
	sw $t0, 1440($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1460($sp)
	lw $t0, 1440($sp)
	lw $t1, 1460($sp)
	add $t1, $t0, $t1
	sw $t1, 1368($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1048($sp)
	lw $t0, 1048($sp)
	lw $t1, 1368($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	beqz $t0, _logicalFalse989
	b _logicalTrue988
_logicalTrue988:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 1092($sp)
	lw $t0, 1092($sp)
	sw $t0, 1324($sp)
	b _logicalMerge990
_logicalFalse989:
	li $t0, 0
	sw $t0, 1324($sp)
	b _logicalMerge990
_logicalMerge990:
	lw $t0, 1324($sp)
	beqz $t0, _alternative986
	b _consequence985
_consequence985:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf987
_alternative986:
	b _OutOfIf987
_OutOfIf987:
	b _OutOfIf978
_alternative977:
	b _OutOfIf978
_OutOfIf978:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 612($sp)
	lw $t0, 544($sp)
	lw $t1, 612($sp)
	add $t1, $t0, $t1
	sw $t1, 1040($sp)
	lw $t1, 1040($sp)
	lw $t0, 0($t1)
	sw $t0, 648($sp)
	lw $t0, 648($sp)
	li $t1, 2
	sub $t1, $t0, $t1
	sw $t1, 1560($sp)
	lw $t0, 1560($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t0, 940($sp)
	lw $t1, 320($sp)
	add $t1, $t0, $t1
	sw $t1, 816($sp)
	lw $t1, 816($sp)
	lw $t0, 0($t1)
	sw $t0, 452($sp)
	lw $t0, 452($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 992($sp)
	lw $t0, 992($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 900($sp)
	lw $t0, 900($sp)
	beqz $t0, _logicalFalse995
	b _logicalTrue994
_logicalTrue994:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 840($sp)
	lw $t0, 840($sp)
	sw $t0, 376($sp)
	b _logicalMerge996
_logicalFalse995:
	li $t0, 0
	sw $t0, 376($sp)
	b _logicalMerge996
_logicalMerge996:
	lw $t0, 376($sp)
	beqz $t0, _logicalFalse998
	b _logicalTrue997
_logicalTrue997:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1236($sp)
	lw $t0, 1044($sp)
	lw $t1, 1236($sp)
	add $t1, $t0, $t1
	sw $t1, 1128($sp)
	lw $t1, 1128($sp)
	lw $t0, 0($t1)
	sw $t0, 464($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1244($sp)
	lw $t0, 464($sp)
	lw $t1, 1244($sp)
	add $t1, $t0, $t1
	sw $t1, 1448($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 760($sp)
	lw $t1, 1448($sp)
	lw $t0, 0($t1)
	sw $t0, 628($sp)
	lw $t0, 628($sp)
	lw $t1, 760($sp)
	seq $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	sw $t0, 1408($sp)
	b _logicalMerge999
_logicalFalse998:
	li $t0, 0
	sw $t0, 1408($sp)
	b _logicalMerge999
_logicalMerge999:
	lw $t0, 1408($sp)
	beqz $t0, _alternative992
	b _consequence991
_consequence991:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 580($sp)
	lw $t0, 580($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1196($sp)
	lw $t0, 544($sp)
	lw $t1, 1196($sp)
	add $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 1388($sp)
	lw $t1, 232($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1056($sp)
	lw $t0, 940($sp)
	lw $t1, 1056($sp)
	add $t1, $t0, $t1
	sw $t1, 1420($sp)
	lw $t0, 1060($sp)
	lw $t1, 1420($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t0, 1044($sp)
	lw $t1, 424($sp)
	add $t1, $t0, $t1
	sw $t1, 916($sp)
	lw $t1, 916($sp)
	lw $t0, 0($t1)
	sw $t0, 956($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1024($sp)
	lw $t0, 956($sp)
	lw $t1, 1024($sp)
	add $t1, $t0, $t1
	sw $t1, 456($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 744($sp)
	lw $t0, 744($sp)
	lw $t1, 456($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 968($sp)
	lw $t0, 968($sp)
	beqz $t0, _logicalFalse1004
	b _logicalTrue1003
_logicalTrue1003:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 1468($sp)
	lw $t0, 1468($sp)
	sw $t0, 844($sp)
	b _logicalMerge1005
_logicalFalse1004:
	li $t0, 0
	sw $t0, 844($sp)
	b _logicalMerge1005
_logicalMerge1005:
	lw $t0, 844($sp)
	beqz $t0, _alternative1001
	b _consequence1000
_consequence1000:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf1002
_alternative1001:
	b _OutOfIf1002
_OutOfIf1002:
	b _OutOfIf993
_alternative992:
	b _OutOfIf993
_OutOfIf993:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 492($sp)
	lw $t0, 544($sp)
	lw $t1, 492($sp)
	add $t1, $t0, $t1
	sw $t1, 1068($sp)
	lw $t1, 1068($sp)
	lw $t0, 0($t1)
	sw $t0, 1372($sp)
	lw $t0, 1372($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 212($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 920($sp)
	lw $t0, 940($sp)
	lw $t1, 920($sp)
	add $t1, $t0, $t1
	sw $t1, 556($sp)
	lw $t1, 556($sp)
	lw $t0, 0($t1)
	sw $t0, 268($sp)
	lw $t0, 268($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 1564($sp)
	lw $t0, 1564($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 908($sp)
	lw $t0, 908($sp)
	beqz $t0, _logicalFalse1010
	b _logicalTrue1009
_logicalTrue1009:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 180($sp)
	lw $t0, 180($sp)
	sw $t0, 1308($sp)
	b _logicalMerge1011
_logicalFalse1010:
	li $t0, 0
	sw $t0, 1308($sp)
	b _logicalMerge1011
_logicalMerge1011:
	lw $t0, 1308($sp)
	beqz $t0, _logicalFalse1013
	b _logicalTrue1012
_logicalTrue1012:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 408($sp)
	lw $t0, 1044($sp)
	lw $t1, 408($sp)
	add $t1, $t0, $t1
	sw $t1, 980($sp)
	lw $t1, 980($sp)
	lw $t0, 0($t1)
	sw $t0, 804($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 804($sp)
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 532($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 1336($sp)
	lw $t1, 532($sp)
	lw $t0, 0($t1)
	sw $t0, 1288($sp)
	lw $t0, 1288($sp)
	lw $t1, 1336($sp)
	seq $t1, $t0, $t1
	sw $t1, 792($sp)
	lw $t0, 792($sp)
	sw $t0, 748($sp)
	b _logicalMerge1014
_logicalFalse1013:
	li $t0, 0
	sw $t0, 748($sp)
	b _logicalMerge1014
_logicalMerge1014:
	lw $t0, 748($sp)
	beqz $t0, _alternative1007
	b _consequence1006
_consequence1006:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1268($sp)
	lw $t0, 1268($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1300($sp)
	lw $t0, 544($sp)
	lw $t1, 1300($sp)
	add $t1, $t0, $t1
	sw $t1, 1516($sp)
	lw $t0, 1388($sp)
	lw $t1, 1516($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1552($sp)
	lw $t0, 940($sp)
	lw $t1, 1552($sp)
	add $t1, $t0, $t1
	sw $t1, 1312($sp)
	lw $t0, 1060($sp)
	lw $t1, 1312($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 960($sp)
	lw $t0, 1044($sp)
	lw $t1, 960($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t1, 188($sp)
	lw $t0, 0($t1)
	sw $t0, 356($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1120($sp)
	lw $t0, 356($sp)
	lw $t1, 1120($sp)
	add $t1, $t0, $t1
	sw $t1, 1180($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1320($sp)
	lw $t0, 1320($sp)
	lw $t1, 1180($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t0, 280($sp)
	beqz $t0, _logicalFalse1019
	b _logicalTrue1018
_logicalTrue1018:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 572($sp)
	lw $t0, 572($sp)
	sw $t0, 988($sp)
	b _logicalMerge1020
_logicalFalse1019:
	li $t0, 0
	sw $t0, 988($sp)
	b _logicalMerge1020
_logicalMerge1020:
	lw $t0, 988($sp)
	beqz $t0, _alternative1016
	b _consequence1015
_consequence1015:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf1017
_alternative1016:
	b _OutOfIf1017
_OutOfIf1017:
	b _OutOfIf1008
_alternative1007:
	b _OutOfIf1008
_OutOfIf1008:
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, 544($sp)
	lw $t1, 216($sp)
	add $t1, $t0, $t1
	sw $t1, 1444($sp)
	lw $t1, 1444($sp)
	lw $t0, 0($t1)
	sw $t0, 264($sp)
	lw $t0, 264($sp)
	li $t1, 2
	add $t1, $t0, $t1
	sw $t1, 1152($sp)
	lw $t0, 1152($sp)
	sw $t0, 1388($sp)
	lw $t0, 1464($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 420($sp)
	lw $t0, 940($sp)
	lw $t1, 420($sp)
	add $t1, $t0, $t1
	sw $t1, 1496($sp)
	lw $t1, 1496($sp)
	lw $t0, 0($t1)
	sw $t0, 688($sp)
	lw $t0, 688($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 868($sp)
	lw $t0, 868($sp)
	sw $t0, 1060($sp)
	lw $t0, 1388($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 1400($sp)
	lw $t0, 1400($sp)
	beqz $t0, _logicalFalse1025
	b _logicalTrue1024
_logicalTrue1024:
	lw $t0, 1060($sp)
	sw $t0, -8($sp)
	lw $t0, 1424($sp)
	sw $t0, -4($sp)
	jal _check
	sw $v0, 904($sp)
	lw $t0, 904($sp)
	sw $t0, 1404($sp)
	b _logicalMerge1026
_logicalFalse1025:
	li $t0, 0
	sw $t0, 1404($sp)
	b _logicalMerge1026
_logicalMerge1026:
	lw $t0, 1404($sp)
	beqz $t0, _logicalFalse1028
	b _logicalTrue1027
_logicalTrue1027:
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 524($sp)
	lw $t0, 1044($sp)
	lw $t1, 524($sp)
	add $t1, $t0, $t1
	sw $t1, 1304($sp)
	lw $t1, 1304($sp)
	lw $t0, 0($t1)
	sw $t0, 1528($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 1528($sp)
	lw $t1, 204($sp)
	add $t1, $t0, $t1
	sw $t1, 564($sp)
	li $t0, 1
	neg $t1, $t0
	sw $t1, 196($sp)
	lw $t1, 564($sp)
	lw $t0, 0($t1)
	sw $t0, 872($sp)
	lw $t0, 872($sp)
	lw $t1, 196($sp)
	seq $t1, $t0, $t1
	sw $t1, 1280($sp)
	lw $t0, 1280($sp)
	sw $t0, 1360($sp)
	b _logicalMerge1029
_logicalFalse1028:
	li $t0, 0
	sw $t0, 1360($sp)
	b _logicalMerge1029
_logicalMerge1029:
	lw $t0, 1360($sp)
	beqz $t0, _alternative1022
	b _consequence1021
_consequence1021:
	lw $t0, 1352($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 508($sp)
	lw $t0, 508($sp)
	sw $t0, 1352($sp)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 392($sp)
	lw $t0, 544($sp)
	lw $t1, 392($sp)
	add $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 1388($sp)
	lw $t1, 244($sp)
	sw $t0, 0($t1)
	lw $t0, 1352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 796($sp)
	lw $t0, 940($sp)
	lw $t1, 796($sp)
	add $t1, $t0, $t1
	sw $t1, 1000($sp)
	lw $t0, 1060($sp)
	lw $t1, 1000($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1144($sp)
	lw $t0, 1044($sp)
	lw $t1, 1144($sp)
	add $t1, $t0, $t1
	sw $t1, 780($sp)
	lw $t1, 780($sp)
	lw $t0, 0($t1)
	sw $t0, 1544($sp)
	lw $t0, 1060($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1380($sp)
	lw $t0, 1544($sp)
	lw $t1, 1380($sp)
	add $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $t0, 340($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 640($sp)
	lw $t0, 640($sp)
	lw $t1, 412($sp)
	sw $t0, 0($t1)
	lw $t0, 1388($sp)
	lw $t1, 604($sp)
	seq $t1, $t0, $t1
	sw $t1, 536($sp)
	lw $t0, 536($sp)
	beqz $t0, _logicalFalse1034
	b _logicalTrue1033
_logicalTrue1033:
	lw $t0, 1060($sp)
	lw $t1, 1064($sp)
	seq $t1, $t0, $t1
	sw $t1, 632($sp)
	lw $t0, 632($sp)
	sw $t0, 152($sp)
	b _logicalMerge1035
_logicalFalse1034:
	li $t0, 0
	sw $t0, 152($sp)
	b _logicalMerge1035
_logicalMerge1035:
	lw $t0, 152($sp)
	beqz $t0, _alternative1031
	b _consequence1030
_consequence1030:
	li $t0, 1
	sw $t0, 520($sp)
	b _OutOfIf1032
_alternative1031:
	b _OutOfIf1032
_OutOfIf1032:
	b _OutOfIf1023
_alternative1022:
	b _OutOfIf1023
_OutOfIf1023:
	lw $t0, 520($sp)
	li $t1, 1
	seq $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, 256($sp)
	beqz $t0, _alternative1037
	b _consequence1036
_consequence1036:
	b _OutOfWhile915
	b _OutOfIf1038
_alternative1037:
	b _OutOfIf1038
_OutOfIf1038:
	lw $t0, 1464($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 576($sp)
	lw $t0, 576($sp)
	sw $t0, 1464($sp)
	b _WhileLoop902
_OutOfWhile915:
	lw $t0, 520($sp)
	li $t1, 1
	seq $t1, $t0, $t1
	sw $t1, 752($sp)
	lw $t0, 752($sp)
	beqz $t0, _alternative1040
	b _consequence1039
_consequence1039:
	lw $t0, 604($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 664($sp)
	lw $t0, 1044($sp)
	lw $t1, 664($sp)
	add $t1, $t0, $t1
	sw $t1, 1252($sp)
	lw $t1, 1252($sp)
	lw $t0, 0($t1)
	sw $t0, 952($sp)
	lw $t0, 1064($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 848($sp)
	lw $t0, 952($sp)
	lw $t1, 848($sp)
	add $t1, $t0, $t1
	sw $t1, 680($sp)
	lw $t1, 680($sp)
	lw $t0, 0($t1)
	sw $t0, 176($sp)
	lw $a0, 176($sp)
	jal func__toString
	sw $v0, 620($sp)
	lw $a0, 620($sp)
	jal func__println
	sw $v0, 164($sp)
	b _OutOfIf1041
_alternative1040:
	la $a0, string_2509
	jal func__print
	sw $v0, 1124($sp)
	b _OutOfIf1041
_OutOfIf1041:
	li $v0, 0
	b _EndOfFunctionDecl893
_EndOfFunctionDecl893:
	lw $ra, 120($sp)
	add $sp, $sp, 1580
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
.word 13
string_2509:
.asciiz "no solution!\n"
.align 2
