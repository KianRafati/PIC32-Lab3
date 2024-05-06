#include <xc.h>
#include "configbits.c"

.global main
.ent main

main:
    # Initialize ANSELB (analog select register) to digital mode
    la t0, ANSELB
    sw $0, 0(t0)

    # Configure TRISB (I/O direction register) for output
    la t0, TRISB
    ori t1, $0, 0x0000
    sw t1, 0(t0)

    # Point to PORTB and LATB registers
    la s0, LATB

    addu t0 , $0 , $0 # t0 = counter = 0
    addiu t1 , $0 , 4 # t1 = N = 4 digit 

    .data
    number: 
        .word 0x003F, 0x0006, 0x005B, 0x004F, 0x0066,0x006d, 0x007D, 0x0007, 0x007F, 0x006f  
        # 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    student_num:
        .word 4,0,1,1,0,7,9,1,3
    .text

    
    addiu s1 , $0 , 1
    addiu s2 , $0 , 2
    addiu s3 , $0 , 3  
    addiu s4 , $0 , 9
    addiu s6 , $0 , 100

    
    la s5 , student_num

    addu t4 , $0 , $0
    addu t5 , $0 , s1
    addu t6 , $0 , s2
    addu t7 , $0 , s3

display:

    divu $0 , t0 , t1

    mfhi t3 # t3 is the remainder

    divu $0 , t0 , s6
    
    mfhi t8

    beq t3 , $0 , first_digit
    beq t3 , s1 , second_digit
    beq t3 , s2 , third_digit
    beq t3 , s3 , fourth_digit

    fourth_digit:            
        addiu a0, $0 , 0b1000 # 4th seven-seg
 
        beq t4 , s4 , reset_four
        j load_four
        reset_four:
        addu t4 , $0 , $0
        load_four:
        # a1 = student_num[t4] 
        sll t3, t4 , 2
        add t3 , s5 , t3
        lw a1, 0(t3)
        
        jal display_svs_digit
        j continue
    third_digit:
        addiu a0, $0 , 0b0100 # 3rd seven-seg

        beq t5 , s4 , reset_three
        j load_three
        reset_three:
        addu t5 , $0 , $0
        load_three:
        # a1 = student_num[t5] 
        sll t3, t5 , 2
        add t3 , s5 , t3
        lw a1, 0(t3)
        
        jal display_svs_digit
        j continue
    second_digit: 
        addiu a0, $0 , 0b0010 # 2nd seven-seg

        beq t6 , s4 , reset_two
        j load_two
        reset_two:
        addu t6 , $0 , $0
        load_two:
        # a1 = student_num[t6] 
        sll t3, t6 , 2
        add t3 , s5 , t3
        lw a1, 0(t3)
        
        jal display_svs_digit
        j continue    
    first_digit:
        addiu a0, $0 , 0b0001 # 1st seven-seg

        beq t7 , s4 , reset_one
        j load_one
        reset_one:
        addu t7 , $0 , $0
        load_one:
        # a1 = student_num[t7] 
        sll t3, t7 , 2
        add t3 , s5 , t3
        lw a1, 0(t3)
        
        jal display_svs_digit
        j continue    

continue:
    jal delay_animation
    # jal delay_animation
    # jal delay_animation
    # jal turn_off_7seg

    addiu t0, t0 , 1
    
    # next frame
    beq t8, $0 , animation
    j display
    animation:
        addiu t4, t4 , 1
        addiu t5, t5 , 1
        addiu t6, t6 , 1
        addiu t7, t7 , 1
    j display


display_svs_digit: 
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    sll a0 , a0 , 8 
    la t0 , number
    sll a1, a1 , 2
    add t0 , a1, t0
    lw t1, 0(t0)
    or v0 , a0 , t1
    sw v0, 0(s0)
    
    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8
    
    jr ra

turn_off_7seg:
    sw $0, 0(s0)	
    jr ra 
    
delay_animation:
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    or t0, $0, $0
    # lui t1, 0xffff
    ori t1, $0, 10000
    delay:
    addiu t0, t0, 1
    bne	t0, t1, delay	# if t0 != t1 to delay

    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8	
    jr ra


debug:
    addi sp , sp , -4
    sw t0 , 0(sp)
    addiu t0 , $0 , 0xC000
    sw t0, 0(s0)
    lw t0, 0(sp)
    addi sp ,sp, 4
    jr ra


.end main