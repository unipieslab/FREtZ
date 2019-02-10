# -----------------------------------------------------------------------------------------
# University of Piraeus
# JTAG Configuration Engine
# Version 1.0.0
# Date 22/12/2018
#
# NOTE: The TCL functions setHexBinTbl, setHexRevTbl, revHexData, conv2bin, conv2hex
#       are taken from Xilinx application note xapp1230 and are used here as is.
# -----------------------------------------------------------------------------------------

# Use UltraScale FPGA family
source zynq7000.tcl

# Server configuration port. Please change the TCL port for the server as required by the application
set Port 9955
set Debug 0

# FPGA device configuration. Please change the following according to the target FPGA device
# Target FPGA
global DEF_Z7010
global DEF_Z7020
set TARGET_ID $DEF_Z7010

# Server commands: The server responds to the following commands
set COMMAND_FPGA_CONFIGURE     			"CONFIGURATION"
set COMMAND_FPGA_READBACK      			"READBACK"
set COMMAND_FPGA_READBACK_CAPTURE      	"READBACK_CAPTURE"
set COMMAND_FPGA_READBACK_VERIFY      	"READBACK_VERIFY"
set COMMAND_FPGA_READ_FIFO              "READ_FIFO"
set COMMAND_FPGA_RESET_FIFO				"RESET_FIFO"
set COMMAND_FPGA_READ_HEARTBEAT	        "READ_HEARTBEAT" 
set COMMAND_FPGA_WRITE_FRAMES           "FRAMES_WRITE"
set COMMAND_FPGA_READ_FRAMES            "FRAMES_READ"
set COMMAND_FPGA_LOGIC_STATUS			"LOGIC_STATUS"
set COMMAND_FPGA_FAULT_INJECTION_READ   "FAULT_INJECTION_READ"
set COMMAND_FPGA_FAULT_INJECTION_WRITE  "FAULT_INJECTION_WRITE"
set COMMAND_FPGA_REGISTER_READ  		"REGISTER_READ"
set COMMAND_FPGA_REGISTER_WRITE  		"REGISTER_WRITE"

# Constants 
set FPGA_MODE_NORMAL			0x01
set FPGA_MODE_JTAG				0x02

# Variables
set file_log ____rdbk.log
set prog_ctrl 1
set fileOutput 0
set globDebug 0
set optOverwrite 0

# -----------------------------------------------------------------------------
# FPGA mode
# -----------------------------------------------------------------------------
set fpga_mode		0x01
set tcp_client		0

namespace eval server {}
namespace eval fpga {}

