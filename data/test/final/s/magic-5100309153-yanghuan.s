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
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl1213:
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $a0, 148($sp)
	li $v0, 9
	syscall
	sw $v0, 152($sp)
	lw $t0, 196($sp)
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 164($sp)
	lw $t0, 164($sp)
	sw $t0, global_30
	li $t0, 0
	sw $t0, global_33
_ForLoop1219:
	lw $t0, global_33
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _OutOfFor1230
_ForBody1229:
	lw $t0, global_33
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, global_30
	lw $t1, 188($sp)
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 196($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	li $t1, 4
	add $t2, $t2, $t1
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
	lw $t0, 196($sp)
	sw $t0, 0($t2)
	li $t1, 4
	add $t2, $t2, $t1
	move $t2, $t2
	lw $t1, 192($sp)
	sw $t2, 0($t1)
	li $t0, 0
	sw $t0, global_34
_ForLoop1221:
	lw $t0, global_34
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	beqz $t0, _OutOfFor1232
_ForBody1231:
	lw $t0, global_33
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_30
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t1, 160($sp)
	lw $t2, 0($t1)
	lw $t0, global_34
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t1, 172($sp)
	add $t1, $t2, $t1
	sw $t1, 180($sp)
	li $t0, 0
	lw $t1, 180($sp)
	sw $t0, 0($t1)
_continueFor1222:
	lw $t0, global_34
	sw $t0, 144($sp)
	lw $t0, global_34
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_34
	b _ForLoop1221
_OutOfFor1232:
	b _continueFor1220
_continueFor1220:
	lw $t0, global_33
	sw $t0, 184($sp)
	lw $t0, global_33
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_33
	b _ForLoop1219
_OutOfFor1230:
	b _EndOfFunctionDecl1214
_EndOfFunctionDecl1214:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
	add $sp, $sp, 200
	jr $ra
_search:
	sub $sp, $sp, 1516
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl1215:
	lw $t0, 1508($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 724($sp)
	lw $t0, 724($sp)
	beqz $t0, _logicalFalse1237
_logicalTrue1236:
	li $t0, 1
	move $t5, $t0
	b _logicalMerge1238
_logicalFalse1237:
	lw $t0, 1508($sp)
	li $t1, 0
	slt $t1, $t0, $t1
	sw $t1, 1496($sp)
	lw $t0, 1496($sp)
	move $t5, $t0
	b _logicalMerge1238
_logicalMerge1238:
	beqz $t5, _logicalFalse1240
_logicalTrue1239:
	li $t0, 1
	move $t7, $t0
	b _logicalMerge1241
_logicalFalse1240:
	lw $t0, 1504($sp)
	li $t1, 0
	seq $t2, $t0, $t1
	move $t7, $t2
	b _logicalMerge1241
_logicalMerge1241:
	beqz $t7, _logicalFalse1243
_logicalTrue1242:
	li $t0, 1
	move $s0, $t0
	b _logicalMerge1244
_logicalFalse1243:
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t2, $t0, $t1
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t3, $t3, $t4
	lw $t2, 0($t2)
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	lw $t0, 1504($sp)
	li $t1, 1
	sub $t3, $t0, $t1
	li $t1, 4
	mul $t3, $t3, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	li $t1, 15
	seq $t2, $t2, $t1
	move $s0, $t2
	b _logicalMerge1244
_logicalMerge1244:
	beqz $s0, _alternative1234
_consequence1233:
	lw $t0, 1504($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _logicalFalse1249
_logicalTrue1248:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	move $s1, $t2
	b _logicalMerge1250
_logicalFalse1249:
	li $t0, 0
	move $s1, $t0
	b _logicalMerge1250
_logicalMerge1250:
	beqz $s1, _alternative1246
_consequence1245:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 45
	lw $t1, 1512($sp)
	sub $t2, $t0, $t1
	sw $t2, 0($t3)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t2, $t3
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t4, $t3, $t2
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	move $s2, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t4, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	beqz $t2, _logicalFalse1255
_logicalTrue1254:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t3, $t3, $t4
	lw $t4, 0($t2)
	lw $t2, 0($t3)
	add $t4, $t4, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	move $s3, $t2
	b _logicalMerge1256
_logicalFalse1255:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge1256
_logicalMerge1256:
	beqz $s3, _logicalFalse1258
_logicalTrue1257:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t3, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s4, $t2
	b _logicalMerge1259
_logicalFalse1258:
	li $t0, 0
	move $s4, $t0
	b _logicalMerge1259
_logicalMerge1259:
	beqz $s4, _logicalFalse1261
_logicalTrue1260:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 1
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t2, 0($t2)
	lw $t3, 0($t3)
	add $t3, $t2, $t3
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s5, $t2
	b _logicalMerge1262
_logicalFalse1261:
	li $t0, 0
	move $s5, $t0
	b _logicalMerge1262
_logicalMerge1262:
	beqz $s5, _logicalFalse1264
_logicalTrue1263:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t4, $t2, $t3
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t3, 0($t4)
	lw $t2, 0($t2)
	add $t4, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	add $t2, $t4, $t2
	seq $t2, $t2, $s2
	move $s6, $t2
	b _logicalMerge1265
_logicalFalse1264:
	li $t0, 0
	move $s6, $t0
	b _logicalMerge1265
_logicalMerge1265:
	beqz $s6, _logicalFalse1267
_logicalTrue1266:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t3, 0($t3)
	lw $t2, 0($t2)
	add $t3, $t3, $t2
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 2
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	add $t2, $t3, $t2
	seq $t2, $t2, $s2
	move $s7, $t2
	b _logicalMerge1268
_logicalFalse1267:
	li $t0, 0
	move $s7, $t0
	b _logicalMerge1268
_logicalMerge1268:
	beqz $s7, _logicalFalse1270
_logicalTrue1269:
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	add $t3, $t3, $t2
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
	add $t4, $t4, $t2
	lw $t2, 0($t3)
	lw $t3, 0($t4)
	add $t2, $t2, $t3
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	li $t0, 2
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	add $t2, $t2, $t3
	seq $t2, $t2, $s2
	move $t8, $t2
	b _logicalMerge1271
_logicalFalse1270:
	li $t0, 0
	move $t8, $t0
	b _logicalMerge1271
_logicalMerge1271:
	beqz $t8, _alternative1252
_consequence1251:
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_32
	add $t2, $t0, $t2
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_32
	add $t3, $t0, $t3
	lw $t3, 0($t3)
	li $t1, 1
	add $t3, $t3, $t1
	sw $t3, 0($t2)
	li $t0, 0
	move $t4, $t0
_ForLoop1223:
	li $t1, 2
	sle $t2, $t4, $t1
	beqz $t2, _OutOfFor1273
_ForBody1272:
	li $t0, 0
	move $t9, $t0
_ForLoop1225:
	li $t1, 2
	sle $t2, $t9, $t1
	beqz $t2, _OutOfFor1275
_ForBody1274:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 4
	mul $t3, $t9, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	move $a0, $t2
	jal func__toString
	move $t2, $v0
	move $a0, $t2
	jal func__print
	move $t2, $v0
	la $a0, string_255
	jal func__print
	move $t2, $v0
_continueFor1226:
	move $t2, $t9
	li $t1, 1
	add $t9, $t9, $t1
	b _ForLoop1225
_OutOfFor1275:
	la $a0, string_258
	jal func__print
	move $t2, $v0
_continueFor1224:
	move $t2, $t4
	li $t1, 1
	add $t4, $t4, $t1
	b _ForLoop1223
_OutOfFor1273:
	la $a0, string_261
	jal func__print
	move $t2, $v0
	b _OutOfIf1253
_alternative1252:
	b _OutOfIf1253
_OutOfIf1253:
	b _OutOfIf1247
_alternative1246:
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative1277
_consequence1276:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t6, $t3, $t2
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 0
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t0, 15
	sub $t3, $t0, $t2
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t0, 1
	li $t1, 4
	mul $t4, $t0, $t1
	add $t2, $t2, $t4
	lw $t2, 0($t2)
	sub $t2, $t3, $t2
	sw $t2, 0($t6)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 0
	sgt $t2, $t2, $t1
	beqz $t2, _logicalFalse1283
_logicalTrue1282:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	li $t1, 10
	slt $t2, $t2, $t1
	move $t6, $t2
	b _logicalMerge1284
_logicalFalse1283:
	li $t0, 0
	move $t6, $t0
	b _logicalMerge1284
_logicalMerge1284:
	beqz $t6, _logicalFalse1286
_logicalTrue1285:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 0
	seq $t2, $t2, $t1
	move $k0, $t2
	b _logicalMerge1287
_logicalFalse1286:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge1287
_logicalMerge1287:
	beqz $k0, _alternative1280
_consequence1279:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 1
	sw $t0, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative1289
_consequence1288:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t3, $t0, $t1
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t4, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t4, $t2
	lw $t2, 0($t2)
	lw $t0, 1512($sp)
	add $t2, $t0, $t2
	sw $t3, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf1290
_alternative1289:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t2, $t0, $t1
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	lw $t0, global_30
	add $t3, $t0, $t3
	lw $t4, 0($t3)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t3, $t4, $t3
	lw $t3, 0($t3)
	lw $t0, 1512($sp)
	add $t3, $t0, $t3
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t2, -8($sp)
	sw $t3, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf1290
_OutOfIf1290:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	lw $t2, 0($t2)
	li $t1, 4
	mul $t2, $t2, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 0
	sw $t0, 0($t2)
	b _OutOfIf1281
_alternative1280:
	b _OutOfIf1281
_OutOfIf1281:
	b _OutOfIf1278
_alternative1277:
	li $t0, 1
	move $t4, $t0
_ForLoop1227:
	li $t1, 9
	sle $t2, $t4, $t1
	beqz $t2, _OutOfFor1292
_ForBody1291:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	li $t1, 0
	seq $t2, $t2, $t1
	beqz $t2, _alternative1294
_consequence1293:
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 1
	sw $t0, 0($t2)
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t2, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t3, $t0, $t1
	add $t2, $t2, $t3
	sw $t4, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 2
	seq $t2, $t0, $t1
	beqz $t2, _alternative1297
_consequence1296:
	lw $t0, 1504($sp)
	li $t1, 1
	add $t3, $t0, $t1
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
	sw $t3, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf1298
_alternative1297:
	lw $t0, 1508($sp)
	li $t1, 1
	add $t3, $t0, $t1
	lw $t0, 1512($sp)
	add $t2, $t0, $t4
	lw $t0, 1504($sp)
	sw $t0, -12($sp)
	sw $t3, -8($sp)
	sw $t2, -4($sp)
	jal _search
	move $t2, $v0
	b _OutOfIf1298
_OutOfIf1298:
	lw $t0, 1504($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	lw $t0, global_30
	add $t2, $t0, $t2
	lw $t3, 0($t2)
	lw $t0, 1508($sp)
	li $t1, 4
	mul $t2, $t0, $t1
	add $t2, $t3, $t2
	li $t0, 0
	sw $t0, 0($t2)
	li $t1, 4
	mul $t2, $t4, $t1
	lw $t0, global_31
	add $t2, $t0, $t2
	li $t0, 0
	sw $t0, 0($t2)
	b _OutOfIf1295
_alternative1294:
	b _OutOfIf1295
_OutOfIf1295:
	b _continueFor1228
_continueFor1228:
	move $t2, $t4
	li $t1, 1
	add $t4, $t4, $t1
	b _ForLoop1227
_OutOfFor1292:
	b _OutOfIf1278
_OutOfIf1278:
	b _OutOfIf1247
_OutOfIf1247:
	b _OutOfIf1235
_alternative1234:
	b _OutOfIf1235
_OutOfIf1235:
	b _EndOfFunctionDecl1216
_EndOfFunctionDecl1216:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
	add $sp, $sp, 1516
	jr $ra
main:
	sub $sp, $sp, 180
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl1217:
	li $t0, 10
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
	sw $v0, 140($sp)
	li $t0, 10
	lw $t1, 140($sp)
	sw $t0, 0($t1)
	lw $t0, 140($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	sw $t0, 168($sp)
	lw $t0, 168($sp)
	sw $t0, global_31
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $a0, 148($sp)
	li $v0, 9
	syscall
	sw $v0, 172($sp)
	li $t0, 1
	lw $t1, 172($sp)
	sw $t0, 0($t1)
	lw $t0, 172($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	sw $t0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_32
	li $t0, 3
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 144($sp)
	li $t0, 0
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	sw $v0, 156($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, global_32
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t1, 128($sp)
	lw $t0, 0($t1)
	sw $t0, 160($sp)
	lw $a0, 160($sp)
	jal func__toString
	sw $v0, 164($sp)
	lw $a0, 164($sp)
	jal func__println
	sw $v0, 152($sp)
	li $v0, 0
	b _EndOfFunctionDecl1218
_EndOfFunctionDecl1218:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
	add $sp, $sp, 180
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_30:
.space 4
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
global_34:
.space 4
.align 2
.word 1
string_255:
.asciiz " "
.align 2
.word 1
string_258:
.asciiz "\n"
.align 2
.word 1
string_261:
.asciiz "\n"
.align 2
