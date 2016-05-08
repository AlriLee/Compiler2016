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
_calc:
	sub $sp, $sp, 236
	sw $ra, 120($sp)
_BeginOfFunctionDecl59:
	lw $a0, 232($sp)
	jal func__length
	sw $v0, 140($sp)
	lw $t0, 140($sp)
	sw $t0, 200($sp)
	li $t0, 1
	lw $t1, 200($sp)
	seq $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	beqz $t0, _alternative1
_consequence0:
	lw $v0, 232($sp)
	b _EndOfFunctionDecl60
	b _OutOfIf2
_alternative1:
	b _OutOfIf2
_OutOfIf2:
	lw $t0, 200($sp)
	li $t1, 2
	div $t1, $t0, $t1
	sw $t1, 188($sp)
	lw $t0, 188($sp)
	sw $t0, 224($sp)
	lw $t0, 224($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $a0, 232($sp)
	li $a1, 0
	lw $a2, 164($sp)
	jal func__substring
	sw $v0, 228($sp)
	lw $t0, 228($sp)
	sw $t0, -4($sp)
	jal _calc
	sw $v0, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 176($sp)
	lw $t0, 200($sp)
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 128($sp)
	lw $a0, 232($sp)
	lw $a1, 224($sp)
	lw $a2, 128($sp)
	jal func__substring
	sw $v0, 204($sp)
	lw $t0, 204($sp)
	sw $t0, -4($sp)
	jal _calc
	sw $v0, 208($sp)
	lw $t0, 208($sp)
	sw $t0, 192($sp)
	lw $a0, 176($sp)
	lw $a1, 192($sp)
	jal func__stringLess
	sw $v0, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _alternative4
_consequence3:
	lw $a0, 176($sp)
	lw $a1, 192($sp)
	jal func__stringConcatenate
	sw $v0, 196($sp)
	lw $v0, 196($sp)
	b _EndOfFunctionDecl60
	b _OutOfIf5
_alternative4:
	lw $a0, 176($sp)
	lw $a1, 192($sp)
	jal func__stringIsEqual
	sw $v0, 172($sp)
	lw $t0, 172($sp)
	beqz $t0, _alternative7
_consequence6:
	lw $a0, 176($sp)
	li $a1, 0
	jal func__ord
	sw $v0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, 180($sp)
	lw $a0, 192($sp)
	li $a1, 0
	jal func__ord
	sw $v0, 148($sp)
	lw $t0, 148($sp)
	sw $t0, 168($sp)
	lw $t0, 180($sp)
	lw $t1, 168($sp)
	slt $t1, $t0, $t1
	sw $t1, 156($sp)
	lw $t0, 156($sp)
	beqz $t0, _alternative10
_consequence9:
	lw $a0, 176($sp)
	lw $a1, 192($sp)
	jal func__stringConcatenate
	sw $v0, 160($sp)
	lw $v0, 160($sp)
	b _EndOfFunctionDecl60
	b _OutOfIf11
_alternative10:
	b _OutOfIf11
_OutOfIf11:
	lw $a0, 192($sp)
	lw $a1, 176($sp)
	jal func__stringConcatenate
	sw $v0, 216($sp)
	lw $v0, 216($sp)
	b _EndOfFunctionDecl60
	b _OutOfIf8
_alternative7:
	lw $a0, 176($sp)
	lw $a1, 192($sp)
	jal func__stringLarge
	sw $v0, 212($sp)
	lw $t0, 212($sp)
	beqz $t0, _alternative13
_consequence12:
	lw $a0, 192($sp)
	lw $a1, 176($sp)
	jal func__stringConcatenate
	sw $v0, 220($sp)
	lw $v0, 220($sp)
	b _EndOfFunctionDecl60
	b _OutOfIf14
_alternative13:
	b _OutOfIf14
_OutOfIf14:
	b _OutOfIf8
_OutOfIf8:
	b _OutOfIf5
_OutOfIf5:
	la $a0, string_19
	jal func__println
	sw $v0, 184($sp)
_EndOfFunctionDecl60:
	lw $ra, 120($sp)
	add $sp, $sp, 236
	jr $ra
main:
	sub $sp, $sp, 168
	sw $ra, 120($sp)
_BeginOfFunctionDecl61:
	jal func__getString
	sw $v0, 128($sp)
	lw $t0, 128($sp)
	sw $t0, global_101
	jal func__getString
	sw $v0, 140($sp)
	lw $t0, 140($sp)
	sw $t0, global_102
	lw $a0, global_102
	jal func__parseInt
	sw $v0, 132($sp)
	lw $t0, 132($sp)
	sw $t0, global_104
	lw $a0, global_101
	jal func__length
	sw $v0, 148($sp)
	lw $t0, 148($sp)
	lw $t1, global_104
	slt $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	beqz $t0, _alternative16
_consequence15:
	la $a0, string_29
	jal func__println
	sw $v0, 160($sp)
	li $v0, 0
	b _EndOfFunctionDecl62
	b _OutOfIf17
_alternative16:
	b _OutOfIf17
_OutOfIf17:
	lw $t0, global_104
	li $t1, 1
	sub $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $a0, global_101
	li $a1, 0
	lw $a2, 144($sp)
	jal func__substring
	sw $v0, 152($sp)
	lw $t0, 152($sp)
	sw $t0, -4($sp)
	jal _calc
	sw $v0, 156($sp)
	lw $t0, 156($sp)
	sw $t0, global_103
	lw $a0, global_103
	jal func__println
	sw $v0, 164($sp)
	li $v0, 0
	b _EndOfFunctionDecl62
_EndOfFunctionDecl62:
	lw $ra, 120($sp)
	add $sp, $sp, 168
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_101:
.space 4
.align 2
global_102:
.space 4
.align 2
global_103:
.space 4
.align 2
global_104:
.space 4
.align 2
.word 11
string_19:
.asciiz "Never Ever!"
.align 2
.word 13
string_29:
.asciiz "length error!"
.align 2
