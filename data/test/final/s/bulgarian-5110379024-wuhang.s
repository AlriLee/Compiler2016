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
_random:
	sub $sp, $sp, 160
	sw $ra, 120($sp)
_BeginOfFunctionDecl266:
	lw $t0, global_310
	lw $t1, global_308
	rem $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, global_306
	lw $t1, 144($sp)
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, global_310
	lw $t1, global_308
	div $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, global_309
	lw $t1, 140($sp)
	mul $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 148($sp)
	lw $t1, 128($sp)
	sub $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	sw $t0, 156($sp)
	lw $t0, 156($sp)
	li $t1, 0
	sge $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	beqz $t0, _alternative309
	b _consequence308
_consequence308:
	lw $t0, 156($sp)
	sw $t0, global_310
	b _OutOfIf310
_alternative309:
	lw $t0, 156($sp)
	lw $t1, global_307
	add $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_310
	b _OutOfIf310
_OutOfIf310:
	lw $v0, global_310
	b _EndOfFunctionDecl267
_EndOfFunctionDecl267:
	lw $ra, 120($sp)
	add $sp, $sp, 160
	jr $ra
_initialize:
	sub $sp, $sp, 132
	sw $ra, 120($sp)
_BeginOfFunctionDecl268:
	lw $t0, 128($sp)
	sw $t0, global_310
_EndOfFunctionDecl269:
	lw $ra, 120($sp)
	add $sp, $sp, 132
	jr $ra
_swap:
	sub $sp, $sp, 180
	sw $ra, 120($sp)
