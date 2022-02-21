
# Movie on an FPGA

<https://github.com/E4tHam/fpga_movie>

This project implements the VGA protocol and allows custom images to be displayed to the screen.

This is a good introductory project to RTL, video interfaces, and FPGAs.

## To Run

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

* [FuseSoC](https://fusesoc.readthedocs.io/)
* [Icarus Verilog](http://iverilog.icarus.com/)
* [GTKWave](http://gtkwave.sourceforge.net/)
* [Verilator](https://www.veripool.org/verilator/)
* [Yosys](https://yosyshq.net/yosys/)
* [Apicula](https://github.com/YosysHQ/apicula)
* [nextpnr-gowin](https://github.com/YosysHQ/nextpnr#nextpnr-gowin)
