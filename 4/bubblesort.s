	.text
	.align	2 #2byete 
	.globl bubblesort 
bubblesort: 
	addi sp, sp, -12
	sw s2, 8(sp) 
	sw s3, 4(sp)  
	sw s4, 0(sp) 

	# Argument: a0 - base address of array 
	# Argument: a1 - end offset of array(4*9)
	add s2, zero, zero
	add s3, zero, zero 
	addi s4, a1, -4 
	srli s4, s4, 2   
.L1: 
	bge s2, s4, .L_END 
	beq zero, zero, .L2
	

.L2: 
	sub t1, s4, s2 
	bge s3, t1, .L4
	slli t2, s3, 2
	add t3, t2, a0  
	addi t4, t3, 4  

	lw t1, 0(t3) 
	lw t2, 0(t4) 

	blt t2, t1, .SWAP
	beq zero, zero, .L3
.SWAP:
	sw t2, 0(t3) 
	sw t1, 0(t4) 
	beq zero, zero, .L3 
.L3:
	addi s3, s3, 1
	beq zero, zero, .L2

.L4:
	addi s2, s2, 1
	add s3, zero, zero
	beq zero, zero, .L1

.L_END:
	lw s2, 8(sp)
	lw s3, 4(sp)
	lw s4, 0(sp)
	addi sp, sp, 12

	#    Implement your code    #
	#############################
	xor a0, a0, a0 
	jalr	zero, 0(ra) 
	############################

	.align 2
	.globl print_array
print_array:
	# Argument: a0 - base address of array
	# Argument: a1 - end offset of array
	add	t1, zero, zero # byte offset of array
	add	t3, zero, a0 # t3 base addr
.PLOOP:
	add 	t2, t3, t1 
	lw	a0, 0(t2) # t2 load at a0 
	addi	t0, zero, 1 # t0 is reserved for syscall, plus one in t0 
	ecall 
	addi	t1, t1, 4 
	bne	t1, s2, .PLOOP 
	jalr	zero, 0(ra) 

	.align	2
	.globl main
main:
	addi	sp,sp,-16
	sw	ra,12(sp)
	sw	s0,8(sp)
	sw	s2,4(sp)
	sw	s1,0(sp)
	lui s1, %hi(ARRAY) #Load Upper Imm 
	addi s1, s1, %lo(ARRAY) # s0 has the addr of ADDR
	lw	s2, -4(s1) # s1 = # size of ADDR
	slli	s2, s2, 2

	lui a0, %hi(MSG1)
	addi a0, a0, %lo(MSG1)
	addi a1, zero, 16
	addi t0, zero, 3
	ecall
	# print array
	add	a0, zero, s1
	add	a1, zero, s2
	jal	ra, print_array
	###################
	# Call the target function
	add	a0, zero, s1
	add	a1, zero, s2
	jal	ra, bubblesort
	###################
	lui a0, %hi(MSG2)
	addi a0, a0, %lo(MSG2)
	addi a1, zero, 14
	addi t0, zero, 3
	ecall
	# print sorted array
	add	a0, zero, s1
	add	a1, zero, s2
	jal	ra, print_array 
	lw	ra,12(sp)
	lw	s0,8(sp)
	lw	s2,4(sp)
	lw	s1,0(sp)
	addi	sp,sp,16
	jalr	zero, 0(ra)



	.rodata 
MSG1: 
	.word 0x4f534e55 # UNSO:
	.word 0x44455452 # RTED
	.word 0x52524120 #  ARR
	.word 0x0a3a5941 #   AY
	# 15 chars
MSG2:
	.word 0x54524f53 # SORTED ARRAY:
	.word 0x41204445
	.word 0x59415252
	.word 0x00000a3a
	# 13 chars

	.data 
	.align 2 
	####################################
	#           ARRAY DATA             #
	####################################
ARRAY_SIZE: 
	.word 9
ARRAY:	
	.word 4
	.word 9
	.word 11
	.word 3
	.word 15
	.word 5
	.word 6
	.word 8
	.word 0