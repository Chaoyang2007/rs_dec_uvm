#!/usr/bin/bash

vcs -full64 -sverilog /usr/uvm/uvm-1.1d/src/dpi/uvm_dpi.cc +v2k -l elab.log \
-debug_acc+all -kdb -lca +lint=TFIPC-L -timescale=1ns/1ps -work work_dut +error+99 \
-f file_list.f +define+$1=$1

/home/scott/project/rs_dec_uvm_/sim/./simv +fsdb+functions -ucli -i dump.tcl -l irun.log +UVM_TESTNAME=rs_error_case_test +UVM_VERBOSITY=UVM_MEDIUM

#cp ./irun.log ./rs_test_$1.log
#cp ./twave.fsdb ./rs_test_$1.fsdb
#mkdir -p ./logfiles/rs_test_$1
#cp ./elab.log ./logfiles/rs_test_$1/
#cp ./irun.log ./logfiles/rs_test_$1/
#cp ./twave.fsdb ./logfiles/rs_test_$1/

mv ./irun.log ./rs_test_$1.log

