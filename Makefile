
.PHONY: test

RTL = $(shell find rtl -type f)
CORE = top.core
TB = $(shell find tb -type f)
USAGE = $(shell find usage -type f)
SRC = ${RTL} ${CORE}

FST = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/dump.fst
IMG = build/ucsbieee__fpga_movie_1.0.0/tb-icarus/image.png
USAGE_REPORT = build/ucsbieee__fpga_movie_1.0.0/usage-yosys/usage.txt

run: ${FST}
img: ${IMG}
init: fusesoc.conf
usage: ${USAGE_REPORT}

view: fusesoc.conf ${FST}
	gtkwave ${FST} > /dev/null 2>&1 &

lint: fusesoc.conf ${SRC}
	fusesoc run --target lint ucsbieee::fpga_movie

fusesoc.conf:
	fusesoc library add tests . --sync-type=local

clean:
	rm -rf build fusesoc.conf

${FST} ${IMG}: fusesoc.conf ${SRC} ${TB}
	fusesoc run --target tb ucsbieee::fpga_movie

${USAGE_REPORT}: fusesoc.conf ${SRC} ${USAGE}
	fusesoc run --target usage ucsbieee::fpga_movie
