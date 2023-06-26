MAIN:
	# read switch
	lui s0, 0xFFFFF

CALCULATE:
	lw s1, 0x70(s0)
	# lui s1, 8
	# addi s1, s1, 0x1AF
	# s2 holds op code
	# s3 holds operandA
	# s4 holds operandB
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

SRA:

CONDITION:

DIVIDE:


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
	
	



	 
	
	
	
	
	