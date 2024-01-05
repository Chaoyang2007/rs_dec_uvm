`ifndef RS_INPUT_MONITOR__SV
`define RS_INPUT_MONITOR__SV

class rs_input_monitor extends uvm_component;
    `uvm_component_utils(rs_input_monitor)

    // Declare the virtual interface, analysis port, and transaction
    virtual rs_interface                vif;
    uvm_analysis_port#(rs_transaction)  ap;

    // Constructor
    function new(string name="rs_input_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to configure the monitor
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Get the virtual interface configuration
        if (!uvm_config_db#(virtual rs_interface)::get(this, "", "vif", vif))
            `uvm_fatal("rs_input_monitor", "vif connect error!")
        // Create and configure the analysis port
        ap = new("ap", this);
    endfunction // build_phase

    // Main monitoring task
    task main_phase(uvm_phase phase);
        rs_transaction  tr;
        forever begin
            collect_once(tr);
            tr.print_rx("input monitor");
            ap.write(tr);
        end
    endtask // main_phase

    // Task to collect data from the virtual interface
    task collect_once(ref rs_transaction tr);
        // Wait for the specified condition on the virtual interface
        @(vif.i_mon_cb iff (vif.rstn == 1 && vif.i_mon_cb.rs_ena == 1));

        // Create a new transaction and copy data from the virtual interface
        tr = rs_transaction::type_id::create("tr");
        tr.rx_vld  = vif.i_mon_cb.rx_vld;
        tr.rx_data = vif.i_mon_cb.rx_data;
    endtask // collect_once
endclass // rs_input_monitor

`endif // RS_INPUT_MONITOR__SV
