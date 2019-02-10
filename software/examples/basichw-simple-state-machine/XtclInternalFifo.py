# -*- coding: utf-8 -*-

import XtclLog
import XtclCommon

class XtclInternalFifo:
    FIFO_FULL_INDEX = 44
    FIFO_ALMOST_FULL_INDEX = 43
    FIFO_EMPTY_INDEX = 42
    FRAME_ADDRESS_START_INDEX = 16
    FRAME_ADDRESS_END_INDEX = 42
    ECC_SYNDROME_START_INDEX = 3
    ECC_SYNDROME_END_INDEX = 16
    CRC_ERROR_INDEX = 2
    ECC_ERROR_INDEX = 1
    ECC_VALID_INDEX = 0

    def __init__(self):
        self._ecc_syndrome_valid = 0;
        self._ecc_error = 0;
        self._crc_error = 0;
        self._ecc_syndrome = 0;
        self._frame_address = 0;
        self._frame_address_hex = ''
        self._fifo_empty = 0;
        self._fifo_almost_full = 0;
        self._fifo_full = 0;
        return

    def __init__(self, fifo_register):
        self.parseFifoRegister(fifo_register)
        return

    def parseFifoRegister(self, fifo_register):       
        fifo_register_ = self.reverse(fifo_register.strip())
        self._ecc_syndrome_valid = int(fifo_register_[XtclInternalFifo.ECC_VALID_INDEX])
        self._ecc_error = int(fifo_register_[XtclInternalFifo.ECC_ERROR_INDEX])
        self._crc_error = int(fifo_register_[XtclInternalFifo.CRC_ERROR_INDEX])
        self._ecc_syndrome = int(self.reverse(fifo_register_[XtclInternalFifo.ECC_SYNDROME_START_INDEX:XtclInternalFifo.ECC_SYNDROME_END_INDEX]), 2)
        self._frame_address = int(self.reverse(fifo_register_[XtclInternalFifo.FRAME_ADDRESS_START_INDEX:XtclInternalFifo.FRAME_ADDRESS_END_INDEX]), 2)
        #if self._frame_address > 1:
        #    self._frame_address -= 2
        self._fifo_empty = int(fifo_register_[XtclInternalFifo.FIFO_EMPTY_INDEX])
        self._fifo_almost_full = int(fifo_register_[XtclInternalFifo.FIFO_ALMOST_FULL_INDEX])
        self._fifo_full = int(fifo_register_[XtclInternalFifo.FIFO_FULL_INDEX])
        self._frame_address_hex = '{0:0{1}X}'.format(self._frame_address, 8)
        return

    def printToLog(self):
        XtclLog.writeLine("ECC syndrome valid: " + str(self._ecc_syndrome_valid), XtclCommon.blue)
        XtclLog.writeLine("ECC error: " + str(self._ecc_error), XtclCommon.blue)
        XtclLog.writeLine("CRC error: " + str(self._crc_error), XtclCommon.blue)
        XtclLog.writeLine("ECC syndrome: " + str(self._ecc_syndrome), XtclCommon.blue)
        XtclLog.writeLine("Frame address (HEX): " + self._frame_address_hex, XtclCommon.blue)
        XtclLog.writeLine("FIFO empty: " + str(self._fifo_empty), XtclCommon.blue)
        XtclLog.writeLine("FIFO almost full: " + str(self._fifo_almost_full), XtclCommon.blue)
        XtclLog.writeLine("FIFO full: " + str(self._fifo_full), XtclCommon.blue)
        return

    @property
    def isEccSyndromeValid(self):
        return bool(self._ecc_syndrome_valid)

    @property
    def isEccError(self):
        return bool(self._ecc_error)

    @property
    def isCrcError(self):
        return bool(self._crc_error)

    @property
    def isFifoEmpty(self):
        return bool(self._fifo_empty)

    @property
    def isFifoAlmostFull(self):
        return bool(self._fifo_almost_full)

    @property
    def isFifoFull(self):
        return bool(self._fifo_full)

    @property
    def getFrameAddress(self):
        return self._frame_address

    @property
    def getEccSyndrome(self):
        return self._ecc_syndrome

    @property
    def getFrameAddressHex(self):
        return self._frame_address_hex

    def reverse(self, s):
        str = ""
        for i in s:
            str = i + str
        return str
