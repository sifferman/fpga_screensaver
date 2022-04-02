# List all Makefile targets which don't yield any file output
.PHONY: run img init usage tangnano view lint load_tangnano clean

# Assemble lists of all relevant source files
RTL = $(shell find rtl -type f)
CORE = top.core
SRC = ${RTL} ${CORE}

# Assemble lists of all relevant testbench files and the location of output files
# created by the testbench
TB = $(shell find tb -type f)
FST = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/dump.fst
IMG = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/image.png

# Assemble a list of all hardware utilization report files and the location of
# the output report file
USAGE = $(shell find usage -type f)
USAGE_REPORT = build/ucsbieee__fpga_movie_1.0.0/usage-yosys/usage.txt

# Assemble a list of all Tang Nano board files and the location of the synthesized
# bitstream for upload
TANGNANO = $(shell find tangnano -type f)
FS = build/ucsbieee__fpga_movie_1.0.0/tangnano-apicula/ucsbieee__fpga_movie_1.0.0.fs


# Define primary Makefile targets (as specified in README.md)
run: ${FST}
img: ${IMG}
init: fusesoc.conf
usage: ${USAGE_REPORT}
tangnano: ${FS}

# Open the timing diagram visualization
view: fusesoc.conf ${FST}
	gtkwave ${FST} > /dev/null 2>&1 &

# Perform the linting procedure
lint: fusesoc.conf ${SRC}
	fusesoc run --target lint ucsbieee::fpga_movie

# Synthesize the FPGA design into a bistream for upload to the Tang Nano
${FS}: fusesoc.conf ${SRC} ${TANGNANO}
	fusesoc run --target tangnano ucsbieee::fpga_movie

# Load the Tang Nano with the synthesized bistream
load_tangnano: ${FS}
	sudo openFPGALoader -m -b tangnano $<

# Configure the project folder as a FuseSoC core library
fusesoc.conf:
	fusesoc library add tests . --sync-type=local

# Remove all of the Makefile-created build files and start fresh
clean:
	rm -rf build fusesoc.conf

# Simulate the RTL
${FST}: fusesoc.conf ${SRC} ${TB}
	fusesoc run --target tb ucsbieee::fpga_movie

# Create a PNG representing the VGA's output
${IMG}: fusesoc.conf ${SRC} ${TB} ${FST}
	@pip3 install -r tb/requirements.txt > /dev/null
	python3 tb/to_png.py $(IMG:.png=.txt) ${IMG}

# Statically-analyze (without uploading/running it) the design's FPGA logic
# cell utilization
${USAGE_REPORT}: fusesoc.conf ${SRC} ${USAGE}
	fusesoc run --target usage ucsbieee::fpga_movie
