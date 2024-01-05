`ifndef RS_INTERFACE__SV
`define RS_INTERFACE__SV

interface rs_interface(input clk, rstn);
    logic               rs_ena;

    // Signals for received data
    logic               rx_vld;
    logic [`DATA_WIDTH-1:0]  rx_data;

    // Signals for decoded data
    logic               dec_vld;
    logic [`DATA_WIDTH-1:0]  dec_data;
    logic               dec_isos;
    logic               RDE_ERROR;

    // Clocking block for driver callback
    clocking i_drv_cb @(posedge clk);
        default input `D output `D;
        output  rs_ena;
        output  rx_vld;
        output  rx_data;
    endclocking

    // Clocking block for input monitor callback
    clocking i_mon_cb @(posedge clk);
        default input `D output `D;
        input   rs_ena;
        input   rx_vld;
        input   rx_data;
    endclocking

    // Clocking block for output monitor callback
    clocking o_mon_cb @(posedge clk);
        default input `D output `D;
        input   rs_ena;
        input   dec_vld;
        input   dec_data;
        input   dec_isos;
        input   RDE_ERROR;
    endclocking
    
endinterface // rs_interface

`endif // RS_INTERFACE__SV
