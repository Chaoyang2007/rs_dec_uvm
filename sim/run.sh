#!/usr/bin/bash
#a1=$1
a2=$2
#var1=${a1:-"DCME2"}
var2=${a2:-"30"}
#echo $var1,$var2,$var3

vcs -full64 -sverilog /usr/uvm/uvm-1.1d/src/dpi/uvm_dpi.cc +v2k -l elab.log \
-debug_acc+all -kdb -lca +lint=TFIPC-L -work work_dut +error+99 \
-f file_list.f -timescale=1ns/1ps \
+define+SEQ_LENGTH=$var2 \
+define+$1=$1

./simv +fsdb+functions -ucli -i dump.tcl -l irun.log \
+UVM_VERBOSITY=UVM_MEDIUM \
+UVM_TESTNAME=rs_error_case_test


cp ./irun.log ./rs_test_$1.log
cp ./elab.log ./rs_test_$1.elog
cp ./twave.fsdb ./rs_test_$1.fsdb
cp ./rs_decoder.saif ./rs_test_$1.saif
