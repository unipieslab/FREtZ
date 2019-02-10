# -*- coding: utf-8 -*-

import sys
import time
import datetime
import XtclLog
import XtclCommon
from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtUiTools import QUiLoader
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import QFile
from PySide2.QtCore import QTimer
from PySide2.QtCore import QObject, Signal, Slot
from enum import Enum

from TclInterfaceHandler import TclInterfaceHandler
from XtclSettings import XtclSettings
from XtclCommon import Operation, BeamState
from XtclInternalFifo import XtclInternalFifo
from XtclFaultInjection import XtclFaultInjection


class Widget(QtWidgets.QWidget, TclInterfaceHandler, QObject):
    app = QApplication(sys.argv)
    file = QFile("mainwindow.ui")
    file.open(QFile.ReadOnly)
    loader = QUiLoader()
    window = loader.load(file)

    #---------------------------------------------------------------------------------------
    #@brief Class constructor.
    #---------------------------------------------------------------------------------------
    def __init__(self, jtag_configuration_engine, parent=None):
        self.jtag_configuration_engine = jtag_configuration_engine
        self.message_received = ""
        self.jtag_configuration_engine.commandExecutionFinished.connect(self.interfaceCommandExecutionFinished)

        Widget.window.connect(Widget.window.btnRead, QtCore.SIGNAL("clicked()"), self.btnReadClicked)
        Widget.window.connect(Widget.window.btnWrite, QtCore.SIGNAL("clicked()"), self.btnWriteClicked)
        Widget.window.connect(Widget.window.btnReadRegister, QtCore.SIGNAL("clicked()"), self.btnRegisterReadClicked)
        Widget.window.connect(Widget.window.btnWriteRegister, QtCore.SIGNAL("clicked()"), self.btnRegisterWriteClicked)
        Widget.window.connect(Widget.window.btnConfigure, QtCore.SIGNAL("clicked()"), self.btnConfigureClicked)
        Widget.window.connect(Widget.window.btnVerify, QtCore.SIGNAL("clicked()"), self.btnVerifyClicked)
        Widget.window.connect(Widget.window.btnReadback, QtCore.SIGNAL("clicked()"), self.btnReadbackClicked)
        Widget.window.connect(Widget.window.btnReadbackCapture, QtCore.SIGNAL("clicked()"), self.btnReadbaclCaptureClicked)

        Widget.app.aboutToQuit.connect(self.appExitHandler)

        Widget.window.show()
        Widget.window.txtFrameAddress.setText(XtclSettings.frame_address)
        sys.exit(Widget.app.exec_())
        return

    #**********************************************************************************
    # Class slots
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    # @brief Callback function from the XtclInterface upon message received event from the vivado
    # process
    #---------------------------------------------------------------------------------------
    @Slot(str)
    def interfaceCommandExecutionFinished(self, message):
        response = message.split("%")
        command = response[0]
        if Operation.REGISTER_READ.name in command:
            value = response[1]
            Widget.window.txtRegisterValue.setText(value)
        return

    @Slot(str)
    def beamListenerStateChanged(self, message):
        return

    #**********************************************************************************
    # GUI control event handlers
    #**********************************************************************************

    #
    # Read configuration register
    #
    def btnRegisterReadClicked(self):
        register_address = Widget.window.txtRegisterAddress.text()
        try:
            if register_address.startswith("0x"):
                register_address = register_address.replace("0x", "")
            int(register_address, 16)
        except Exception as e:
            msgBox = QtWidgets.QMessageBox()
            msgBox.setText('Invalid register address!')
            msgBox.exec_()
            return
        self.jtag_configuration_engine.readRegister(register_address)
        return

    #
    # Write configuration register
    #
    def btnRegisterWriteClicked(self):
        register_address = Widget.window.txtRegisterAddress.text()
        register_value = Widget.window.txtRegisterValue.text()
        try:
            if register_address.startswith("0x"):
                register_address = register_address.replace("0x", "")
            if register_value.startswith("0x"):
                register_value = register_value.replace("0x", "")
            int(register_address, 16)
            int(register_value, 16)
        except Exception as e:
            msgBox = QtWidgets.QMessageBox()
            msgBox.setText('Invalid register address or register value!')
            msgBox.exec_()
            return
        self.jtag_configuration_engine.writeRegister(register_address, register_value)
        return

    #
    # Write configuration frames
    #
    def btnWriteClicked(self):
        frame_address = Widget.window.txtFrameAddress.text()
        try:
            if frame_address.startswith("0x"):
                frame_address = frame_address.replace("0x", "")
            int(frame_address, 16)
        except Exception as e:
            msgBox = QtWidgets.QMessageBox()
            msgBox.setText('Invalid frame address!')
            msgBox.exec_()
            return

        frames = Widget.window.nudFrames.value()
        self.jtag_configuration_engine.writeFrames(frame_address, XtclSettings.frameDataFilePath, XtclSettings.append_dummy_frame, XtclSettings.is_frame_data_in_hex_format, frames)
        return

    #
    #   Read configuration frames
    #
    def btnReadClicked(self):
        frame_address = Widget.window.txtFrameAddress.text()
        try:
            if frame_address.startswith("0x"):
                frame_address = frame_address.replace("0x", "")
            int(frame_address, 16)
        except Exception as e:
            msgBox = QtWidgets.QMessageBox()
            msgBox.setText('Invalid frame address!')
            msgBox.exec_()

        frames = Widget.window.nudFrames.value()
        self.jtag_configuration_engine.readFrames(frame_address, frames)
        return

    #
    # FPGA configure
    #
    def btnConfigureClicked(self):
        self.jtag_configuration_engine.configure(XtclSettings.bitstreamFilePath, XtclSettings.mask_filepath)
        return

    #
    # FPGA verify
    #
    def btnVerifyClicked(self):
        self.jtag_configuration_engine.readbackVerify()
        return

    #
    # FPGA readback
    #
    def btnReadbackClicked(self):
        self.jtag_configuration_engine.readback()
        return

    #
    # FPGA readback capture
    #
    def btnReadbaclCaptureClicked(self):
        self.jtag_configuration_engine.readbackCapture()
        return

    #---------------------------------------------------------------------------------------
    #@brief This function executes when the application is going to be closed.
    #---------------------------------------------------------------------------------------
    def appExitHandler(self):
        self.jtag_configuration_engine.exit()
        return

    #**********************************************************************************
    # Class static methods
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    #@brief Writes a text to the console
    #@param text The text to be written
    #@param color The color of the text
    #---------------------------------------------------------------------------------------
    @staticmethod
    def writeText(text, color = QtGui.QColor("black")):
        if color == None:
            color = QtGui.QColor("black")
        Widget.window.txtConsole.setTextColor(color)
        Widget.window.txtConsole.append(text)
        return

    @staticmethod
    def setVerificationStatus(status):
        return

    @staticmethod
    def getBeamState():
        return None