# ================================================================================
# --------------------------------------------------------------------------------
# FPGA configuration readback functionality
# --------------------------------------------------------------------------------
# ================================================================================
# -----------------------------------------------------------------------------
# Setup hex to bin array
# Ex: 0x5  = binary 0101
# -----------------------------------------------------------------------------
proc setHexBinTbl {} {
  global arrayHexBinVal

  set arrayHexBinVal(0) 0000
  set arrayHexBinVal(1) 0001
  set arrayHexBinVal(2) 0010
  set arrayHexBinVal(3) 0011
  set arrayHexBinVal(4) 0100
  set arrayHexBinVal(5) 0101
  set arrayHexBinVal(6) 0110
  set arrayHexBinVal(7) 0111
  set arrayHexBinVal(8) 1000
  set arrayHexBinVal(9) 1001
  set arrayHexBinVal(A) 1010
  set arrayHexBinVal(B) 1011
  set arrayHexBinVal(C) 1100
  set arrayHexBinVal(D) 1101
  set arrayHexBinVal(E) 1110
  set arrayHexBinVal(F) 1111

  set arrayHexBinVal(a) 1010
  set arrayHexBinVal(b) 1011
  set arrayHexBinVal(c) 1100
  set arrayHexBinVal(d) 1101
  set arrayHexBinVal(e) 1110
  set arrayHexBinVal(f) 1111
}
# -----------------------------------------------------------------------------
# Reverse hex values in str
# Setup array to return reverse of specified hex value
# Ex: 0x5 (binary 0101) when reversed is 0xA (binary 1010)
# -----------------------------------------------------------------------------
proc setHexRevTbl {} {
  global arrayHexVal

  set arrayHexVal(0) 0
  set arrayHexVal(1) 8
  set arrayHexVal(2) 4
  set arrayHexVal(3) C
  set arrayHexVal(4) 2
  set arrayHexVal(5) A
  set arrayHexVal(6) 6
  set arrayHexVal(7) E
  set arrayHexVal(8) 1
  set arrayHexVal(9) 9
  set arrayHexVal(A) 5
  set arrayHexVal(B) D
  set arrayHexVal(C) 3
  set arrayHexVal(D) B
  set arrayHexVal(E) 7
  set arrayHexVal(F) F

  set arrayHexVal(a) 5
  set arrayHexVal(b) D
  set arrayHexVal(c) 3
  set arrayHexVal(d) B
  set arrayHexVal(e) 7
  set arrayHexVal(f) F
  return 1
}
# -----------------------------------------------------------------------------
# Reverse hex values in str
# Ex: 0x80034014 becomes 0x2802C001
# - Note: Chars in string are indexed [0 1 2 .. N-1]
# -       = works only for strings where the number of bits represented
#           by hex characters is a multiple of 4
# -----------------------------------------------------------------------------
proc revHexData {argHexStr} {
  global arrayHexVal
  global globDebug

  if {$globDebug == 1} {
    puts "In revHexData = $argHexStr"
  }

  if {![string is xdigit $argHexStr]} {
    puts "ERROR: TDI data contains non-hex chars"
    return "0x0x0x0"
  }
  set numchars [string length $argHexStr] 
  for {set iX 0} {$iX < $numchars} {incr iX} {
    set sHex [string index $argHexStr [expr ($numchars - $iX - 1)]]
    set sHex $arrayHexVal($sHex) 
    if {$iX == 0} {
      set sStr $sHex
      continue;
    } else {
      append sStr $sHex
    }
  }; # end of FOR $iX < $numchars
  return $sStr
}; # end of revHexData
# -----------------------------------------------------------------------------
# Convert hex data pattern to a bit pattern of argBitCount.
# - con2bin 10 36
#   = will be converted to 00_0011_0110
# -----------------------------------------------------------------------------
proc conv2bin { argBitCount argHexPattern } {
  global globDebug
  global arrayHexBinVal

  set iFirstHex 1

  if {$globDebug == 1} {
    puts "Conv2bin = $argBitCount $argHexPattern"
  }
  set numHexChars [string length $argHexPattern]
  set iY 0
  set iZ 0
  for {set iX 0} {$iX < $numHexChars} {incr iX} {
    set iHex [string index $argHexPattern [expr ($numHexChars - $iX - 1)]]
    set tmp $arrayHexBinVal($iHex)
    if {$iX == 0} {
      set sBitStr $tmp 
    } else {
      append tmp $sBitStr
      set sBitStr $tmp
    }
  }; # end of FOR iX < numHexChars

  set iLen [string length $sBitStr]
  if {$argBitCount < $iLen} {
# Strip leading 0s from converted hex to binary string
    set iX [expr ($iLen - $argBitCount)]
    for {set iY 0} {$iY < $iX} {incr iY} {
      if {[string index $sBitStr $iY] != 0} {
        puts "Specified bit count $argBitCount cannot represent hex pattern \[$argHexPattern\]"
	break
      }
    }
# strip the leading 0 bits from the generated binary string
    if {$iY >= $iX} {
      set sBitStr [string range $sBitStr $iX [expr ($iLen-1)]]
    }
  } elseif {$argBitCount > $iLen} {
# Pad with leading 0s
    set iX [expr ($argBitCount - $iLen)]
    set tmp [format "%0*d" [expr ($iX+1)] 1]
    set tmp [string range $tmp 0 [expr ($iX-1)]]
    append tmp $sBitStr
    set sBitStr $tmp
  }; # end of if argBitCount < iLen

  return $sBitStr

}; # end of conv2bin
# -----------------------------------------------------------------------------
# Convert bit pattern of length argBitCount to hex format.
# -----------------------------------------------------------------------------
proc conv2hex { argBitCount argBitPattern } {
  global globDebug

  set iFirstHex 1

  if {$globDebug == 1} {
    puts "Conv2hex = $argBitCount $argBitPattern"
  }
  set numbits [string length $argBitPattern]
  if {$argBitCount != $numbits} {
    puts "Error: Bit pattern length != $argBitCount"
    return
  }
  set iY 0
  set iZ 0
  for {set iX 0} {$iX < $numbits} {incr iX} {
    if {[string index $argBitPattern [expr ($numbits - $iX - 1)]] == 1} {
      set iY [expr ($iY + (1 << $iZ))]
    }
    incr iZ
    if {$iZ >= 4} {
      if {$iFirstHex == 1} {
        set sHexPattern [format "%X" $iY]
	set iFirstHex 0
      } else {
        set sHexChar [format "%X" $iY]
        append sHexChar $sHexPattern
	set sHexPattern $sHexChar
      }
      set iY 0
      set iZ 0
    }
  }; # end of FOR iX < numbits

# The following code handles case where bit count is not a multiple of 4
  if {$iZ > 0} {
    if {$iFirstHex == 1} {
      set sHexPattern [format "%X" $iY]
    } else {
      append iY $sHexPattern
      set sHexPattern $iY
    }
  }
  return $sHexPattern

}; # end of conv2hex
# -----------------------------------------------------------------------------
proc SetupLog {} {

  global file_log
  global prog_ctrl
  global fileOutput
  global optOverwrite

  if {[file exists $file_log]} {
    puts -nonewline "File \[$file_log\] exists;"
    if {$optOverwrite == 0} {
      puts " file exists, to overwrite the option must be set to 1"
      set prog_ctrl 0
      return
    }
   } else {
     puts  -nonewline "File \[$file_log\] does not exist;"
   }
   puts " script will overwrite file"
   set fileOutput [open $file_log w 0600]
   return
  }

