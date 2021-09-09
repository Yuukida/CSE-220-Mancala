# Haoran Weng
# haweng
# 112790954

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

load_game: #use t0
	addi $sp, $sp, -28
	sw $ra, 0($sp)
	sw $s0, 4($sp) #game state addr
	sw $s1, 8($sp) #file descriptor
	sw $s2, 12($sp) #placeholder for num/ pocket num holder
	sw $s3, 16($sp) #total num of mancala
	sw $s4, 20($sp) #row counter for first 3
	sw $s5, 24($sp) #store bot mancala for later use
#-------------------------------------------------	
	move $s0, $a0 #save struct addr 
	#read file
	li $v0, 13 #syscall for open file
	move $a0, $a1
	li $a1, 0 #read-only
	li $a2, 0 #mode 0
	syscall
	
	bltz $v0, no_such_file #no such file, $v0=-1
	addi $sp, $sp, -4
	move $s1, $v0 #set file desrciptor
		
	li $t0, 0
	sb $t0, 4($s0) #reset turn
	li $t0, 'B'
	sb $t0, 5($s0) #reset player
	
	li $s2, 0
	li $s3, 0 #reset total mancala
	li $s4, 0 #reset counter
	read_three_loop:
	li $v0, 14
	move $a0, $s1 #file descriptor 
	move $a1, $sp #buffer
	li $a2, 1 #read 1 char
	syscall
	
	lbu $t0, 0($sp)
	li $t1, '\r'
	beq $t0, $t1, read_three_loop
	li $t1, '\n'
	beq $t0, $t1, newline_three
#-------------------------------------------------	
	addi $t0, $t0, -48 #convert to digit
	li $t1, 10
	mult $s2, $t1 #mult original by 10, increase digit
	mflo $s2
	add $s2, $s2, $t0 #add digit after shift
	j read_three_loop
	
	newline_three:
	bnez $s4, r1 #r=0
	add $s3, $s3, $s2 #add to total
	sb $s2, 1($s0) #store total
	
	move $a0, $s2 #set arg
	jal form_char
	sb $v0, 6($s0)
	sb $v1, 7($s0) #store to board top 
	#r=0
	li $s2, 0 #reset $s2
	addi $s4, $s4, 1 #increment i
	j read_three_loop
	#-------------------------------------------------
	r1:#r=1
	li $t0, 1
	bne $s4, $t0, r2
	
	add $s3, $s3, $s2
	sb $s2, 0($s0)
	move $s5, $s2 #store bot mancala
	li $s2, 0 #reset $s2
	addi $s4, $s4, 1 #increment i
	j read_three_loop
	r2: #r=2
	sb $s2, 2($s0)
	sb $s2, 3($s0) # s2 contains total num of pocket
	addi $s0, $s0, 8 #offset to gameboard
	#continue
#-------------------------------------------------	
	read_loop:
	li $v0, 14
	move $a0, $s1 #file descriptor 
	move $a1, $sp #buffer
	li $a2, 2 #read 2 char
	syscall
	
	li $t0, 2
	blt $v0, $t0, read_done
	
	lbu $s4, 0($sp) #tens
	#check new line
	li $t0, '\r'
	beq $t0, $s4, read_loop #newline skip
	li $t0, '\n'
	beq $t0, $s4, newline #newline process
	
	lbu $t0, 1($sp) #singles
	sb $s4, 0($s0) #store on board
	sb $t0, 1($s0)
	
	addi $a0, $s4, -48 #convert to num
	addi $a1, $t0, -48 #convert to num
	jal form_num
	add $s3, $s3, $v0 #add to total
	
	addi $s0, $s0, 2 #offset to next pocket
	j read_loop
	
	#-------------------------------------------------
	newline:
	lbu $s4, 1($sp) #load first char of next row
	
	li $v0, 14 #read the next char
	move $a0, $s1 #file descriptor 
	move $a1, $sp #buffer
	li $a2, 1 #read 2 char
	syscall
	
	lbu $t0, 0($sp) #sec char of next row
	sb $s4, 0($sp)
	sb $t0, 1($sp)
	
	addi $a0, $s4, -48 #convert to num
	addi $a1, $t0, -48 #convert to num
	jal form_num
	add $s3, $s3, $v0 #add to total
	
	addi $s0, $s0, 2 #offset to next pocket
	j read_loop
	
	#-------------------------------------------------	
	read_done:
	addi $sp, $sp, 4 #reset stack
	
	move $a0, $s5
	jal form_char
	sb $v0, 0($s0)
	sb $v1, 1($s0)
	
	li $t0,99
	bgt $s3, $t0, exceed_mancala
	li $t0, 49
	bgt $s2, $t0, exceed_pocket
	
	li $v0, 1
	sll $v1, $s2, 1
	j load_exit
	
	exceed_pocket:
	li $v0, 1 #passed mancala num
	li $v1, 0 #exceed pocket
	j load_exit
	
	exceed_mancala:
	li $v0, 0
	li $t0, 49
	bgt $s2, $t0, exceed_both
	sll $v1, $s2, 1
	j load_exit
	
	exceed_both:
	li $v1, 0 
	
	j load_exit
