`ifndef RS_4BLOCKs_SEQ__SV
`define RS_4BLOCKs_SEQ__SV

class rs_4blocks_seq extends uvm_sequence#(rs_transaction);
    `uvm_object_utils(rs_4blocks_seq)
    
    rand bit has_error;

    constraint c {
        // soft has_error inside {0, 1};
        soft has_error dist {0:=10, 1:=90};
    }

    function new(string name="rs_4blocks_seq");
        super.new(name);
    endfunction // new()

    virtual task body();
        rs_transaction tr, drv_tr;
        bit [1551:0] buffer = 0; //194B
        bit [31:0]   parity = 0;
        integer      count  = 0;

        // 1st block
        $display($time, " 4blocks_seq 1st block");
        forever begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `SYMBOLS_IN_BLOCK) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:60] = 0;
                    buffer = {buffer[1535:0],tr.rx_data[63:48]}; // 2B syncbit buffered
                    rs_utils::calculate_par(buffer,has_error,parity);
                    tr.rx_data[47:16] = parity;
                    buffer = {buffer[1535:0],tr.rx_data[15:0]}; // 2B next buffered
                    count  = 0;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        // 2nd block
        $display($time, " 4blocks_seq 2nd block");
        forever begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `SYMBOLS_IN_BLOCK - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    count  = count + 1;
                end else if (count == 2 * `SYMBOLS_IN_BLOCK - 1) begin
                    tr.rx_data[15:12] = 0;
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered with 2B syncbit
                    rs_utils::calculate_par(buffer,has_error,parity);
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:32] = parity;
                    buffer = {buffer[1519:0],tr.rx_data[31:0]}; // 4B next buffered
                    count  = 0;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        // 3rd block
        $display($time, " 4blocks_seq 3rd block");
        forever begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `SYMBOLS_IN_BLOCK - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    count  = count + 1;
                end else if (count == 2 * `SYMBOLS_IN_BLOCK - 1) begin
                    tr.rx_data[31:28] = 0;
                    buffer = {buffer[1503:0],tr.rx_data[63:16]}; // 6B buffered with 2B syncbit
                    rs_utils::calculate_par(buffer,has_error,parity);
                    tr.rx_data[15:0] = parity[31:16];
                    count  = count + 1;
                end else begin
                    tr.rx_data[63:48] = parity[15:0];
                    buffer = {buffer[1503:0],tr.rx_data[63:16]}; // 6B next buffered
                    count  = 0;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        // 4th block
        $display($time, " 4blocks_seq 4th block");
        forever begin
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (count < 2 * `SYMBOLS_IN_BLOCK - 1) begin
                    buffer = {buffer[1487:0],tr.rx_data}; // all buffered
                    count  = count + 1;
                end else begin
                    tr.rx_data[47:44] = 0;
                    buffer = {buffer[1519:0],tr.rx_data[63:32]}; // 4B buffered with 2B syncbit
                    rs_utils::calculate_par(buffer,has_error,parity);
                    tr.rx_data[32:0] = parity;
                    count  = 0;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        // ends with a tr with rx_vld=0
        `uvm_do_with(tr, {tr.rx_vld==0;});
    endtask // body

endclass //rs_4blocks_seq extends uvm_sequence#(rs_transaction)

`endif // RS_4BLOCKs_SEQ__SV
