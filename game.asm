#####################################################################
#
# CSCB58 Winter 2022 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Annanya Sharma, 1007113017, shar1902, annanya.sharma@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. Health 2 pts (keeps track of the character's health) 
# 2. Fail condition 1 pt (when the character loses all the hearts, it dies and game over)
# 3. Win condition 1 pt(when the players reachers the last platform of lvl 3, it wins)
# 4. Moving Object / Moving platform 2 pts (the platforms on which the level change or the character wins is moving up and down) 
# 5. Different levels 2 pts ( there are 3 different levels and as the level number of platforms decreases) 
# 6. 3 Pick-up effects 2 pts (There are 3 different pick-ups)
#	a) Pink => refreshes all the hearts 
#	b) Purple => takes away one heart (you really want to avoid this) 
#	c) Yellow => changes the colour of the character for that level
#
# Link to video demonstration for final submission:
# https://utoronto.zoom.us/rec/share/lWG3Tcju3fsjLzJeJcXq6z_Xc7EE3KxCI-n2yJoV51IX-2hZ9BleclWW3y6IOEeE.55Wyz9BYAaEA2_-0
#
# Are you OK with us sharing the video with people outside course staff?
# - No
#
# Any additional information that the TA needs to know:
# - The lives refreshes every level.
# - When the character touches the gray floor, it dies. It loses a heart and start at 
#	the same level.
# - When the key p is pressed, it starts at level 1.
#####################################################################

# Defining Global Varibales
.eqv    BASE_ADDRESS    0x10008000
.eqv    Refresh_rate    40
.eqv    Red 		0xff0000
.eqv	Yellow		0xffd312
.eqv	Another_cloud	0xc61aff
.eqv	Gray		0x8b8b83
.eqv	Brown		0x805a00
.eqv	White		0xffffff
.eqv	Purp		0x7852ff
.eqv	Pink		0xf8c8dc
.eqv	Blue		0x0047ab
.eqv	Black		0x000000
.eqv	SkyBlue		0xace9f3 
.eqv	Character_start	64 #12040
.eqv	SLEEP_TIME 	100
.eqv	Heart_address	14340
.eqv	Star_1		8856 #Yellow => changes the clour of the cloud to yellow
.eqv	Star_2		6828 #Pink => gives heart 
.eqv	Star_3		5696 #Purple => takes away heart 
.eqv	Colour_lv1	0x96a67c	#sage green
.eqv	Colour_lv2	0xfff5ee	#sea shell
.eqv	Colour_lv3	0x04b18f	# greenish
.eqv	Winning_platform_add	8384	
.data   
.text
.globl main
# Defs 
# s0 = character address 
# s6 = colour of the current level winning platform
# s5 = checks if the colour of the cloud should be purp or white
# s7 = for moving platform 
# s3 = direction for the platfrom going in 0=> down 1=> up

#################################### LEVEL 1 ##################################
main:   jal clear_screen
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	jal draw_heart	#Drawing lives 
    	addi $t7, $t7, 32
    	jal draw_heart
    	addi $t7, $t7, 32
    	jal draw_heart
    	
    	li $t0, BASE_ADDRESS	#Initializing the winning platform
	addi $s7, $t0, Winning_platform_add
	
	li $s5, 0 	# initialises the colour of the cloud to white 
       
Init:   # Drawing character 
	li $t0, BASE_ADDRESS
	addi $s0, $t0, Character_start #$s0 is going to hold the character address
	jal draw_character
	
	# Drawing dying floor
	li $t2, Gray
	addi $a1, $t0, 13312
    	li $a2, 256
    	jal floor 
    	
    	# Drawing platforms
    	li $t2, SkyBlue
    	li $a2, 32
    	
    	addi $a1, $t0, 10592
    	jal floor
    	
    	addi $a1, $t0, 5128
    	jal floor
    	
    	addi $a1, $t0 , 7212
    	jal floor
    	
    	addi $a1, $t0, 9616
    	jal floor
    
    	# Drawing pick-ups 
    	jal draw_star
    	jal draw_star2
    	jal draw_star3

	# Keeping track of the level
    	li $s6, Colour_lv1
    		
	# Initializing direction for moving_platform 
	li $s3, 0
	jal draw_moving_platform
    	b moving_platform	#winning platform
    	
   
