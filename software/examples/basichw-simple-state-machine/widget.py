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

class App1State(Enum):
    CONFIGURATION     = 1
    WAIT_FOR_BEAM_ON  = 2
    WAIT_FOR_BEAM_OFF = 3
    READBACK          = 4
    READBACK_CAPTURE  = 5
    RECONFIGURE       = 6
    READBACK_VERIFY   = 7
    READBACK_VERIFY_CHECK  = 8
    READBACK_VERIFY_STATUS = 9
    IDLE = 10

class AppRunning(Enum):
        NONE     = 0
        APP1     = 1


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
        self.isRunningTest = False
        self.operation = Operation.NONE

        self.app1_state_next = App1State.IDLE
        self.app_running = AppRunning.NONE

        self.message_received = ""

        # Timers ---------------------
        # APP trigger timer - used to trigger the state machine upon request
        self.app_trigger_timer = QTimer()
        self.app_trigger_timer.setInterval(1000)
        self.app_trigger_timer.timeout.connect(self.appTriggerTimeout)
        # Beam timer - used to simulate the BEAM-ON/OFF events: Starts when beam = ON and expires when beam = OFF
        self.timer_beam = QTimer()
        self.timer_beam.setInterval(XtclSettings.BeamTimeMsec())
        self.timer_beam.timeout.connect(self.timerBeamTimeout)

        self.jtag_configuration_engine.commandExecutionFinished.connect(self.interfaceCommandExecutionFinished)


        Widget.window.connect(Widget.window.btnStart, QtCore.SIGNAL("clicked()"), self.btnStartClicked)
        Widget.window.connect(Widget.window.btnStop, QtCore.SIGNAL("clicked()"), self.btnStopClicked)
        Widget.app.aboutToQuit.connect(self.appExitHandler)

        imgGreen = QtGui.QImage("green.jpg");
        imgGreenOff = QtGui.QImage("greenoff.jpg");
        imgRed = QtGui.QImage("red.jpg");
        Widget.pixmapGreen = QtGui.QPixmap.fromImage(imgGreen.scaled(32, 32, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        Widget.pixmapRed = QtGui.QPixmap.fromImage(imgRed.scaled(32, 32, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        Widget.pixmapGreenOff = QtGui.QPixmap.fromImage(imgGreenOff.scaled(32, 32, QtCore.Qt.KeepAspectRatio, QtCore.Qt.FastTransformation))
        Widget.window.imgLed.setPixmap(self.pixmapGreenOff);


        Widget.window.show()
        sys.exit(Widget.app.exec_())
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
        if self.isRunningTest == False:
            return

        if self.app_running == AppRunning.APP1:
            if self.app1_state_next != App1State.IDLE:
                self.app1StateMachine(self.app1_state_next, message)
        return

    @Slot(str)
    def beamListenerStateChanged(self, message):
        return

    #**********************************************************************************
    # Event handlers
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    #@brief This function is called when the appTrigger timer expires
    #---------------------------------------------------------------------------------------
    def appTriggerTimeout(self):
        self.app_trigger_timer.stop()
        if self.app_running == AppRunning.APP1:
            self.app1StateMachine(self.app1_state_next)
        return

    #---------------------------------------------------------------------------------------
    #@brief This function is called when the timerBeam timer expires
    #---------------------------------------------------------------------------------------
    def timerBeamTimeout(self):
        self.timer_beam.stop()
        if self.app_running == AppRunning.APP1:
            self.app1StateMachine(App1State.WAIT_FOR_BEAM_OFF)
        return

    #**********************************************************************************
    # GUI control event handlers
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    #@brief This function is called when the START button is clicked.
    #---------------------------------------------------------------------------------------
    def btnStartClicked(self):
        if self.isRunningTest == False:
            self.isRunningTest = True

            self.jtag_configuration_engine.clientStart()
            self.app1_state_next = App1State.IDLE
            self.executeApplication1()
            self.app_running = AppRunning.APP1
            Widget.window.btnStart.setEnabled(False)
            Widget.window.btnStop.setEnabled(True)
        return

    #---------------------------------------------------------------------------------------
    #@brief This function is called when the STOP button is clicked.
    #---------------------------------------------------------------------------------------
    def btnStopClicked(self):
        if self.isRunningTest == False:
            return

        self.isRunningTest = False
        self.app_trigger_timer.stop()
        self.timer_beam.stop()

        self.app1_state_current = App1State.IDLE
        self.app1_state_next = App1State.IDLE
        self.app_running = AppRunning.NONE

        Widget.window.imgLed.setPixmap(Widget.pixmapGreenOff)

        Widget.window.btnStart.setEnabled(True)
        Widget.window.btnStop.setEnabled(False)
        return

    #---------------------------------------------------------------------------------------
    #@brief This function executes when the application is going to be closed.
    #---------------------------------------------------------------------------------------
    def appExitHandler(self):
        self.jtag_configuration_engine.exit()
        return

    #**********************************************************************************
    # Applications
    #**********************************************************************************
    #---------------------------------------------------------------------------------------
    #@brief This function starts the execution of Test 1 application
    #---------------------------------------------------------------------------------------
    def executeApplication1(self):
        self.app1StateMachine(App1State.IDLE)
        return

    #---------------------------------------------------------------------------------------
    #@brief A simple state machine for the test application.
    #---------------------------------------------------------------------------------------
    def app1StateMachine(self, state = None, message = None):
        if state == None:
            return
        # IDLE
        if state == App1State.IDLE:
            self.jtag_configuration_engine.configure(XtclSettings.bitstreamFilePath, XtclSettings.mask_filepath)
            self.app1_state_next = App1State.WAIT_FOR_BEAM_ON

        # WAIT FOR BEAM -ON-
        elif state == App1State.WAIT_FOR_BEAM_ON:
            self.timer_beam.start()
            self.app1_state_next = None

        # WAIT FOR BEAM -OFF-
        elif state == App1State.WAIT_FOR_BEAM_OFF:
            Widget.window.imgLed.setPixmap(Widget.pixmapGreenOff);
            self.jtag_configuration_engine.readback()
            self.app1_state_next = App1State.READBACK_CAPTURE

        # READBACK CAPTURE
        elif state == App1State.READBACK_CAPTURE:
            self.jtag_configuration_engine.readbackCapture()
            self.app1_state_next = App1State.RECONFIGURE

        # RECONFIGURE
        elif state == App1State.RECONFIGURE:
            self.jtag_configuration_engine.configure(XtclSettings.bitstreamFilePath, XtclSettings.mask_filepath)
            self.app1_state_next = App1State.READBACK_VERIFY

        # READBACK VERIFY
        elif state == App1State.READBACK_VERIFY:
            self.jtag_configuration_engine.readbackVerify()
            self.app1_state_next = App1State.READBACK_VERIFY_STATUS

        # CHECK VERIFY STATUS
        elif state == App1State.READBACK_VERIFY_STATUS:
            if "VERIFY_OK" in message:
                Widget.setVerificationStatus(True)
                self.app1_state_next = App1State.WAIT_FOR_BEAM_ON
                self.app_trigger_timer.start()
            else:
                Widget.setVerificationStatus(False)
                self.app1_state_next = App1State.IDLE
                self.app_trigger_timer.start()
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
        if status == True:
            Widget.window.imgLed.setPixmap(Widget.pixmapGreen);
        else:
            Widget.window.imgLed.setPixmap(Widget.pixmapRed);
        return

    @staticmethod
    def getBeamState():
        return None
