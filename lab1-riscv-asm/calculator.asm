MAIN:
	# read switch
	lui s0, 0xFFFFF

CALCULATE:
	lw s1, 0x70(s0)
	####################
	# Test 
	# 1100, 0000, 0000, 1101, 0001, 1000
	# 1100, 0000, 0000, 1101, 0000, 0110
	# 1100, 0000, 0010, 0001, 0000, 0101
	lui s1, 0xC02
	addi s1, s1, 0x105
	#addi t1, zero, 1
	#slli t1, t1, 11
	#add s1, t1, s1
	####################
	# s2 holds op code
	# s3 holds operand A
	# s4 holds operand B
	# treat A and B as non signed int when logical operation 
	# as true form when arithmetic operation
	srli s2, s1, 21
	andi s2, s2, 0x7
	srli s3, s1, 8
	andi s3, s3, 0xFF
	andi s4, s1, 0xFF

SWITCH:
	# t0 is test case for op code
	addi t0, zero, 0
	beq s2, t0, AND
	addi t0, zero, 1
	beq s2, t0, OR
	addi t0, zero, 2
	beq s2, t0, XOR
	addi t0, zero, 3
	beq s2, t0, SLL
	addi t0, zero, 4
	beq s2, t0, SRA
	addi t0, zero, 5
	beq s2, t0, CONDITION
	addi t0, zero, 6
	beq s2, t0, DIVIDE

# s5 is the result
AND:
	and s5, s3, s4
	add a0, s5, zero
	jal ra, TO_BINARY
	add s5, a0, zero
	jal zero, END_OP
OR:
	or s5, s3, s4
	add a0, s5, zero
	jal ra, TO_BINARY
	add s5, a0, zero
	jal zero, END_OP
XOR:
	xor s5, s3, s4
	add a0, s5, zero
	jal ra, TO_BINARY
	add s5, a0, zero
	jal zero, END_OP
SLL:
	# ans shows in true form
	# assumpt that B is always positive
	sll s5, s3, s4
	add a0, s5, zero
	jal ra, TO_BINARY
	add s5, a0, zero
	jal zero, END_OP
SRA:
	# ans shows in true form
	# assumpt that B is always positive
	srli t0, s3, 7 	# t0 is signal of A
	andi s3, s3, 0x7F
	srl s5, s3, s4
	slli t1, t0, 7
	add s5, s5, t1
	add a0, s5, zero
	jal ra, TO_BINARY
	add s5, a0, zero
	jal zero, END_OP
CONDITION:
	bne s3, zero, not_zero
		add a0, s4, zero
		jal ra, TO_BINARY
		add s5, a0, zero
		jal zero, END_OP
	not_zero:
		add a0, s4, zero
		jal ra, GET_TWOS_COMPLEMENT
		jal ra, TO_BINARY
		add s5, a0, zero
		jal zero, END_OP
DIVIDE:
	srli t0, s3, 7		# t0 is signal of A
	add t1, s3, zero
	andi t1, t1, 0x7F 	# t1 is the abs value of A
	srli t2, s4, 7		# t2 is signal of B
	add t3, s4, zero	
	andi t3, t3, 0x7F	# t3 is abs value of B, also two'comp of y*
	
	add s11, zero, zero	# s11 is count of shifts
	while_b_lt_a:
	bge t3, t1, b_ge_a
		slli t3, t3, 1
		addi s11, s11, 1
		jal zero, while_b_lt_a
	b_ge_a:
	addi a0, t3, 0x80
	jal ra, GET_TWOS_COMPLEMENT 	# TODO: changes t0 and t1, need to restore
	srli t0, s3, 7		# t0 is signal of A
	add t1, s3, zero
	andi t1, t1, 0x7F 	# t1 is the abs value of A
	add t4, a0, zero 	# t4 is the two'comp of -y*
	add t5, zero, zero 	# t5 is the iter
	addi t6, zero, 7	# t6 is max iter
	add s6, t1, t4		# s6 is add result of every step
	add s7, zero, zero 	# s7 is the temp ans
	for_loop_divide:
		beq t5, t6, end_loop_divide
		srli s8, s6, 7	# s8 is the signal of s6
		beq s8, zero is_zero_divide
			addi s7, s7, 0
			slli s6, s6, 1
			slli s7, s7, 1
			add s6, s6, t3
			andi s6, s6, 0xFF
			jal zero iter_divide
		is_zero_divide:
			addi s7, s7, 1
			slli s6, s6, 1
			slli s7, s7, 1
			add s6, s6, t4
			andi s6, s6, 0xFF
			jal zero iter_divide
	iter_divide:
		addi t5, t5, 1
		jal zero, for_loop_divide
	end_loop_divide:
		srli s8, s6, 7
		# if s6 is negative, add y* to restore
		beq s8, zero check_s8
			add s6, s6, t3
			jal zero, final_divide
		check_s8:
			addi s7, s7, 1
			jal zero, final_divide
	final_divide:
		add s5, s7, zero
		addi t6, zero, 7
		sub t6, t6, s11
		srl s5, s5, t6
		slli t0, t0, 7
		xor s5, s5, t0
		slli s5, s5, 8
		srl s6, s6, t6
		add s5, s5, s6
		xor s5, s5, t0
		jal zero, END_OP


END_OP:
	sw s5, 0x00(s0)
	jal zero, CALCULATE


TO_BINARY:
	# Given a 8 bit number stored in a0
	# Translate the number into a 32 bit number,
	# which looks like a binary number in decimal.
	# Return the translated number in a0
	# eg. 	1010,0100 
	# 	->	0001,0000,0001,0000,0000,0001,0000,0000
	add t0, a0, zero	# temp a0
	add t1, zero, zero	# temp ans
	add t2, zero, zero 	# iter
	addi t3, zero, 8 	# max_iter
	addi t4, zero, 0x1	# base num
	for_loop_to_bin:
		beq t2, t3, end_loop_to_bin
		add t0, a0, zero
		sll t5, t4, t2 # t5 = t4 << t2
		and t0, t0, t5
		srl t0, t0, t2
		slli t6, t2, 2 	# t6 = t2 * 4
		sll t0, t0, t6
		add t1, t0, t1
		addi t2, t2, 1
		jal zero, for_loop_to_bin
	end_loop_to_bin:
		add a0, zero, t1
		jalr zero, 0(ra)
		
GET_TWOS_COMPLEMENT:
	# Given a 8 bit number stored in a0
	# Return the two's complement in a0, also in 8 bit
	srli t0, a0, 7
	addi t1, zero, 1
	beq t0, t1, negative
		jalr zero, 0(ra)
	negative:
		addi t0, zero, 0x7F
		xor a0, a0, t0
		addi a0, a0, 1
		andi a0, a0, 0xFF
		jalr zero, 0(ra)