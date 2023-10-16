# Blink an LED 

This example shows how to toggle a GPIO pin with RISC-V assembly only using registers as described in the [ESP32­C3
Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf).

# GPIO matrix and IO MUX
![Diagram](GPIO_diagram.png)

## Enable GPIO3 output
GPIO output has to be enabled by setting the respective bit in register GPIO_ENABLE_REG (0x0024). See 5.1.1 (p 161) and p 73 in
[ESP32­C3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf)
for details.

## Set GPIO matrix GPIO_FUNC_OUT_SEL with a special peripheral index 128 (0×80)
Simple GPIO output (see section 5.5.3, p 158 in 
[ESP32­C3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf))
the special value `0x80` has to be loaded in the register GPIO_FUNCn_OUT_SEL_CFG_REG. 
The address is (x0554+4*n) and therefore 0x0560 for GPIO3 (see p 170, 178) for details. 

`
lw t0,gpiobase		# load base address for GPIO registers into t0
lh t1,funcsel		# load offset for GPIO_FUNC3_OUT_SEL
or t2,t0,t1			# add offset for GPIO_FUNC3_OUT_SEL and store address in t2
lbu t0,index		# load index (0x80) into t0
sw t0,0(t2) 		# store index to GPIO_FUNC3_OUT_SEL
`

## Set the corresponding bit in GPIO_OUT_REG register 
To set the appropriate bit for the output for GPIO3 is has to be set in GPIO_OUT_REG (0x0004).
Recommended operation is to use GPIO_OUT_W1TS_REG (0x0008) to set the bit in GPIO_OUT_REG. See p 172 in 
[ESP32­C3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf)
for details.


## Clear the corresponding bit in GPIO_OUT_REG register
To clear the appropriate bit for the output for GPIO3 is has to be cleared in GPIO_OUT_REG (0x0004).
Recommended operation is to use GPIO_OUT_W1TC_REG (0x000C) to clear the bit in GPIO_OUT_REG. See p 173 in 
[ESP32­C3 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c3_technical_reference_manual_en.pdf)
for details.
