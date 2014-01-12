/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
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
 */

#include <stdio.h>
#include "platform.h"
#include "xgpio.h"
#include "xparameters.h"
#include "fsl.h"

#define PLS_1(X) (XGpio_DiscreteRead(X, 1) & 1<<1)
#define PLS_2(X) (XGpio_DiscreteRead(X, 1) & 1<<2)
#define PLS_3(X) (XGpio_DiscreteRead(X, 1) & 1<<3)
#define PLS_4(X) (XGpio_DiscreteRead(X, 1) & 1<<4)

void print(char *str);
extern void xil_printf(const char *ctrl1, ...);

int read_data(XGpio *, XGpio *);
char conv_hex(int);

char conv_hex(int value) {
	switch (value) {
	case 0:
		return '0';
	case 1:
		return '1';
	case 2:
		return '2';
	case 3:
		return '3';
	case 4:
		return '4';
	case 5:
		return '5';
	case 6:
		return '6';
	case 7:
		return '7';
	case 8:
		return '8';
	case 9:
		return '9';
	case 10:
		return 'A';
	case 11:
		return 'B';
	case 12:
		return 'C';
	case 13:
		return 'D';
	case 14:
		return 'E';
	case 15:
		return 'F';
	default:
		return 'Z';
	}
}

int read_data(XGpio *switches, XGpio *buttons) {
	int data1, data2;

	xil_printf("0x00\b\b");

	while (!PLS_1(buttons)) {
		data1 = XGpio_DiscreteRead(switches, 1);
		xil_printf("%c0=%3d\b\b\b\b\b\b", conv_hex(data1), data1 * 16);
	}
	while (PLS_1(buttons))
		;

	while (!PLS_1(buttons)) {
		data2 = XGpio_DiscreteRead(switches, 1);
		xil_printf("%c%c=%3d\b\b\b\b\b\b", conv_hex(data1), conv_hex(data2),
				data1 * 16 + data2);
	}
	while (PLS_1(buttons))
		;
	xil_printf("\n\r");

	return data1 * 16 + data2;

}

int main() {
	XGpio leds, switches, buttons;
	int data[8], result[8], x;

	xil_printf("%c[2JStarting application.\n\r", (char) 27);

	XGpio_Initialize(&switches, XPAR_DIP_SWITCHES_4BIT_DEVICE_ID);
	XGpio_SetDataDirection(&switches, 1, 0xffffffff);

	XGpio_Initialize(&buttons, XPAR_BUTTONS_4BIT_DEVICE_ID);
	XGpio_SetDataDirection(&buttons, 1, 0xffffffff);

	XGpio_Initialize(&leds, XPAR_LEDS_8BIT_DEVICE_ID);
	XGpio_SetDataDirection(&leds, 1, 0);

	while (1) {
		for (x = 0; x < 8; x++)
			data[x] = 0;
		xil_printf("Input data now.\n\r");
		xil_printf("Read data. Please press button 1 to insert.\n\r");
		xil_printf(
				"Maintain button 1 and press button 2 to stop on 2nd char write\n\r");
		xil_printf("Switches value is %c\n\r",
				conv_hex(XGpio_DiscreteRead(&switches, 1)));
		for (x = 0; x < 8; x++) {
			xil_printf("input[%d]=", x);
			data[x] = read_data(&switches, &buttons);
			xil_printf("\n\r");
			if (PLS_2(&buttons))
				break;
		}

		for (x = 0; x < 8; x++) {
			xil_printf("Pushing data: %d\n\r", data[x]);
			putfslx(data[x], 0, FSL_DEFAULT);
		}

		for (x = 0; x < 8; x++) {
			getfslx(result[x], 0, FSL_DEFAULT);
			xil_printf("Retrieving result: %d\n\r", result[x]);
		}

		XGpio_DiscreteWrite(&leds, 1, result[0]);

	}
	return 0;
}
