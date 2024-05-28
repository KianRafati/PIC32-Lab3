#include <xc.h>

//You cannot use sp as a general purpose register.

#define TIMER_PERIOD (20000)    // maximum value is 65535, actual rate is 5,000,000/TIMER_PERIOD

#define CT_INT_ON (0)
#define CT_INT_PRIOR_3 (3)

.global main

.data

seg:
.word 0x0000, 0x0000, 0x0000, 0x0000
# //    seg1, seg2, seg3, seg4
InterruptCounter:
.word 0x0000

number:
.word 0x003F, 0x0006, 0x005B, 0x004F, 0x0066,0x006d, 0x007D, 0x0007, 0x007F, 0x006f  
      # 0, 1, 2, 3, 4, 5, 6, 7, 8, 9

A_column:
.word 0b0001,0b0010,0b0100

B_row:
.word 0x0000,0x1000,0x0000,0x0000,0x2000,0x0000,0x0000,0x4000
#        0 ,    1   ,  2  ,  3   ,  4  ,  5  ,  6  ,  7
.text
   
.ent main
main:

jal InterruptSetup

addiu s2 , $0 , 0xf000

la $8, ANSELA
sw $0 , 0($8)

la $8, ANSELB
sw $0, 0($8)

la $8, TRISB
sw s2, 0($8)

la $8, TRISA
sw $0, 0($8)

la s0, LATA
sw $0, 0(s0)

la s4, LATB
sw $0, 0(s4)

la s1, PORTB
sw $0, 0(s1)


# loop:
#    jal read_keypad
#    j loop

loop:
   # addi sp , sp , -12
   # sw t0 , 8(sp)
   # sw t1 , 4(sp)
   # sw t2 , 0(sp)
   addiu t0 , $0 , 1
   addiu t1 , $0 , 0b1000
   iterate_column:
      beq t1 , t0 , break_iterate

      sw t0 , 0(s0)

      iterate_row:
         # nop
         # nop
         # nop
         jal delay_animation
         lw s3 , 0(s1)
         # srl t2 , s3 , 12
         and t2 , s2 , s3

         # sw v0, 0(s4)

         beq t2 , $0 , continue
         
         # addiu t8 , $0 , 0x0480
         # la t9 , seg
         # sw t8 , 4(t9)

         addu a0 , $0 , t0
         addu a1 , $0 , t2
         jal entry_to_digit
         addu a1 , $0 , v0
         jal display_svs_digit

         j break_iterate

      continue:
            sll t0 , t0 , 1
            j iterate_column

   break_iterate:
   # lw t2 , 0(sp)
   # lw t1, 4(sp)
   # lw t0, 8(sp)
   # addi sp ,sp, 12
   # # jal debug
   j loop

entry_to_digit:
   addi sp , sp , -16
   sw t0 , 12(sp)
   sw t1 , 8(sp)
   sw t2 , 4(sp)
   sw t3 , 0(sp)

   addiu t0 , $0 , 0
   addiu t1 , $0 , 3

   la t2 , A_column

   iterate_A:
      beq t0 ,t1,found_A

      sll t3 , t0 , 2
      addu t3 , t2 , t3
      lw t3 , 0(t3)
      beq a0 ,t3 , found_A 

      addiu t0 , t0 , 1
      j iterate_A
   
   found_A:
   # v0 = index of A_column 0 , 1 , 2
   addu v0 , $0 , t0

   addiu t0 , $0 , 0
   addiu t1 , $0 , 8
   la t2 , B_row
   
   iterate_B:
      beq t0 ,t1,end_of_B

      sll t3 , t0 , 2
      addu t3 , t2 , t3
      lw t3 , 0(t3)
      beq a1 ,t3 , found_B

      addiu t0 , t0 , 1
      j iterate_B
   
   end_of_B:
   # addiu t3 , $0 , 0x8000
   # beq a1 , t3 , found_B
   # jal debug
   addi v1 , $0 , -1
   j end_of_entry_func

   found_B:
   # v1 = index of B_row 1 , 4 , 7 
   addu v1 , $0 , t0

   end_of_entry_func:
   lw t3 , 0(sp)
   lw t2 , 4(sp)
   lw t1, 8(sp)
   lw t0, 12(sp)
   addi sp ,sp, 16
   addu v0 ,v0 , v1
   # v1 = 8
   jr ra


display_svs_digit: 
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    la t0 , number
    sll a1, a1 , 2
    add t0 , a1, t0
    lw t1, 0(t0)
    addu v0 , $0 , t1
    
    ori v0, v0, 0x0800
   #  la t1 , seg
   #  sw v0, 0(t1)
    sw v0, 0(s4)
    
    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8
    
    jr ra

debug:
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    addiu t0 , $0 , 0x0480
   #  la t1 , seg
   #  sw t0 , 4(t1)
    sw t0 , 0(s4)

    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8
    jr ra
    

debug2:
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    addiu t0 , $0 , 0x0280
   #  la t1 , seg
   #  sw t0 , 8(t1)
    sw t0 , 8(s4)

    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8
    jr ra


delay_animation:
    addi sp , sp , -8
    sw t0 , 4(sp)
    sw t1 , 0(sp)

    or t0, $0, $0
   #  lui t1, 0xffff
    ori t1, $0, 0xffff
    delay:
    addiu t0, t0, 1
    bne	t0, t1, delay	# if t0 != t1 to delay

    lw t1, 0(sp)
    lw t0, 4(sp)
    addi sp ,sp, 8	
    jr ra





.end main

# /*********************************************************************
#  * This is the actual interrupt handler that gets installed
#  * in the interrupt vector table. It jumps to the core-timer
#  * interrupt handler function.
#  *
#  * Note: The ".section .vector_0" is not allocatable. Hence to force
#  * this section to be allocatable, use the "ax" directive.
#  ********************************************************************/
.section .vector_0,code
   j      CoreTimerIntHandler