# -----------------------------------------------------------------------------
# Readback configuration frames via JTAG 
# -readback_filepath = file path to store the readback data 
# -frame_address = frames address to start reading back 
# -frames = number of frames to readback
# -overwrite = set to 1 in order to allow the readback file to be overwritten
# -----------------------------------------------------------------------------
proc fpga::FrameRead {readback_filepath frame_address frames overwrite} {
   
  set argFormat 1 
  set sOperationStart [clock format [clock seconds]]

  global prog_ctrl
  global fileOutput
  global DEF_JCONFIG
  global DEF_JRDBK
  global DEF_BYPASS
  global arrayHexVal
  global arrayHexBinVal
  global DEF_WPF
  global file_log
  global DEF_FDR_PIPE_DEPTH
  global optOverwrite
  global COMMAND_FPGA_READ_FRAMES

  set optOverwrite $overwrite

  set prog_ctrl 1
  set file_log $readback_filepath
  SetupLog
  if {$prog_ctrl == 0} {
   return
  }

  set sTmpVar [fpga::SetupReadbackFrames $frame_address $frames]
  set iBitCount [expr ([string length $sTmpVar] * 4)]
  set tdi_data [revHexData $sTmpVar]
  set rdbk_cmd_length [expr ([string length $tdi_data] * 4)]
   

	fpga::OpenJtagMode
	scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
	scan_dr_hw_jtag $rdbk_cmd_length -tdi $tdi_data
  
	set iReadbackCount [expr (($DEF_WPF * ($frames + 1) + $DEF_FDR_PIPE_DEPTH) * 32)]
	scan_ir_hw_jtag 6 -tdi $DEF_JRDBK
	set sReadback [scan_dr_hw_jtag $iReadbackCount -tdi 0]

# Reverse readback data to match order in bitstream
  set numchars [string length $sReadback]
  set dumy_frame_len [expr ($DEF_WPF * 8)]
  set numchars [expr ($numchars - $dumy_frame_len)]
  set iY 0

# Put into ascii 32 bit RBT type format 
  if {$argFormat == 0} {
    for {set iX [expr ($numchars - 1)]} {$iX >= 0} {incr iX -1} {
      incr iY
      if { $iY < 64} {
        puts -nonewline $fileOutput \
              $arrayHexVal([string index $sReadback [expr ($iX)]])
      } else {
        puts            $fileOutput \
              $arrayHexVal([string index $sReadback [expr ($iX)]])
        set iY 0
      }
    }
  } else {
    for {set iX [expr ($numchars - 1)]} {$iX >= 0} {incr iX -1} {
      incr iY
      if { $iY < 8} {
        puts -nonewline $fileOutput \
              $arrayHexBinVal($arrayHexVal([string index $sReadback\
	                                   [expr ($iX)]]))
      } else {
        puts            $fileOutput \
              $arrayHexBinVal($arrayHexVal([string index $sReadback\
	                                   [expr ($iX)]]))
        set iY 0
      }
    }
  };


#  DESYNC COMMAND 
#   DesyncCmd

  close $fileOutput
  
  # send report
  set result $COMMAND_FPGA_READ_FRAMES
  server::SendData [append result "%" $readback_filepath] 
}; 

 #-----------------------------------------------------------------------------
 # Returns readback command sequence.
 # This procedure is called from rdbk_conf_frames_jtag 
 # -frame_address = frames address to start reading back 
 # -frames = number of frames to readback
 #-----------------------------------------------------------------------------
