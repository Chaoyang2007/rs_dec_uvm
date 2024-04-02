`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_dcme1_arc
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

    wire [7:0] a;
    wire [7:0] b;

    wire idle;
    wire init;
    wire done;
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
    assign shift_r = a==8'h00; // right shift R
    assign shift_q = b==8'h00; // right shift Q
    assign swap  = deg_R<deg_Q; // swap R Q and calculate

    assign kes_in_process = init | ~idle;

    wire [7:0] r0_out, r0_final;
    wire [7:0] r1_out, r1_final;
    wire [7:0] r2_out, r2_final;
    wire [7:0] r3_out, r3_final;
    wire [7:0] r4_out, r4_final;

    wire [7:0] l0_out, l0_final;
    wire [7:0] l1_out, l1_final;
    wire [7:0] l2_out, l2_final;

    wire [7:0] q0_out;
    wire [7:0] q1_out;
    wire [7:0] q2_out;
    wire [7:0] q3_out;
    wire [7:0] q4_out;

    wire [7:0] u0_out;
    wire [7:0] u1_out;
    wire [7:0] u2_out;
    
    assign a = r4_out;
    assign b = q4_out;

    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_0(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(8'h00), 
                                        .r_in(8'h00), .q_in(8'h00), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(r0_out), .q_out(q0_out), 
                                        .r_final(r0_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_1(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(rs_syn0), 
                                        .r_in(r0_out), .q_in(q0_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(r1_out), .q_out(q1_out), 
                                        .r_final(r1_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_2(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(rs_syn1), 
                                        .r_in(r1_out), .q_in(q1_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(r2_out), .q_out(q2_out), 
                                        .r_final(r2_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_3(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(rs_syn2), 
                                        .r_in(r2_out), .q_in(q2_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(r3_out), .q_out(q3_out), 
                                        .r_final(r3_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_4(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h01), .q_init(rs_syn3), 
                                        .r_in(r3_out), .q_in(q3_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(r4_out), .q_out(q4_out), 
                                        .r_final(r4_final));

    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_5(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(8'h00), 
                                        .r_in(l2_out), .q_in(u2_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(l0_out), .q_out(u0_out), 
                                        .r_final(l0_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_6(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(8'h01), 
                                        .r_in(l0_out), .q_in(u0_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(l1_out), .q_out(u1_out), 
                                        .r_final(l1_final));
    s2_kes_dcme1_pe u_s2_kes_dcme1_pe_6(.clk(clk), .rstn(rstn), 
                                        .idle(idle), .shift_r(shift_r), .shift_q(shift_q), .swap(swap), 
                                        .r_init(8'h00), .q_init(8'h00), 
                                        .r_in(l1_out), .q_in(u1_out), 
                                        .a(a), .b(b), 
                                        
                                        .r_out(l2_out), .q_out(u2_out), 
                                        .r_final(l2_final));

    
    // icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            deg_R <= `D 'd0;
            deg_Q <= `D 'd0;
        end else if(idle) begin //load
            deg_R <= `D 'd4;
            deg_Q <= `D 'd3;
        end else if(shift_r) begin
            deg_R <= `D deg_R - 'd1;
            deg_Q <= `D deg_Q;
        end else if(shift_q) begin
            deg_R <= `D deg_R;
            deg_Q <= `D deg_Q - 'd1;
        end else if(swap) begin
            deg_R <= `D deg_Q - 'd1;
            deg_Q <= `D deg_R;
        end else begin
            deg_R <= `D deg_R - 'd1;
            deg_Q <= `D deg_Q;
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
            rs_lambda0 <= `D l0_final;
            rs_lambda1 <= `D l1_final;
            rs_lambda2 <= `D l2_final;
            rs_omega0  <= `D r0_final; //omegah0
            rs_omega1  <= `D r1_final; //omegah1
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
