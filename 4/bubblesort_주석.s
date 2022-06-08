	.text
	.align	2 #2byete 
	.globl bubblesort 
bubblesort: 
	addi sp, sp, -12 #s2,s3,s4 사용하기위해서 이미 저장된 값 스택에 저장하기 위해 포인터 3개 내려줌
	sw s2, 8(sp) 
	sw s3, 4(sp)  
	sw s4, 0(sp) 

	# Argument: a0 - base address of array 
	# Argument: a1 - end offset of array(4*9)
	add s2, zero, zero #s2 = i : 0으로 초기화
	add s3, zero, zero #s3 = j : 0으로 초기화 
	addi s4, a1, -4  #s4 = N-1 : a1에 배열 크기 저장되어있으며 s4에 N-1의 값 저장하기 위해 -4해줌(이미 곱하기 4되어있어서)
	srli s4, s4, 2   #4로 나누어주기 위해서 오른쪽으로 시프트 두번 해줌 
.L1: #i로 돌리는 루프
	bge s2, s4, .L_END  # i >= N-1 일때 종료
	j .L2 #L2로 이동 
	
.L2: #j로 돌리는 루프 
	sub t1, s4, s2 # t1 = n-1 - i
	bge s3, t1, .L4 #j >= n-1 - i일때 j루프 탈출
	slli t2, s3, 2 #j*4 
	add t3, t2, a0  #address + j*4  
	addi t4, t3, 4  # t3옆의 주소

	lw t1, 0(t3) #arr[j]
	lw t2, 0(t4) #arr[j+1]

	blt t2, t1, .SWAP # t2<t1이면 스왑
	j .L3 
.SWAP: #스왑
	sw t2, 0(t3) #t2 = arr[j+1], t4는 arr[j]의 주소
	sw t1, 0(t4) #t1 = arr[j], t4는 arr[j+1]의 주소
	j .L3 
.L3: # j 루프 마지막부분
	addi s3, s3, 1 #j++
	j .L2 #j루프 가장 위로  

.L4: # i 루프 마지막부분 
	addi s2, s2, 1 #i++ 
	add s3, zero, zero #j = 0
	j .L1 #i루프 가장위로 

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