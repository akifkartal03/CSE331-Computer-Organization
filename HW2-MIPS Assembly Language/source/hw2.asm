.data
	
	#int arr[MAX_SIZE];
	arr: .space 400 # MAX_SIZE is 100, it can be modified.(400=100*4).
	subset: .space 400 #for bonus part
	pos: .asciiz "Possible!"
	notPos: .asciiz "Not possible!"
	msg1: .asciiz "Enter size of Array:"
	msg2: .asciiz "Enter target sum number:"
	msg3: .asciiz "Enter array elements one by one\n"
	opPar: .asciiz "( "
	clsPar: .asciiz ")"
	space: .asciiz " "
	newLine: .asciiz "\n"
	# don't use memory for other variables for better performance.
	# I will use registers to store and retrieve the other variables.
.text

main:
	#int arraySize ==> t0 register
	#int num ==> t1 register
	#int returnVal ==> t3 register.
	
	#cin >> arraySize;
	li $v0, 4
	la $a0, msg1
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	sll $t0, $t0, 2 # multiply arraySize with 4 to traverse array in misp
	
	#cin >> num;
	li $v0, 4
	la $a0, msg2
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	
	#for(int i = 0; i < arraySize; ++i) { cin >> arr[i];}
	li $v0, 4
	la $a0, msg3
	syscall
	addi $s0, $zero, 0 # int i = 0
	Loop:
		beq $s0, $t0, AfterLoop # i < arraySize
		li $v0, 5
		syscall
		move $t2, $v0
		sw $t2, arr($s0) # cin >> arr[i]
	   	addi $s0, $s0, 4 # ++i
	   	j Loop
	   	
	AfterLoop:
		#adjust the arguments
		move $a0,$t1 # a0 is num
		move $a2, $t0 # a2 is arraySize
		#arr is global in misp
		
		# returnVal = CheckSumPossibility(num, arr, arraySize); 
		jal CheckSumPossibility 
		move $t3,$v0
		
		# if(returnVal == 1){ cout << "Possible!" << endl;}
		beq $t3,1 Possible 
		# else{cout << "Not possible!" << endl;}
		li $v0, 4
		la $a0, notPos
		syscall
		# exit the program(return 0)
		li $v0,10
		syscall	
		
# write possible with subset	
Possible:
	#cout << "Possible!"
	li $v0, 4
	la $a0, pos
	syscall
	#cout << " ";
	li $v0,4
	la $a0,space 
	syscall
	# cout << "(";
	li $v0,4
	la $a0,opPar
	syscall
	addi $t7, $zero, 0 # int i = 0
	Loop4:
		beq $t7, $a3, AfterLoop4 # i < size 
		lw $t2, subset($t7)
	   	li $v0,1 #cout << arr[i];
	   	move $a0,$t2
	   	syscall
	   	li $v0,4
	   	la $a0,space #cout << " ";
	   	syscall
	   	addi $t7, $t7, 4 # i++  
	   	j Loop4
	AfterLoop4:
		# cout << ")" ;
		li $v0,4
	   	la $a0,clsPar
	   	syscall
	   	# cout << endl;
	   	li $v0,4
	   	la $a0,newLine
	   	syscall	
