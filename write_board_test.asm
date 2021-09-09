.data
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 9         # top_mancala       	(byte #1)
    .byte 10         # bot_pockets       	(byte #2)
    .byte 10         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'B'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "09100000000000000000000000000000000000000105"
.text
.globl main
main:
la $a0, state
jal write_board
# You must write your own code here to check the correctness of the function implementation.
move $a0, $v0
li $v0, 1
syscall

li $v0, 10
syscall

.include "hw3.asm"
