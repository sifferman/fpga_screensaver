
.PHONY: test

RTL = $(shell find rtl -type f)
CORE = top.core
SRC = ${RTL} ${CORE}

TB = $(shell find tb -type f)
FST = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/dump.fst
IMG = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/image.png

USAGE = $(shell find usage -type f)
USAGE_REPORT = build/ucsbieee__fpga_movie_1.0.0/usage-yosys/usage.txt

TANGNANO = $(shell find tangnano -type f)
FS = build/ucsbieee__fpga_movie_1.0.0/tangnano-apicula/ucsbieee__fpga_movie_1.0.0.fs


run: ${FST}
img: ${IMG}
init: fusesoc.conf
usage: ${USAGE_REPORT}
tangnano: ${FS}

view: fusesoc.conf ${FST}
	gtkwave ${FST} > /dev/null 2>&1 &

lint: fusesoc.conf ${SRC}
	fusesoc run --target lint ucsbieee::fpga_movie

${FS}: fusesoc.conf ${SRC} ${TANGNANO}
	fusesoc run --target tangnano ucsbieee::fpga_movie

load_tangnano: ${FS}
	sudo openFPGALoader -m -b tangnano $<

fusesoc.conf:
	fusesoc library add tests . --sync-type=local

clean:
	rm -rf build fusesoc.conf

${FST} ${IMG}: fusesoc.conf ${SRC} ${TB}
	fusesoc run --target tb ucsbieee::fpga_movie

${USAGE_REPORT}: fusesoc.conf ${SRC} ${USAGE}
	fusesoc run --target usage ucsbieee::fpga_movie