#-------------------------------------------------	
	no_such_file:
	li $v0, -1
	li $v1, -1
	
	load_exit:
	lw $ra, 0($sp)
	lw $s0, 4($sp) #game state addr
	lw $s1, 8($sp) #file descriptor
	lw $s2, 12($sp) #total of mancalas
	lw $s3, 16($sp) #row i counter 
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp 28
	jr $ra
get_pocket: #t0
	addi $sp, $sp, -8
	sw $s0, 0($sp) #store addr
	sw $ra, 4($sp) 
	lbu $t0, 3($a0) #load num of top pocket
	bge $a2, $t0, case_error #exceed distance
	bltz $a2, case_error #distance less than 0
	
	li $t0, 'B'
	bne $a1, $t0, caseT #check which row
	#offset addr
	lbu $t0, 3($a0) #load num of top pocket
	addi $s0, $a0, 8 #offset to beginning of board
	sll $t0, $t0, 1 #pockets * 2
	add $s0, $s0, $t0 #offset to bot pockets
	sll $a2, $a2, 1 #distance * 2
	addi $a2, $a2, 2 #distance * 2 + 2
	sub $a2, $t0, $a2 #pocket - distance
	add $s0, $s0, $a2 #offset to distance
	j find
	
	caseT:
	li $t0, 'T'
	bne $a1, $t0, case_error #check error player input
	#offset addr, t goes backward, right to left
	addi $s0, $a0, 8 #offset to top pocket in board
	sll $a2, $a2, 1 #distance * 2
	add $s0, $s0, $a2 #offset to distance
	
	find: #find element
	lbu $a1, 1($s0) #load ???
	addi $a1, $a1, -48
	lbu $a0, 0($s0) #load ???
	addi $a0, $a0, -48
	jal form_num
	j get_pocket_exit
	
	case_error: #error
	li $v0, -1
	
	get_pocket_exit:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
set_pocket: #t0
#a0: state, a1:player, a2:distance, a3:size
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	#check errors
	lbu $t0, 3($a0) #pocket num
	bge $a2, $t0, distance_player_error #greater than pockets
	bltz $a2, distance_player_error #less than  0
	li $t0, 99
	bgt $a3, $t0, size_error #greater than 99
	bltz $a3, size_error #less than 0
	#case B
	li $t0, 'B'
	bne $a1, $t0, caseT1 #check which row
	#offset addr
	lbu $t0, 2($a0) #num of pocket
	addi $s0, $a0, 8 #offset to beginning of board
	sll $t0, $t0, 1 #pockets * 2
	add $s0, $s0, $t0 #offset to bot pockets
	sll $a2, $a2, 1 #distance * 2
	addi $a2, $a2, 2 #distance * 2 + 2
	sub $a2, $t0, $a2 #pocket - distance
	add $s0, $s0, $a2 #offset to distance
	j replace
	
	caseT1:
	li $t0, 'T'
	bne $a1, $t0, distance_player_error #check error player input
	lbu $t0, 2($a0) #num of pocket
	bgt $a2, $t0, case_error #exceed distance
	#offset addr, t goes backward, right to left
	addi $s0, $a0, 8 #offset to top pocket in board
	sll $a2, $a2, 1 #distance * 2
	add $s0, $s0, $a2 #offset to distance
	
	replace:
	move $a0, $a3
	jal form_char
	sb $v1, 1($s0) #store single
	sb $v0, 0($s0) #stroe tens
	move $v0, $a3
	j set_pocket_exit
	
	size_error:
	li $v0, -2
	j set_pocket_exit
	
	distance_player_error:
	li $v0, -1
	
	set_pocket_exit:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