proc fpga::SetupReadbackFrames {frame_address frames} {
    global DEF_CMD
    global DEF_WPF
    global DEF_FDR_PIPE_DEPTH
    global DEF_SYNCWORD
    global DEF HDR_W1_CMD
    global DEF_TYPE_1
    global DEF_TYPE_2
    global DEF_WRITE
    global DEF_READ
    global DEF_FAR
    global DEF_NULL_CMD
    global DEF_FDRO
    global DEF_IDCODE  
    global DEF_FDRI  
    global DEF_MSK  
    global DEF_CTL1  
    global DEF_CTL0  
    global DEF_STAT  
    global DEF_BOOTSTS  
    global DEF_COR0  
    global DEF_COR1  
    global DEF_BSPI  
    global DEF_WBSTAR  
    global DEF_CRC  
    global DEF_MFWR  
    global DEF_CBC  
    global DEF_AXSS  
    global DEF_TIMER  
    
    set    tmp FFFFFFFF
    append tmp AA995566
    append tmp 20000000
    append tmp 20000000
    append tmp 20000000
    append tmp 20000000
    append tmp 20000000
    append tmp 20000000
    append tmp 20000000
    append tmp 30008001
    append tmp 00000004
    append tmp 20000000
    append tmp 30002001
    append tmp $frame_address 
    append tmp 28006000

    #-------------------------------
    # Add HDR_RNF2_FDRO
    #-------------------------------
    set    tmp2 $DEF_TYPE_2
    append tmp2 $DEF_READ
    append tmp2 000000000000000000000000000

    set tmp3 0x[conv2hex 32 $tmp2]
    #-------------------------------
    # add framecount -> wcnt = (WPF * frmcnt + 1) + FDR_PIPE_DEPTH
    #-------------------------------
    set valWordCount [format "0x%08X" \
       [expr (($DEF_WPF * ($frames + 1)) + $DEF_FDR_PIPE_DEPTH)]] 

    set tmp4 [format "%08X" [expr ($tmp3 | $valWordCount)]]

    append tmp $tmp4 

    #-------------------------------
    # Add NO_OP command - 20000000
    #-------------------------------
    append tmp 20000000
    append tmp 20000000

    return $tmp
    }; 
	

 #-----------------------------------------------------------------------------
 # Writes a frame to the FPGA
 # -frame_address = The frame address to write 
 # -frame_filepath = The file holding the frame data
 #-----------------------------------------------------------------------------
 proc fpga::FrameWrite {frame_address frame_filepath frames append_dummy_frame use_hex_format reset_fifo} {
	global fileOutput
	global DEF_JCONFIG
	global DEF_JRDBK
	global DEF_BYPASS
	global arrayHexVal
	global arrayHexBinVal
	global DEF_WPF
	global DEF_FDR_PIPE_DEPTH
	global COMMAND_FPGA_WRITE_FRAMES

	set sTmpVar [fpga::WriteFramesSetup $frame_address $frame_filepath $frames $append_dummy_frame $use_hex_format]
	set iBitCount [expr ([string length $sTmpVar] * 4)]
	
	set tdi_data [revHexData $sTmpVar]

    fpga::OpenJtagMode
	scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
	scan_dr_hw_jtag $iBitCount -tdi $tdi_data
	
    # Puts "Clear JTAG IR - Release access to the configuration logic" 
    scan_ir_hw_jtag 6 -tdi $DEF_BYPASS
    scan_ir_hw_jtag 6 -tdi $DEF_BYPASS
	server::SendData $COMMAND_FPGA_WRITE_FRAMES
 };

 #-----------------------------------------------------------
 # Creates the command sequence which will be sent to the
 # configuration controller. This includes the frame data and
 # the dummy frame
 #-----------------------------------------------------------
 proc fpga::WriteFramesSetup {frame_address frame_filepath frames append_dummy_frame use_hex_format} {
	global DEF_WPF
    global DEF_SYNCWORD
	global DEF_TYPE_2
	global DEF_WRITE
	global DEF_FDR_PIPE_DEPTH
	global TARGET_ID

	set tmp FFFFFFFF
	## SYNC
	append tmp $DEF_SYNCWORD
	# NOOP
	append tmp 20000000
	# Reset CRC
#	append tmp 30008001
#	append tmp 00000007
	# NOOP	
	append tmp 20000000	
	# Write IDCODE
    append tmp 30018001
    append tmp $TARGET_ID
	# NOOP
    append tmp 20000000
	# Packet Type 1: Write to the Frame Address Register (FAR)
	append tmp 30002001
	append tmp $frame_address
	# NOOP
    append tmp 20000000
	# COMMAND: Write to the configuration memory
	append tmp 30008001
	append tmp 00000001	
	# NOOP
	append tmp 20000000	
	# Packet Type 1: Write to the Frame Data Register In (FDRI)
	append tmp 30004000
	#append tmp 500000CA
	set    tmp2 $DEF_TYPE_2
	append tmp2 $DEF_WRITE
	append tmp2 000000000000000000000000000
	set tmp3 0x[conv2hex 32 $tmp2]
	set valWordCount [format "0x%08X" [expr (($DEF_WPF * ($frames + 1)) + $DEF_FDR_PIPE_DEPTH)]] 
	set tmp4 [format "%08X" [expr ($tmp3 | $valWordCount)]]
	append tmp $tmp4 
	
	# Frame data section ----------------------------------------
	# Read the frame
	set frame_data [fpga::ReadFrameFromFile $frame_filepath]	
	# Append the dummy frame
	if {$append_dummy_frame == 1} {
		for {set index 0} {$index < $DEF_WPF} {incr index 1} {
			if {$use_hex_format == 1} {
				append frame_data 00000000
			} else {
				append frame_data 00000000000000000000000000000000
			}
		}	
	}
    if {$use_hex_format == 0} {
	    set iLength [string length $frame_data]
		set frame_data [conv2hex $iLength $frame_data]
	}
	append tmp $frame_data
    # Frame data section ----------------------------------------
	
	append tmp 20000000
	append tmp 20000000

  # Write DESYNC command
	append tmp 30008001
	append tmp 0000000D

    return $tmp
};

 #-----------------------------------------------------------
 # Opens and reads the content of a file
 #----------------------------------------------------------- 
