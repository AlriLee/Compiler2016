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
	sub $sp, $sp, 412
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl44
_BeginOfFunctionDecl44:
#	$2 = mul 4 4
	li $t0, 4
	li $t1, 4
	mul $t2, $t0, $t1
#	$2 = add $2 4
	li $t1, 4
	add $t2, $t2, $t1
#	$1 = alloc $2
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $1 4 0
	li $t0, 4
	sw $t0, 0($t2)
#	$1 = add $1 4
	li $t1, 4
	add $t2, $t2, $t1
#	$0 = move $1
#	$52 = move $0
	sw $t2, global_52
#	$5 = mul 4 4
	li $t0, 4
	li $t1, 4
	mul $t2, $t0, $t1
#	$5 = add $5 4
	li $t1, 4
	add $t2, $t2, $t1
#	$4 = alloc $5
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $4 4 0
	li $t0, 4
	sw $t0, 0($t2)
#	$4 = add $4 4
	li $t1, 4
	add $t2, $t2, $t1
#	$3 = move $4
#	$53 = move $3
	move $t3, $t2
#	$7 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$8 = add $53 $7
	add $t2, $t3, $t2
#	store 4 $8 $52 0
	lw $t0, global_52
	sw $t0, 0($t2)
#	$10 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$11 = add $53 $10
	add $t2, $t3, $t2
#	store 4 $11 $52 0
	lw $t0, global_52
	sw $t0, 0($t2)
#	$13 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$14 = add $53 $13
	add $t2, $t3, $t2
#	store 4 $14 $52 0
	lw $t0, global_52
	sw $t0, 0($t2)
#	$16 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$17 = add $53 $16
	add $t2, $t3, $t2
#	store 4 $17 $52 0
	lw $t0, global_52
	sw $t0, 0($t2)
#	$18 = call size $53
	move $a0, $t3
	jal func__size
	move $t2, $v0
#	$19 = call toString $18
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $19
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	$54 = move 0
	li $t0, 0
	sw $t0, 208($sp)
#	%ForLoop46
_ForLoop46:
#	$23 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$24 = add $53 $23
	add $t2, $t3, $t2
#	$25 = load 4 $24 0
	lw $t2, 0($t2)
#	$26 = call size $25
	move $a0, $t2
	jal func__size
	move $t2, $v0
#	$22 = slt $54 $26
	lw $t0, 208($sp)
	slt $t2, $t0, $t2
#	br $22 %ForBody0 %OutOfFor1
	beqz $t2, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$28 = mul 0 4
	li $t0, 0
	li $t1, 4
	mul $t2, $t0, $t1
#	$29 = add $53 $28
	add $t2, $t3, $t2
#	$30 = load 4 $29 0
	lw $t2, 0($t2)
