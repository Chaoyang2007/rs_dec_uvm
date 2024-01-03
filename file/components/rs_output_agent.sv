`ifndef RS_OUTPUT_AGENT__SV
`define RS_OUTPUT_AGENT__SV

class rs_output_agent extends uvm_agent;
    `uvm_component_utils(rs_output_agent)

    rs_output_monitor   mon;
    uvm_analysis_port#(rs_transaction)  ap;

    // Constructor
    function new(string name="rs_output_agent", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to create and configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = rs_output_monitor::type_id::create("mon", this);
    endfunction // build_phase

    // Connect phase to establish connections between components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        ap = mon.ap;
    endfunction // connect_phase
endclass // rs_output_agent

`endif // RS_OUTPUT_AGENT__SV
