`ifndef RS_INPUT_AGENT__SV
`define RS_INPUT_AGENT__SV

class rs_input_agent extends uvm_agent;
    `uvm_component_utils(rs_input_agent)

    rs_sequencer        sqr;
    rs_driver           drv;
    rs_input_monitor    mon;
    uvm_analysis_port#(rs_transaction)  ap;

    // Constructor
    function new(string name="rs_input_agent", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to create and configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            sqr = rs_sequencer::type_id::create("sqr", this);
            drv = rs_driver::type_id::create("drv", this);
        end
        mon = rs_input_monitor::type_id::create("mon", this);
    endfunction // build_phase

    // Connect phase to establish connections between components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(sqr.seq_item_export);
        end
        ap = mon.ap;
    endfunction // connect_phase
endclass // rs_input_agent

`endif // RS_INPUT_AGENT__SV
