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
	sub $sp, $sp, 456
	sw $ra, 120($sp)
_BeginOfFunctionDecl1908:
	li $t0, 0
	sw $t0, global_6991
	jal func__getInt
	sw $v0, 152($sp)
	lw $t0, 152($sp)
	sw $t0, global_6990
	lw $t0, global_6990
	li $t1, 5
	add $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t0, 316($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $a0, 204($sp)
	li $v0, 9
	syscall
	sw $v0, 344($sp)
	lw $t0, 316($sp)
	lw $t1, 344($sp)
	sw $t0, 0($t1)
	lw $t0, 344($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t0, 344($sp)
	sw $t0, 128($sp)
	lw $t0, 128($sp)
	sw $t0, global_6992
	li $t0, 0
	sw $t0, 324($sp)
_WhileLoop1910:
	lw $t0, 324($sp)
	lw $t1, global_6990
	sle $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t0, 336($sp)
	beqz $t0, _OutOfWhile1916
	b _WhileBody1915
_WhileBody1915:
	lw $t0, 324($sp)
	sw $t0, 352($sp)
	lw $t0, 324($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, 352($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, global_6992
	lw $t1, 252($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
	li $t0, 1
	lw $t1, 228($sp)
	sw $t0, 0($t1)
	b _WhileLoop1910
_OutOfWhile1916:
	lw $t0, global_6990
	li $t1, 5
	add $t1, $t0, $t1
	sw $t1, 284($sp)
	lw $t0, 284($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $a0, 140($sp)
	li $v0, 9
	syscall
	sw $v0, 176($sp)
	lw $t0, 284($sp)
	lw $t1, 176($sp)
	sw $t0, 0($t1)
	lw $t0, 176($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 176($sp)
	sw $t0, 248($sp)
	lw $t0, 248($sp)
	sw $t0, 156($sp)
	lw $t0, global_6990
	li $t1, 5
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $a0, 132($sp)
	li $v0, 9
	syscall
	sw $v0, 444($sp)
	lw $t0, 160($sp)
	lw $t1, 444($sp)
	sw $t0, 0($t1)
	lw $t0, 444($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, 444($sp)
	sw $t0, 264($sp)
	lw $t0, 264($sp)
	sw $t0, 292($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $t0, 156($sp)
	lw $t1, 412($sp)
	add $t1, $t0, $t1
	sw $t1, 308($sp)
	li $t0, 1
	lw $t1, 308($sp)
	sw $t0, 0($t1)
	li $t0, 2
	sw $t0, 324($sp)
_ForLoop1911:
	b _ForBody1917
_ForBody1917:
	lw $t0, 324($sp)
	lw $t1, global_6990
	sgt $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 380($sp)
	beqz $t0, _alternative1920
	b _consequence1919
_consequence1919:
	b _OutOfFor1918
	b _OutOfIf1921
_alternative1920:
	b _OutOfIf1921
_OutOfIf1921:
	lw $t0, 324($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, global_6992
	lw $t1, 256($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t1, 196($sp)
	lw $t0, 0($t1)
	sw $t0, 208($sp)
	lw $t0, 208($sp)
	beqz $t0, _alternative1923
	b _consequence1922
_consequence1922:
	lw $t0, global_6991
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_6991
	lw $t0, global_6991
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, 292($sp)
	lw $t1, 312($sp)
	add $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 324($sp)
	lw $t1, 232($sp)
	sw $t0, 0($t1)
	lw $t0, 324($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 156($sp)
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t0, 324($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 184($sp)
	lw $t1, 424($sp)
	sw $t0, 0($t1)
	b _OutOfIf1924
_alternative1923:
	b _OutOfIf1924
_OutOfIf1924:
	lw $t0, 324($sp)
	sw $t0, 260($sp)
	li $t0, 1
	sw $t0, 148($sp)
_ForLoop1913:
	lw $t0, 148($sp)
	lw $t1, global_6991
	sle $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	beqz $t0, _logicalFalse1928
	b _logicalTrue1927
_logicalTrue1927:
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 440($sp)
	lw $t0, 292($sp)
	lw $t1, 440($sp)
	add $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t1, 320($sp)
	lw $t0, 0($t1)
	sw $t0, 384($sp)
	lw $t0, 260($sp)
	lw $t1, 384($sp)
	mul $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t0, 448($sp)
	lw $t1, global_6990
	sle $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, 236($sp)
	sw $t0, 328($sp)
	b _logicalMerge1929
_logicalFalse1928:
	li $t0, 0
	sw $t0, 328($sp)
	b _logicalMerge1929
_logicalMerge1929:
	lw $t0, 328($sp)
	beqz $t0, _OutOfFor1926
	b _ForBody1925
_ForBody1925:
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t0, 292($sp)
	lw $t1, 376($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t1, 188($sp)
	lw $t0, 0($t1)
	sw $t0, 224($sp)
	lw $t0, 260($sp)
	lw $t1, 224($sp)
	mul $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t0, 280($sp)
	sw $t0, 400($sp)
	lw $t0, 400($sp)
	lw $t1, global_6990
	sgt $t1, $t0, $t1
	sw $t1, 396($sp)
	lw $t0, 396($sp)
	beqz $t0, _alternative1931
	b _consequence1930
_consequence1930:
	b _continueFor1914
	b _OutOfIf1932
_alternative1931:
	b _OutOfIf1932
_OutOfIf1932:
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, global_6992
	lw $t1, 296($sp)
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	li $t0, 0
	lw $t1, 332($sp)
	sw $t0, 0($t1)
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 292($sp)
	lw $t1, 192($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t1, 136($sp)
	lw $t0, 0($t1)
	sw $t0, 356($sp)
	lw $t0, 260($sp)
	lw $t1, 356($sp)
	rem $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t0, 348($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 420($sp)
	lw $t0, 420($sp)
	beqz $t0, _alternative1934
	b _consequence1933
_consequence1933:
	lw $t0, 400($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 156($sp)
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t0, 260($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 156($sp)
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t0, 292($sp)
	lw $t1, 388($sp)
	add $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t1, 428($sp)
	lw $t0, 0($t1)
	sw $t0, 216($sp)
	lw $t1, 368($sp)
	lw $t0, 0($t1)
	sw $t0, 452($sp)
	lw $t0, 216($sp)
	lw $t1, 452($sp)
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	lw $t1, 300($sp)
	sw $t0, 0($t1)
	b _OutOfFor1926
	b _OutOfIf1935
_alternative1934:
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 292($sp)
	lw $t1, 244($sp)
	add $t1, $t0, $t1
	sw $t1, 340($sp)
	lw $t1, 340($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
	lw $t0, 260($sp)
	lw $t1, 220($sp)
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 288($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 156($sp)
	lw $t1, 272($sp)
	add $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, 260($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t0, 156($sp)
	lw $t1, 304($sp)
	add $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t0, 292($sp)
	lw $t1, 404($sp)
	add $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t1, 212($sp)
	lw $t0, 0($t1)
	sw $t0, 436($sp)
	lw $t0, 436($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 408($sp)
	lw $t1, 360($sp)
	lw $t0, 0($t1)
	sw $t0, 392($sp)
	lw $t0, 392($sp)
	lw $t1, 408($sp)
	mul $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	lw $t1, 268($sp)
	sw $t0, 0($t1)
	b _OutOfIf1935
_OutOfIf1935:
	b _continueFor1914
_continueFor1914:
	lw $t0, 148($sp)
	sw $t0, 416($sp)
	lw $t0, 148($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	b _ForLoop1913
_OutOfFor1926:
	lw $t0, 260($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 156($sp)
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t1, 432($sp)
	lw $t0, 0($t1)
	sw $t0, 372($sp)
	lw $a0, 372($sp)
	jal func__toString
	sw $v0, 364($sp)
	lw $a0, 364($sp)
	jal func__println
	sw $v0, 276($sp)
_continueFor1912:
	lw $t0, 324($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 324($sp)
	b _ForLoop1911
_OutOfFor1918:
	li $v0, 0
	b _EndOfFunctionDecl1909
_EndOfFunctionDecl1909:
	lw $ra, 120($sp)
	add $sp, $sp, 456
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_6990:
.space 4
.align 2
global_6991:
.space 4
.align 2
global_6992:
.space 4
.align 2
