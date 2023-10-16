		.global	blink

		.macro 	delay_loop count n
				li   t0, \count	   # Load immediate value into t0 for delay count
				loop_\n:
				addi t0, t0, -1
				bnez t0, loop_\n
		.endm

		.text

blink:	

		# Enable GPIO3 output
        lw t0,gpiobase		# load base address for GPIO registers into t0
        lb t1,enable		# load offset for GPIO_ENABLE_REG into t1
        or t2,t0,t1			# add offset to address and store address in t2
        li t0,1 			# load 1 in register t0
        slli t0,t0,3		# shift 1 left by 3 positions
        sw t0,0(t2)			# store value to GPIO_ENABLE_REG

		# Set GPIO matrix GPIO_FUNC_OUT_SEL with a special peripheral index 128 (0×80)
        lw t0,gpiobase		# load base address for GPIO registers into t0
		lh t1,funcsel		# load offset for GPIO_FUNC3_OUT_SEL
		or t2,t0,t1			# add offset for GPIO_FUNC5_OUT_SEL and store address in t2
		lbu t0,index		# load index (0x80) into t0
        sw t0,0(t2) 		# store index to GPIO_FUNC3_OUT_SEL

		# Set the corresponding bit in GPIO_OUT_REG register 
on:	    lw t0,gpiobase		# load base address for GPIO registers into t0
        lb t1,set			# load offset for GPIO_OUT_W1TS_REG
		or t2,t0,t1			# add offset for GPIO_OUT_W1TS_REG
		li t0,1 			# load 1 in register t0
		slli t0,t0,3        # shift 1 left by 3 positions
		sw t0,0(t2) 		# store value to GPIO_OUT_W1TS_REG

		# Delay loop
		delay_loop 20000000 1

		# Clear the corresponding bit in GPIO_OUT_REG register
off:	lw t0,gpiobase		# load base address for GPIO registers into t0
		lb t1,clear	        # load offset for GGPIO_OUT_W1TC_REG
		or t2,t0,t1			# add offset for GPIO_OUT_W1TC_REG 
		li t0,1 			# load 1 in register t0
		slli t0,t0,3        # shift 1 left by 3 positions
		sw t0,0(t2) 		# store value to GPIO_OUT_W1TC_REG

		# Delay loop
		delay_loop 20000000 2

		j on				# jump to on

		.data

gpiobase: 	.word 0x60004000	# base address for GPIO registers
funcsel:	.hword 0x560		# offset for GPIO_FUNC3_OUT_SEL
index:		.byte 0x80			# special index for GPIO_FUNCn_OUT_SEL 
enable:     .byte 0x24			# offset for GPIO_ENABLE_REG
set: 		.byte 0x08			# offset for GPIO_OUT_W1TS_REG
clear:      .byte 0x0C			# offset for GPIO_OUT_W1TC_REG



