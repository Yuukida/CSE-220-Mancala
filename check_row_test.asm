.data
space: .asciiz " "
.align 2
state:        
    .byte 26         # bot_mancala       	(byte #0)
    .byte 24         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "240200000000000002000000026"
.text
.globl main
main:
la $a0, state
jal check_row
# You must write your own code here to check the correctness of the function implementation.

move $a0, $v0
li $v0, 1
syscall

la $a0, space
li $v0, 4
syscall

move $a0, $v1
li $v0, 1
syscall


li $v0, 10
syscall

.include "hw3.asm"
