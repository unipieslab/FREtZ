#!/usr/bin/env python
# -*- coding: utf-8 -*-
from PySide2 import QtGui
from enum import Enum

class Operation(Enum):
    CONFIGURATION = 1
    READBACK = 2
    READBACK_CAPTURE  = 3
    READBACK_VERIFY = 4
    READBACK_FRAME = 5
    FRAMES_WRITE = 6
    FRAMES_READ = 7
    READ_FIFO = 8
    RESET_FIFO = 9
    READ_HEARTBEAT = 10
    LOGIC_STATUS = 11
    FAULT_INJECTION_READ = 12
    FAULT_INJECTION_WRITE = 13
    REGISTER_READ = 14
    REGISTER_WRITE = 15
    NONE = 16

#
class BeamState(Enum):
        BEAM_ON  = 0
        BEAM_OFF = 1
        NONE = 2

#
#
#
red = QtGui.QColor("red")
black = QtGui.QColor("black")
blue = QtGui.QColor("blue")

#
# FPGA configuration memory parameter
#
NUMBER_OF_FRAME_WORDS = 101
NUMBER_OF_BITS_PER_WORD = 32
