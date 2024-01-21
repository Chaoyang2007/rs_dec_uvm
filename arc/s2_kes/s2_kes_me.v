`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_me
// Project Name: 
// Desription: unsure cycles, fixed, no shift (compared to dcme0)
// no me_state, stop when deg_*<t
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

module s2_kes_me(
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

    wire [7:0] msb_R;
    wire [7:0] msb_Q;
    wire [2:0] deg_P;
    wire [2:0] deg_diff;

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

    wire [7:0] wire_P0;
    wire [7:0] wire_P1;
    wire [7:0] wire_P2;
    wire [7:0] wire_P3;
    wire [7:0] wire_P4;

    wire [7:0] wire_L0;
    wire [7:0] wire_L1;
    wire [7:0] wire_L2;

    wire [7:0] mux_Q0;
    wire [7:0] mux_Q1;
    wire [7:0] mux_Q2;
    wire [7:0] mux_Q3;
    wire [7:0] mux_Q4;
    wire [7:0] mux_U0;
    wire [7:0] mux_U1;
    wire [7:0] mux_U2;

    wire r4nz, r3nz, r2nz, r1nz, r0nz;
    wire q3nz, q2nz, q1nz, q0nz;
    wire p3nz, p2nz, p1nz, p0nz;

    reg  idle;
    wire init;
    wire done;
    wire swap;
    wire kes_in_process;

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            idle <= `D 'b1;
        end else if(init) begin
            idle <= `D 'b0;
        end else if(done) begin
            idle <= `D 'b1;
        end else begin
            idle <= `D idle;
        end
    end

    assign init  = kes_ena & idle;
    assign done  = (deg_P < 'd2) & ~idle; // kes done
    assign swap  = (deg_P < deg_Q) & ~idle; // swap R Q and calculate

    assign kes_in_process = init | ~idle;
    
    assign r4nz = reg_R4 != 0;
    assign r3nz = reg_R4 == 0 && reg_R3 != 0;
    assign r2nz = reg_R4 == 0 && reg_R3 == 0 && reg_R2 != 0;
    assign r1nz = reg_R4 == 0 && reg_R3 == 0 && reg_R2 == 0 && reg_R1 != 0;
    assign r0nz = reg_R4 == 0 && reg_R3 == 0 && reg_R2 == 0 && reg_R1 == 0 && reg_R0 != 0;

    assign q3nz = reg_Q3 != 0;
    assign q2nz = reg_Q3 == 0 && reg_Q2 != 0;
    assign q1nz = reg_Q3 == 0 && reg_Q2 == 0 && reg_Q1 != 0;
    assign q0nz = reg_Q3 == 0 && reg_Q2 == 0 && reg_Q1 == 0 && reg_Q0 != 0;

    assign p3nz = wire_P3 != 0;
    assign p2nz = wire_P3 == 0 && wire_P2 != 0;
    assign p1nz = wire_P3 == 0 && wire_P2 == 0 && wire_P1 != 0;
    assign p0nz = wire_P3 == 0 && wire_P2 == 0 && wire_P1 == 0 && wire_P0 != 0;

    assign msb_R = r4nz ? reg_R4 : r3nz ? reg_R3 : r2nz ? reg_R2 : r1nz ? reg_R1 : reg_R0;
    assign msb_Q = q3nz ? reg_Q3 : q2nz ? reg_Q2 : q1nz ? reg_Q1 : reg_Q0;
    assign deg_P = p3nz ? 3 : p2nz ? 2 : p1nz ? 1 : p0nz ? 0 : deg_Q;

    assign deg_diff = deg_R - deg_Q;

    assign mux_Q0 = (deg_diff==2) ? 8'h00  : (deg_diff==1) ? 8'h00  : reg_Q0;
    assign mux_Q1 = (deg_diff==2) ? 8'h00  : (deg_diff==1) ? reg_Q0 : reg_Q1;
    assign mux_Q2 = (deg_diff==2) ? reg_Q0 : (deg_diff==1) ? reg_Q1 : reg_Q2;
    assign mux_Q3 = (deg_diff==2) ? reg_Q1 : (deg_diff==1) ? reg_Q2 : reg_Q3;
    assign mux_Q4 = (deg_diff==2) ? reg_Q2 : (deg_diff==1) ? reg_Q3 : reg_Q4;

    assign mux_U0 = (deg_diff==2) ? 8'h00  : (deg_diff==1) ? 8'h00  : reg_U0;
    assign mux_U1 = (deg_diff==2) ? 8'h00  : (deg_diff==1) ? reg_U0 : reg_U1;
    assign mux_U2 = (deg_diff==2) ? reg_U0 : (deg_diff==1) ? reg_U1 : reg_U2;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(msb_R), .y(mux_Q0), .z(msb_R_multi_Q0) );
    gf2m8_multi u_gf2m8_multi_aq1 ( .x(msb_R), .y(mux_Q1), .z(msb_R_multi_Q1) );
    gf2m8_multi u_gf2m8_multi_aq2 ( .x(msb_R), .y(mux_Q2), .z(msb_R_multi_Q2) );
    gf2m8_multi u_gf2m8_multi_aq3 ( .x(msb_R), .y(mux_Q3), .z(msb_R_multi_Q3) );
    gf2m8_multi u_gf2m8_multi_aq4 ( .x(msb_R), .y(mux_Q4), .z(msb_R_multi_Q4) );

    gf2m8_multi u_gf2m8_multi_au0 ( .x(msb_R), .y(mux_U0), .z(msb_R_multi_U0) );
    gf2m8_multi u_gf2m8_multi_au1 ( .x(msb_R), .y(mux_U1), .z(msb_R_multi_U1) );
    gf2m8_multi u_gf2m8_multi_au2 ( .x(msb_R), .y(mux_U2), .z(msb_R_multi_U2) );

    gf2m8_multi u_gf2m8_multi_br0 ( .x(msb_Q), .y(reg_R0), .z(msb_Q_multi_R0) );
    gf2m8_multi u_gf2m8_multi_br1 ( .x(msb_Q), .y(reg_R1), .z(msb_Q_multi_R1) );
    gf2m8_multi u_gf2m8_multi_br2 ( .x(msb_Q), .y(reg_R2), .z(msb_Q_multi_R2) );
    gf2m8_multi u_gf2m8_multi_br3 ( .x(msb_Q), .y(reg_R3), .z(msb_Q_multi_R3) );
    gf2m8_multi u_gf2m8_multi_br4 ( .x(msb_Q), .y(reg_R4), .z(msb_Q_multi_R4) );

    gf2m8_multi u_gf2m8_multi_bl0 ( .x(msb_Q), .y(reg_L0), .z(msb_Q_multi_L0) );
    gf2m8_multi u_gf2m8_multi_bl1 ( .x(msb_Q), .y(reg_L1), .z(msb_Q_multi_L1) );
    gf2m8_multi u_gf2m8_multi_bl2 ( .x(msb_Q), .y(reg_L2), .z(msb_Q_multi_L2) );

    //P = (b·R − a·Q·x^(deg_R-deg_Q)) 
    assign wire_P0 = msb_Q_multi_R0 ^ msb_R_multi_Q0;
    assign wire_P1 = msb_Q_multi_R1 ^ msb_R_multi_Q1;
    assign wire_P2 = msb_Q_multi_R2 ^ msb_R_multi_Q2;
    assign wire_P3 = msb_Q_multi_R3 ^ msb_R_multi_Q3;
    assign wire_P4 = msb_Q_multi_R4 ^ msb_R_multi_Q4;

    assign wire_L0 = msb_Q_multi_L0 ^ msb_R_multi_U0;
    assign wire_L1 = msb_Q_multi_L1 ^ msb_R_multi_U1;
    assign wire_L2 = msb_Q_multi_L2 ^ msb_R_multi_U2;

    always @(*) begin
        if(idle) begin //load
            deg_R_next = 'd4;
            deg_Q_next = (rs_syn3==0) ? 'd2 : 'd3;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {8'h00, 8'h00, 8'h00, 8'h00, 8'h01};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00};
            {reg_L0_next, reg_L1_next, reg_L2_next} = {8'h00, 8'h00, 8'h00};
            {reg_U0_next, reg_U1_next, reg_U2_next} = {8'h01, 8'h00, 8'h00};
        end else if(swap) begin
            deg_R_next = deg_Q;
            deg_Q_next = deg_P;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {wire_P0, wire_P1, wire_P2, wire_P3, wire_P4};
            {reg_L0_next, reg_L1_next, reg_L2_next} = {reg_U0, reg_U1, reg_U2};
            {reg_U0_next, reg_U1_next, reg_U2_next} = {wire_L0, wire_L1, wire_L2};
        end else begin
            deg_R_next = deg_P;
            deg_Q_next = deg_Q;
            {reg_R0_next, reg_R1_next, reg_R2_next, reg_R3_next, reg_R4_next} = {wire_P0, wire_P1, wire_P2, wire_P3, wire_P4};
            {reg_Q0_next, reg_Q1_next, reg_Q2_next, reg_Q3_next, reg_Q4_next} = {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4};
            {reg_L0_next, reg_L1_next, reg_L2_next} = {wire_L0, wire_L1, wire_L2};
            {reg_U0_next, reg_U1_next, reg_U2_next} = {reg_U0, reg_U1, reg_U2};
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            deg_R <= `D 8'h00;//4
            deg_Q <= `D 8'h00;//3
            {reg_R0, reg_R1, reg_R2, reg_R3, reg_R4} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_Q0, reg_Q1, reg_Q2, reg_Q3, reg_Q4} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {reg_L0, reg_L1, reg_L2} <= `D {8'h00, 8'h00, 8'h00};
            {reg_U0, reg_U1, reg_U2} <= `D {8'h00, 8'h00, 8'h00};
        end else begin
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
            rs_lambda0 <= `D wire_L0;
            rs_lambda1 <= `D wire_L1;
            rs_lambda2 <= `D wire_L2;
            rs_omega0  <= `D wire_P0;
            rs_omega1  <= `D wire_P1;
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
