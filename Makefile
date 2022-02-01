
.PHONY: test

RTL = $(shell find rtl -type f)
TB = $(shell find tb -type f)
CORE = top.core
SRC = ${RTL} ${TB} ${CORE}

FST = build/ucsbieee_fpga_movie_top_1.0.0/tb-icarus/dump.fst
IMG = build/ucsbieee_fpga_movie_top_1.0.0/tb-icarus/image.png

run: ${FST}
img: ${IMG}

fusesoc.conf:
	fusesoc library add tests . --sync-type=local

${FST} ${IMG}: fusesoc.conf ${SRC}
	fusesoc run --target tb ucsbieee:fpga_movie:top

view: fusesoc.conf ${FST}
	gtkwave ${FST} > /dev/null 2>&1 &

init: fusesoc.conf

clean:
	rm -rf build fusesoc.conf
