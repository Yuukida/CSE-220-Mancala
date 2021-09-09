.data
filename: .asciiz "out.txt"
out: .asciiz "12345"

.text
.globl main
main:
	
	addi $sp, $sp, -12
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

	li $v0, 13
	move $a0, $sp
	li $a1, 1 #read-only
	li $a2, 0 #mode 0
	syscall
	
	move $s0, $v0 
	
	li $v0, 15
	move $a0, $s0
	la $a1, out
	li $a2, 2
	syscall
	
	addi $sp, $sp, -4
	li $t0, '\n'
	sb $t0, 0($sp)
	
	li $v0, 15
	move $a0, $s0
	move $a1, $sp
	li $a2, 1
	syscall
	
	la $t0, out
	addi $t0, $t0, 2
	
	li $v0, 15
	move $a0, $s0
	move $a1, $t0
	li $a2, 3
	syscall
	
	li $v0, 16
	move $a0, $s0
	syscall

	
	exit:
	li $v0, 10
	syscall
