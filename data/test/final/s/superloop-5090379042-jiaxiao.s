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
	sub $sp, $sp, 540
	sw $ra, 120($sp)
_BeginOfFunctionDecl2034:
	li $t0, 99
	sw $t0, global_7161
	li $t0, 100
	sw $t0, global_7162
	li $t0, 101
	sw $t0, global_7163
	li $t0, 102
	sw $t0, global_7164
	li $t0, 0
	sw $t0, global_7165
	jal func__getInt
	sw $v0, 388($sp)
	lw $t0, 388($sp)
	sw $t0, global_7160
	li $t0, 1
	sw $t0, 456($sp)
_ForLoop2036:
	lw $t0, 456($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 492($sp)
	lw $t0, 492($sp)
	beqz $t0, _OutOfFor2049
	b _ForBody2048
_ForBody2048:
	li $t0, 1
	sw $t0, 208($sp)
_ForLoop2038:
	lw $t0, 208($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 488($sp)
	lw $t0, 488($sp)
	beqz $t0, _OutOfFor2051
	b _ForBody2050
_ForBody2050:
	li $t0, 1
	sw $t0, 192($sp)
_ForLoop2040:
	lw $t0, 192($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 404($sp)
	lw $t0, 404($sp)
	beqz $t0, _OutOfFor2053
	b _ForBody2052
_ForBody2052:
	li $t0, 1
	sw $t0, 236($sp)
_ForLoop2042:
	lw $t0, 236($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 308($sp)
	lw $t0, 308($sp)
	beqz $t0, _OutOfFor2055
	b _ForBody2054
_ForBody2054:
	li $t0, 1
	sw $t0, 272($sp)
_ForLoop2044:
	lw $t0, 272($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 180($sp)
	lw $t0, 180($sp)
	beqz $t0, _OutOfFor2057
	b _ForBody2056
_ForBody2056:
	li $t0, 1
	sw $t0, 284($sp)
_ForLoop2046:
	lw $t0, 284($sp)
	lw $t1, global_7160
	sle $t1, $t0, $t1
	sw $t1, 400($sp)
	lw $t0, 400($sp)
	beqz $t0, _OutOfFor2059
	b _ForBody2058
_ForBody2058:
	lw $t0, 456($sp)
	lw $t1, 208($sp)
	sne $t1, $t0, $t1
	sw $t1, 440($sp)
	lw $t0, 440($sp)
	beqz $t0, _logicalFalse2064
	b _logicalTrue2063
_logicalTrue2063:
	lw $t0, 456($sp)
	lw $t1, 192($sp)
	sne $t1, $t0, $t1
	sw $t1, 160($sp)
	lw $t0, 160($sp)
	sw $t0, 532($sp)
	b _logicalMerge2065
_logicalFalse2064:
	li $t0, 0
	sw $t0, 532($sp)
	b _logicalMerge2065
_logicalMerge2065:
	lw $t0, 532($sp)
	beqz $t0, _logicalFalse2067
	b _logicalTrue2066
_logicalTrue2066:
	lw $t0, 456($sp)
	lw $t1, 236($sp)
	sne $t1, $t0, $t1
	sw $t1, 464($sp)
	lw $t0, 464($sp)
	sw $t0, 228($sp)
	b _logicalMerge2068
_logicalFalse2067:
	li $t0, 0
	sw $t0, 228($sp)
	b _logicalMerge2068
_logicalMerge2068:
	lw $t0, 228($sp)
	beqz $t0, _logicalFalse2070
	b _logicalTrue2069
_logicalTrue2069:
	lw $t0, 456($sp)
	lw $t1, 272($sp)
	sne $t1, $t0, $t1
	sw $t1, 436($sp)
	lw $t0, 436($sp)
	sw $t0, 244($sp)
	b _logicalMerge2071
_logicalFalse2070:
	li $t0, 0
	sw $t0, 244($sp)
	b _logicalMerge2071
_logicalMerge2071:
	lw $t0, 244($sp)
	beqz $t0, _logicalFalse2073
	b _logicalTrue2072
_logicalTrue2072:
	lw $t0, 456($sp)
	lw $t1, 284($sp)
	sne $t1, $t0, $t1
	sw $t1, 512($sp)
	lw $t0, 512($sp)
	sw $t0, 276($sp)
	b _logicalMerge2074
_logicalFalse2073:
	li $t0, 0
	sw $t0, 276($sp)
	b _logicalMerge2074
_logicalMerge2074:
	lw $t0, 276($sp)
	beqz $t0, _logicalFalse2076
	b _logicalTrue2075
_logicalTrue2075:
	lw $t0, 456($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 432($sp)
	lw $t0, 432($sp)
	sw $t0, 292($sp)
	b _logicalMerge2077
_logicalFalse2076:
	li $t0, 0
	sw $t0, 292($sp)
	b _logicalMerge2077
_logicalMerge2077:
	lw $t0, 292($sp)
	beqz $t0, _logicalFalse2079
	b _logicalTrue2078
_logicalTrue2078:
	lw $t0, 456($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 288($sp)
	lw $t0, 288($sp)
	sw $t0, 332($sp)
	b _logicalMerge2080
_logicalFalse2079:
	li $t0, 0
	sw $t0, 332($sp)
	b _logicalMerge2080
_logicalMerge2080:
	lw $t0, 332($sp)
	beqz $t0, _logicalFalse2082
	b _logicalTrue2081
_logicalTrue2081:
	lw $t0, 456($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 172($sp)
	lw $t0, 172($sp)
	sw $t0, 336($sp)
	b _logicalMerge2083
_logicalFalse2082:
	li $t0, 0
	sw $t0, 336($sp)
	b _logicalMerge2083
_logicalMerge2083:
	lw $t0, 336($sp)
	beqz $t0, _logicalFalse2085
	b _logicalTrue2084
_logicalTrue2084:
	lw $t0, 456($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 508($sp)
	lw $t0, 508($sp)
	sw $t0, 408($sp)
	b _logicalMerge2086
_logicalFalse2085:
	li $t0, 0
	sw $t0, 408($sp)
	b _logicalMerge2086
_logicalMerge2086:
	lw $t0, 408($sp)
	beqz $t0, _logicalFalse2088
	b _logicalTrue2087
_logicalTrue2087:
	lw $t0, 208($sp)
	lw $t1, 192($sp)
	sne $t1, $t0, $t1
	sw $t1, 148($sp)
	lw $t0, 148($sp)
	sw $t0, 504($sp)
	b _logicalMerge2089
_logicalFalse2088:
	li $t0, 0
	sw $t0, 504($sp)
	b _logicalMerge2089
_logicalMerge2089:
	lw $t0, 504($sp)
	beqz $t0, _logicalFalse2091
	b _logicalTrue2090
_logicalTrue2090:
	lw $t0, 208($sp)
	lw $t1, 236($sp)
	sne $t1, $t0, $t1
	sw $t1, 252($sp)
	lw $t0, 252($sp)
	sw $t0, 412($sp)
	b _logicalMerge2092
_logicalFalse2091:
	li $t0, 0
	sw $t0, 412($sp)
	b _logicalMerge2092
_logicalMerge2092:
	lw $t0, 412($sp)
	beqz $t0, _logicalFalse2094
	b _logicalTrue2093
_logicalTrue2093:
	lw $t0, 208($sp)
	lw $t1, 272($sp)
	sne $t1, $t0, $t1
	sw $t1, 376($sp)
	lw $t0, 376($sp)
	sw $t0, 260($sp)
	b _logicalMerge2095
_logicalFalse2094:
	li $t0, 0
	sw $t0, 260($sp)
	b _logicalMerge2095
_logicalMerge2095:
	lw $t0, 260($sp)
	beqz $t0, _logicalFalse2097
	b _logicalTrue2096
_logicalTrue2096:
	lw $t0, 208($sp)
	lw $t1, 284($sp)
	sne $t1, $t0, $t1
	sw $t1, 428($sp)
	lw $t0, 428($sp)
	sw $t0, 468($sp)
	b _logicalMerge2098
_logicalFalse2097:
	li $t0, 0
	sw $t0, 468($sp)
	b _logicalMerge2098
_logicalMerge2098:
	lw $t0, 468($sp)
	beqz $t0, _logicalFalse2100
	b _logicalTrue2099
_logicalTrue2099:
	lw $t0, 208($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 232($sp)
	lw $t0, 232($sp)
	sw $t0, 340($sp)
	b _logicalMerge2101
_logicalFalse2100:
	li $t0, 0
	sw $t0, 340($sp)
	b _logicalMerge2101
_logicalMerge2101:
	lw $t0, 340($sp)
	beqz $t0, _logicalFalse2103
	b _logicalTrue2102
_logicalTrue2102:
	lw $t0, 208($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 248($sp)
	lw $t0, 248($sp)
	sw $t0, 352($sp)
	b _logicalMerge2104
_logicalFalse2103:
	li $t0, 0
	sw $t0, 352($sp)
	b _logicalMerge2104
_logicalMerge2104:
	lw $t0, 352($sp)
	beqz $t0, _logicalFalse2106
	b _logicalTrue2105
_logicalTrue2105:
	lw $t0, 208($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 524($sp)
	lw $t0, 524($sp)
	sw $t0, 324($sp)
	b _logicalMerge2107
_logicalFalse2106:
	li $t0, 0
	sw $t0, 324($sp)
	b _logicalMerge2107
_logicalMerge2107:
	lw $t0, 324($sp)
	beqz $t0, _logicalFalse2109
	b _logicalTrue2108
_logicalTrue2108:
	lw $t0, 208($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 360($sp)
	lw $t0, 360($sp)
	sw $t0, 280($sp)
	b _logicalMerge2110
_logicalFalse2109:
	li $t0, 0
	sw $t0, 280($sp)
	b _logicalMerge2110
_logicalMerge2110:
	lw $t0, 280($sp)
	beqz $t0, _logicalFalse2112
	b _logicalTrue2111
_logicalTrue2111:
	lw $t0, 192($sp)
	lw $t1, 236($sp)
	sne $t1, $t0, $t1
	sw $t1, 196($sp)
	lw $t0, 196($sp)
	sw $t0, 328($sp)
	b _logicalMerge2113
_logicalFalse2112:
	li $t0, 0
	sw $t0, 328($sp)
	b _logicalMerge2113
_logicalMerge2113:
	lw $t0, 328($sp)
	beqz $t0, _logicalFalse2115
	b _logicalTrue2114
_logicalTrue2114:
	lw $t0, 192($sp)
	lw $t1, 272($sp)
	sne $t1, $t0, $t1
	sw $t1, 484($sp)
	lw $t0, 484($sp)
	sw $t0, 472($sp)
	b _logicalMerge2116
_logicalFalse2115:
	li $t0, 0
	sw $t0, 472($sp)
	b _logicalMerge2116
_logicalMerge2116:
	lw $t0, 472($sp)
	beqz $t0, _logicalFalse2118
	b _logicalTrue2117
_logicalTrue2117:
	lw $t0, 192($sp)
	lw $t1, 284($sp)
	sne $t1, $t0, $t1
	sw $t1, 144($sp)
	lw $t0, 144($sp)
	sw $t0, 480($sp)
	b _logicalMerge2119
_logicalFalse2118:
	li $t0, 0
	sw $t0, 480($sp)
	b _logicalMerge2119
_logicalMerge2119:
	lw $t0, 480($sp)
	beqz $t0, _logicalFalse2121
	b _logicalTrue2120
_logicalTrue2120:
	lw $t0, 192($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 344($sp)
	lw $t0, 344($sp)
	sw $t0, 212($sp)
	b _logicalMerge2122
_logicalFalse2121:
	li $t0, 0
	sw $t0, 212($sp)
	b _logicalMerge2122
_logicalMerge2122:
	lw $t0, 212($sp)
	beqz $t0, _logicalFalse2124
	b _logicalTrue2123
_logicalTrue2123:
	lw $t0, 192($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 368($sp)
	lw $t0, 368($sp)
	sw $t0, 520($sp)
	b _logicalMerge2125
_logicalFalse2124:
	li $t0, 0
	sw $t0, 520($sp)
	b _logicalMerge2125
_logicalMerge2125:
	lw $t0, 520($sp)
	beqz $t0, _logicalFalse2127
	b _logicalTrue2126
_logicalTrue2126:
	lw $t0, 192($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 256($sp)
	lw $t0, 256($sp)
	sw $t0, 356($sp)
	b _logicalMerge2128
_logicalFalse2127:
	li $t0, 0
	sw $t0, 356($sp)
	b _logicalMerge2128
_logicalMerge2128:
	lw $t0, 356($sp)
	beqz $t0, _logicalFalse2130
	b _logicalTrue2129
_logicalTrue2129:
	lw $t0, 192($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 184($sp)
	lw $t0, 184($sp)
	sw $t0, 420($sp)
	b _logicalMerge2131
_logicalFalse2130:
	li $t0, 0
	sw $t0, 420($sp)
	b _logicalMerge2131
_logicalMerge2131:
	lw $t0, 420($sp)
	beqz $t0, _logicalFalse2133
	b _logicalTrue2132
_logicalTrue2132:
	lw $t0, 236($sp)
	lw $t1, 272($sp)
	sne $t1, $t0, $t1
	sw $t1, 264($sp)
	lw $t0, 264($sp)
	sw $t0, 220($sp)
	b _logicalMerge2134
_logicalFalse2133:
	li $t0, 0
	sw $t0, 220($sp)
	b _logicalMerge2134
_logicalMerge2134:
	lw $t0, 220($sp)
	beqz $t0, _logicalFalse2136
	b _logicalTrue2135
_logicalTrue2135:
	lw $t0, 236($sp)
	lw $t1, 284($sp)
	sne $t1, $t0, $t1
	sw $t1, 496($sp)
	lw $t0, 496($sp)
	sw $t0, 156($sp)
	b _logicalMerge2137
_logicalFalse2136:
	li $t0, 0
	sw $t0, 156($sp)
	b _logicalMerge2137
_logicalMerge2137:
	lw $t0, 156($sp)
	beqz $t0, _logicalFalse2139
	b _logicalTrue2138
_logicalTrue2138:
	lw $t0, 236($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 416($sp)
	lw $t0, 416($sp)
	sw $t0, 364($sp)
	b _logicalMerge2140
_logicalFalse2139:
	li $t0, 0
	sw $t0, 364($sp)
	b _logicalMerge2140
_logicalMerge2140:
	lw $t0, 364($sp)
	beqz $t0, _logicalFalse2142
	b _logicalTrue2141
_logicalTrue2141:
	lw $t0, 236($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 448($sp)
	lw $t0, 448($sp)
	sw $t0, 424($sp)
	b _logicalMerge2143
_logicalFalse2142:
	li $t0, 0
	sw $t0, 424($sp)
	b _logicalMerge2143
_logicalMerge2143:
	lw $t0, 424($sp)
	beqz $t0, _logicalFalse2145
	b _logicalTrue2144
_logicalTrue2144:
	lw $t0, 236($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 164($sp)
	lw $t0, 164($sp)
	sw $t0, 500($sp)
	b _logicalMerge2146
_logicalFalse2145:
	li $t0, 0
	sw $t0, 500($sp)
	b _logicalMerge2146
_logicalMerge2146:
	lw $t0, 500($sp)
	beqz $t0, _logicalFalse2148
	b _logicalTrue2147
_logicalTrue2147:
	lw $t0, 236($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 452($sp)
	lw $t0, 452($sp)
	sw $t0, 268($sp)
	b _logicalMerge2149
_logicalFalse2148:
	li $t0, 0
	sw $t0, 268($sp)
	b _logicalMerge2149
_logicalMerge2149:
	lw $t0, 268($sp)
	beqz $t0, _logicalFalse2151
	b _logicalTrue2150
_logicalTrue2150:
	lw $t0, 272($sp)
	lw $t1, 284($sp)
	sne $t1, $t0, $t1
	sw $t1, 392($sp)
	lw $t0, 392($sp)
	sw $t0, 204($sp)
	b _logicalMerge2152
_logicalFalse2151:
	li $t0, 0
	sw $t0, 204($sp)
	b _logicalMerge2152
_logicalMerge2152:
	lw $t0, 204($sp)
	beqz $t0, _logicalFalse2154
	b _logicalTrue2153
_logicalTrue2153:
	lw $t0, 272($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 152($sp)
	lw $t0, 152($sp)
	sw $t0, 216($sp)
	b _logicalMerge2155
_logicalFalse2154:
	li $t0, 0
	sw $t0, 216($sp)
	b _logicalMerge2155
_logicalMerge2155:
	lw $t0, 216($sp)
	beqz $t0, _logicalFalse2157
	b _logicalTrue2156
_logicalTrue2156:
	lw $t0, 272($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 296($sp)
	lw $t0, 296($sp)
	sw $t0, 132($sp)
	b _logicalMerge2158
_logicalFalse2157:
	li $t0, 0
	sw $t0, 132($sp)
	b _logicalMerge2158
_logicalMerge2158:
	lw $t0, 132($sp)
	beqz $t0, _logicalFalse2160
	b _logicalTrue2159
_logicalTrue2159:
	lw $t0, 272($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 380($sp)
	lw $t0, 380($sp)
	sw $t0, 460($sp)
	b _logicalMerge2161
_logicalFalse2160:
	li $t0, 0
	sw $t0, 460($sp)
	b _logicalMerge2161
_logicalMerge2161:
	lw $t0, 460($sp)
	beqz $t0, _logicalFalse2163
	b _logicalTrue2162
_logicalTrue2162:
	lw $t0, 272($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 240($sp)
	lw $t0, 240($sp)
	sw $t0, 348($sp)
	b _logicalMerge2164
_logicalFalse2163:
	li $t0, 0
	sw $t0, 348($sp)
	b _logicalMerge2164
_logicalMerge2164:
	lw $t0, 348($sp)
	beqz $t0, _logicalFalse2166
	b _logicalTrue2165
_logicalTrue2165:
	lw $t0, 284($sp)
	lw $t1, global_7161
	sne $t1, $t0, $t1
	sw $t1, 140($sp)
	lw $t0, 140($sp)
	sw $t0, 300($sp)
	b _logicalMerge2167
_logicalFalse2166:
	li $t0, 0
	sw $t0, 300($sp)
	b _logicalMerge2167
_logicalMerge2167:
	lw $t0, 300($sp)
	beqz $t0, _logicalFalse2169
	b _logicalTrue2168
_logicalTrue2168:
	lw $t0, 284($sp)
	lw $t1, global_7162
	sne $t1, $t0, $t1
	sw $t1, 304($sp)
	lw $t0, 304($sp)
	sw $t0, 536($sp)
	b _logicalMerge2170
_logicalFalse2169:
	li $t0, 0
	sw $t0, 536($sp)
	b _logicalMerge2170
_logicalMerge2170:
	lw $t0, 536($sp)
	beqz $t0, _logicalFalse2172
	b _logicalTrue2171
_logicalTrue2171:
	lw $t0, 284($sp)
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 384($sp)
	lw $t0, 384($sp)
	sw $t0, 372($sp)
	b _logicalMerge2173
_logicalFalse2172:
	li $t0, 0
	sw $t0, 372($sp)
	b _logicalMerge2173
_logicalMerge2173:
	lw $t0, 372($sp)
	beqz $t0, _logicalFalse2175
	b _logicalTrue2174
_logicalTrue2174:
	lw $t0, 284($sp)
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 200($sp)
	lw $t0, 200($sp)
	sw $t0, 128($sp)
	b _logicalMerge2176
_logicalFalse2175:
	li $t0, 0
	sw $t0, 128($sp)
	b _logicalMerge2176
_logicalMerge2176:
	lw $t0, 128($sp)
	beqz $t0, _logicalFalse2178
	b _logicalTrue2177
_logicalTrue2177:
	lw $t0, global_7162
	lw $t1, global_7163
	sne $t1, $t0, $t1
	sw $t1, 136($sp)
	lw $t0, 136($sp)
	sw $t0, 396($sp)
	b _logicalMerge2179
_logicalFalse2178:
	li $t0, 0
	sw $t0, 396($sp)
	b _logicalMerge2179
_logicalMerge2179:
	lw $t0, 396($sp)
	beqz $t0, _logicalFalse2181
	b _logicalTrue2180
_logicalTrue2180:
	lw $t0, global_7161
	lw $t1, global_7164
	sne $t1, $t0, $t1
	sw $t1, 224($sp)
	lw $t0, 224($sp)
	sw $t0, 188($sp)
	b _logicalMerge2182
_logicalFalse2181:
	li $t0, 0
	sw $t0, 188($sp)
	b _logicalMerge2182
_logicalMerge2182:
	lw $t0, 188($sp)
	beqz $t0, _alternative2061
	b _consequence2060
_consequence2060:
	lw $t0, global_7165
	sw $t0, 444($sp)
	lw $t0, global_7165
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_7165
	b _OutOfIf2062
_alternative2061:
	b _OutOfIf2062
_OutOfIf2062:
	b _continueFor2047
_continueFor2047:
	lw $t0, 284($sp)
	sw $t0, 320($sp)
	lw $t0, 284($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 284($sp)
	b _ForLoop2046
_OutOfFor2059:
	b _continueFor2045
_continueFor2045:
	lw $t0, 272($sp)
	sw $t0, 476($sp)
	lw $t0, 272($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 272($sp)
	b _ForLoop2044
_OutOfFor2057:
	b _continueFor2043
_continueFor2043:
	lw $t0, 236($sp)
	sw $t0, 516($sp)
	lw $t0, 236($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 236($sp)
	b _ForLoop2042
_OutOfFor2055:
	b _continueFor2041
_continueFor2041:
	lw $t0, 192($sp)
	sw $t0, 316($sp)
	lw $t0, 192($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 192($sp)
	b _ForLoop2040
_OutOfFor2053:
	b _continueFor2039
_continueFor2039:
	lw $t0, 208($sp)
	sw $t0, 528($sp)
	lw $t0, 208($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 208($sp)
	b _ForLoop2038
_OutOfFor2051:
	b _continueFor2037
_continueFor2037:
	lw $t0, 456($sp)
	sw $t0, 176($sp)
	lw $t0, 456($sp)
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, 456($sp)
	b _ForLoop2036
_OutOfFor2049:
	lw $a0, global_7165
	jal func__toString
	sw $v0, 312($sp)
	lw $a0, 312($sp)
	jal func__println
	sw $v0, 168($sp)
	li $v0, 0
	b _EndOfFunctionDecl2035
_EndOfFunctionDecl2035:
	lw $ra, 120($sp)
	add $sp, $sp, 540
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
	.align 2
global_7160:
.space 4
.align 2
global_7161:
.space 4
.align 2
global_7162:
.space 4
.align 2
global_7163:
.space 4
.align 2
global_7164:
.space 4
.align 2
global_7165:
.space 4
.align 2