collect_stones: #t0, t1
#a0: state, a1: player, a2:stone
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	sw $s1, 8($sp)
	
	li $t0, 'B'
	bne $a1, $t0, caseT2 #check player
	blez $a2, stone_error #check stone num
	move $s1, $a2 #save stones
	lbu $t0, 0($a0) #load bot mancala
	add $t0, $t0, $a2 #add stone
	sb $t0, 0($a0) #store updated stones
	addi $s0, $a0, 8 #offset to top pockets
	lbu $t1, 2($a0) #load bot pockets
	sll $t1, $t1, 2 #pockets * 4 = offset to last two char
	add $s0, $s0, $t1 #offset to last two char
	j update_board
	
	caseT2:
	li $t0, 'T'
	bne $a1, $t0, player_error #check player
	blez $a2, stone_error #check stone num
	move $s1, $a2 #save stones
	lbu $t0, 1($a0) #load top mancala
	add $t0, $t0, $a2 #add stones
	sb $t0, 1($a0) #store updated stones
	addi $s0, $a0, 6 #offset to top mancala on board, and save state to s0
	
	update_board:
	move $a0, $t0
	jal form_char
	sb $v0, 0($s0)
	sb $v1, 1($s0) #store tens and singles
	move $v0, $s1
	j collect_stones_exit
	
	player_error:
	li $v0, -1
	j collect_stones_exit
	
	stone_error:
	li $v0, -2
	
	collect_stones_exit:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra
