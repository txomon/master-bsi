#################################################################
# Makefile generated by Xilinx Platform Studio 
# Project:C:\Users\Alumno\proyectos\master-bsi\ejercicio_4\system.xmp
#
# WARNING : This file will be re-generated every time a command
# to run a make target is invoked. So, any changes made to this  
# file manually, will be lost when make is invoked next. 
#################################################################

XILINX_EDK_DIR = /cygdrive/c/Xilinx/12.3/ISE_DS/EDK
NON_CYG_XILINX_EDK_DIR = C:/Xilinx/12.3/ISE_DS/EDK

SYSTEM = system

MHSFILE = system.mhs

MSSFILE = system.mss

FPGA_ARCH = spartan3e

DEVICE = xc3s500eft256-4

LANGUAGE = vhdl
GLOBAL_SEARCHPATHOPT = 
PROJECT_SEARCHPATHOPT = 

SEARCHPATHOPT = $(PROJECT_SEARCHPATHOPT) $(GLOBAL_SEARCHPATHOPT)

SUBMODULE_OPT = 

PLATGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(SUBMODULE_OPT) -msg __xps/ise/xmsgprops.lst

LIBGEN_OPTIONS = -mhs $(MHSFILE) -p $(DEVICE) $(SEARCHPATHOPT) -msg __xps/ise/xmsgprops.lst \
                   $(PROCESSOR_LIBG_OPT)

OBSERVE_PAR_OPTIONS = -error yes

PROGRAM_OUTPUT_DIR = program
PROGRAM_OUTPUT = $(PROGRAM_OUTPUT_DIR)/executable.elf
CYG_PROGRAM_OUTPUT_DIR = program
CYG_PROGRAM_OUTPUT = $(CYG_PROGRAM_OUTPUT_DIR)/executable.elf

MICROBLAZE_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop.elf
MICROBLAZE_BOOTLOOP_LE = $(XILINX_EDK_DIR)/sw/lib/microblaze/mb_bootloop_le.elf
PPC405_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc405/ppc_bootloop.elf
PPC440_BOOTLOOP = $(XILINX_EDK_DIR)/sw/lib/ppc440/ppc440_bootloop.elf
BOOTLOOP_DIR = bootloops

PROCESSOR_BOOTLOOP = $(BOOTLOOP_DIR)/processor.elf
PROCESSOR_XMDSTUB = processor/code/xmdstub.elf

BRAMINIT_ELF_FILES =  
BRAMINIT_ELF_FILE_ARGS =  

ALL_USER_ELF_FILES = $(CYG_PROGRAM_OUTPUT) 

SIM_CMD = vsim

BEHAVIORAL_SIM_SCRIPT = simulation/behavioral/$(SYSTEM)_setup.do

STRUCTURAL_SIM_SCRIPT = simulation/structural/$(SYSTEM)_setup.do

TIMING_SIM_SCRIPT = simulation/timing/$(SYSTEM)_setup.do

DEFAULT_SIM_SCRIPT = $(BEHAVIORAL_SIM_SCRIPT)

MIX_LANG_SIM_OPT = -mixed yes

SIMGEN_OPTIONS = -p $(DEVICE) -lang $(LANGUAGE) $(SEARCHPATHOPT) $(BRAMINIT_ELF_FILE_ARGS) $(MIX_LANG_SIM_OPT) -msg __xps/ise/xmsgprops.lst -s mti -X C:/Users/Alumno/proyectos/master-bsi/ejercicio_4/


LIBRARIES =  \
       processor/lib/libxil.a 

LIBSCLEAN_TARGETS = processor_libsclean 

PROGRAMCLEAN_TARGETS = program_programclean 

CORE_STATE_DEVELOPMENT_FILES = 

WRAPPER_NGC_FILES = implementation/data_lmb_wrapper.ngc \
implementation/sys_plb_wrapper.ngc \
implementation/processor_wrapper.ngc \
implementation/instruction_lmb_wrapper.ngc \
implementation/debugger_wrapper.ngc \
implementation/leds_switch_8_4_wrapper.ngc \
implementation/clock_mod_wrapper.ngc \
implementation/reset_mod_wrapper.ngc \
implementation/ctrl_instructions_wrapper.ngc \
implementation/ctrl_data_wrapper.ngc \
implementation/ram_wrapper.ngc

POSTSYN_NETLIST = implementation/$(SYSTEM).ngc

SYSTEM_BIT = implementation/$(SYSTEM).bit

