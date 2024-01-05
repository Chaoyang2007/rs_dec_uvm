`ifndef RS_ERROR_CASE_VSEQ__SV
`define RS_ERROR_CASE_VSEQ__SV

class rs_error_case_vseq extends rs_base_vseq;
    `uvm_object_utils(rs_error_case_vseq)

    // Constructor
    function new(string name="rs_error_case_vseq");
        super.new(name);
    endfunction // new

    virtual task body();
        rs_4blocks_seq seq;
        rs_transaction tr;

        // Raise objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.raise_objection(this);
        
        $display($time, " sequence \"rs_error_case_vseq\" start");

        #(10 * `CLOCK_PERIOD)
        // Set 'rstn' to 1 after a delay of 10 clock periods
        uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 1);

        #(10 * `CLOCK_PERIOD)
        // Execute 'seq' (rs_4blocks_seq) sequence from rs_base_vseq 20 times
        //repeat(120) `uvm_do_on(tr, p_sequencer.sqr);
        repeat(20) `uvm_do_on(seq, p_sequencer.sqr);
        // repeat(20) `uvm_do_with(seq, has_error=='b1);
        // repeat(20) `uvm_do_on_with(seq, p_sequencer.sqr, {has_error==1;})

        // #(10 * `CLOCK_PERIOD)
        // Set 'rstn' to 0 after a delay of 10 clock periods
        // uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 0);

        #(10 * `CLOCK_PERIOD)
        $display($time, " sequence \"rs_error_case_vseq\" end");

        // Drop objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask // body
endclass // rs_error_case_vseq

`endif // RS_ERROR_CASE_VSEQ__SV
