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
	sw $t2, 40($sp)
	sw $t3, 44($sp)
	sw $t4, 48($sp)
	sw $t5, 52($sp)
	sw $t6, 56($sp)
	sw $t7, 60($sp)
	sw $s0, 64($sp)
	sw $s1, 68($sp)
	sw $s2, 72($sp)
	sw $s3, 76($sp)
	sw $s4, 80($sp)
	sw $s5, 84($sp)
	sw $s6, 88($sp)
	sw $s7, 92($sp)
	sw $t8, 96($sp)
	sw $t9, 100($sp)
	sw $k0, 104($sp)
	sw $k1, 108($sp)
	sw $gp, 112($sp)
	sw $fp, 124($sp)
	sw $ra, 120($sp)
_BeginOfFunctionDecl2034:
	li $t0, 99
	sw $t0, global_50
	li $t0, 100
	sw $t0, global_51
	li $t0, 101
	sw $t0, global_52
	li $t0, 102
	sw $t0, global_53
	li $t0, 0
	sw $t0, global_54
	jal func__getInt
	sw $v0, 472($sp)
	lw $t0, 472($sp)
	sw $t0, global_49
	li $t0, 1
	move $t3, $t0
_ForLoop2036:
	lw $t1, global_49
	sle $t2, $t3, $t1
	beqz $t2, _OutOfFor2049
_ForBody2048:
	li $t0, 1
	move $t5, $t0
_ForLoop2038:
	lw $t1, global_49
	sle $t2, $t5, $t1
	beqz $t2, _OutOfFor2051
_ForBody2050:
	li $t0, 1
	move $t8, $t0
_ForLoop2040:
	lw $t1, global_49
	sle $t2, $t8, $t1
	beqz $t2, _OutOfFor2053
_ForBody2052:
	li $t0, 1
	move $t4, $t0
_ForLoop2042:
	lw $t1, global_49
	sle $t2, $t4, $t1
	beqz $t2, _OutOfFor2055
_ForBody2054:
	li $t0, 1
	move $t6, $t0
_ForLoop2044:
	lw $t1, global_49
	sle $t2, $t6, $t1
	beqz $t2, _OutOfFor2057
_ForBody2056:
	li $t0, 1
	move $t7, $t0
_ForLoop2046:
	lw $t1, global_49
	sle $t2, $t7, $t1
	beqz $t2, _OutOfFor2059
_ForBody2058:
	sne $t2, $t3, $t5
	beqz $t2, _logicalFalse2064
_logicalTrue2063:
	sne $t2, $t3, $t8
	move $s0, $t2
	b _logicalMerge2065
_logicalFalse2064:
	li $t0, 0
	move $s0, $t0
	b _logicalMerge2065
_logicalMerge2065:
	beqz $s0, _logicalFalse2067
_logicalTrue2066:
	sne $t2, $t3, $t4
	move $s1, $t2
	b _logicalMerge2068
_logicalFalse2067:
	li $t0, 0
	move $s1, $t0
	b _logicalMerge2068
_logicalMerge2068:
	beqz $s1, _logicalFalse2070
_logicalTrue2069:
	sne $t2, $t3, $t6
	move $s2, $t2
	b _logicalMerge2071
_logicalFalse2070:
	li $t0, 0
	move $s2, $t0
	b _logicalMerge2071
_logicalMerge2071:
	beqz $s2, _logicalFalse2073
_logicalTrue2072:
	sne $t2, $t3, $t7
	move $s3, $t2
	b _logicalMerge2074
_logicalFalse2073:
	li $t0, 0
	move $s3, $t0
	b _logicalMerge2074
_logicalMerge2074:
	beqz $s3, _logicalFalse2076
_logicalTrue2075:
	lw $t1, global_50
	sne $t2, $t3, $t1
	move $s4, $t2
	b _logicalMerge2077
_logicalFalse2076:
	li $t0, 0
	move $s4, $t0
	b _logicalMerge2077
_logicalMerge2077:
	beqz $s4, _logicalFalse2079
