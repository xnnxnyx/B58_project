# Defining Global Varibales
.eqv    BASE_ADDRESS    0x10008000
.eqv    Refresh_rate    40
.eqv    Red 		0xff0000
.eqv	Yellow		0xffd312
.eqv	Gray		0x8b8b83
.eqv	Brown		0x805a00
.eqv	White		0xffffff
.eqv	Purp		0xe5ccfe
.eqv	Pink		0xf8c8dc
.eqv	Blue		0x0047ab
.eqv	Black		0x000000
.eqv	Character_start	64 #12040
.eqv	SLEEP_TIME 500

.data   

# Defining Address of the objects	

.text
.globl main

# Defs 
# s0 = character address 
# 
main:   
        
Init:   #initialize the character 
	li $t0, BASE_ADDRESS
	addi $s0, $t0, Character_start #$s0 is going to hold the character address
	jal draw_character
	
	#initialize the floor
	li $t1, BASE_ADDRESS
	li $t2, Gray
	addi $a1, $t0, 13312
    	li $a2, 256 # this is the last column i want to colour plus 4 ? 
    	jal floor 
    	
    	#inititalize the platforms for lvl 1 
    	#jal platforms
    	
    	li $t2, Brown
    	
    	sw $t2, 5424($t0)
    	sw $t2, 5428($t0)
    	sw $t2, 5432($t0)
    	sw $t2, 5436($t0)
    	sw $t2, 5432($t0)
    	sw $t2, 5436($t0)
    	sw $t2, 5440($t0)
    	sw $t2, 5444($t0)
    	sw $t2, 5448($t0)
    	sw $t2, 5452($t0)
    	sw $t2, 5456($t0)
    	sw $t2, 5460($t0)
    	sw $t2, 5464($t0)
    	sw $t2, 5468($t0)
    	
    	
    	#li $s7, 0xffff0000 #Address of keystroke event
        #la $s6, character #Address of space_ship
        #li $s0, 40 #Refresh Rate
	
        
m_loop:	
	#add $a0, $s6, $zero #a0 stores the address of the character
        #add $a1, $s7, $zero #a1 gets the address of the keystroke event
        #jal key_update #jump to key_update to update the addressess
        
        # move the box go right 
        
       
        
        li $t1, 0xffff0000
	lw $t0, 0($t1)
	beq $t0, 1, keypressed
	
	jal gravity
	
	# sleep 
	j sleep

        
Refresh:
	li $v0, 40
        add $a0, $s0, $zero
        syscall
        
        j m_loop
       
gravity: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 12260 # Leaving space for hearts and floor value: 12260
	bgt $t1, $t2, jump2
	
	#check for collision
	lw $t1, 1024($s0) #storing the left most pixel 
	#addi $t1, $t1, 256	#going to the down pixel
	lw $t2, 1048($s0)#storing the right most pixel 
	#addi $t2, $t2, 256 #going to the down pixel 
	li $t3, Brown # stroing the colour of the platform 
	beq $t3, $t1, m_loop #if equal, jumping to collide, which jumps back to the main loop
	beq $t3, $t2, m_loop # same^ 

	
	jal erase_character # else, erasing the character and redrawing 
	addi $s0, $s0, 256
	jal draw_character
	j jump2
	
jump2:  lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
# in every loop => +256 
# if on a platform => colour I will not move down (go through) 
	
collide: j jump2
	       
       
keypressed:
	lw $t7, 4($t1)
	beq $t7, 0x61, a_pressed
	beq $t7, 0x64, d_pressed
	beq $t7, 0x73, s_pressed
	beq $t7, 0x77, w_pressed
	jr $ra
	
d_pressed: 

	li $t0, BASE_ADDRESS
   	sub $t0, $s0, $t0
    	addi $t0, $t0, 28
    	li $t4, 256
    	div $t0, $t4
    	mfhi $t4
    	beqz $t4, m_loop
	
	# Add check for D
	
	#Otherwise, add 4
	jal erase_character
	addi $s0, $s0, 4
	jal draw_character
	j m_loop
	
       