verify_move: #t0, t1
#a0: state, a1: original pocket, a2: distance
#v0: 2 if distance 99, 1 if valid move
#0 if original pocket has 0 stones, -1 if the original pocket is invalid size, -2 if distance is zero or not equal to num in pocket
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	li $t0, 99 #check distance 99
	beq $a2, $t0, distance_99 #distance = 99
	#check origin_pocket
	lbu $t0, 3($a0) #load pocket num
	bge $a1, $t0, invalid_pocket #if origin pocket greater than pocket num
	bltz $a1, invalid_pocket #if origin pocket is less than 0
	
	lbu $t0, 5($a0) #load player
	li $t1, 'B'
	addi $s0, $a0, 8 #offset to top row
	bne $t0, $t1, caseT3
	#offset addr
	lbu $t0, 2($a0) #num of pocket
	sll $t0, $t0, 1 #pockets * 2
	add $s0, $s0, $t0 #offset to bot pockets
	sll $a1, $a1, 1 #distance * 2
	addi $a1, $a1, 2 #distance * 2 + 2
	sub $a1, $t0, $a1 #pocket - distance * 2 + 2
	add $s0, $s0, $a1 #offset to distance
	j compare
	
	caseT3:
	sll $a1, $a1, 1 #distance * 2
	add $s0, $s0, $a1 #offset to distance
	
	compare:
	#check num in origin pocket
	lbu $a0, 0($s0) #tens
	addi $a0, $a0, -48
	lbu $a1, 1($s0) #singles
	addi $a1, $a1, -48
	jal form_num
	beqz $v0, zero_pocket #check if position contain 0
	beqz $a2, zero_distance #distance = 0
	bne $v0, $a2, zero_distance #num != distance
	li $v0, 1
	j verify_move_exit
	
	distance_99:#change player turn
	lbu $t0, 5($a0) #load curr player
	li $t1, 'B'
	bne $t1, $t0, changeT
	li $t0, 'T'
	sb $t0, 5($a0) #change from B to T
	lbu $t0, 4($a0)
	addi, $t0, $t0, 1
	sb $t0, 4($a0)
	li $v0, 2 
	j verify_move_exit
	
	changeT:
	li $t0, 'B'
	sb $t0, 5($a0) #change from T to B
	lbu $t0, 4($a0)
	addi, $t0, $t0, 1
	sb $t0, 4($a0)
	li $v0, 2 
	j verify_move_exit
	
	invalid_pocket:
	li $v0, -1
	j verify_move_exit
	
	zero_pocket:
	li $v0, 0
	j verify_move_exit
	
	zero_distance:
	li $v0, -2
	
	verify_move_exit:
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr  $ra
execute_move: #t0, t1
	#a0: state, #a1: origin pocket
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) #store state
	sw $s1, 8($sp) #store number of mancala
	sw $s2, 12($sp) #store curr player
	sw $s3, 16($sp) #store distance
	sw $s4, 20($sp) #origin pocket
	
	move $s0, $a0 #store state
	li $s1, 0 #reset mancala
	lbu $s2, 5($s0) #store curr player
	move $s4, $a1 #store origin pocket
	
	move $a2, $s4 #set origin pocket
	move $a1, $s2 #set player
	#a0 in state
	jal get_pocket
	move $s3, $v0 #set distance from pocket
	
	move $a0, $s0 #set state
	move $a1, $s2 #set player
	move $a2, $s4 #set origin pocket
	li $a3, 0 #set num of stone in origin pocket to 0
	jal set_pocket
	
	addi $s4, $s4, -1 #move to next pocket
	move_loop:
	beqz $s3, move_done #check num of stone left
	li $t0, -1
	bne $s4, $t0, move_cont #check if reach mancala
	
	#if reach mancala, check which player's
	lbu $t0, 5($s0)
	bne $t0, $s2, switch_row #not curr player's, skip
	addi $s3, $s3, -1 #decrement num of stones
	addi $s1, $s1, 1 #increment added mancala
	beqz $s3, mancala_done #check last deposit is mancala
	
	switch_row:
	lbu $t0, 2($s0) #load num of pockets
	add $s4, $s4, $t0 #set pocket to furtherest spot from mancala i.e. switch row
	
	li $t0, 'B'
	bne $t0, $s2, caseT4 #check if on B's row
	li $s2, 'T'
	j move_cont
	caseT4:
	li $s2, 'B' #set to bot row
	j move_cont
	
	move_cont:
	move $a0, $s0 #set state
	move $a1, $s2 #set row
	move $a2, $s4, #set pocket
	jal get_pocket
	
	li $t0, 1
	bne $s3, $t0, move_cont1 #check if last stone
	beqz $v0, empty_done #check pocket contains 0

	move_cont1:
	addi $a3, $v0, 1 #increemnt num of stone in curr pocket
	move $a0, $s0 #set state
	move $a1, $s2 #set row
	move $a2, $s4, #set pocket
	jal set_pocket #set new num of stone
	addi $s4, $s4, -1 #decrement pocket
	addi $s3, $s3, -1 #decrement distance/ stone in hand
	j move_loop
	
	empty_done:
	addi $a3, $v0, 1 #increemnt num of stone in curr pocket
	move $a0, $s0 #set state
	move $a1, $s2 #set row
	move $a2, $s4, #set pocket
	jal set_pocket #set new num of stone
	
	move $a0, $s0
	lbu $a1, 5($s0)
	move $a2, $s1
	jal collect_stones
	
	li $v1, 1 #empty finish
	move $v0, $s1 #return num of stone added to mancala
	j change_turn
	
	mancala_done:
	move $a0, $s0
	lbu $a1, 5($s0)
	move $a2, $s1
	jal collect_stones
	
	lbu $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0) #add one move
	
	li $v1, 2 #set mancala finish
	move $v0, $s1 #return num of stone added to mancala 
	j execute_move_exit #dont change turn if in mancala
	
	move_done:
	move $a0, $s0
	lbu $a1, 5($s0)
	move $a2, $s1
	jal collect_stones
	
	move $v0, $s1 #return num of stone added to mancala 
	li $v1, 0
	
	change_turn:
	lbu $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0) #add one move
	
	#change player turn
	lbu $t0, 5($s0)
	li $t1, 'B'
	bne $t1, $t0, caseT5
	li $t0, 'T'
	sb $t0, 5($s0)
	j execute_move_exit
	caseT5:
	li $t0, 'B'
	sb $t0, 5($s0)
	
	execute_move_exit:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp) #store curr player
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	jr $ra
steal: #t0, t1
#a0: state, a1: destination pocket
	addi $sp $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp) #store state
	sw $s1, 8($sp) #store detination
	sw $s2, 12($sp) #store previous player
	sw $s3, 16($sp) #total stones from stealing
	
	move $s0, $a0 #save state
	move $s1, $a1 #save destination pocket
	
	lbu $t0, 5($s0)
	li $t1, 'B'
	bne $t0, $t1, caseT6 #check curr player
	li $s2, 'T' #find previous player
	j steal_cont
	
	caseT6:
	li $s2, 'B' #find previous player
	
	steal_cont:
	move $a0, $s0
	move $a1, $s2 #find previous player's pocket
	move $a2, $s1 #previous destination pocket
	jal get_pocket
	move $s3, $v0 #save num of stone in player's pocket
	
	move $a0, $s0
	move $a1, $s2 #find previous player's pocket
	move $a2, $s1 #previous destination pocket
	li $a3, 0 #set that pocket to 0
	jal set_pocket
	
	lbu $t0, 2($s0) #load pocket
	addi $t0, $t0, -1 #pocket -1
	sub $s1, $t0, $s1 #opposite row pocket
	
	move $a0, $s0
	lbu $a1, 5($s0) #opponent 
	move $a2, $s1 #opponent's pocket
	jal get_pocket
	add $s3, $s3, $v0 #add opponent's stones
	
	move $a0, $s0
	lbu $a1, 5($s0) #opponent 
	move $a2, $s1 #opponent's pocket
	li $a3, 0 #set opponent's pocket to 0
	jal set_pocket
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s3
	jal collect_stones
	
	move $v0, $s3 #set return value
	
	steal_exit:
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	jr $ra
check_row:
#a0: game state
	addi $sp, $sp, -24
	sw $ra, 0($sp)
	sw $s0, 4($sp) #game state
	sw $s1, 8($sp) #mancala in top
	sw $s2, 12($sp) #mancala in bot
	sw $s3, 16($sp) #store distance
	sw $s4, 20($sp) #store player thats not empty
	
	move $s0, $a0 #save state
	lbu $s3, 2($s0) #load num of pockets
	addi $s3, $s3, -1 #to index
	
	li $s1, 0 #reset values
	li $s2, 0