# exit the program(return 0)
li $v0,10
syscall
CheckSumPossibility:
	#save return adress
	addi $sp, $sp, -4
	sw $ra,0($sp)
	
	# int total_sum = 0, current_sum = 0, index = 0, res = 0 k = 0;
	li $a1,0 # k (subset index)
	# since we already run out of argument registers we have to use temp register for arguments
	li $t4,0 # total_sum
	li $t5,0 # current_sum
	li $t6,0 # index
	li $v1,0 # res
	
	# Calculate total sum of given array
	# for(int i = 0; i < size; ++i) { total_sum += arr[i];}
	addi $t7, $zero, 0 # int i = 0
	Loop2:
		beq $t7, $a2, AfterLoop2 # i < size 
		lw $t2, arr($t7)
	   	add $t4, $t4, $t2 #total_sum += arr[i]
	   	addi $t7, $t7, 4 # i++  
	   	j Loop2
	   	
	AfterLoop2:
		#if (num <= 0)
		bgt $a0,$zero,secondIf
	return0:	
		#return 0;
		move $v0,$v1 #return res with v0 register 
		lw $ra , 0($sp)
		addi $sp, $sp, 4
		jr $ra
	secondIf:
		# if (total_sum < num)
		bge $t4,$a0,thirdIf
		j return0
	thirdIf:
		# if (total_sum == num)
		bne $t4,$a0,checkWithBacktracking
		j return1
	checkWithBacktracking:
		# call recursive function	 
		jal CheckSumPossibilityHelper
		# return res;
		move $v0,$v1 #return res with v0 register 
		lw $ra , 0($sp)
		addi $sp, $sp, 4
		jr $ra
	return1:
		# copy orijinal array as subset
		addi $t7, $zero, 0 # int i = 0
		Loop3:
			beq $t7, $a2, AfterLoop3 # i < size 
			lw $t2, arr($t7)
	   		sw $t2, subset($t7) # subset[i] = arr[i]
	   		addi $t7, $t7, 4 # i++  
	   		j Loop3
		AfterLoop3:
	   		# return 1;
			li $v1,1 # res
			move $v0,$v1 #return res with v0 register
			move $a3,$a2 # k = size 
			lw $ra , 0($sp)
			addi $sp, $sp, 4
			jr $ra
			
CheckSumPossibilityHelper:
		# parameters and registers as in contract.
		
		# num = a0	# total_sum = t4
		# k = a1	# current_sum = t5 = 0
		# size = a2	# index = t6 = 0
		# res = v1	# t0,t1,t2,t3,t7 are free to use.
		# arr = arr	# subset = subset = empty
		
		#save imptortant parameters in stack
		addi $sp, $sp, -20
		sw $ra, 0($sp) # return adress
		sw $t4, 4($sp) # total_sum
		sw $t5, 8($sp) # current_sum
		sw $t6, 12($sp) # index
		sw $a1, 16($sp) # k (subset index)
		
		#if (current_sum == num)
		bne $t5,$a0,checkSum
		#return 1;
		move $a3,$a1
		li $v1,1
		j return
		
		checkSum:
			# if (current_sum == 0)
			bne $t4,$zero,secondBase
			# k = 0;
			li $a1,0
		secondBase:
			# if (index >= size)
			blt $t6,$a2,recurPart
			# return;
			j return
		# else	
		recurPart:
			# if (current_sum + arr[index] <= num && res == 0)
			lw $t7, arr($t6) # arr[index]
			add $t2, $t5,$t7
			bgt $t2,$a0,secondCheck
			#  res == 0
			bne $v1,$zero,secondCheck
			# subset[k] = arr[index];
            		# k = k + 1;
			sw $t7, subset($a1)
			addi $a1, $a1, 4 # k++ 
			#total_sum - arr[index] 
			sub $t4,$t4,$t7
			#current_sum + arr[index] 
			add $t5,$t5,$t7
			# index + 1
			addi $t6,$t6,4
			# CheckSumPossibilityHelper(num, arr, size, total_sum - arr[index], current_sum + arr[index], index + 1, res);
			jal ,CheckSumPossibilityHelper
			# restore parameters in stack for other calls
			lw $a1, 16($sp)
			lw $t6, 12($sp)
			lw $t5, 8($sp)
			lw $t4, 4($sp)
			lw $ra , 0($sp)
		secondCheck:
			# if (current_sum + total_sum - arr[index] >= num && res == 0) 
			lw $t7, arr($t6)
			add $t2, $t5,$t4
			sub $t1, $t2,$t7
			blt $t1, $a0,return
			# res == 0
			bne $v1,$zero,return
			lw $t7, arr($t6) #arr[index]
			#total_sum - arr[index] 
			sub $t4,$t4,$t7
			# index + 1
			addi $t6,$t6,4
			# CheckSumPossibilityHelper(num, arr, size, total_sum - arr[index], current_sum, index + 1, res);
			jal ,CheckSumPossibilityHelper
		return:
			#return;
			# restore parameters in stack for other calls
			lw $a1, 16($sp)
			lw $t6, 12($sp)
			lw $t5, 8($sp)
			lw $t4, 4($sp)
			lw $ra , 0($sp)
			addi $sp, $sp, 20
			jr $ra
	   			
