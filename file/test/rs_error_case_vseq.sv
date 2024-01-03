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

        // Raise objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.raise_objection(this);
        
        // Display start time of the "rs_error_case_vseq" sequence
        $display($time, " sequence \"rs_error_case_vseq\" start");

        // Set 'rstn' to 1 after a delay of 10 clock periods
        #10 * `CLOCK_PERIOD
        uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 1);

        // Execute 'seq' (rs_4blocks_seq) sequence from rs_base_vseq 20 times
        #10 * `CLOCK_PERIOD
        repeat(20) `uvm_do(seq)

        // Set 'rstn' to 0 after a delay of 10 clock periods
        #10 * `CLOCK_PERIOD
        uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 0);

        // Display end time of the "rs_error_case_vseq" sequence
        $display($time, " sequence \"rs_error_case_vseq\" end");

        // Drop objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask : body
endclass : rs_error_case_vseq

`endif // RS_ERROR_CASE_VSEQ__SV
