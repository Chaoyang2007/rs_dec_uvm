`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_ribm1_pe
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

module s2_kes_ribm1_pe(
    input wire       clk,
    input wire       rstn,
    input wire       idle,
    input wire       swap,
    input wire [7:0] delta_init,
    input wire [7:0] theta_init,
    input wire [7:0] delta_in,
    input wire [7:0] delta,
    input wire [7:0] gamma,

    output wire [7:0] delta_out,
    output wire [7:0] delta_final
);
    reg [7:0] Delta;
    reg [7:0] Theta;

    reg [7:0] Delta_next;
    reg [7:0] Theta_next;

    wire [7:0] delta_multi_T;
    wire [7:0] gamma_multi_D;
    wire [7:0] Delta_update;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(delta), .y(Theta   ), .z(delta_multi_T) );
    gf2m8_multi u_gf2m8_multi_br0 ( .x(gamma), .y(delta_in), .z(gamma_multi_D) );

    assign Delta_update = gamma_multi_D ^ delta_multi_T;
    
    always @(*) begin
        if(idle) begin //load
            {Delta_next} = {delta_init};
            {Theta_next} = {theta_init};
        end else begin
            {Delta_next} = {Delta_update};
            if(swap) begin
                {Theta_next} = {delta_init};                    
            end else begin
                {Theta_next} = {Theta};  
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            {Delta} <= `D {8'h00};
            {Theta} <= `D {8'h00};
        end else begin
            {Delta} <= `D {Delta_next};
            {Theta} <= `D {Theta_next};
        end
    end

    assign delta_out = Delta;
    assign delta_final = Delta_next;

endmodule