_logicalTrue2078:
	lw $t1, global_51
	sne $t2, $t3, $t1
	move $s5, $t2
	b _logicalMerge2080
_logicalFalse2079:
	li $t0, 0
	move $s5, $t0
	b _logicalMerge2080
_logicalMerge2080:
	beqz $s5, _logicalFalse2082
_logicalTrue2081:
	lw $t1, global_52
	sne $t2, $t3, $t1
	move $s6, $t2
	b _logicalMerge2083
_logicalFalse2082:
	li $t0, 0
	move $s6, $t0
	b _logicalMerge2083
_logicalMerge2083:
	beqz $s6, _logicalFalse2085
_logicalTrue2084:
	lw $t1, global_53
	sne $t2, $t3, $t1
	move $s7, $t2
	b _logicalMerge2086
_logicalFalse2085:
	li $t0, 0
	move $s7, $t0
	b _logicalMerge2086
_logicalMerge2086:
	beqz $s7, _logicalFalse2088
_logicalTrue2087:
	sne $t2, $t5, $t8
	move $t9, $t2
	b _logicalMerge2089
_logicalFalse2088:
	li $t0, 0
	move $t9, $t0
	b _logicalMerge2089
_logicalMerge2089:
	beqz $t9, _logicalFalse2091
_logicalTrue2090:
	sne $t2, $t5, $t4
	move $k0, $t2
	b _logicalMerge2092
_logicalFalse2091:
	li $t0, 0
	move $k0, $t0
	b _logicalMerge2092
_logicalMerge2092:
	beqz $k0, _logicalFalse2094
_logicalTrue2093:
	sne $t2, $t5, $t6
	move $k1, $t2
	b _logicalMerge2095
_logicalFalse2094:
	li $t0, 0
	move $k1, $t0
	b _logicalMerge2095
_logicalMerge2095:
	beqz $k1, _logicalFalse2097
_logicalTrue2096:
	sne $t2, $t5, $t7
	move $gp, $t2
	b _logicalMerge2098
_logicalFalse2097:
	li $t0, 0
	move $gp, $t0
	b _logicalMerge2098
_logicalMerge2098:
	beqz $gp, _logicalFalse2100
_logicalTrue2099:
	lw $t1, global_50
	sne $t2, $t5, $t1
	move $fp, $t2
	b _logicalMerge2101
_logicalFalse2100:
	li $t0, 0
	move $fp, $t0
	b _logicalMerge2101
_logicalMerge2101:
	beqz $fp, _logicalFalse2103
_logicalTrue2102:
	lw $t1, global_51
	sne $t2, $t5, $t1
	move $t2, $t2
	b _logicalMerge2104
_logicalFalse2103:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2104
_logicalMerge2104:
	beqz $t2, _logicalFalse2106
_logicalTrue2105:
	lw $t1, global_52
	sne $t2, $t5, $t1
	move $t2, $t2
	b _logicalMerge2107
_logicalFalse2106:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2107
_logicalMerge2107:
	beqz $t2, _logicalFalse2109
_logicalTrue2108:
	lw $t1, global_53
	sne $t2, $t5, $t1
	move $t2, $t2
	b _logicalMerge2110
_logicalFalse2109:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2110
_logicalMerge2110:
	beqz $t2, _logicalFalse2112
_logicalTrue2111:
	sne $t2, $t8, $t4
	move $t2, $t2
	b _logicalMerge2113
_logicalFalse2112:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2113
_logicalMerge2113:
	beqz $t2, _logicalFalse2115
_logicalTrue2114:
	sne $t2, $t8, $t6
	move $t2, $t2
	b _logicalMerge2116
_logicalFalse2115:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2116
_logicalMerge2116:
	beqz $t2, _logicalFalse2118
_logicalTrue2117:
	sne $t2, $t8, $t7
	move $t2, $t2
	b _logicalMerge2119
_logicalFalse2118:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2119
_logicalMerge2119:
	beqz $t2, _logicalFalse2121
