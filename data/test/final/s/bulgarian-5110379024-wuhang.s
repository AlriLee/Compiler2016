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
	sw $t2, 40($sp)
	sw $t3, 44($sp)
#	%BeginOfFunctionDecl38
_BeginOfFunctionDecl38:
#	$2 = rem $55 $53
	lw $t0, global_55
	lw $t1, global_53
	rem $t2, $t0, $t1
#	$1 = mul $51 $2
	lw $t0, global_51
	mul $t2, $t0, $t2
#	$4 = div $55 $53
	lw $t0, global_55
	lw $t1, global_53
	div $t3, $t0, $t1
#	$3 = mul $54 $4
	lw $t0, global_54
	mul $t1, $t0, $t3
	sw $t1, 148($sp)
#	$0 = sub $1 $3
	lw $t1, 148($sp)
	sub $t2, $t2, $t1
#	$56 = move $0
#	$5 = sge $56 0
	li $t1, 0
	sge $t1, $t2, $t1
	sw $t1, 140($sp)
#	br $5 %consequence0 %alternative1
	lw $t0, 140($sp)
	beqz $t0, _alternative1
#	%consequence0
_consequence0:
#	$55 = move $56
	sw $t2, global_55
#	jump %OutOfIf2
	b _OutOfIf2
#	%alternative1
_alternative1:
#	$8 = add $56 $52
	lw $t1, global_52
	add $t1, $t2, $t1
	sw $t1, 144($sp)
#	$55 = move $8
	lw $t0, 144($sp)
	sw $t0, global_55
#	jump %OutOfIf2
	b _OutOfIf2
#	%OutOfIf2
_OutOfIf2:
#	ret $55
	lw $v0, global_55
#	jump %EndOfFunctionDecl39
	b _EndOfFunctionDecl39
#	%EndOfFunctionDecl39
_EndOfFunctionDecl39:
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 160
	jr $ra
_initialize:
	sub $sp, $sp, 132
#	%BeginOfFunctionDecl40
_BeginOfFunctionDecl40:
#	$55 = move $57
	lw $t0, 128($sp)
	sw $t0, global_55
#	%EndOfFunctionDecl41
_EndOfFunctionDecl41:
	add $sp, $sp, 132
	jr $ra
_swap:
	sub $sp, $sp, 180
	sw $t2, 40($sp)
	sw $t3, 44($sp)
