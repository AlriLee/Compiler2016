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
_merge:
	sub $sp, $sp, 244
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl43
_BeginOfFunctionDecl43:
#	$0 = seq 0 $795
	li $t0, 0
	lw $t1, 236($sp)
	seq $t2, $t0, $t1
#	br $0 %consequence0 %alternative1
	beqz $t2, _alternative1
#	%consequence0
_consequence0:
#	ret $796
	lw $v0, 240($sp)
#	jump %EndOfFunctionDecl44
	b _EndOfFunctionDecl44
#	jump %OutOfIf2
	b _OutOfIf2
#	%alternative1
_alternative1:
#	jump %OutOfIf2
	b _OutOfIf2
#	%OutOfIf2
_OutOfIf2:
#	$1 = seq 0 $796
	li $t0, 0
	lw $t1, 240($sp)
	seq $t2, $t0, $t1
#	br $1 %consequence3 %alternative4
	beqz $t2, _alternative4
#	%consequence3
_consequence3:
#	ret $795
	lw $v0, 236($sp)
#	jump %EndOfFunctionDecl44
	b _EndOfFunctionDecl44
#	jump %OutOfIf5
	b _OutOfIf5
#	%alternative4
_alternative4:
#	jump %OutOfIf5
	b _OutOfIf5
#	%OutOfIf5
_OutOfIf5:
#	$3 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$4 = add $794 $3
	lw $t0, global_794
	add $t2, $t0, $t2