#-------------------------------------------------	
	check_row_loop:
	li $t0, -1
	beq $t0, $s3, check_done #finishing check pockets 
	
	move $a0, $s0
	li $a1, 'T' #set player
	move $a2, $s3 #set distance
	jal get_pocket #pocket for top player
	add $s1, $s1, $v0
	
	move $a0, $s0
	li $a1, 'B'
	move $a2, $s3
	jal get_pocket #pocket for bot player
	add $s2, $s2, $v0
	
	addi $s3, $s3, -1
	j check_row_loop
#-------------------------------------------------	
	check_done:
	beqz $s1, top_row_empty #check empty row
	beqz $s2, bot_row_empty
	
	li $v0, 0 #both not empty
	
	lbu $s1, 1($s0) #load top mancala
	lbu $s2, 0($s0) #bot mancala
	blt $s1, $s2, bot_more #top less than bot
	blt $s2, $s1, top_more
	li $v1, 0
	j check_row_exit
	
	top_more:
	li $v1, 2
	j check_row_exit
	
	bot_more:
	li $v1, 1 
	j check_row_exit
#-------------------------------------------------	
	top_row_empty:
	li $s4, 'B' #collect bot's row
	j row_empty
	
	bot_row_empty:
	li $s4, 'T' #collect top's row
	
	row_empty:
	lbu $s3, 2($s0) #load pocket
	addi $s3, $s3, -1 #to index
	
	collect_loop:
	li $t0, -1
	beq $t0, $s3, collect_done
	
	move $a0, $s0
	move $a1, $s4
	move $a2, $s3
	li $a3, 0
	jal set_pocket #set to 0
	
	addi $s3, $s3, -1 #decrement
	j collect_loop
	
	collect_done:
	#add to mancala
	move $a0, $s0
	move $a1, $s4
	li $t0, 'B'
	bne $t0, $s4, caseT7
	move $a2, $s2 #add to bot
	j collect_done_cont
	caseT7:
	move $a2, $s1 #add to top
	
	collect_done_cont:
	jal collect_stones
	
	li $t0, 'D'
	sb $t0, 5($s0)
	
	li $v0, 1
	#compare stones 
	lbu $s1, 1($s0) #load top mancala
	lbu $s2, 0($s0) #bot mancala
	blt $s1, $s2, bot_more1 #top less than bot
	blt $s2, $s1, top_more1 #bot less than top
	li $v1, 0
	j check_row_exit
	
	top_more1:
	li $v1, 2
	j check_row_exit
	
	bot_more1:
	li $v1, 1 
	
	check_row_exit:
	lw $ra, 0($sp)
	lw $s0, 4($sp) #game state
	lw $s1, 8($sp) #mancala in top
	lw $s2, 12($sp) #mancala in bot
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	jr $ra 
load_moves: #t0, t1
#a0: addr of moves array, a1: string of the moves file
	addi $sp, $sp, -28
	sw $s0, 0($sp) #store addr of move array
	sw $s1, 4($sp) #store row i 
	sw $s2, 8($sp) #store column j
	sw $s3, 12($sp) #file descriptor 
	sw $s4, 16($sp) #store curr char
	sw $s5, 20($sp) #row/moves counter
	sw $s6, 24($sp) #column counter
	
	move $s0, $a0 #save move array
	
	li $v0, 13
	move $a0, $a1
	li $a1, 0 #read-only
	li $a2, 0 #mode 0
	syscall
	
	bltz $v0, no_such_move_file #no such file, $v0=-1
	move $s3, $v0 #set file descriptor
#-------------------------------------------------	
	addi $sp, $sp, -4
	li $s1, 0
	li $s2, 0
	li $s4, 0
	li $s5, 0 #reset row counter
	li $s6, 0
	
	moves_ij_loop: #read column/row
	li $v0, 14
	move $a0, $s3 #set file descriptor
	move $a1, $sp #set buffer
	li $a2, 1 #read 1 char
	syscall
	
	lbu $t0, 0($sp) #get curr char
	li $t1, '\r'
	beq $t0, $t1, moves_ij_loop
	li $t1, '\n'
	beq $t0, $t1, newline_ij
	
#-------------------------------------------------	
	addi $t0, $t0, -48 #convert to digit
	li $t1, 10
	mul $s4, $s4, $t1 #mult original by 10, increase digit
	add $s4, $s4, $t0 #add digit after shift
	j moves_ij_loop
	
	#-------------------------------------------------	
	newline_ij:
	li $t0, 1
	beq $t0, $s5, row_1 #check which row
	move $s2, $s4 #set column j
	addi $s5, $s5, 1 #increment row if on r=0
	li $s4, 0
	j moves_ij_loop
	
	row_1:
	move $s1, $s4 #set column i
	#continue
	
