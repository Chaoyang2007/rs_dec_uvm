`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_dcme1_pe
// Project Name: 
// Desription:
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

module s2_kes_dcme1_pe(
    input wire       clk,
    input wire       rstn,
    input wire       idle,
    input wire       shift_r,
    input wire       shift_q,
    input wire       swap,
    input wire [7:0] r_init,
    input wire [7:0] q_init,
    input wire [7:0] r_in,
    input wire [7:0] q_in,
    input wire [7:0] a,
    input wire [7:0] b,

    output wire [7:0] r_out,
    output wire [7:0] q_out,
    output wire [7:0] r_final
);
    reg [7:0] R;
    reg [7:0] Q;

    reg [7:0] R_next;
    reg [7:0] Q_next;

    wire [7:0] a_multi_q;
    wire [7:0] b_multi_r;
    wire [7:0] R_update;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(a), .y(q_in), .z(a_multi_q) );
    gf2m8_multi u_gf2m8_multi_br0 ( .x(b), .y(r_in), .z(b_multi_r) );

    assign R_update = b_multi_r ^ a_multi_q;
    
    always @(*) begin
        if(idle) begin
            {R_next} = {r_init};
            {Q_next} = {q_init};
        end else if(shift_r) begin
            {R_next} = {r_in};
            {Q_next} = {Q};
        end else if(shift_q) begin
            {R_next} = {R};
            {Q_next} = {q_in};
        end else if(swap) begin
            {R_next} = {R_update};
            {Q_next} = {R};                    
        end else begin
            {R_next} = {R_update};
            {Q_next} = {Q};  
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            {R} <= `D {8'h00};
            {Q} <= `D {8'h00};
        end else begin
            {R} <= `D {R_next};
            {Q} <= `D {Q_next};
        end
    end

    assign r_out = R;
    assign q_out = Q;
    assign r_final = R_next;

endmodule
