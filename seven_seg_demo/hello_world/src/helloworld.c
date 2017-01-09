/*
 * Copyright (c) 2009-2012 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 */

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <xiomodule.h>
#include <xiomodule_l.h>
#include <xil_exception.h>
#include "platform.h"
#include <xil_printf.h>

XIOModule gpio;

void print(char *str);

u16 state = 0xDEAD;

void fitInterrupt(void *data) {
	u16 bit = ((state >> 15) & 1) ^ ((state >> 13) & 1) ^ ((state >> 12) & 1) ^ ((state >> 10) & 1);
	state = (state << 1) | bit;

	XIOModule_DiscreteWrite(&gpio, 1, state);

	print("ping\r\n");
}

void uartRecv(void* data) {

}

int main()
{
    init_platform();

    state = 0xDEAD;

    XIOModule_Initialize(&gpio, XPAR_IOMODULE_0_DEVICE_ID);
    XIOModule_Start(&gpio);
    XIOModule_DiscreteWrite(&gpio, 1, (u32)state);

    XIOModule_Connect(&gpio, XIN_IOMODULE_UART_TX_INTERRUPT_INTR, uartRecv, NULL);
    XIOModule_Connect(&gpio, XIN_IOMODULE_FIT_1_INTERRUPT_INTR, fitInterrupt, NULL);
    XIOModule_Enable(&gpio, XIN_IOMODULE_FIT_1_INTERRUPT_INTR);

    Xil_ExceptionInit();
    Xil_ExceptionRegisterHandler(
    	XIL_EXCEPTION_ID_INT,
    	(Xil_ExceptionHandler)XIOModule_DeviceInterruptHandler, NULL
    );
    Xil_ExceptionEnable();

    return 0;
}
