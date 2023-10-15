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

	
blink:	lw t0,gpiobase		# load addresss for GPIO_FUNC5_OUT_SEL
		lh t1,funcsel		# load value for GPIO_FUNC5_OUT_SEL
		#lb t1,gpioenable	# load value for GPIO_ENABLE_REG_OFFS
		or a0,t0,t1			# add offset for GPIO_FUNC5_OUT_SEL
		lbu t0,index		# load value for GPIO_FUNC5_OUT_SEL
		# li t0,1
		#slli t0,t0,4
		sw t0,0(a0) 		# store value to GPIO_FUNC5_OUT_SEL

#skip:	lw t0,gpiobase		
#		lb t1,gpioenable	
#		or a1,t0,t1		
#		li t0,1
#		slli t0,t0,5		
#		sw t0,0(a1) 		
		
		lw t0,gpiobase		# load addresss for GPIO_OUT_W1TS_REG
		lb t1,gpiooutset	# load value for GPIO_OUT_W1TS_REG
		or a1,t0,t1			# add offset for GPIO_OUT_W1TS_REG
		li t0,1
		slli t0,t0,5
		lb t0,write			# load value for GPIO_OUT_W1TS_REG
		sw t0,0(a1) 		# store value to GPIO_OUT_W1TS_REG

		lw t0,gpiobase		# base
		lb t1,mcusel		# offset
		or a1,t0,t1			# base + offset: register address in a1
		li t0,1				
		slli t0,t0,12		# bit for mcu_sel function 1 in t0
		lw t1,0(a1)			# load register
		or t1,t1,t0			# update value of register
		sw t1,0(a1)			# store value in register

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
delay:	li t0,0
		addi t0,t0,1
		bge t0,t1,blink
		 
		j blink					# jump to app_main

		.data

gpiobase: 	.word 0x60004000	# base address for GPIO registers
#gpioenable: .byte 0x20			# offset for GPIO_ENABLE
funcsel:	.hword 0x560		# offset for GPIO_FUNC3_OUT_SEL
gpioout:	.byte 0x04			# offset for GPIO_OUT
gpiooutset: .byte 0x08			# offset for GPIO_OUT_W1TS_REG
write:		.byte 0x08			# offset for GPIO_OUT_W1TS_REG (Pin 3)
index:		.byte 0x80			# special index for  GPIO_FUNCn_OUT_SEL 
iomuxreg:	.byte 0x18		
muxconfig:	.word 0x51
mcusel:		.byte 0x10			# offset for MCU_SEL