#	%BeginOfFunctionDecl42
_BeginOfFunctionDecl42:
#	$10 = mul $58 4
	lw $t0, 172($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$11 = add $50 $10
	lw $t0, global_50
	add $t2, $t0, $t2
#	$12 = load 4 $11 0
	lw $t2, 0($t2)
#	$60 = move $12
	move $t3, $t2
#	$14 = mul $58 4
	lw $t0, 172($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 168($sp)
#	$15 = add $50 $14
	lw $t0, global_50
	lw $t1, 168($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
#	$16 = mul $59 4
	lw $t0, 176($sp)
	li $t1, 4
	mul $t2, $t0, $t1
#	$17 = add $50 $16
	lw $t0, global_50
	add $t2, $t0, $t2
#	$18 = load 4 $17 0
	lw $t2, 0($t2)
#	store 4 $15 $18 0
	lw $t1, 160($sp)
	sw $t2, 0($t1)
#	$20 = mul $59 4
	lw $t0, 176($sp)
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 148($sp)
#	$21 = add $50 $20
	lw $t0, global_50
	lw $t1, 148($sp)
	add $t1, $t0, $t1
	sw $t1, 136($sp)
#	store 4 $21 $60 0
	lw $t1, 136($sp)
	sw $t3, 0($t1)
#	%EndOfFunctionDecl43
_EndOfFunctionDecl43:
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 180
	jr $ra
_pd:
	sub $sp, $sp, 152
	sw $t2, 40($sp)
#	%BeginOfFunctionDecl44
_BeginOfFunctionDecl44:
#	jump %ForLoop56
	b _ForLoop56
#	%ForLoop56
_ForLoop56:
#	$22 = sle $48 $61
	lw $t0, global_48
	lw $t1, 148($sp)
	sle $t2, $t0, $t1
#	br $22 %ForBody3 %OutOfFor4
	beqz $t2, _OutOfFor4
#	%ForBody3
_ForBody3:
#	$26 = add $48 1
	lw $t0, global_48
	li $t1, 1
	add $t2, $t0, $t1
#	$25 = mul $48 $26
	lw $t0, global_48
	mul $t2, $t0, $t2
#	$24 = div $25 2
	li $t1, 2
	div $t2, $t2, $t1
#	$23 = seq $61 $24
	lw $t0, 148($sp)
	seq $t2, $t0, $t2
#	br $23 %consequence5 %alternative6
	beqz $t2, _alternative6
#	%consequence5
_consequence5:
#	ret 1
	li $v0, 1
#	jump %EndOfFunctionDecl45
	b _EndOfFunctionDecl45
#	jump %OutOfIf7
	b _OutOfIf7
#	%alternative6
_alternative6:
#	jump %OutOfIf7
	b _OutOfIf7
#	%OutOfIf7
_OutOfIf7:
#	jump %continueFor57
	b _continueFor57
#	%continueFor57
_continueFor57:
#	$48 = add $48 1
	lw $t0, global_48
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_48
#	jump %ForLoop56
	b _ForLoop56
#	%OutOfFor4
_OutOfFor4:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl45
	b _EndOfFunctionDecl45
#	%EndOfFunctionDecl45
_EndOfFunctionDecl45:
	lw $t2, 40($sp)
	add $sp, $sp, 152
	jr $ra
_show:
	sub $sp, $sp, 164
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl46
_BeginOfFunctionDecl46:
#	$62 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop58
_ForLoop58:
#	$28 = slt $62 $49
	lw $t1, global_49
	slt $t1, $t2, $t1
	sw $t1, 148($sp)
#	br $28 %ForBody8 %OutOfFor9
	lw $t0, 148($sp)
	beqz $t0, _OutOfFor9
#	%ForBody8
_ForBody8:
#	$29 = mul $62 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 156($sp)
#	$30 = add $50 $29
	lw $t0, global_50
	lw $t1, 156($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
#	$31 = load 4 $30 0
	lw $t1, 160($sp)
	lw $t3, 0($t1)
#	$32 = call toString $31
	move $a0, $t3
	jal func__toString
	move $t3, $v0
#	$34 = call stringConcatenate $32 " "
	move $a0, $t3
	la $a1, string_33
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall print $34
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	%continueFor59
_continueFor59:
#	$62 = add $62 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop58
	b _ForLoop58
#	%OutOfFor9
_OutOfFor9:
#	nullcall println ""
	la $a0, string_36
	jal func__println
	sw $v0, 152($sp)
#	%EndOfFunctionDecl47
_EndOfFunctionDecl47:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 164
	jr $ra
_win:
	sub $sp, $sp, 292
	sw $s0, 64($sp)
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
#	%BeginOfFunctionDecl48
_BeginOfFunctionDecl48:
#	$40 = mul 100 4
	li $t0, 100
	li $t1, 4
	mul $t2, $t0, $t1
#	$40 = add $40 4
	li $t1, 4
	add $t2, $t2, $t1
#	$39 = alloc $40
	move $a0, $t2
	li $v0, 9
	syscall
	move $t2, $v0
#	store 4 $39 100 0
	li $t0, 100
	sw $t0, 0($t2)
#	$39 = add $39 4
	li $t1, 4
	add $t2, $t2, $t1
#	$38 = move $39
#	$65 = move $38
#	$41 = sne $49 $48
	lw $t0, global_49
	lw $t1, global_48
	sne $t3, $t0, $t1
#	br $41 %consequence10 %alternative11
	beqz $t3, _alternative11
#	%consequence10
_consequence10:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl49
	b _EndOfFunctionDecl49
#	jump %OutOfIf12
	b _OutOfIf12
#	%alternative11
_alternative11:
#	jump %OutOfIf12
	b _OutOfIf12
#	%OutOfIf12
_OutOfIf12:
#	$64 = move 0
	li $t0, 0
	move $t7, $t0
#	%ForLoop60
_ForLoop60:
#	$43 = slt $64 $49
	lw $t1, global_49
	slt $t3, $t7, $t1
#	br $43 %ForBody13 %OutOfFor14
	beqz $t3, _OutOfFor14
#	%ForBody13
_ForBody13:
#	$45 = mul $64 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$46 = add $65 $45
	add $t4, $t2, $t3
#	$47 = mul $64 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$48 = add $50 $47
	lw $t0, global_50
	add $t3, $t0, $t3
#	$49 = load 4 $48 0
	lw $t3, 0($t3)
#	store 4 $46 $49 0
	sw $t3, 0($t4)
#	%continueFor61
_continueFor61:
#	$64 = add $64 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop60
	b _ForLoop60
#	%OutOfFor14
_OutOfFor14:
#	$63 = move 0
	li $t0, 0
	move $t6, $t0
#	%ForLoop62
_ForLoop62:
#	$52 = sub $49 1
	lw $t0, global_49
	li $t1, 1
	sub $t3, $t0, $t1
#	$51 = slt $63 $52
	slt $t3, $t6, $t3
#	br $51 %ForBody15 %OutOfFor16
	beqz $t3, _OutOfFor16
#	%ForBody15
_ForBody15:
#	$54 = add $63 1
	li $t1, 1
	add $t3, $t6, $t1
#	$64 = move $54
	move $t7, $t3
#	%ForLoop64
_ForLoop64:
#	$55 = slt $64 $49
	lw $t1, global_49
	slt $t3, $t7, $t1
#	br $55 %ForBody17 %OutOfFor18
	beqz $t3, _OutOfFor18
#	%ForBody17
_ForBody17:
#	$57 = mul $63 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$58 = add $65 $57
	add $t3, $t2, $t3
#	$59 = mul $64 4
	li $t1, 4
	mul $t4, $t7, $t1
#	$60 = add $65 $59
	add $t4, $t2, $t4
#	$61 = load 4 $58 0
	lw $t3, 0($t3)
#	$62 = load 4 $60 0
	lw $t4, 0($t4)
#	$56 = sgt $61 $62
	sgt $t3, $t3, $t4
#	br $56 %consequence19 %alternative20
	beqz $t3, _alternative20
#	%consequence19
_consequence19:
#	$64 = mul $63 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$65 = add $65 $64
	add $t3, $t2, $t3
#	$66 = load 4 $65 0
	lw $t3, 0($t3)
#	$66 = move $66
	move $t4, $t3
#	$68 = mul $63 4
	li $t1, 4
	mul $t1, $t6, $t1
	sw $t1, 288($sp)
#	$69 = add $65 $68
	lw $t1, 288($sp)
	add $t5, $t2, $t1
#	$70 = mul $64 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$71 = add $65 $70
	add $t3, $t2, $t3
#	$72 = load 4 $71 0
	lw $t3, 0($t3)
#	store 4 $69 $72 0
	sw $t3, 0($t5)
#	$74 = mul $64 4
	li $t1, 4
	mul $t3, $t7, $t1
#	$75 = add $65 $74
	add $t3, $t2, $t3
#	store 4 $75 $66 0
	sw $t4, 0($t3)
#	jump %OutOfIf21
	b _OutOfIf21
#	%alternative20
_alternative20:
#	jump %OutOfIf21
	b _OutOfIf21
#	%OutOfIf21
_OutOfIf21:
#	jump %continueFor65
	b _continueFor65
#	%continueFor65
_continueFor65:
#	$64 = add $64 1
	li $t1, 1
	add $t7, $t7, $t1
#	jump %ForLoop64
	b _ForLoop64
#	%OutOfFor18
_OutOfFor18:
#	jump %continueFor63
	b _continueFor63
#	%continueFor63
_continueFor63:
#	$63 = add $63 1
	li $t1, 1
	add $t6, $t6, $t1
#	jump %ForLoop62
	b _ForLoop62
#	%OutOfFor16
_OutOfFor16:
#	$63 = move 0
	li $t0, 0
	move $t6, $t0
#	%ForLoop66
_ForLoop66:
#	$77 = slt $63 $49
	lw $t1, global_49
	slt $t3, $t6, $t1
#	br $77 %ForBody22 %OutOfFor23
	beqz $t3, _OutOfFor23
#	%ForBody22
_ForBody22:
#	$79 = mul $63 4
	li $t1, 4
	mul $t3, $t6, $t1
#	$80 = add $65 $79
	add $t3, $t2, $t3
#	$81 = add $63 1
	li $t1, 1
	add $t4, $t6, $t1
#	$82 = load 4 $80 0
	lw $t3, 0($t3)
#	$78 = sne $82 $81
	sne $t3, $t3, $t4
#	br $78 %consequence24 %alternative25
	beqz $t3, _alternative25
#	%consequence24
_consequence24:
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl49
	b _EndOfFunctionDecl49
#	jump %OutOfIf26
	b _OutOfIf26
#	%alternative25
_alternative25:
#	jump %OutOfIf26
	b _OutOfIf26
#	%OutOfIf26
_OutOfIf26:
#	jump %continueFor67
	b _continueFor67
#	%continueFor67
_continueFor67:
#	$63 = add $63 1
	li $t1, 1
	add $t6, $t6, $t1
#	jump %ForLoop66
	b _ForLoop66
#	%OutOfFor23
_OutOfFor23:
#	ret 1
	li $v0, 1
#	jump %EndOfFunctionDecl49
	b _EndOfFunctionDecl49
#	%EndOfFunctionDecl49
_EndOfFunctionDecl49:
	lw $s0, 64($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 292
	jr $ra
_merge:
	sub $sp, $sp, 204
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl50
_BeginOfFunctionDecl50:
#	$67 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop68
_ForLoop68:
#	$84 = slt $67 $49
	lw $t1, global_49
	slt $t3, $t2, $t1
#	br $84 %ForBody27 %OutOfFor28
	beqz $t3, _OutOfFor28
#	%ForBody27
_ForBody27:
#	$86 = mul $67 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 188($sp)
#	$87 = add $50 $86
	lw $t0, global_50
	lw $t1, 188($sp)
	add $t1, $t0, $t1
	sw $t1, 176($sp)
#	$88 = load 4 $87 0
	lw $t1, 176($sp)
	lw $t0, 0($t1)
	sw $t0, 184($sp)
#	$85 = seq $88 0
	lw $t0, 184($sp)
	li $t1, 0
	seq $t3, $t0, $t1
#	br $85 %consequence29 %alternative30
	beqz $t3, _alternative30
#	%consequence29
_consequence29:
#	$90 = add $67 1
	li $t1, 1
	add $t1, $t2, $t1
	sw $t1, 168($sp)
#	$68 = move $90
	lw $t0, 168($sp)
	move $t4, $t0
#	%ForLoop70
_ForLoop70:
#	$91 = slt $68 $49
	lw $t1, global_49
	slt $t1, $t4, $t1
	sw $t1, 172($sp)
#	br $91 %ForBody32 %OutOfFor33
	lw $t0, 172($sp)
	beqz $t0, _OutOfFor33
#	%ForBody32
_ForBody32:
#	$93 = mul $68 4
	li $t1, 4
	mul $t3, $t4, $t1
#	$94 = add $50 $93
	lw $t0, global_50
	add $t1, $t0, $t3
	sw $t1, 192($sp)
#	$95 = load 4 $94 0
	lw $t1, 192($sp)
	lw $t0, 0($t1)
	sw $t0, 200($sp)
#	$92 = sne $95 0
	lw $t0, 200($sp)
	li $t1, 0
	sne $t3, $t0, $t1
#	br $92 %consequence34 %alternative35
	beqz $t3, _alternative35
#	%consequence34
_consequence34:
#	nullcall swap $67 $68
	sw $t2, -8($sp)
	sw $t4, -4($sp)
	jal _swap
	move $t3, $v0
#	jump %OutOfFor33
	b _OutOfFor33
#	jump %OutOfIf36
	b _OutOfIf36
#	%alternative35
_alternative35:
#	jump %OutOfIf36
	b _OutOfIf36
#	%OutOfIf36
_OutOfIf36:
#	jump %continueFor71
	b _continueFor71
#	%continueFor71
_continueFor71:
#	$68 = add $68 1
	li $t1, 1
	add $t4, $t4, $t1
#	jump %ForLoop70
	b _ForLoop70
#	%OutOfFor33
_OutOfFor33:
#	jump %OutOfIf31
	b _OutOfIf31
#	%alternative30
_alternative30:
#	jump %OutOfIf31
	b _OutOfIf31
#	%OutOfIf31
_OutOfIf31:
#	jump %continueFor69
	b _continueFor69
#	%continueFor69
_continueFor69:
#	$67 = add $67 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop68
	b _ForLoop68
#	%OutOfFor28
_OutOfFor28:
#	$67 = move 0
	li $t0, 0
	move $t2, $t0
#	%ForLoop72
_ForLoop72:
#	$98 = slt $67 $49
	lw $t1, global_49
	slt $t3, $t2, $t1
#	br $98 %ForBody37 %OutOfFor38
	beqz $t3, _OutOfFor38
#	%ForBody37
_ForBody37:
#	$100 = mul $67 4
	li $t1, 4
	mul $t1, $t2, $t1
	sw $t1, 180($sp)
#	$101 = add $50 $100
	lw $t0, global_50
	lw $t1, 180($sp)
	add $t3, $t0, $t1
#	$102 = load 4 $101 0
	lw $t0, 0($t3)
	sw $t0, 196($sp)
#	$99 = seq $102 0
	lw $t0, 196($sp)
	li $t1, 0
	seq $t3, $t0, $t1
#	br $99 %consequence39 %alternative40
	beqz $t3, _alternative40
#	%consequence39
_consequence39:
#	$49 = move $67
	sw $t2, global_49
#	jump %OutOfFor38
	b _OutOfFor38
#	jump %OutOfIf41
	b _OutOfIf41
#	%alternative40
_alternative40:
#	jump %OutOfIf41
	b _OutOfIf41
#	%OutOfIf41
_OutOfIf41:
#	jump %continueFor73
	b _continueFor73
#	%continueFor73
_continueFor73:
#	$67 = add $67 1
	li $t1, 1
	add $t2, $t2, $t1
#	jump %ForLoop72
	b _ForLoop72
#	%OutOfFor38
_OutOfFor38:
#	jump %EndOfFunctionDecl51
	b _EndOfFunctionDecl51
#	%EndOfFunctionDecl51
_EndOfFunctionDecl51:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 204
	jr $ra
_move:
	sub $sp, $sp, 164
	sw $t2, 40($sp)
	sw $t3, 44($sp)
#	%BeginOfFunctionDecl52
_BeginOfFunctionDecl52:
#	$69 = move 0
	li $t0, 0
	move $t3, $t0
#	%ForLoop74
_ForLoop74:
#	$104 = slt $69 $49
	lw $t1, global_49
	slt $t1, $t3, $t1
	sw $t1, 132($sp)
#	br $104 %ForBody42 %OutOfFor43
	lw $t0, 132($sp)
	beqz $t0, _OutOfFor43
#	%ForBody42
_ForBody42:
#	$105 = mul $69 4
	li $t1, 4
	mul $t1, $t3, $t1
	sw $t1, 140($sp)
#	$106 = add $50 $105
	lw $t0, global_50
	lw $t1, 140($sp)
	add $t1, $t0, $t1
	sw $t1, 160($sp)
#	$107 = load 4 $106 0
	lw $t1, 160($sp)
	lw $t2, 0($t1)
#	$107 = sub $107 1
	li $t1, 1
	sub $t2, $t2, $t1
#	store 4 $106 $107 0
	lw $t1, 160($sp)
	sw $t2, 0($t1)
#	$109 = add $69 1
	li $t1, 1
	add $t2, $t3, $t1
#	$69 = move $109
	move $t3, $t2
#	%continueFor75
_continueFor75:
#	jump %ForLoop74
	b _ForLoop74
#	%OutOfFor43
_OutOfFor43:
#	$111 = mul $49 4
	lw $t0, global_49
	li $t1, 4
	mul $t1, $t0, $t1
	sw $t1, 152($sp)
#	$112 = add $50 $111
	lw $t0, global_50
	lw $t1, 152($sp)
	add $t1, $t0, $t1
	sw $t1, 156($sp)
#	store 4 $112 $49 0
	lw $t0, global_49
	lw $t1, 156($sp)
	sw $t0, 0($t1)
#	$113 = move $49
	lw $t0, global_49
	sw $t0, 144($sp)
#	$49 = add $49 1
	lw $t0, global_49
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_49
#	%EndOfFunctionDecl53
_EndOfFunctionDecl53:
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 164
	jr $ra
main:
	sub $sp, $sp, 368
	sw $t4, 48($sp)
	sw $t2, 40($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl54
_BeginOfFunctionDecl54:
#	$51 = move 48271
	li $t0, 48271
	sw $t0, global_51
#	$52 = move 2147483647
	li $t0, 2147483647
	sw $t0, global_52
#	$55 = move 1
	li $t0, 1
	sw $t0, global_55
#	$70 = move 0
	li $t0, 0
	sw $t0, 212($sp)
#	$71 = move 0
	li $t0, 0
	move $t2, $t0
#	$72 = move 0
	li $t0, 0
	move $t4, $t0
#	$116 = mul 3 7
	li $t0, 3
	li $t1, 7
	mul $t3, $t0, $t1
#	$115 = mul $116 10
	li $t1, 10
	mul $t3, $t3, $t1
#	$47 = move $115
	sw $t3, global_47
#	$48 = move 0
	li $t0, 0
	sw $t0, global_48
#	$121 = mul 100 4
	li $t0, 100
	li $t1, 4
	mul $t3, $t0, $t1
#	$121 = add $121 4
	li $t1, 4
	add $t3, $t3, $t1
#	$120 = alloc $121
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $120 100 0
	li $t0, 100
	sw $t0, 0($t3)
#	$120 = add $120 4
	li $t1, 4
	add $t3, $t3, $t1
#	$119 = move $120
#	$50 = move $119
	sw $t3, global_50
#	$123 = div $52 $51
	lw $t0, global_52
	lw $t1, global_51
	div $t3, $t0, $t1
#	$53 = move $123
	sw $t3, global_53
#	$125 = rem $52 $51
	lw $t0, global_52
	lw $t1, global_51
	rem $t3, $t0, $t1
#	$54 = move $125
	sw $t3, global_54
#	$126 = call pd $47
	lw $t0, global_47
	sw $t0, -4($sp)
	jal _pd
	move $t3, $v0
#	$127 = not $126
	xor $t3, $t3, 1
#	br $127 %consequence44 %alternative45
	beqz $t3, _alternative45
#	%consequence44
_consequence44:
#	nullcall println "Sorry, the number n must be a number s.t. there exists i satisfying n=1+2+...+i"
	la $a0, string_128
	jal func__println
	move $t3, $v0
#	ret 1
	li $v0, 1
#	jump %EndOfFunctionDecl55
	b _EndOfFunctionDecl55
#	jump %OutOfIf46
	b _OutOfIf46
#	%alternative45
_alternative45:
#	jump %OutOfIf46
	b _OutOfIf46
#	%OutOfIf46
_OutOfIf46:
#	nullcall println "Let's start!"
	la $a0, string_130
	jal func__println
	move $t3, $v0
#	nullcall initialize 3654898
	li $t0, 3654898
	sw $t0, -4($sp)
	jal _initialize
	move $t3, $v0
#	$136 = call random
	jal _random
	move $t3, $v0
#	$135 = rem $136 10
	li $t1, 10
	rem $t3, $t3, $t1
#	$134 = add $135 1
	li $t1, 1
	add $t3, $t3, $t1
#	$49 = move $134
	sw $t3, global_49
#	$137 = call toString $49
	lw $a0, global_49
	jal func__toString
	move $t3, $v0
#	nullcall println $137
	move $a0, $t3
	jal func__println
	move $t3, $v0
#	%ForLoop76
_ForLoop76:
#	$140 = sub $49 1
	lw $t0, global_49
	li $t1, 1
	sub $t3, $t0, $t1
#	$139 = slt $70 $140
	lw $t0, 212($sp)
	slt $t3, $t0, $t3
#	br $139 %ForBody47 %OutOfFor48
	beqz $t3, _OutOfFor48
#	%ForBody47
_ForBody47:
#	$142 = mul $70 4
	lw $t0, 212($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$143 = add $50 $142
	lw $t0, global_50
	add $t3, $t0, $t3
#	$146 = call random
	jal _random
	move $t5, $v0
#	$145 = rem $146 10
	li $t1, 10
	rem $t5, $t5, $t1
#	$144 = add $145 1
	li $t1, 1
	add $t5, $t5, $t1
#	store 4 $143 $144 0
	sw $t5, 0($t3)
#	%WhileLoop78
_WhileLoop78:
#	$149 = mul $70 4
	lw $t0, 212($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$150 = add $50 $149
	lw $t0, global_50
	add $t3, $t0, $t3
#	$151 = load 4 $150 0
	lw $t3, 0($t3)
#	$148 = add $151 $71
	add $t3, $t3, $t2
#	$147 = sgt $148 $47
	lw $t1, global_47
	sgt $t3, $t3, $t1
#	br $147 %WhileBody49 %OutOfWhile50
	beqz $t3, _OutOfWhile50
#	%WhileBody49
_WhileBody49:
#	$153 = mul $70 4
	lw $t0, 212($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$154 = add $50 $153
	lw $t0, global_50
	add $t3, $t0, $t3
#	$157 = call random
	jal _random
	move $t5, $v0
#	$156 = rem $157 10
	li $t1, 10
	rem $t5, $t5, $t1
#	$155 = add $156 1
	li $t1, 1
	add $t5, $t5, $t1
#	store 4 $154 $155 0
	sw $t5, 0($t3)
#	jump %WhileLoop78
	b _WhileLoop78
#	%OutOfWhile50
_OutOfWhile50:
#	$160 = mul $70 4
	lw $t0, 212($sp)
	li $t1, 4
	mul $t3, $t0, $t1
#	$161 = add $50 $160
	lw $t0, global_50
	add $t3, $t0, $t3
#	$162 = load 4 $161 0
	lw $t3, 0($t3)
#	$159 = add $71 $162
	add $t2, $t2, $t3
#	$71 = move $159
#	%continueFor77
_continueFor77:
#	$70 = add $70 1
	lw $t0, 212($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 212($sp)
#	jump %ForLoop76
	b _ForLoop76
#	%OutOfFor48
_OutOfFor48:
#	$164 = sub $49 1
	lw $t0, global_49
	li $t1, 1
	sub $t3, $t0, $t1
#	$165 = mul $164 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$166 = add $50 $165
	lw $t0, global_50
	add $t3, $t0, $t3
#	$167 = sub $47 $71
	lw $t0, global_47
	sub $t5, $t0, $t2
#	store 4 $166 $167 0
	sw $t5, 0($t3)
#	nullcall show
	jal _show
	move $t3, $v0
#	nullcall merge
	jal _merge
	move $t3, $v0
#	%WhileLoop79
_WhileLoop79:
#	$170 = call win
	jal _win
	move $t3, $v0
#	$171 = not $170
	xor $t3, $t3, 1
#	br $171 %WhileBody51 %OutOfWhile52
	beqz $t3, _OutOfWhile52
#	%WhileBody51
_WhileBody51:
#	$72 = add $72 1
	li $t1, 1
	add $t4, $t4, $t1
#	$173 = call toString $72
	move $a0, $t4
	jal func__toString
	move $t3, $v0
#	$174 = call stringConcatenate "step " $173
	la $a0, string_172
	move $a1, $t3
	jal func__stringConcatenate
	move $t3, $v0
#	$176 = call stringConcatenate $174 ":"
	move $a0, $t3
	la $a1, string_175
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall println $176
	move $a0, $t3
	jal func__println
	move $t3, $v0
#	nullcall move
	jal _move
	move $t3, $v0
#	nullcall merge
	jal _merge
	move $t3, $v0
#	nullcall show
	jal _show
	move $t3, $v0
#	jump %WhileLoop79
	b _WhileLoop79
#	%OutOfWhile52
_OutOfWhile52:
#	$182 = call toString $72
	move $a0, $t4
	jal func__toString
	move $t3, $v0
#	$183 = call stringConcatenate "Total: " $182
	la $a0, string_181
	move $a1, $t3
	jal func__stringConcatenate
	move $t3, $v0
#	$185 = call stringConcatenate $183 " step(s)"
	move $a0, $t3
	la $a1, string_184
	jal func__stringConcatenate
	move $t3, $v0
#	nullcall println $185
	move $a0, $t3
	jal func__println
	move $t3, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl55
	b _EndOfFunctionDecl55
#	%EndOfFunctionDecl55
_EndOfFunctionDecl55:
	lw $ra, 120($sp)
	lw $t4, 48($sp)
	lw $t2, 40($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 368
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_47:
.space 4
.align 2
global_48:
.space 4
.align 2
global_49:
.space 4
.align 2
global_50:
.space 4
.align 2
global_51:
.space 4
.align 2
global_52:
.space 4
.align 2
global_53:
.space 4
.align 2
global_54:
.space 4
.align 2
global_55:
.space 4
.align 2
.word 1
string_33:
.asciiz " "
.align 2
.word 0
string_36:
.asciiz ""
.align 2
.word 79
string_128:
.asciiz "Sorry, the number n must be a number s.t. there exists i satisfying n=1+2+...+i"
.align 2
.word 12
string_130:
.asciiz "Let's start!"
.align 2
.word 5
string_172:
.asciiz "step "
.align 2
.word 1
string_175:
.asciiz ":"
.align 2
.word 7
string_181:
.asciiz "Total: "
.align 2
.word 8
string_184:
.asciiz " step(s)"
.align 2
