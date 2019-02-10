# -*- coding: utf-8 -*-

import sys
import time
import datetime
import random
import XtclLog
import XtclCommon
from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtUiTools import QUiLoader
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import QFile
from PySide2.QtCore import QTimer
from PySide2.QtCore import QObject, Signal, Slot, QThread
from enum import Enum

from TclInterfaceHandler import TclInterfaceHandler
from XtclSettings import XtclSettings
from XtclCommon import Operation, BeamState
from XtclInternalFifo import XtclInternalFifo

class FaultInjectionState(Enum):
    READ_FRAME     = 1
    WRITE_FRAME    = 2
    IDLE = 3

class XtclFaultInjection(QObject):
    # Timer to periodically fire the fault injection mechanism
    timer = None
    # TCL interface
    xtcl_interface = None
    # States to be used fault injection synchronization
    state_current = FaultInjectionState.IDLE
    state_next = FaultInjectionState.IDLE
    # The number of the available FPGA configuration frames
    frames_total = 0
    # The selected frame address where the fault(s) will be injected
    frame_address = 0
    # The selected word of the frame
    word = 0
    # The selected bit which will be flipped
    bit = 0
    # Array to hold the FPGA configuration memory addresses
    frames = [None]
    # The file name to be used for the readback frame
    filename_read = "frame_faultinjection-read.txt"
    # The file name to be used for the modified frame
    filename_write = "frame_faultinjection-write.txt"
    # Holds the full path of the frame readback file
    readback_file = ''
    # Number of faults to be injected
    faults_to_inject = 0


    #
    # @brief Class constructor
    #
    def __init__(self, xtcl_interface):
        super(XtclFaultInjection, self).__init__()
        XtclFaultInjection.xtcl_interface = xtcl_interface
        XtclFaultInjection.frames_total = 0
        XtclFaultInjection.frame_address = 0
        XtclFaultInjection.word = 0
        XtclFaultInjection.bit = 0
        XtclFaultInjection.frames = [None]
        XtclFaultInjection.readback_file = XtclSettings.workingDirectory + '/readback-frame-files/' + XtclFaultInjection.filename_read
        XtclFaultInjection.fault_file = XtclSettings.workingDirectory + '/write-frame-files/' + XtclFaultInjection.filename_write
        XtclFaultInjection.state_current = FaultInjectionState.IDLE
        XtclFaultInjection.state_next = FaultInjectionState.IDLE

        XtclFaultInjection.xtcl_interface.faultInjectionFinished.connect(self.interfaceCommandExecutionFinished)
        self.readFrames()


        #self.timer.start()
        #self.timer.connect(self.timerTimeout)
        return

    #**********************************************************************************
    # Class slots
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    # @brief Callback function from the TclInterfaceHandler upon message received event from the vivado
    # process
    #---------------------------------------------------------------------------------------
    @Slot(str)
    def interfaceCommandExecutionFinished(self, message):
        if XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_ON:
            XtclFaultInjection.state_current = XtclFaultInjection.state_next
            if XtclFaultInjection.state_current == FaultInjectionState.WRITE_FRAME:
                if XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_ON:
                    XtclFaultInjection.injectFault()
                    if XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_ON:
                        XtclFaultInjection.xtcl_interface.writeFrames(XtclFaultInjection.frame_address, XtclFaultInjection.fault_file, True, False, 1, True, True)
                XtclFaultInjection.state_next = FaultInjectionState.READ_FRAME
                XtclFaultInjection.state_current = FaultInjectionState.READ_FRAME
            elif XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_OFF:
                XtclFaultInjection.state_current = FaultInjectionState.READ_FRAME
        return

    #
    # @brief This slot is executed to read a selected configuration frame from the FPGA device.
    #
    @Slot()
    def timerTimeout():
        if XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_ON and not XtclFaultInjection.xtcl_interface.isBusy():
            if XtclFaultInjection.state_current == FaultInjectionState.READ_FRAME:
                XtclFaultInjection.generateRandomFault()
                if XtclLog.readBeamState() == XtclCommon.BeamState.BEAM_ON:
                    XtclFaultInjection.xtcl_interface.readFrames(XtclFaultInjection.frame_address, 1, XtclFaultInjection.filename_read, True)
                    XtclFaultInjection.state_next = FaultInjectionState.WRITE_FRAME
                    XtclFaultInjection.state_current = FaultInjectionState.IDLE
        return


    #
    # @brief This function starts a timer which upon expiration executes the @see timerTimeout slot
    #
    def start(self):
        XtclFaultInjection.timer = QTimer()
        XtclFaultInjection.timer.setInterval(XtclSettings.fault_injection_period_msec)
        XtclFaultInjection.timer.timeout.connect(XtclFaultInjection.timerTimeout)
        XtclFaultInjection.timer.start()
        XtclFaultInjection.state_current = FaultInjectionState.READ_FRAME
        #self.exec_()
        #XtclFaultInjection.timer.stop()
        return

    def exit(self):
        XtclFaultInjection.timer.stop()
        return

    #
    # @brief Reads FPGA's frame addresses from the selected file (address per line) to an array
    #
    def readFrames(self):
        try:
            file = open(XtclSettings.frame_addresses_list_filepath, 'r')
            XtclFaultInjection.frames = file.readlines()
            file.close()
            XtclFaultInjection.frames_total = len(XtclFaultInjection.frames)
        except Exception as e:
            print(e)
        return

    #
    # @brief Selects randomly a frame address from @ref frames and the number of faults that will be injected in that frame
    #
    def generateRandomFault():
        frame_index = random.randint(0, XtclFaultInjection.frames_total)
        XtclFaultInjection.frame_address = XtclFaultInjection.frames[frame_index].strip()
        #XtclFaultInjection.word = random.randint(0, XtclCommon.NUMBER_OF_FRAME_WORDS - 1)
        #XtclFaultInjection.bit = random.randint(0, XtclCommon.NUMBER_OF_BITS_PER_WORD - 1)
        XtclFaultInjection.faults_to_inject = random.randint(1, XtclSettings.faults_per_frame)
        return

    #
    # @brief Injects the faults to the selected frame
    #
    def injectFault():
        XtclLog.writeLine("Fault injection: Frame=" + str(XtclFaultInjection.frame_address), XtclCommon.red)
        file = open(XtclFaultInjection.readback_file, 'r')
        words = file.readlines()
        file.close()

        for x in range(XtclFaultInjection.faults_to_inject):
            XtclFaultInjection.word = random.randint(0, XtclCommon.NUMBER_OF_FRAME_WORDS - 1)
            XtclFaultInjection.bit = random.randint(0, XtclCommon.NUMBER_OF_BITS_PER_WORD - 1)
            XtclLog.writeLine("Word=" + str(XtclFaultInjection.word) + ", Bit=" + str(XtclFaultInjection.bit), XtclCommon.red)
            word = list(words[XtclFaultInjection.word])
            XtclLog.writeLine("Read value:" + str(words[XtclFaultInjection.word]).strip(), XtclCommon.red)
            if word[XtclFaultInjection.bit] == '0':
                word[XtclFaultInjection.bit] = '1'
            else:
                word[XtclFaultInjection.bit] = '0'
            words[XtclFaultInjection.word] = "".join(word)
            XtclLog.writeLine("Modified value:" + str(words[XtclFaultInjection.word]).strip(), XtclCommon.red)

        file = open(XtclFaultInjection.fault_file, 'w')
        file.writelines(words)
        file.close()
        return
