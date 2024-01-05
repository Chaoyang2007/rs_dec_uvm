`ifndef RS_TRANSACTION__SV
`define RS_TRANSACTION__SV

class rs_transaction extends uvm_sequence_item;
    // Random members for received data
    rand bit              rx_vld;          // Valid flag for received data
    rand bit [`DATA_WIDTH-1:0] rx_data;         // Received data

    // Random members for decoded data
    rand bit              dec_vld;         // Valid flag for decoded data
    rand bit [`DATA_WIDTH-1:0] dec_data;        // Decoded data
    rand bit              dec_isos;        // Flag indicating OS or Data symbol
    rand bit              RDE_ERROR;       // Error flag during decoding

    // Constraint block
    constraint c{
        // Constraints on received data
        soft rx_data inside {[0:(2**`DATA_WIDTH)-1]};  // Range constraint for received data
        soft rx_vld  dist {0:=60, 1:=30};         // Distribution constraint for rx_vld

        // Constraints on decoded data
        soft dec_vld  dist {0:=50, 1:=50};        // Distribution constraint for dec_vld
        soft dec_data inside {[0:(2**`DATA_WIDTH)-1]}; // Range constraint for decoded data
        soft dec_isos inside {0, 1};              // Constraint on isos flag
        soft RDE_ERROR inside {0, 1};             // Constraint on RDE_ERROR
    }

    // UVM field macros for factory creation and copying
    `uvm_object_utils_begin(rs_transaction)
        `uvm_field_int(rx_vld,    UVM_ALL_ON)
        `uvm_field_int(rx_data,   UVM_ALL_ON)
        `uvm_field_int(dec_vld,   UVM_ALL_ON)
        `uvm_field_int(dec_data,  UVM_ALL_ON)
        `uvm_field_int(dec_isos,  UVM_ALL_ON)
        `uvm_field_int(RDE_ERROR, UVM_ALL_ON)
    `uvm_object_utils_end

    // Constructor
    function new(string name="rs_transaction");
        super.new(name);
    endfunction // new()

    function void print_rx(string prefix="");
        $display($time, " %s tr.rx : (vld, data) = (%b, %h)", prefix, rx_vld, rx_data);
    endfunction // print_rx
    function void print_dec(string prefix="");
        $display($time, " %s tr.dec: (vld, data, isos, rde) = (%b, %h, %b, %b)", prefix, dec_vld, dec_data, dec_isos, RDE_ERROR);
    endfunction // print_dec
    function void print(string prefix="");
        $display($time, " %s tr.rx : (vld, data) = (%b, %h)", prefix, rx_vld, rx_data);
        $display($time, " %s tr.dec: (vld, data, isos, rde) = (%b, %h, %b, %b)", prefix, dec_vld, dec_data, dec_isos, RDE_ERROR);
    endfunction // print
endclass // rs_transaction

`endif // RS_TRANSACTION__SV
