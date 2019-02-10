# -----------------------------------------------------------------------------------------
# University of Piraeus
# JTAG Configuration Engine
# Version 1.0.0
# Date 22/12/2018
#
# This file is used to contain specific settings for the UltraScale FPGA family
# -----------------------------------------------------------------------------------------
global DEF_FDR_PIPE_DEPTH
global DEF_USER4
global DEF_JCONFIG
global DEF_JRDBK
global DEF_BYPASS
global DEF_CMD_IDCODE
global DEF_AXSS
global DEF_TYPE_1
global DEF_TYPE_2
global DEF_IDCODE
global DEF_WRITE
global DEF_READ
global DEF_FDRO
global DEF_FDRI
global DEF_FAR
global DEF_CMD
global DEF_MSK
global DEF_CTL1
global DEF_CTL0
global DEF_SYNCWORD
global DEF_Z7020
global DEF_Z7010
global DEF_WPF

# Defines word per frame for UltraScale
set DEF_WPF 101
# Defines pipeline value to add to frame count
set DEF_FDR_PIPE_DEPTH 0

#Defines UltraScale JTAG instruction opcodes 
set DEF_USER4              0x23
set DEF_JCONFIG            0x05
set DEF_JRDBK              0x04
set DEF_BYPASS             0x3F
set DEF_CMD_IDCODE         0x09
set DEF_AXSS			   0x37

# Defines UltraScale configuration register commands
set DEF_TYPE_1 001
set DEF_TYPE_2 010
set DEF_IDCODE 01100
set DEF_WRITE 10
set DEF_READ  01
set DEF_FDRO 00011
set DEF_FDRI 00010
set DEF_FAR  00001
set DEF_CMD  00100
set DEF_MSK  00110 
set DEF_CTL1 11000
set DEF_CTL0 00101

# Defines UltraScale syncword
set DEF_SYNCWORD AA995566

# IDCODEs for FPGA devices
set DEF_Z7010 13722093
set DEF_Z7020 23727093
