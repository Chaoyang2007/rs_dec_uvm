`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/27 18:22:37
// Design Name: 
// Module Name: s3_cseeh
// Project Name: 
// Desription: for kes_ribm1/2
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File reated 2023/06/13 14:33:52
// Revision 0.01 - File reated 2023/10/18 16:22:41
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif

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

endmodule

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