#	$5 = mul $796 4
	lw $t0, 240($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 180($sp)
#	$6 = add $794 $5
	lw $t0, global_794
	lw $t1, 180($sp)
	add $t1, $t0, $t1
	sw $t1, 196($sp)
#	$7 = load 4 $4 0
	lw $t2, 0($t2)
#	$8 = load 4 $6 0
	lw $t1, 196($sp)
	lw $t0, 0($t1)
	sw $t0, 220($sp)
#	$2 = slt $7 $8
	lw $t1, 220($sp)
	slt $t2, $t2, $t1
#	br $2 %consequence6 %alternative7
	beqz $t2, _alternative7
#	%consequence6
_consequence6:
#	$797 = move $795
	lw $t0, 236($sp)
	move $t2, $t0
#	$795 = move $796
	lw $t0, 240($sp)
	sw $t0, 236($sp)
#	$796 = move $797
	sw $t2, 240($sp)
#	jump %OutOfIf8
	b _OutOfIf8
#	%alternative7
_alternative7:
#	jump %OutOfIf8
	b _OutOfIf8
#	%OutOfIf8
_OutOfIf8:
#	$12 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$13 = add $793 $12
	lw $t0, global_793
	add $t2, $t0, $t2
#	$14 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$15 = add $793 $14
	lw $t0, global_793
	add $t3, $t0, $t3
#	$16 = load 4 $15 0
	lw $t3, 0($t3)
#	$17 = call merge $16 $796
	sw $t3, -8($sp)
	lw $t0, 240($sp)
	sw $t0, -4($sp)
	jal _merge
	sw $v0, 232($sp)
#	store 4 $13 $17 0
	lw $t0, 232($sp)
	sw $t0, 0($t2)
#	$18 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$19 = add $792 $18
	lw $t0, global_792
	add $t2, $t0, $t2
#	$20 = load 4 $19 0
	lw $t2, 0($t2)
#	$798 = move $20
	move $t3, $t2
#	$22 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 204($sp)
#	$23 = add $792 $22
	lw $t0, global_792
	lw $t1, 204($sp)
	add $t1, $t0, $t1
	sw $t1, 224($sp)
#	$24 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$25 = add $793 $24
	lw $t0, global_793
	add $t2, $t0, $t2
#	$26 = load 4 $25 0
	lw $t2, 0($t2)
#	store 4 $23 $26 0
	lw $t1, 224($sp)
	sw $t2, 0($t1)
#	$28 = mul $795 4
	lw $t0, 236($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 176($sp)
#	$29 = add $793 $28
	lw $t0, global_793
	lw $t1, 176($sp)
	add $t1, $t0, $t1
	sw $t1, 208($sp)
#	store 4 $29 $798 0
	lw $t1, 208($sp)
	sw $t3, 0($t1)
#	ret $795
	lw $v0, 236($sp)
#	jump %EndOfFunctionDecl44
	b _EndOfFunctionDecl44
#	%EndOfFunctionDecl44
_EndOfFunctionDecl44:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 244
	jr $ra
main:
	sub $sp, $sp, 400
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl45
_BeginOfFunctionDecl45:
#	$31 = call getInt
	jal func__getInt
	move $t2, $v0
#	$789 = move $31
	sw $t2, global_789
#	$33 = call getInt
	jal func__getInt
	move $t2, $v0
#	$790 = move $33
	sw $t2, global_790
#	$35 = call getString
	jal func__getString
	move $t2, $v0
#	$791 = move $35
	sw $t2, global_791
#	$40 = add $789 $790
	lw $t0, global_789
	lw $t1, global_790
	add $t2, $t0, $t1
#	$39 = add $40 5
	li $t1, 5
	add $t2, $t2, $t1
#	$41 = mul $39 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 192($sp)
#	$41 = add $41 4
	lw $t0, 192($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 192($sp)
#	$38 = alloc $41
	lw $a0, 192($sp)
	li $v0, 9
	syscall
	sw $v0, 352($sp)
#	store 4 $38 $39 0
	lw $t1, 352($sp)
	sw $t2, 0($t1)
#	$38 = add $38 4
	lw $t0, 352($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 352($sp)
#	$37 = move $38
	lw $t0, 352($sp)
	move $t2, $t0
#	$792 = move $37
	sw $t2, global_792
#	$46 = add $789 $790
	lw $t0, global_789
	lw $t1, global_790
	add $t2, $t0, $t1
#	$45 = add $46 5
	li $t1, 5
	add $t2, $t2, $t1
#	$47 = mul $45 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 308($sp)
#	$47 = add $47 4
	lw $t0, 308($sp)
	li $t1, 4
	add $t1, $t0, $t1
	sw $t1, 308($sp)
#	$44 = alloc $47
	lw $a0, 308($sp)
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $44 $45 0
	sw $t2, 0($t3)
#	$44 = add $44 4
	li $t1, 4
	add $t3, $t3, $t1
#	$43 = move $44
	move $t2, $t3
#	$793 = move $43
	sw $t2, global_793
#	$52 = add $789 $790
	lw $t0, global_789
	lw $t1, global_790
	add $t2, $t0, $t1
#	$51 = add $52 5
	li $t1, 5
	add $t1, $t2, $t1
	sw $t1, 388($sp)
#	$53 = mul $51 4
	lw $t0, 388($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$53 = add $53 4
	li $t1, 4
	add $t2, $t2, $t1
#	$50 = alloc $53
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $50 $51 0
	lw $t0, 388($sp)
	sw $t0, 0($t2)
#	$50 = add $50 4
	li $t1, 4
	add $t2, $t2, $t1
#	$49 = move $50
#	$794 = move $49
	sw $t2, global_794
#	$799 = move 1
	li $t0, 1
	sw $t0, 248($sp)
#	%ForLoop47
_ForLoop47:
#	$55 = sle $799 $789
	lw $t0, 248($sp)
	lw $t1, global_789
	sle $t2, $t0, $t1
#	br $55 %ForBody9 %OutOfFor10
	beqz $t2, _OutOfFor10
#	%ForBody9
_ForBody9:
#	$57 = mul $799 4
	lw $t0, 248($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$58 = add $794 $57
	lw $t0, global_794
	add $t3, $t0, $t2
#	$59 = call getInt
	jal func__getInt
	move $t2, $v0
#	store 4 $58 $59 0
	sw $t2, 0($t3)
#	$61 = mul $799 4
	lw $t0, 248($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$62 = add $792 $61
	lw $t0, global_792
	add $t2, $t0, $t2
#	store 4 $62 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$64 = mul $799 4
	lw $t0, 248($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$65 = add $793 $64
	lw $t0, global_793
	add $t2, $t0, $t2
#	store 4 $65 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor48
_continueFor48:
#	$66 = move $799
	lw $t0, 248($sp)
	move $t2, $t0
#	$799 = add $799 1
	lw $t0, 248($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 248($sp)
#	jump %ForLoop47
	b _ForLoop47
#	%OutOfFor10
_OutOfFor10:
#	$799 = move 1
	li $t0, 1
	sw $t0, 248($sp)
#	%ForLoop49
_ForLoop49:
#	$68 = sle $799 $790
	lw $t0, 248($sp)
	lw $t1, global_790
	sle $t2, $t0, $t1
#	br $68 %ForBody11 %OutOfFor12
	beqz $t2, _OutOfFor12
#	%ForBody11
_ForBody11:
#	$70 = add $799 $789
	lw $t0, 248($sp)
	lw $t1, global_789
	add $t2, $t0, $t1
#	$71 = mul $70 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$72 = add $794 $71
	lw $t0, global_794
	add $t3, $t0, $t2
#	$73 = sub $799 1
	lw $t0, 248($sp)
	li $t1, 1
	sub $t2, $t0, $t1
#	$74 = call ord $791 $73
	lw $a0, global_791
	move $a1, $t2
	jal func__ord
	move $t2, $v0
#	store 4 $72 $74 0
	sw $t2, 0($t3)
#	$76 = add $799 $789
	lw $t0, 248($sp)
	lw $t1, global_789
	add $t2, $t0, $t1
#	$77 = mul $76 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$78 = add $792 $77
	lw $t0, global_792
	add $t2, $t0, $t2
#	store 4 $78 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	$80 = add $799 $789
	lw $t0, 248($sp)
	lw $t1, global_789
	add $t2, $t0, $t1
#	$81 = mul $80 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$82 = add $793 $81
	lw $t0, global_793
	add $t2, $t0, $t2
#	store 4 $82 0 0
	li $t0, 0
	sw $t0, 0($t2)
#	%continueFor50
_continueFor50:
#	$83 = move $799
	lw $t0, 248($sp)
	move $t2, $t0
#	$799 = add $799 1
	lw $t0, 248($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 248($sp)
#	jump %ForLoop49
	b _ForLoop49
#	%OutOfFor12
_OutOfFor12:
#	$800 = move 1
	li $t0, 1
	move $t3, $t0
#	$84 = add $789 1
	lw $t0, global_789
	li $t1, 1
	add $t2, $t0, $t1
#	$801 = move $84
	move $t5, $t2
#	$799 = move 2
	li $t0, 2
	sw $t0, 248($sp)
#	%ForLoop51
_ForLoop51:
#	$86 = sle $799 $789
	lw $t0, 248($sp)
	lw $t1, global_789
	sle $t2, $t0, $t1
#	br $86 %ForBody13 %OutOfFor14
	beqz $t2, _OutOfFor14
#	%ForBody13
_ForBody13:
#	$88 = call merge $800 $799
	sw $t3, -8($sp)
	lw $t0, 248($sp)
	sw $t0, -4($sp)
	jal _merge
	move $t2, $v0
#	$800 = move $88
	move $t3, $t2
#	%continueFor52
_continueFor52:
#	$89 = move $799
	lw $t0, 248($sp)
	move $t2, $t0
#	$799 = add $799 1
	lw $t0, 248($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 248($sp)
#	jump %ForLoop51
	b _ForLoop51
#	%OutOfFor14
_OutOfFor14:
#	$91 = add $789 2
	lw $t0, global_789
	li $t1, 2
	add $t2, $t0, $t1
#	$799 = move $91
	sw $t2, 248($sp)
#	%ForLoop53
_ForLoop53:
#	$93 = add $789 $790
	lw $t0, global_789
	lw $t1, global_790
	add $t2, $t0, $t1
#	$92 = sle $799 $93
	lw $t0, 248($sp)
	sle $t2, $t0, $t2
#	br $92 %ForBody15 %OutOfFor16
	beqz $t2, _OutOfFor16
#	%ForBody15
_ForBody15:
#	$95 = call merge $801 $799
	sw $t5, -8($sp)
	lw $t0, 248($sp)
	sw $t0, -4($sp)
	jal _merge
	move $t2, $v0
#	$801 = move $95
	move $t5, $t2
#	%continueFor54
_continueFor54:
#	$96 = move $799
	lw $t0, 248($sp)
	move $t2, $t0
#	$799 = add $799 1
	lw $t0, 248($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 248($sp)
#	jump %ForLoop53
	b _ForLoop53
#	%OutOfFor16
_OutOfFor16:
#	$97 = mul $800 4
	li $t1, 4
	mul $t2, $t3, $t1
#	$98 = add $794 $97
	lw $t0, global_794
	add $t2, $t0, $t2
#	$99 = load 4 $98 0
	lw $t2, 0($t2)
#	$100 = call toString $99
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall print $100
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	nullcall print " "
	la $a0, string_102
	jal func__print
	move $t2, $v0
#	$105 = sub $801 $789
	lw $t1, global_789
	sub $t2, $t5, $t1
#	$104 = sub $105 1
	li $t1, 1
	sub $t4, $t2, $t1
#	$107 = sub $801 $789
	lw $t1, global_789
	sub $t2, $t5, $t1
#	$106 = sub $107 1
	li $t1, 1
	sub $t2, $t2, $t1
#	$108 = call substring $791 $104 $106
	lw $a0, global_791
	move $a1, $t4
	move $a2, $t2
	jal func__substring
	move $t2, $v0
#	nullcall print $108
	move $a0, $t2
	jal func__print
	move $t2, $v0
#	nullcall print "\n"
	la $a0, string_110
	jal func__print
	move $t2, $v0
#	$112 = call merge $800 $801
	sw $t3, -8($sp)
	sw $t5, -4($sp)
	jal _merge
	move $t2, $v0
#	$113 = call toString $112
	move $a0, $t2
	jal func__toString
	move $t2, $v0
#	nullcall println $113
	move $a0, $t2
	jal func__println
	move $t2, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl46
	b _EndOfFunctionDecl46
#	%EndOfFunctionDecl46
_EndOfFunctionDecl46:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 400
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_789:
.space 4
.align 2
global_790:
.space 4
.align 2
global_791:
.space 4
.align 2
global_792:
.space 4
.align 2
global_793:
.space 4
.align 2
global_794:
.space 4
.align 2
.word 1
string_102:
.asciiz " "
.align 2
.word 1
string_110:
.asciiz "\n"
.align 2