#################################### MAIN LOOP ##################################
m_loop:	
	# Taking input from the keyboard
        li $t1, 0xffff0000
	lw $t0, 0($t1)
	beq $t0, 1, keypressed
	jal gravity
	jal sleep
	b moving_platform
Refresh:
	li $v0, 40
        add $a0, $s0, $zero
        syscall
        b m_loop
 
#################################### GRAVITY ################################## 
gravity: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)		#storing $ra 
	
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 12260 # Leaving space for hearts and floor
	
	#Collision with the floor
	bgt $t1, $t2, lose_heart
	
	#Collision with platform
	lw $t1, 1024($s0) #storing the bottom of left most pixel 
	lw $t2, 1048($s0)#storing the bottom of right most pixel
	li $t3, SkyBlue #storing the colour of the platform 
	
	beq $t3, $t1, jump2
	beq $t3, $t2, jump2
	
	# Collision with the winning platform
	li $t3, Colour_lv1
	beq $t3, $t1, level2 
	beq $t3, $t2, level2 
	
	li $t3, Colour_lv2
	beq $t3, $t1, level3
	beq $t3, $t2, level3
	
	li $t3, Colour_lv3
	beq $t3, $t1, win
	beq $t3, $t2, win
	
	# Collision with the pick-ups
	lw $t4, 1036($s0)
	lw $t5, 1032($s0)
	lw $t6, 1028($s0)
	lw $t7, 1040($s0)
	lw $t8, 1040($s0)

	li $t3, Yellow		# colliding with a star_1 
	beq $t3, $t1, erase_star
	beq $t3, $t2, erase_star
	beq $t3, $t4, erase_star
	beq $t3, $t5, erase_star
	beq $t3, $t6, erase_star
	beq $t3, $t2, erase_star
	beq $t3, $t8, erase_star
	
	
	li $t3, Pink		# colliding with a star_1 
	beq $t3, $t1, erase_star2
	beq $t3, $t2, erase_star2
	beq $t3, $t4, erase_star2
	beq $t3, $t5, erase_star2
	beq $t3, $t6, erase_star2
	beq $t3, $t2, erase_star2
	beq $t3, $t8, erase_star2
	
	
	li $t3, Purp		# colliding with a star_1 
	beq $t3, $t1, erase_star3
	beq $t3, $t2, erase_star3
	beq $t3, $t4, erase_star3
	beq $t3, $t5, erase_star3
	beq $t3, $t6, erase_star3
	beq $t3, $t2, erase_star3
	beq $t3, $t8, erase_star3
	
	# else, erasing the character and redrawing 
	jal erase_character 
	addi $s0, $s0, 256
	jal draw_character
	j jump2
	
jump2:  lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
collide: j jump2
	       
#################################### KEY INPUTS ##################################     
keypressed:
	lw $t7, 4($t1)
	beq $t7, 0x61, a_pressed
	beq $t7, 0x64, d_pressed
	#beq $t7, 0x73, s_pressed
	beq $t7, 0x77, w_pressed
	beq $t7, 0x70,p_pressed_orignal
	jr $ra
	
