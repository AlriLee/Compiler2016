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
	sub $sp, $sp, 3216
	sw $ra, 120($sp)
_BeginOfFunctionDecl444:
	li $t0, 1
	sw $t0, global_588
	li $t0, 1
	sw $t0, global_589
	li $t0, 1
	sw $t0, global_590
_WhileLoop446:
	li $t0, 1
	li $t1, 29
	sll $t1, $t0, $t1
	sw $t1, 2796($sp)
	lw $t0, global_590
	lw $t1, 2796($sp)
	slt $t1, $t0, $t1
	sw $t1, 1840($sp)
	lw $t0, 1840($sp)
	beqz $t0, _logicalFalse450
	b _logicalTrue449
_logicalTrue449:
	li $t0, 1
	li $t1, 29
	sll $t1, $t0, $t1
	sw $t1, 1700($sp)
	lw $t0, 1700($sp)
	neg $t1, $t0
	sw $t1, 1940($sp)
	lw $t0, global_590
	lw $t1, 1940($sp)
	sgt $t1, $t0, $t1
	sw $t1, 2788($sp)
	lw $t0, 2788($sp)
	sw $t0, 2180($sp)
	b _logicalMerge451
_logicalFalse450:
	li $t0, 0
	sw $t0, 2180($sp)
	b _logicalMerge451
_logicalMerge451:
	lw $t0, 2180($sp)
	beqz $t0, _OutOfWhile448
	b _WhileBody447