#-------------------------------------------------	
	li $s5, 0 #reset row counter to moves counter
	moves_loop:
	li $v0, 14
	move $a0, $s3 #set file descriptor
	move $a1, $sp #set buffer
	li $a2, 2 #read 2 char per pocket
	syscall
	
	li $t0, 2
	blt $v0, $t0, moves_loop_done
	
	lbu $s4, 0($sp) #tens
	#check newline
	li $t0, '\r'
	beq $t0, $s4, moves_loop_done #newline done, only 1 line for array
	li $t0, '\n'
	beq $t0, $s4, moves_loop_done #newline done, only 1 line for array
	
	beq $s6, $s2, next_row #check next row
	
	next_row_cont:
	#check valid digits
	li $t0, '0'
	blt $s4, $t0, invalid_moves #less than 0
	li $t0, '9'
	bgt $s4, $t0, invalid_moves #greater than 9
	
	
	addi $s4, $s4, -48 #convert to digit
	li $t0, 10
	mul $s4, $s4, $t0 #move to tens
	
	lbu $t0, 1($sp) #singles
	li $t1, '0'
	blt $t0, $t1, invalid_moves #less than 0
	li $t1, '9'
	bgt $t0, $t1, invalid_moves #greater than 9
	
	addi $t0, $t0, -48 #convert to digit
	add $s4, $s4, $t0 #final distance
	
	sb $s4, 0($s0) #store move in curr byte
	addi $s0, $s0, 1 #increment addr
	addi $s5, $s5, 1 #increment move
	addi $s6, $s6, 1 #increment column count
	
	j moves_loop
	
	next_row:
	#add 99 and increment move and addr
	li $s6, 0 #reset column count
	li $t0, 99
	sb $t0, 0($s0)
	addi $s0, $s0, 1 #increment addr
	addi $s5, $s5, 1 #increment move
	j next_row_cont
	
	
	invalid_moves:
	#set move to 100, i.e. greater than the max stone num
	li $t0, 100
	sb $t0, 0($s0) #store 100
	addi $s0, $s0, 1 #increment addr
	addi $s5, $s5, 1 #increment move
	addi $s6, $s6, 1 #increment column count
	j moves_loop
#-------------------------------------------------	
	moves_loop_done:
	addi $sp, $sp, 4
	move $v0, $s5
	j load_moves_exit
#-------------------------------------------------	
	no_such_move_file:
	li $v0, -1
	
	load_moves_exit:
	lw $s0, 0($sp)
	lw $s1, 4($sp) #store row i 
	lw $s2, 8($sp)
	lw $s3, 12($sp) #file descriptor
	lw $s4, 16($sp) 
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	addi $sp, $sp, 28
	jr $ra
play_game:
#a0: move string, a1: board string, a2: state, a3:moves array, 0($sp): num of moves to execute
	lw $t0, 0($sp) #load 4th arg
	#prep
	addi $sp, $sp, -28
	sw $ra, 0($sp) 
	sw $s0, 4($sp) #state
	sw $s1, 8($sp) #moves array
	sw $s2, 12($sp) #num of moves to execute
	sw $s3, 16($sp) #curr move
	sw $s4, 20($sp) #temp
	sw $s5, 24($sp) #num of moves from move file
	
	move $s2, $t0 #save 4th arg/ num of moves to execute
	move $s0, $a2 #save state
	move $s1, $a3 #save array
	move $s3, $a0 #save move string temp
	
	move $a0, $s0 #load state base addr
	jal load_game
	blez $v0, file_error #file doesnt exist/ too many stones
	beqz $v1, file_error #too many pockets
	#passed load game
	
	move $a0, $s1 #byte array
	move $a1, $s3 #move string
	jal load_moves
	bltz $v0, file_error #no such file
	beqz $v0, no_moves_check #no moves from moves input
	move $s1, $a3 #save moves array
	move $s5, $v0 #save num of moves from file
	blez $s2, no_moves_check #no moves to make
	
	move $a0, $s0
	jal check_row
	bgtz $v0, player_won
