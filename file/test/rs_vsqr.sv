`ifndef RS_VSQR__SV
`define RS_VSQR__SV

class rs_vsqr extends uvm_sequencer;
    `uvm_component_utils(rs_vsqr)

    rs_sequencer sqr;
    
    // Constructor
    function new(string name="rs_vsqr", uvm_component parent);
        super.new(name, parent);
    endfunction  // new

endclass:rs_vsqr

`endif // RS_VSQR__SV