a_pressed: 
	# we want to make sure that the ship is not at the left edge before moving it
	# divide by 240, if remainder is 0 - jump back to loop
	
	#check whether the ship has reach the left end
        add $t0, $0, $s0  #1st unit
        li $t1, 256
        div $t0, $t1
        mfhi $t1
        beq $t1, 0, m_loop
	
	#otherwise, add -4 to current ship address
	jal erase_character
	addi $s0, $s0, -4
	jal draw_character
	j m_loop
	
s_pressed: 
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 12260 # Leaving space for hearts and floor value: 12260
	bgt $t1, $t2, m_loop
	
	jal erase_character 
	addi $s0, $s0, 256
	jal draw_character
	j m_loop
	
w_pressed: 
	#check to make sure that the ship address is not at the top
	#check if ship address is within 0 and 256
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 256
	#bltz $t0, sleep
	blt $t1, $t2, m_loop
	jal erase_character 
	addi $s0, $s0, -256
	jal draw_character
	j m_loop
      
draw_character:
	 
        li $t1, White #white head
    	li $t2, Blue #pink eyes
    	li $t3, Pink #orange tail
    	
    	sw $t1, 12($s0)
    	sw $t1, 268($s0)
    	sw $t1, 264($s0)
    	sw $t1, 272($s0)
    	sw $t1, 524($s0)
    	sw $t2, 520($s0)
    	sw $t1, 516($s0)
    	sw $t2, 528($s0)
    	sw $t1, 532($s0)
    	sw $t1, 780($s0)
    	sw $t3, 776($s0)
    	sw $t3, 772($s0)
    	sw $t1, 768($s0)
    	sw $t3, 784($s0)
    	sw $t3, 788($s0)
    	sw $t1, 792($s0)
    	jr $ra
    	#j jump
    	
    	
erase_character: 
	#take address of ship, fill all values with black
	li $t0, Black
	sw $t0, 12($s0)
    	sw $t0, 268($s0)
    	sw $t0, 264($s0)
    	sw $t0, 272($s0)
    	sw $t0, 524($s0)
    	sw $t0, 520($s0)
    	sw $t0, 516($s0)
    	sw $t0, 528($s0)
    	sw $t0, 532($s0)
    	sw $t0, 780($s0)
    	sw $t0, 776($s0)
    	sw $t0, 772($s0)
    	sw $t0, 768($s0)
    	sw $t0, 784($s0)
    	sw $t0, 788($s0)
    	sw $t0, 792($s0)
	jr $ra
	#j jump
	
floor: la $t6, ($a1)  #change this for starting condition 
	la $t7, ($a2)    #change this for stopping condition 
	#mul $t7, $t7, 4
   	add $t7, $t7, $t6  #adding to the current adrress to create the actual point to stop

floor_loop: 
    	bge $t6, $t7, jump  #break condition: if t6 is greater than or equal to t7=128+startadd then stop and go to end_loop
    	sw $t2, 0($t6)   #t3 is my colour but change it to any colour you are using 
    	#sw $t2, $t6
    	addi $t6, $t6, 4 # we are adding 4 to the address to move it to the next position for coloring 
    	j floor_loop # jump to first line of the loop
	
	
    	
platforms: #draw platforms for LEVEL 1
	#Pushing ra into the stack, to know where came from 
    addi $s1, $s0, 1056	# s0 -> jelly fish address s1->the location
    li $s2, 30 # s2 -> till length of the platform 
    jal plat_loop

    addi $s1, $s1, -728
    li $s2, 30
    jal plat_loop

    addi $s1, $s1, -1240
    li $s2, 30
    jal plat_loop

    addi $s1, $s1, -1480
    li $s2, 30
    jal plat_loop

    addi $s1, $s1, -732
    li $s2, 30
    jal plat_loop

    #draw platforms for LEVEL 2

    #draw platforms for LEVEL 3

plat_loop:
    li $t4, Brown #coral pink
    la $t6, ($s1) #starting position -- add 4
    la $t7, ($s2) #last column address
    add $t7, $t7, $t6 #add starting position to current address for endpoint

barrier:
    bge $t6, $t7, jump #if starting position > endpoint
    sw $t4, 0($t6) #draw coral color
    addi $t6, $t6, 4 #move to next position to draw
    j barrier #loop again

jump:
     jr $ra
       
	

sleep:
    li $v0, 32
    li $a0, SLEEP_TIME
    syscall
    j m_loop

end:    li $v0, 10 # terminate the program gracefully 
	syscall
