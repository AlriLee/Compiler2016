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
_getHash:
	sub $sp, $sp, 140
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl41
_BeginOfFunctionDecl41:
#	$1 = mul $47 237
	lw $t0, 136($sp)
	li $t1, 237
	mul $t2, $t0, $t1
#	$0 = rem $1 $45
	lw $t1, global_45
	rem $t2, $t2, $t1
#	ret $0
	move $v0, $t2
#	jump %EndOfFunctionDecl42
	b _EndOfFunctionDecl42
#	%EndOfFunctionDecl42
_EndOfFunctionDecl42:
	lw $t2, 40($sp)
	add $sp, $sp, 140
	jr $ra
_put:
	sub $sp, $sp, 272
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl43
_BeginOfFunctionDecl43:
#	$51 = move 0
	li $t0, 0
	move $t4, $t0
#	$3 = call getHash $48
	lw $t0, 264($sp)
	sw $t0, -4($sp)
	jal _getHash
	move $t2, $v0
#	$50 = move $3
#	$5 = mul $50 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$6 = add $46 $5
	lw $t0, global_46
	add $t3, $t0, $t3
#	$7 = load 4 $6 0
	lw $t0, 0($t3)
	sw $t0, 240($sp)
#	$4 = seq $7 0
	lw $t0, 240($sp)
	li $t1, 0
	seq $t3, $t0, $t1
#	br $4 %consequence0 %alternative1
	beqz $t3, _alternative1
#	%consequence0
_consequence0:
#	$9 = mul $50 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$10 = add $46 $9
	lw $t0, global_46
	add $t3, $t0, $t3
#	$13 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t4, $t0, $t1
#	$12 = alloc $13
	move $a0, $t4
	li $v0, 9
	syscall
	move $t4, $v0
#	$11 = move $12
#	store 4 $10 $11 0
	sw $t4, 0($t3)
#	$15 = mul $50 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$16 = add $46 $15
	lw $t0, global_46
	add $t3, $t0, $t3
#	$17 = load 4 $16 0
	lw $t0, 0($t3)
	sw $t0, 256($sp)
#	store 4 $17 $48 0
	lw $t0, 264($sp)
	lw $t1, 256($sp)
	sw $t0, 0($t1)
#	$19 = mul $50 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$20 = add $46 $19
	lw $t0, global_46
	add $t1, $t0, $t3
	sw $t1, 228($sp)
#	$21 = load 4 $20 0
	lw $t1, 228($sp)
	lw $t3, 0($t1)
#	store 4 $21 $49 4
	lw $t0, 268($sp)
	sw $t0, 4($t3)
#	$23 = mul $50 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$24 = add $46 $23
	lw $t0, global_46
	add $t1, $t0, $t3
	sw $t1, 224($sp)
#	$25 = load 4 $24 0
	lw $t1, 224($sp)
	lw $t0, 0($t1)
	sw $t0, 232($sp)
#	store 4 $25 0 8
	li $t0, 0
	lw $t1, 232($sp)
	sw $t0, 8($t1)
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
#	$27 = mul $50 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 244($sp)
#	$28 = add $46 $27
	lw $t0, global_46
	lw $t1, 244($sp)
	add $t1, $t0, $t1
	sw $t1, 236($sp)
#	$29 = load 4 $28 0
	lw $t1, 236($sp)
	lw $t3, 0($t1)
#	$51 = move $29
	move $t4, $t3
#	%WhileLoop49
_WhileLoop49:
#	$31 = load 4 $51 0
	lw $t3, 0($t4)
#	$30 = sne $31 $48
	lw $t1, 264($sp)
	sne $t1, $t3, $t1
	sw $t1, 220($sp)
#	br $30 %WhileBody3 %OutOfWhile4
	lw $t0, 220($sp)
	beqz $t0, _OutOfWhile4
#	%WhileBody3
_WhileBody3:
#	$33 = load 4 $51 8
	lw $t3, 8($t4)
#	$32 = seq $33 0
	li $t1, 0
	seq $t1, $t3, $t1
	sw $t1, 260($sp)
#	br $32 %consequence5 %alternative6
	lw $t0, 260($sp)
	beqz $t0, _alternative6
#	%consequence5
_consequence5:
#	$37 = mul 3 4
	li $t0, 3
	li $t1, 4
	mul $t3, $t0, $t1
#	$36 = alloc $37
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	$35 = move $36
	sw $t3, 252($sp)
#	store 4 $51 $35 8
	lw $t0, 252($sp)
	sw $t0, 8($t4)
#	$39 = load 4 $51 8
	lw $t3, 8($t4)
#	store 4 $39 $48 0
	lw $t0, 264($sp)
	sw $t0, 0($t3)
#	$41 = load 4 $51 8
	lw $t3, 8($t4)
#	store 4 $41 0 8
	li $t0, 0
	sw $t0, 8($t3)
#	jump %OutOfIf7
	b _OutOfIf7
#	%alternative6
_alternative6:
#	jump %OutOfIf7
	b _OutOfIf7
#	%OutOfIf7
_OutOfIf7:
#	$43 = load 4 $51 8
	lw $t3, 8($t4)
#	$51 = move $43
	move $t4, $t3
#	jump %WhileLoop49
	b _WhileLoop49
#	%OutOfWhile4
_OutOfWhile4:
#	store 4 $51 $49 4
	lw $t0, 268($sp)
	sw $t0, 4($t4)
