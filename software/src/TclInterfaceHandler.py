# -*- coding: utf-8 -*-

import sys
import argparse
import time
import datetime
import subprocess
import os
import codecs
import filecmp
import XtclLog
import XtclCommon
from PySide2.QtCore import QIODevice, SIGNAL, QProcess, QTextCodec, QTextStream, QDataStream, QByteArray
from PySide2.QtCore import QObject, Signal, Slot
from PySide2 import QtGui, QtNetwork
from enum import Enum
from XtclSettings import XtclSettings
from XtclCommon import Operation

class SocketStatus(Enum):
    DISCONNECTED = 0
    CONNECTED    = 1

class TclInterfaceHandler(QObject):
    # The TCP server IP address
    HOST = "127.0.0.1"
    # TCP server port
    PORT = 9955

    commandExecutionFinished = Signal(str)
    faultInjectionFinished = Signal(str)

    #---------------------------------------------------------------------------------
    # @brief Class constructor.
    #---------------------------------------------------------------------------------
    def __init__(self):
        super(TclInterfaceHandler, self).__init__()
        self.operation = Operation.NONE
        self.frame_address = "00000000"
        self.frames = "1"
        self.tcpClientSocket = QtNetwork.QTcpSocket()
        self.tcpClientSocketStatus = SocketStatus.DISCONNECTED
        self.startVivado()
        return

    #---------------------------------------------------------------------------------
    # @brief This function should be called when the application terminates.
    #---------------------------------------------------------------------------------
    def exit(self):
        self.vivadoProcess.kill()
        vivado_command_to_kill = "cmd.exe /C Taskkill /IM vivado.exe /F"
        process = QProcess()
        process.start(vivado_command_to_kill)
        process.waitForFinished(5000)

        tcp_command_to_kill = "cmd.exe /C netstat -ano | find '0.0.0.0:9955'"

        return


    #**********************************************************************************
    # TCP Client
    #**********************************************************************************
    #---------------------------------------------------------------------------------
    # @brief This function starts the TCP client.
    #---------------------------------------------------------------------------------
    def clientStart(self):
        if self.tcpClientSocketStatus == SocketStatus.CONNECTED:
            self.tcpClientSocket.abort()
        self.tcpClientSocket.connectToHost(TclInterfaceHandler.HOST, TclInterfaceHandler.PORT)
        self.tcpClientSocket.waitForConnected(3000)
        self.tcpClientSocket.readyRead.connect(self.clientReadReady)
        self.tcpClientSocket.error.connect(self.clientError)

        self.tcpClientSocketStatus = SocketStatus.CONNECTED
        return

    #---------------------------------------------------------------------------------
    # @brief This function is called by the TCP client when it has data ready to be read.
    #---------------------------------------------------------------------------------
    def clientReadReady(self):
        message = QTextStream(self.tcpClientSocket).readAll()

        if Operation.READBACK_CAPTURE.name in message:
            XtclLog.writeLine("================ FPGA readback capture finished ================ ", XtclCommon.blue)
        elif Operation.READBACK_VERIFY.name in message:
            XtclLog.writeLine("================ FPGA readback verify finished ================ ", XtclCommon.blue)
            #verify = filecmp.cmp(XtclSettings.readbackFilePathGolden, self.readbackFile, False)
        elif Operation.READBACK.name in message:
            XtclLog.writeLine("================ FPGA readback finished ================ ", XtclCommon.blue)
        elif Operation.CONFIGURATION.name in message:
            XtclLog.writeLine("================ FPGA configuration finished ================ ", XtclCommon.blue)
        elif Operation.FRAMES_READ.name in message or Operation.FAULT_INJECTION_READ.name in message:
            XtclLog.writeLine("================ FPGA frame readback finished ================ ", XtclCommon.blue)
        elif Operation.FRAMES_WRITE.name in message or Operation.FAULT_INJECTION_WRITE.name in message:
            XtclLog.writeLine("================ FPGA frame write finished ================ ", XtclCommon.blue)
        elif Operation.READ_FIFO.name in message:
            XtclLog.writeLine("================ Reading internal FIFO finished ================ ", XtclCommon.blue)
        elif Operation.RESET_FIFO.name in message:
            XtclLog.writeLine("================ Reseting internal FIFO finished ================ ", XtclCommon.blue)
        elif Operation.READ_HEARTBEAT.name in message:
            XtclLog.writeLine("================ Reading heartbeat finished ================ ", XtclCommon.blue)
        elif Operation.LOGIC_STATUS.name in message:
            XtclLog.writeLine("================ Reading active logic status finished ================ ", XtclCommon.blue)
        elif Operation.REGISTER_READ.name in message:
            XtclLog.writeLine("================ Reading configuration register finished ================ ", XtclCommon.blue)
        elif Operation.REGISTER_WRITE.name in message:
            XtclLog.writeLine("================ Writing configuration register finished ================ ", XtclCommon.blue)
        else:
            XtclLog.writeLine(message, XtclCommon.red)

        self.operation = Operation.NONE

        if "FAULT_INJECTION" in message:
            self.faultInjectionFinished.emit(message)
        else:
            self.commandExecutionFinished.emit(message)
        return

    #---------------------------------------------------------------------------------
    # @brief Callback function for the client error.
    #---------------------------------------------------------------------------------
    def clientError(self, socketError):
        if socketError == QtNetwork.QAbstractSocket.RemoteHostClosedError:
            pass
        elif socketError == QtNetwork.QAbstractSocket.HostNotFoundError:
            XtclLog.writeLine("The host was not found. Please check the host name and port settings", XtclCommon.red)
        elif socketError == QtNetwork.QAbstractSocket.ConnectionRefusedError:
            XtclLog.writeLine("The connection was refused by the peer. Make sure the "
            "server is running, and check that the host name "
            "and port settings are correct.", TclInterfaceHandler.red)
        else:
            XtclLog.writeLine("The following error occurred: %s." % self.tcpSocket.errorString(), XtclCommon.red)
        return

    #---------------------------------------------------------------------------------
    # @brief Send data to the TCP server
    #---------------------------------------------------------------------------------
    def clientSend(self, data):
        bytesArray = bytes(data, 'utf-8')
        message = QByteArray.fromRawData(bytesArray)
        self.tcpClientSocket.write(message)
        self.tcpClientSocket.flush()
        return

    #**********************************************************************************
    # Vivado interface
    #**********************************************************************************
    #---------------------------------------------------------------------------------
    # @brief This function starts the Vivado instanse. Please replace the command
    #        with the appropriate command for the running platform
    #---------------------------------------------------------------------------------
    def startVivado(self):
        self.operation = Operation.NONE
        TclInterfaceHandler.isOperationFinished = False
        XtclLog.writeLine("================ Starting Vivado process ================ ", XtclCommon.blue)
        XtclLog.write("PLEASE WAIT UNTIL YOU SEE \"# vwait forever\" MESSAGE!", XtclCommon.red)
        command = XtclSettings.vivadoDirectory + "/vivado.bat -nojournal -nolog -mode batch -source jtag_configuration_engine.tcl"
        # Create runner
        self.vivadoProcess = QProcess()
        self.vivadoProcess.readyReadStandardError.connect(self.errorInfo)
        self.vivadoProcess.readyReadStandardOutput.connect(self.readAllStandardOutput)
        self.vivadoProcess.finished.connect(self.finished)
        self.vivadoProcess.start(command)
        return

    #---------------------------------------------------------------------------------
    # @brief Callback function for the error of the Vivado process
    #---------------------------------------------------------------------------------
    def errorInfo(self): 
        info = self.vivadoProcess.readAllStandardError()
        info_text = QTextStream(info).readAll()
        XtclLog.write(info_text)
        return

    #---------------------------------------------------------------------------------
    # @brief Callback function to rediarect the output of the Vivado process
    #---------------------------------------------------------------------------------
    def readAllStandardOutput(self):
        info = self.vivadoProcess.readAllStandardOutput()
        info_text = QTextStream(info).readAll()        
        XtclLog.write(info_text)
        return

    #---------------------------------------------------------------------------------
    # @brief Callback function for the termination event of the Vivado process
    #---------------------------------------------------------------------------------
    def finished(self, exitCode, exitStatus):
        return

    #**********************************************************************************
    # Interface commands
    #**********************************************************************************
    #---------------------------------------------------------------------------------
    # @brief This function configures the FPGA
    # @param bitstream_filepath: The full path of the bitstream file
    # @param mask_filepath: The full path of the mask file
    #---------------------------------------------------------------------------------
    def configure(self, bitstream_filepath, mask_filepath):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Starting FPGA configuration ================ ", XtclCommon.blue)
        self.clientSend(Operation.CONFIGURATION.name + "%" + bitstream_filepath + "%" + mask_filepath)
        self.operation = Operation.CONFIGURATION
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads-back the FPGA
    # @param filename: If provided should be the full path of the file where the readback
    #                  data will be saved. Othervise the readback data is saved in a
    #                  timestamp-based file name inside the "readback-files" of the
    #                  working folder.
    #---------------------------------------------------------------------------------
    def readback(self, filename = None):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        if filename == None:
            readbackFileName = "readback-" + str(datetime.datetime.now().timestamp()) + ".rbd"
        else:
            readbackFileName = filename
        self.readbackFile = XtclSettings.workingDirectory + '/readback-files/' + readbackFileName
        XtclLog.writeLine("================ Starting FPGA readback ================ ", XtclCommon.blue)
        XtclLog.writeLine(readbackFileName,  XtclCommon.blue)
        self.clientSend(Operation.READBACK.name + "%" + self.readbackFile)
        self.operation = Operation.READBACK
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads-back the FPGA using the capture mode
    # @note The readback data is saved in a timestamp-based file name inside the "readback-capture-files"
    #       of the working folder.
    #---------------------------------------------------------------------------------
    def readbackCapture(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        readbackFileName = "readbackCapture-" + str(datetime.datetime.now().timestamp()) + ".rbd"
        self.readbackFile = XtclSettings.workingDirectory + '/readback-capture-files/' + readbackFileName
        XtclLog.writeLine("================ Starting FPGA readback capture ================ ", XtclCommon.blue)
        XtclLog.writeLine(readbackFileName,  XtclCommon.blue)
        self.clientSend(Operation.READBACK_CAPTURE.name + "%" + self.readbackFile)
        self.operation = Operation.READBACK_CAPTURE
        return

    #---------------------------------------------------------------------------------
    # @brief This function verifies the FPGA.
    # @note The FPGA device should be configured before issuing this command.
    #---------------------------------------------------------------------------------
    def readbackVerify(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Starting FPGA readback verify ================ ", XtclCommon.blue)
        self.clientSend(Operation.READBACK_VERIFY.name)
        self.operation = Operation.READBACK_VERIFY
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads the internal FIFO of the interface logic.
    #---------------------------------------------------------------------------------
    def readInternalFifo(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Reading internal FIFO ================ ", XtclCommon.blue)
        self.clientSend(Operation.READ_FIFO.name)
        self.operation = Operation.READ_FIFO
        return

    #---------------------------------------------------------------------------------
    # @brief This function resets the internal FIFO of the interface logic.
    #---------------------------------------------------------------------------------
    def resetInternalFifo(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Reseting internal FIFO ================ ", XtclCommon.blue)
        self.clientSend(Operation.RESET_FIFO.name)
        self.operation = Operation.RESET_FIFO
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads the heartbeat signal the interface logic.
    #---------------------------------------------------------------------------------
    def readHeartbeat(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Reading heartbeat ================ ", XtclCommon.blue)
        self.clientSend(Operation.READ_HEARTBEAT.name)
        self.operation = Operation.READ_HEARTBEAT
        return

    #---------------------------------------------------------------------------------
    # @brief This function writes frames in configuration memory of the FPGA
    # @param frame_address: The frame address in HEX format (i.e. 00001002).
    # @param frame_file: The full path of the file which holds the frame data to be written.
    # @param append_dummy_frame: True to append a dummy frame after writing the frame data.
    #                            Set it to false if the file contains also the dummy frame.
    # @param is_frame_data_in_hex_format: Trus if the content of the @ref frame_file is in HEX foramt.
    # @param frames: The number of frames to be written. This should be the same as the frames
    #                inside the @ref frame_file (do not include the dummy frame).
    # @param reset_fifo: True to reset the FIFO at the end of writing.
    # @param is_fault_injection: Trus if this write is for fault injection experiment.
    #---------------------------------------------------------------------------------
    def writeFrames(self, frame_address, frame_file, append_dummy_frame = True, is_frame_data_in_hex_format = True, frames = 1, reset_fifo = False, is_fault_injection = False):
        self.frame_address = str(frame_address)
        self.frames = str(frames)
        XtclLog.writeLine("================ Starting FPGA frame write ================ ", XtclCommon.blue)
        append_dummy_frame_ = str(int(append_dummy_frame))
        is_frame_data_in_hex_format_ = str(int(is_frame_data_in_hex_format))
        reset_fifo_ = str(int(reset_fifo))

        if is_fault_injection == True:
            command = Operation.FAULT_INJECTION_WRITE.name + "%" + frame_file + "%" + self.frame_address + "%" + self.frames + "%" + append_dummy_frame_ + "%" + is_frame_data_in_hex_format_ + "%" + reset_fifo_
        else:
            command = Operation.FRAMES_WRITE.name + "%" + frame_file + "%" + self.frame_address + "%" + self.frames + "%" + append_dummy_frame_ + "%" + is_frame_data_in_hex_format_ + "%" + reset_fifo_
        self.clientSend(command)
        self.operation = Operation.FRAMES_WRITE
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads frames from the configuration memory of the FPGA
    # @param frame_address: The frame address in HEX format (i.e. 00001002).
    # @param frames: The number of frames to be written. This should be the same as the frames
    #                inside the @ref frame_file (do not include the dummy frame).
    # @param readback_file: If provided should be the full path of the file where the readback
    #                  data will be saved. Othervise the readback data is saved in a
    #                  timestamp-based file name inside the "readback-frame-files" of the
    #                  working folder.
    # @param is_fault_injection: Trus if this write is for fault injection experiment.
    #---------------------------------------------------------------------------------
    def readFrames(self, frame_address, frames = 1, readback_file = None, is_fault_injection = False):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        self.frame_address = str(frame_address)
        self.frames = str(frames)
        XtclLog.writeLine("================ Starting FPGA frame read ================ ", XtclCommon.blue)
        if readback_file == None:
            readbackFileName = "readbackBlock-0x" + str(self.frame_address) + "-" + str(datetime.datetime.now().timestamp()) + ".rbd"
            self.readbackFile = XtclSettings.workingDirectory + '/readback-frame-files/' + readbackFileName
        else:
            self.readbackFile = XtclSettings.workingDirectory + '/readback-frame-files/' + readback_file

        if is_fault_injection == True:
            command = Operation.FAULT_INJECTION_READ.name + "%" + self.readbackFile + "%" + self.frame_address + "%" + self.frames
        else:
            command = Operation.FRAMES_READ.name + "%" + self.readbackFile + "%" + self.frame_address + "%" + self.frames
        self.clientSend(command)
        self.operation = Operation.FRAMES_READ
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads the status signal of the user logic
    #---------------------------------------------------------------------------------
    def readLogicStatus(self):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Reading active logic status ================ ", XtclCommon.blue)
        self.clientSend(Operation.LOGIC_STATUS.name)
        self.operation = Operation.LOGIC_STATUS
        return

    #---------------------------------------------------------------------------------
    # @brief This function reads a configuration register
    # @param register_address: The frame of the register in 5-bit format (i.e. 01010) of in HEX format (0A).
    #---------------------------------------------------------------------------------
    def readRegister(self, register_address):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Reading configuration register ================ ", XtclCommon.blue)
        self.register_address = str(register_address)
        command = Operation.REGISTER_READ.name + "%" + self.register_address
        self.clientSend(command)
        self.operation = Operation.REGISTER_READ
        return

    #---------------------------------------------------------------------------------
    # @brief This function writes a configuration register
    # @param register_address: The frame of the register in 5-bit format (i.e. 01010) of in HEX format (0A).
    # @param register_value: The register value to be written in 32-bit HEX format (i.e. A000029B)
    #---------------------------------------------------------------------------------
    def writeRegister(self, register_address, register_value):
        if self.tcpClientSocketStatus != SocketStatus.CONNECTED:
            self.clientStart()
        XtclLog.writeLine("================ Writing configuration register ================ ", XtclCommon.blue)
        self.register_address = str(register_address)
        self.register_value = str(register_value)
        command = Operation.REGISTER_WRITE.name + "%" + self.register_address + "%" + self.register_value
        self.clientSend(command)
        self.operation = Operation.REGISTER_WRITE
        return
