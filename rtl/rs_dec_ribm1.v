`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// reate Date: 2024/02/01
// Design Name: 
// Module Name: rs_dec_ribm1
// Project Name: 
// Desription: 
// 
// Dependencies: 
// 
// Revision:
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif


module rs_dec_ribm1 (
    input wire        clk,
    input wire        rstn,
    input wire        rs_ena,
    input wire        rx_vld,
    input wire [63:0] rx_data,

    output wire        dec_vld,
    output wire [63:0] dec_data,
    output wire        dec_isos,
    output wire        rde_error
);

    //======================== rx_data process  ========================//
    reg  [63:0] rx_data_1t;
    wire [63:0] syn_data0;
    wire [63:0] syn_data1;

    reg [1:0] counter_rx_len0;
    reg [4:0] counter_rx_len1;

    wire syn_data_init;
    wire syn_data_last;
    wire syn_data_last0;
    wire syn_data_last1;

    assign syn_data_init  = (counter_rx_len1 == 'd0);
    assign syn_data_last  = syn_data_last0 | syn_data_last1;
    assign syn_data_last0 = (~&counter_rx_len0 && counter_rx_len1=='d24);
    assign syn_data_last1 = ( &counter_rx_len0 && counter_rx_len1=='d23);

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rx_len0 <= `D 'd0;
        end else if(rx_vld) begin
            counter_rx_len0 <= `D syn_data_last ? counter_rx_len0 + 'd1 : counter_rx_len0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rx_len1 <= `D 'd0;
        end else if(rx_vld) begin
            counter_rx_len1 <= `D syn_data_last ? 'd0 : counter_rx_len1 + 'd1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rx_data_1t <= `D 'h0;
        end else begin
            rx_data_1t <= `D rx_vld ? rx_data : rx_data_1t;
        end
    end

    assign syn_data0 = (counter_rx_len0=='d0) ? (syn_data_last0 ? {rx_data   [63:16], 16'b0                } : rx_data                            ) :
                       (counter_rx_len0=='d1) ? (syn_data_last0 ? {rx_data_1t[15: 0], rx_data[63:32], 16'b0} : {rx_data_1t[15: 0], rx_data[63:16]}) :
                       (counter_rx_len0=='d2) ? (syn_data_last0 ? {rx_data_1t[31: 0], rx_data[63:48], 16'b0} : {rx_data_1t[31: 0], rx_data[63:32]}) :
                       (counter_rx_len0=='d3) ? (                                                              {rx_data_1t[47: 0], rx_data[63:48]}) : 64'b0;
    assign syn_data1 = {rx_data[47: 0], 16'b0};
    //======================== dec_data rd_ctrl ========================//
    reg [4:0] counter_rd_len;

    wire syn_nerror;
    wire kes_done;

    wire dec_data_rd_init;
    wire dec_data_rd_done;
    reg  dec_data_rd_ena;

    assign dec_data_rd_init = syn_nerror || kes_done;
    assign dec_data_rd_done = counter_rd_len == 'd23;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            dec_data_rd_ena <= `D 'b0;
        end else if(dec_data_rd_done) begin
            dec_data_rd_ena <= `D 'b0;
        end else if(dec_data_rd_init) begin
            dec_data_rd_ena <= `D 'b1;
        end else begin
            dec_data_rd_ena <= `D dec_data_rd_ena;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_rd_len <= `D 'd0;
        end else if(dec_data_rd_done) begin
            counter_rd_len <= `D 'd0;
        end else if(dec_data_rd_ena) begin
            counter_rd_len <= `D counter_rd_len + 'd1;
        end else begin
            counter_rd_len <= `D counter_rd_len;
        end
    end
    //======================== sub modules inst ========================//
    wire [7:0] rs_syn0;
    wire [7:0] rs_syn1;
    wire [7:0] rs_syn2;
    wire [7:0] rs_syn3;
    wire syn_error;
    wire syn_done;

    s1_syncal u_s1_syncal(
        .clk(clk),
        .rstn(rstn),
        .rs_ena(rs_ena),
        .data_vld(rx_vld),
        .syn_data0(syn_data0),
        .syn_data1(syn_data1),
        .data_init(syn_data_init),
        .data_last0(syn_data_last0),
        .data_last1(syn_data_last1),

        .rs_syn0(rs_syn0),
        .rs_syn1(rs_syn1),
        .rs_syn2(rs_syn2),
        .rs_syn3(rs_syn3),
        .syn_error(syn_error),
        .syn_nerror(syn_nerror),
        .syn_done(syn_done)
    );

    wire [7:0] rs_lambda0;
    wire [7:0] rs_lambda1;
    wire [7:0] rs_lambda2;
    wire [7:0] rs_omega0;
    wire [7:0] rs_omega1;

    s2_kes_ribm1 u_s2_kes_ribm1 (
        .clk(clk),
        .rstn(rstn),
        .kes_ena(syn_error),
        .rs_syn0(rs_syn0),
        .rs_syn1(rs_syn1),
        .rs_syn2(rs_syn2),
        .rs_syn3(rs_syn3),

        .rs_lambda0(rs_lambda0),
        .rs_lambda1(rs_lambda1),
        .rs_lambda2(rs_lambda2),
        .rs_omega0(rs_omega0),
        .rs_omega1(rs_omega1),
        .kes_done(kes_done)
    );

    wire [63:0] rs_error_data;
    wire [11:0] rs_error_sync;
    wire csee_in_process;
    wire rs_decode_fail;
    
    s3_cseeh u_s3_cseeh(
        .clk(clk),
        .rstn(rstn),
        .rs_ena(rs_ena),
        .csee_ena(kes_done),
        .rs_lambda0(rs_lambda0),
        .rs_lambda1(rs_lambda1),
        .rs_lambda2(rs_lambda2),
        .rs_omega0(rs_omega0),
        .rs_omega1(rs_omega1),

        .csee_in_process(csee_in_process),
        .rs_error_data(rs_error_data),
        .rs_error_sync(rs_error_sync),
        .rs_decode_fail(rs_decode_fail)
    );

    wire        rs_pop_data_vld;
    wire [63:0] rs_pop_data;
    wire        rs_pop_isos;

    rs_fifo u_rs_fifo(
        .clk(clk),
        .rstn(rstn),
        .push_data_ena(rx_vld),
        .rs_data0(syn_data0),
        .rs_data1(syn_data1),
        .data_last0(syn_data_last0),
        .data_last1(syn_data_last1),
        .rs_errdata_vld(csee_in_process),
        .rs_errdata(rs_error_data),
        .rs_errsync_vld(kes_done),
        .rs_errsync(rs_error_sync),
        .pop_data_ena(dec_data_rd_ena),
        
        .rs_pop_data_vld(rs_pop_data_vld),
        .rs_pop_data(rs_pop_data),
        .rs_pop_isos(rs_pop_isos)
    );

    //========================   output logic   ========================//
    assign dec_vld = rs_pop_data_vld;
    assign dec_data  = rs_pop_data;
    assign dec_isos  = rs_pop_isos;
    assign rde_error = rs_decode_fail;

endmodule

// syncal
module s1_syncal(
    input wire        clk,
    input wire        rstn,
    input wire        rs_ena,
    input wire        data_vld,
    input wire [63:0] syn_data0,
    input wire [63:0] syn_data1,
    input wire        data_init,
    input wire        data_last0,
    input wire        data_last1,

    output reg [ 7:0] rs_syn0,
    output reg [ 7:0] rs_syn1,
    output reg [ 7:0] rs_syn2,
    output reg [ 7:0] rs_syn3,
    output reg        syn_error,
    output reg        syn_nerror,
    output reg        syn_done
);

    localparam ALPHA01 = 8'd2,    ALPHA02 = 8'd4,   ALPHA03 = 8'd8,   ALPHA04 = 8'd16,  ALPHA05 = 8'd32,  ALPHA06 = 8'd64;
    localparam ALPHA07 = 8'd128,  ALPHA08 = 8'd29,  ALPHA09 = 8'd58,  ALPHA10 = 8'd116, ALPHA11 = 8'd232, ALPHA12 = 8'd205;
    localparam ALPHA13 = 8'd135,  ALPHA14 = 8'd19,  ALPHA15 = 8'd38,  ALPHA16 = 8'd76,  ALPHA17 = 8'd152, ALPHA18 = 8'd45;
    localparam ALPHA19 = 8'd90,   ALPHA20 = 8'd180, ALPHA21 = 8'd117, ALPHA22 = 8'd234, ALPHA23 = 8'd201, ALPHA24 = 8'd143;
    localparam ITERATION='d25;

    reg [ 4:0] counter_it;

    reg [63:0] syn_data0_1t;

    reg [ 7:0] syn0_temp;
    reg [ 7:0] syn1_temp;
    reg [ 7:0] syn2_temp;
    reg [ 7:0] syn3_temp;

    wire[ 7:0] syn0_next;
    wire[ 7:0] syn1_next;
    wire[ 7:0] syn2_next;
    wire[ 7:0] syn3_next;

    //========================   normal syn_data   ========================//
    wire[ 7:0] data0_0;
    wire[ 7:0] data0_1;
    wire[ 7:0] data0_2;
    wire[ 7:0] data0_3;
    wire[ 7:0] data0_4;
    wire[ 7:0] data0_5;
    wire[ 7:0] data0_6;
    wire[ 7:0] data0_7;

    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha01;
    wire[ 7:0] data0_2_multi_alpha02;
    wire[ 7:0] data0_3_multi_alpha03;
    wire[ 7:0] data0_4_multi_alpha04;
    wire[ 7:0] data0_5_multi_alpha05;
    wire[ 7:0] data0_6_multi_alpha06;
    wire[ 7:0] data0_7_multi_alpha07;
    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha02;
    wire[ 7:0] data0_2_multi_alpha04;
    wire[ 7:0] data0_3_multi_alpha06;
    wire[ 7:0] data0_4_multi_alpha08;
    wire[ 7:0] data0_5_multi_alpha10;
    wire[ 7:0] data0_6_multi_alpha12;
    wire[ 7:0] data0_7_multi_alpha14;
    //wire[ 7:0] data0_0_multi_alpha00;
    wire[ 7:0] data0_1_multi_alpha03;
    wire[ 7:0] data0_2_multi_alpha06;
    wire[ 7:0] data0_3_multi_alpha09;
    wire[ 7:0] data0_4_multi_alpha12;
    wire[ 7:0] data0_5_multi_alpha15;
    wire[ 7:0] data0_6_multi_alpha18;
    wire[ 7:0] data0_7_multi_alpha21;

    wire[ 7:0] sum_data0_multi_x0;
    wire[ 7:0] sum_data0_multi_x1;
    wire[ 7:0] sum_data0_multi_x2;
    wire[ 7:0] sum_data0_multi_x3;

    assign data0_0 = syn_data0[23:16];
    assign data0_1 = syn_data0[31:24];
    assign data0_2 = syn_data0[39:32];
    assign data0_3 = syn_data0[47:40];
    assign data0_4 = syn_data0[55:48];
    assign data0_5 = syn_data0[63:56];
    assign data0_6 = data_init ? 8'h00 : syn_data0_1t[ 7: 0];
    assign data0_7 = data_init ? 8'h00 : syn_data0_1t[15: 8];

    //gf2m8_multi u_gf2m8_multi_010(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_011(.x(data0_1), .y(ALPHA01),  .z(data0_1_multi_alpha01));
    gf2m8_multi u_gf2m8_multi_012(.x(data0_2), .y(ALPHA02),  .z(data0_2_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_013(.x(data0_3), .y(ALPHA03),  .z(data0_3_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_014(.x(data0_4), .y(ALPHA04),  .z(data0_4_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_015(.x(data0_5), .y(ALPHA05),  .z(data0_5_multi_alpha05));
    gf2m8_multi u_gf2m8_multi_016(.x(data0_6), .y(ALPHA06),  .z(data0_6_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_017(.x(data0_7), .y(ALPHA07),  .z(data0_7_multi_alpha07));
    //gf2m8_multi u_gf2m8_multi_020(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_021(.x(data0_1), .y(ALPHA02),  .z(data0_1_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_022(.x(data0_2), .y(ALPHA04),  .z(data0_2_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_023(.x(data0_3), .y(ALPHA06),  .z(data0_3_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_024(.x(data0_4), .y(ALPHA08),  .z(data0_4_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_025(.x(data0_5), .y(ALPHA10),  .z(data0_5_multi_alpha10));
    gf2m8_multi u_gf2m8_multi_026(.x(data0_6), .y(ALPHA12),  .z(data0_6_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_027(.x(data0_7), .y(ALPHA14),  .z(data0_7_multi_alpha14));
    //gf2m8_multi u_gf2m8_multi_030(.x(data0_0), .y(ALPHA00),  .z(data0_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_031(.x(data0_1), .y(ALPHA03),  .z(data0_1_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_032(.x(data0_2), .y(ALPHA06),  .z(data0_2_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_033(.x(data0_3), .y(ALPHA09),  .z(data0_3_multi_alpha09));
    gf2m8_multi u_gf2m8_multi_034(.x(data0_4), .y(ALPHA12),  .z(data0_4_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_035(.x(data0_5), .y(ALPHA15),  .z(data0_5_multi_alpha15));
    gf2m8_multi u_gf2m8_multi_036(.x(data0_6), .y(ALPHA18),  .z(data0_6_multi_alpha18));
    gf2m8_multi u_gf2m8_multi_037(.x(data0_7), .y(ALPHA21),  .z(data0_7_multi_alpha21));

    assign sum_data0_multi_x0 = data0_0 ^ data0_1 ^ data0_2 ^ data0_3 ^ data0_4 ^ data0_5 ^ data0_6 ^ data0_7;
    assign sum_data0_multi_x1 = data0_0 ^ data0_1_multi_alpha01 ^ data0_2_multi_alpha02 ^ data0_3_multi_alpha03 ^ 
                                data0_4_multi_alpha04 ^ data0_5_multi_alpha05 ^ data0_6_multi_alpha06 ^ data0_7_multi_alpha07;
    assign sum_data0_multi_x2 = data0_0 ^ data0_1_multi_alpha02 ^ data0_2_multi_alpha04 ^ data0_3_multi_alpha06 ^ 
                                data0_4_multi_alpha08 ^ data0_5_multi_alpha10 ^ data0_6_multi_alpha12 ^ data0_7_multi_alpha14;
    assign sum_data0_multi_x3 = data0_0 ^ data0_1_multi_alpha03 ^ data0_2_multi_alpha06 ^ data0_3_multi_alpha09 ^ 
                                data0_4_multi_alpha12 ^ data0_5_multi_alpha15 ^ data0_6_multi_alpha18 ^ data0_7_multi_alpha21;

    //========================   burst syn_data   ========================//
    wire[ 7:0] data1_0;
    wire[ 7:0] data1_1;
    wire[ 7:0] data1_2;
    wire[ 7:0] data1_3;
    wire[ 7:0] data1_4;
    wire[ 7:0] data1_5;
    wire[ 7:0] data1_6;
    wire[ 7:0] data1_7;

    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha01;
    wire[ 7:0] data1_2_multi_alpha02;
    wire[ 7:0] data1_3_multi_alpha03;
    wire[ 7:0] data1_4_multi_alpha04;
    wire[ 7:0] data1_5_multi_alpha05;
    wire[ 7:0] data1_6_multi_alpha06;
    wire[ 7:0] data1_7_multi_alpha07;
    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha02;
    wire[ 7:0] data1_2_multi_alpha04;
    wire[ 7:0] data1_3_multi_alpha06;
    wire[ 7:0] data1_4_multi_alpha08;
    wire[ 7:0] data1_5_multi_alpha10;
    wire[ 7:0] data1_6_multi_alpha12;
    wire[ 7:0] data1_7_multi_alpha14;
    //wire[ 7:0] data1_0_multi_alpha00;
    wire[ 7:0] data1_1_multi_alpha03;
    wire[ 7:0] data1_2_multi_alpha06;
    wire[ 7:0] data1_3_multi_alpha09;
    wire[ 7:0] data1_4_multi_alpha12;
    wire[ 7:0] data1_5_multi_alpha15;
    wire[ 7:0] data1_6_multi_alpha18;
    wire[ 7:0] data1_7_multi_alpha21;

    wire[ 7:0] sum_data1_multi_x0;
    wire[ 7:0] sum_data1_multi_x1;
    wire[ 7:0] sum_data1_multi_x2;
    wire[ 7:0] sum_data1_multi_x3;
   
    assign data1_0 = syn_data1[23:16];
    assign data1_1 = syn_data1[31:24];
    assign data1_2 = syn_data1[39:32];
    assign data1_3 = syn_data1[47:40];
    assign data1_4 = syn_data1[55:48];
    assign data1_5 = syn_data1[63:56];
    assign data1_6 = syn_data0[ 7: 0];
    assign data1_7 = syn_data0[15: 8];

    //gf2m8_multi u_gf2m8_multi_110(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_111(.x(data1_1), .y(ALPHA01),  .z(data1_1_multi_alpha01));
    gf2m8_multi u_gf2m8_multi_112(.x(data1_2), .y(ALPHA02),  .z(data1_2_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_113(.x(data1_3), .y(ALPHA03),  .z(data1_3_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_114(.x(data1_4), .y(ALPHA04),  .z(data1_4_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_115(.x(data1_5), .y(ALPHA05),  .z(data1_5_multi_alpha05));
    gf2m8_multi u_gf2m8_multi_116(.x(data1_6), .y(ALPHA06),  .z(data1_6_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_117(.x(data1_7), .y(ALPHA07),  .z(data1_7_multi_alpha07));
    //gf2m8_multi u_gf2m8_multi_120(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_121(.x(data1_1), .y(ALPHA02),  .z(data1_1_multi_alpha02));
    gf2m8_multi u_gf2m8_multi_122(.x(data1_2), .y(ALPHA04),  .z(data1_2_multi_alpha04));
    gf2m8_multi u_gf2m8_multi_123(.x(data1_3), .y(ALPHA06),  .z(data1_3_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_124(.x(data1_4), .y(ALPHA08),  .z(data1_4_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_125(.x(data1_5), .y(ALPHA10),  .z(data1_5_multi_alpha10));
    gf2m8_multi u_gf2m8_multi_126(.x(data1_6), .y(ALPHA12),  .z(data1_6_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_127(.x(data1_7), .y(ALPHA14),  .z(data1_7_multi_alpha14));
    //gf2m8_multi u_gf2m8_multi_130(.x(data1_0), .y(ALPHA00),  .z(data1_0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_131(.x(data1_1), .y(ALPHA03),  .z(data1_1_multi_alpha03));
    gf2m8_multi u_gf2m8_multi_132(.x(data1_2), .y(ALPHA06),  .z(data1_2_multi_alpha06));
    gf2m8_multi u_gf2m8_multi_133(.x(data1_3), .y(ALPHA09),  .z(data1_3_multi_alpha09));
    gf2m8_multi u_gf2m8_multi_134(.x(data1_4), .y(ALPHA12),  .z(data1_4_multi_alpha12));
    gf2m8_multi u_gf2m8_multi_135(.x(data1_5), .y(ALPHA15),  .z(data1_5_multi_alpha15));
    gf2m8_multi u_gf2m8_multi_136(.x(data1_6), .y(ALPHA18),  .z(data1_6_multi_alpha18));
    gf2m8_multi u_gf2m8_multi_137(.x(data1_7), .y(ALPHA21),  .z(data1_7_multi_alpha21));

    assign sum_data1_multi_x0 = data1_0 ^ data1_1 ^ data1_2 ^ data1_3 ^ data1_4 ^ data1_5 ^ data1_6 ^ data1_7;
    assign sum_data1_multi_x1 = data1_0 ^ data1_1_multi_alpha01 ^ data1_2_multi_alpha02 ^ data1_3_multi_alpha03 ^ 
                                data1_4_multi_alpha04 ^ data1_5_multi_alpha05 ^ data1_6_multi_alpha06 ^ data1_7_multi_alpha07;
    assign sum_data1_multi_x2 = data1_0 ^ data1_1_multi_alpha02 ^ data1_2_multi_alpha04 ^ data1_3_multi_alpha06 ^ 
                                data1_4_multi_alpha08 ^ data1_5_multi_alpha10 ^ data1_6_multi_alpha12 ^ data1_7_multi_alpha14;
    assign sum_data1_multi_x3 = data1_0 ^ data1_1_multi_alpha03 ^ data1_2_multi_alpha06 ^ data1_3_multi_alpha09 ^ 
                                data1_4_multi_alpha12 ^ data1_5_multi_alpha15 ^ data1_6_multi_alpha18 ^ data1_7_multi_alpha21;

    //========================   syn*_next   ========================//
    //wire[ 7:0] syn0_multi_alpha00;
    wire[ 7:0] syn1_multi_alpha08;
    wire[ 7:0] syn2_multi_alpha16;
    wire[ 7:0] syn3_multi_alpha24;

    wire[ 7:0] syn0_next_op1;
    wire[ 7:0] syn1_next_op1;
    wire[ 7:0] syn2_next_op1;
    wire[ 7:0] syn3_next_op1;

    //wire[ 7:0] syn0_next_op1_multi_alpha00;
    wire[ 7:0] syn1_next_op1_multi_alpha08;
    wire[ 7:0] syn2_next_op1_multi_alpha16;
    wire[ 7:0] syn3_next_op1_multi_alpha24;

    wire[ 7:0] syn0_next_op2;
    wire[ 7:0] syn1_next_op2;
    wire[ 7:0] syn2_next_op2;
    wire[ 7:0] syn3_next_op2;
    
    //gf2m8_multi u_gf2m8_multi_s0(.x(syn0_temp), .y(ALPHA00),  .z(syn0_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_s1(.x(syn1_temp ), .y(ALPHA08),  .z(syn1_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_s2(.x(syn2_temp ), .y(ALPHA16),  .z(syn2_multi_alpha16));
    gf2m8_multi u_gf2m8_multi_s3(.x(syn3_temp ), .y(ALPHA24),  .z(syn3_multi_alpha24));

    //gf2m8_multi u_gf2m8_multi_s4(.x(syn0_next_op1), .y(ALPHA00),  .z(syn0_next_op1_multi_alpha00));
    gf2m8_multi u_gf2m8_multi_s5(.x(syn1_next_op1), .y(ALPHA08),  .z(syn1_next_op1_multi_alpha08));
    gf2m8_multi u_gf2m8_multi_s6(.x(syn2_next_op1), .y(ALPHA16),  .z(syn2_next_op1_multi_alpha16));
    gf2m8_multi u_gf2m8_multi_s7(.x(syn3_next_op1), .y(ALPHA24),  .z(syn3_next_op1_multi_alpha24));

    assign syn0_next_op1 = sum_data0_multi_x0 ^ syn0_temp         ;
    assign syn1_next_op1 = sum_data0_multi_x1 ^ syn1_multi_alpha08;
    assign syn2_next_op1 = sum_data0_multi_x2 ^ syn2_multi_alpha16;
    assign syn3_next_op1 = sum_data0_multi_x3 ^ syn3_multi_alpha24;

    assign syn0_next_op2 = sum_data1_multi_x0 ^ syn0_next_op1              ;
    assign syn1_next_op2 = sum_data1_multi_x1 ^ syn1_next_op1_multi_alpha08;
    assign syn2_next_op2 = sum_data1_multi_x2 ^ syn2_next_op1_multi_alpha16;
    assign syn3_next_op2 = sum_data1_multi_x3 ^ syn3_next_op1_multi_alpha24;

    assign syn0_next = data_init ? sum_data0_multi_x0 : data_last1 ? syn0_next_op2 : syn0_next_op1;//mux 位置，驱动能力的差异
    assign syn1_next = data_init ? sum_data0_multi_x1 : data_last1 ? syn1_next_op2 : syn1_next_op1;
    assign syn2_next = data_init ? sum_data0_multi_x2 : data_last1 ? syn2_next_op2 : syn2_next_op1;
    assign syn3_next = data_init ? sum_data0_multi_x3 : data_last1 ? syn3_next_op2 : syn3_next_op1;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            syn_data0_1t <= `D 'b0;
        end else if(rs_ena & data_vld) begin
            syn_data0_1t <= `D syn_data0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_it <= `D 'd0;
        end else if(rs_ena & data_vld) begin
            if(counter_it=='d0 && data_init) begin
                counter_it <= `D 'd1;
            end else if((counter_it==ITERATION-1 && data_last0) || (counter_it==ITERATION-2 && data_last1)) begin
                counter_it <= `D 'd0;
            end else if(counter_it) begin
                counter_it <= `D counter_it + 'd1;
            end else begin
                counter_it <= `D counter_it;
            end
        end
    end

    icg u_icg_syn_temp(.clk(clk), .ena(rs_ena & data_vld), .rstn(rstn), .gclk(syn_temp_clk));
    always @(posedge syn_temp_clk or negedge rstn) begin
        if(!rstn) begin
            syn0_temp <= `D 'b0;
            syn1_temp <= `D 'b0;
            syn2_temp <= `D 'b0;
            syn3_temp <= `D 'b0;
        end else begin
            syn0_temp <= `D syn0_next;
            syn1_temp <= `D syn1_next;
            syn2_temp <= `D syn2_next;
            syn3_temp <= `D syn3_next;
        end
    end

    icg u_icg_rs_syn(.clk(clk), .ena(rs_ena && data_vld && (data_last0 || data_last1)), .rstn(rstn), .gclk(rs_syn_clk));
    always @(posedge rs_syn_clk or negedge rstn) begin
        if(!rstn) begin
            rs_syn0 <= `D 'b0;
            rs_syn1 <= `D 'b0;
            rs_syn2 <= `D 'b0;
            rs_syn3 <= `D 'b0;
        end else begin
            rs_syn0 <= `D syn0_next;
            rs_syn1 <= `D syn1_next;
            rs_syn2 <= `D syn2_next;
            rs_syn3 <= `D syn3_next;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            syn_error  <= `D 'b0;
            syn_nerror <= `D 'b0;
            syn_done   <= `D 'b0;
        end else if(rs_ena && (data_last0 || data_last1) && data_vld) begin
            syn_error  <= `D {syn0_next,syn1_next,syn2_next,syn3_next} != 'b0;
            syn_nerror <= `D {syn0_next,syn1_next,syn2_next,syn3_next} == 'b0;
            syn_done   <= `D 'b1;
        end else begin
            syn_error  <= `D 'b0;
            syn_nerror <= `D 'b0;
            syn_done   <= `D 'b0;
        end
    end

endmodule // end of syncal

// kes_ribm1
module s2_kes_ribm1(
    input wire       clk,
    input wire       rstn,
    input wire       kes_ena,
    input wire [7:0] rs_syn0,
    input wire [7:0] rs_syn1,
    input wire [7:0] rs_syn2,
    input wire [7:0] rs_syn3,

    output reg [7:0] rs_lambda0,
    output reg [7:0] rs_lambda1,
    output reg [7:0] rs_lambda2,
    output reg [7:0] rs_omega0,
    output reg [7:0] rs_omega1,
    output reg       kes_done
);
    localparam S0='b00001;
    localparam S1='b00010;
    localparam S2='b00100;
    localparam S3='b01000;
    localparam S4='b10000;

    reg [4:0] ribm1_state;
    reg [4:0] ribm1_state_next;

    reg [2:0] L;
    reg [2:0] K;

    reg [7:0] Delta0;
    reg [7:0] Delta1;
    reg [7:0] Delta2;
    reg [7:0] Delta3;
    reg [7:0] Delta4;
    reg [7:0] Delta5;
    reg [7:0] Delta6;

    reg [7:0] Theta0;
    reg [7:0] Theta1;
    reg [7:0] Theta2;
    reg [7:0] Theta3;
    reg [7:0] Theta4;
    reg [7:0] Theta5;
    reg [7:0] Theta6;

    reg [2:0] L_next;

    reg [7:0] Delta0_next;
    reg [7:0] Delta1_next;
    reg [7:0] Delta2_next;
    reg [7:0] Delta3_next;
    reg [7:0] Delta4_next;
    reg [7:0] Delta5_next;
    reg [7:0] Delta6_next;

    reg [7:0] Theta0_next;
    reg [7:0] Theta1_next;
    reg [7:0] Theta2_next;
    reg [7:0] Theta3_next;
    reg [7:0] Theta4_next;
    reg [7:0] Theta5_next;
    reg [7:0] Theta6_next;

    wire [7:0] delta;
    reg  [7:0] gamma;
    reg  [7:0] gamma_next;

    wire [7:0] delta_multi_T0;
    wire [7:0] delta_multi_T1;
    wire [7:0] delta_multi_T2;
    wire [7:0] delta_multi_T3;
    wire [7:0] delta_multi_T4;
    wire [7:0] delta_multi_T5;
    wire [7:0] delta_multi_T6;
    //wire [7:0] gamma_multi_D0;
    wire [7:0] gamma_multi_D1;
    wire [7:0] gamma_multi_D2;
    wire [7:0] gamma_multi_D3;
    wire [7:0] gamma_multi_D4;
    wire [7:0] gamma_multi_D5;
    wire [7:0] gamma_multi_D6;

    wire [7:0] Delta0_update;
    wire [7:0] Delta1_update;
    wire [7:0] Delta2_update;
    wire [7:0] Delta3_update;
    wire [7:0] Delta4_update;
    wire [7:0] Delta5_update;
    wire [7:0] Delta6_update;

    wire idle;
    wire init;
    wire done;
    wire swap;
    wire kes_in_process;

    always @(*) begin
        case (ribm1_state)
            S0: ribm1_state_next = init ? S1 : S0;
            S1: ribm1_state_next = S2;
            S2: ribm1_state_next = S3;
            S3: ribm1_state_next = S4;
            S4: ribm1_state_next = S0;
            default: ribm1_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            ribm1_state <= `D S0;
        end else begin
            ribm1_state <= `D ribm1_state_next;
        end
    end

    always @(*) begin
        case (ribm1_state)
            S0: K = 'd0;
            S1: K = 'd0;
            S2: K = 'd1;
            S3: K = 'd2;
            S4: K = 'd3;
            default: K = 'd0;
        endcase
    end

    assign idle  = ribm1_state[0];
    assign init = kes_ena & idle;
    assign done  = ribm1_state[4]; // kes done
    assign swap  = delta!=8'h00 && 2*L<=K; // swap Delta Theta and calculate

    assign kes_in_process = init | ~idle;

    assign delta = Delta0;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(delta), .y(Theta0), .z(delta_multi_T0) );
    gf2m8_multi u_gf2m8_multi_aq1 ( .x(delta), .y(Theta1), .z(delta_multi_T1) );
    gf2m8_multi u_gf2m8_multi_aq2 ( .x(delta), .y(Theta2), .z(delta_multi_T2) );
    gf2m8_multi u_gf2m8_multi_aq3 ( .x(delta), .y(Theta3), .z(delta_multi_T3) );
    gf2m8_multi u_gf2m8_multi_aq4 ( .x(delta), .y(Theta4), .z(delta_multi_T4) );
    gf2m8_multi u_gf2m8_multi_aq5 ( .x(delta), .y(Theta5), .z(delta_multi_T5) );
    gf2m8_multi u_gf2m8_multi_aq6 ( .x(delta), .y(Theta6), .z(delta_multi_T6) );
    //gf2m8_multi u_gf2m8_multi_br0 ( .x(gamma), .y(Delta0), .z(gamma_multi_D0) );
    gf2m8_multi u_gf2m8_multi_br1 ( .x(gamma), .y(Delta1), .z(gamma_multi_D1) );
    gf2m8_multi u_gf2m8_multi_br2 ( .x(gamma), .y(Delta2), .z(gamma_multi_D2) );
    gf2m8_multi u_gf2m8_multi_br3 ( .x(gamma), .y(Delta3), .z(gamma_multi_D3) );
    gf2m8_multi u_gf2m8_multi_br4 ( .x(gamma), .y(Delta4), .z(gamma_multi_D4) );
    gf2m8_multi u_gf2m8_multi_br5 ( .x(gamma), .y(Delta5), .z(gamma_multi_D5) );
    gf2m8_multi u_gf2m8_multi_br6 ( .x(gamma), .y(Delta6), .z(gamma_multi_D6) );

    //∆ = γ·∆·x^(−1) − δ·Θ
    assign Delta0_update = gamma_multi_D1 ^ delta_multi_T0;
    assign Delta1_update = gamma_multi_D2 ^ delta_multi_T1;
    assign Delta2_update = gamma_multi_D3 ^ delta_multi_T2;
    assign Delta3_update = gamma_multi_D4 ^ delta_multi_T3;
    assign Delta4_update = gamma_multi_D5 ^ delta_multi_T4;
    assign Delta5_update = gamma_multi_D6 ^ delta_multi_T5;
    assign Delta6_update =                  delta_multi_T6;
    
    always @(*) begin
        if(idle) begin //load
            L_next = 'd0;
            gamma_next = 8'h01;;
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00, 8'h00, 8'h01};
            {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00, 8'h00, 8'h01};
        end else begin
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {Delta0_update, Delta1_update, Delta2_update, Delta3_update, Delta4_update, Delta5_update, Delta6_update};
            if(swap) begin
                L_next = K + 1 - L;
                gamma_next = delta;
                {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {Delta1, Delta2, Delta3, Delta4, Delta5, Delta6, 8'h00};                    
            end else begin
                L_next = L;
                gamma_next = gamma;
                {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6};  
            end
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            L <= `D 'd0;//4
            gamma <= `D 8'h00;
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            L <= `D L_next;
            gamma <= `D gamma_next;
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next};
            {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6} <= `D {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next};
        end
    end

    // icg u_icg_kes_lo(.clk(clk), .ena(done), .rstn(rstn), .gclk(kes_lo_clk));
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            rs_lambda0 <= `D 8'h00;
            rs_lambda1 <= `D 8'h00;
            rs_lambda2 <= `D 8'h00;
            rs_omega0  <= `D 8'h00;
            rs_omega1  <= `D 8'h00;
        end else if(done) begin
            rs_lambda0 <= `D Delta2_next;
            rs_lambda1 <= `D Delta3_next;
            rs_lambda2 <= `D Delta4_next;
            rs_omega0  <= `D Delta0_next; //omegah0
            rs_omega1  <= `D Delta1_next; //omegah1
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            kes_done <= `D 0;
        end else if (done) begin
            kes_done <= `D 1;
        end else begin
            kes_done <= `D 0;
        end
    end

endmodule // end of kes_ribm1

// cseeh
module s3_cseeh(
    input  wire        clk,
    input  wire        rstn,
    input  wire        rs_ena,
    input  wire        csee_ena,
    input  wire [ 7:0] rs_lambda0,
    input  wire [ 7:0] rs_lambda1,
    input  wire [ 7:0] rs_lambda2,
    input  wire [ 7:0] rs_omega0,
    input  wire [ 7:0] rs_omega1,

    output wire        csee_in_process,
    output wire [63:0] rs_error_data,
    output wire [11:0] rs_error_sync,
    output reg         rs_decode_fail
);
    localparam ALPHA1 = 8'd2, ALPHA2 = 8'd4, ALPHA3 = 8'd8, ALPHA4 = 8'd16, ALPHA5 = 8'd32, ALPHA6 = 8'd64, ALPHA7 = 8'd128, ALPHA8 = 8'd29;
    localparam /*ALPHA2  = 8'd4, ALPHA4  = 8'd16, ALPHA6  = 8'd64, ALPHA8  = 8'd29,*/ ALPHA10 = 8'd116, ALPHA12 = 8'd205, ALPHA14 = 8'd19, ALPHA16 = 8'd76;
    localparam /*ALPHA4  = 8'd16, ALPHA8  = 8'd29, ALPHA12 = 8'd205, ALPHA16 = 8'd76, ALPHA20 = 8'd180,*/ ALPHA24 = 8'd143, ALPHA28 = 8'd24, ALPHA32 = 8'd157;
    localparam /*ALPHA5  = 8'd32, ALPHA10 = 8'd116,*/ ALPHA15 = 8'd38, ALPHA20 = 8'd180, ALPHA25 = 8'd3, ALPHA30 = 8'd96, ALPHA35 = 8'd156, ALPHA40 = 8'd106;
    localparam ALPHA58 = 8'd105, ALPHA59 = 8'd210, ALPHA60 = 8'd185, ALPHA61 = 8'd111, ALPHA62 = 8'd222, ALPHA63 = 8'd161, ALPHA64 = 8'd95, ALPHA65 = 8'd190;
    localparam ALPHA116= 8'd248, ALPHA118= 8'd199, ALPHA120= 8'd59, ALPHA122= 8'd236, ALPHA124= 8'd151, ALPHA126= 8'd102, ALPHA128= 8'd133, ALPHA130= 8'd46;
    localparam ALPHA232 = 8'd247, ALPHA236 = 8'd203, ALPHA240 = 8'd44, ALPHA244 = 8'd250, ALPHA248 = 8'd27, ALPHA252 = 8'd173, ALPHA256 = 8'd2, ALPHA260 = 8'd32;
    localparam ALPHA290 = 8'd156, ALPHA295 = 8'd106, ALPHA300 = 8'd193, ALPHA305 = 8'd5, ALPHA310 = 8'd160, ALPHA315 = 8'd185, ALPHA320 = 8'd190, ALPHA325 = 8'd94;
    //localparam ALPHA35 = 8'd156, ALPHA40 = 8'd106, ALPHA45 = 8'd193, ALPHA50 = 8'd5, ALPHA55 = 8'd160, ALPHA60 = 8'd185, ALPHA65 = 8'd190, ALPHA70 = 8'd94;
    localparam ALPHA250 = 8'd108, ALPHA251 = 8'd216, /*ALPHA252 = 8'd173,*/ ALPHA253 = 8'd71, ALPHA254 = 8'd142, ALPHA255 = 8'd1;
    localparam ALPHA500 = 8'd233, ALPHA502 = 8'd131, ALPHA504 = 8'd54, ALPHA506 = 8'd216, ALPHA508 = 8'd71, ALPHA510 = 8'd1;
    localparam ALPHA1000 = 8'd235, ALPHA1004 = 8'd22, ALPHA1008 = 8'd125, ALPHA1012 = 8'd131, ALPHA1016 = 8'd216, ALPHA1020 = 8'd1;
    //localparam ALPHA235 = 8'd235,  ALPHA239 = 8'd22,  ALPHA243 = 8'd125,  ALPHA247 = 8'd131,  ALPHA251 = 8'd216,  ALPHA255 = 8'd1;
    localparam ALPHA1250 = 8'd244, ALPHA1255 = 8'd235, ALPHA1260 = 8'd44, ALPHA1265 = 8'd233, ALPHA1270 = 8'd108, ALPHA1275 = 8'd1;
    //localparam ALPHA230 = 8'd244, ALPHA235 = 8'd235, ALPHA240 = 8'd44, ALPHA245 = 8'd233, ALPHA250 = 8'd108, ALPHA255 = 8'd1;
    localparam ITERATION='d24;

    reg [4:0] counter_it;

    reg [7:0] error_count;

    wire error_flag_0;
    wire error_flag_1;
    wire error_flag_2;
    wire error_flag_3;
    wire error_flag_4;
    wire error_flag_5;
    wire error_flag_6;
    wire error_flag_7;
    wire [7:0] error_data_0;
    wire [7:0] error_data_1;
    wire [7:0] error_data_2;
    wire [7:0] error_data_3;
    wire [7:0] error_data_4;
    wire [7:0] error_data_5;
    wire [7:0] error_data_6;
    wire [7:0] error_data_7;

    wire error_flag_192;
    wire error_flag_193;
    wire error_flag_194;
    wire error_flag_195;
    wire error_flag_196;
    wire error_flag_197;
    wire [7:0] error_data_192;
    wire [7:0] error_data_193;
    wire [7:0] error_data_194;
    wire [7:0] error_data_195;
    wire [7:0] error_data_196;
    wire [7:0] error_data_197;

    reg  [7:0] l1_multi_a1_p8;
    reg  [7:0] l2_multi_a2_p8;
    reg  [7:0] o0_multi_a0_p8;
    reg  [7:0] o1_multi_a1_p8;
    wire [7:0] l1_multi_a1_p8_next;
    wire [7:0] l2_multi_a2_p8_next;
    wire [7:0] o0_multi_a0_p8_next;
    wire [7:0] o1_multi_a1_p8_next;

    wire [7:0] mux_lambda1;
    wire [7:0] mux_lambda2;
    wire [7:0] mux_omega0;
    wire [7:0] mux_omega1;

    wire [7:0] mux_lam1_a0;
    wire [7:0] mux_lam1_a1;
    wire [7:0] mux_lam1_a2;
    wire [7:0] mux_lam1_a3;
    wire [7:0] mux_lam1_a4;
    wire [7:0] mux_lam1_a5;
    wire [7:0] mux_lam1_a6;
    wire [7:0] mux_lam1_a7;
    wire [7:0] mux_lam2_a0;
    wire [7:0] mux_lam2_a1;
    wire [7:0] mux_lam2_a2;
    wire [7:0] mux_lam2_a3;
    wire [7:0] mux_lam2_a4;
    wire [7:0] mux_lam2_a5;
    wire [7:0] mux_lam2_a6;
    wire [7:0] mux_lam2_a7;
    wire [7:0] mux_ome0_a0;
    wire [7:0] mux_ome0_a1;
    wire [7:0] mux_ome0_a2;
    wire [7:0] mux_ome0_a3;
    wire [7:0] mux_ome0_a4;
    wire [7:0] mux_ome0_a5;
    wire [7:0] mux_ome0_a6;
    wire [7:0] mux_ome0_a7;
    wire [7:0] mux_ome1_a0;
    wire [7:0] mux_ome1_a1;
    wire [7:0] mux_ome1_a2;
    wire [7:0] mux_ome1_a3;
    wire [7:0] mux_ome1_a4;
    wire [7:0] mux_ome1_a5;
    wire [7:0] mux_ome1_a6;
    wire [7:0] mux_ome1_a7;
    
    wire csee_idle;
    wire csee_init;
    wire csee_keep;
    wire csee_done;
    reg  csee_done_d1;
    reg  csee_done_d2;
    
    assign csee_idle = (counter_it == 'd0   );
    assign csee_init = (csee_idle & csee_ena);
    assign csee_keep = ~csee_idle;
    assign csee_done = (counter_it == ITERATION-'d1);

    assign csee_in_process = csee_init | csee_keep;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            counter_it <= `D 'd0;
        end else if(csee_done) begin
            counter_it <= `D 'd0;
        end else if(csee_in_process) begin
            counter_it <= `D counter_it + 'd1;
        end else begin
            counter_it <= `D counter_it;
        end
    end

    icg u_icg_csee_lo_next(.clk(clk), .ena(csee_in_process), .rstn(rstn), .gclk(csee_in_process_clk));
    always @(posedge csee_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            l1_multi_a1_p8 <= `D 'h00;
            l2_multi_a2_p8 <= `D 'h00;
            o0_multi_a0_p8 <= `D 'h00;
            o1_multi_a1_p8 <= `D 'h00;
        end else begin
            l1_multi_a1_p8 <= `D l1_multi_a1_p8_next;
            l2_multi_a2_p8 <= `D l2_multi_a2_p8_next;
            o0_multi_a0_p8 <= `D o0_multi_a0_p8_next;
            o1_multi_a1_p8 <= `D o1_multi_a1_p8_next;
        end
    end

    assign mux_lambda1  = csee_init ? rs_lambda1 : csee_keep ? l1_multi_a1_p8 : 'h00;
    assign mux_lambda2  = csee_init ? rs_lambda2 : csee_keep ? l2_multi_a2_p8 : 'h00;
    assign mux_omega0   = csee_init ? rs_omega0  : csee_keep ? o0_multi_a0_p8 : 'h00;
    assign mux_omega1   = csee_init ? rs_omega1  : csee_keep ? o1_multi_a1_p8 : 'h00;

    assign mux_lam1_a0 = csee_init ? ALPHA58  : ALPHA1 ;
    assign mux_lam1_a1 = csee_init ? ALPHA59  : ALPHA2 ;
    assign mux_lam1_a2 = csee_init ? ALPHA60  : ALPHA3 ;
    assign mux_lam1_a3 = csee_init ? ALPHA61  : ALPHA4 ;
    assign mux_lam1_a4 = csee_init ? ALPHA62  : ALPHA5 ;
    assign mux_lam1_a5 = csee_init ? ALPHA63  : ALPHA6 ;
    assign mux_lam1_a6 = csee_init ? ALPHA64  : ALPHA7 ;
    assign mux_lam1_a7 = csee_init ? ALPHA65  : ALPHA8 ;
    assign mux_lam2_a0 = csee_init ? ALPHA116 : ALPHA2 ;
    assign mux_lam2_a1 = csee_init ? ALPHA118 : ALPHA4 ;
    assign mux_lam2_a2 = csee_init ? ALPHA120 : ALPHA6 ;
    assign mux_lam2_a3 = csee_init ? ALPHA122 : ALPHA8 ;
    assign mux_lam2_a4 = csee_init ? ALPHA124 : ALPHA10;
    assign mux_lam2_a5 = csee_init ? ALPHA126 : ALPHA12;
    assign mux_lam2_a6 = csee_init ? ALPHA128 : ALPHA14;
    assign mux_lam2_a7 = csee_init ? ALPHA130 : ALPHA16;
    assign mux_ome0_a0 = csee_init ? ALPHA232 : ALPHA4 ;
    assign mux_ome0_a1 = csee_init ? ALPHA236 : ALPHA8 ;
    assign mux_ome0_a2 = csee_init ? ALPHA240 : ALPHA12;
    assign mux_ome0_a3 = csee_init ? ALPHA244 : ALPHA16;
    assign mux_ome0_a4 = csee_init ? ALPHA248 : ALPHA20;
    assign mux_ome0_a5 = csee_init ? ALPHA252 : ALPHA24;
    assign mux_ome0_a6 = csee_init ? ALPHA256 : ALPHA28;
    assign mux_ome0_a7 = csee_init ? ALPHA260 : ALPHA32;
    assign mux_ome1_a0 = csee_init ? ALPHA290 : ALPHA5 ;
    assign mux_ome1_a1 = csee_init ? ALPHA295 : ALPHA10;
    assign mux_ome1_a2 = csee_init ? ALPHA300 : ALPHA15;
    assign mux_ome1_a3 = csee_init ? ALPHA305 : ALPHA20;
    assign mux_ome1_a4 = csee_init ? ALPHA310 : ALPHA25;
    assign mux_ome1_a5 = csee_init ? ALPHA315 : ALPHA30;
    assign mux_ome1_a6 = csee_init ? ALPHA320 : ALPHA35;
    assign mux_ome1_a7 = csee_init ? ALPHA325 : ALPHA40;

    s3_cseeh_one u_s3_cseeh_one_0 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a0), .lam_alpha2(mux_lam2_a0), .ome_alpha0(mux_ome0_a0), .ome_alpha1(mux_ome1_a0), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_0), .error_data(error_data_0));
    s3_cseeh_one u_s3_cseeh_one_1 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a1), .lam_alpha2(mux_lam2_a1), .ome_alpha0(mux_ome0_a1), .ome_alpha1(mux_ome1_a1), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_1), .error_data(error_data_1));
    s3_cseeh_one u_s3_cseeh_one_2 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a2), .lam_alpha2(mux_lam2_a2), .ome_alpha0(mux_ome0_a2), .ome_alpha1(mux_ome1_a2), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_2), .error_data(error_data_2));
    s3_cseeh_one u_s3_cseeh_one_3 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a3), .lam_alpha2(mux_lam2_a3), .ome_alpha0(mux_ome0_a3), .ome_alpha1(mux_ome1_a3), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_3), .error_data(error_data_3));
    s3_cseeh_one u_s3_cseeh_one_4 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a4), .lam_alpha2(mux_lam2_a4), .ome_alpha0(mux_ome0_a4), .ome_alpha1(mux_ome1_a4), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_4), .error_data(error_data_4));
    s3_cseeh_one u_s3_cseeh_one_5 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a5), .lam_alpha2(mux_lam2_a5), .ome_alpha0(mux_ome0_a5), .ome_alpha1(mux_ome1_a5), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_5), .error_data(error_data_5));
    s3_cseeh_one u_s3_cseeh_one_6 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a6), .lam_alpha2(mux_lam2_a6), .ome_alpha0(mux_ome0_a6), .ome_alpha1(mux_ome1_a6), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_6), .error_data(error_data_6));
    s3_cseeh_one u_s3_cseeh_one_7 (.cseeh_one_ena(csee_in_process), .lam_alpha1(mux_lam1_a7), .lam_alpha2(mux_lam2_a7), .ome_alpha0(mux_ome0_a7), .ome_alpha1(mux_ome1_a7), .rs_lambda0(rs_lambda0), .rs_lambda1(mux_lambda1), .rs_lambda2(mux_lambda2), .rs_omega0(mux_omega0), .rs_omega1(mux_omega1), .error_flag(error_flag_7), .error_data(error_data_7), 
                                   .l1_multi_a1(l1_multi_a1_p8_next), .l2_multi_a2(l2_multi_a2_p8_next), .o0_multi_a0(o0_multi_a0_p8_next), .o1_multi_a1(o1_multi_a1_p8_next));

    s3_cseeh_one u_s3_cseeh_one_192 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA250), .lam_alpha2(ALPHA500), .ome_alpha0(ALPHA1000), .ome_alpha1(ALPHA1250), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_192), .error_data(error_data_192));
    s3_cseeh_one u_s3_cseeh_one_193 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA251), .lam_alpha2(ALPHA502), .ome_alpha0(ALPHA1004), .ome_alpha1(ALPHA1255), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_193), .error_data(error_data_193));
    s3_cseeh_one u_s3_cseeh_one_194 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA252), .lam_alpha2(ALPHA504), .ome_alpha0(ALPHA1008), .ome_alpha1(ALPHA1260), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_194), .error_data(error_data_194));
    s3_cseeh_one u_s3_cseeh_one_195 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA253), .lam_alpha2(ALPHA506), .ome_alpha0(ALPHA1012), .ome_alpha1(ALPHA1265), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_195), .error_data(error_data_195));
    s3_cseeh_one u_s3_cseeh_one_196 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA254), .lam_alpha2(ALPHA508), .ome_alpha0(ALPHA1016), .ome_alpha1(ALPHA1270), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_196), .error_data(error_data_196));
    s3_cseeh_one u_s3_cseeh_one_197 (.cseeh_one_ena(csee_init), .lam_alpha1(ALPHA255), .lam_alpha2(ALPHA510), .ome_alpha0(ALPHA1020), .ome_alpha1(ALPHA1275), .rs_lambda0(rs_lambda0), .rs_lambda1(rs_lambda1), .rs_lambda2(rs_lambda2), .rs_omega0(rs_omega0), .rs_omega1(rs_omega1), .error_flag(error_flag_197), .error_data(error_data_197));

    assign rs_error_data = {error_data_0, error_data_1, error_data_2, error_data_3, error_data_4, error_data_5, error_data_6, error_data_7};
    assign rs_error_sync = {error_data_192[3:0], error_data_193};

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            csee_done_d1 <= `D 'd0;
            csee_done_d2 <= `D 'd0;
        end else begin
            csee_done_d1 <= `D csee_done;
            csee_done_d2 <= `D csee_done_d1;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            error_count <= `D 'd0;
        end else if(csee_init) begin
            error_count <= `D error_count + (((error_flag_0+error_flag_1)+(error_flag_2+error_flag_3))
                                          + ((error_flag_4+error_flag_5)+(error_flag_6+error_flag_7)))
                                          + (((error_flag_192+error_flag_193)+(error_flag_194+error_flag_195))
                                          + (error_flag_196+error_flag_197));
        end else if(csee_keep) begin
            error_count <= `D error_count + (((error_flag_0+error_flag_1)+(error_flag_2+error_flag_3))
                                          + ((error_flag_4+error_flag_5)+(error_flag_6+error_flag_7)));
        end else if(csee_done_d2 & !rs_decode_fail) begin
            error_count <= `D 'd0;
        end else begin
            error_count <= `D error_count;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rs_decode_fail <= `D 'd0;
        end else if(!rs_ena) begin
            rs_decode_fail <= `D 'd0;
        end else if(csee_in_process | csee_done_d1) begin
            rs_decode_fail <= `D ((csee_done_d1 & error_count == 'd0) | error_count > 'd2);
        end else begin
            rs_decode_fail <= `D rs_decode_fail;
        end
    end

endmodule // end of cseeh

module s3_cseeh_one(
    input wire       cseeh_one_ena,
    input wire [7:0] lam_alpha1,
    input wire [7:0] lam_alpha2,
    input wire [7:0] ome_alpha0,
    input wire [7:0] ome_alpha1,
    input wire [7:0] rs_lambda0,
    input wire [7:0] rs_lambda1,
    input wire [7:0] rs_lambda2,
    input wire [7:0] rs_omega0,
    input wire [7:0] rs_omega1,

    output wire       error_flag,
    output wire [7:0] error_data,
    output wire [7:0] l1_multi_a1,
    output wire [7:0] l2_multi_a2,
    output wire [7:0] o0_multi_a0,
    output wire [7:0] o1_multi_a1
);

    wire [7:0] l1_x_a1;
    wire [7:0] l2_x_a2;
    wire [7:0] o0_x_a0;
    wire [7:0] o1_x_a1;
    wire [7:0] l1_x_a1_inv;
    wire [7:0] error_value;
    wire       sum_check;

    gf2m8_multi u_gf2m8_multi_l1al( .x(rs_lambda1), .y(lam_alpha1), .z(l1_x_a1) );
    gf2m8_multi u_gf2m8_multi_l2a2( .x(rs_lambda2), .y(lam_alpha2), .z(l2_x_a2) );
    gf2m8_multi u_gf2m8_multi_o0a0( .x(rs_omega0 ), .y(ome_alpha0), .z(o0_x_a0) );
    gf2m8_multi u_gf2m8_multi_o1a1( .x(rs_omega1 ), .y(ome_alpha1), .z(o1_x_a1) );

    gf2m8_inverse u_gf2m8_inverse_l1a1i( .b(l1_x_a1), .b_inv(l1_x_a1_inv) );

    gf2m8_multi u_gf2m8_multi_errv( .x(o0_x_a0 ^ o1_x_a1), .y(l1_x_a1_inv), .z(error_value) );

    assign sum_check = ( (rs_lambda0 ^ l1_x_a1 ^ l2_x_a2) == 0 );

    assign error_flag = cseeh_one_ena & sum_check;
    assign error_data = {8{error_flag}} & error_value;
    assign l1_multi_a1 = {8{cseeh_one_ena}} & l1_x_a1;
    assign l2_multi_a2 = {8{cseeh_one_ena}} & l2_x_a2;
    assign o0_multi_a0 = {8{cseeh_one_ena}} & o0_x_a0;
    assign o1_multi_a1 = {8{cseeh_one_ena}} & o1_x_a1;

endmodule

// fifo
module rs_fifo (
    input wire        clk,
    input wire        rstn,
    input wire        push_data_ena,
    input wire [63:0] rs_data0,
    input wire [63:0] rs_data1,
    input wire        data_last0,
    input wire        data_last1,

    input wire        rs_errdata_vld,
    input wire [63:0] rs_errdata,
    input wire        rs_errsync_vld,
    input wire [11:0] rs_errsync,
    input wire        pop_data_ena,

    output reg        rs_pop_data_vld,
    output reg [63:0] rs_pop_data,
    output reg        rs_pop_isos
);
    //======================== common used logics ========================//
    wire        data_last;
    wire [11:0] rs_data_syncbit;
    wire        pop_data_end;

    assign data_last       = data_last0 | data_last1;
    assign rs_data_syncbit = data_last1 ? rs_data1[59:48] : rs_data0[59:48];
    assign pop_data_end    = ~pop_data_ena & rs_pop_data_vld;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            rs_pop_data_vld <= `D 'd0;
        end else begin
            rs_pop_data_vld <= `D pop_data_ena;
        end
    end
    //======================== data fifo logics ========================//
    reg     [63:0] data_ram      [0:31];
    reg     [ 5:0] data_wr_ptr;
    reg     [ 5:0] data_aw_ptr;
    reg     [ 5:0] data_rd_ptr;
    wire    [ 4:0] data_wr_addr;
    wire    [ 4:0] data_aw_addr;
    wire    [ 4:0] data_rd_addr;
    wire           data_wr_full;
    wire           data_aw_empty;
    wire           data_rd_empty;
    integer        i; //used for initializing data_ram

    assign data_wr_addr  = data_wr_ptr[4:0];
    assign data_aw_addr  = data_aw_ptr[4:0];
    assign data_rd_addr  = data_rd_ptr[4:0];
    assign data_wr_full  = data_wr_ptr == {~data_rd_ptr[5], data_rd_ptr[4:0]};
    assign data_aw_empty = data_aw_ptr == data_wr_ptr;
    assign data_rd_empty = data_rd_ptr == data_wr_ptr;

    always @(posedge clk) begin
        if (!rstn) begin
            data_wr_ptr <= `D 'b0;
            data_aw_ptr <= `D 'b0;
            for (i = 0; i < 32; i = i + 1) begin : reset_data_ram
                data_ram[i] <= `D {64{1'b0}};
            end
        end else begin
            if (push_data_ena & !data_last0 & !data_wr_full) begin
                data_wr_ptr            <= `D data_wr_ptr + 'b1;
                data_ram[data_wr_addr] <= `D rs_data0;
            end
            if (rs_errdata_vld & !data_aw_empty) begin
                data_aw_ptr            <= `D data_aw_ptr + 'b1;
                data_ram[data_aw_addr] <= `D data_ram[data_aw_addr] ^ rs_errdata;
            end else if (pop_data_end) begin
                data_aw_ptr            <= `D data_rd_ptr;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            data_rd_ptr <= `D 'b0;
            rs_pop_data <= `D {64{1'b0}};
        end else if (pop_data_ena & !data_rd_empty) begin
            data_rd_ptr <= `D data_rd_ptr + 'b1;
            rs_pop_data <= `D data_ram[data_rd_addr];
        end else begin
            data_rd_ptr <= `D data_rd_ptr;
            rs_pop_data <= `D rs_pop_data;
        end
    end
    //======================== isos fifo logics ========================//
    reg  [11:0] isos_ram         [0:1];
    reg  [ 1:0] isos_wr_ptr;
    reg  [ 1:0] isos_aw_ptr;
    reg  [ 1:0] isos_rd_ptr;
    wire        isos_wr_full;
    wire        isos_aw_empty;
    wire        isos_rd_empty;
    reg  [ 4:0] counter_pop_isos;
    wire [ 3:0] sync_bit_loc;

    assign isos_wr_full  = isos_wr_ptr == {~isos_rd_ptr[1], isos_rd_ptr[0]};
    assign isos_aw_empty = isos_aw_ptr == isos_wr_ptr;
    assign isos_rd_empty = isos_rd_ptr == isos_wr_ptr;

    always @(posedge clk) begin
        if (!rstn) begin
            isos_wr_ptr <= `D 'b0;
            isos_aw_ptr <= `D 'b0;
            isos_ram[0] <= `D 'b0;
            isos_ram[1] <= `D 'b0;
        end else begin
            if (push_data_ena & data_last & !isos_wr_full) begin
                isos_wr_ptr              <= `D isos_wr_ptr + 'b1;
                isos_ram[isos_wr_ptr[0]] <= `D rs_data_syncbit;
            end
            if (rs_errsync_vld & !isos_aw_empty) begin
                isos_aw_ptr              <= `D isos_aw_ptr + 'b1;
                isos_ram[isos_aw_ptr[0]] <= `D isos_ram[isos_aw_ptr[0]] ^ rs_errsync;
            end else if (pop_data_end) begin
                isos_aw_ptr            <= `D isos_rd_ptr;
            end
        end
    end

    always @(posedge clk) begin
        if (!rstn) begin
            isos_rd_ptr      <= `D 'b0;
            counter_pop_isos <= `D 'd0;
        end else if (counter_pop_isos == 'd23) begin
            isos_rd_ptr      <= `D isos_rd_ptr + 'b1;
            counter_pop_isos <= `D 'd0;
        end else if (pop_data_ena & !isos_rd_empty) begin
            isos_rd_ptr      <= `D isos_rd_ptr;
            counter_pop_isos <= `D counter_pop_isos + 'd1;
        end else begin
            isos_rd_ptr      <= `D isos_rd_ptr;
            counter_pop_isos <= `D counter_pop_isos;
        end
    end

    assign sync_bit_loc = counter_pop_isos[4:1];

    always @(posedge clk) begin
        if (!rstn) begin
            rs_pop_isos <= `D 'b0;
        end else if (pop_data_ena & !isos_rd_empty) begin
            rs_pop_isos <= `D isos_ram[isos_rd_ptr[0]]['d11-sync_bit_loc];
        end else begin
            rs_pop_isos <= `D 'b0;
        end
    end

endmodule // end of fifo



/**********************************gf2m8 multi************************************/
module gf2m8_multi (
    input  wire [7:0] x,
    input  wire [7:0] y,
    output wire [7:0] z
);
    assign z[0] = ^{y[0] & x[0], 
                    y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                    y[5] & x[7], y[6] & x[6], y[7] & x[5],  //5-7
                    y[6] & x[7], y[7] & x[6],  //6-7
                    y[7] & x[7]};  //7
    assign z[1] = ^{y[0] & x[1], y[1] & x[0], 
                    y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                    y[6] & x[7], y[7] & x[6],  //6-7
                    y[7] & x[7]};  //7
    assign z[2] = ^{y[0] & x[2], y[1] & x[1], y[2] & x[0], 
                    y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                    y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3],  //3-7
                    y[5] & x[7], y[6] & x[6], y[7] & x[5],  //5-7
                    y[6] & x[7], y[7] & x[6]};  //6-7
    assign z[3] = ^{y[0] & x[3], y[1] & x[2], y[2] & x[1], y[3] & x[0], 
                    y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                    y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2],  //2-7
                    y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4],  //4-7
                    y[5] & x[7], y[6] & x[6], y[7] & x[5]};  //5-7
    assign z[4] = ^{y[0] & x[4], y[1] & x[3], y[2] & x[2], y[3] & x[1], y[4] & x[0], 
                    y[1] & x[7], y[2] & x[6], y[3] & x[5], y[4] & x[4], y[5] & x[3], y[6] & x[2], y[7] & x[1], //1-7
                    y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2],  //2-7
                    y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3],  //3-7
                    y[7] & x[7]};  //7
    assign z[5] = ^{y[0] & x[5], y[1] & x[4], y[2] & x[3], y[3] & x[2], y[4] & x[1], y[5] & x[0], 
                    y[2] & x[7], y[3] & x[6], y[4] & x[5], y[5] & x[4], y[6] & x[3], y[7] & x[2], //2-7
                    y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3],  //3-7
                    y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4]};  //4-7
    assign z[6] = ^{y[0] & x[6], y[1] & x[5], y[2] & x[4], y[3] & x[3], y[4] & x[2], y[5] & x[1], y[6] & x[0], 
                    y[3] & x[7], y[4] & x[6], y[5] & x[5], y[6] & x[4], y[7] & x[3], //3-7
                    y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4],  //4-7
                    y[5] & x[7], y[6] & x[6], y[7] & x[5]};  //5-7
    assign z[7] = ^{y[0] & x[7], y[1] & x[6], y[2] & x[5], y[3] & x[4], y[4] & x[3], y[5] & x[2], y[6] & x[1], y[7] & x[0], 
                    y[4] & x[7], y[5] & x[6], y[6] & x[5], y[7] & x[4], //4-7
                    y[5] & x[7], y[6] & x[6], y[7] & x[5],  //5-7
                    y[6] & x[7], y[7] & x[6]};  //6-7