#	$31 = mul $54 4
	lw $t0, 208($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$32 = add $30 $31
	add $t4, $t2, $t4
#	$33 = call getInt
	jal func__getInt
	move $t2, $v0
#	store 4 $32 $33 0
	sw $t2, 0($t4)
#	%continueFor47
_continueFor47:
#	$34 = move $54
	lw $t0, 208($sp)
	move $t2, $t0
#	$54 = add $54 1
	lw $t0, 208($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 208($sp)
#	jump %ForLoop46
	b _ForLoop46
#	%OutOfFor1
_OutOfFor1:
#	$54 = move 0
	li $t0, 0
	sw $t0, 208($sp)
#	%ForLoop48
_ForLoop48:
#	$37 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$38 = add $53 $37
	add $t2, $t3, $t2
#	$39 = load 4 $38 0
	lw $t2, 0($t2)
#	$40 = call size $39
	move $a0, $t2
	jal func__size
	move $t2, $v0
#	$36 = slt $54 $40
	lw $t0, 208($sp)
	slt $t2, $t0, $t2
#	br $36 %ForBody2 %OutOfFor3
	beqz $t2, _OutOfFor3
#	%ForBody2
_ForBody2:
#	$41 = mul 1 4
	li $t0, 1
	li $t1, 4
	mul $t2, $t0, $t1
#	$42 = add $53 $41
	add $t2, $t3, $t2
#	$43 = load 4 $42 0
	lw $t4, 0($t2)
#	$44 = mul $54 4
	lw $t0, 208($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$45 = add $43 $44
	add $t2, $t4, $t2
#	$46 = load 4 $45 0
	lw $t2, 0($t2)
#	$47 = call toString $46
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall print $47
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	%continueFor49
_continueFor49:
#	$49 = move $54
	lw $t0, 208($sp)
	move $t2, $t0
#	$54 = add $54 1
	lw $t0, 208($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 208($sp)
#	jump %ForLoop48
	b _ForLoop48
#	%OutOfFor3
_OutOfFor3:
#	nullcall println ""
	la $a0, string_50
	jal func__println
	move $t2, $v0
#	$54 = move 0
	li $t0, 0
	sw $t0, 208($sp)
#	%ForLoop50
_ForLoop50:
#	$54 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$55 = add $53 $54
	add $t2, $t3, $t2
#	$56 = load 4 $55 0
	lw $t2, 0($t2)
#	$57 = call size $56
	move $a0, $t2
	jal func__size
	move $t2, $v0
#	$53 = slt $54 $57
	lw $t0, 208($sp)
	slt $t2, $t0, $t2
#	br $53 %ForBody4 %OutOfFor5
	beqz $t2, _OutOfFor5
#	%ForBody4
_ForBody4:
#	$59 = mul 2 4
	li $t0, 2
	li $t1, 4
	mul $t2, $t0, $t1
#	$60 = add $53 $59
	add $t2, $t3, $t2
#	$61 = load 4 $60 0
	lw $t2, 0($t2)
#	$62 = mul $54 4
	lw $t0, 208($sp)
	li $t1, 4
	mul $t4, $t0, $t1
#	$63 = add $61 $62
	add $t2, $t2, $t4
#	store 4 $63 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor51
_continueFor51:
#	$64 = move $54
	lw $t0, 208($sp)
	move $t2, $t0
#	$54 = add $54 1
	lw $t0, 208($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 208($sp)
#	jump %ForLoop50
	b _ForLoop50
#	%OutOfFor5
_OutOfFor5:
#	$54 = move 0
	li $t0, 0
	sw $t0, 208($sp)
#	%ForLoop52
_ForLoop52:
#	$67 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$68 = add $53 $67
	add $t2, $t3, $t2
#	$69 = load 4 $68 0
	lw $t2, 0($t2)
#	$70 = call size $69
	move $a0, $t2
	jal func__size
	move $t2, $v0
#	$66 = slt $54 $70
	lw $t0, 208($sp)
	slt $t2, $t0, $t2
#	br $66 %ForBody6 %OutOfFor7
	beqz $t2, _OutOfFor7
#	%ForBody6
_ForBody6:
#	$71 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t2, $t0, $t1
#	$72 = add $53 $71
	add $t2, $t3, $t2
#	$73 = load 4 $72 0
	lw $t4, 0($t2)
#	$74 = mul $54 4
	lw $t0, 208($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$75 = add $73 $74
	add $t2, $t4, $t2
#	$76 = load 4 $75 0
	lw $t2, 0($t2)
#	$77 = call toString $76
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall print $77
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	%continueFor53
_continueFor53:
#	$79 = move $54
	lw $t0, 208($sp)
	move $t2, $t0
#	$54 = add $54 1
	lw $t0, 208($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 208($sp)
#	jump %ForLoop52
	b _ForLoop52
#	%OutOfFor7
_OutOfFor7:
#	jump %EndOfFunctionDecl45
	b _EndOfFunctionDecl45
#	%EndOfFunctionDecl45
_EndOfFunctionDecl45:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 412
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_52:
.space 4
.align 2
.word 0
string_50:
.asciiz ""
.align 2
