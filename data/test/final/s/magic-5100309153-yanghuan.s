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
_BeginOfFunctionDecl1213:
	lw $t0, 196($sp)
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
	sw $v0, 188($sp)
	lw $t0, 196($sp)
	lw $t1, 188($sp)
	sw $t0, 0($t1)
	lw $t0, 188($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	sw $t0, 136($sp)
	lw $t0, 136($sp)
	sw $t0, global_2779
	li $t0, 0
	sw $t0, global_2782
_ForLoop1219:
	lw $t0, global_2782
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	beqz $t0, _OutOfFor1230
	b _ForBody1229
_ForBody1229:
	lw $t0, global_2782
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, global_2779
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 196($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 184($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $a0, 184($sp)
	li $v0, 9
	syscall
	sw $v0, 192($sp)
	lw $t0, 196($sp)
	lw $t1, 192($sp)
	sw $t0, 0($t1)
	lw $t0, 192($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 192($sp)
	sw $t0, 148($sp)
	lw $t0, 148($sp)
	lw $t1, 144($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, global_2783
_ForLoop1221:
	lw $t0, global_2783
	lw $t1, 196($sp)
	slt $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _OutOfFor1232
	b _ForBody1231
_ForBody1231:
	lw $t0, global_2782
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_2779
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t1, 128($sp)
	lw $t0, 0($t1)
	sw $t0, 172($sp)
	lw $t0, global_2783
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 172($sp)
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	li $t0, 0
	lw $t1, 140($sp)
	sw $t0, 0($t1)
_continueFor1222:
	lw $t0, global_2783
	sw $t0, 160($sp)
	lw $t0, global_2783
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_2783
	b _ForLoop1221
_OutOfFor1232:
	b _continueFor1220
_continueFor1220:
	lw $t0, global_2782
	sw $t0, 180($sp)
	lw $t0, global_2782
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_2782
	b _ForLoop1219
_OutOfFor1230:
	b _EndOfFunctionDecl1214
_EndOfFunctionDecl1214:
	lw $ra, 120($sp)
	add $sp, $sp, 200
	jr $ra
_search:
	sub $sp, $sp, 1528
	sw $ra, 120($sp)
_BeginOfFunctionDecl1215:
	lw $t0, 1520($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 1368($sp)
	lw $t0, 1368($sp)
	beqz $t0, _logicalFalse1237
	b _logicalTrue1236
_logicalTrue1236:
	li $t0, 1
	sw $t0, 1376($sp)
	b _logicalMerge1238
_logicalFalse1237:
	lw $t0, 1520($sp)
	li $t1, 0
	slt $t1, $t0, $t1
	sw $t1, 864($sp)
	lw $t0, 864($sp)
	sw $t0, 1376($sp)
	b _logicalMerge1238
_logicalMerge1238:
	lw $t0, 1376($sp)
	beqz $t0, _logicalFalse1240
	b _logicalTrue1239
_logicalTrue1239:
	li $t0, 1
	sw $t0, 452($sp)
	b _logicalMerge1241
_logicalFalse1240:
	lw $t0, 1516($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 1040($sp)
	lw $t0, 1040($sp)
	sw $t0, 452($sp)
	b _logicalMerge1241
_logicalMerge1241:
	lw $t0, 452($sp)
	beqz $t0, _logicalFalse1243
	b _logicalTrue1242
_logicalTrue1242:
	li $t0, 1
	sw $t0, 732($sp)
	b _logicalMerge1244
_logicalFalse1243:
	lw $t0, 1516($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 908($sp)
	lw $t0, 908($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1508($sp)
	lw $t0, global_2779
	lw $t1, 1508($sp)
	add $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t1, 368($sp)
	lw $t0, 0($t1)
	sw $t0, 248($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t0, 248($sp)
	lw $t1, 424($sp)
	add $t1, $t0, $t1
	sw $t1, 1360($sp)
	lw $t0, 1516($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 936($sp)
	lw $t0, 936($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1456($sp)
	lw $t0, global_2779
	lw $t1, 1456($sp)
	add $t1, $t0, $t1
	sw $t1, 596($sp)
	lw $t1, 596($sp)
	lw $t0, 0($t1)
	sw $t0, 540($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1032($sp)
	lw $t0, 540($sp)
	lw $t1, 1032($sp)
	add $t1, $t0, $t1
	sw $t1, 468($sp)
	lw $t1, 1360($sp)
	lw $t0, 0($t1)
	sw $t0, 548($sp)
	lw $t1, 468($sp)
	lw $t0, 0($t1)
	sw $t0, 1280($sp)
	lw $t0, 548($sp)
	lw $t1, 1280($sp)
	add $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, 1516($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 252($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1220($sp)
	lw $t0, global_2779
	lw $t1, 1220($sp)
	add $t1, $t0, $t1
	sw $t1, 1212($sp)
	lw $t1, 1212($sp)
	lw $t0, 0($t1)
	sw $t0, 924($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1012($sp)
	lw $t0, 924($sp)
	lw $t1, 1012($sp)
	add $t1, $t0, $t1
	sw $t1, 584($sp)
	lw $t1, 584($sp)
	lw $t0, 0($t1)
	sw $t0, 1104($sp)
	lw $t0, 360($sp)
	lw $t1, 1104($sp)
	add $t1, $t0, $t1
	sw $t1, 712($sp)
	lw $t0, 712($sp)
	li $t1, 15
	seq $t1, $t0, $t1
	sw $t1, 600($sp)
	lw $t0, 600($sp)
	sw $t0, 732($sp)
	b _logicalMerge1244
_logicalMerge1244:
	lw $t0, 732($sp)
	beqz $t0, _alternative1234
	b _consequence1233
_consequence1233:
	lw $t0, 1516($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 1412($sp)
	lw $t0, 1412($sp)
	beqz $t0, _logicalFalse1249
	b _logicalTrue1248
_logicalTrue1248:
	lw $t0, 1520($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 576($sp)
	lw $t0, 576($sp)
	sw $t0, 460($sp)
	b _logicalMerge1250
_logicalFalse1249:
	li $t0, 0
	sw $t0, 460($sp)
	b _logicalMerge1250
_logicalMerge1250:
	lw $t0, 460($sp)
	beqz $t0, _alternative1246
	b _consequence1245
_consequence1245:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1416($sp)
	lw $t0, global_2779
	lw $t1, 1416($sp)
	add $t1, $t0, $t1
	sw $t1, 616($sp)
	lw $t1, 616($sp)
	lw $t0, 0($t1)
	sw $t0, 180($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1140($sp)
	lw $t0, 180($sp)
	lw $t1, 1140($sp)
	add $t1, $t0, $t1
	sw $t1, 588($sp)
	li $t0, 45
	lw $t1, 1524($sp)
	sub $t1, $t0, $t1
	sw $t1, 420($sp)
	lw $t0, 420($sp)
	lw $t1, 588($sp)
	sw $t0, 0($t1)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1460($sp)
	lw $t0, global_2779
	lw $t1, 1460($sp)
	add $t1, $t0, $t1
	sw $t1, 1088($sp)
	lw $t1, 1088($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1036($sp)
	lw $t0, 220($sp)
	lw $t1, 1036($sp)
	add $t1, $t0, $t1
	sw $t1, 972($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, global_2779
	lw $t1, 384($sp)
	add $t1, $t0, $t1
	sw $t1, 1180($sp)
	lw $t1, 1180($sp)
	lw $t0, 0($t1)
	sw $t0, 520($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 532($sp)
	lw $t0, 520($sp)
	lw $t1, 532($sp)
	add $t1, $t0, $t1
	sw $t1, 1332($sp)
	lw $t1, 972($sp)
	lw $t0, 0($t1)
	sw $t0, 1084($sp)
	lw $t1, 1332($sp)
	lw $t0, 0($t1)
	sw $t0, 456($sp)
	lw $t0, 1084($sp)
	lw $t1, 456($sp)
	add $t1, $t0, $t1
	sw $t1, 516($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1444($sp)
	lw $t0, global_2779
	lw $t1, 1444($sp)
	add $t1, $t0, $t1
	sw $t1, 1424($sp)
	lw $t1, 1424($sp)
	lw $t0, 0($t1)
	sw $t0, 852($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1492($sp)
	lw $t0, 852($sp)
	lw $t1, 1492($sp)
	add $t1, $t0, $t1
	sw $t1, 816($sp)
	lw $t1, 816($sp)
	lw $t0, 0($t1)
	sw $t0, 1252($sp)
	lw $t0, 516($sp)
	lw $t1, 1252($sp)
	add $t1, $t0, $t1
	sw $t1, 944($sp)
	lw $t0, 944($sp)
	sw $t0, 1108($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 980($sp)
	lw $t0, global_2779
	lw $t1, 980($sp)
	add $t1, $t0, $t1
	sw $t1, 644($sp)
	lw $t1, 644($sp)
	lw $t0, 0($t1)
	sw $t0, 672($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1052($sp)
	lw $t0, 672($sp)
	lw $t1, 1052($sp)
	add $t1, $t0, $t1
	sw $t1, 688($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, global_2779
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 492($sp)
	lw $t1, 492($sp)
	lw $t0, 0($t1)
	sw $t0, 1428($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1392($sp)
	lw $t0, 1428($sp)
	lw $t1, 1392($sp)
	add $t1, $t0, $t1
	sw $t1, 1196($sp)
	lw $t1, 688($sp)
	lw $t0, 0($t1)
	sw $t0, 1144($sp)
	lw $t1, 1196($sp)
	lw $t0, 0($t1)
	sw $t0, 484($sp)
	lw $t0, 1144($sp)
	lw $t1, 484($sp)
	add $t1, $t0, $t1
	sw $t1, 1168($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 284($sp)
	lw $t0, global_2779
	lw $t1, 284($sp)
	add $t1, $t0, $t1
	sw $t1, 1316($sp)
	lw $t1, 1316($sp)
	lw $t0, 0($t1)
	sw $t0, 1352($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 1352($sp)
	lw $t1, 132($sp)
	add $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t1, 300($sp)
	lw $t0, 0($t1)
	sw $t0, 176($sp)
	lw $t0, 1168($sp)
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 1128($sp)
	lw $t0, 1128($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 556($sp)
	lw $t0, 556($sp)
	beqz $t0, _logicalFalse1255
	b _logicalTrue1254
_logicalTrue1254:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 956($sp)
	lw $t0, global_2779
	lw $t1, 956($sp)
	add $t1, $t0, $t1
	sw $t1, 1284($sp)
	lw $t1, 1284($sp)
	lw $t0, 0($t1)
	sw $t0, 372($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1228($sp)
	lw $t0, 372($sp)
	lw $t1, 1228($sp)
	add $t1, $t0, $t1
	sw $t1, 1356($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 636($sp)
	lw $t0, global_2779
	lw $t1, 636($sp)
	add $t1, $t0, $t1
	sw $t1, 1420($sp)
	lw $t1, 1420($sp)
	lw $t0, 0($t1)
	sw $t0, 504($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 504($sp)
	lw $t1, 200($sp)
	add $t1, $t0, $t1
	sw $t1, 332($sp)
	lw $t1, 1356($sp)
	lw $t0, 0($t1)
	sw $t0, 1312($sp)
	lw $t1, 332($sp)
	lw $t0, 0($t1)
	sw $t0, 488($sp)
	lw $t0, 1312($sp)
	lw $t1, 488($sp)
	add $t1, $t0, $t1
	sw $t1, 624($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1148($sp)
	lw $t0, global_2779
	lw $t1, 1148($sp)
	add $t1, $t0, $t1
	sw $t1, 1024($sp)
	lw $t1, 1024($sp)
	lw $t0, 0($t1)
	sw $t0, 1244($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 888($sp)
	lw $t0, 1244($sp)
	lw $t1, 888($sp)
	add $t1, $t0, $t1
	sw $t1, 1364($sp)
	lw $t1, 1364($sp)
	lw $t0, 0($t1)
	sw $t0, 628($sp)
	lw $t0, 624($sp)
	lw $t1, 628($sp)
	add $t1, $t0, $t1
	sw $t1, 984($sp)
	lw $t0, 984($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 876($sp)
	lw $t0, 876($sp)
	sw $t0, 1344($sp)
	b _logicalMerge1256
_logicalFalse1255:
	li $t0, 0
	sw $t0, 1344($sp)
	b _logicalMerge1256
_logicalMerge1256:
	lw $t0, 1344($sp)
	beqz $t0, _logicalFalse1258
	b _logicalTrue1257
_logicalTrue1257:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 844($sp)
	lw $t0, global_2779
	lw $t1, 844($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 640($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1384($sp)
	lw $t0, 640($sp)
	lw $t1, 1384($sp)
	add $t1, $t0, $t1
	sw $t1, 728($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, global_2779
	lw $t1, 216($sp)
	add $t1, $t0, $t1
	sw $t1, 1264($sp)
	lw $t1, 1264($sp)
	lw $t0, 0($t1)
	sw $t0, 1476($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 704($sp)
	lw $t0, 1476($sp)
	lw $t1, 704($sp)
	add $t1, $t0, $t1
	sw $t1, 720($sp)
	lw $t1, 728($sp)
	lw $t0, 0($t1)
	sw $t0, 808($sp)
	lw $t1, 720($sp)
	lw $t0, 0($t1)
	sw $t0, 976($sp)
	lw $t0, 808($sp)
	lw $t1, 976($sp)
	add $t1, $t0, $t1
	sw $t1, 272($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1124($sp)
	lw $t0, global_2779
	lw $t1, 1124($sp)
	add $t1, $t0, $t1
	sw $t1, 692($sp)
	lw $t1, 692($sp)
	lw $t0, 0($t1)
	sw $t0, 1240($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t0, 1240($sp)
	lw $t1, 336($sp)
	add $t1, $t0, $t1
	sw $t1, 900($sp)
	lw $t1, 900($sp)
	lw $t0, 0($t1)
	sw $t0, 784($sp)
	lw $t0, 272($sp)
	lw $t1, 784($sp)
	add $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t0, 388($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 696($sp)
	lw $t0, 696($sp)
	sw $t0, 392($sp)
	b _logicalMerge1259
_logicalFalse1258:
	li $t0, 0
	sw $t0, 392($sp)
	b _logicalMerge1259
_logicalMerge1259:
	lw $t0, 392($sp)
	beqz $t0, _logicalFalse1261
	b _logicalTrue1260
_logicalTrue1260:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 676($sp)
	lw $t0, global_2779
	lw $t1, 676($sp)
	add $t1, $t0, $t1
	sw $t1, 524($sp)
	lw $t1, 524($sp)
	lw $t0, 0($t1)
	sw $t0, 1304($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1408($sp)
	lw $t0, 1304($sp)
	lw $t1, 1408($sp)
	add $t1, $t0, $t1
	sw $t1, 736($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 544($sp)
	lw $t0, global_2779
	lw $t1, 544($sp)
	add $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t1, 376($sp)
	lw $t0, 0($t1)
	sw $t0, 256($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t0, 256($sp)
	lw $t1, 304($sp)
	add $t1, $t0, $t1
	sw $t1, 940($sp)
	lw $t1, 736($sp)
	lw $t0, 0($t1)
	sw $t0, 1204($sp)
	lw $t1, 940($sp)
	lw $t0, 0($t1)
	sw $t0, 788($sp)
	lw $t0, 1204($sp)
	lw $t1, 788($sp)
	add $t1, $t0, $t1
	sw $t1, 1184($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 776($sp)
	lw $t0, global_2779
	lw $t1, 776($sp)
	add $t1, $t0, $t1
	sw $t1, 1112($sp)
	lw $t1, 1112($sp)
	lw $t0, 0($t1)
	sw $t0, 464($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 812($sp)
	lw $t0, 464($sp)
	lw $t1, 812($sp)
	add $t1, $t0, $t1
	sw $t1, 592($sp)
	lw $t1, 592($sp)
	lw $t0, 0($t1)
	sw $t0, 792($sp)
	lw $t0, 1184($sp)
	lw $t1, 792($sp)
	add $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t0, 348($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 428($sp)
	sw $t0, 700($sp)
	b _logicalMerge1262
_logicalFalse1261:
	li $t0, 0
	sw $t0, 700($sp)
	b _logicalMerge1262
_logicalMerge1262:
	lw $t0, 700($sp)
	beqz $t0, _logicalFalse1264
	b _logicalTrue1263
_logicalTrue1263:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 648($sp)
	lw $t0, global_2779
	lw $t1, 648($sp)
	add $t1, $t0, $t1
	sw $t1, 408($sp)
	lw $t1, 408($sp)
	lw $t0, 0($t1)
	sw $t0, 832($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1432($sp)
	lw $t0, 832($sp)
	lw $t1, 1432($sp)
	add $t1, $t0, $t1
	sw $t1, 412($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1340($sp)
	lw $t0, global_2779
	lw $t1, 1340($sp)
	add $t1, $t0, $t1
	sw $t1, 1336($sp)
	lw $t1, 1336($sp)
	lw $t0, 0($t1)
	sw $t0, 140($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1048($sp)
	lw $t0, 140($sp)
	lw $t1, 1048($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t1, 412($sp)
	lw $t0, 0($t1)
	sw $t0, 152($sp)
	lw $t1, 160($sp)
	lw $t0, 0($t1)
	sw $t0, 400($sp)
	lw $t0, 152($sp)
	lw $t1, 400($sp)
	add $t1, $t0, $t1
	sw $t1, 1208($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 968($sp)
	lw $t0, global_2779
	lw $t1, 968($sp)
	add $t1, $t0, $t1
	sw $t1, 1328($sp)
	lw $t1, 1328($sp)
	lw $t0, 0($t1)
	sw $t0, 684($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 800($sp)
	lw $t0, 684($sp)
	lw $t1, 800($sp)
	add $t1, $t0, $t1
	sw $t1, 1096($sp)
	lw $t1, 1096($sp)
	lw $t0, 0($t1)
	sw $t0, 288($sp)
	lw $t0, 1208($sp)
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 824($sp)
	lw $t0, 824($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 1028($sp)
	lw $t0, 1028($sp)
	sw $t0, 796($sp)
	b _logicalMerge1265
_logicalFalse1264:
	li $t0, 0
	sw $t0, 796($sp)
	b _logicalMerge1265
_logicalMerge1265:
	lw $t0, 796($sp)
	beqz $t0, _logicalFalse1267
	b _logicalTrue1266
_logicalTrue1266:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 716($sp)
	lw $t0, global_2779
	lw $t1, 716($sp)
	add $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t1, 260($sp)
	lw $t0, 0($t1)
	sw $t0, 992($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 992($sp)
	lw $t1, 204($sp)
	add $t1, $t0, $t1
	sw $t1, 1188($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 748($sp)
	lw $t0, global_2779
	lw $t1, 748($sp)
	add $t1, $t0, $t1
	sw $t1, 1396($sp)
	lw $t1, 1396($sp)
	lw $t0, 0($t1)
	sw $t0, 1440($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 680($sp)
	lw $t0, 1440($sp)
	lw $t1, 680($sp)
	add $t1, $t0, $t1
	sw $t1, 1292($sp)
	lw $t1, 1188($sp)
	lw $t0, 0($t1)
	sw $t0, 1268($sp)
	lw $t1, 1292($sp)
	lw $t0, 0($t1)
	sw $t0, 1320($sp)
	lw $t0, 1268($sp)
	lw $t1, 1320($sp)
	add $t1, $t0, $t1
	sw $t1, 560($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 328($sp)
	lw $t0, global_2779
	lw $t1, 328($sp)
	add $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t1, 312($sp)
	lw $t0, 0($t1)
	sw $t0, 932($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 500($sp)
	lw $t0, 932($sp)
	lw $t1, 500($sp)
	add $t1, $t0, $t1
	sw $t1, 1248($sp)
	lw $t1, 1248($sp)
	lw $t0, 0($t1)
	sw $t0, 444($sp)
	lw $t0, 560($sp)
	lw $t1, 444($sp)
	add $t1, $t0, $t1
	sw $t1, 476($sp)
	lw $t0, 476($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 244($sp)
	sw $t0, 916($sp)
	b _logicalMerge1268
_logicalFalse1267:
	li $t0, 0
	sw $t0, 916($sp)
	b _logicalMerge1268
_logicalMerge1268:
	lw $t0, 916($sp)
	beqz $t0, _logicalFalse1270
	b _logicalTrue1269
_logicalTrue1269:
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, global_2779
	lw $t1, 164($sp)
	add $t1, $t0, $t1
	sw $t1, 708($sp)
	lw $t1, 708($sp)
	lw $t0, 0($t1)
	sw $t0, 1072($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 960($sp)
	lw $t0, 1072($sp)
	lw $t1, 960($sp)
	add $t1, $t0, $t1
	sw $t1, 1224($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 836($sp)
	lw $t0, global_2779
	lw $t1, 836($sp)
	add $t1, $t0, $t1
	sw $t1, 1192($sp)
	lw $t1, 1192($sp)
	lw $t0, 0($t1)
	sw $t0, 1160($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, 1160($sp)
	lw $t1, 264($sp)
	add $t1, $t0, $t1
	sw $t1, 1152($sp)
	lw $t1, 1224($sp)
	lw $t0, 0($t1)
	sw $t0, 1232($sp)
	lw $t1, 1152($sp)
	lw $t0, 0($t1)
	sw $t0, 724($sp)
	lw $t0, 1232($sp)
	lw $t1, 724($sp)
	add $t1, $t0, $t1
	sw $t1, 828($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t0, global_2779
	lw $t1, 344($sp)
	add $t1, $t0, $t1
	sw $t1, 1296($sp)
	lw $t1, 1296($sp)
	lw $t0, 0($t1)
	sw $t0, 324($sp)
	li $t0, 2
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 884($sp)
	lw $t0, 324($sp)
	lw $t1, 884($sp)
	add $t1, $t0, $t1
	sw $t1, 472($sp)
	lw $t1, 472($sp)
	lw $t0, 0($t1)
	sw $t0, 1496($sp)
	lw $t0, 828($sp)
	lw $t1, 1496($sp)
	add $t1, $t0, $t1
	sw $t1, 396($sp)
	lw $t0, 396($sp)
	lw $t1, 1108($sp)
	seq $t1, $t0, $t1
	sw $t1, 1236($sp)
	lw $t0, 1236($sp)
	sw $t0, 872($sp)
	b _logicalMerge1271
_logicalFalse1270:
	li $t0, 0
	sw $t0, 872($sp)
	b _logicalMerge1271
_logicalMerge1271:
	lw $t0, 872($sp)
	beqz $t0, _alternative1252
	b _consequence1251
_consequence1251:
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1488($sp)
	lw $t0, global_2781
	lw $t1, 1488($sp)
	add $t1, $t0, $t1
	sw $t1, 1324($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1464($sp)
	lw $t0, global_2781
	lw $t1, 1464($sp)
	add $t1, $t0, $t1
	sw $t1, 988($sp)
	lw $t1, 988($sp)
	lw $t0, 0($t1)
	sw $t0, 780($sp)
	lw $t0, 780($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	lw $t1, 1324($sp)
	sw $t0, 0($t1)
	li $t0, 0
	sw $t0, 1068($sp)
_ForLoop1223:
	lw $t0, 1068($sp)
	li $t1, 2
	sle $t1, $t0, $t1
	sw $t1, 580($sp)
	lw $t0, 580($sp)
	beqz $t0, _OutOfFor1273
	b _ForBody1272
_ForBody1272:
	li $t0, 0
	sw $t0, 1404($sp)
_ForLoop1225:
	lw $t0, 1404($sp)
	li $t1, 2
	sle $t1, $t0, $t1
	sw $t1, 668($sp)
	lw $t0, 668($sp)
	beqz $t0, _OutOfFor1275
	b _ForBody1274
_ForBody1274:
	lw $t0, 1068($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, global_2779
	lw $t1, 232($sp)
	add $t1, $t0, $t1
	sw $t1, 652($sp)
	lw $t1, 652($sp)
	lw $t0, 0($t1)
	sw $t0, 552($sp)
	lw $t0, 1404($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t0, 552($sp)
	lw $t1, 404($sp)
	add $t1, $t0, $t1
	sw $t1, 1300($sp)
	lw $t1, 1300($sp)
	lw $t0, 0($t1)
	sw $t0, 568($sp)
	lw $a0, 568($sp)
	jal func__toString
	sw $v0, 996($sp)
	lw $a0, 996($sp)
	jal func__print
	sw $v0, 1400($sp)
	la $a0, string_3046
	jal func__print
	sw $v0, 192($sp)
_continueFor1226:
	lw $t0, 1404($sp)
	sw $t0, 168($sp)
	lw $t0, 1404($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1404($sp)
	b _ForLoop1225
_OutOfFor1275:
	la $a0, string_3049
	jal func__print
	sw $v0, 1348($sp)
_continueFor1224:
	lw $t0, 1068($sp)
	sw $t0, 1372($sp)
	lw $t0, 1068($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1068($sp)
	b _ForLoop1223
_OutOfFor1273:
	la $a0, string_3052
	jal func__print
	sw $v0, 308($sp)
	b _OutOfIf1253
_alternative1252:
	b _OutOfIf1253
_OutOfIf1253:
	b _OutOfIf1247
_alternative1246:
	lw $t0, 1520($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 564($sp)
	lw $t0, 564($sp)
	beqz $t0, _alternative1277
	b _consequence1276
_consequence1276:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, global_2779
	lw $t1, 432($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t1, 208($sp)
	lw $t0, 0($t1)
	sw $t0, 1452($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $t0, 1452($sp)
	lw $t1, 1080($sp)
	add $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1016($sp)
	lw $t0, global_2779
	lw $t1, 1016($sp)
	add $t1, $t0, $t1
	sw $t1, 612($sp)
	lw $t1, 612($sp)
	lw $t0, 0($t1)
	sw $t0, 892($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1100($sp)
	lw $t0, 892($sp)
	lw $t1, 1100($sp)
	add $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t1, 276($sp)
	lw $t0, 0($t1)
	sw $t0, 1448($sp)
	li $t0, 15
	lw $t1, 1448($sp)
	sub $t1, $t0, $t1
	sw $t1, 1156($sp)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 840($sp)
	lw $t0, global_2779
	lw $t1, 840($sp)
	add $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t1, 316($sp)
	lw $t0, 0($t1)
	sw $t0, 172($sp)
	li $t0, 1
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1000($sp)
	lw $t0, 172($sp)
	lw $t1, 1000($sp)
	add $t1, $t0, $t1
	sw $t1, 760($sp)
	lw $t1, 760($sp)
	lw $t0, 0($t1)
	sw $t0, 768($sp)
	lw $t0, 1156($sp)
	lw $t1, 768($sp)
	sub $t1, $t0, $t1
	sw $t1, 528($sp)
	lw $t0, 528($sp)
	lw $t1, 280($sp)
	sw $t0, 0($t1)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 772($sp)
	lw $t0, global_2779
	lw $t1, 772($sp)
	add $t1, $t0, $t1
	sw $t1, 1076($sp)
	lw $t1, 1076($sp)
	lw $t0, 0($t1)
	sw $t0, 268($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 268($sp)
	lw $t1, 212($sp)
	add $t1, $t0, $t1
	sw $t1, 1004($sp)
	lw $t1, 1004($sp)
	lw $t0, 0($t1)
	sw $t0, 1308($sp)
	lw $t0, 1308($sp)
	li $t1, 0
	sgt $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t0, 364($sp)
	beqz $t0, _logicalFalse1283
	b _logicalTrue1282
_logicalTrue1282:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 752($sp)
	lw $t0, global_2779
	lw $t1, 752($sp)
	add $t1, $t0, $t1
	sw $t1, 856($sp)
	lw $t1, 856($sp)
	lw $t0, 0($t1)
	sw $t0, 928($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 928($sp)
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 860($sp)
	lw $t1, 860($sp)
	lw $t0, 0($t1)
	sw $t0, 1480($sp)
	lw $t0, 1480($sp)
	li $t1, 10
	slt $t1, $t0, $t1
	sw $t1, 804($sp)
	lw $t0, 804($sp)
	sw $t0, 1468($sp)
	b _logicalMerge1284
_logicalFalse1283:
	li $t0, 0
	sw $t0, 1468($sp)
	b _logicalMerge1284
_logicalMerge1284:
	lw $t0, 1468($sp)
	beqz $t0, _logicalFalse1286
	b _logicalTrue1285
_logicalTrue1285:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t0, global_2779
	lw $t1, 320($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t1, 228($sp)
	lw $t0, 0($t1)
	sw $t0, 848($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 352($sp)
	lw $t0, 848($sp)
	lw $t1, 352($sp)
	add $t1, $t0, $t1
	sw $t1, 572($sp)
	lw $t1, 572($sp)
	lw $t0, 0($t1)
	sw $t0, 536($sp)
	lw $t0, 536($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 948($sp)
	lw $t0, global_2780
	lw $t1, 948($sp)
	add $t1, $t0, $t1
	sw $t1, 1056($sp)
	lw $t1, 1056($sp)
	lw $t0, 0($t1)
	sw $t0, 1288($sp)
	lw $t0, 1288($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 868($sp)
	lw $t0, 868($sp)
	sw $t0, 1500($sp)
	b _logicalMerge1287
_logicalFalse1286:
	li $t0, 0
	sw $t0, 1500($sp)
	b _logicalMerge1287
_logicalMerge1287:
	lw $t0, 1500($sp)
	beqz $t0, _alternative1280
	b _consequence1279
_consequence1279:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, global_2779
	lw $t1, 196($sp)
	add $t1, $t0, $t1
	sw $t1, 1276($sp)
	lw $t1, 1276($sp)
	lw $t0, 0($t1)
	sw $t0, 1512($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 912($sp)
	lw $t0, 1512($sp)
	lw $t1, 912($sp)
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t1, 144($sp)
	lw $t0, 0($t1)
	sw $t0, 416($sp)
	lw $t0, 416($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t0, global_2780
	lw $t1, 448($sp)
	add $t1, $t0, $t1
	sw $t1, 896($sp)
	li $t0, 1
	lw $t1, 896($sp)
	sw $t0, 0($t1)
	lw $t0, 1520($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 880($sp)
	lw $t0, 880($sp)
	beqz $t0, _alternative1289
	b _consequence1288
_consequence1288:
	lw $t0, 1516($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1116($sp)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, global_2779
	lw $t1, 356($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t1, 224($sp)
	lw $t0, 0($t1)
	sw $t0, 952($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 340($sp)
	lw $t0, 952($sp)
	lw $t1, 340($sp)
	add $t1, $t0, $t1
	sw $t1, 1272($sp)
	lw $t1, 1272($sp)
	lw $t0, 0($t1)
	sw $t0, 128($sp)
	lw $t0, 1524($sp)
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 664($sp)
	lw $t0, 1116($sp)
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	lw $t0, 664($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 744($sp)
	b _OutOfIf1290
_alternative1289:
	lw $t0, 1520($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 964($sp)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, global_2779
	lw $t1, 296($sp)
	add $t1, $t0, $t1
	sw $t1, 1064($sp)
	lw $t1, 1064($sp)
	lw $t0, 0($t1)
	sw $t0, 236($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 512($sp)
	lw $t0, 236($sp)
	lw $t1, 512($sp)
	add $t1, $t0, $t1
	sw $t1, 1436($sp)
	lw $t1, 1436($sp)
	lw $t0, 0($t1)
	sw $t0, 1120($sp)
	lw $t0, 1524($sp)
	lw $t1, 1120($sp)
	add $t1, $t0, $t1
	sw $t1, 292($sp)
	lw $t0, 1516($sp)
	sw $t0, -12($sp)
	lw $t0, 964($sp)
	sw $t0, -8($sp)
	lw $t0, 292($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 436($sp)
	b _OutOfIf1290
_OutOfIf1290:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1164($sp)
	lw $t0, global_2779
	lw $t1, 1164($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t1, 156($sp)
	lw $t0, 0($t1)
	sw $t0, 1132($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 756($sp)
	lw $t0, 1132($sp)
	lw $t1, 756($sp)
	add $t1, $t0, $t1
	sw $t1, 1020($sp)
	lw $t1, 1020($sp)
	lw $t0, 0($t1)
	sw $t0, 1176($sp)
	lw $t0, 1176($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1256($sp)
	lw $t0, global_2780
	lw $t1, 1256($sp)
	add $t1, $t0, $t1
	sw $t1, 740($sp)
	li $t0, 0
	lw $t1, 740($sp)
	sw $t0, 0($t1)
	b _OutOfIf1281
_alternative1280:
	b _OutOfIf1281
_OutOfIf1281:
	b _OutOfIf1278
_alternative1277:
	li $t0, 1
	sw $t0, 1068($sp)
_ForLoop1227:
	lw $t0, 1068($sp)
	li $t1, 9
	sle $t1, $t0, $t1
	sw $t1, 1388($sp)
	lw $t0, 1388($sp)
	beqz $t0, _OutOfFor1292
	b _ForBody1291
_ForBody1291:
	lw $t0, 1068($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 1092($sp)
	lw $t0, global_2780
	lw $t1, 1092($sp)
	add $t1, $t0, $t1
	sw $t1, 480($sp)
	lw $t1, 480($sp)
	lw $t0, 0($t1)
	sw $t0, 1136($sp)
	lw $t0, 1136($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 1216($sp)
	lw $t0, 1216($sp)
	beqz $t0, _alternative1294
	b _consequence1293
_consequence1293:
	lw $t0, 1068($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 620($sp)
	lw $t0, global_2780
	lw $t1, 620($sp)
	add $t1, $t0, $t1
	sw $t1, 1484($sp)
	li $t0, 1
	lw $t1, 1484($sp)
	sw $t0, 0($t1)
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 508($sp)
	lw $t0, global_2779
	lw $t1, 508($sp)
	add $t1, $t0, $t1
	sw $t1, 1472($sp)
	lw $t1, 1472($sp)
	lw $t0, 0($t1)
	sw $t0, 1260($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 764($sp)
	lw $t0, 1260($sp)
	lw $t1, 764($sp)
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 1068($sp)
	lw $t1, 148($sp)
	sw $t0, 0($t1)
	lw $t0, 1520($sp)
	li $t1, 2
	seq $t1, $t0, $t1
	sw $t1, 1380($sp)
	lw $t0, 1380($sp)
	beqz $t0, _alternative1297
	b _consequence1296
_consequence1296:
	lw $t0, 1516($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $t0, 1524($sp)
	lw $t1, 1068($sp)
	add $t1, $t0, $t1
	sw $t1, 820($sp)
	lw $t0, 1200($sp)
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	lw $t0, 820($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 1504($sp)
	b _OutOfIf1298
_alternative1297:
	lw $t0, 1520($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 440($sp)
	lw $t0, 1524($sp)
	lw $t1, 1068($sp)
	add $t1, $t0, $t1
	sw $t1, 1044($sp)
	lw $t0, 1516($sp)
	sw $t0, -12($sp)
	lw $t0, 440($sp)
	sw $t0, -8($sp)
	lw $t0, 1044($sp)
	sw $t0, -4($sp)
	jal _search
	sw $v0, 380($sp)
	b _OutOfIf1298
_OutOfIf1298:
	lw $t0, 1516($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 604($sp)
	lw $t0, global_2779
	lw $t1, 604($sp)
	add $t1, $t0, $t1
	sw $t1, 904($sp)
	lw $t1, 904($sp)
	lw $t0, 0($t1)
	sw $t0, 656($sp)
	lw $t0, 1520($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 608($sp)
	lw $t0, 656($sp)
	lw $t1, 608($sp)
	add $t1, $t0, $t1
	sw $t1, 1008($sp)
	li $t0, 0
	lw $t1, 1008($sp)
	sw $t0, 0($t1)
	lw $t0, 1068($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 632($sp)
	lw $t0, global_2780
	lw $t1, 632($sp)
	add $t1, $t0, $t1
	sw $t1, 660($sp)
	li $t0, 0
	lw $t1, 660($sp)
	sw $t0, 0($t1)
	b _OutOfIf1295
_alternative1294:
	b _OutOfIf1295
_OutOfIf1295:
	b _continueFor1228
_continueFor1228:
	lw $t0, 1068($sp)
	sw $t0, 1060($sp)
	lw $t0, 1068($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 1068($sp)
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
	add $sp, $sp, 1528
	jr $ra
main:
	sub $sp, $sp, 180
	sw $ra, 120($sp)
_BeginOfFunctionDecl1217:
	li $t0, 10
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $a0, 172($sp)
	li $v0, 9
	syscall
	sw $v0, 152($sp)
	li $t0, 10
	lw $t1, 152($sp)
	sw $t0, 0($t1)
	lw $t0, 152($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 128($sp)
	lw $t0, 128($sp)
	sw $t0, global_2780
	li $t0, 1
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
	sw $v0, 164($sp)
	li $t0, 1
	lw $t1, 164($sp)
	sw $t0, 0($t1)
	lw $t0, 164($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	sw $t0, 148($sp)
	lw $t0, 148($sp)
	sw $t0, global_2781
	li $t0, 3
	sw $t0, -4($sp)
	jal _origin
	sw $v0, 168($sp)
	li $t0, 0
	sw $t0, -12($sp)
	li $t0, 0
	sw $t0, -8($sp)
	li $t0, 0
	sw $t0, -4($sp)
	jal _search
	sw $v0, 144($sp)
	li $t0, 0
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, global_2781
	lw $t1, 132($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t1, 160($sp)
	lw $t0, 0($t1)
	sw $t0, 140($sp)
	lw $a0, 140($sp)
	jal func__toString
	sw $v0, 176($sp)
	lw $a0, 176($sp)
	jal func__println
	sw $v0, 156($sp)
	li $v0, 0
	b _EndOfFunctionDecl1218
_EndOfFunctionDecl1218:
	lw $ra, 120($sp)
	add $sp, $sp, 180
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_2779:
.space 4
.align 2
global_2780:
.space 4
.align 2
global_2781:
.space 4
.align 2
global_2782:
.space 4
.align 2
global_2783:
.space 4
.align 2
.word 1
string_3046:
.asciiz " "
.align 2
.word 1
string_3049:
.asciiz "\n"
.align 2
.word 1
string_3052:
.asciiz "\n"
.align 2
