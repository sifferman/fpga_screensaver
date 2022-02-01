
# Movie on an FPGA

<https://github.com/E4tHam/fpga_movie>

This project acts as an introduction to FPGAs, RTL, and VGA.

## To Run

```bash
make run    # generaes the dump file
make view   # opens the dump file in gtkwave
make lint   # ensure code meets Verilator standards
```

The VGA output is formatted in a png here: `build/ucsbieee_fpga_movie_top_1.0.0/tb-icarus/image.png`.

## Requirements

* [FuseSoC](https://fusesoc.readthedocs.io/)
* [Icarus Verilog](http://iverilog.icarus.com/)
* [GTKWave](http://gtkwave.sourceforge.net/)
* [Verilator](https://www.veripool.org/verilator/)
