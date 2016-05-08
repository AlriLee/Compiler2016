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
	sub $sp, $sp, 276
	sw $s0, 64($sp)
	sw $t4, 48($sp)
	sw $t6, 56($sp)
	sw $s1, 68($sp)
	sw $t2, 40($sp)
	sw $t7, 60($sp)
	sw $t5, 52($sp)
	sw $t3, 44($sp)
	sw $ra, 120($sp)
#	%BeginOfFunctionDecl54
_BeginOfFunctionDecl54:
#	$129 = move 10000
	li $t0, 10000
	move $t2, $t0
#	$130 = move 0
	li $t0, 0
	move $t5, $t0
#	$131 = move 2800
	li $t0, 2800
	sw $t0, 184($sp)
#	$132 = move 0
	li $t0, 0
	move $s1, $t0
#	$133 = move 0
	li $t0, 0
	move $t4, $t0
#	$2 = mul 2801 4
	li $t0, 2801
	li $t1, 4
	mul $t3, $t0, $t1
#	$2 = add $2 4
	li $t1, 4
	add $t3, $t3, $t1
#	$1 = alloc $2
	move $a0, $t3
	li $v0, 9
	syscall
	move $t3, $v0
#	store 4 $1 2801 0
	li $t0, 2801
	sw $t0, 0($t3)
#	$1 = add $1 4
	li $t1, 4
	add $t3, $t3, $t1
#	$0 = move $1
#	$134 = move $0
	move $t7, $t3
#	$135 = move 0
	li $t0, 0
	move $t6, $t0
#	%ForLoop56
_ForLoop56:
#	$4 = sub $130 $131
	lw $t1, 184($sp)
	sub $t3, $t5, $t1
#	$3 = sne $4 0
	li $t1, 0
	sne $t3, $t3, $t1
#	br $3 %ForBody0 %OutOfFor1
	beqz $t3, _OutOfFor1
#	%ForBody0
_ForBody0:
#	$6 = move $130
	move $t3, $t5
#	$130 = add $130 1
	li $t1, 1
	add $t5, $t5, $t1
#	$7 = mul $6 4
	li $t1, 4
	mul $t3, $t3, $t1
#	$8 = add $134 $7
	add $t5, $t7, $t3
#	$9 = div $129 5
	li $t1, 5
	div $t3, $t2, $t1
#	store 4 $8 $9 0
	sw $t3, 0($t5)
#	%continueFor57
_continueFor57:
#	jump %ForLoop56
	b _ForLoop56
#	%OutOfFor1
_OutOfFor1:
#	jump %ForLoop58
	b _ForLoop58
#	%ForLoop58
_ForLoop58:
#	jump %ForBody2
	b _ForBody2
#	%ForBody2
_ForBody2:
#	$132 = move 0
	li $t0, 0
	move $s1, $t0
#	$12 = mul $131 2
	lw $t0, 184($sp)
	li $t1, 2
	mul $t3, $t0, $t1
#	$135 = move $12
	move $t6, $t3
#	$13 = seq $135 0
	li $t1, 0
	seq $t3, $t6, $t1
#	br $13 %consequence4 %alternative5
	beqz $t3, _alternative5
#	%consequence4
_consequence4:
#	jump %OutOfFor3
	b _OutOfFor3
#	jump %OutOfIf6
	b _OutOfIf6
#	%alternative5
_alternative5:
#	jump %OutOfIf6
	b _OutOfIf6
#	%OutOfIf6
_OutOfIf6:
#	$130 = move $131
	lw $t0, 184($sp)
	move $t5, $t0
#	%ForLoop60
_ForLoop60:
#	jump %ForBody7
	b _ForBody7
#	%ForBody7
_ForBody7:
#	$18 = mul $130 4
	li $t1, 4
	mul $t3, $t5, $t1
#	$19 = add $134 $18
	add $t3, $t7, $t3
#	$20 = load 4 $19 0
	lw $t3, 0($t3)
#	$17 = mul $20 $129
	mul $t3, $t3, $t2
#	$16 = add $132 $17
	add $t3, $s1, $t3
#	$132 = move $16
	move $s1, $t3
#	$22 = mul $130 4
	li $t1, 4
	mul $t3, $t5, $t1
#	$23 = add $134 $22
	add $s0, $t7, $t3
#	$135 = sub $135 1
	li $t1, 1
	sub $t6, $t6, $t1
#	$24 = rem $132 $135
	rem $t3, $s1, $t6
#	store 4 $23 $24 0
	sw $t3, 0($s0)
#	$27 = move $135
	move $t3, $t6
#	$135 = sub $135 1
	li $t1, 1
	sub $t6, $t6, $t1
#	$26 = div $132 $27
	div $t3, $s1, $t3
#	$132 = move $26
	move $s1, $t3
#	$130 = sub $130 1
	li $t1, 1
	sub $t5, $t5, $t1
#	$28 = seq $130 0
	li $t1, 0
	seq $t3, $t5, $t1
#	br $28 %consequence9 %alternative10
	beqz $t3, _alternative10
#	%consequence9
_consequence9:
#	jump %OutOfFor8
	b _OutOfFor8
#	jump %OutOfIf11
	b _OutOfIf11
#	%alternative10
_alternative10:
#	jump %OutOfIf11
	b _OutOfIf11
#	%OutOfIf11
_OutOfIf11:
#	jump %continueFor61
	b _continueFor61
#	%continueFor61
_continueFor61:
#	$30 = mul $132 $130
	mul $t3, $s1, $t5
#	$132 = move $30
	move $s1, $t3
#	jump %ForLoop60
	b _ForLoop60
#	%OutOfFor8
_OutOfFor8:
#	$32 = sub $131 14
	lw $t0, 184($sp)
	li $t1, 14
	sub $t3, $t0, $t1
#	$131 = move $32
	sw $t3, 184($sp)
#	$34 = div $132 $129
	div $t3, $s1, $t2
#	$33 = add $133 $34
	add $t3, $t4, $t3
#	$35 = call toString $33
	move $a0, $t3
	jal func__toString
	move $t3, $v0
#	nullcall print $35
	move $a0, $t3
	jal func__print
	move $t3, $v0
#	%continueFor59
_continueFor59:
#	$38 = rem $132 $129
	rem $t3, $s1, $t2
#	$133 = move $38
	move $t4, $t3
#	jump %ForLoop58
	b _ForLoop58
#	%OutOfFor3
_OutOfFor3:
#	nullcall print "\n"
	la $a0, string_39
	jal func__print
	move $t3, $v0
#	ret 0
	li $v0, 0
#	jump %EndOfFunctionDecl55
	b _EndOfFunctionDecl55
#	%EndOfFunctionDecl55
_EndOfFunctionDecl55:
	lw $ra, 120($sp)
	lw $s0, 64($sp)
	lw $t4, 48($sp)
	lw $t6, 56($sp)
	lw $s1, 68($sp)
	lw $t2, 40($sp)
	lw $t7, 60($sp)
	lw $t5, 52($sp)
	lw $t3, 44($sp)
	add $sp, $sp, 276
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
.word 1
string_39:
.asciiz "\n"
.align 2
