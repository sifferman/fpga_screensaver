
# Movie on an FPGA

[github.com/E4tHam/fpga_movie](https://github.com/E4tHam/fpga_movie)

This project implements the VGA protocol and allows custom images to be displayed to the screen using the [Sipeed Tang Nano](https://tangnano.sipeed.com/en) FPGA dev board.

This is a good introductory project to RTL (*[Register-Transfer Level code](https://vhdlwhiz.com/terminology/register-transfer-level)*), analog video interfaces, and fundamental FPGA (*[Field-Programmable Gate Array](https://www.digikey.com/en/blog/fpgas-101-a-beginners-guide)*) concepts in the [Verilog](http://en.wikipedia.org/wiki/Verilog) and [SystemVerilog](http://en.wikipedia.org/wiki/SystemVerilog) HDLs (*[Hardware Description Languages](http://en.wikipedia.org/wiki/Hardware_description_language)*).

## Workspace Setup

At the time of writing, some of the required tools must be compiled from source (*e.g. `nextpnr-gowin`, `openFPGALoader`*) and `openFPGALoader` specifically requires a native Linux OS for COM/serial port acesss.

The process is fairly straightforward, but the compilation takes a long time (*at least on the Raspberry Pi for which the installation procedure was validated*). The instructions are maintained on [this Notion document](https://gamy-hamburger-7fe.notion.site/FuseSoC-Gowin-Toolchain-Installation-30af2f32f31745eeb0b53ba20aac22d2).

## To Run

There are several different [Makefile](https://www.gnu.org/software/make) targets specified, each of which represents an element of the project build procedure:

```bash
make run            # generaes the dump and VGA image file
make view           # opens the dump file in gtkwave
make lint           # ensure code meets Verilator standards
make usage          # report generic cell utilization
make tangnano       # generate tangnano bitstream
make load_tangnano  # load bistream to tangnano
```

The VGA output is formatted in a png here: `build/ucsbieee__fpga_movie_1.0.0/tb-icarus/image.png`.

## Requirements

* [FuseSoC](https://fusesoc.readthedocs.io): RTL design build system, similar in concept to CMake, Bazel, etc. but specific to HDL code
* [Icarus Verilog](http://iverilog.icarus.com): Verilog design simulator
* [GTKWave](http://gtkwave.sourceforge.net): Waveform viewer (view the timing-diagram of the simulation)
* [Verilator](https://www.veripool.org/verilator): (System)Verilog design simulator
* [Yosys](https://yosyshq.net/yosys): RTL design synthesis tool, similar in concept to the "compilation" stage during C++ compilation
* [`nextpnr-gowin`](https://github.com/YosysHQ/nextpnr#nextpnr-gowin): Gowin-specific FPGA "place-and-route" tool, similar in concept to the "assembly" stage during C++ compilation
* [Apicula](https://github.com/YosysHQ/apicula): Gowin-specific FPGA design formatter, similar in concept to the "linker" stage during C++ compilation
* [`openFPGALoader`](https://github.com/trabucayre/openFPGALoader): FPGA programming tool

## Directory Structure

This project is organized so as to cleanly separate/delineate groups of files responsible for each part of the design:

* `.vscode`: VSCode workspace configuration files
* `build`: FuseSoC build directory (*doesn't exist until project is built for the first time*)
* `rtl`: SystemVerilog code to define the VGA display driver
* `tangnano`: (System)Verilog code to define elements of the project which are uniquely specific to the Sipeed Tang Nano dev board
* `tb`: SystemVerilog code to define the testbench, used for verifying the design behavior in simulation before programming the physical FPGA
* `usage`: Files related to generating a cell utilization report in Yosys.
* `.gitignore`: Git SCM configuration to help keep the repository clean of files built by FuseSoC
* `fusesoc.conf`: FuseSoC project definition/configuration
* `lint.vlt`: Verilator configuration specifying rules in verifying the syntax of the RTL code
* `Makefile`: GNU Make configuration specifying common project tasks/targets
* `top.core`: FuseSoC "core" configuration specifiing how to build each of the (System)Verilog files in the design
