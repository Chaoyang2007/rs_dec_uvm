`ifndef RS_OUTPUT_MONITOR__SV
`define RS_OUTPUT_MONITOR__SV

class rs_output_monitor extends uvm_component;
    `uvm_component_utils(rs_output_monitor)

    // Declare the virtual interface, analysis port, and transaction
    virtual rs_interface                vif;
    uvm_analysis_port#(rs_transaction)  ap;
    rs_transaction                      tr;

    // Constructor
    function new(string name="rs_output_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to configure the monitor
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get the virtual interface configuration
        if (!uvm_config_db#(virtual rs_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_full_name(), "vif connect error!")

        // Create and configure the analysis port
        ap = new("ap", this);
    endfunction // build_phase

    // Main monitoring task
    task main_phase(uvm_phase phase);
        forever begin
            collect_once(tr);
            ap.write(tr);
        end
    endtask // main_phase

    // Task to collect data from the virtual interface
    task collect_once(ref rs_transaction tr);
        // Wait for the specified condition on the virtual interface
        @(vif.o_mon_cb iff (vif.rstn == 1 && vif.o_mon_cb.rs_ena == 1));

        // Create a new transaction and copy data from the virtual interface
        tr = rs_transaction::type_id::create("tr");
        tr.dec_vld   = vif.o_mon_cb.dec_vld;
        tr.dec_data  = vif.o_mon_cb.dec_data;
        tr.dec_isos  = vif.o_mon_cb.dec_isos;
        tr.RDE_ERROR = vif.o_mon_cb.RDE_ERROR;
    endtask // collect_once
endclass // rs_output_monitor

`endif // RS_OUTPUT_MONITOR__SV
