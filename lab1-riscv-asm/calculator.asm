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
	# 1100, 0000, 0000, 1101, 0000, 0110
	#lui s1, 0xC02
	#addi s1, s1, 0x105
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
	jal zero, MAIN

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
	add s9, s3, zero
	andi s9, s9, 0x7F # s9 is the abs value of A
	add s10, s4, zero
	andi s10, s10, 0x7F	# s10 is the abs value of B, y*
	addi s6, zero, 0	# s6 is the bit count of s9, less than 8
	start_count:
		addi, t5, zero, 1
		sll t5, t5, s6
		bge t5, s9, end_count
		addi s6, s6, 1
		jal zero, start_count
	end_count:
		addi s6, s6, 1	# s6 is the total count of s9, contains signal bit
	
	add a0, s6, zero
	jal ra, GET_MASK
	add t6, a0, zero
	
	addi a6, zero, 1
	slli a6, a6, 7
	add a7, s10, a6
	add a0, a7, zero
	jal ra, GET_TWOS_COMPLEMENT
	add s11, a0, zero
	and s11, t6, s11	# s11 is the -y*
	
	addi a7, s6, -1
	slli a7, a7, 1
	addi a0, a7, 1
	jal ra, GET_MASK
	add a7, a0, zero
	
	add t0, zero, s6	# t0 is shift count
	addi t0, t0, -1
	sll t1, s10, t0		# t1 is y*
	sll t2, s11, t0		# t2 is -y*
	and t2, a7, t2
	add t3, s9, zero	# t3 is add res
	slli t3, t3, 1
	add t3, t3, t2
	add t4, zero, zero	# t4 is quotient
	slli t5, t0, 1		# t5 is 2 * t0
	addi t6, t0, -1		# t6 is loop count
	loop_divide:
		bge zero, t6 end_loop_divide
		and t3, t3, a7
		addi t6, t6, -1
		srl a6, t3, t5
		andi a6, a6, 0x1
		beq a6, zero, positive_res
			addi t4, t4, 0
			slli t4, t4, 1
			slli t3, t3, 1
			add t3, t3, t1
			jal zero, loop_divide
		positive_res:
			addi t4, t4, 1
			slli t4, t4, 1
			slli t3, t3, 1
			add t3, t3, t2
			jal zero, loop_divide
	end_loop_divide:
		and t3, t3, a7
		srl a6, t3, t5
		beq a6, zero, positive_res_no_store
			add t3, t3, t1
			and t3, t3, a7
			jal zero, final_divide
		positive_res_no_store:
			addi t4, t4, 1
			jal zero, final_divide
	final_divide:
		srli t5, s3, 7
		srli t6, s4, 7
		xor a5, t5, t6
		slli a5, a5, 7
		srl t3, t3, t0
		add t3, a5, t3
		slli s5, t3, 8
		add s5, t4, s5
		add s5, a5, s5
		jal zero, END_OP
		

END_OP:
	sw s5, 0x00(s0)
	jal zero, MAIN


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
		sll t5, t4, t2 	# t5 = t4 << t2
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

GET_MASK:
	# Given a number in a0
	# Return mask 111...111 in a0 bits
	add t0, zero, zero
	loop_mask:
		bge zero, a0, return_mask
			slli t0, t0, 1
			addi t0, t0, 1
			addi, a0, a0, -1
			jal zero, loop_mask
	return_mask:
		add a0, t0, zero
		jalr zero, 0(ra)
	
	
