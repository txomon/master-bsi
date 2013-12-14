#include "xparameters.h"
#include "stdio.h"

#define WAIT_TIME 1000

int main ()
{
	unsigned int *leds = (unsigned int *) XPAR_LEDS_SWITCH_8_4_BASEADDR;
	unsigned int *switches = (unsigned int *) (XPAR_LEDS_SWITCH_8_4_BASEADDR + 0x08);
	int waiting;
	unsigned int temp;
	while(1)
	{
		temp = *switches;
		*leds = temp;
		for (waiting = 0 ; waiting < WAIT_TIME ; waiting++){
			asm("");
		}
	}
	
	return 0;
}