.data
board_filename: .asciiz "game06.txt"
space: .asciiz " "
.align 2
state:        
    .byte 0         # bot_mancala       	(byte #0)
    .byte 1         # top_mancala       	(byte #1)
    .byte 6         # bot_pockets       	(byte #2)
    .byte 6         # top_pockets        	(byte #3)
    .byte 2         # moves_executed	(byte #4)
    .byte 'T'    # player_turn        		(byte #5)
    # game_board                     		(bytes #6-end)
    .asciiz
    "0108070601000404040404040401"
.text
.globl main
main:
la $a0, state
la $a1, board_filename
jal load_game
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
