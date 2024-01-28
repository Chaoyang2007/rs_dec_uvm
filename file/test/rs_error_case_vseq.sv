`ifndef RS_ERROR_CASE_VSEQ__SV
`define RS_ERROR_CASE_VSEQ__SV

class rs_error_case_vseq extends rs_base_vseq;
    `uvm_object_utils(rs_error_case_vseq)

    // Constructor
    function new(string name="rs_error_case_vseq");
        super.new(name);
    endfunction // new

    virtual task body();
        rs_4blocks_tb_seq tb_seq;
        rs_4blocks_rd_seq rd_seq;
        rs_transaction tr;

        // Raise objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.raise_objection(this);

        `ifdef SAIF
        $display("collecte toggle info, generate saif");
        $set_toggle_region(top.u_rs_decoder);
        $display($time, " toggle start");
        $toggle_start();
        `endif // SAIF

        $display($time, " sequence \"rs_error_case_vseq\" start!");

        #(10 * `CLOCK_PERIOD)
        // Set 'rstn' to 1 after a delay of 10 clock periods
        uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 1);

        #(10 * `CLOCK_PERIOD)
        // Execute 'seq' (rs_4blocks_seq) sequence from rs_base_vseq 20 times
        //repeat(120) `uvm_do_on(tr, p_sequencer.sqr);
        repeat(2) `uvm_do_on(tb_seq, p_sequencer.sqr);
        repeat(`SEQ_LENGTH) `uvm_do_on(rd_seq, p_sequencer.sqr);

        // #(10 * `CLOCK_PERIOD)
        // Set 'rstn' to 0 after a delay of 10 clock periods
        // uvm_config_db#(bit)::set(null, "uvm_test_top", "rstn", 0);

        #(32 * `CLOCK_PERIOD)
        $display($time, " sequence \"rs_error_case_vseq\" end!");

        `ifdef SAIF
        $toggle_stop(); 
        $display($time, " toggle stop");
        $toggle_report("rs_decoder.saif",1.0e-9,"top"); 
        $display($time, " toggle report");
        `endif // SAIF

        // Drop objection if a starting phase is specified
        if (starting_phase != null)
            starting_phase.drop_objection(this);
    endtask // body
endclass // rs_error_case_vseq

`endif // RS_ERROR_CASE_VSEQ__SV
