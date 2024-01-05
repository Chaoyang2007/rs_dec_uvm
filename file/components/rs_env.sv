`ifndef RS_ENV__SV
`define RS_ENV__SV

class rs_env extends uvm_env;
    `uvm_component_utils(rs_env)

    rs_input_agent  i_agt;
    rs_output_agent o_agt;
    rs_scoreboard   scb;
    rs_model        mdl;
    uvm_tlm_analysis_fifo #(rs_transaction) iagt_mdl_fifo;
    uvm_tlm_analysis_fifo #(rs_transaction) mdl_scb_fifo;
    uvm_tlm_analysis_fifo #(rs_transaction) oagt_scb_fifo;

    // Constructor
    function new(string name="rs_env", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to create and configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Create and configure input agent
        i_agt = rs_input_agent::type_id::create("i_agt", this);
        i_agt.is_active = UVM_ACTIVE;
        // Create and configure output agent
        o_agt = rs_output_agent::type_id::create("o_agt", this);
        // Create and configure scoreboard
        scb = rs_scoreboard::type_id::create("scb", this);
        // Create and configure model
        mdl = rs_model::type_id::create("mdl", this);
        // Create and configure FIFOs
        iagt_mdl_fifo   = new("iagt_mdl_fifo", this);
        mdl_scb_fifo    = new("mdl_scb_fifo", this);
        oagt_scb_fifo   = new("oagt_scb_fifo", this);
    endfunction // build_phase

    // Connect phase to establish connections between components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        // Connect input agent to model
        i_agt.ap.connect(iagt_mdl_fifo.analysis_export);
        mdl.port.connect(iagt_mdl_fifo.blocking_get_export);
        // Connect model to scoreboard
        mdl.ap.connect(mdl_scb_fifo.analysis_export);
        scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
        // Connect output agent to scoreboard
        o_agt.ap.connect(oagt_scb_fifo.analysis_export);
        scb.act_port.connect(oagt_scb_fifo.blocking_get_export);
    endfunction // connect_phase
endclass // rs_env

`endif // RS_ENV__SV
