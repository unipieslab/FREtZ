#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import XtclLog

from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtUiTools import QUiLoader
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import QFile

from widget import Widget
from TclInterfaceHandler import TclInterfaceHandler
from XtclSettings import XtclSettings

settings = XtclSettings()
tcl_interface_handler = TclInterfaceHandler()
widget = Widget(tcl_interface_handler)

XtclLog.writeLine("====================================================================================")
XtclLog.writeLine("Starting the application")


