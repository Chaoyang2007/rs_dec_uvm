`ifndef RS_4BLOCKS_TB_SEQ__SV
`define RS_4BLOCKS_TB_SEQ__SV

class rs_4blocks_tb_seq extends uvm_sequence#(rs_transaction);
    `uvm_object_utils(rs_4blocks_tb_seq)
    
    function new(string name="rs_4blocks_tb_seq");
        super.new(name);
    endfunction // new()

    virtual task body();
        rs_transaction tr;
        // bit [194`B:0]  buffer = 0;
        // bit [31:0]     parity = 0;
        integer        k;

        // ================= 1st =================
        k = 0;
        $display($time, " tb_seq 1st block");
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8};
        // buffer = {buffer[186`B:0],tr.rx_data};
        finish_item(tr);
        for(integer i=0; i<23; i++) begin:_1_rx_symbol_1of1 //rcv=msg, 0-error
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            tr.rx_vld = 1;
            tr.rx_data[63:56] = 8*k+9;
            tr.rx_data[55:48] = 8*k+10;
            tr.rx_data[47:40] = 8*k+11;
            tr.rx_data[39:32] = 8*k+12;
            tr.rx_data[31:24] = 8*k+13;
            tr.rx_data[23:16] = 8*k+14;
            tr.rx_data[15:8 ] = 8*k+15;
            tr.rx_data[7:0  ] = 8*k+16;
            // buffer = {buffer[186`B:0],tr.rx_data};
            finish_item(tr);
            k++;
        end
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd3, 8'd51, 8'd196, 8'd215, 8'd142, 8'd109, 8'd1, 8'd2};
        // buffer = {buffer[192`B:0],tr.rx_data[8`B:6`B+1]};
        // rs_utils::parity_cal(buffer, parity);
        // $display(" parity_cal = (%0d, %0d, %0d, %0d)", parity[4`B:3`B+1], parity[3`B:2`B+1], parity[2`B:1`B+1], parity[1`B:0]);
        // $display(" parity_gld = (%0d, %0d, %0d, %0d)", 8'd196, 8'd215, 8'd142, 8'd109);
        finish_item(tr);

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 2nd =================
        k = 0;
        $display($time, " tb_seq 2nd block");
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd3, 8'd4, 8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10};
        finish_item(tr);
        for(integer i=0; i<44; i++) begin:_2_rx_symbol_1of2 //rcv(192)=0, 1-error
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if(i%2 == 0)
                tr.rx_vld = 0;
            else begin
                tr.rx_vld = 1;
                tr.rx_data[63:56] = 8*k+11;
                tr.rx_data[55:48] = 8*k+12;
                tr.rx_data[47:40] = 8*k+13;
                tr.rx_data[39:32] = 8*k+14;
                tr.rx_data[31:24] = 8*k+15;
                tr.rx_data[23:16] = 8*k+16;
                tr.rx_data[15:8 ] = 8*k+17;
                tr.rx_data[7:0  ] = 8*k+18;
                k++;
            end
            finish_item(tr);
        end
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd187, 8'd188, 8'd189, 8'd190, 8'd191, 8'd0, 8'd3, 8'd51};
        finish_item(tr);
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd196, 8'd215, 8'd142, 8'd109, 8'd1, 8'd2, 8'd3, 8'd4};
        finish_item(tr);

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 3rd =================
        k = 0;
        $display($time, " tb_seq 3rd block");
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd5, 8'd6, 8'd7, 8'd8, 8'd9, 8'd10, 8'd11, 8'd12};
        finish_item(tr);
        for(integer i=0; i<33; i++) begin:_3_rx_symbol_2of3 //rcv(192)=0, rcv(193)=0, 2-error
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if(i%3 == 0)
                tr.rx_vld = 0;
            else begin
                tr.rx_vld = 1;
                tr.rx_data[63:56] = 8*k+13;
                tr.rx_data[55:48] = 8*k+14;
                tr.rx_data[47:40] = 8*k+15;
                tr.rx_data[39:32] = 8*k+16;
                tr.rx_data[31:24] = 8*k+17;
                tr.rx_data[23:16] = 8*k+18;
                tr.rx_data[15:8 ] = 8*k+19;
                tr.rx_data[7:0  ] = 8*k+20;
                k++;
            end
            finish_item(tr);
        end
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd189, 8'd190, 8'd191, 8'd0, 8'd0, 8'd51, 8'd196, 8'd215};
        finish_item(tr);
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd142, 8'd109, 8'd1, 8'd2, 8'd3, 8'd4, 8'd5, 8'd6};
        finish_item(tr);

        `uvm_do_with(tr, {tr.rx_vld==0;});

        // ================= 4th =================
        k = 0;
        $display($time, " tb_seq 4th block");
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd7, 8'd0, 8'd9, 8'd10, 8'd11, 8'd12, 8'd13, 8'd14};
        finish_item(tr);
        for(integer i=0; i<27; i++) begin:_4_rx_symbol_5of6 //rcv(8)=0, rcv(194)=0, 2-error
            tr = new("tr");
            start_item(tr);
            assert(tr.randomize());
            if(i%6 == 0)
                tr.rx_vld = 0;
            else begin
                tr.rx_vld = 1;
                tr.rx_data[63:56] = 8*k+15;
                tr.rx_data[55:48] = 8*k+16;
                tr.rx_data[47:40] = 8*k+17;
                tr.rx_data[39:32] = 8*k+18;
                tr.rx_data[31:24] = 8*k+19;
                tr.rx_data[23:16] = 8*k+20;
                tr.rx_data[15:8 ] = 8*k+21;
                tr.rx_data[7:0  ] = 8*k+22;
                k++;
            end
            finish_item(tr);
        end
        tr = new("tr");
        start_item(tr);
        assert(tr.randomize());
        tr.rx_vld = 1;
        tr.rx_data = {8'd191, 8'd192, 8'd3, 8'd0, 8'd196, 8'd215, 8'd142, 8'd109};
        finish_item(tr);

        `uvm_do_with(tr, {tr.rx_vld==0;});

        repeat(10)`uvm_do_with(tr, {tr.rx_vld==0;});

        // ends with a tr with rx_vld=0
        `uvm_do_with(tr, {tr.rx_vld==0;});
    endtask // body

endclass //rs_4blocks_tb_seq extends uvm_sequence#(rs_transaction)

`endif // RS_4BLOCKS_TB_SEQ__SV