_logicalTrue2120:
	lw $t1, global_50
	sne $t2, $t8, $t1
	move $t2, $t2
	b _logicalMerge2122
_logicalFalse2121:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2122
_logicalMerge2122:
	beqz $t2, _logicalFalse2124
_logicalTrue2123:
	lw $t1, global_51
	sne $t2, $t8, $t1
	move $t2, $t2
	b _logicalMerge2125
_logicalFalse2124:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2125
_logicalMerge2125:
	beqz $t2, _logicalFalse2127
_logicalTrue2126:
	lw $t1, global_52
	sne $t2, $t8, $t1
	move $t2, $t2
	b _logicalMerge2128
_logicalFalse2127:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2128
_logicalMerge2128:
	beqz $t2, _logicalFalse2130
_logicalTrue2129:
	lw $t1, global_53
	sne $t2, $t8, $t1
	move $t2, $t2
	b _logicalMerge2131
_logicalFalse2130:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2131
_logicalMerge2131:
	beqz $t2, _logicalFalse2133
_logicalTrue2132:
	sne $t2, $t4, $t6
	move $t2, $t2
	b _logicalMerge2134
_logicalFalse2133:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2134
_logicalMerge2134:
	beqz $t2, _logicalFalse2136
_logicalTrue2135:
	sne $t2, $t4, $t7
	move $t2, $t2
	b _logicalMerge2137
_logicalFalse2136:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2137
_logicalMerge2137:
	beqz $t2, _logicalFalse2139
_logicalTrue2138:
	lw $t1, global_50
	sne $t2, $t4, $t1
	move $t2, $t2
	b _logicalMerge2140
_logicalFalse2139:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2140
_logicalMerge2140:
	beqz $t2, _logicalFalse2142
_logicalTrue2141:
	lw $t1, global_51
	sne $t2, $t4, $t1
	move $t2, $t2
	b _logicalMerge2143
_logicalFalse2142:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2143
_logicalMerge2143:
	beqz $t2, _logicalFalse2145
_logicalTrue2144:
	lw $t1, global_52
	sne $t2, $t4, $t1
	move $t2, $t2
	b _logicalMerge2146
_logicalFalse2145:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2146
_logicalMerge2146:
	beqz $t2, _logicalFalse2148
_logicalTrue2147:
	lw $t1, global_53
	sne $t2, $t4, $t1
	move $t2, $t2
	b _logicalMerge2149
_logicalFalse2148:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2149
_logicalMerge2149:
	beqz $t2, _logicalFalse2151
_logicalTrue2150:
	sne $t2, $t6, $t7
	move $t2, $t2
	b _logicalMerge2152
_logicalFalse2151:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2152
_logicalMerge2152:
	beqz $t2, _logicalFalse2154
_logicalTrue2153:
	lw $t1, global_50
	sne $t2, $t6, $t1
	move $t2, $t2
	b _logicalMerge2155
_logicalFalse2154:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2155
_logicalMerge2155:
	beqz $t2, _logicalFalse2157
_logicalTrue2156:
	lw $t1, global_51
	sne $t2, $t6, $t1
	move $t2, $t2
	b _logicalMerge2158
_logicalFalse2157:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2158
_logicalMerge2158:
	beqz $t2, _logicalFalse2160
_logicalTrue2159:
	lw $t1, global_52
	sne $t2, $t6, $t1
	move $t2, $t2
	b _logicalMerge2161
_logicalFalse2160:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2161
_logicalMerge2161:
	beqz $t2, _logicalFalse2163
_logicalTrue2162:
	lw $t1, global_53
	sne $t2, $t6, $t1
	move $t2, $t2
	b _logicalMerge2164
_logicalFalse2163:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2164
_logicalMerge2164:
	beqz $t2, _logicalFalse2166
_logicalTrue2165:
	lw $t1, global_50
	sne $t2, $t7, $t1
	move $t2, $t2
	b _logicalMerge2167
_logicalFalse2166:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2167
_logicalMerge2167:
	beqz $t2, _logicalFalse2169
