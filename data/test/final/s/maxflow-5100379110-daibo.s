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
	sw $ra, 120($sp)
_BeginOfFunctionDecl1379:
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $a0, 160($sp)
	li $v0, 9
	syscall
	sw $v0, 188($sp)
	lw $t0, 196($sp)
	lw $t1, 188($sp)
	sw $t0, 0($t1)
	lw $t0, 188($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	sw $t0, 184($sp)
	lw $t0, 184($sp)
	sw $t0, global_3246
	li $t0, 0
	sw $t0, global_3251
_ForLoop1389:
	lw $t0, global_3251
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	beqz $t0, _OutOfFor1409
	b _ForBody1408
_ForBody1408:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, global_3246
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $a0, 168($sp)
	li $v0, 9
	syscall
	sw $v0, 144($sp)
	lw $t0, 196($sp)
	lw $t1, 144($sp)
	sw $t0, 0($t1)
	lw $t0, 144($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	sw $t0, 152($sp)
	lw $t0, 152($sp)
	lw $t1, 140($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, global_3252
_ForLoop1391:
	lw $t0, global_3252
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	beqz $t0, _OutOfFor1411
	b _ForBody1410
_ForBody1410:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, global_3246
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t1, 156($sp)
	lw $t0, 0($t1)
	sw $t0, 148($sp)
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 148($sp)
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	li $t0, 0
	lw $t1, 176($sp)
	sw $t0, 0($t1)
_continueFor1392:
	lw $t0, global_3252
	sw $t0, 192($sp)
	lw $t0, global_3252
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3252
	b _ForLoop1391
_OutOfFor1411:
	b _continueFor1390
_continueFor1390:
	lw $t0, global_3251
	sw $t0, 136($sp)
	lw $t0, global_3251
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3251
	b _ForLoop1389
_OutOfFor1409:
	b _EndOfFunctionDecl1380
_EndOfFunctionDecl1380:
	lw $ra, 120($sp)
	add $sp, $sp, 200
	jr $ra
_build:
	sub $sp, $sp, 236
	sw $ra, 120($sp)
_BeginOfFunctionDecl1381:
	li $t0, 1
	sw $t0, global_3251
_ForLoop1393:
	lw $t0, global_3251
	li $t1, 49
	sle $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, 196($sp)
	beqz $t0, _OutOfFor1413
	b _ForBody1412
_ForBody1412:
	li $t0, 50
	sw $t0, global_3252
_ForLoop1395:
	li $t0, 98
	lw $t1, global_3251
	sub $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, global_3252
	lw $t1, 144($sp)
	sle $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _OutOfFor1415
	b _ForBody1414
_ForBody1414:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_3246
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t1, 224($sp)
	lw $t0, 0($t1)
	sw $t0, 172($sp)
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 172($sp)
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	li $t0, 1
	lw $t1, 200($sp)
	sw $t0, 0($t1)
_continueFor1396:
	lw $t0, global_3252
	sw $t0, 188($sp)
	lw $t0, global_3252
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3252
	b _ForLoop1395
_OutOfFor1415:
	b _continueFor1394
_continueFor1394:
	lw $t0, global_3251
	sw $t0, 168($sp)
	lw $t0, global_3251
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3251
	b _ForLoop1393
_OutOfFor1413:
	li $t0, 1
	sw $t0, global_3251
_ForLoop1397:
	lw $t0, global_3251
	li $t1, 49
	sle $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	beqz $t0, _OutOfFor1417
	b _ForBody1416
_ForBody1416:
	lw $t0, 228($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, global_3246
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t1, 132($sp)
	lw $t0, 0($t1)
	sw $t0, 192($sp)
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 192($sp)
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	li $t0, 1
	lw $t1, 160($sp)
	sw $t0, 0($t1)
_continueFor1398:
	lw $t0, global_3251
	sw $t0, 216($sp)
	lw $t0, global_3251
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3251
	b _ForLoop1397
_OutOfFor1417:
	li $t0, 50
	sw $t0, global_3251
_ForLoop1399:
	lw $t0, global_3251
	li $t1, 98
	sle $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	beqz $t0, _OutOfFor1419
	b _ForBody1418
_ForBody1418:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, global_3246
	lw $t1, 208($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 204($sp)
	lw $t0, 232($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 204($sp)
	lw $t1, 212($sp)
	add $t1, $t0, $t1
	sw $t1, 220($sp)
	li $t0, 1
	lw $t1, 220($sp)
	sw $t0, 0($t1)
_continueFor1400:
	lw $t0, global_3251
	sw $t0, 176($sp)
	lw $t0, global_3251
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3251
	b _ForLoop1399
_OutOfFor1419:
	li $v0, 0
	b _EndOfFunctionDecl1382
_EndOfFunctionDecl1382:
	lw $ra, 120($sp)
	add $sp, $sp, 236
	jr $ra
_find:
	sub $sp, $sp, 296
	sw $ra, 120($sp)
_BeginOfFunctionDecl1383:
	li $t0, 0
	sw $t0, global_3253
	li $t0, 1
	sw $t0, global_3254
	li $t0, 1
	sw $t0, global_3251
_ForLoop1401:
	lw $t0, global_3251
	lw $t1, 284($sp)
	sle $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t0, 260($sp)
	beqz $t0, _OutOfFor1421
	b _ForBody1420
_ForBody1420:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_3248
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	li $t0, 0
	lw $t1, 176($sp)
	sw $t0, 0($t1)
_continueFor1402:
	lw $t0, global_3251
	sw $t0, 252($sp)
	lw $t0, global_3251
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3251
	b _ForLoop1401
_OutOfFor1421:
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_3250
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t0, 288($sp)
	lw $t1, 224($sp)
	sw $t0, 0($t1)
	lw $t0, 288($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, global_3248
	lw $t1, 212($sp)
	add $t1, $t0, $t1
	sw $t1, 232($sp)
	li $t0, 1
	lw $t1, 232($sp)
	sw $t0, 0($t1)
	lw $t0, 288($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, global_3249
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	li $t0, 0
	lw $t1, 188($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, 292($sp)
_WhileLoop1403:
	lw $t0, global_3253
	lw $t1, global_3254
	slt $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, 236($sp)
	beqz $t0, _logicalFalse1425
	b _logicalTrue1424
_logicalTrue1424:
	lw $t0, 292($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, 216($sp)
	sw $t0, 172($sp)
	b _logicalMerge1426
_logicalFalse1425:
	li $t0, 0
	sw $t0, 172($sp)
	b _logicalMerge1426
_logicalMerge1426:
	lw $t0, 172($sp)
	beqz $t0, _OutOfWhile1423
	b _WhileBody1422
_WhileBody1422:
	lw $t0, global_3253
	sw $t0, 192($sp)
	lw $t0, global_3253
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3253
	lw $t0, global_3253
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, global_3250
	lw $t1, 272($sp)
	add $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t1, 244($sp)
	lw $t0, 0($t1)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_3251
	li $t0, 1
	sw $t0, global_3252
_ForLoop1404:
	lw $t0, global_3252
	lw $t1, 284($sp)
	sle $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 180($sp)
	beqz $t0, _OutOfFor1428
	b _ForBody1427
_ForBody1427:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, global_3246
	lw $t1, 268($sp)
	add $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t1, 256($sp)
	lw $t0, 0($t1)
	sw $t0, 160($sp)
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t0, 160($sp)
	lw $t1, 276($sp)
	add $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t1, 280($sp)
	lw $t0, 0($t1)
	sw $t0, 148($sp)
	lw $t0, 148($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	beqz $t0, _logicalFalse1433
	b _logicalTrue1432
_logicalTrue1432:
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, global_3248
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t1, 220($sp)
	lw $t0, 0($t1)
	sw $t0, 196($sp)
	lw $t0, 196($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	sw $t0, 248($sp)
	b _logicalMerge1434
_logicalFalse1433:
	li $t0, 0
	sw $t0, 248($sp)
	b _logicalMerge1434
_logicalMerge1434:
	lw $t0, 248($sp)
	beqz $t0, _alternative1430
	b _consequence1429
_consequence1429:
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, global_3248
	lw $t1, 200($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	li $t0, 1
	lw $t1, 128($sp)
	sw $t0, 0($t1)
	lw $t0, global_3254
	sw $t0, 204($sp)
	lw $t0, global_3254
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3254
	lw $t0, global_3254
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, global_3250
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, global_3252
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t0, global_3249
	lw $t1, 228($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, global_3251
	lw $t1, 264($sp)
	sw $t0, 0($t1)
	lw $t0, global_3254
	lw $t1, 284($sp)
	seq $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, 208($sp)
	beqz $t0, _alternative1436
	b _consequence1435
_consequence1435:
	li $t0, 1
	sw $t0, 292($sp)
	b _OutOfIf1437
_alternative1436:
	b _OutOfIf1437
_OutOfIf1437:
	b _OutOfIf1431
_alternative1430:
	b _OutOfIf1431
_OutOfIf1431:
	b _continueFor1405
_continueFor1405:
	lw $t0, global_3252
	sw $t0, 144($sp)
	lw $t0, global_3252
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3252
	b _ForLoop1404
_OutOfFor1428:
	b _WhileLoop1403
_OutOfWhile1423:
	lw $v0, 292($sp)
	b _EndOfFunctionDecl1384
_EndOfFunctionDecl1384:
	lw $ra, 120($sp)
	add $sp, $sp, 296
	jr $ra
_improve:
	sub $sp, $sp, 228
	sw $ra, 120($sp)
_BeginOfFunctionDecl1385:
	lw $t0, 224($sp)
	sw $t0, global_3251
	lw $t0, global_3247
	sw $t0, 212($sp)
	lw $t0, global_3247
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_3247
_WhileLoop1406:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, global_3249
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t1, 176($sp)
	lw $t0, 0($t1)
	sw $t0, 188($sp)
	lw $t0, 188($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	beqz $t0, _OutOfWhile1439
	b _WhileBody1438
_WhileBody1438:
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_3249
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t1, 140($sp)
	lw $t0, 0($t1)
	sw $t0, 216($sp)
	lw $t0, 216($sp)
	sw $t0, global_3252
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, global_3246
	lw $t1, 144($sp)
	add $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t1, 220($sp)
	lw $t0, 0($t1)
	sw $t0, 128($sp)
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 128($sp)
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t1, 156($sp)
	lw $t0, 0($t1)
	sw $t0, 180($sp)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	lw $t1, 156($sp)
	sw $t0, 0($t1)
	lw $t0, global_3251
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, global_3246
	lw $t1, 200($sp)
	add $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t1, 204($sp)
	lw $t0, 0($t1)
	sw $t0, 208($sp)
	lw $t0, global_3252
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 208($sp)
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t1, 148($sp)
	lw $t0, 0($t1)
	sw $t0, 184($sp)
	sw $t0, 192($sp)
	lw $t0, 192($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, 196($sp)
	lw $t1, 148($sp)
	sw $t0, 0($t1)
	lw $t0, global_3252
	sw $t0, global_3251
	b _WhileLoop1406
_OutOfWhile1439:
	li $v0, 0
	b _EndOfFunctionDecl1386
_EndOfFunctionDecl1386:
	lw $ra, 120($sp)
	add $sp, $sp, 228
	jr $ra
main:
	sub $sp, $sp, 208
	sw $ra, 120($sp)
_BeginOfFunctionDecl1387:
	li $t0, 0
	sw $t0, global_3247
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 192($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $a0, 192($sp)
	li $v0, 9
	syscall
	sw $v0, 152($sp)
	li $t0, 110
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 128($sp)
	lw $t0, 128($sp)
	sw $t0, global_3248
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $a0, 200($sp)
	li $v0, 9
	syscall
	sw $v0, 180($sp)
	li $t0, 110
	lw $t1, 180($sp)
	sw $t0, 0($t1)
	lw $t0, 180($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 180($sp)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_3249
	li $t0, 110
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $a0, 136($sp)
	li $v0, 9
	syscall
	sw $v0, 148($sp)
	li $t0, 110
	lw $t1, 148($sp)
	sw $t0, 0($t1)
	lw $t0, 148($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	sw $t0, 168($sp)
	lw $t0, 168($sp)
	sw $t0, global_3250
	li $t0, 110
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 144($sp)
	li $t0, 0
	sw $t0, 156($sp)
	li $t0, 99
	sw $t0, 184($sp)
	li $t0, 100
	sw $t0, 196($sp)
	li $t0, 0
	sw $t0, 160($sp)
	lw $t0, 184($sp)
	sw $t0, -8($sp)
	lw $t0, 196($sp)
	sw $t0, -4($sp)
	jal _build
	sw $v0, 140($sp)
_WhileLoop1407:
	lw $t0, 196($sp)
	sw $t0, -12($sp)
	lw $t0, 184($sp)
	sw $t0, -8($sp)
	lw $t0, 160($sp)
	sw $t0, -4($sp)
	jal _find
	sw $v0, 164($sp)
	lw $t0, 164($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	beqz $t0, _OutOfWhile1441
	b _WhileBody1440
_WhileBody1440:
	lw $t0, 196($sp)
	sw $t0, -4($sp)
	jal _improve
	sw $v0, 172($sp)
	b _WhileLoop1407
_OutOfWhile1441:
	lw $a0, global_3247
	jal func__toString
	sw $v0, 188($sp)
	lw $a0, 188($sp)
	jal func__println
	sw $v0, 176($sp)
	li $v0, 0
	b _EndOfFunctionDecl1388
_EndOfFunctionDecl1388:
	lw $ra, 120($sp)
	add $sp, $sp, 208
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_3246:
.space 4
.align 2
global_3247:
.space 4
.align 2
global_3248:
.space 4
.align 2
global_3249:
.space 4
.align 2
global_3250:
.space 4
.align 2
global_3251:
.space 4
.align 2
global_3252:
.space 4
.align 2
global_3253:
.space 4
.align 2
global_3254:
.space 4
.align 2
