`ifndef RS_BASE_VSEQ__SV
`define RS_BASE_VSEQ__SV

class rs_base_vseq extends uvm_sequence #(rs_transaction);
    `uvm_object_utils(rs_base_vseq)
    `uvm_declare_p_sequencer(rs_vsqr) // (rs_sequencer)

    // Constructor
    function new(string name="rs_base_vseq");
        super.new(name);
    endfunction // new
    
endclass:rs_base_vseq
`endif // RS_BASE_VSEQ__SV