`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_ribm1_arc
// Project Name: 
// Desription: 5 cycles
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

    wire [7:0] delta;
    reg  [7:0] gamma;

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
    assign init  = kes_ena & idle;
    assign done  = ribm1_state[4]; // kes done
    assign swap  = delta!=8'h00 && 2*L<=K; // swap Delta Gamma and calculate

    assign kes_in_process = init | ~idle;

    wire [7:0] delta0_out, delta0_final;
    wire [7:0] delta1_out, delta1_final;
    wire [7:0] delta2_out, delta2_final;
    wire [7:0] delta3_out, delta3_final;
    wire [7:0] delta4_out, delta4_final;
    wire [7:0] delta5_out, delta5_final;
    wire [7:0] delta6_out, delta6_final;
    
    assign delta = delta0_out;

    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_0(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(rs_syn0), .theta_init(rs_syn0), 
                                        .delta_in(delta1_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta0_out), 
                                        .delta_final(delta0_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_1(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(rs_syn1), .theta_init(rs_syn1), 
                                        .delta_in(delta2_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta1_out), 
                                        .delta_final(delta1_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_2(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(rs_syn2), .theta_init(rs_syn2), 
                                        .delta_in(delta3_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta2_out), 
                                        .delta_final(delta2_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_3(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(rs_syn3), .theta_init(rs_syn3), 
                                        .delta_in(delta4_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta3_out), 
                                        .delta_final(delta3_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_4(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(8'h00), .theta_init(8'h00), 
                                        .delta_in(delta5_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta4_out), 
                                        .delta_final(delta4_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_5(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(8'h00), .theta_init(8'h00), 
                                        .delta_in(delta6_out), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta5_out), 
                                        .delta_final(delta5_final));
    s2_kes_ribm1_pe u_s2_kes_ribm1_pe_6(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .swap(swap), 
                                        .delta_init(8'h01), .theta_init(8'h01), 
                                        .delta_in(8'h00), 
                                        .delta(delta), .gamma(gamma), 
                                        
                                        .delta_out(delta6_out), 
                                        .delta_final(delta6_final));

    
    // icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            L <= `D 'd0;
            gamma <= `D 8'h00;
        end else if(idle) begin
            L <= `D 'd0;
            gamma <= `D 8'h01;
        end else if(swap) begin
            L <= `D K + 1 - L;
            gamma <= `D delta;
        end else begin
            L <= `D L;
            gamma <= `D gamma;
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
            rs_lambda0 <= `D delta2_final;
            rs_lambda1 <= `D delta3_final;
            rs_lambda2 <= `D delta4_final;
            rs_omega0  <= `D delta0_final; //omegah0
            rs_omega1  <= `D delta1_final; //omegah1
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
