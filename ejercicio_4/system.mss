


BEGIN OS
 PARAMETER OS_NAME = standalone
 PARAMETER OS_VER = 3.00.a
 PARAMETER PROC_INSTANCE = processor
END


BEGIN PROCESSOR
 PARAMETER DRIVER_NAME = cpu
 PARAMETER DRIVER_VER = 1.13.a
 PARAMETER HW_INSTANCE = processor
 PARAMETER COMPILER = mb-gcc
 PARAMETER ARCHIVER = mb-ar
END


BEGIN DRIVER
 PARAMETER DRIVER_NAME = generic
 PARAMETER DRIVER_VER = 1.00.a
 PARAMETER HW_INSTANCE = sys_plb
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = uartlite
 PARAMETER DRIVER_VER = 2.00.a
 PARAMETER HW_INSTANCE = debugger
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = gpio
 PARAMETER DRIVER_VER = 3.00.a
 PARAMETER HW_INSTANCE = leds_switch_8_4
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 2.00.a
 PARAMETER HW_INSTANCE = ctrl_instructions
END

BEGIN DRIVER
 PARAMETER DRIVER_NAME = bram
 PARAMETER DRIVER_VER = 2.00.a
 PARAMETER HW_INSTANCE = ctrl_data
END