#-------------------------------------------------	
	play_loop:
	beqz $s5, play_done
	beqz $s2, play_done
	lbu $s3, 0($s1) #load move
	
	bltz $s3, invalid_move #check move validity
	li $t0, 99
	beq $s3, $t0, equal_99 #equal 99
	li $t0, 48
	bgt $s3, $t0, invalid_move #greater than 99

	#-------------------------------------------------		
	#passed errors
	move $a0, $s0 #load state addr
	lbu $a1, 5($s0) #load player
	move $a2, $s3 #origin pocket/distance
	jal get_pocket
	move $s4, $v0 #save num of stone for later
	#-------------------------------------------------		
	move $a0, $s0
	move $a1, $s3 #origin pocket / move
	move $a2, $s4 #num of stone in pocket
	jal verify_move
	bltz $v0, invalid_move #move invalid for row
	beqz $v0, invalid_move #pocket = 0
	#-------------------------------------------------		
	#passed, execute move
	move $a0, $s0
	move $a1, $s3 #origin pocket
	jal execute_move #move + 1
	li $t0, 1
	bne $v1, $t0, row_check #if 1 steal
	#-------------------------------------------------	
	move $a0, $s3 #origin pocket
	move $a1, $s4 #num of stone
	lbu $a2, 2($s0) #pocket num
	jal calculate_destination
	#steal, caluclate destination pocket
	move $a0, $s0 #state
	move $a1, $v0 #dest
	jal steal
	
	row_check:
	move $a0, $s0
	jal check_row
	bgtz $v0, player_won #one row empty
	addi $s1, $s1, 1 #offset moves array
	addi $s2, $s2, -1 #-1 num of moves executed
	addi $s5, $s5, -1 #moves - 1
	j play_loop
	#-------------------------------------------------	
	equal_99: #change player add turn
	#(change player), continue, dont add executed move, add moves array
	lbu $t0, 5($s0) #load player
	li $t1, 'B'
	bne $t1, $t0, caseTf
	li $t0, 'T' 
	sb $t0, 5($s0) #B -> T
	j add_more
	
	caseTf:
	li $t0, 'B'
	sb $t0, 5($s0) #T -> B
	
	add_more:
	lbu $t0, 4($s0)
	addi $t0, $t0, 1
	sb $t0, 4($s0)
	addi $s1, $s1, 1
	addi $s5, $s5, -1
	addi $s2, $s2, -1
	j play_loop
	#-------------------------------------------------	
	invalid_move: 
	#<0 or >99, go to next move, dont add executed move
	addi $s1, $s1, 1 #offset moves array
	addi $s5, $s5, -1
	j play_loop
	
#-------------------------------------------------		
	play_done: #nobody won
	move $a0, $s0
	jal check_row #check in case of 99s
	bgtz $v0, player_won 
	
	li $v0, 0 #tie
	lbu $v1, 4($s0)
	j play_game_exit
#-------------------------------------------------		
	no_moves_check:
	li $t0, 0
	sb $t0, 4($s0)
	#check row, v1=0
	move $a0, $s0
	jal check_row
	#v0 greater than 1, player win
	bgtz $v0, player_won
	li $v0, 0
	li $v1, 0 #0 move
	j play_game_exit
#-------------------------------------------------		
	player_won:
	#add moves executed
	move $v0, $v1
	lbu $v1, 4($s0)
	j play_game_exit
#-------------------------------------------------		
	file_error:
	li $v0, -1
	li $v1, -1
	
	play_game_exit:
	lw $ra, 0($sp) 
	lw $s0, 4($sp) #state
	lw $s1, 8($sp) #moves array
	lw $s2, 12($sp) #num of moves to execute
	lw $s3, 16($sp) #num of valid moves executed
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	jr  $ra
print_board:
#a0: state
	addi $sp, $sp, -4
	sw $s0, 0($sp)
#-------------------------------------------------	
	move $s0, $a0 #save state	
	#print top mancala
	addi $t0, $s0, 6 #offset to board
	lbu $a0, 0($t0)
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1 #next char
	lbu $a0, 0($t0)
	li $v0, 11
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
#-------------------------------------------------		
	#print bot mancala
	lbu $t0, 2($s0) #load pocket num
	sll $t0, $t0, 2 #pocket * 2
	move $t1, $s0
	addi $t1, $t1, 8
	add $t0, $t1, $t0 #offset to bot mancala
	
	lbu $a0, 0($t0)
	li $v0, 11
	syscall
	
	addi $t0, $t0, 1 #next char
	lbu $a0, 0($t0)
	li $v0, 11
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
#-------------------------------------------------		
	#print board
	lbu $t0, 2($s0) #pocket count
	sll $t3, $t0, 1 #pocket * 2 char
	addi $s0, $s0, 8 #offset to board
	
	move $t0, $t3
	li $t1, 0 #round counter
	print_loop:
	li $t2, 2
	beq $t1, $t2, print_board_exit
	
	lbu $a0,0($s0) #print curr char
	li $v0, 11
	syscall
	
	addi $s0, $s0, 1 #set to next char
	addi $t0, $t0, -1
	
	bnez $t0, print_loop
	
	addi $t1, $t1, 1 #next round
	move $t0, $t3 #reset count
	
	li $a0, '\n' #new line
	li $v0, 11
	syscall
	
	j print_loop

	print_board_exit:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
