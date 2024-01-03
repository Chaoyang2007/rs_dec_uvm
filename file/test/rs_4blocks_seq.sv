`ifndef RS_4BLOCKs_SEQ__SV
`define RS_4BLOCKs_SEQ__SV

class rs_4blocks_seq extends uvm_sequence#(rs_transaction);
    `uvm_object_utils(rs_4blocks_seq)
    
    rand bit has_error;

    constraint c {has_error inside {0, 1};}

    virtual task body();
        rs_transaction tr, drv_tr;
        bit [1551:0] buffer = 0; //194B
        bit [31:0]   parity = 0;
        integer      count  = 0;

        // 1st block
        forever begin
            tr = new();
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `M) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:60] = 0;
                    buffer = {buffer[1535:0],tr.rx_data[63:48]}; // 2B syncbit buffered
                    parity = rs_utils::calculate_par(buffer,has_error);
                    tr.rx_data[47:16] = parity;
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    buffer = {buffer[1535:0],tr.rx_data[15:0]}; // 2B next buffered
                    count  = 0;
                    break;
                end
            end else begin
                uvm_do_with(drv_tr, drv_tr.rx_vld==0;);
            end
        end

        // 2nd block
        forever begin
            tr = new();
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `M - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else if (count == 2 * `M - 1) begin
                    tr.rx_data[15:12] = 0;
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered with 2B syncbit
                    parity = rs_utils::calculate_par(buffer,has_error);
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:32] = parity;
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    buffer = {buffer[1519:0],tr.rx_data[31:0]}; // 4B next buffered
                    count  = 0;
                    break;
                end
            end else begin
                uvm_do_with(drv_tr, drv_tr.rx_vld==0;);
            end
        end

        // 3rd block
        forever begin
            tr = new();
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `M - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else if (count == 2 * `M - 1) begin
                    tr.rx_data[31:28] = 0;
                    buffer = {buffer[1503:0],tr.rx_data[63:16]}; // 6B buffered with 2B syncbit
                    parity = rs_utils::calculate_par(buffer,has_error);
                    tr.rx_data[15:0] = parity[31:16];
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:48] = parity[15:0];
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    buffer = {buffer[1503:0],tr.rx_data[63:16]}; // 6B next buffered
                    count  = 0;
                    break;
                end
            end else begin
                uvm_do_with(drv_tr, drv_tr.rx_vld==0;);
            end
        end

        // 4th block
        forever begin
            tr = new();
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `M - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = count + 1;
                end else begin
                    tr.rx_data[47:44] = 0;
                    buffer = {buffer[1519:0],tr.rx_data[63:32]}; // 4B buffered with 2B syncbit
                    parity = rs_utils::calculate_par(buffer,has_error);
                    tr.rx_data[32:0] = parity;
                    uvm_do_with(drv_tr, drv_tr = tr;);
                    count  = 0;
                    break;
                end
            end else begin
                uvm_do_with(drv_tr, drv_tr.rx_vld==0;);
            end
        end

        // ends with a tr with rx_vld=0
        uvm_do_with(drv_tr, drv_tr.rx_vld==0;);
    endtask // body

    function new(string name="rs_4blocks_seq");
        super.new(name)
        has_error = 1;
    endfunction //new()
endclass //rs_4blocks_seq extends uvm_sequence#(rs_transaction)

`endif RS_4BLOCKs_SEQ__SV