# /*********************************************************************
#  * CoreTimerIntHandler()
#  * Interrupt handler function for core-timer. The function
#  * clears the interrupt flag, shows one digit on the seven segment board and updates the
#  * core-timer registers.
#  *
#  * pre-condition: A jump to ISR is registered in vector table
#  * Input: none
#  * Output: none
#  * Side effect: shows one digit on the seven segment board
#  ********************************************************************/
.text
.ent CoreTimerIntHandler
CoreTimerIntHandler:
   /* interrupt prologue */
   addiu sp, sp, -20
   sw $1, 0(sp)
   sw t0, 4(sp)
   sw t1, 8(sp)
   
   mfc0 t1, $14          /* read EPC register (program counter at last exeption) */
   sw t1, 12(sp)      /* save EPC on stack */
   
   mfc0 t1, $12         /* read STATUS register */
   sw t1, 16(sp)         /* save STATUS on stack */
   
   mfc0        t0, $13          /* read CAUSE register */
   srl         t0, t0,0xA      /* align RIPL (Requested Interrupt Priority Level) to bit 0 */
   ins         t1, t0, 10, 6      /* insert RIPL to IPL(Interrupt Priority Level) field (copy and replace from 6 LSBs of k0 to k1 starting at bit 10 of k1, k1<15:10> = k0<5:0>) */
   ins         t1, zero, 1, 4   /* k1<4:1> = zero<3:0> */
   mtc0        t1, $12         /* write STATUS register  (status<15:10> = cause<15:10>, status<4:1> = 0)  */
   
   
   /* set up t0 with time period and then call the update core-timer routine for next interrupt. */
   ori     t0, zero, TIMER_PERIOD
   mtc0    $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0    t0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   /* clear interrupt flag */
   addiu   t1, zero, 1
   la      t0, IFS0CLR
   sw      t1, 0(t0)    // IFS0<0> = 0
   
#    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   la t0, LATBCLR
   addi t1, zero, 0x0fff
   sw t1, 0(t0)
   
   la t1, InterruptCounter
   lw t0, 0(t1)
   addiu t0, t0, 4
   sw t0, 0(t1)       // InterruptCounter = InterruptCounter + 4
   andi t0, t0, 0xf     // t0 = InterrupCounter%16
   la t1, seg
   add t0, t1, t0       // t0 = seg address + InterrupCounter%16
   
    lw t1, 0(t0)        // t1 = pattern
    andi t1, t1, 0x0fff
    la t0, LATBSET
    sw t1, 0(t0)        // LATB<11:0> = seg<11:0>
     
#    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
   /* interrupt epilogue */
   di                      /* disable interrupts */
   
   lw t1, 12(sp)      /* restore EPC from stack */
   mtc0 t1, $14
   
   lw t1, 16(sp)         /* restore STATUS from stack */
   mtc0 t1, $12
   
   lw $1, 0(sp)
   lw t0, 4(sp)
   lw t1, 8(sp)
   addiu sp, sp, 20
   
   ei                        /* enable interrupts */
   /* return from interrupt */
   eret        
.end CoreTimerIntHandler
   
#  /*********************************************************************
#  * InterruptSetup()
#  *
#  * cause<23> = 1
#  * ei
#  * count = 0
#  * compare = TIMER_PERIOD
#  * IFS0CLR<0> = 0
#  * IPC0<4:2> = CT_INT_PRIOR_3
#  * IEC0<0> = CT_INT_ON
#  ********************************************************************/
.ent InterruptSetup
InterruptSetup:
    /* function prologue - save registers used in this function
     * on stack and adjust stack-pointer
     */
   addiu   sp, sp, -8
   sw      s0, 0(sp)
   sw      s1, 4(sp)

   //INTEnableSystemMultiVectoredInt:
   mfc0    s0, $13
   lui     s1, 0x0080
   or      s0, s0, s1
   mtc0    s0, $13  // bit <23> (IV bit = Interrupt Vector) in the cause register ($13) in coprocessor0 is set
   ei      /* enable system-wide interrupts */
   
   //OpenCoreTimer:
   ori     s0, zero, TIMER_PERIOD  // s0 = TIMER_PERIOD
   mtc0    $0, $9   // count register ($9) in coprocessor0 = 0
   mtc0    s0, $11  // compare register ($11) in coprocessor0 = TIMER_PERIOD
   
   //mCTClearIntFlag:
   addiu   s1, zero, 1
   la      s0, IFS0CLR
   sw      s1, 0(s0)    // bit <0> in the Interrupt Flag Status register is cleared
   
   //mCTSetIntPriority:
   addiu   s1, zero, (7 << 2)
   la      s0, IPC0CLR
   sw      s1, 0(s0)
   ori     s0, zero, CT_INT_PRIOR_3 // s0 = CT_INT_PRIOR_3
   sll     s1, s0, 2
   la      s0, IPC0SET
   sw      s1, 0(s0)    // bits <4:2> in the Interrupt Priority Control register (of the core timer interrupt), which are the core timer interrupt priority bits = CT_INT_PRIOR_3
   
   //mCTIntEnable:
   ori     s1, zero, CT_INT_ON  // s1 = CT_INT_ON
   la      s0, IEC0SET
   sw      s1, 0(s0)    // bit <0> in the Interrupt Enable Control register (of the core timer interrupt), which is the core timer interrupt enable bit = CT_INT_ON
   
   /* function epilogue - restore registers used in this function
     * from stack and adjust stack-pointer
     */
   lw      s1, 4(sp)
   lw      s0, 0(sp)
   addiu   sp, sp, 8
   
#    /* return to caller */
   jr      ra
.end InterruptSetup