#	%EndOfFunctionDecl44
_EndOfFunctionDecl44:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 272
	jr $ra
_get:
	sub $sp, $sp, 168
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl45
_BeginOfFunctionDecl45:
#	$53 = move 0
	li $t0, 0
	move $t2, $t0
#	$46 = call getHash $52
	lw $t0, 164($sp)
	sw $t0, -4($sp)
	jal _getHash
	move $t2, $v0
#	$47 = mul $46 4
	li $t1, 4
	mul $t2, $t2, $t1
#	$48 = add $46 $47
	lw $t0, global_46
	add $t2, $t0, $t2
#	$49 = load 4 $48 0
	lw $t2, 0($t2)
#	$53 = move $49
#	%WhileLoop50
_WhileLoop50:
#	$51 = load 4 $53 0
	lw $t3, 0($t2)
#	$50 = sne $51 $52
	lw $t1, 164($sp)
	sne $t1, $t3, $t1
	sw $t1, 156($sp)
#	br $50 %WhileBody8 %OutOfWhile9
	lw $t0, 156($sp)
	beqz $t0, _OutOfWhile9
#	%WhileBody8
_WhileBody8:
#	$53 = load 4 $53 8
	lw $t2, 8($t2)
#	$53 = move $53
#	jump %WhileLoop50
	b _WhileLoop50
#	%OutOfWhile9
_OutOfWhile9:
#	$54 = load 4 $53 4
	lw $t0, 4($t2)
	sw $t0, 160($sp)
#	ret $54
	lw $v0, 160($sp)
#	jump %EndOfFunctionDecl46
	b _EndOfFunctionDecl46
#	%EndOfFunctionDecl46
_EndOfFunctionDecl46:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 168
	jr $ra
main:
	sub $sp, $sp, 204
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl47
_BeginOfFunctionDecl47:
#	$45 = move 100
	li $t0, 100
	sw $t0, global_45
#	$58 = mul 100 4
	li $t0, 100
	li $t1, 4
	mul $t2, $t0, $t1
#	$58 = add $58 4
	li $t1, 4
	add $t2, $t2, $t1
#	$57 = alloc $58
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $57 100 0
	li $t0, 100
	sw $t0, 0($t2)
#	$57 = add $57 4
	li $t1, 4
	add $t2, $t2, $t1
#	$56 = move $57
#	$46 = move $56
	sw $t2, global_46
#	$54 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop51
_ForLoop51:
#	$60 = slt $54 $45
	lw $t1, global_45
	slt $t3, $t2, $t1
#	br $60 %ForBody10 %OutOfFor11
	beqz $t3, _OutOfFor11
#	%ForBody10
_ForBody10:
#	$62 = mul $54 4
	li $t1, 4
	mul $t3, $t2, $t1
#	$63 = add $46 $62
	lw $t0, global_46
	add $t1, $t0, $t3
	sw $t1, 192($sp)
#	store 4 $63 0 0
	li $t0, 0
	lw $t1, 192($sp)
	sw $t0, 0($t1)
#	%continueFor52
_continueFor52:
#	$64 = move $54
	sw $t2, 196($sp)
#	$54 = add $54 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop51
	b _ForLoop51
#	%OutOfFor11
_OutOfFor11:
#	$54 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop53
_ForLoop53:
#	$66 = slt $54 1000
	li $t1, 1000
	slt $t1, $t2, $t1
	sw $t1, 184($sp)
#	br $66 %ForBody12 %OutOfFor13
	lw $t0, 184($sp)
	beqz $t0, _OutOfFor13
#	%ForBody12
_ForBody12:
#	nullcall put $54 $54
	sw $t2, -8($sp)
	sw $t2, -4($sp)
	jal _put
	move $t3, $v0
#	%continueFor54
_continueFor54:
#	$68 = move $54
	move $t3, $t2
#	$54 = add $54 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop53
	b _ForLoop53
#	%OutOfFor13
_OutOfFor13:
#	$54 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop55
_ForLoop55:
#	$70 = slt $54 1000
	li $t1, 1000
	slt $t3, $t2, $t1
#	br $70 %ForBody14 %OutOfFor15
	beqz $t3, _OutOfFor15
#	%ForBody14
_ForBody14:
#	$71 = call toString $54
	move $a0, $t2
	jal func__toString
	sw $v0, 180($sp)
#	$73 = call stringConcatenate $71 " "
	lw $a0, 180($sp)
	la $a1, string_72
	jal func__stringConcatenate
	move $t4, $v0
#	$74 = call get $54
	sw $t2, -4($sp)
	jal _get
	move $t3, $v0
#	$75 = call toString $74
	move $a0, $t3
	jal func__toString
	sw $v0, 176($sp)
#	$76 = call stringConcatenate $73 $75
	move $a0, $t4
	lw $a1, 176($sp)
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall println $76
	move $a0, $t3
	jal func__println
	move $t3, $v0
#	%continueFor56
_continueFor56:
#	$78 = move $54
	sw $t2, 188($sp)
#	$54 = add $54 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop55
	b _ForLoop55
#	%OutOfFor15
_OutOfFor15:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl48
	b _EndOfFunctionDecl48
#	%EndOfFunctionDecl48
_EndOfFunctionDecl48:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 204
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_45:
.space 4
.align 2
global_46:
.space 4
.align 2
.word 1
string_72:
.asciiz " "
.align 2
