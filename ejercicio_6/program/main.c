#include "xparameters.h"
#include "stdio.h"

#define WAIT_TIME 1000000

int main ()
{
	unsigned int *leds = (unsigned int *) (XPAR_LEDS_SWITCH_8_4_BASEADDR + 0x00);
	unsigned int *switches = (unsigned int *) (XPAR_LEDS_SWITCH_8_4_BASEADDR + 0x08);
	volatile int waiting;
	volatile unsigned int temp;
	while(1)
	{
		*leds = *switches + 1;
		for (waiting = 0 ; waiting < WAIT_TIME;){
			waiting++;
		}
	}
	
	return 0;
}