proc fpga::ReadFrameFromFile {frame_filepath} {
	set fhandle [open $frame_filepath r]
	set file_data [read $fhandle]
	set data [split $file_data "\n"]
	set tmp ""
	
	foreach line $data {
		append tmp $line
	}
	close $fhandle
	
	return $tmp
};

 #-----------------------------------------------------------
 # Reads a single internal FPGA register
 # register_address :Is the address of the register to be read expresed in 5 bits:
 # e.g. 01100 -> IDCODE register
 #
 #	ReadRegister 01100
 #----------------------------------------------------------- 
proc fpga::ReadRegister {register_address} {
	global DEF_JCONFIG
	global DEF_JRDBK
	global DEF_BYPASS
	global DEF_TYPE_1
	global DEF_READ
	global arrayHexVal
	global COMMAND_FPGA_REGISTER_READ
	
	set register_address_bin ""
    if {[string length $register_address] == 5} {
		set register_address_bin $register_address
	} elseif {[string length $register_address] == 2 || [string length $register_address] == 1} {
		set register_address_bin [conv2bin 5 $register_address]
	} else {
		puts "The given register address is invalid!"
		set result $COMMAND_FPGA_REGISTER_READ
		server::SendData [append result "%0"]
		return
	}		
	
	#Create the command word
	set    tmp2 $DEF_TYPE_1
    append tmp2 $DEF_READ
	append tmp2 000000000
	append tmp2 $register_address_bin
    append tmp2 00
	append tmp2 00000000001
	set read_command [conv2hex 32 $tmp2]
    #puts "read_command(binary) = $tmp2, read_command(hex) = 0x$read_command"
	
	# Create the write/request command sequence
	set    tmp FFFFFFFF
    append tmp AA995566
    append tmp 20000000
	append tmp 20000000
    append tmp $read_command 
	append tmp 20000000
	append tmp 20000000
	
	fpga::OpenJtagMode
	set tdi_data [revHexData $tmp]
	set rdbk_cmd_length [expr ([string length $tdi_data] * 4)]
	#puts "Data length to write (bits) = $rdbk_cmd_length"
	#puts "Data to write = $tdi_data"	
	
	# Read
	scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
	scan_dr_hw_jtag $rdbk_cmd_length -tdi $tdi_data
	scan_ir_hw_jtag 6 -tdi $DEF_JRDBK
	set register_value [scan_dr_hw_jtag 32 -tdi 0]	
	#puts "Register value (read) = $register_value"
	
	# Reverse
	set numchars [string length $register_value]
	set iY 0
	set read_data 0x
    for {set iX [expr ($numchars - 1)]} {$iX >= 0} {incr iX -1} {
      incr iY
        append read_data $arrayHexVal([string index $register_value [expr ($iX)]])
    }
	puts "Register value (reversed) = $read_data"
	
	set result $COMMAND_FPGA_REGISTER_READ
	server::SendData [append result "%" $read_data]
}