endmodule

/**********************************gf2m8 inverse************************************/
module gf2m8_inverse (
    input  wire [7:0] b,
    output reg  [7:0] b_inv
);
    always @(*) begin
        case (b)
            8'd1:    b_inv = 8'd1;  // 2^255 2^0
            8'd2:    b_inv = 8'd142;  // 2^1
            8'd4:    b_inv = 8'd71;  // 2^2
            8'd8:    b_inv = 8'd173;  // 2^3
            8'd16:   b_inv = 8'd216;  // 2^4
            8'd32:   b_inv = 8'd108;  // 2^5
            8'd64:   b_inv = 8'd54;  // 2^6
            8'd128:  b_inv = 8'd27;  // 2^7
            8'd29:   b_inv = 8'd131;  // 2^8
            8'd58:   b_inv = 8'd207;  // 2^9
            8'd116:  b_inv = 8'd233;  // 2^10
            8'd232:  b_inv = 8'd250;  // 2^11
            8'd205:  b_inv = 8'd125;  // 2^12
            8'd135:  b_inv = 8'd176;  // 2^13
            8'd19:   b_inv = 8'd88;  // 2^14
            8'd38:   b_inv = 8'd44;  // 2^15
            8'd76:   b_inv = 8'd22;  // 2^16
            8'd152:  b_inv = 8'd11;  // 2^17
            8'd45:   b_inv = 8'd139;  // 2^18
            8'd90:   b_inv = 8'd203;  // 2^19
            8'd180:  b_inv = 8'd235;  // 2^20
            8'd117:  b_inv = 8'd251;  // 2^21
            8'd234:  b_inv = 8'd243;  // 2^22
            8'd201:  b_inv = 8'd247;  // 2^23
            8'd143:  b_inv = 8'd245;  // 2^24
            8'd3:    b_inv = 8'd244;  // 2^25
            8'd6:    b_inv = 8'd122;  // 2^26
            8'd12:   b_inv = 8'd61;  // 2^27
            8'd24:   b_inv = 8'd144;  // 2^28
            8'd48:   b_inv = 8'd72;  // 2^29
            8'd96:   b_inv = 8'd36;  // 2^30
            8'd192:  b_inv = 8'd18;  // 2^31
            8'd157:  b_inv = 8'd9;  // 2^32
            8'd39:   b_inv = 8'd138;  // 2^33
            8'd78:   b_inv = 8'd69;  // 2^34
            8'd156:  b_inv = 8'd172;  // 2^35
            8'd37:   b_inv = 8'd86;  // 2^36
            8'd74:   b_inv = 8'd43;  // 2^37
            8'd148:  b_inv = 8'd155;  // 2^38
            8'd53:   b_inv = 8'd195;  // 2^39
            8'd106:  b_inv = 8'd239;  // 2^40
            8'd212:  b_inv = 8'd249;  // 2^41
            8'd181:  b_inv = 8'd242;  // 2^42
            8'd119:  b_inv = 8'd121;  // 2^43
            8'd238:  b_inv = 8'd178;  // 2^44
            8'd193:  b_inv = 8'd89;  // 2^45
            8'd159:  b_inv = 8'd162;  // 2^46
            8'd35:   b_inv = 8'd81;  // 2^47
            8'd70:   b_inv = 8'd166;  // 2^48
            8'd140:  b_inv = 8'd83;  // 2^49
            8'd5:    b_inv = 8'd167;  // 2^50
            8'd10:   b_inv = 8'd221;  // 2^51
            8'd20:   b_inv = 8'd224;  // 2^52
            8'd40:   b_inv = 8'd112;  // 2^53
            8'd80:   b_inv = 8'd56;  // 2^54
            8'd160:  b_inv = 8'd28;  // 2^55
            8'd93:   b_inv = 8'd14;  // 2^56
            8'd186:  b_inv = 8'd7;  // 2^57
            8'd105:  b_inv = 8'd141;  // 2^58
            8'd210:  b_inv = 8'd200;  // 2^59
            8'd185:  b_inv = 8'd100;  // 2^60
            8'd111:  b_inv = 8'd50;  // 2^61
            8'd222:  b_inv = 8'd25;  // 2^62
            8'd161:  b_inv = 8'd130;  // 2^63
            8'd95:   b_inv = 8'd65;  // 2^64
            8'd190:  b_inv = 8'd174;  // 2^65
            8'd97:   b_inv = 8'd87;  // 2^66
            8'd194:  b_inv = 8'd165;  // 2^67
            8'd153:  b_inv = 8'd220;  // 2^68
            8'd47:   b_inv = 8'd110;  // 2^69
            8'd94:   b_inv = 8'd55;  // 2^70
            8'd188:  b_inv = 8'd149;  // 2^71
            8'd101:  b_inv = 8'd196;  // 2^72
            8'd202:  b_inv = 8'd98;  // 2^73
            8'd137:  b_inv = 8'd49;  // 2^74
            8'd15:   b_inv = 8'd150;  // 2^75
            8'd30:   b_inv = 8'd75;  // 2^76
            8'd60:   b_inv = 8'd171;  // 2^77
            8'd120:  b_inv = 8'd219;  // 2^78
            8'd240:  b_inv = 8'd227;  // 2^79
            8'd253:  b_inv = 8'd255;  // 2^80
            8'd231:  b_inv = 8'd241;  // 2^81
            8'd211:  b_inv = 8'd246;  // 2^82
            8'd187:  b_inv = 8'd123;  // 2^83
            8'd107:  b_inv = 8'd179;  // 2^84
            8'd214:  b_inv = 8'd215;  // 2^85
            8'd177:  b_inv = 8'd229;  // 2^86
            8'd127:  b_inv = 8'd252;  // 2^87
            8'd254:  b_inv = 8'd126;  // 2^88
            8'd225:  b_inv = 8'd63;  // 2^89
            8'd223:  b_inv = 8'd145;  // 2^90
            8'd163:  b_inv = 8'd198;  // 2^91
            8'd91:   b_inv = 8'd99;  // 2^92
            8'd182:  b_inv = 8'd191;  // 2^93
            8'd113:  b_inv = 8'd209;  // 2^94
            8'd226:  b_inv = 8'd230;  // 2^95
            8'd217:  b_inv = 8'd115;  // 2^96
            8'd175:  b_inv = 8'd183;  // 2^97
            8'd67:   b_inv = 8'd213;  // 2^98
            8'd134:  b_inv = 8'd228;  // 2^99
            8'd17:   b_inv = 8'd114;  // 2^100
            8'd34:   b_inv = 8'd57;  // 2^101
            8'd68:   b_inv = 8'd146;  // 2^102
            8'd136:  b_inv = 8'd73;  // 2^103
            8'd13:   b_inv = 8'd170;  // 2^104
            8'd26:   b_inv = 8'd85;  // 2^105
            8'd52:   b_inv = 8'd164;  // 2^106
            8'd104:  b_inv = 8'd82;  // 2^107
            8'd208:  b_inv = 8'd41;  // 2^108
            8'd189:  b_inv = 8'd154;  // 2^109
            8'd103:  b_inv = 8'd77;  // 2^110
            8'd206:  b_inv = 8'd168;  // 2^111
            8'd129:  b_inv = 8'd84;  // 2^112
            8'd31:   b_inv = 8'd42;  // 2^113
            8'd62:   b_inv = 8'd21;  // 2^114
            8'd124:  b_inv = 8'd132;  // 2^115
            8'd248:  b_inv = 8'd66;  // 2^116
            8'd237:  b_inv = 8'd33;  // 2^117
            8'd199:  b_inv = 8'd158;  // 2^118
            8'd147:  b_inv = 8'd79;  // 2^119
            8'd59:   b_inv = 8'd169;  // 2^120
            8'd118:  b_inv = 8'd218;  // 2^121
            8'd236:  b_inv = 8'd109;  // 2^122
            8'd197:  b_inv = 8'd184;  // 2^123
            8'd151:  b_inv = 8'd92;  // 2^124
            8'd51:   b_inv = 8'd46;  // 2^125
            8'd102:  b_inv = 8'd23;  // 2^126
            8'd204:  b_inv = 8'd133;  // 2^127
            8'd133:  b_inv = 8'd204;  // 2^128
            8'd23:   b_inv = 8'd102;  // 2^129
            8'd46:   b_inv = 8'd51;  // 2^130
            8'd92:   b_inv = 8'd151;  // 2^131
            8'd184:  b_inv = 8'd197;  // 2^132
            8'd109:  b_inv = 8'd236;  // 2^133
            8'd218:  b_inv = 8'd118;  // 2^134
            8'd169:  b_inv = 8'd59;  // 2^135
            8'd79:   b_inv = 8'd147;  // 2^136
            8'd158:  b_inv = 8'd199;  // 2^137
            8'd33:   b_inv = 8'd237;  // 2^138
            8'd66:   b_inv = 8'd248;  // 2^139
            8'd132:  b_inv = 8'd124;  // 2^140
            8'd21:   b_inv = 8'd62;  // 2^141
            8'd42:   b_inv = 8'd31;  // 2^142
            8'd84:   b_inv = 8'd129;  // 2^143
            8'd168:  b_inv = 8'd206;  // 2^144
            8'd77:   b_inv = 8'd103;  // 2^145
            8'd154:  b_inv = 8'd189;  // 2^146
            8'd41:   b_inv = 8'd208;  // 2^147
            8'd82:   b_inv = 8'd104;  // 2^148
            8'd164:  b_inv = 8'd52;  // 2^149
            8'd85:   b_inv = 8'd26;  // 2^150
            8'd170:  b_inv = 8'd13;  // 2^151
            8'd73:   b_inv = 8'd136;  // 2^152
            8'd146:  b_inv = 8'd68;  // 2^153
            8'd57:   b_inv = 8'd34;  // 2^154
            8'd114:  b_inv = 8'd17;  // 2^155
            8'd228:  b_inv = 8'd134;  // 2^156
            8'd213:  b_inv = 8'd67;  // 2^157
            8'd183:  b_inv = 8'd175;  // 2^158
            8'd115:  b_inv = 8'd217;  // 2^159
            8'd230:  b_inv = 8'd226;  // 2^160
            8'd209:  b_inv = 8'd113;  // 2^161
            8'd191:  b_inv = 8'd182;  // 2^162
            8'd99:   b_inv = 8'd91;  // 2^163
            8'd198:  b_inv = 8'd163;  // 2^164
            8'd145:  b_inv = 8'd223;  // 2^165
            8'd63:   b_inv = 8'd225;  // 2^166
            8'd126:  b_inv = 8'd254;  // 2^167
            8'd252:  b_inv = 8'd127;  // 2^168
            8'd229:  b_inv = 8'd177;  // 2^169
            8'd215:  b_inv = 8'd214;  // 2^170
            8'd179:  b_inv = 8'd107;  // 2^171
            8'd123:  b_inv = 8'd187;  // 2^172
            8'd246:  b_inv = 8'd211;  // 2^173
            8'd241:  b_inv = 8'd231;  // 2^174
            8'd255:  b_inv = 8'd253;  // 2^175
            8'd227:  b_inv = 8'd240;  // 2^176
            8'd219:  b_inv = 8'd120;  // 2^177
            8'd171:  b_inv = 8'd60;  // 2^178
            8'd75:   b_inv = 8'd30;  // 2^179
            8'd150:  b_inv = 8'd15;  // 2^180
            8'd49:   b_inv = 8'd137;  // 2^181
            8'd98:   b_inv = 8'd202;  // 2^182
            8'd196:  b_inv = 8'd101;  // 2^183
            8'd149:  b_inv = 8'd188;  // 2^184
            8'd55:   b_inv = 8'd94;  // 2^185
            8'd110:  b_inv = 8'd47;  // 2^186
            8'd220:  b_inv = 8'd153;  // 2^187
            8'd165:  b_inv = 8'd194;  // 2^188
            8'd87:   b_inv = 8'd97;  // 2^189
            8'd174:  b_inv = 8'd190;  // 2^190
            8'd65:   b_inv = 8'd95;  // 2^191
            8'd130:  b_inv = 8'd161;  // 2^192
            8'd25:   b_inv = 8'd222;  // 2^193
            8'd50:   b_inv = 8'd111;  // 2^194
            8'd100:  b_inv = 8'd185;  // 2^195
            8'd200:  b_inv = 8'd210;  // 2^196
            8'd141:  b_inv = 8'd105;  // 2^197
            8'd7:    b_inv = 8'd186;  // 2^198
            8'd14:   b_inv = 8'd93;  // 2^199
            8'd28:   b_inv = 8'd160;  // 2^200
            8'd56:   b_inv = 8'd80;  // 2^201
            8'd112:  b_inv = 8'd40;  // 2^202
            8'd224:  b_inv = 8'd20;  // 2^203
            8'd221:  b_inv = 8'd10;  // 2^204
            8'd167:  b_inv = 8'd5;  // 2^205
            8'd83:   b_inv = 8'd140;  // 2^206
            8'd166:  b_inv = 8'd70;  // 2^207
            8'd81:   b_inv = 8'd35;  // 2^208
            8'd162:  b_inv = 8'd159;  // 2^209
            8'd89:   b_inv = 8'd193;  // 2^210
            8'd178:  b_inv = 8'd238;  // 2^211
            8'd121:  b_inv = 8'd119;  // 2^212
            8'd242:  b_inv = 8'd181;  // 2^213
            8'd249:  b_inv = 8'd212;  // 2^214
            8'd239:  b_inv = 8'd106;  // 2^215
            8'd195:  b_inv = 8'd53;  // 2^216
            8'd155:  b_inv = 8'd148;  // 2^217
            8'd43:   b_inv = 8'd74;  // 2^218
            8'd86:   b_inv = 8'd37;  // 2^219
            8'd172:  b_inv = 8'd156;  // 2^220
            8'd69:   b_inv = 8'd78;  // 2^221
            8'd138:  b_inv = 8'd39;  // 2^222
            8'd9:    b_inv = 8'd157;  // 2^223
            8'd18:   b_inv = 8'd192;  // 2^224
            8'd36:   b_inv = 8'd96;  // 2^225
            8'd72:   b_inv = 8'd48;  // 2^226
            8'd144:  b_inv = 8'd24;  // 2^227
            8'd61:   b_inv = 8'd12;  // 2^228
            8'd122:  b_inv = 8'd6;  // 2^229
            8'd244:  b_inv = 8'd3;  // 2^230
            8'd245:  b_inv = 8'd143;  // 2^231
            8'd247:  b_inv = 8'd201;  // 2^232
            8'd243:  b_inv = 8'd234;  // 2^233
            8'd251:  b_inv = 8'd117;  // 2^234
            8'd235:  b_inv = 8'd180;  // 2^235
            8'd203:  b_inv = 8'd90;  // 2^236
            8'd139:  b_inv = 8'd45;  // 2^237
            8'd11:   b_inv = 8'd152;  // 2^238
            8'd22:   b_inv = 8'd76;  // 2^239
            8'd44:   b_inv = 8'd38;  // 2^240
            8'd88:   b_inv = 8'd19;  // 2^241
            8'd176:  b_inv = 8'd135;  // 2^242
            8'd125:  b_inv = 8'd205;  // 2^243
            8'd250:  b_inv = 8'd232;  // 2^244
            8'd233:  b_inv = 8'd116;  // 2^245
            8'd207:  b_inv = 8'd58;  // 2^246
            8'd131:  b_inv = 8'd29;  // 2^247
            8'd27:   b_inv = 8'd128;  // 2^248
            8'd54:   b_inv = 8'd64;  // 2^249
            8'd108:  b_inv = 8'd32;  // 2^250
            8'd216:  b_inv = 8'd16;  // 2^251
            8'd173:  b_inv = 8'd8;  // 2^252
            8'd71:   b_inv = 8'd4;  // 2^253
            8'd142:  b_inv = 8'd2;  // 2^254
            default: b_inv = 8'd0;
        endcase
    end

endmodule

/**********************************     icg     ************************************/
module icg (
    input  clk,
    input  ena,
    input  rstn,
    output gclk
);
    reg gena;
    always @(rstn, clk, ena) begin
        if(!rstn) begin
            gena <= 'b0;
        end else if(!clk) begin
            gena <= ena;
        end else begin
            gena <= gena;
        end
    end
    assign gclk = gena & clk;
endmodule