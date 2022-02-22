yosys -import
source edalize_yosys_procs.tcl

read_json $name.json
tee -o usage.txt stat