write_board:
#a0: state
	addi $sp, $sp, -20
	#create file name
	li $t0, 'o' 
	sb $t0, 0($sp)
	li $t0, 'u'
	sb $t0, 1($sp)
	li $t0, 't'
	sb $t0, 2($sp)
	li $t0, 'p'
	sb $t0, 3($sp)
	li $t0, 'u'
	sb $t0, 4($sp)
	li $t0, 't'
	sb $t0, 5($sp)
	li $t0, '.'
	sb $t0, 6($sp)
	li $t0, 't'
	sb $t0, 7($sp)
	li $t0, 'x'
	sb $t0, 8($sp)
	li $t0, 't'
	sb $t0, 9($sp)
	li $t0, '\0'
	sb $t0, 10($sp)
	
	sw $s0, 12($sp) #state
	sw $s1, 16($sp) #file descriptor
	
	move $s0, $a0 #save state
	
	li $v0, 13
	move $a0, $sp
	li $a1, 1 #read-only
	li $a2, 0 #mode 0
	syscall
	bltz $v0, write_error
	move $s1, $v0 #save file descriptor
	addi $sp, $sp, 12 #reset sp
	
#-------------------------------------------------		
	#write top mancala
	addi $t0, $s0, 6
	li $v0, 15
	move $a0, $s1 #file descriptoy
	move $a1, $t0 #buffer
	li $a2, 2
	syscall
	bltz $v0, write_error
	
	addi $sp, $sp, -4 #load newline to stack, stack as buffer
	li $t0, '\n'
	sb $t0, 0($sp)
	
	li $v0, 15 #print newline
	move $a0, $s1
	move $a1, $sp
	li $a2, 1
	syscall
	bltz $v0, write_error
	
#-------------------------------------------------		
	#write bot mancala
	addi $t0, $s0, 8 #offset to board
	lbu $t1, 2($s0) #pocket num
	sll $t1, $t1, 2 #pcket * 4
	add $t0, $t0, $t1 #bot mancala addr
	
	li $v0, 15 #write bot
	move $a0, $s1 #file descriptoy
	move $a1, $t0 #buffer
	li $a2, 2
	syscall
	bltz $v0, write_error
	#-------------------------------------------------		
	li $v0, 15 #print newline
	move $a0, $s1
	move $a1, $sp
	li $a2, 1
	syscall
	bltz $v0, write_error

#-------------------------------------------------		
	#print top board
	lbu $t0, 2($s0)
	sll $t0, $t0, 1 #pocket * 2 char
	addi $s0, $s0, 8
	
	li $v0, 15 #top board
	move $a0, $s1
	move $a1, $s0
	move $a2, $t0
	syscall
	bltz $v0, write_error
	
	li $v0, 15 #print newline
	move $a0, $s1
	move $a1, $sp
	li $a2, 1
	syscall
	bltz $v0, write_error

#-------------------------------------------------		
	#print bot board
	add $s0, $s0, $t0 #offset to bot board
	
	li $v0, 15
	move $a0, $s1
	move $a1, $s0
	move $a2, $t0
	syscall
	bltz $v0, write_error
	
	li $v0, 15 #print newline
	move $a0, $s1
	move $a1, $sp
	li $a2, 1
	syscall
	bltz $v0, write_error
	
	addi $sp, $sp, 4

	li $v0, 16
	move $a0, $s1
	syscall
	bltz $v0, write_error
	
	li $v0, 1
	j write_baord_exit
	
	write_error:
	li $v0, -1
	
	write_baord_exit:
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra

#helpers
form_num:
#a0= value to be added, a1:value to add, v0:return total
	li $t0, 10
	mul $v0, $a0, $t0
	add $v0, $v0, $a1
	jr $ra

form_char:
#a0: entire num, v0:tens v1: digit
	move $t0, $a0
	li $t1, 10
	div $t0, $t1 #num/10
	mflo $t0
	addi $v0, $t0, 48 #char of tens
	
	mul $t0, $t0, $t1 #mul 10
	sub $v1, $a0, $t0 #original - ??? = ???
	addi $v1, $v1, 48 #char of digit
	jr $ra
	
calculate_destination:
#a0: origin pocket, #a1: num of stone in pocket, #a2: pocket num
	bgt $a1, $a0, larger_stone
	sub $v0, $a0, $a1
	j dest_exit
	
	larger_stone:
	addi $a1, $a1, -1 #stone -1
	sub $a1, $a1, $a2 #stone -1 - pocket num
	sub $a1, $a1, $a0 #stone -1 - pocket num - pocket
	sub $v0, $a2, $a1 #pocket num - (stone -1 - pocket num - pocket)
	dest_exit:
	jr $ra
	

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
