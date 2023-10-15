		.global	blink

		.text

# Simple GPIO Output 
# - Set GPIO matrix GPIO_FUNC_OUT_SEL with a special peripheral index 128 (0×80);
# - Set the corresponding bit in GPIO_OUT_REG register to the desired GPIO output value.
# GPIO3
# GPIO_FUNC3_OUT_SEL => 0x80
# GPIO_OUT_DATA_bit_x (Bit 3, position 4) => ...01000 (0x08)
# ---GPIO_FUNCX_OUT_INV_SEL--- (default 0)
# MCU_SEL (Offset: 0x0010) => 1 (Position 12-14) shift 12 + or

blink:	

# GPIO Enable (p 173)

        lw t0,gpiobase
        lb t1,enable
        or t2,t0,t1	
        li t0,1 
        slli t0,t0,3
        sw t0,0(t2)

# Set GPIO matrix GPIO_FUNC_OUT_SEL with a special peripheral index 128 (0×80);
        lw t0,gpiobase		# load addresss for GPIO_FUNC5_OUT_SEL
		lh t1,funcsel		# load value for GPIO_FUNC5_OUT_SEL
		or t2,t0,t1			# add offset for GPIO_FUNC5_OUT_SEL => address in t2
		lbu t0,index		# load index (0x80) for GPIO_FUNC5_OUT_SEL
        sw t0,0(t2) 		# store value to GPIO_FUNC5_OUT_SEL

# Set the corresponding bit in GPIO_OUT_REG register to the desired GPIO output value.
# Use GPIO_OUT_W1TS_REG (0x0008)
    
on:	    lw t0,gpiobase		# load addresss for GPIO_OUT_W1TS_REG
        lb t1,gpiooutset	# load value for GPIO_OUT_W1TS_REG
		or t2,t0,t1			# add offset for GPIO_OUT_W1TS_REG => address in t2
		li t0,1 
		slli t0,t0,3        # bit for GPIO_OUT_W1TS_REG (Pin 3) in t0
		sw t0,0(t2) 		# store value to GPIO_OUT_W1TS_REG

    li   t0, 10000000     # Load immediate value into t0 for delay count
delay_loop:
    addi t0, t0, -1      # Decrement t0 by 1
    bnez t0, delay_loop  # If t0 is not zero, branch to delay_loop

off:	lw t0,gpiobase		# load addresss for GPIO_OUT_W1TS_REG
		lb t1,clear	        # load value for GGPIO_OUT_W1TC_REG (0x000C)
		or t2,t0,t1			# add offset for GPIO_OUT_W1TS_REG => address in t2
		li t0,1 
		slli t0,t0,3        # bit for GPIO_OUT_W1TS_REG (Pin 3) in t0
		sw t0,0(t2) 		# store value to GPIO_OUT_W1TS_REG

    li   t0, 10000000     # Load immediate value into t0 for delay count
delay_loop2:
    addi t0, t0, -1      # Decrement t0 by 1
    bnez t0, delay_loop2  # If t0 is not zero, branch to delay_loop

		j on					# jump to app_main



# GPIO_OUT_W1TC_REG (0x000C) to clear the corresponding bit in GPIO_OUT_REG register to the desired GPIO output value.

###

#		lw t0,gpiobase		# base
#		lb t1,mcusel		# offset
#		or a1,t0,t1			# base + offset: register address in a1
#		li t0,1				
#		slli t0,t0,12		# bit for mcu_sel function 1 in t0
#		lw t1,0(a1)			# load register
#		or t1,t1,t0			# update value of register
#		sw t1,0(a1)			# store value in register

#		lw t0,gpiobase
#		lb t1,iomuxreg
#		or a2,t0,t1
#		lw t0,muxconfig
#		sw t0,0(a2)
		
check:	lw t0,gpiobase
		lh t1,funcsel
		# lb t1,gpioenable
		or a3,t0,t1
		lw a3,0(a3)

		lw t0,gpiobase		
		lb t1,gpioout		
		or a4,t0,t1
		lw a4,0(a4)

		lw t0,gpiobase		
		lb t1,mcusel		
		or a5,t0,t1
		lw a5,0(a5)

		li t1,1000


		.data

gpiobase: 	.word 0x60004000	# base address for GPIO registers
#gpioenable: .byte 0x20			# offset for GPIO_ENABLE
funcsel:	.hword 0x560		# offset for GPIO_FUNC3_OUT_SEL (GPIO3)
gpioout:	.byte 0x04			# offset for GPIO_OUT
gpiooutset: .byte 0x08			# offset for GPIO_OUT_W1TS_REG
write:		.byte 0x08			# offset for GPIO_OUT_W1TS_REG (Pin 3)
index:		.byte 0x80			# special index for  GPIO_FUNCn_OUT_SEL 
iomuxreg:	.byte 0x18		
muxconfig:	.word 0x51
mcusel:		.byte 0x10			# offset for MCU_SEL
enable:     .byte 0x24
clear:      .byte 0x0C