_logicalTrue2168:
	lw $t1, global_51
	sne $t2, $t7, $t1
	move $t2, $t2
	b _logicalMerge2170
_logicalFalse2169:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2170
_logicalMerge2170:
	beqz $t2, _logicalFalse2172
_logicalTrue2171:
	lw $t1, global_52
	sne $t2, $t7, $t1
	move $t2, $t2
	b _logicalMerge2173
_logicalFalse2172:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2173
_logicalMerge2173:
	beqz $t2, _logicalFalse2175
_logicalTrue2174:
	lw $t1, global_53
	sne $t2, $t7, $t1
	move $t2, $t2
	b _logicalMerge2176
_logicalFalse2175:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2176
_logicalMerge2176:
	beqz $t2, _logicalFalse2178
_logicalTrue2177:
	lw $t0, global_51
	lw $t1, global_52
	sne $t2, $t0, $t1
	move $t2, $t2
	b _logicalMerge2179
_logicalFalse2178:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2179
_logicalMerge2179:
	beqz $t2, _logicalFalse2181
_logicalTrue2180:
	lw $t0, global_50
	lw $t1, global_53
	sne $t2, $t0, $t1
	move $t2, $t2
	b _logicalMerge2182
_logicalFalse2181:
	li $t0, 0
	move $t2, $t0
	b _logicalMerge2182
_logicalMerge2182:
	beqz $t2, _alternative2061
_consequence2060:
	lw $t0, global_54
	move $t2, $t0
	lw $t0, global_54
	li $t1, 1
	add $t1, $t0, $t1
	sw $t1, global_54
	b _OutOfIf2062
_alternative2061:
	b _OutOfIf2062
_OutOfIf2062:
	b _continueFor2047
_continueFor2047:
	move $t2, $t7
	li $t1, 1
	add $t7, $t7, $t1
	b _ForLoop2046
_OutOfFor2059:
	b _continueFor2045
_continueFor2045:
	move $t2, $t6
	li $t1, 1
	add $t6, $t6, $t1
	b _ForLoop2044
_OutOfFor2057:
	b _continueFor2043
_continueFor2043:
	move $t2, $t4
	li $t1, 1
	add $t4, $t4, $t1
	b _ForLoop2042
_OutOfFor2055:
	b _continueFor2041
_continueFor2041:
	move $t2, $t8
	li $t1, 1
	add $t8, $t8, $t1
	b _ForLoop2040
_OutOfFor2053:
	b _continueFor2039
_continueFor2039:
	move $t2, $t5
	li $t1, 1
	add $t5, $t5, $t1
	b _ForLoop2038
_OutOfFor2051:
	b _continueFor2037
_continueFor2037:
	move $t2, $t3
	li $t1, 1
	add $t3, $t3, $t1
	b _ForLoop2036
_OutOfFor2049:
	lw $a0, global_54
	jal func__toString
	move $t2, $v0
	move $a0, $t2
	jal func__println
	move $t2, $v0
	li $v0, 0
	b _EndOfFunctionDecl2035
_EndOfFunctionDecl2035:
	lw $ra, 120($sp)
	lw $t2, 40($sp)
	lw $t3, 44($sp)
	lw $t4, 48($sp)
	lw $t5, 52($sp)
	lw $t6, 56($sp)
	lw $t7, 60($sp)
	lw $s0, 64($sp)
	lw $s1, 68($sp)
	lw $s2, 72($sp)
	lw $s3, 76($sp)
	lw $s4, 80($sp)
	lw $s5, 84($sp)
	lw $s6, 88($sp)
	lw $s7, 92($sp)
	lw $t8, 96($sp)
	lw $t9, 100($sp)
	lw $k0, 104($sp)
	lw $k1, 108($sp)
	lw $gp, 112($sp)
	lw $fp, 124($sp)
	add $sp, $sp, 540
	jr $ra
.data
_end: .asciiz "\n"
	.align 2
_buffer: .space 256
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