# -----------------------------------------------------------
# Writes a single internal FPGA register
# register_address :Is the address of the register to be written expresed in 5 bits:
# 					e.g. 00001 -> FAR register
# register_value   :The value to be written in register @ref register_address in hex (32 bits)
#
# example: WriteRegister 00001 00110BA0
# -----------------------------------------------------------
proc fpga::WriteRegister {register_address register_value} {
	global DEF_JCONFIG
	global DEF_BYPASS
	global DEF_TYPE_1
	global DEF_WRITE
	global arrayHexVal
	global COMMAND_FPGA_REGISTER_WRITE
	
	set register_address_bin ""
    if {[string length $register_address] == 5} {
		set register_address_bin $register_address
	} elseif {[string length $register_address] == 2 || [string length $register_address] == 1} {
		set register_address_bin [conv2bin 5 $register_address]
	} else {
		puts "The given register address is invalid!"
                set result $COMMAND_FPGA_REGISTER_WRITE
		server::SendData [append result "%0"]
		return
	}
	
	#Write command
	set    tmp $DEF_TYPE_1
    append tmp $DEF_WRITE
	append tmp 000000000
	append tmp $register_address_bin
    append tmp 00
	append tmp 00000000001
	set command [conv2hex 32 $tmp]
    puts "command(binary) = $tmp, command(hex) = 0x$command"
	
	# Command sequence to send 
	set    tmp FFFFFFFF
    append tmp AA995566
    append tmp 20000000
	append tmp 20000000
    append tmp $command
	append tmp $register_value	
	append tmp 20000000
	append tmp 20000000
	
	fpga::OpenJtagMode
	set tdi_data [revHexData $tmp]
	set iLength [expr ([string length $tdi_data] * 4)]
	puts "Write data length (bits) = $iLength"
	puts "Write data = $tdi_data"	
	
	scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
	scan_dr_hw_jtag $iLength -tdi $tdi_data
	
	server::SendData $COMMAND_FPGA_REGISTER_WRITE
}

proc fpga::Configure {bit_filepath mask_filepath} {
	global COMMAND_FPGA_CONFIGURE
	fpga::OpenNormalMode
	set_property PROGRAM.FILE $bit_filepath [current_hw_device]
	create_hw_bitstream -hw_device [current_hw_device] -mask $mask_filepath $bit_filepath
	program_hw_devices [current_hw_device]
	server::SendData $COMMAND_FPGA_CONFIGURE
}

proc fpga::Readback {rdb_filepath} {
	global COMMAND_FPGA_READBACK
	fpga::OpenNormalMode	
	readback_hw_device -readback_file $rdb_filepath [current_hw_device]
	set result $COMMAND_FPGA_READBACK
	server::SendData [append result "%" $rdb_filepath] 
}

proc fpga::ReadbackCapture {rdb_filepath} {
	global COMMAND_FPGA_READBACK_CAPTURE
	fpga::OpenJtagMode
	fpga::GcaptureCmd
	fpga::OpenNormalMode	
	readback_hw_device -readback_file $rdb_filepath [current_hw_device]
	server::SendData $COMMAND_FPGA_READBACK_CAPTURE
}

proc fpga::ReadbackVerify {} {
	global COMMAND_FPGA_READBACK_VERIFY
	set verify_status "VERIFY_OK"
	fpga::OpenNormalMode	
	if { [ catch { verify_hw_devices [current_hw_device] } err ] } {
		set verify_status "VERIFY_ERROR"
	}
	set result $COMMAND_FPGA_READBACK_VERIFY
	server::SendData [append result "%" $verify_status] 
}

proc fpga::ReadInternalFifo {} {
    global COMMAND_FPGA_READ_FIFO
	fpga::OpenJtagMode
	scan_ir_hw_jtag 6 -tdi 2
	scan_dr_hw_jtag 4 -tdi 6
	set value [scan_dr_hw_jtag 48 -tdi 0]
	set value [conv2bin 48 $value]
	set result $COMMAND_FPGA_READ_FIFO
	server::SendData [append result "%" $value]
}

proc fpga::ResetInternalFifo {} {
    global COMMAND_FPGA_RESET_FIFO
	fpga::OpenJtagMode
	fpga::SyncCmd
	scan_ir_hw_jtag 6 -tdi 2
	scan_dr_hw_jtag 4 -tdi 9
	scan_dr_hw_jtag 4 -tdi 0
	fpga::DesyncCmd  
	server::SendData $COMMAND_FPGA_RESET_FIFO
}