d_pressed: 
	#Checking for the boundaries
	li $t0, BASE_ADDRESS
   	sub $t0, $s0, $t0
    	addi $t0, $t0, 28
    	li $t4, 256
    	div $t0, $t4
    	mfhi $t4
    	beqz $t4, m_loop
	
	#check for collision with platform, pickups and winning platform
	lw $t1, 16($s0) #storing the left most pixel 
	li $t3, SkyBlue # stroing the colour of the platform 
	li $t0, Yellow
	li $t2, Pink
	li $t9, Purp
	
	li $t8, Colour_lv1
	li $t5, Colour_lv2
	li $t4, Colour_lv3
	
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop #if equal, jumping to collide, which jumps back to the main loop
	
	lw $t1, 276($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 536($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 792($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	#Otherwise, add 4
	jal erase_character
	addi $s0, $s0, 4
	jal draw_character
	j m_loop
	
       
a_pressed: 
	#check whether the ship has reach the left end
        add $t0, $0, $s0
        li $t1, 256
        div $t0, $t1
        mfhi $t1
        beq $t1, 0, m_loop
        
        #check for collision with platforms, pick-ups and winning platforms
	lw $t1, 8($s0) #storing the left most pixel 
	li $t3, SkyBlue # stroing the colour of the platform 
	li $t0, Yellow
	li $t2, Pink
	li $t9, Purp
	li $t8, Colour_lv1
	li $t5, Colour_lv2
	li $t4, Colour_lv3
	
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop #if equal, jumping to collide, which jumps back to the main loop
	
	lw $t1, 260($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 512($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 764($s0)
	beq $t0, $t1, erase_star
	beq $t2, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t8, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	#otherwise, add -4 to current ship address
	jal erase_character
	addi $s0, $s0, -4
	jal draw_character
	j m_loop
	
s_pressed: # Not used.
	# Check for the boundaries
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 12260 # Leaving space for hearts and floor value: 12260
	bgt $t1, $t2, m_loop
	
	jal erase_character 
	addi $s0, $s0, 256
	jal draw_character
	j m_loop
	
w_pressed: 
	# Check for the boundaries
	li $t1, BASE_ADDRESS
	sub $t1, $s0, $t1
	li $t2, 256
	blt $t1, $t2, m_loop
	
	 #check for collision with the platform, pick-ups and winning platform
	lw $t1, -756($s0)
	li $t3, SkyBlue # stroing the colour of the platform 
	li $t0, Yellow
	li $t8, Pink 
	li $t9, Purp
	
	li $t2, Colour_lv1
	li $t5, Colour_lv2
	li $t4, Colour_lv3
	
	beq $t3, $t1, m_loop #if equal, jumping to collide, which jumps back to the main loop
	
	lw $t1, -496($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, -236($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 24($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, -504($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, -256($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	lw $t1, 0($s0)
	beq $t0, $t1, erase_star
	beq $t8, $t1, erase_star2
	beq $t9, $t1, erase_star3
	
	beq $t2, $t1, level2
	beq $t5, $t1, level3
	beq $t4, $t1, win
	
	beq $t3, $t1, m_loop # same^ 
	
	jal erase_character 
	addi $s0, $s0, -768
	jal draw_character
	j m_loop

# when touches the gound, restart (level 1)	
p_pressed: jal erase_character
	   b Init

# when touches the gound, restart (level 2)		   	   
p_pressed2: jal erase_character
	   b Init2

# when touches the gound, restart (level 3)		   	   
p_pressed3: jal erase_character
	   b Init3
	   
# when pressed the key "p" => restart
p_pressed_orignal: jal erase_character
	   	b main
      
draw_character:
        li $t1, White #white head
    	li $t2, Blue #pink eyes
    	li $t3, Pink #orange tail
    	
    	sw $t2, 520($s0)
    	sw $t2, 528($s0)
    	sw $t3, 776($s0)
    	sw $t3, 772($s0)
    	sw $t3, 784($s0)
    	sw $t3, 788($s0)
    	
    	beq $s5, 1, colour_diff	# if the colour is purp
    	sw $t1, 12($s0)
    	sw $t1, 268($s0)
    	sw $t1, 264($s0)
    	sw $t1, 272($s0)
    	sw $t1, 524($s0)
    	sw $t1, 516($s0)
    	sw $t1, 532($s0)
    	sw $t1, 780($s0)
    	sw $t1, 768($s0)
    	sw $t1, 792($s0)
    	jr $ra
    	
colour_diff: 
	li $t1, Another_cloud # Coulours blue
	sw $t1, 12($s0)
    	sw $t1, 268($s0)
    	sw $t1, 264($s0)
    	sw $t1, 272($s0)
    	sw $t1, 524($s0)
    	sw $t1, 516($s0)
    	sw $t1, 532($s0)
    	sw $t1, 780($s0)
    	sw $t1, 768($s0)
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
	
draw_star: 
	# t6 stores the address for the star 
	li $t0, BASE_ADDRESS
    	#addi $t5, $t0, 7880
	addi $t6, $t0, Star_1
	li $t0, Yellow
	sw $t0, 4($t6)
	sw $t0, 264($t6)
	sw $t0, 256($t6)
	sw $t0, 516($t6)
	jr $ra

erase_star: 
	# yellow star => changes the colour to yellow 
	# t6 stores the address for the star
	li $t0, BASE_ADDRESS 
	addi $t6, $t0, Star_1 
	li $t0, Black
	sw $t0, 4($t6)
	sw $t0, 264($t6)
	sw $t0, 256($t6)
	sw $t0, 516($t6)
	li $s5, 1	# flags the colour to yellow 
	jr $ra
	
erase_star2: 
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	li $t0, BASE_ADDRESS 
	addi $t6, $t0, Star_2
	li $t0, Black
	sw $t0, 4($t6)
	sw $t0, 264($t6)
	sw $t0, 256($t6)
	sw $t0, 516($t6)
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	jal draw_heart
    	addi $t7, $t7, 32
    	jal draw_heart
    	addi $t7, $t7, 32
    	jal draw_heart
	b jump2
	
	
erase_star3: 
	# purp star => takes away one heart 
	# t6 stores the address for the star 
	li $t0, BASE_ADDRESS 
	addi $t6, $t0, Star_3
	li $t0, Black
	sw $t0, 4($t6)
	sw $t0, 264($t6)
	sw $t0, 256($t6)
	sw $t0, 516($t6)
	b lose_heart2 
	# jr $ra
	
draw_star2: 
	# t6 stores the address for the star 
	li $t0, BASE_ADDRESS
	addi $t5, $t0, Star_2
	li $t0, Pink
	sw $t0, 4($t5)
	sw $t0, 264($t5)
	sw $t0, 256($t5)
	sw $t0, 516($t5)
	jr $ra


draw_star3: 
	# t6 stores the address for the star 
	li $t0, BASE_ADDRESS
	addi $t5, $t0, Star_3
	li $t0, Purp
	sw $t0, 4($t5)
	sw $t0, 264($t5)
	sw $t0, 256($t5)
	sw $t0, 516($t5)
	jr $ra

	
draw_heart: 
	# t7 stores the address for the heart 
	li $t0, Red
	sw $t0, 4($t7) 
	sw $t0, 20($t7)
	sw $t0, 256($t7)
	sw $t0, 260($t7)
	sw $t0, 264($t7)
	sw $t0, 272($t7)
	sw $t0, 276($t7)
	sw $t0, 280($t7)
	sw $t0, 516($t7)
	sw $t0, 524($t7)
	sw $t0, 528($t7)
	sw $t0, 532($t7)
	sw $t0, 776($t7)
	sw $t0, 780($t7)
	sw $t0, 784($t7)
	sw $t0, 1036($t7)
	li $t0, White
	sw $t0,	520($t7)
	jr $ra
	
erase_heart: 
	# t7 stores the address for the heart 
	li $t0, Black
	sw $t0, 4($t7) 
	sw $t0, 20($t7)
	sw $t0, 256($t7)
	sw $t0, 260($t7)
	sw $t0, 264($t7)
	sw $t0, 272($t7)
	sw $t0, 276($t7)
	sw $t0, 280($t7)
	sw $t0, 516($t7)
	sw $t0, 524($t7)
	sw $t0, 528($t7)
	sw $t0, 532($t7)
	sw $t0, 776($t7)
	sw $t0, 780($t7)
	sw $t0, 784($t7)
	sw $t0, 1036($t7)
	sw $t0,	520($t7)
	beq $s6, Colour_lv1, p_pressed
	beq $s6, Colour_lv2, p_pressed2
	beq $s6, Colour_lv3, p_pressed3
	
lose_heart:
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	addi $t7, $t7, 64
    	
    	li $t2, Red
    	
    	lw $t1, 4($t7)
    	beq $t2, $t1, erase_heart
    	addi $t7, $t7, -32
    	lw $t1, 4($t7)
    	beq $t2, $t1, erase_heart
    	addi $t7, $t7, -32
    	lw $t1, 4($t7)
    	beq $t2, $t1, game_over
    	
    	
    	
erase_heart2:  # FOR THE PICK UP 
	# t7 stores the address for the heart 
	li $t0, Black
	sw $t0, 4($t7) 
	sw $t0, 20($t7)
	sw $t0, 256($t7)
	sw $t0, 260($t7)
	sw $t0, 264($t7)
	sw $t0, 272($t7)
	sw $t0, 276($t7)
	sw $t0, 280($t7)
	sw $t0, 516($t7)
	sw $t0, 524($t7)
	sw $t0, 528($t7)
	sw $t0, 532($t7)
	sw $t0, 776($t7)
	sw $t0, 780($t7)
	sw $t0, 784($t7)
	sw $t0, 1036($t7)
	sw $t0,	520($t7)
	jr $ra
	
lose_heart2: 
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	addi $t7, $t7, 64
    	
    	li $t2, Red
    	
    	lw $t1, 4($t7)
    	beq $t2, $t1, erase_heart2
    	addi $t7, $t7, -32
    	lw $t1, 4($t7)
    	beq $t2, $t1, erase_heart2
    	addi $t7, $t7, -32
    	lw $t1, 4($t7)
    	beq $t2, $t1, game_over
 
win: jal clear_screen
     li $t0, BASE_ADDRESS 
     
     li $t2, White 
     
     	sw $t2, 5200($t0)	#eyes 
	sw $t2, 5204($t0)
	sw $t2, 5456($t0)
	sw $t2, 5460($t0)
	
	sw $t2, 5296($t0)
	sw $t2, 5292($t0)
	sw $t2, 5548($t0)
	sw $t2, 5552($t0)
	
	sw $t2, 8784($t0) 
	sw $t2, 9044($t0) 	
	sw $t2, 9304($t0) 	
	sw $t2, 9564($t0) 	
	sw $t2, 9824($t0) 
	sw $t2, 10084($t0)	
	
	sw $t2, 10344($t0)	
	sw $t2, 10348($t0)
	sw $t2, 10352($t0)
	sw $t2, 10356($t0)
	sw $t2, 10360($t0)
	sw $t2, 10364($t0)
	sw $t2, 10368($t0)
	sw $t2, 10372($t0)
	sw $t2, 10376($t0)
	sw $t2, 10380($t0)
	sw $t2, 10384($t0)
	sw $t2, 10388($t0)
	
	sw $t2, 10136($t0)
	sw $t2, 9884($t0)
	sw $t2, 9632($t0)
	sw $t2, 9380($t0)
	sw $t2, 9128($t0)
	sw $t2, 8876($t0)
	
	b END_loop



game_over: 
	jal clear_screen
	li $t0, BASE_ADDRESS
	
	li $t2, White 
	
	sw $t2, 5200($t0)	#eyes 
	sw $t2, 5204($t0)
	sw $t2, 5456($t0)
	sw $t2, 5460($t0)
	
	sw $t2, 5296($t0)
	sw $t2, 5292($t0)
	sw $t2, 5548($t0)
	sw $t2, 5552($t0)
	
	sw $t2, 11600($t0) 
	sw $t2, 11348($t0) 	
	sw $t2, 11096($t0) 	
	sw $t2, 10844($t0) 	
	sw $t2, 10592($t0) 
	sw $t2, 10340($t0)	
	
	sw $t2, 10344($t0)	
	sw $t2, 10348($t0)
	sw $t2, 10352($t0)
	sw $t2, 10356($t0)
	sw $t2, 10360($t0)
	sw $t2, 10364($t0)
	sw $t2, 10368($t0)
	sw $t2, 10372($t0)
	sw $t2, 10376($t0)
	sw $t2, 10380($t0)
	sw $t2, 10384($t0)
	sw $t2, 10388($t0)
	
	sw $t2, 10648($t0)
	sw $t2, 10908($t0)
	sw $t2, 11168($t0)
	sw $t2, 11428($t0)
	sw $t2, 11688($t0)
	 
END_loop:
	# go into loop waiting for keyboard press
	# if "p" is typed, restart the game
	# take in input from keyboard, branch if a key was pressed
	li $t1, 0xffff0000
	lw $t0, 0($t1)
	beq $t0, 1, end_keypressed
	j END_loop

end_keypressed:
	#branch to end if 'm' is clicked
	#branch to start of main if 'p' is clicked (restart)
	lw $t7, 4($t1)
	beq $t7, 0x70, main
	beq $t7, 0x6D, end_program
	j END_loop

end_program:
	#end the program
	li $v0, 10
	syscall

clear_screen:
    	li $t0, BASE_ADDRESS
    	addi $t3, $t0, 16384
    	li $t8, Black
    	
clear_loop:
    	beq $t0, $t3, jump
    	sw $t8, 0($t0)
    	addi $t0, $t0, 4
    	j clear_loop
	
floor: la $t6, ($a1)  #starting condition 
	la $t7, ($a2)    #stopping condition 
   	add $t7, $t7, $t6  #adding to the current adrress to create the actual point to stop

floor_loop: 
    	bge $t6, $t7, jump  #break condition: if t6 is greater than or equal to t7=128+startadd then stop and go to end_loop
    	sw $t2, 0($t6) 
    	addi $t6, $t6, 4  
    	j floor_loop # jump to first line of the loop
	
#################################### LEVEL 2 ##################################     
level2: 
main2:  jal clear_screen
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	jal draw_heart
    	
    	#li $t0, BASE_ADDRESS
    	addi $t7, $t7, 32
    	jal draw_heart
    	
    	#li $t0, BASE_ADDRESS
    	addi $t7, $t7, 32
    	jal draw_heart
    	
    	li $s5, 0 	# initialises the colour of the cloud to white 

        
Init2:   #initialize the character 
	li $t0, BASE_ADDRESS
	addi $s0, $t0, Character_start 
	jal draw_character
	
	li $t2, Gray
	addi $a1, $t0, 13312
    	li $a2, 256 
    	jal floor 
    	
    	li $t2, SkyBlue
    	addi $a1, $t0, 11568
    	li $a2, 32 
    	jal floor
    	
    	addi $a1, $t0, 10592
    	jal floor

    	
    	addi $a1, $t0, 1088
    	jal floor
    	
    	jal draw_star
    	
    	jal draw_star2
    	
    	jal draw_star3
   
    	li $s6, Colour_lv2
    
    	b m_loop
    	
#################################### LEVEL 3 ##################################     
level3:
main3:   jal clear_screen
	li $t0, BASE_ADDRESS
    	addi $t7, $t0, Heart_address
    	jal draw_heart
    	
    	#li $t0, BASE_ADDRESS
    	addi $t7, $t7, 32
    	jal draw_heart
    	
    	#li $t0, BASE_ADDRESS
    	addi $t7, $t7, 32
    	jal draw_heart
    	
    	li $s5, 0 	# initialises the colour of the cloud to white 

        
Init3:   #initialize the character 
	li $t0, BASE_ADDRESS
	addi $s0, $t0, Character_start #$s0 is going to hold the character address
	jal draw_character
	
	li $t2, Gray
	addi $a1, $t0, 13312
    	li $a2, 256 
    	jal floor 
    	
    	li $t2, SkyBlue
    	addi $a1, $t0, 11568
    	li $a2, 32
    	jal floor
    	
    	addi $a1, $t0, 10592
    	jal floor

    	
    	addi $a1, $t0, 5224
    	jal floor
    	
    	jal draw_star
    	
    	jal draw_star2
    	
    	jal draw_star3
  
    	li $s6, Colour_lv3	#To keep track of what level we are on.
    	b m_loop
    	
jump:
     jr $ra
         
moving_platform:
# s7 => add of moving platfrom 
# s3 => direction 1=> goes up 0=>goes down 
# s6 => current level colour 

	li $t1, BASE_ADDRESS
	sub $t1, $s7, $t1
	li $t2, 10432
	
	beq $t1, $t2, change_direction
	li $t2, 2752
	beq $t1, $t2, change_direction
	b move_platform

change_direction:
	beq $s3, 0, up
	li $s3, 0	#goes down
	b move_platform 
	
up: li $s3, 1	#goes up

move_platform: 
	beq $s3, 0, move_down 
	# else move up 
	jal erase_moving_platform 
	addi $s7, $s7, -256
	jal draw_moving_platform
	b m_loop
	
move_down: 
	jal erase_moving_platform 
	addi $s7, $s7, 256
	jal draw_moving_platform
	b m_loop
	
draw_moving_platform:
	#lw $t1, $s6	#storing the colour of the platform
    	sw $s6, 0($s7)
    	sw $s6, 4($s7)
    	sw $s6, 8($s7)
    	sw $s6, 12($s7)
    	sw $s6, 16($s7)
    	sw $s6, 20($s7)
    	sw $s6, 24($s7)
    	sw $s6, 28($s7)
    	jr $ra
    	

erase_moving_platform: 
	li $t1, Black	#storing the colour of the platform
    	sw $t1, 0($s7)
    	sw $t1, 4($s7)
    	sw $t1, 8($s7)
    	sw $t1, 12($s7)
    	sw $t1, 16($s7)
    	sw $t1, 20($s7)
    	sw $t1, 24($s7)
    	sw $t1, 28($s7)
    	jr $ra

sleep:
    li $v0, 32
    li $a0, SLEEP_TIME
    syscall
    #b m_loop
    jr $ra