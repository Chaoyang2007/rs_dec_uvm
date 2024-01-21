`ifndef RS_SEQUENCER__SV
`define RS_SEQUENCER__SV

class rs_sequencer extends uvm_sequencer #(rs_transaction);
    `uvm_component_utils(rs_sequencer)

    // Constructor
    function new(string name = "rs_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

endclass // rs_sequencer

`endif // RS_SEQUENCER__SV