proc fpga::ReadHeartbeat {} {
    global COMMAND_FPGA_READ_HEARTBEAT
	fpga::OpenJtagMode
	scan_ir_hw_jtag 6 -tdi 3
	set value [scan_dr_hw_jtag 1 -tdi 0]
	set result $COMMAND_FPGA_READ_HEARTBEAT
	server::SendData [append result "%" $value]
} 

proc fpga::OpenJtagMode {} {
	global fpga_mode
	global FPGA_MODE_JTAG
	if {$fpga_mode == $FPGA_MODE_JTAG} {
		return		
	}
	close_hw_target
	open_hw_target -jtag_mode 1
	set fpga_mode $FPGA_MODE_JTAG
}

proc fpga::OpenNormalMode {} {
	global fpga_mode
	global FPGA_MODE_NORMAL
	
	if {$fpga_mode == $FPGA_MODE_NORMAL} {
		return		
	}
	close_hw_target
	open_hw_target
	set fpga_mode $FPGA_MODE_NORMAL
}	

proc fpga::GcaptureCmd {} {
  global DEF_JCONFIG
  global DEF_BYPASS 
  global arrayHexVal

  # Command sequence to send 
  set    tmp FFFFFFFF
  append tmp AA995566
  append tmp 20000000

  # Write GCAPTURE command
  append tmp 30008001
  append tmp 0000000C

  set tdi_data [revHexData $tmp]
  set iLength [expr ([string length $tdi_data] * 4)]

  scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
  scan_dr_hw_jtag $iLength -tdi $tdi_data
}

proc fpga::DesyncCmd {} {
  global DEF_JCONFIG
  global DEF_BYPASS 
  global arrayHexVal
  
  # Command sequence to send 
  set    tmp FFFFFFFF
  append tmp AA995566
  append tmp 20000000

  # Write DESYNC command
  append tmp 30008001
  append tmp 0000000D
  append tmp 20000000
  append tmp 20000000

  set tdi_data [revHexData $tmp]
  set iLength [expr ([string length $tdi_data] * 4)]

  scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
  scan_dr_hw_jtag $iLength -tdi $tdi_data

#  puts "Clear JTAG IR - Release access to the configuration logic" 
  scan_ir_hw_jtag 6 -tdi $DEF_BYPASS
  scan_ir_hw_jtag 6 -tdi $DEF_BYPASS
}

proc fpga::SyncCmd {} {
  global DEF_JCONFIG
  global DEF_BYPASS 
  global arrayHexVal

  # Command sequence to send 
  set    tmp FFFFFFFF
  append tmp AA995566
  append tmp 20000000
  append tmp 20000000
  # Reset CRC
  append tmp 30008001
  append tmp 00000007
  append tmp 20000000
  append tmp 20000000

  set tdi_data [revHexData $tmp]
  set iLength [expr ([string length $tdi_data] * 4)]

  scan_ir_hw_jtag 6 -tdi $DEF_JCONFIG
  scan_dr_hw_jtag $iLength -tdi $tdi_data
}

proc fpga::ReadLogicStatus {} {
    global COMMAND_FPGA_LOGIC_STATUS
	fpga::OpenJtagMode
	scan_ir_hw_jtag 6 -tdi 23
	set value [scan_dr_hw_jtag 4 -tdi 0]
	set result $COMMAND_FPGA_LOGIC_STATUS
	server::SendData [append result "%" $value]
}




# ================================================================================
# --------------------------------------------------------------------------------
# Server functionality
# --------------------------------------------------------------------------------
# ================================================================================

proc log {lvl msg} {
    global Debug
    if {$lvl eq "debug" && $Debug == 0} {return}
    puts stdout "\[$lvl\] $msg"
}

proc server::ConnectionHandler {chan addr port} {
    log debug [info level 0]
    variable Clients
    if {[catch {
        fconfigure $chan -blocking 0 -buffering line -translation binary -eofchar {}
        fileevent $chan readable [list [namespace current]::ClientReader $chan]
    } err]} {
        log error "Error configuring channel $chan from ${addr}:${port}, $err"
        catch {close $chan}
        return
    }
    set Clients($chan) [list $addr $port]
    log info "Client $Clients($chan) | Connected"
}