_WhileBody447:
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1484($sp)
	lw $t0, 1484($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 916($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3044($sp)
	lw $t0, 916($sp)
	lw $t1, 3044($sp)
	sub $t1, $t0, $t1
	sw $t1, 2348($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2940($sp)
	lw $t0, 2940($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3156($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3184($sp)
	lw $t0, 3156($sp)
	lw $t1, 3184($sp)
	sub $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 2348($sp)
	lw $t1, 212($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1328($sp)
	lw $t0, 1328($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1364($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 1364($sp)
	lw $t1, 164($sp)
	sub $t1, $t0, $t1
	sw $t1, 2824($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2876($sp)
	lw $t0, 2876($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2292($sp)
	lw $t0, 2824($sp)
	lw $t1, 2292($sp)
	add $t1, $t0, $t1
	sw $t1, 3176($sp)
	lw $t0, 264($sp)
	lw $t1, 3176($sp)
	add $t1, $t0, $t1
	sw $t1, 864($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2544($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t0, 304($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1300($sp)
	lw $t0, 2544($sp)
	lw $t1, 1300($sp)
	add $t1, $t0, $t1
	sw $t1, 1864($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2852($sp)
	lw $t0, 1864($sp)
	lw $t1, 2852($sp)
	sub $t1, $t0, $t1
	sw $t1, 1228($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 860($sp)
	lw $t0, 860($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2276($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t0, 2276($sp)
	lw $t1, 224($sp)
	sub $t1, $t0, $t1
	sw $t1, 2364($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2592($sp)
	lw $t0, 2592($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2208($sp)
	lw $t0, 2364($sp)
	lw $t1, 2208($sp)
	add $t1, $t0, $t1
	sw $t1, 812($sp)
	lw $t0, 1228($sp)
	lw $t1, 812($sp)
	add $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t0, 864($sp)
	lw $t1, 448($sp)
	sub $t1, $t0, $t1
	sw $t1, 2816($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 868($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1664($sp)
	lw $t0, 1664($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2552($sp)
	lw $t0, 868($sp)
	lw $t1, 2552($sp)
	add $t1, $t0, $t1
	sw $t1, 2432($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2612($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 912($sp)
	lw $t0, 912($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 824($sp)
	lw $t0, 2612($sp)
	lw $t1, 824($sp)
	add $t1, $t0, $t1
	sw $t1, 1948($sp)
	lw $t0, 2432($sp)
	lw $t1, 1948($sp)
	sub $t1, $t0, $t1
	sw $t1, 2840($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 692($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1596($sp)
	lw $t0, 692($sp)
	lw $t1, 1596($sp)
	add $t1, $t0, $t1
	sw $t1, 412($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1048($sp)
	lw $t0, 412($sp)
	lw $t1, 1048($sp)
	sub $t1, $t0, $t1
	sw $t1, 2468($sp)
	lw $t0, 2840($sp)
	lw $t1, 2468($sp)
	sub $t1, $t0, $t1
	sw $t1, 2568($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3088($sp)
	lw $t0, 3088($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2268($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2476($sp)
	lw $t0, 2268($sp)
	lw $t1, 2476($sp)
	sub $t1, $t0, $t1
	sw $t1, 1140($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1772($sp)
	lw $t0, 1772($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 1140($sp)
	lw $t1, 252($sp)
	add $t1, $t0, $t1
	sw $t1, 1368($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 320($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2664($sp)
	lw $t0, 2664($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1132($sp)
	lw $t0, 320($sp)
	lw $t1, 1132($sp)
	add $t1, $t0, $t1
	sw $t1, 572($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2480($sp)
	lw $t0, 572($sp)
	lw $t1, 2480($sp)
	sub $t1, $t0, $t1
	sw $t1, 2324($sp)
	lw $t0, 1368($sp)
	lw $t1, 2324($sp)
	sub $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, 2568($sp)
	lw $t1, 296($sp)
	add $t1, $t0, $t1
	sw $t1, 2000($sp)
	lw $t0, 2816($sp)
	lw $t1, 2000($sp)
	sub $t1, $t0, $t1
	sw $t1, 2440($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1072($sp)
	lw $t0, 1072($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2116($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2668($sp)
	lw $t0, 2116($sp)
	lw $t1, 2668($sp)
	sub $t1, $t0, $t1
	sw $t1, 2520($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1060($sp)
	lw $t0, 1060($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2600($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 516($sp)
	lw $t0, 2600($sp)
	lw $t1, 516($sp)
	sub $t1, $t0, $t1
	sw $t1, 2052($sp)
	lw $t0, 2520($sp)
	lw $t1, 2052($sp)
	add $t1, $t0, $t1
	sw $t1, 1964($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2264($sp)
	lw $t0, 2264($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1224($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1292($sp)
	lw $t0, 1224($sp)
	lw $t1, 1292($sp)
	sub $t1, $t0, $t1
	sw $t1, 808($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2784($sp)
	lw $t0, 2784($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1728($sp)
	lw $t0, 808($sp)
	lw $t1, 1728($sp)
	add $t1, $t0, $t1
	sw $t1, 848($sp)
	lw $t0, 1964($sp)
	lw $t1, 848($sp)
	add $t1, $t0, $t1
	sw $t1, 2756($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3004($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 964($sp)
	lw $t0, 964($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 780($sp)
	lw $t0, 3004($sp)
	lw $t1, 780($sp)
	add $t1, $t0, $t1
	sw $t1, 3204($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2096($sp)
	lw $t0, 3204($sp)
	lw $t1, 2096($sp)
	sub $t1, $t0, $t1
	sw $t1, 1824($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2380($sp)
	lw $t0, 2380($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2696($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1600($sp)
	lw $t0, 2696($sp)
	lw $t1, 1600($sp)
	sub $t1, $t0, $t1
	sw $t1, 1820($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1232($sp)
	lw $t0, 1232($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 1820($sp)
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 904($sp)
	lw $t0, 1824($sp)
	lw $t1, 904($sp)
	add $t1, $t0, $t1
	sw $t1, 1456($sp)
	lw $t0, 2756($sp)
	lw $t1, 1456($sp)
	sub $t1, $t0, $t1
	sw $t1, 2196($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2800($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1812($sp)
	lw $t0, 1812($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 2800($sp)
	lw $t1, 428($sp)
	add $t1, $t0, $t1
	sw $t1, 2920($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1376($sp)
	lw $t0, 2920($sp)
	lw $t1, 1376($sp)
	sub $t1, $t0, $t1
	sw $t1, 1992($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1032($sp)
	lw $t0, 1032($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1892($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 708($sp)
	lw $t0, 1892($sp)
	lw $t1, 708($sp)
	sub $t1, $t0, $t1
	sw $t1, 2044($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1616($sp)
	lw $t0, 1616($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1712($sp)
	lw $t0, 2044($sp)
	lw $t1, 1712($sp)
	add $t1, $t0, $t1
	sw $t1, 784($sp)
	lw $t0, 1992($sp)
	lw $t1, 784($sp)
	add $t1, $t0, $t1
	sw $t1, 984($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 832($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1496($sp)
	lw $t0, 1496($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2184($sp)
	lw $t0, 832($sp)
	lw $t1, 2184($sp)
	add $t1, $t0, $t1
	sw $t1, 1112($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2864($sp)
	lw $t0, 1112($sp)
	lw $t1, 2864($sp)
	sub $t1, $t0, $t1
	sw $t1, 1168($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1052($sp)
	lw $t0, 1052($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1160($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 604($sp)
	lw $t0, 1160($sp)
	lw $t1, 604($sp)
	sub $t1, $t0, $t1
	sw $t1, 2976($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1960($sp)
	lw $t0, 1960($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 992($sp)
	lw $t0, 2976($sp)
	lw $t1, 992($sp)
	add $t1, $t0, $t1
	sw $t1, 1656($sp)
	lw $t0, 1168($sp)
	lw $t1, 1656($sp)
	add $t1, $t0, $t1
	sw $t1, 452($sp)
	lw $t0, 984($sp)
	lw $t1, 452($sp)
	sub $t1, $t0, $t1
	sw $t1, 3080($sp)
	lw $t0, 2196($sp)
	lw $t1, 3080($sp)
	sub $t1, $t0, $t1
	sw $t1, 608($sp)
	lw $t0, 2440($sp)
	lw $t1, 608($sp)
	add $t1, $t0, $t1
	sw $t1, 2704($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 792($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 756($sp)
	lw $t0, 756($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 348($sp)
	lw $t0, 792($sp)
	lw $t1, 348($sp)
	add $t1, $t0, $t1
	sw $t1, 1264($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 948($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t0, 276($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1080($sp)
	lw $t0, 948($sp)
	lw $t1, 1080($sp)
	add $t1, $t0, $t1
	sw $t1, 2992($sp)
	lw $t0, 1264($sp)
	lw $t1, 2992($sp)
	sub $t1, $t0, $t1
	sw $t1, 652($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1352($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2948($sp)
	lw $t0, 2948($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1324($sp)
	lw $t0, 1352($sp)
	lw $t1, 1324($sp)
	add $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1672($sp)
	lw $t0, 268($sp)
	lw $t1, 1672($sp)
	sub $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, 652($sp)
	lw $t1, 324($sp)
	sub $t1, $t0, $t1
	sw $t1, 1472($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1148($sp)
	lw $t0, 1148($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1524($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2212($sp)
	lw $t0, 1524($sp)
	lw $t1, 2212($sp)
	sub $t1, $t0, $t1
	sw $t1, 732($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2252($sp)
	lw $t0, 2252($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2088($sp)
	lw $t0, 732($sp)
	lw $t1, 2088($sp)
	add $t1, $t0, $t1
	sw $t1, 336($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 728($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1272($sp)
	lw $t0, 1272($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1508($sp)
	lw $t0, 728($sp)
	lw $t1, 1508($sp)
	add $t1, $t0, $t1
	sw $t1, 2956($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3100($sp)
	lw $t0, 2956($sp)
	lw $t1, 3100($sp)
	sub $t1, $t0, $t1
	sw $t1, 1444($sp)
	lw $t0, 336($sp)
	lw $t1, 1444($sp)
	sub $t1, $t0, $t1
	sw $t1, 1276($sp)
	lw $t0, 1472($sp)
	lw $t1, 1276($sp)
	add $t1, $t0, $t1
	sw $t1, 940($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2152($sp)
	lw $t0, 2152($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1436($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3152($sp)
	lw $t0, 1436($sp)
	lw $t1, 3152($sp)
	sub $t1, $t0, $t1
	sw $t1, 396($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3188($sp)
	lw $t0, 3188($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1040($sp)
	lw $t0, 396($sp)
	lw $t1, 1040($sp)
	add $t1, $t0, $t1
	sw $t1, 3160($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2108($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, 256($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2540($sp)
	lw $t0, 2108($sp)
	lw $t1, 2540($sp)
	add $t1, $t0, $t1
	sw $t1, 2884($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2136($sp)
	lw $t0, 2884($sp)
	lw $t1, 2136($sp)
	sub $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, 3160($sp)
	lw $t1, 384($sp)
	sub $t1, $t0, $t1
	sw $t1, 372($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 884($sp)
	lw $t0, 884($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1688($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 588($sp)
	lw $t0, 1688($sp)
	lw $t1, 588($sp)
	sub $t1, $t0, $t1
	sw $t1, 2424($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 888($sp)
	lw $t0, 888($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2904($sp)
	lw $t0, 2424($sp)
	lw $t1, 2904($sp)
	add $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 632($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 800($sp)
	lw $t0, 800($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 788($sp)
	lw $t0, 632($sp)
	lw $t1, 788($sp)
	add $t1, $t0, $t1
	sw $t1, 836($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2896($sp)
	lw $t0, 836($sp)
	lw $t1, 2896($sp)
	sub $t1, $t0, $t1
	sw $t1, 1260($sp)
	lw $t0, 236($sp)
	lw $t1, 1260($sp)
	sub $t1, $t0, $t1
	sw $t1, 2352($sp)
	lw $t0, 372($sp)
	lw $t1, 2352($sp)
	add $t1, $t0, $t1
	sw $t1, 436($sp)
	lw $t0, 940($sp)
	lw $t1, 436($sp)
	add $t1, $t0, $t1
	sw $t1, 580($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1384($sp)
	lw $t0, 1384($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2428($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1952($sp)
	lw $t0, 2428($sp)
	lw $t1, 1952($sp)
	sub $t1, $t0, $t1
	sw $t1, 1152($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1968($sp)
	lw $t0, 1968($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2320($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1908($sp)
	lw $t0, 2320($sp)
	lw $t1, 1908($sp)
	sub $t1, $t0, $t1
	sw $t1, 1984($sp)
	lw $t0, 1152($sp)
	lw $t1, 1984($sp)
	add $t1, $t0, $t1
	sw $t1, 1208($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1528($sp)
	lw $t0, 1528($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 564($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1420($sp)
	lw $t0, 564($sp)
	lw $t1, 1420($sp)
	sub $t1, $t0, $t1
	sw $t1, 2020($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2328($sp)
	lw $t0, 2328($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1432($sp)
	lw $t0, 2020($sp)
	lw $t1, 1432($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t0, 1208($sp)
	lw $t1, 228($sp)
	add $t1, $t0, $t1
	sw $t1, 1076($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2308($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1748($sp)
	lw $t0, 1748($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 752($sp)
	lw $t0, 2308($sp)
	lw $t1, 752($sp)
	add $t1, $t0, $t1
	sw $t1, 1332($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1680($sp)
	lw $t0, 1332($sp)
	lw $t1, 1680($sp)
	sub $t1, $t0, $t1
	sw $t1, 612($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2628($sp)
	lw $t0, 2628($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2828($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1408($sp)
	lw $t0, 2828($sp)
	lw $t1, 1408($sp)
	sub $t1, $t0, $t1
	sw $t1, 1648($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2700($sp)
	lw $t0, 2700($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3208($sp)
	lw $t0, 1648($sp)
	lw $t1, 3208($sp)
	add $t1, $t0, $t1
	sw $t1, 1360($sp)
	lw $t0, 612($sp)
	lw $t1, 1360($sp)
	add $t1, $t0, $t1
	sw $t1, 1500($sp)
	lw $t0, 1076($sp)
	lw $t1, 1500($sp)
	sub $t1, $t0, $t1
	sw $t1, 1620($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2916($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1204($sp)
	lw $t0, 1204($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2792($sp)
	lw $t0, 2916($sp)
	lw $t1, 2792($sp)
	add $t1, $t0, $t1
	sw $t1, 944($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1916($sp)
	lw $t0, 944($sp)
	lw $t1, 1916($sp)
	sub $t1, $t0, $t1
	sw $t1, 2856($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3056($sp)
	lw $t0, 3056($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1344($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1532($sp)
	lw $t0, 1344($sp)
	lw $t1, 1532($sp)
	sub $t1, $t0, $t1
	sw $t1, 2312($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2808($sp)
	lw $t0, 2312($sp)
	lw $t1, 2808($sp)
	add $t1, $t0, $t1
	sw $t1, 1628($sp)
	lw $t0, 2856($sp)
	lw $t1, 1628($sp)
	add $t1, $t0, $t1
	sw $t1, 1380($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2680($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1636($sp)
	lw $t0, 1636($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1304($sp)
	lw $t0, 2680($sp)
	lw $t1, 1304($sp)
	add $t1, $t0, $t1
	sw $t1, 920($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1504($sp)
	lw $t0, 920($sp)
	lw $t1, 1504($sp)
	sub $t1, $t0, $t1
	sw $t1, 308($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2008($sp)
	lw $t0, 2008($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1744($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 892($sp)
	lw $t0, 1744($sp)
	lw $t1, 892($sp)
	sub $t1, $t0, $t1
	sw $t1, 1852($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2340($sp)
	lw $t0, 2340($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 616($sp)
	lw $t0, 1852($sp)
	lw $t1, 616($sp)
	add $t1, $t0, $t1
	sw $t1, 3112($sp)
	lw $t0, 308($sp)
	lw $t1, 3112($sp)
	add $t1, $t0, $t1
	sw $t1, 3124($sp)
	lw $t0, 1380($sp)
	lw $t1, 3124($sp)
	sub $t1, $t0, $t1
	sw $t1, 284($sp)
	lw $t0, 1620($sp)
	lw $t1, 284($sp)
	sub $t1, $t0, $t1
	sw $t1, 2256($sp)
	lw $t0, 580($sp)
	lw $t1, 2256($sp)
	add $t1, $t0, $t1
	sw $t1, 1288($sp)
	lw $t0, 2704($sp)
	lw $t1, 1288($sp)
	sub $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, 168($sp)
	sw $t0, global_588
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1512($sp)
	lw $t0, 1512($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2024($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 2024($sp)
	lw $t1, 160($sp)
	sub $t1, $t0, $t1
	sw $t1, 1608($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1216($sp)
	lw $t0, 1216($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1316($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1200($sp)
	lw $t0, 1316($sp)
	lw $t1, 1200($sp)
	sub $t1, $t0, $t1
	sw $t1, 2172($sp)
	lw $t0, 1608($sp)
	lw $t1, 2172($sp)
	add $t1, $t0, $t1
	sw $t1, 960($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2764($sp)
	lw $t0, 2764($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1988($sp)
	lw $t0, 232($sp)
	lw $t1, 1988($sp)
	sub $t1, $t0, $t1
	sw $t1, 2524($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2880($sp)
	lw $t0, 2880($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1156($sp)
	lw $t0, 2524($sp)
	lw $t1, 1156($sp)
	add $t1, $t0, $t1
	sw $t1, 2692($sp)
	lw $t0, 960($sp)
	lw $t1, 2692($sp)
	add $t1, $t0, $t1
	sw $t1, 2156($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2448($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1016($sp)
	lw $t0, 1016($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3064($sp)
	lw $t0, 2448($sp)
	lw $t1, 3064($sp)
	add $t1, $t0, $t1
	sw $t1, 316($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1144($sp)
	lw $t0, 316($sp)
	lw $t1, 1144($sp)
	sub $t1, $t0, $t1
	sw $t1, 1740($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1848($sp)
	lw $t0, 1848($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 584($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 840($sp)
	lw $t0, 584($sp)
	lw $t1, 840($sp)
	sub $t1, $t0, $t1
	sw $t1, 3068($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 628($sp)
	lw $t0, 628($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 592($sp)
	lw $t0, 3068($sp)
	lw $t1, 592($sp)
	add $t1, $t0, $t1
	sw $t1, 1880($sp)
	lw $t0, 1740($sp)
	lw $t1, 1880($sp)
	add $t1, $t0, $t1
	sw $t1, 2584($sp)
	lw $t0, 2156($sp)
	lw $t1, 2584($sp)
	sub $t1, $t0, $t1
	sw $t1, 2032($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2608($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2588($sp)
	lw $t0, 2588($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1340($sp)
	lw $t0, 2608($sp)
	lw $t1, 1340($sp)
	add $t1, $t0, $t1
	sw $t1, 1356($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 644($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3048($sp)
	lw $t0, 3048($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3084($sp)
	lw $t0, 644($sp)
	lw $t1, 3084($sp)
	add $t1, $t0, $t1
	sw $t1, 1036($sp)
	lw $t0, 1356($sp)
	lw $t1, 1036($sp)
	sub $t1, $t0, $t1
	sw $t1, 2952($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2384($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2128($sp)
	lw $t0, 2128($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2404($sp)
	lw $t0, 2384($sp)
	lw $t1, 2404($sp)
	add $t1, $t0, $t1
	sw $t1, 2648($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 520($sp)
	lw $t0, 2648($sp)
	lw $t1, 520($sp)
	sub $t1, $t0, $t1
	sw $t1, 548($sp)
	lw $t0, 2952($sp)
	lw $t1, 548($sp)
	sub $t1, $t0, $t1
	sw $t1, 2944($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3136($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1196($sp)
	lw $t0, 3136($sp)
	lw $t1, 1196($sp)
	sub $t1, $t0, $t1
	sw $t1, 2296($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2280($sp)
	lw $t0, 2296($sp)
	lw $t1, 2280($sp)
	add $t1, $t0, $t1
	sw $t1, 1516($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 464($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 748($sp)
	lw $t0, 748($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1480($sp)
	lw $t0, 464($sp)
	lw $t1, 1480($sp)
	add $t1, $t0, $t1
	sw $t1, 1348($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1800($sp)
	lw $t0, 1348($sp)
	lw $t1, 1800($sp)
	sub $t1, $t0, $t1
	sw $t1, 1996($sp)
	lw $t0, 1516($sp)
	lw $t1, 1996($sp)
	sub $t1, $t0, $t1
	sw $t1, 1752($sp)
	lw $t0, 2944($sp)
	lw $t1, 1752($sp)
	add $t1, $t0, $t1
	sw $t1, 1008($sp)
	lw $t0, 2032($sp)
	lw $t1, 1008($sp)
	sub $t1, $t0, $t1
	sw $t1, 1176($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1220($sp)
	lw $t0, 1220($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 704($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2232($sp)
	lw $t0, 704($sp)
	lw $t1, 2232($sp)
	sub $t1, $t0, $t1
	sw $t1, 3128($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 976($sp)
	lw $t0, 976($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1732($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1604($sp)
	lw $t0, 1732($sp)
	lw $t1, 1604($sp)
	sub $t1, $t0, $t1
	sw $t1, 2912($sp)
	lw $t0, 3128($sp)
	lw $t1, 2912($sp)
	add $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2332($sp)
	lw $t0, 2332($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 716($sp)
	lw $t0, 300($sp)
	lw $t1, 716($sp)
	sub $t1, $t0, $t1
	sw $t1, 2616($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 672($sp)
	lw $t0, 672($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3076($sp)
	lw $t0, 2616($sp)
	lw $t1, 3076($sp)
	add $t1, $t0, $t1
	sw $t1, 2636($sp)
	lw $t0, 344($sp)
	lw $t1, 2636($sp)
	add $t1, $t0, $t1
	sw $t1, 2472($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2412($sp)
	lw $t0, 2412($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2504($sp)
	lw $t0, 152($sp)
	lw $t1, 2504($sp)
	add $t1, $t0, $t1
	sw $t1, 1064($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2216($sp)
	lw $t0, 1064($sp)
	lw $t1, 2216($sp)
	sub $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2400($sp)
	lw $t0, 2400($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 392($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2200($sp)
	lw $t0, 392($sp)
	lw $t1, 2200($sp)
	sub $t1, $t0, $t1
	sw $t1, 596($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2144($sp)
	lw $t0, 2144($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1976($sp)
	lw $t0, 596($sp)
	lw $t1, 1976($sp)
	add $t1, $t0, $t1
	sw $t1, 736($sp)
	lw $t0, 404($sp)
	lw $t1, 736($sp)
	add $t1, $t0, $t1
	sw $t1, 1792($sp)
	lw $t0, 2472($sp)
	lw $t1, 1792($sp)
	sub $t1, $t0, $t1
	sw $t1, 996($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1980($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2436($sp)
	lw $t0, 2436($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 444($sp)
	lw $t0, 1980($sp)
	lw $t1, 444($sp)
	add $t1, $t0, $t1
	sw $t1, 1676($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3024($sp)
	lw $t0, 1676($sp)
	lw $t1, 3024($sp)
	sub $t1, $t0, $t1
	sw $t1, 1776($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1548($sp)
	lw $t0, 1548($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2168($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2728($sp)
	lw $t0, 2168($sp)
	lw $t1, 2728($sp)
	sub $t1, $t0, $t1
	sw $t1, 1780($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 764($sp)
	lw $t0, 764($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1560($sp)
	lw $t0, 1780($sp)
	lw $t1, 1560($sp)
	add $t1, $t0, $t1
	sw $t1, 1764($sp)
	lw $t0, 1776($sp)
	lw $t1, 1764($sp)
	add $t1, $t0, $t1
	sw $t1, 804($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2148($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2760($sp)
	lw $t0, 2760($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1012($sp)
	lw $t0, 2148($sp)
	lw $t1, 1012($sp)
	add $t1, $t0, $t1
	sw $t1, 3020($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 3020($sp)
	lw $t1, 132($sp)
	sub $t1, $t0, $t1
	sw $t1, 2820($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 636($sp)
	lw $t0, 636($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1452($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2996($sp)
	lw $t0, 1452($sp)
	lw $t1, 2996($sp)
	sub $t1, $t0, $t1
	sw $t1, 1768($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 956($sp)
	lw $t0, 956($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1092($sp)
	lw $t0, 1768($sp)
	lw $t1, 1092($sp)
	add $t1, $t0, $t1
	sw $t1, 852($sp)
	lw $t0, 2820($sp)
	lw $t1, 852($sp)
	add $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, 804($sp)
	lw $t1, 432($sp)
	sub $t1, $t0, $t1
	sw $t1, 712($sp)
	lw $t0, 996($sp)
	lw $t1, 712($sp)
	sub $t1, $t0, $t1
	sw $t1, 2120($sp)
	lw $t0, 1176($sp)
	lw $t1, 2120($sp)
	add $t1, $t0, $t1
	sw $t1, 2228($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1576($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1024($sp)
	lw $t0, 1024($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3052($sp)
	lw $t0, 1576($sp)
	lw $t1, 3052($sp)
	add $t1, $t0, $t1
	sw $t1, 2140($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1404($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2620($sp)
	lw $t0, 2620($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1632($sp)
	lw $t0, 1404($sp)
	lw $t1, 1632($sp)
	add $t1, $t0, $t1
	sw $t1, 1492($sp)
	lw $t0, 2140($sp)
	lw $t1, 1492($sp)
	sub $t1, $t0, $t1
	sw $t1, 532($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 424($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2736($sp)
	lw $t0, 2736($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1412($sp)
	lw $t0, 424($sp)
	lw $t1, 1412($sp)
	add $t1, $t0, $t1
	sw $t1, 400($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3092($sp)
	lw $t0, 400($sp)
	lw $t1, 3092($sp)
	sub $t1, $t0, $t1
	sw $t1, 932($sp)
	lw $t0, 532($sp)
	lw $t1, 932($sp)
	sub $t1, $t0, $t1
	sw $t1, 3108($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3180($sp)
	lw $t0, 3180($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2304($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3060($sp)
	lw $t0, 2304($sp)
	lw $t1, 3060($sp)
	sub $t1, $t0, $t1
	sw $t1, 2012($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2100($sp)
	lw $t0, 2100($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2284($sp)
	lw $t0, 2012($sp)
	lw $t1, 2284($sp)
	add $t1, $t0, $t1
	sw $t1, 2508($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1468($sp)
	lw $t0, 1468($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1056($sp)
	lw $t0, 184($sp)
	lw $t1, 1056($sp)
	add $t1, $t0, $t1
	sw $t1, 1552($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 556($sp)
	lw $t0, 1552($sp)
	lw $t1, 556($sp)
	sub $t1, $t0, $t1
	sw $t1, 488($sp)
	lw $t0, 2508($sp)
	lw $t1, 488($sp)
	sub $t1, $t0, $t1
	sw $t1, 1832($sp)
	lw $t0, 3108($sp)
	lw $t1, 1832($sp)
	add $t1, $t0, $t1
	sw $t1, 2632($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2072($sp)
	lw $t0, 2072($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2164($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2732($sp)
	lw $t0, 2164($sp)
	lw $t1, 2732($sp)
	sub $t1, $t0, $t1
	sw $t1, 1172($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 768($sp)
	lw $t0, 768($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1124($sp)
	lw $t0, 1172($sp)
	lw $t1, 1124($sp)
	add $t1, $t0, $t1
	sw $t1, 2748($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1028($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1836($sp)
	lw $t0, 1836($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3200($sp)
	lw $t0, 1028($sp)
	lw $t1, 3200($sp)
	add $t1, $t0, $t1
	sw $t1, 1708($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2560($sp)
	lw $t0, 1708($sp)
	lw $t1, 2560($sp)
	sub $t1, $t0, $t1
	sw $t1, 1904($sp)
	lw $t0, 2748($sp)
	lw $t1, 1904($sp)
	sub $t1, $t0, $t1
	sw $t1, 2652($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2804($sp)
	lw $t0, 2804($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2720($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1424($sp)
	lw $t0, 2720($sp)
	lw $t1, 1424($sp)
	sub $t1, $t0, $t1
	sw $t1, 1396($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2624($sp)
	lw $t0, 2624($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1084($sp)
	lw $t0, 1396($sp)
	lw $t1, 1084($sp)
	add $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2908($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1460($sp)
	lw $t0, 1460($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2776($sp)
	lw $t0, 2908($sp)
	lw $t1, 2776($sp)
	add $t1, $t0, $t1
	sw $t1, 2528($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 496($sp)
	lw $t0, 2528($sp)
	lw $t1, 496($sp)
	sub $t1, $t0, $t1
	sw $t1, 2500($sp)
	lw $t0, 240($sp)
	lw $t1, 2500($sp)
	sub $t1, $t0, $t1
	sw $t1, 2924($sp)
	lw $t0, 2652($sp)
	lw $t1, 2924($sp)
	add $t1, $t0, $t1
	sw $t1, 1108($sp)
	lw $t0, 2632($sp)
	lw $t1, 1108($sp)
	add $t1, $t0, $t1
	sw $t1, 2388($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2548($sp)
	lw $t0, 2548($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 680($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 688($sp)
	lw $t0, 680($sp)
	lw $t1, 688($sp)
	sub $t1, $t0, $t1
	sw $t1, 1100($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2452($sp)
	lw $t0, 2452($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 560($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2968($sp)
	lw $t0, 560($sp)
	lw $t1, 2968($sp)
	sub $t1, $t0, $t1
	sw $t1, 1592($sp)
	lw $t0, 1100($sp)
	lw $t1, 1592($sp)
	add $t1, $t0, $t1
	sw $t1, 1520($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1212($sp)
	lw $t0, 1212($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2132($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 480($sp)
	lw $t0, 2132($sp)
	lw $t1, 480($sp)
	sub $t1, $t0, $t1
	sw $t1, 2660($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2004($sp)
	lw $t0, 2004($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 668($sp)
	lw $t0, 2660($sp)
	lw $t1, 668($sp)
	add $t1, $t0, $t1
	sw $t1, 2036($sp)
	lw $t0, 1520($sp)
	lw $t1, 2036($sp)
	add $t1, $t0, $t1
	sw $t1, 3172($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1720($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1652($sp)
	lw $t0, 1652($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2684($sp)
	lw $t0, 1720($sp)
	lw $t1, 2684($sp)
	add $t1, $t0, $t1
	sw $t1, 1136($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1872($sp)
	lw $t0, 1136($sp)
	lw $t1, 1872($sp)
	sub $t1, $t0, $t1
	sw $t1, 700($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1972($sp)
	lw $t0, 1972($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1104($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2892($sp)
	lw $t0, 1104($sp)
	lw $t1, 2892($sp)
	sub $t1, $t0, $t1
	sw $t1, 2688($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1416($sp)
	lw $t0, 1416($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2444($sp)
	lw $t0, 2688($sp)
	lw $t1, 2444($sp)
	add $t1, $t0, $t1
	sw $t1, 1928($sp)
	lw $t0, 700($sp)
	lw $t1, 1928($sp)
	add $t1, $t0, $t1
	sw $t1, 2488($sp)
	lw $t0, 3172($sp)
	lw $t1, 2488($sp)
	sub $t1, $t0, $t1
	sw $t1, 2844($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2676($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 524($sp)
	lw $t0, 524($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1240($sp)
	lw $t0, 2676($sp)
	lw $t1, 1240($sp)
	add $t1, $t0, $t1
	sw $t1, 500($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2224($sp)
	lw $t0, 500($sp)
	lw $t1, 2224($sp)
	sub $t1, $t0, $t1
	sw $t1, 720($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 420($sp)
	lw $t0, 420($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1756($sp)
	lw $t0, 136($sp)
	lw $t1, 1756($sp)
	sub $t1, $t0, $t1
	sw $t1, 3212($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2604($sp)
	lw $t0, 2604($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 760($sp)
	lw $t0, 3212($sp)
	lw $t1, 760($sp)
	add $t1, $t0, $t1
	sw $t1, 2712($sp)
	lw $t0, 720($sp)
	lw $t1, 2712($sp)
	add $t1, $t0, $t1
	sw $t1, 2068($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3028($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2408($sp)
	lw $t0, 2408($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 3028($sp)
	lw $t1, 128($sp)
	add $t1, $t0, $t1
	sw $t1, 656($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2456($sp)
	lw $t0, 656($sp)
	lw $t1, 2456($sp)
	sub $t1, $t0, $t1
	sw $t1, 2396($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 664($sp)
	lw $t0, 664($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 472($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 472($sp)
	lw $t1, 200($sp)
	sub $t1, $t0, $t1
	sw $t1, 3140($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 856($sp)
	lw $t0, 856($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2644($sp)
	lw $t0, 3140($sp)
	lw $t1, 2644($sp)
	add $t1, $t0, $t1
	sw $t1, 1876($sp)
	lw $t0, 2396($sp)
	lw $t1, 1876($sp)
	add $t1, $t0, $t1
	sw $t1, 1588($sp)
	lw $t0, 2068($sp)
	lw $t1, 1588($sp)
	sub $t1, $t0, $t1
	sw $t1, 492($sp)
	lw $t0, 2844($sp)
	lw $t1, 492($sp)
	sub $t1, $t0, $t1
	sw $t1, 1540($sp)
	lw $t0, 2388($sp)
	lw $t1, 1540($sp)
	add $t1, $t0, $t1
	sw $t1, 1816($sp)
	lw $t0, 2228($sp)
	lw $t1, 1816($sp)
	sub $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t0, 376($sp)
	sw $t0, global_589
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3000($sp)
	lw $t0, 3000($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1280($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2484($sp)
	lw $t0, 1280($sp)
	lw $t1, 2484($sp)
	sub $t1, $t0, $t1
	sw $t1, 2204($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 476($sp)
	lw $t0, 476($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3008($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1624($sp)
	lw $t0, 3008($sp)
	lw $t1, 1624($sp)
	sub $t1, $t0, $t1
	sw $t1, 1488($sp)
	lw $t0, 2204($sp)
	lw $t1, 1488($sp)
	add $t1, $t0, $t1
	sw $t1, 2104($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1448($sp)
	lw $t0, 1448($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1956($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1296($sp)
	lw $t0, 1956($sp)
	lw $t1, 1296($sp)
	sub $t1, $t0, $t1
	sw $t1, 2076($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1476($sp)
	lw $t0, 1476($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3144($sp)
	lw $t0, 2076($sp)
	lw $t1, 3144($sp)
	add $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t0, 2104($sp)
	lw $t1, 280($sp)
	add $t1, $t0, $t1
	sw $t1, 2656($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 468($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 536($sp)
	lw $t0, 536($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1128($sp)
	lw $t0, 468($sp)
	lw $t1, 1128($sp)
	add $t1, $t0, $t1
	sw $t1, 2492($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2188($sp)
	lw $t0, 2492($sp)
	lw $t1, 2188($sp)
	sub $t1, $t0, $t1
	sw $t1, 2708($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 924($sp)
	lw $t0, 924($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1584($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 828($sp)
	lw $t0, 1584($sp)
	lw $t1, 828($sp)
	sub $t1, $t0, $t1
	sw $t1, 1640($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2112($sp)
	lw $t0, 2112($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 796($sp)
	lw $t0, 1640($sp)
	lw $t1, 796($sp)
	add $t1, $t0, $t1
	sw $t1, 2416($sp)
	lw $t0, 2708($sp)
	lw $t1, 2416($sp)
	add $t1, $t0, $t1
	sw $t1, 2080($sp)
	lw $t0, 2656($sp)
	lw $t1, 2080($sp)
	sub $t1, $t0, $t1
	sw $t1, 2536($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 928($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2248($sp)
	lw $t0, 2248($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1020($sp)
	lw $t0, 928($sp)
	lw $t1, 1020($sp)
	add $t1, $t0, $t1
	sw $t1, 1644($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1068($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2392($sp)
	lw $t0, 2392($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2812($sp)
	lw $t0, 1068($sp)
	lw $t1, 2812($sp)
	add $t1, $t0, $t1
	sw $t1, 1388($sp)
	lw $t0, 1644($sp)
	lw $t1, 1388($sp)
	sub $t1, $t0, $t1
	sw $t1, 908($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1920($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2556($sp)
	lw $t0, 2556($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1428($sp)
	lw $t0, 1920($sp)
	lw $t1, 1428($sp)
	add $t1, $t0, $t1
	sw $t1, 3036($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 440($sp)
	lw $t0, 3036($sp)
	lw $t1, 440($sp)
	sub $t1, $t0, $t1
	sw $t1, 2244($sp)
	lw $t0, 908($sp)
	lw $t1, 2244($sp)
	sub $t1, $t0, $t1
	sw $t1, 2512($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 416($sp)
	lw $t0, 416($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2872($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 456($sp)
	lw $t0, 2872($sp)
	lw $t1, 456($sp)
	sub $t1, $t0, $t1
	sw $t1, 2836($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 972($sp)
	lw $t0, 972($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2516($sp)
	lw $t0, 2836($sp)
	lw $t1, 2516($sp)
	add $t1, $t0, $t1
	sw $t1, 1936($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2984($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2048($sp)
	lw $t0, 2048($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2672($sp)
	lw $t0, 2984($sp)
	lw $t1, 2672($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2752($sp)
	lw $t0, 208($sp)
	lw $t1, 2752($sp)
	sub $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 1936($sp)
	lw $t1, 368($sp)
	sub $t1, $t0, $t1
	sw $t1, 1912($sp)
	lw $t0, 2512($sp)
	lw $t1, 1912($sp)
	add $t1, $t0, $t1
	sw $t1, 2336($sp)
	lw $t0, 2536($sp)
	lw $t1, 2336($sp)
	sub $t1, $t0, $t1
	sw $t1, 2900($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1660($sp)
	lw $t0, 1660($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2888($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 552($sp)
	lw $t0, 2888($sp)
	lw $t1, 552($sp)
	sub $t1, $t0, $t1
	sw $t1, 2176($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2260($sp)
	lw $t0, 2260($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1312($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2988($sp)
	lw $t0, 1312($sp)
	lw $t1, 2988($sp)
	sub $t1, $t0, $t1
	sw $t1, 460($sp)
	lw $t0, 2176($sp)
	lw $t1, 460($sp)
	add $t1, $t0, $t1
	sw $t1, 388($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3192($sp)
	lw $t0, 3192($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1856($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 772($sp)
	lw $t0, 1856($sp)
	lw $t1, 772($sp)
	sub $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2040($sp)
	lw $t0, 2040($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1704($sp)
	lw $t0, 156($sp)
	lw $t1, 1704($sp)
	add $t1, $t0, $t1
	sw $t1, 2596($sp)
	lw $t0, 388($sp)
	lw $t1, 2596($sp)
	add $t1, $t0, $t1
	sw $t1, 3120($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1000($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 648($sp)
	lw $t0, 648($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1568($sp)
	lw $t0, 1000($sp)
	lw $t1, 1568($sp)
	add $t1, $t0, $t1
	sw $t1, 1244($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1544($sp)
	lw $t0, 1244($sp)
	lw $t1, 1544($sp)
	sub $t1, $t0, $t1
	sw $t1, 3148($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1888($sp)
	lw $t0, 1888($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2092($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2420($sp)
	lw $t0, 2092($sp)
	lw $t1, 2420($sp)
	sub $t1, $t0, $t1
	sw $t1, 528($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 312($sp)
	lw $t0, 312($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1716($sp)
	lw $t0, 528($sp)
	lw $t1, 1716($sp)
	add $t1, $t0, $t1
	sw $t1, 2740($sp)
	lw $t0, 3148($sp)
	lw $t1, 2740($sp)
	add $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, 3120($sp)
	lw $t1, 356($sp)
	sub $t1, $t0, $t1
	sw $t1, 3132($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 676($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 620($sp)
	lw $t0, 620($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1252($sp)
	lw $t0, 676($sp)
	lw $t1, 1252($sp)
	add $t1, $t0, $t1
	sw $t1, 872($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1828($sp)
	lw $t0, 872($sp)
	lw $t1, 1828($sp)
	sub $t1, $t0, $t1
	sw $t1, 2564($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1844($sp)
	lw $t0, 1844($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 576($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1696($sp)
	lw $t0, 576($sp)
	lw $t1, 1696($sp)
	sub $t1, $t0, $t1
	sw $t1, 3032($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1556($sp)
	lw $t0, 1556($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3116($sp)
	lw $t0, 3032($sp)
	lw $t1, 3116($sp)
	add $t1, $t0, $t1
	sw $t1, 1284($sp)
	lw $t0, 2564($sp)
	lw $t1, 1284($sp)
	add $t1, $t0, $t1
	sw $t1, 968($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2368($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 544($sp)
	lw $t0, 544($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 980($sp)
	lw $t0, 2368($sp)
	lw $t1, 980($sp)
	add $t1, $t0, $t1
	sw $t1, 1736($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1564($sp)
	lw $t0, 1736($sp)
	lw $t1, 1564($sp)
	sub $t1, $t0, $t1
	sw $t1, 1784($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2772($sp)
	lw $t0, 2772($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3016($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 540($sp)
	lw $t0, 3016($sp)
	lw $t1, 540($sp)
	sub $t1, $t0, $t1
	sw $t1, 740($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 332($sp)
	lw $t0, 332($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 508($sp)
	lw $t0, 740($sp)
	lw $t1, 508($sp)
	add $t1, $t0, $t1
	sw $t1, 1612($sp)
	lw $t0, 1784($sp)
	lw $t1, 1612($sp)
	add $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, 968($sp)
	lw $t1, 220($sp)
	sub $t1, $t0, $t1
	sw $t1, 2084($sp)
	lw $t0, 3132($sp)
	lw $t1, 2084($sp)
	sub $t1, $t0, $t1
	sw $t1, 2356($sp)
	lw $t0, 2900($sp)
	lw $t1, 2356($sp)
	add $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2016($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1392($sp)
	lw $t0, 1392($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1860($sp)
	lw $t0, 2016($sp)
	lw $t1, 1860($sp)
	add $t1, $t0, $t1
	sw $t1, 900($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2460($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1804($sp)
	lw $t0, 2460($sp)
	lw $t1, 1804($sp)
	add $t1, $t0, $t1
	sw $t1, 640($sp)
	lw $t0, 900($sp)
	lw $t1, 640($sp)
	sub $t1, $t0, $t1
	sw $t1, 1944($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2980($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2376($sp)
	lw $t0, 2376($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1308($sp)
	lw $t0, 2980($sp)
	lw $t1, 1308($sp)
	add $t1, $t0, $t1
	sw $t1, 1760($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3096($sp)
	lw $t0, 1760($sp)
	lw $t1, 3096($sp)
	sub $t1, $t0, $t1
	sw $t1, 2160($sp)
	lw $t0, 1944($sp)
	lw $t1, 2160($sp)
	sub $t1, $t0, $t1
	sw $t1, 624($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2316($sp)
	lw $t0, 2316($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1788($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 844($sp)
	lw $t0, 1788($sp)
	lw $t1, 844($sp)
	sub $t1, $t0, $t1
	sw $t1, 1724($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, 360($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2716($sp)
	lw $t0, 1724($sp)
	lw $t1, 2716($sp)
	add $t1, $t0, $t1
	sw $t1, 2220($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2768($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2860($sp)
	lw $t0, 2860($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 2768($sp)
	lw $t1, 272($sp)
	add $t1, $t0, $t1
	sw $t1, 2288($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1440($sp)
	lw $t0, 2288($sp)
	lw $t1, 1440($sp)
	sub $t1, $t0, $t1
	sw $t1, 2532($sp)
	lw $t0, 2220($sp)
	lw $t1, 2532($sp)
	sub $t1, $t0, $t1
	sw $t1, 952($sp)
	lw $t0, 624($sp)
	lw $t1, 952($sp)
	add $t1, $t0, $t1
	sw $t1, 2028($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t0, 260($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1400($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2360($sp)
	lw $t0, 1400($sp)
	lw $t1, 2360($sp)
	sub $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1808($sp)
	lw $t0, 1808($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1580($sp)
	lw $t0, 248($sp)
	lw $t1, 1580($sp)
	add $t1, $t0, $t1
	sw $t1, 484($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1096($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2124($sp)
	lw $t0, 2124($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2496($sp)
	lw $t0, 1096($sp)
	lw $t1, 2496($sp)
	add $t1, $t0, $t1
	sw $t1, 2932($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2300($sp)
	lw $t0, 2932($sp)
	lw $t1, 2300($sp)
	sub $t1, $t0, $t1
	sw $t1, 568($sp)
	lw $t0, 484($sp)
	lw $t1, 568($sp)
	sub $t1, $t0, $t1
	sw $t1, 3012($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2060($sp)
	lw $t0, 2060($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2576($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2832($sp)
	lw $t0, 2576($sp)
	lw $t1, 2832($sp)
	sub $t1, $t0, $t1
	sw $t1, 2236($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2640($sp)
	lw $t0, 2640($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1192($sp)
	lw $t0, 2236($sp)
	lw $t1, 1192($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1248($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1268($sp)
	lw $t0, 1268($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 1248($sp)
	lw $t1, 380($sp)
	add $t1, $t0, $t1
	sw $t1, 328($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1120($sp)
	lw $t0, 328($sp)
	lw $t1, 1120($sp)
	sub $t1, $t0, $t1
	sw $t1, 2744($sp)
	lw $t0, 196($sp)
	lw $t1, 2744($sp)
	sub $t1, $t0, $t1
	sw $t1, 1796($sp)
	lw $t0, 3012($sp)
	lw $t1, 1796($sp)
	add $t1, $t0, $t1
	sw $t1, 2372($sp)
	lw $t0, 2028($sp)
	lw $t1, 2372($sp)
	add $t1, $t0, $t1
	sw $t1, 2964($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t0, 364($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1336($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 988($sp)
	lw $t0, 1336($sp)
	lw $t1, 988($sp)
	sub $t1, $t0, $t1
	sw $t1, 1668($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3040($sp)
	lw $t0, 3040($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1164($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3196($sp)
	lw $t0, 1164($sp)
	lw $t1, 3196($sp)
	sub $t1, $t0, $t1
	sw $t1, 1236($sp)
	lw $t0, 1668($sp)
	lw $t1, 1236($sp)
	add $t1, $t0, $t1
	sw $t1, 936($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2972($sp)
	lw $t0, 2972($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1464($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2928($sp)
	lw $t0, 1464($sp)
	lw $t1, 2928($sp)
	sub $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 876($sp)
	lw $t0, 876($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3164($sp)
	lw $t0, 172($sp)
	lw $t1, 3164($sp)
	add $t1, $t0, $t1
	sw $t1, 820($sp)
	lw $t0, 936($sp)
	lw $t1, 820($sp)
	add $t1, $t0, $t1
	sw $t1, 2272($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 3072($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 244($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1924($sp)
	lw $t0, 3072($sp)
	lw $t1, 1924($sp)
	add $t1, $t0, $t1
	sw $t1, 2240($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1372($sp)
	lw $t0, 2240($sp)
	lw $t1, 1372($sp)
	sub $t1, $t0, $t1
	sw $t1, 660($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1884($sp)
	lw $t0, 1884($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1256($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1088($sp)
	lw $t0, 1256($sp)
	lw $t1, 1088($sp)
	sub $t1, $t0, $t1
	sw $t1, 1116($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2936($sp)
	lw $t0, 2936($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1572($sp)
	lw $t0, 1116($sp)
	lw $t1, 1572($sp)
	add $t1, $t0, $t1
	sw $t1, 2580($sp)
	lw $t0, 660($sp)
	lw $t1, 2580($sp)
	add $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 2272($sp)
	lw $t1, 288($sp)
	sub $t1, $t0, $t1
	sw $t1, 1536($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1180($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 180($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 408($sp)
	lw $t0, 1180($sp)
	lw $t1, 408($sp)
	add $t1, $t0, $t1
	sw $t1, 880($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 600($sp)
	lw $t0, 880($sp)
	lw $t1, 600($sp)
	sub $t1, $t0, $t1
	sw $t1, 744($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 1684($sp)
	lw $t0, 1684($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 684($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 816($sp)
	lw $t0, 684($sp)
	lw $t1, 816($sp)
	sub $t1, $t0, $t1
	sw $t1, 1188($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3168($sp)
	lw $t0, 3168($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2192($sp)
	lw $t0, 1188($sp)
	lw $t1, 2192($sp)
	add $t1, $t0, $t1
	sw $t1, 896($sp)
	lw $t0, 744($sp)
	lw $t1, 896($sp)
	add $t1, $t0, $t1
	sw $t1, 292($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2724($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 3104($sp)
	lw $t0, 3104($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2056($sp)
	lw $t0, 2724($sp)
	lw $t1, 2056($sp)
	add $t1, $t0, $t1
	sw $t1, 2064($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 2344($sp)
	lw $t0, 2064($sp)
	lw $t1, 2344($sp)
	sub $t1, $t0, $t1
	sw $t1, 512($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2572($sp)
	lw $t0, 2572($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1184($sp)
	lw $t0, global_588
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 696($sp)
	lw $t0, 1184($sp)
	lw $t1, 696($sp)
	sub $t1, $t0, $t1
	sw $t1, 1692($sp)
	lw $t0, global_590
	lw $t1, global_588
	sub $t1, $t0, $t1
	sw $t1, 2848($sp)
	lw $t0, 2848($sp)
	lw $t1, global_589
	add $t1, $t0, $t1
	sw $t1, 1932($sp)
	lw $t0, 1692($sp)
	lw $t1, 1932($sp)
	add $t1, $t0, $t1
	sw $t1, 1004($sp)
	lw $t0, 512($sp)
	lw $t1, 1004($sp)
	add $t1, $t0, $t1
	sw $t1, 2960($sp)
	lw $t0, 292($sp)
	lw $t1, 2960($sp)
	sub $t1, $t0, $t1
	sw $t1, 2780($sp)
	lw $t0, 1536($sp)
	lw $t1, 2780($sp)
	sub $t1, $t0, $t1
	sw $t1, 1044($sp)
	lw $t0, 2964($sp)
	lw $t1, 1044($sp)
	add $t1, $t0, $t1
	sw $t1, 2868($sp)
	lw $t0, 216($sp)
	lw $t1, 2868($sp)
	sub $t1, $t0, $t1
	sw $t1, 2464($sp)
	lw $t0, 2464($sp)
	sw $t0, global_590
	b _WhileLoop446
_OutOfWhile448:
	lw $a0, global_588
	jal func__toString
	sw $v0, 1900($sp)
	lw $a0, 1900($sp)
	la $a1, string_1357
	jal func__stringConcatenate
	sw $v0, 504($sp)
	lw $a0, global_589
	jal func__toString
	sw $v0, 340($sp)
	lw $a0, 504($sp)
	lw $a1, 340($sp)
	jal func__stringConcatenate
	sw $v0, 1320($sp)
	lw $a0, 1320($sp)
	la $a1, string_1361
	jal func__stringConcatenate
	sw $v0, 1896($sp)
	lw $a0, global_590
	jal func__toString
	sw $v0, 724($sp)
	lw $a0, 1896($sp)
	lw $a1, 724($sp)
	jal func__stringConcatenate
	sw $v0, 776($sp)
	lw $a0, 776($sp)
	jal func__println
	sw $v0, 192($sp)
	li $v0, 0
	b _EndOfFunctionDecl445
_EndOfFunctionDecl445:
	lw $ra, 120($sp)
	add $sp, $sp, 3216
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_588:
.space 4
.align 2
global_589:
.space 4
.align 2
global_590:
.space 4
.align 2
.word 1
string_1357:
.asciiz " "
.align 2
.word 1
string_1361:
.asciiz " "
.align 2
