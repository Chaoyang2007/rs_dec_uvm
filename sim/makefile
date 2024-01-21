
VCS = vcs	-full64 -sverilog $$UVM_HOME/src/dpi/uvm_dpi.cc +v2k \
		-l elab.log \
		-debug_acc+all \
		-kdb -lca \
		+lint=TFIPC-L \
      		-timescale=1ns/1ps \
		-work work_dut \
		+error+99 \
		-f file_list.f 

SIM = ./simv	+fsdb+functions \
		-ucli -i dump.tcl \
		-l irun.log  \
		+UVM_TESTNAME=rs_error_case_test \
		+UVM_VERBOSITY=UVM_MEDIUM


other = +UVM_PHASE_TRACE +UVM_CONFIG_DB_TRACE +UVM_OBJECTION_TRACE 

VERDI = verdi	-full64 -dbdir ./simv.daidir -ssf twave.fsdb -sswr signal.rc

com: 
	$(VCS)
sim: 
	$(SIM)
verdi: 
	$(VERDI)
clean:	
	rm -rf csrc simv* *.lib *.lib++ nLint* novas*
	rm -rf *.key
	rm -rf verdiLog	
