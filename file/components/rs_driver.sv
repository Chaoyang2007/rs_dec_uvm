`ifndef RS_DRIVER__SV
`define RS_DRIVER__SV

class rs_driver extends uvm_driver #(rs_transaction);
    `uvm_component_utils(rs_driver)

    virtual rs_interface vif;
    rs_transaction       req;

    // Constructor
    function new(string name="rs_driver", uvm_component parent);
        super.new(name, parent);
    endfunction // new()

    // Build phase to configure components
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual rs_interface)::get(this, "", "vif", vif))
            `uvm_fatal(get_full_name(), "vif connect error!")
    endfunction // build_phase

    // Reset phase to handle reset conditions
    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        phase.raise_objection(this);
        wait(vif.rstn == 'b0);
            `uvm_info(get_full_name(), "reset phase start", UVM_MEDIUM);
            vif.rs_ena <= `b0;
            vif.rx_vld <= 'b0;
        wait(vif.rstn == 'b1);
            `uvm_info(get_full_name(), "write reset phase end", UVM_MEDIUM);
            @(vif.i_drv_cb);
            vif.rs_ena <= `b0;
            vif.rx_vld <= 'b0;
        phase.drop_objection(this);
    endtask // reset_phase

    // Main phase to drive transactions
    task main_phase(uvm_phase phase);
        fork
            forever begin
                seq_item_port.get_next_item(req);
                drive_once(req);
                seq_item_port.item_done();
            end

            forever begin
                @(negedge vif.rstn);
                phase.jump(uvm_reset_phase::get());
            end
        join
    endtask // main_phase

    // Drive a single transaction
    task drive_once(rs_transaction tr);
        @(vif.i_drv_cb iff (vif.rstn == 1));
        vif.i_drv_cb.rs_ena  <= vif.rstn;
        vif.i_drv_cb.rx_vld  <= tr.rx_vld;
        vif.i_drv_cb.rx_data <= tr.rx_data;
    endtask // drive_once
endclass // rs_driver

`endif // RS_DRIVER__SV