proc server::ClientReader chan {
	global tcp_client
    log debug [info level 0]
    variable Clients
    if {[catch {read -nonewline $chan} data]} {
        catch {close $chan}
        log error "Client $Clients($chan) | Read Error: $data"
        log debug $::errorInfo
        log info "Client $Clients($chan) | Dropping client"
        array unset Clients $chan
        return
    }
    if {[eof $chan]} {
        catch {close $chan}
        log debug EOF
        log info "Client $Clients($chan) | Disconnected"
        array unset Clients $chan
		set tcp_client 0
        return
    }

    if {$data eq ""} {return}
	set tcp_client $chan
	ParseReceivedData $data
}

proc server::ParseReceivedData {data} {
	global COMMAND_FPGA_CONFIGURE
	global COMMAND_FPGA_READBACK_CAPTURE
	global COMMAND_FPGA_READBACK_VERIFY
	global COMMAND_FPGA_READBACK
	global COMMAND_FPGA_READ_FIFO
	global COMMAND_FPGA_RESET_FIFO
	global COMMAND_FPGA_READ_HEARTBEAT
	global COMMAND_FPGA_WRITE_FRAMES
	global COMMAND_FPGA_READ_FRAMES
	global COMMAND_FPGA_LOGIC_STATUS
	global COMMAND_FPGA_FAULT_INJECTION_READ
	global COMMAND_FPGA_FAULT_INJECTION_WRITE
	global COMMAND_FPGA_REGISTER_READ
	global COMMAND_FPGA_REGISTER_WRITE
	
	set args [split $data "%"]
	
	if {[lindex $args 0] == $COMMAND_FPGA_CONFIGURE} {
		set bitstream_filepath [regsub -all {\\} [lindex $args 1] {/}]
		set mask_filepath [regsub -all {\\} [lindex $args 2] {/}]
		fpga::Configure $bitstream_filepath $mask_filepath
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READBACK_CAPTURE} {
		set readback_filepath [regsub -all {\\} [lindex $args 1] {/}]
		fpga::ReadbackCapture $readback_filepath
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READBACK_VERIFY} {
		fpga::ReadbackVerify
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READBACK} {
		set readback_filepath [regsub -all {\\} [lindex $args 1] {/}]
		fpga::Readback $readback_filepath
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READ_FIFO} {
		fpga::ReadInternalFifo
	} elseif {[lindex $args 0] == $COMMAND_FPGA_RESET_FIFO} {
		fpga::ResetInternalFifo
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READ_HEARTBEAT} {
		fpga::ReadHeartbeat
	} elseif {[lindex $args 0] == $COMMAND_FPGA_WRITE_FRAMES} {
		set command [lindex $args 0]
		set filepath [regsub -all {\\} [lindex $args 1] {/}]
		set frame_address [lindex $args 2]
		set frames [lindex $args 3]
		set append_dummy_frame [lindex $args 4]
		set use_hex_format [lindex $args 5]
		set reset_fifo [lindex $args 6]
		fpga::FrameWrite $frame_address $filepath $frames $append_dummy_frame $use_hex_format $reset_fifo
	} elseif {[lindex $args 0] == $COMMAND_FPGA_READ_FRAMES} {
		set command [lindex $args 0]
		set readback_filepath [regsub -all {\\} [lindex $args 1] {/}]
		set frame_address [lindex $args 2]
		set frames [lindex $args 3]
		fpga::FrameRead $readback_filepath $frame_address $frames 1
	} elseif {[lindex $args 0] == $COMMAND_FPGA_LOGIC_STATUS} {
		fpga::ReadLogicStatus
	} elseif {[lindex $args 0] == $COMMAND_FPGA_REGISTER_READ} {
		set register_address [lindex $args 1]
		fpga::ReadRegister $register_address
	} elseif {[lindex $args 0] == $COMMAND_FPGA_REGISTER_WRITE} {
		set register_address [lindex $args 1]
		set register_value [lindex $args 2]
		fpga::WriteRegister $register_address $register_value
	}		
}

proc server::SendData {data} {	
	global tcp_client
	if {$tcp_client != 0} {
		puts $tcp_client $data
	}
}


# ================================================================================
# --------------------------------------------------------------------------------
# MAIN execution
# --------------------------------------------------------------------------------
# ================================================================================
setHexRevTbl
setHexBinTbl

open_hw
connect_hw_server
current_hw_target [get_hw_targets */xilinx_tcf/Digilent/*]
set_property PARAM.FREQUENCY 30000000 [get_hw_targets */xilinx_tcf/Digilent/*]
open_hw_target
current_hw_device [lindex [get_hw_devices] 0]
set fpgaMode $FPGA_MODE_NORMAL

socket -server server::ConnectionHandler $Port
vwait forever