DOWNLOAD_BIT = implementation/download.bit

SYSTEM_ACE = implementation/$(SYSTEM).ace

UCF_FILE = data/system.ucf

BMM_FILE = implementation/$(SYSTEM).bmm

BITGEN_UT_FILE = etc/bitgen.ut

XFLOW_OPT_FILE = etc/fast_runtime.opt
XFLOW_DEPENDENCY = __xps/xpsxflow.opt $(XFLOW_OPT_FILE)

XPLORER_DEPENDENCY = __xps/xplorer.opt
XPLORER_OPTIONS = -p $(DEVICE) -uc $(SYSTEM).ucf -bm $(SYSTEM).bmm -max_runs 7

FPGA_IMP_DEPENDENCY = $(BMM_FILE) $(POSTSYN_NETLIST) $(UCF_FILE) $(XFLOW_DEPENDENCY)

# cygwin path for windows
SDK_EXPORT_DIR = SDK/SDK_Export/hw
CYG_SDK_EXPORT_DIR = SDK/SDK_Export/hw
SYSTEM_HW_HANDOFF = $(SDK_EXPORT_DIR)/$(SYSTEM).xml
CYG_SYSTEM_HW_HANDOFF = $(CYG_SDK_EXPORT_DIR)/$(SYSTEM).xml
SYSTEM_HW_HANDOFF_BIT = $(SDK_EXPORT_DIR)/$(SYSTEM).bit
CYG_SYSTEM_HW_HANDOFF_BIT = $(CYG_SDK_EXPORT_DIR)/$(SYSTEM).bit
SYSTEM_HW_HANDOFF_BMM = $(SDK_EXPORT_DIR)/$(SYSTEM)_bd.bmm
CYG_SYSTEM_HW_HANDOFF_BMM = $(CYG_SDK_EXPORT_DIR)/$(SYSTEM)_bd.bmm
SYSTEM_HW_HANDOFF_DEP = $(CYG_SYSTEM_HW_HANDOFF) $(CYG_SYSTEM_HW_HANDOFF_BIT) $(CYG_SYSTEM_HW_HANDOFF_BMM)

#################################################################
# SOFTWARE APPLICATION PROGRAM
#################################################################

PROGRAM_SOURCES = program/main.c 

PROGRAM_HEADERS = 

PROGRAM_CC = mb-gcc
PROGRAM_CC_SIZE = mb-size
PROGRAM_CC_OPT = -O2
PROGRAM_CFLAGS = 
PROGRAM_CC_SEARCH = # -B
PROGRAM_LIBPATH = -L./processor/lib/ # -L
PROGRAM_INCLUDES = -I./processor/include/ # -I
PROGRAM_LFLAGS = # -l
PROGRAM_LINKER_SCRIPT = 
PROGRAM_LINKER_SCRIPT_FLAG = #-T $(PROGRAM_LINKER_SCRIPT) 
PROGRAM_CC_DEBUG_FLAG =  -g 
PROGRAM_CC_PROFILE_FLAG = # -pg
PROGRAM_CC_GLOBPTR_FLAG= # -mxl-gp-opt
PROGRAM_MODE = executable
PROGRAM_LIBG_OPT = -$(PROGRAM_MODE) processor
PROGRAM_CC_INFERRED_FLAGS= -mxl-soft-mul -mxl-barrel-shift -mxl-pattern-compare -mno-xl-soft-div -mcpu=v8.00.a 
PROGRAM_CC_START_ADDR_FLAG=  # -Wl,-defsym -Wl,_TEXT_START_ADDR=
PROGRAM_CC_STACK_SIZE_FLAG=  # -Wl,-defsym -Wl,_STACK_SIZE=
PROGRAM_CC_HEAP_SIZE_FLAG=  # -Wl,-defsym -Wl,_HEAP_SIZE=
PROGRAM_OTHER_CC_FLAGS= $(PROGRAM_CC_GLOBPTR_FLAG)  \
                  $(PROGRAM_CC_START_ADDR_FLAG) $(PROGRAM_CC_STACK_SIZE_FLAG) $(PROGRAM_CC_HEAP_SIZE_FLAG)  \
                  $(PROGRAM_CC_INFERRED_FLAGS)  \
                  $(PROGRAM_LINKER_SCRIPT_FLAG) $(PROGRAM_CC_DEBUG_FLAG) $(PROGRAM_CC_PROFILE_FLAG) 
