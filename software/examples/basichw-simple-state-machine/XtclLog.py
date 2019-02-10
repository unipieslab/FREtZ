# -*- coding: utf-8 -*-

import sys
import argparse
import time
import datetime
import subprocess
import os
import re
from os import getcwd
sys.path.insert(0, getcwd())

from PySide2 import QtCore, QtGui, QtWidgets
from widget import Widget
from XtclSettings import XtclSettings

logFileName = "xtclLog-" + str(datetime.datetime.now().timestamp()) + ".txt"
currentDir = os.path.dirname(os.path.realpath(__file__))
logFile = os.path.normpath(XtclSettings.workingDirectory) + '/log-files/' + logFileName

def write(text, color = None, print_timestamp = True):
    if not text:
        return
    fHandle = open(logFile, "a")
    if print_timestamp:
        text_to_write = str(datetime.datetime.now().timestamp()) + ":" + text
    else:
        text_to_write = text
    Widget.writeText(text_to_write, color)
    fHandle.write(text_to_write)
    fHandle.close()
    return

def writeLine(text, color = None, print_timestamp = True):
    write(text + "\n", color, print_timestamp)
    return

def setReadStatus(value):
    Widget.setVerificationStatus(value)
    return

def readBeamState():
    return Widget.getBeamState()
