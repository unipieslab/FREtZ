# -*- coding: utf-8 -*-
import os
from PySide2.QtXml import QDomNode
import xml.etree.ElementTree as ET


class XtclSettings:
    readbackPerionMsec  = 0
    heartbeat_fifo_check_period_msec = 0
    bitstreamFilePath   = ''
    selectedApplication = 1
    vivadoDirectory     = ''
    frameDataFilePath   = ''
    readbackFilePathGolden = ''
    workingDirectory    = ''
    mask_filepath       = ''
    frame_address       = ''
    append_dummy_frame  = False
    is_frame_data_in_hex_format = True
    beam_off_time_msec  = 0
    frame_addresses_list_filepath = ''
    enable_fault_injection = True
    manual_beam_off = True
    fault_injection_period_msec = 0
    faults_per_frame = 0
    beam_time_msec = 0
    fifo_depth = 0
    oscilloscope_edge = '';
    number_of_heartbeats = 0
    trigger_level_volts = 1.5

    def __init__(self):
        try:
            xmlTree = ET.parse('settings.xml')
            doc = xmlTree.getroot()
            XtclSettings.readbackPerionMsec = int(doc.find('TimeToReadbackMsec').text)
            XtclSettings.heartbeat_fifo_check_period_msec = int(doc.find('HeartbeatFifoCheckPeriodMsec').text)
            XtclSettings.bitstreamFilePath = os.path.normpath(doc.find('BitstreamFilePath').text)
            XtclSettings.selectedApplication = int(doc.find('SelectedApplication').text)
            XtclSettings.vivadoDirectory = os.path.abspath(doc.find('VivadoBinDirectoryPath').text)
            XtclSettings.frameDataFilePath = os.path.abspath(doc.find('FrameDataFilePath').text)
            XtclSettings.readbackFilePathGolden = os.path.abspath(doc.find('ReadbackFilePathGolden').text)
            XtclSettings.workingDirectory = doc.find('WorkingDirectory').text
            XtclSettings.mask_filepath = os.path.abspath(doc.find('MaskFilePath').text)
            frames_hex = doc.find('FrameDataInHexFormat').text
            frame_address = doc.find('FrameAddress').text
            dummy_frame = doc.find('AppendDummyFrame').text
            XtclSettings.beam_off_time_msec = int(doc.find('BeamOffTimeMsec').text)
            XtclSettings.frame_addresses_list_filepath = os.path.normpath(doc.find('FrameAddressesListFilePath').text)
            fault_injection_enabled = doc.find('EnableFaultInjection').text
            manual_beam_off = doc.find('ManualBeamOff').text
            XtclSettings.fault_injection_period_msec = int(doc.find('FaultInjectionPeriodMsec').text)
            XtclSettings.faults_per_frame = int(doc.find('FaultsPerFrame').text)
            XtclSettings.beam_time_msec = int(doc.find('BeamTimeMsec').text)
            XtclSettings.fifo_depth = int(doc.find('FifoDepth').text)
            oscilloscope_edge = doc.find('OscilloscopeEdge').text
            XtclSettings.number_of_heartbeats = int(doc.find('NumberOfHeartbeats').text)
            XtclSettings.trigger_level_volts = float(doc.find('TriggerLevelVolts').text)

            if frames_hex == 'True' or frames_hex == '1' or frames_hex == 'true':
                XtclSettings.is_frame_data_in_hex_format = True
            else:
                XtclSettings.is_frame_data_in_hex_format = False

            if dummy_frame == 'True' or dummy_frame == '1' or dummy_frame == 'true':
                XtclSettings.append_dummy_frame = True
            else:
                XtclSettings.append_dummy_frame = False

            if fault_injection_enabled == 'True' or fault_injection_enabled == '1' or fault_injection_enabled == 'true':
                XtclSettings.enable_fault_injection = True
            else:
                XtclSettings.enable_fault_injection = False

            #
            if manual_beam_off == 'True' or manual_beam_off == '1' or manual_beam_off == 'true':
                XtclSettings.manual_beam_off = True
            else:
                XtclSettings.manual_beam_off = False
        except Exception as e:
            print(e)
        return

    def TriggerLevelVolts():
        return XtclSettings.trigger_level_volts

    def BeamOffTimeMsec():
        return XtclSettings.beam_off_time_msec

    def BeamTimeMsec():
        return XtclSettings.beam_time_msec

    def FifoDepth():
        return XtclSettings.fifo_depth

    def NumberOfHeartbeats():
        return XtclSettings.number_of_heartbeats

    def IsOscilloscopeRisingEdge():
        return XtclSettings.oscilloscope_edge == "Rising"