_BeginOfFunctionDecl270:
	lw $t0, 172($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, global_305
	lw $t1, 160($sp)
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t1, 144($sp)
	lw $t0, 0($t1)
	sw $t0, 136($sp)
	lw $t0, 136($sp)
	sw $t0, 148($sp)
	lw $t0, 172($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, global_305
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 176($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, global_305
	lw $t1, 132($sp)
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t1, 164($sp)
	lw $t0, 0($t1)
	sw $t0, 156($sp)
	lw $t0, 156($sp)
	lw $t1, 128($sp)
	sw $t0, 0($t1)
	lw $t0, 176($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, global_305
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 148($sp)
	lw $t1, 152($sp)
	sw $t0, 0($t1)
_EndOfFunctionDecl271:
	lw $ra, 120($sp)
	add $sp, $sp, 180
	jr $ra
_pd:
	sub $sp, $sp, 152
	sw $ra, 120($sp)
_BeginOfFunctionDecl272:
	b _ForLoop284
_ForLoop284:
	lw $t0, global_303
	lw $t1, 148($sp)
	sle $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	beqz $t0, _OutOfFor312
	b _ForBody311
_ForBody311:
	lw $t0, global_303
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_303
	lw $t1, 136($sp)
	mul $t1, $t0, $t1
	sw $t1, 132($sp)
	lw $t0, 132($sp)
	li $t1, 2
	div $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 148($sp)
	lw $t1, 128($sp)
	seq $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	beqz $t0, _alternative314
	b _consequence313
_consequence313:
	li $v0, 1
	b _EndOfFunctionDecl273
	b _OutOfIf315
_alternative314:
	b _OutOfIf315
_OutOfIf315:
	b _continueFor285
_continueFor285:
	lw $t0, global_303
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_303
	b _ForLoop284
_OutOfFor312:
	li $v0, 0
	b _EndOfFunctionDecl273
_EndOfFunctionDecl273:
	lw $ra, 120($sp)
	add $sp, $sp, 152
	jr $ra
_show:
	sub $sp, $sp, 172
	sw $ra, 120($sp)
_BeginOfFunctionDecl274:
	li $t0, 0
	sw $t0, 128($sp)
_ForLoop286:
	lw $t0, 128($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, 156($sp)
	beqz $t0, _OutOfFor317
	b _ForBody316
_ForBody316:
	lw $t0, 128($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_305
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t1, 160($sp)
	lw $t0, 0($t1)
	sw $t0, 164($sp)
	lw $a0, 164($sp)
	jal func__toString
	sw $v0, 168($sp)
	lw $a0, 168($sp)
	la $a1, string_361
	jal func__stringConcatenate
	sw $v0, 132($sp)
	lw $a0, 132($sp)
	jal func__print
	sw $v0, 140($sp)
_continueFor287:
	lw $t0, 128($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	b _ForLoop286
_OutOfFor317:
	la $a0, string_364
	jal func__println
	sw $v0, 144($sp)
_EndOfFunctionDecl275:
	lw $ra, 120($sp)
	add $sp, $sp, 172
	jr $ra
_win:
	sub $sp, $sp, 292
	sw $ra, 120($sp)
_BeginOfFunctionDecl276:
	li $t0, 100
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
	sw $v0, 160($sp)
	li $t0, 100
	lw $t1, 160($sp)
	sw $t0, 0($t1)
	lw $t0, 160($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	sw $t0, 156($sp)
	lw $t0, 156($sp)
	sw $t0, 188($sp)
	lw $t0, global_304
	lw $t1, global_303
	sne $t1, $t0, $t1
	sw $t1, 244($sp)
	lw $t0, 244($sp)
	beqz $t0, _alternative319
	b _consequence318
_consequence318:
	li $v0, 0
	b _EndOfFunctionDecl277
	b _OutOfIf320
_alternative319:
	b _OutOfIf320
_OutOfIf320:
	li $t0, 0
	sw $t0, 216($sp)
_ForLoop288:
	lw $t0, 216($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 208($sp)
	lw $t0, 208($sp)
	beqz $t0, _OutOfFor322
	b _ForBody321
_ForBody321:
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, 188($sp)
	lw $t1, 220($sp)
	add $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t0, global_305
	lw $t1, 224($sp)
	add $t1, $t0, $t1
	sw $t1, 260($sp)
	lw $t1, 260($sp)
	lw $t0, 0($t1)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	lw $t1, 272($sp)
	sw $t0, 0($t1)
_continueFor289:
	lw $t0, 216($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 216($sp)
	b _ForLoop288
_OutOfFor322:
	li $t0, 0
	sw $t0, 140($sp)
_ForLoop290:
	lw $t0, global_304
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 140($sp)
	lw $t1, 176($sp)
	slt $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, 248($sp)
	beqz $t0, _OutOfFor324
	b _ForBody323
_ForBody323:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 268($sp)
	lw $t0, 268($sp)
	sw $t0, 216($sp)
_ForLoop292:
	lw $t0, 216($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 232($sp)
	beqz $t0, _OutOfFor326
	b _ForBody325
_ForBody325:
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 188($sp)
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 188($sp)
	lw $t1, 172($sp)
	add $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t1, 164($sp)
	lw $t0, 0($t1)
	sw $t0, 128($sp)
	lw $t1, 256($sp)
	lw $t0, 0($t1)
	sw $t0, 196($sp)
	lw $t0, 128($sp)
	lw $t1, 196($sp)
	sgt $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 240($sp)
	beqz $t0, _alternative328
	b _consequence327
_consequence327:
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 276($sp)
	lw $t0, 188($sp)
	lw $t1, 276($sp)
	add $t1, $t0, $t1
	sw $t1, 228($sp)
	lw $t1, 228($sp)
	lw $t0, 0($t1)
	sw $t0, 192($sp)
	lw $t0, 192($sp)
	sw $t0, 132($sp)
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 188($sp)
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 188($sp)
	lw $t1, 184($sp)
	add $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t1, 200($sp)
	lw $t0, 0($t1)
	sw $t0, 204($sp)
	lw $t0, 204($sp)
	lw $t1, 264($sp)
	sw $t0, 0($t1)
	lw $t0, 216($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 188($sp)
	lw $t1, 288($sp)
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 132($sp)
	lw $t1, 148($sp)
	sw $t0, 0($t1)
	b _OutOfIf329
_alternative328:
	b _OutOfIf329
_OutOfIf329:
	b _continueFor293
_continueFor293:
	lw $t0, 216($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 216($sp)
	b _ForLoop292
_OutOfFor326:
	b _continueFor291
_continueFor291:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	b _ForLoop290
_OutOfFor324:
	li $t0, 0
	sw $t0, 140($sp)
_ForLoop294:
	lw $t0, 140($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 212($sp)
	beqz $t0, _OutOfFor331
	b _ForBody330
_ForBody330:
	lw $t0, 140($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 188($sp)
	lw $t1, 252($sp)
	add $t1, $t0, $t1
	sw $t1, 280($sp)
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t1, 280($sp)
	lw $t0, 0($t1)
	sw $t0, 284($sp)
	lw $t0, 284($sp)
	lw $t1, 152($sp)
	sne $t1, $t0, $t1
	sw $t1, 236($sp)
	lw $t0, 236($sp)
	beqz $t0, _alternative333
	b _consequence332
_consequence332:
	li $v0, 0
	b _EndOfFunctionDecl277
	b _OutOfIf334
_alternative333:
	b _OutOfIf334
_OutOfIf334:
	b _continueFor295
_continueFor295:
	lw $t0, 140($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 140($sp)
	b _ForLoop294
_OutOfFor331:
	li $v0, 1
	b _EndOfFunctionDecl277
_EndOfFunctionDecl277:
	lw $ra, 120($sp)
	add $sp, $sp, 292
	jr $ra
_merge:
	sub $sp, $sp, 204
	sw $ra, 120($sp)
_BeginOfFunctionDecl278:
	li $t0, 0
	sw $t0, 160($sp)
_ForLoop296:
	lw $t0, 160($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 176($sp)
	lw $t0, 176($sp)
	beqz $t0, _OutOfFor336
	b _ForBody335
_ForBody335:
	lw $t0, 160($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, global_305
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t1, 136($sp)
	lw $t0, 0($t1)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t0, 192($sp)
	beqz $t0, _alternative338
	b _consequence337
_consequence337:
	lw $t0, 160($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t0, 128($sp)
	sw $t0, 148($sp)
_ForLoop298:
	lw $t0, 148($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, 196($sp)
	beqz $t0, _OutOfFor341
	b _ForBody340
_ForBody340:
	lw $t0, 148($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
	lw $t0, global_305
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t1, 184($sp)
	lw $t0, 0($t1)
	sw $t0, 140($sp)
	lw $t0, 140($sp)
	li $t1, 0
	sne $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	beqz $t0, _alternative343
	b _consequence342
_consequence342:
	lw $t0, 160($sp)
	sw $t0, -8($sp)
	lw $t0, 148($sp)
	sw $t0, -4($sp)
	jal _swap
	sw $v0, 132($sp)
	b _OutOfFor341
	b _OutOfIf344
_alternative343:
	b _OutOfIf344
_OutOfIf344:
	b _continueFor299
_continueFor299:
	lw $t0, 148($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 148($sp)
	b _ForLoop298
_OutOfFor341:
	b _OutOfIf339
_alternative338:
	b _OutOfIf339
_OutOfIf339:
	b _continueFor297
_continueFor297:
	lw $t0, 160($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	b _ForLoop296
_OutOfFor336:
	li $t0, 0
	sw $t0, 160($sp)
_ForLoop300:
	lw $t0, 160($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	beqz $t0, _OutOfFor346
	b _ForBody345
_ForBody345:
	lw $t0, 160($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, global_305
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t1, 188($sp)
	lw $t0, 0($t1)
	sw $t0, 156($sp)
	lw $t0, 156($sp)
	li $t1, 0
	seq $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	beqz $t0, _alternative348
	b _consequence347
_consequence347:
	lw $t0, 160($sp)
	sw $t0, global_304
	b _OutOfFor346
	b _OutOfIf349
_alternative348:
	b _OutOfIf349
_OutOfIf349:
	b _continueFor301
_continueFor301:
	lw $t0, 160($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 160($sp)
	b _ForLoop300
_OutOfFor346:
	b _EndOfFunctionDecl279
_EndOfFunctionDecl279:
	lw $ra, 120($sp)
	add $sp, $sp, 204
	jr $ra
_move:
	sub $sp, $sp, 164
	sw $ra, 120($sp)
_BeginOfFunctionDecl280:
	li $t0, 0
	sw $t0, 132($sp)
_ForLoop302:
	lw $t0, 132($sp)
	lw $t1, global_304
	slt $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	beqz $t0, _OutOfFor351
	b _ForBody350
_ForBody350:
	lw $t0, 132($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_305
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $t1, 128($sp)
	lw $t0, 0($t1)
	sw $t0, 144($sp)
	lw $t0, 144($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	lw $t1, 128($sp)
	sw $t0, 0($t1)
	lw $t0, 132($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 132($sp)
_continueFor303:
	b _ForLoop302
_OutOfFor351:
	lw $t0, global_304
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, global_305
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_304
	lw $t1, 136($sp)
	sw $t0, 0($t1)
	lw $t0, global_304
	sw $t0, 140($sp)
	lw $t0, global_304
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_304
_EndOfFunctionDecl281:
	lw $ra, 120($sp)
	add $sp, $sp, 164
	jr $ra
main:
	sub $sp, $sp, 392
	sw $ra, 120($sp)
_BeginOfFunctionDecl282:
	li $t0, 48271
	sw $t0, global_306
	li $t0, 2147483647
	sw $t0, global_307
	li $t0, 1
	sw $t0, global_310
	li $t0, 0
	sw $t0, 308($sp)
	li $t0, 0
	sw $t0, 240($sp)
	li $t0, 0
	sw $t0, 144($sp)
	li $t0, 3
	li $t1, 7
	mul $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 232($sp)
	li $t1, 10
	mul $t1, $t0, $t1
	sw $t1, 216($sp)
	lw $t0, 216($sp)
	sw $t0, global_302
	li $t0, 0
	sw $t0, global_303
	li $t0, 100
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
	sw $v0, 264($sp)
	li $t0, 100
	lw $t1, 264($sp)
	sw $t0, 0($t1)
	lw $t0, 264($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, 264($sp)
	sw $t0, 224($sp)
	lw $t0, 224($sp)
	sw $t0, global_305
	lw $t0, global_307
	lw $t1, global_306
	div $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	sw $t0, global_308
	lw $t0, global_307
	lw $t1, global_306
	rem $t1, $t0, $t1
	sw $t1, 212($sp)
	lw $t0, 212($sp)
	sw $t0, global_309
	lw $t0, global_302
	sw $t0, -4($sp)
	jal _pd
	sw $v0, 244($sp)
	lw $t0, 244($sp)
	xor $t1, $t0, 1
	sw $t1, 204($sp)
	lw $t0, 204($sp)
	beqz $t0, _alternative353
	b _consequence352
_consequence352:
	la $a0, string_456
	jal func__println
	sw $v0, 348($sp)
	li $v0, 1
	b _EndOfFunctionDecl283
	b _OutOfIf354
_alternative353:
	b _OutOfIf354
_OutOfIf354:
	la $a0, string_458
	jal func__println
	sw $v0, 296($sp)
	li $t0, 3654898
	sw $t0, -4($sp)
	jal _initialize
	sw $v0, 132($sp)
	jal _random
	sw $v0, 252($sp)
	lw $t0, 252($sp)
	li $t1, 10
	rem $t1, $t0, $t1
	sw $t1, 220($sp)
	lw $t0, 220($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 340($sp)
	lw $t0, 340($sp)
	sw $t0, global_304
	lw $a0, global_304
	jal func__toString
	sw $v0, 148($sp)
	lw $a0, 148($sp)
	jal func__println
	sw $v0, 184($sp)
_ForLoop304:
	lw $t0, global_304
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, 308($sp)
	lw $t1, 256($sp)
	slt $t1, $t0, $t1
	sw $t1, 356($sp)
	lw $t0, 356($sp)
	beqz $t0, _OutOfFor356
	b _ForBody355
_ForBody355:
	lw $t0, 308($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t0, global_305
	lw $t1, 376($sp)
	add $t1, $t0, $t1
	sw $t1, 248($sp)
	jal _random
	sw $v0, 164($sp)
	lw $t0, 164($sp)
	li $t1, 10
	rem $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 368($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 380($sp)
	lw $t1, 248($sp)
	sw $t0, 0($t1)
_WhileLoop306:
	lw $t0, 308($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, global_305
	lw $t1, 360($sp)
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	lw $t1, 192($sp)
	lw $t0, 0($t1)
	sw $t0, 228($sp)
	lw $t0, 228($sp)
	lw $t1, 240($sp)
	add $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, 384($sp)
	lw $t1, global_302
	sgt $t1, $t0, $t1
	sw $t1, 352($sp)
	lw $t0, 352($sp)
	beqz $t0, _OutOfWhile358
	b _WhileBody357
_WhileBody357:
	lw $t0, 308($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 300($sp)
	lw $t0, global_305
	lw $t1, 300($sp)
	add $t1, $t0, $t1
	sw $t1, 276($sp)
	jal _random
	sw $v0, 292($sp)
	lw $t0, 292($sp)
	li $t1, 10
	rem $t1, $t0, $t1
	sw $t1, 364($sp)
	lw $t0, 364($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 288($sp)
	lw $t1, 276($sp)
	sw $t0, 0($t1)
	b _WhileLoop306
_OutOfWhile358:
	lw $t0, 308($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 328($sp)
	lw $t0, global_305
	lw $t1, 328($sp)
	add $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t1, 344($sp)
	lw $t0, 0($t1)
	sw $t0, 152($sp)
	lw $t0, 240($sp)
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t0, 304($sp)
	sw $t0, 240($sp)
_continueFor305:
	lw $t0, 308($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 308($sp)
	b _ForLoop304
_OutOfFor356:
	lw $t0, global_304
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 324($sp)
	lw $t0, 324($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, global_305
	lw $t1, 136($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, global_302
	lw $t1, 240($sp)
	sub $t1, $t0, $t1
	sw $t1, 272($sp)
	lw $t0, 272($sp)
	lw $t1, 156($sp)
	sw $t0, 0($t1)
	jal _show
	sw $v0, 312($sp)
	jal _merge
	sw $v0, 236($sp)
_WhileLoop307:
	jal _win
	sw $v0, 176($sp)
	lw $t0, 176($sp)
	xor $t1, $t0, 1
	sw $t1, 336($sp)
	lw $t0, 336($sp)
	beqz $t0, _OutOfWhile360
	b _WhileBody359
_WhileBody359:
	lw $t0, 144($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $a0, 144($sp)
	jal func__toString
	sw $v0, 284($sp)
	la $a0, string_500
	lw $a1, 284($sp)
	jal func__stringConcatenate
	sw $v0, 388($sp)
	lw $a0, 388($sp)
	la $a1, string_503
	jal func__stringConcatenate
	sw $v0, 316($sp)
	lw $a0, 316($sp)
	jal func__println
	sw $v0, 332($sp)
	jal _move
	sw $v0, 280($sp)
	jal _merge
	sw $v0, 320($sp)
	jal _show
	sw $v0, 268($sp)
	b _WhileLoop307
_OutOfWhile360:
	lw $a0, 144($sp)
	jal func__toString
	sw $v0, 140($sp)
	la $a0, string_509
	lw $a1, 140($sp)
	jal func__stringConcatenate
	sw $v0, 188($sp)
	lw $a0, 188($sp)
	la $a1, string_512
	jal func__stringConcatenate
	sw $v0, 172($sp)
	lw $a0, 172($sp)
	jal func__println
	sw $v0, 260($sp)
	li $v0, 0
	b _EndOfFunctionDecl283
_EndOfFunctionDecl283:
	lw $ra, 120($sp)
	add $sp, $sp, 392
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_302:
.space 4
.align 2
global_303:
.space 4
.align 2
global_304:
.space 4
.align 2
global_305:
.space 4
.align 2
global_306:
.space 4
.align 2
global_307:
.space 4
.align 2
global_308:
.space 4
.align 2
global_309:
.space 4
.align 2
global_310:
.space 4
.align 2
.word 1
string_361:
.asciiz " "
.align 2
.word 0
string_364:
.asciiz ""
.align 2
.word 79
string_456:
.asciiz "Sorry, the number n must be a number s.t. there exists i satisfying n=1+2+...+i"
.align 2
.word 12
string_458:
.asciiz "Let's start!"
.align 2
.word 5
string_500:
.asciiz "step "
.align 2
.word 1
string_503:
.asciiz ":"
.align 2
.word 7
string_509:
.asciiz "Total: "
.align 2
.word 8
string_512:
.asciiz " step(s)"
.align 2
