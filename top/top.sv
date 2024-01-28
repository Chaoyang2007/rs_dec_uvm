//`timescale 1ns/1ps

module top;
reg clk  = 0;
reg rstn = 0;
reg ena  = 0;

rs_interface top_if(clk, rstn);

rs_decoder u_rs_decoder (
    .clk(top_if.clk),
    .rstn(top_if.rstn),
    .rs_ena(top_if.rs_ena),
    .rx_vld(top_if.rx_vld),
    .rx_data(top_if.rx_data),

    .dec_vld(top_if.dec_vld),
    .dec_data(top_if.dec_data),
    .dec_isos(top_if.dec_isos),
    .rde_error(top_if.RDE_ERROR)
);

initial begin
    run_test();
end

initial begin
    // Set the virtual interface in the UVM configuration database
    uvm_config_db#(virtual rs_interface)::set(null, "uvm_test_top.env.i_agt.drv", "vif", top_if);
    uvm_config_db#(virtual rs_interface)::set(null, "uvm_test_top.env.i_agt.mon", "vif", top_if);
    uvm_config_db#(virtual rs_interface)::set(null, "uvm_test_top.env.o_agt.mon", "vif", top_if);
end

initial begin
    `uvm_info("uvm_top", $sformatf("clk period = %0d", `CLOCK_PERIOD), UVM_LOW);
    forever #(`CLOCK_PERIOD/2)  clk=~clk;
end

initial begin
    forever begin
        // Wait for rstn to be modified
        uvm_config_db#(bit)::wait_modified(null, "uvm_test_top", "rstn");
        if(!uvm_config_db#(bit)::get(null, "uvm_test_top", "rstn", rstn))
            `uvm_fatal("uvm_top", "rstn set error!")
    end
end

// initial begin
// 	$set_toggle_region(top.u_rs_decoder);
//     $display($time, " toggle start");
// 	$toggle_start();
// 	run_test();
// 	$toggle_stop(); 
//     $display($time, " toggle stop");
//     $toggle_report("rs_decoder.saif",1.0e-9,"top"); 
//     $display($time, " toggle report");
//     $finish;
// end

endmodule // top