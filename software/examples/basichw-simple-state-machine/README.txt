
This application is developed as demo to illustrate the basic functionalities of the framework.

In to run it, please provide the bellow settings in the settings.xml file:
   1. VivadoBinDirectoryPath : The full path of the Vivado binary folder
   2. BitstreamFilePath      : The full path of the bitstream file which will be used for device configuration
   3. MaskFilePath           : The full path of the mask file which will be used for device verification
   4. WorkingDirectory       : The folder (full path) of the working directory. Set this as the same folder where the application runs.
   5. FrameDataFilePath      : The file containing the frame data which will be written upon frame-write
   6. FrameDataInHexFormat   : Set this value to True if the frame data in the FrameDataFilePath file is in HEX format. False otherwise.
   7. AppendDummyFrame       : Set this value to True to force the application to send a dummy frame after writing the file FrameDataFilePath