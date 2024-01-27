`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_dcme1
// Project Name: 
// Desription: 5 cycles, CQ CR, 
// dcme1_state remained
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File reated 2023/06/02 13:57:31
// Revision 0.02 - File reated 2023/10/18 11:30:27
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`ifndef D
`define D #0.2
`endif

module s2_kes_dcme1(
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

    reg [4:0] dcme1_state;
    reg [4:0] dcme1_state_next;

    reg [2:0] deg_R;
    reg [2:0] deg_Q;

    reg [2:0] deg_R_next;
    reg [2:0] deg_Q_next;

    reg [7:0] reg_R0;
    reg [7:0] reg_R1;
    reg [7:0] reg_R2;
    reg [7:0] reg_R3;
    reg [7:0] reg_R4;

    reg [7:0] reg_Q0;
    reg [7:0] reg_Q1;
    reg [7:0] reg_Q2;
    reg [7:0] reg_Q3;
    reg [7:0] reg_Q4;

    reg [7:0] reg_L0;
    reg [7:0] reg_L1;
    reg [7:0] reg_L2;

    reg [7:0] reg_U0;
    reg [7:0] reg_U1;
    reg [7:0] reg_U2;

    reg [7:0] reg_R0_next;
    reg [7:0] reg_R1_next;
    reg [7:0] reg_R2_next;
    reg [7:0] reg_R3_next;
    reg [7:0] reg_R4_next;

    reg [7:0] reg_Q0_next;
    reg [7:0] reg_Q1_next;
    reg [7:0] reg_Q2_next;
    reg [7:0] reg_Q3_next;
    reg [7:0] reg_Q4_next;

    reg [7:0] reg_L0_next;
    reg [7:0] reg_L1_next;
    reg [7:0] reg_L2_next;

    reg [7:0] reg_U0_next;
    reg [7:0] reg_U1_next;
    reg [7:0] reg_U2_next;

    reg [2:0] CQ;
    reg [2:0] CR;
    reg [2:0] CQ_next;
    reg [2:0] CR_next;


    wire [7:0] msb_R;
    wire [7:0] msb_Q;

    wire [7:0] msb_R_multi_Q0;
    wire [7:0] msb_R_multi_Q1;
    wire [7:0] msb_R_multi_Q2;
    wire [7:0] msb_R_multi_Q3;
    wire [7:0] msb_R_multi_Q4;

    wire [7:0] msb_R_multi_U0;
    wire [7:0] msb_R_multi_U1;
    wire [7:0] msb_R_multi_U2;

    wire [7:0] msb_Q_multi_R0;
    wire [7:0] msb_Q_multi_R1;
    wire [7:0] msb_Q_multi_R2;
    wire [7:0] msb_Q_multi_R3;
    wire [7:0] msb_Q_multi_R4;

    wire [7:0] msb_Q_multi_L0;
    wire [7:0] msb_Q_multi_L1;
    wire [7:0] msb_Q_multi_L2;

    wire [7:0] mux_L0;
    wire [7:0] mux_L1;
    wire [7:0] mux_L2;

    wire [7:0] wire_P0;
    wire [7:0] wire_P1;
    wire [7:0] wire_P2;
    wire [7:0] wire_P3;
    wire [7:0] wire_P4;

    wire [7:0] wire_L0;
    wire [7:0] wire_L1;
    wire [7:0] wire_L2;

    wire idle;
    wire init;
    wire done;
    wire stop;
    wire shift;
    wire swap;
    wire kes_in_process;

    always @(*) begin
        case (dcme1_state)
            S0: dcme1_state_next = init ? S1 : S0;
            S1: dcme1_state_next = S2;
            S2: dcme1_state_next = S3;
            S3: dcme1_state_next = S4;
            S4: dcme1_state_next = S0;
            default: dcme1_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            dcme1_state <= `D S0;
        end else begin
            dcme1_state <= `D dcme1_state_next;
        end
    end

    assign idle  = dcme1_state[0];
    assign init  = kes_ena & idle;
    assign done  = dcme1_state[4]; // kes done
    assign stop  = deg_R < 'd2; // early termination
    assign shift_Q = msb_Q==8'h00; // right shift Q
    assign shift_R = msb_R==8'h00; // right shift R
    assign swap  = CQ == 'd0; // swap R Q and calculate

    assign kes_in_process = init | ~idle;
    
    assign msb_R = reg_R4;
    assign msb_Q = reg_Q4;

    assign mux_L0 = (~swap) ? reg_L0 : (CR==0) ? 8'h00  : (CR==1) ? 8'h00  : 8'h00;
    assign mux_L1 = (~swap) ? reg_L1 : (CR==0) ? reg_L0 : (CR==1) ? 8'h00  : 8'h00;
    assign mux_L2 = (~swap) ? reg_L2 : (CR==0) ? reg_L1 : (CR==1) ? reg_L0 : 8'h00;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(msb_R), .y(reg_Q0), .z(msb_R_multi_Q0) );
    gf2m8_multi u_gf2m8_multi_aq1 ( .x(msb_R), .y(reg_Q1), .z(msb_R_multi_Q1) );
    gf2m8_multi u_gf2m8_multi_aq2 ( .x(msb_R), .y(reg_Q2), .z(msb_R_multi_Q2) );
    gf2m8_multi u_gf2m8_multi_aq3 ( .x(msb_R), .y(reg_Q3), .z(msb_R_multi_Q3) );
    gf2m8_multi u_gf2m8_multi_aq4 ( .x(msb_R), .y(reg_Q4), .z(msb_R_multi_Q4) );

    gf2m8_multi u_gf2m8_multi_au0 ( .x(msb_R), .y(reg_U0), .z(msb_R_multi_U0) );
    gf2m8_multi u_gf2m8_multi_au1 ( .x(msb_R), .y(reg_U1), .z(msb_R_multi_U1) );
    gf2m8_multi u_gf2m8_multi_au2 ( .x(msb_R), .y(reg_U2), .z(msb_R_multi_U2) );

    gf2m8_multi u_gf2m8_multi_br0 ( .x(msb_Q), .y(reg_R0), .z(msb_Q_multi_R0) );
    gf2m8_multi u_gf2m8_multi_br1 ( .x(msb_Q), .y(reg_R1), .z(msb_Q_multi_R1) );
    gf2m8_multi u_gf2m8_multi_br2 ( .x(msb_Q), .y(reg_R2), .z(msb_Q_multi_R2) );
    gf2m8_multi u_gf2m8_multi_br3 ( .x(msb_Q), .y(reg_R3), .z(msb_Q_multi_R3) );
    gf2m8_multi u_gf2m8_multi_br4 ( .x(msb_Q), .y(reg_R4), .z(msb_Q_multi_R4) );

    gf2m8_multi u_gf2m8_multi_bl0 ( .x(msb_Q), .y(mux_L0), .z(msb_Q_multi_L0) );
    gf2m8_multi u_gf2m8_multi_bl1 ( .x(msb_Q), .y(mux_L1), .z(msb_Q_multi_L1) );
    gf2m8_multi u_gf2m8_multi_bl2 ( .x(msb_Q), .y(mux_L2), .z(msb_Q_multi_L2) );

    //R = (b·R − a·Q)·x
    assign wire_P0 = 8'h00;
    assign wire_P1 = msb_Q_multi_R0 ^ msb_R_multi_Q0;
    assign wire_P2 = msb_Q_multi_R1 ^ msb_R_multi_Q1;
    assign wire_P3 = msb_Q_multi_R2 ^ msb_R_multi_Q2;
    assign wire_P4 = msb_Q_multi_R3 ^ msb_R_multi_Q3;

    assign wire_L0 = msb_Q_multi_L0 ^ msb_R_multi_U0;
    assign wire_L1 = msb_Q_multi_L1 ^ msb_R_multi_U1;
    assign wire_L2 = msb_Q_multi_L2 ^ msb_R_multi_U2;

    always @(*) begin
        if(idle) begin //load
            CQ_next = 'd2;
            CR_next = 'd0;
            deg_R_next = 'd4;
            deg_Q_next = 'd3;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {8'h00, 8'h00, 8'h00, 8'h00, 8'h01};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {8'h00, rs_syn0, rs_syn1, rs_syn2, rs_syn3};
            {reg_L0_next, reg_L1_next, reg_L2_next} = {8'h00, 8'h00, 8'h00};
            {reg_U0_next, reg_U1_next, reg_U2_next} = {8'h00, 8'h01, 8'h00};
        end else if(!stop) begin
            if(shift_Q) begin
                CQ_next = CQ + 1;
                CR_next = CR;
                deg_R_next = deg_R;
                deg_Q_next = deg_Q - 'd1;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {8'h00, reg_Q0, reg_Q1, reg_Q2, reg_Q3};
                {reg_L0_next, reg_L1_next, reg_L2_next} = {reg_L0, reg_L1, reg_L2};
                {reg_U0_next, reg_U1_next, reg_U2_next} = {8'h00, reg_U0, reg_U1};
            end else if(shift_R) begin
                CQ_next = (CQ==0) ? 0 : CQ - 1;
                CR_next = (CQ==0) ? CR + 1 : CR;
                deg_R_next = deg_R - 'd1;
                deg_Q_next = deg_Q;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {8'h00, reg_R0, reg_R1, reg_R2, reg_R3};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4};
                {reg_L0_next, reg_L1_next, reg_L2_next} = {reg_L0, reg_L1, reg_L2};
                {reg_U0_next, reg_U1_next, reg_U2_next} = {reg_U0, reg_U1, reg_U2};
            end else if(swap) begin
                CQ_next = CQ + CR + 1;
                CR_next = 0;
                deg_R_next = deg_Q - 1;
                deg_Q_next = deg_R;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {wire_P0, wire_P1, wire_P2, wire_P3, wire_P4};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4};
                {reg_L0_next, reg_L1_next, reg_L2_next} = {wire_L0, wire_L1, wire_L2};
                {reg_U0_next, reg_U1_next, reg_U2_next} = (CR==2) ? {8'h00, 8'h00, reg_L0}  :
                                                          (CR==1) ? {8'h00, reg_L0, reg_L1} : {reg_L0, reg_L1, reg_L2};
            end else begin
                CQ_next = CQ - 1;
                CR_next = CR;
                deg_R_next = deg_R - 1;
                deg_Q_next = deg_Q;
                {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {wire_P0, wire_P1, wire_P2, wire_P3, wire_P4};
                {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4};
                {reg_L0_next, reg_L1_next, reg_L2_next} = {wire_L0, wire_L1, wire_L2};
                {reg_U0_next, reg_U1_next, reg_U2_next} = (CQ>1) ? {reg_U1, reg_U2, 8'h00} : {reg_U0, reg_U1, reg_U2};
            end
        end else begin
            CQ_next = CQ;
            CR_next = CR;
            deg_R_next = deg_R;
            deg_Q_next = deg_Q;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4};
            {reg_L0_next, reg_L1_next, reg_L2_next} = {reg_L0, reg_L1, reg_L2};
            {reg_U0_next, reg_U1_next, reg_U2_next} = {reg_U0, reg_U1, reg_U2};
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            CQ <= `D 'd0;
            CR <= `D 'd0;
            deg_R <= `D 8'h00;//4
            deg_Q <= `D 8'h00;//3
            {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_L0, reg_L1, reg_L2} <= `D {8'h00, 8'h00, 8'h00};
            {reg_U0, reg_U1, reg_U2} <= `D {8'h00, 8'h00, 8'h00};
        end else begin
            CQ <= `D CQ_next;
            CR <= `D CR_next;
            deg_R <= `D deg_R_next;
            deg_Q <= `D deg_Q_next;
            {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4} <= `D {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next};
            {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4} <= `D {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next};
            {reg_L0, reg_L1, reg_L2} <= `D {reg_L0_next, reg_L1_next, reg_L2_next};
            {reg_U0, reg_U1, reg_U2} <= `D {reg_U0_next, reg_U1_next, reg_U2_next};
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
            rs_lambda0 <= `D reg_L0_next;
            rs_lambda1 <= `D reg_L1_next;
            rs_lambda2 <= `D reg_L2_next;
            rs_omega0  <= `D reg_R3_next;
            rs_omega1  <= `D reg_R4_next;
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

endmodule
