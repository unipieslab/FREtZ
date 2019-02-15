
# FREtZ (FPGA Reliability Evaluation through JTAG)

**FREtZ** is an open-source framework that provides access to the FPGA configuration memory and circuit logic via the JTAG protocol. By implementing various configuration memory functions, such as bitstream readback and verify, configuration frame write and read, configuration frame ECC monitoring, the tool can be used to support the design and evaluation of FPGA reliability methodologies.

It mainly consists of: i) an on-chip logic to provide access to the configuration memory, embedded ECC core and DUT logic, ii) a software library of low-level JTAG functions and iii) a set of high-level configuration functions (GUI) to enable the development of target applications.

## Getting Started

The project contains the source files of the framework and the hardware. Regarding the hardware there are three designs ready-to-run that can be loaded on a Zybo or Zedboard development boards: ***basic, frameecc*** and ***hardened***. Two application examples are also provided to illustrate the usage of the software framework: ***basichw-commands*** and ***basichw-simple-state-machine***. The ***basichw-commands*** illustrates the usage of the different APIs of the framework from a simple GUI application while ***basichw-simple-state-machine*** is an application implementing a state machine which can be used as starting point to build a comprehensive application for the reliability evaluation of the FPGA design. 

### Prerequisites
To run the examples either a Zybo or a Zedboard development board is required (see bellow links). Vivado tool should be also installed which will be used by the framework for controlling the JTAG interface.  

[Zybo Zynq-7000 (XC7Z010)](https://store.digilentinc.com/zybo-zynq-7000-arm-fpga-soc-trainer-board/)

[Zybo Z7-10 (XC7Z010)](https://store.digilentinc.com/zybo-z7-zynq-7000-arm-fpga-soc-development-board/)

[ZedBoard Zynq-7000](https://store.digilentinc.com/zedboard-zynq-7000-arm-fpga-soc-development-board/)

The software applications (binaries) can be executed in a Windows machine without any requirement provided that Vivado is install and a TCP server at port 9955. To compile and run the applications though (Windows, Linux), [PySide2](https://pypi.org/project/PySide2/) and [Python](https://www.python.org) should be available in the development machine.

## Running the test applications
Bellow we describe the steps to run one of the provided example applications. In this case the ***basic*** design and the ***basichw-commands*** application are used but the same steps can be followed for the other designs/applications too: 
 1. Load the bitstream in the FPGA device. Use the bitstream for your board:
	 
|Board|Bitstream  |
|--|--|
| Zybo | hardware\bin\basic\zybo |
| Zedboard|hardware\bin\basic\zybo|

 2. Configure the software application:

> 
-- Open the **jtag_configuration_engine.tcl** file and set the target device according to the FPGA device:
	
|Board|TARGET_ID Value  |
|--|--|
| Zybo | set TARGET_ID $DEF_Z7010 |
| Zedboard|set TARGET_ID $DEF_Z7020|
> 
-- Open the **settings.xml** file for setting the required application setting.
	
 3. Execute the software application **basichw-commands-app.exe** (software\bin\win\basichw-commands-app.exe)

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/unipieslab/FREtZ/tags). 

## Authors

* **Aitzan Sari** -  [aitzans](https://github.com/aitzans)
* **Vasileios Vlagkoulis** -  [vvlagkoulis](https://github.com/vvlagkoulis)

See also the list of [contributors](https://github.com/unipieslab/FREtZ/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
