
`ifndef RS_ERROR_CASE_TEST__SV
`define RS_ERROR_CASE_TEST__SV

class rs_error_case_test extends afifo_base_test;
    `uvm_component_utils(rs_error_case_test)

    // Constructor
    function new(string name="rs_error_case_test", uvm_component parent);
        super.new(name, parent);
    endfunction // new
    
    // Build phase to configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Set the default_sequence for the vsqr.main_phase to rs_error_case_vseq
        uvm_config_db#(uvm_object_wrapper)::set(this,
                                                "vsqr.main_phase",
                                                "default_sequence",
                                                rs_error_case_vseq::type_id::get());
    endfunction // build_phase
endclass // rs_error_case_test

`endif // RS_ERROR_CASE_TEST__SV
