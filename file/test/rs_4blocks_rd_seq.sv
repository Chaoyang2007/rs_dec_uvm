`ifndef RS_4BLOCKS_RD_SEQ__SV
`define RS_4BLOCKS_RD_SEQ__SV

class rs_4blocks_rd_seq extends uvm_sequence#(rs_transaction);
    `uvm_object_utils(rs_4blocks_rd_seq)
    
    function new(string name="rs_4blocks_rd_seq");
        super.new(name);
    endfunction // new()

    virtual task body();
        rs_transaction tr;
        bit [194`B:0]  buffer = 0;
        bit [31:0]     parity = 0;
        integer        k      = 0;
        rand_errors    re;

        // ================= 1st =================
        $display($time, " rd_seq 1st block");
        k = 0;
        re = new();
        assert(re.randomize());
        forever begin:_1_rx_symbol
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (k < 24) begin
                    buffer = {buffer[186`B:0],tr.rx_data};
                    rs_utils::errors_inj(tr.rx_data, re, k);
                    k++;
                end else begin
                    tr.rx_data[8`B-:4] = 4'b0;
                    buffer = {buffer[192`B:0],tr.rx_data[8`B:6`B+1]};
                    rs_utils::parity_cal(buffer, parity);
                    buffer = {buffer[192`B:0],tr.rx_data[2`B:0]};
                    tr.rx_data[6`B:2`B+1] = parity;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 2nd =================
        $display($time, " rd_seq 2nd block");
        k = 0;
        re = new();
        assert(re.randomize());
        forever begin:_2_rx_symbol
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (k < 23) begin
                    buffer = {buffer[186`B:0],tr.rx_data};
                    rs_utils::errors_inj(tr.rx_data, re, k);
                    k++;
                end else if (k == 23) begin
                    tr.rx_data[2`B-:4] = 4'b0;
                    buffer = {buffer[186`B:0],tr.rx_data};
                    k++;
                end else begin
                    rs_utils::parity_cal(buffer, parity);
                    buffer = {buffer[190`B:0],tr.rx_data[4`B:0]};
                    tr.rx_data[8`B:4`B+1] = parity;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 3rd =================
        $display($time, " rd_seq 3rd block");
        k = 0;
        re = new();
        assert(re.randomize());
        forever begin:_3_rx_symbol
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (k < 23) begin
                    buffer = {buffer[186`B:0],tr.rx_data};
                    rs_utils::errors_inj(tr.rx_data, re, k);
                    k++;
                end else if (k == 23) begin
                    tr.rx_data[4`B-:4] = 4'b0;
                    buffer = {buffer[188`B:0],tr.rx_data[8`B:2`B+1]};
                    rs_utils::parity_cal(buffer, parity);
                    tr.rx_data[2`B:0] = parity[4`B:2`B+1];
                    k++;
                end else begin
                    buffer = {buffer[188`B:0],tr.rx_data[6`B:0]};
                    tr.rx_data[8`B:6`B+1] = parity[2`B:0];
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 4th =================
        $display($time, " rd_seq 4th block");
        k = 0;
        re = new();
        assert(re.randomize());
        forever begin:_4_rx_symbol
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if (tr.rx_vld) begin
                if (k < 23) begin
                    buffer = {buffer[186`B:0],tr.rx_data};
                    rs_utils::errors_inj(tr.rx_data, re, k);
                    k++;
                end else begin
                    tr.rx_data[6`B-:4] = 4'b0;
                    buffer = {buffer[190`B:0],tr.rx_data[8`B:4`B+1]};
                    rs_utils::parity_cal(buffer, parity);
                    tr.rx_data[4`B:0] = parity;
                    finish_item(tr);
                    break;
                end
            end
            finish_item(tr);
        end

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ends with a tr with rx_vld=0
        `uvm_do_with(tr, {tr.rx_vld==0;});
    endtask // body

endclass //rs_4blocks_rd_seq extends uvm_sequence#(rs_transaction)

`endif // RS_4BLOCKS_RD_SEQ__SV
