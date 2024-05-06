# Student Number Documentation

- `number` is an array containing the LUT patterns.

- `student_num` is an array containing the desired number to be animated

***

`t0` is our iteration counter, each loop I calculate the ramainder of `t0` to 4 and go to each case corresponding to the remainder.

```js

divu $0 , t0 , t1

mfhi t3 // t3 is the remainder

beq t3 , $0 , first_digit
beq t3 , s1 , second_digit // s1 = 1
beq t3 , s2 , third_digit // s2 = 2
beq t3 , s3 , fourth_digit // s1 = 3
```

If we are in the i-th digit I pass down the corresponding segment code and the digit I want to represent in that seven segment.

```js
// 4th seven-seg
addiu a0, $0 , 0b1000 

// a1 = student_num[t4] 
sll t3, t4 , 2
add t3 , s5 , t3 // s5 is the base address of student_num array
lw a1, 0(t3)        
```

Now for how I'm animating the numbers, there are 4 registers containing the indices of student number `t4 t5 t6 t7` which are initially set to 0 1 2 3 respectivly. Each hundred loops I increment these indices by 1 to go to the next frame.

for example:

initial loop:

4 0 1 1 0 7 9 1 3

0 1 2 3 

101th loop:

4 0 1 1 0 7 9 1 3
  
&nbsp;  1 2 3 4

```js
// next frame
beq t8, $0 , animation
j display
animation:
    addiu t4, t4 , 1
    addiu t5, t5 , 1
    addiu t6, t6 , 1
    addiu t7, t7 , 1
j display
```

When either one of these 4 indices reach the end I reset that index to 0 and continue, this will make an indefinite animation.

```js
beq t4 , s4 , reset_four  // s4 = 9
j load_four
reset_four:
addu t4 , $0 , $0
load_four:
// rest of the loading process of the decimal digit into the display_svs_digit function
```

finally `a0` ,which contains the 4-digit binary number indicating which seven segment we want to lit up, and `a1` ,which contains the decimal digit we want to show, are fed to `display_svs_digit` function and it utilizes the number LUT to map the digit we want to show to the coded format and then stores it into LATB.

```js
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
```
