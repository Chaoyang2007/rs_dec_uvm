`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_bm1
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

module s2_kes_bm1(
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

    reg [4:0] bm1_state;
    reg [4:0] bm1_state_next;

    reg [2:0] L;
    reg [2:0] K;

    reg [7:0] Lambda0;
    reg [7:0] Lambda1;
    reg [7:0] Lambda2;

    reg [7:0] PolyB0;
    reg [7:0] PolyB1;
    reg [7:0] PolyB2;

    reg [2:0] L_next;

    reg [7:0] Lambda0_next;
    reg [7:0] Lambda1_next;
    reg [7:0] Lambda2_next;

    reg [7:0] PolyB0_next;
    reg [7:0] PolyB1_next;
    reg [7:0] PolyB2_next;

    reg [7:0] Syndrome0;
    reg [7:0] Syndrome1;
    reg [7:0] Syndrome2;
    reg [7:0] Syndrome3;

    reg  [7:0] D;
    reg  [7:0] D_next;
    wire [7:0] delta;
    wire [7:0] Di;
    wire [7:0] deltaDi;

    wire [7:0] Lambda0_update;
    wire [7:0] Lambda1_update;
    wire [7:0] Lambda2_update;

    wire [7:0] Omega0_next;
    wire [7:0] Omega1_next;

    wire [7:0] mux_lambda_0;
    wire [7:0] mux_lambda_1;
    wire [7:0] mux_lambda_2;
    
    wire [7:0] mux_S_0;
    wire [7:0] mux_S_1;
    wire [7:0] mux_S_2;

    wire [7:0] lambda_multi_S_0;
    wire [7:0] lambda_multi_S_1;
    wire [7:0] lambda_multi_S_2;

    wire [7:0] delta_multi_B0;
    wire [7:0] delta_multi_B1;
    wire [7:0] delta_multi_B2;

    wire [7:0] lambda0_multi_S0;
    wire [7:0] lambda0_multi_S1;
    wire [7:0] lambda1_multi_S0;

    wire idle;
    wire init;
    wire done;
    wire swap;
    wire kes_in_process;

    always @(*) begin
        case (bm1_state)
            S0: bm1_state_next = init ? S1 : S0;
            S1: bm1_state_next = S2;
            S2: bm1_state_next = S3;
            S3: bm1_state_next = S4;
            S4: bm1_state_next = S0;
            default: bm1_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            bm1_state <= `D S0;
        end else begin
            bm1_state <= `D bm1_state_next;
        end
    end

    always @(*) begin
        case (bm1_state)
            S0: K = 'd0;
            S1: K = 'd0;
            S2: K = 'd1;
            S3: K = 'd2;
            S4: K = 'd3;
            default: K = 'd0;
        endcase
    end

    assign idle = bm1_state[0];
    assign init = kes_ena & idle;
    assign done = bm1_state[4]; // kes done
    assign swap = delta!=8'h00 && 2*L<=K; // swap Lambda PolyB and calculate

    assign kes_in_process = init | ~idle;

    assign mux_lambda_0 = Lambda0;
    assign mux_lambda_1 = (L==2 || L==1) ? Lambda1 : 8'h00;
    assign mux_lambda_2 = (L==2) ? Lambda2 : 8'h00;

    assign mux_S_0 = (K==3 & L==2) ? Syndrome3 : (K==3 & L==1) ? Syndrome3 : (K==2 & L==2) ? Syndrome2 : (K==2 & L==1) ? Syndrome2 : (K==1 & L==1) ? Syndrome1 : (K==0 & L==0) ? Syndrome0 : 8'h00;
    assign mux_S_1 = (K==3 & L==2) ? Syndrome2 : (K==3 & L==1) ? Syndrome2 : (K==2 & L==2) ? Syndrome1 : (K==2 & L==1) ? Syndrome1 : (K==1 & L==1) ? Syndrome0 : (K==0 & L==0) ? 8'h00     : 8'h00;
    assign mux_S_2 = (K==3 & L==2) ? Syndrome1 : (K==3 & L==1) ? 8'h00     : (K==2 & L==2) ? Syndrome0 : (K==2 & L==1) ? 8'h00     : (K==1 & L==1) ? 8'h00     : (K==0 & L==0) ? 8'h00     : 8'h00;

    gf2m8_multi u_gf2m8_multi_rqiq0 ( .x(mux_lambda_0), .y(mux_S_0), .z(lambda_multi_S_0) );
    gf2m8_multi u_gf2m8_multi_rqiq1 ( .x(mux_lambda_1), .y(mux_S_1), .z(lambda_multi_S_1) );
    gf2m8_multi u_gf2m8_multi_rqiq2 ( .x(mux_lambda_2), .y(mux_S_2), .z(lambda_multi_S_2) );

    //δ=∑{0,l} λi·s{k-i}
    assign delta = lambda_multi_S_0 ^ lambda_multi_S_1 ^ lambda_multi_S_2;

    gf2m8_inverse u_gf2m8_inverse_msbq ( .b(D), .b_inv(Di) );
    gf2m8_multi u_gf2m8_multi_rqi ( .x(delta), .y(Di), .z(deltaDi) );

    gf2m8_multi u_gf2m8_multi_db0 ( .x(deltaDi), .y(PolyB0), .z(delta_multi_B0) );
    gf2m8_multi u_gf2m8_multi_db1 ( .x(deltaDi), .y(PolyB1), .z(delta_multi_B1) );
    //gf2m8_multi u_gf2m8_multi_db2 ( .x(deltaDi), .y(PolyB2), .z(delta_multi_B2) );

    //Λ = Λ - δi/δ·B·x
    assign Lambda0_update = Lambda0;
    assign Lambda1_update = Lambda1 ^ delta_multi_B0;
    assign Lambda2_update = Lambda2 ^ delta_multi_B1;

    gf2m8_multi u_gf2m8_multi_ls0 ( .x(Lambda0_next), .y(Syndrome0), .z(lambda0_multi_S0) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda0_next), .y(Syndrome1), .z(lambda0_multi_S1) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda1_next), .y(Syndrome0), .z(lambda1_multi_S0) );

    //Ω = Λ·S mod x^(2t)
    assign Omega0_next = lambda0_multi_S0;
    assign Omega1_next = lambda0_multi_S1 ^ lambda1_multi_S0;
    
    always @(*) begin
        if(idle) begin //load
            L_next = 'd0;
            D_next = 8'h01;
            {Lambda0_next, Lambda1_next, Lambda2_next} = {8'h01, 8'h00, 8'h00};
            {PolyB0_next, PolyB1_next, PolyB2_next} = {8'h01, 8'h00, 8'h00};
        end else begin
            {Lambda0_next, Lambda1_next, Lambda2_next} = {Lambda0_update, Lambda1_update, Lambda2_update};
            if(swap) begin
                L_next = K + 1 - L;
                D_next = delta;
                {PolyB0_next, PolyB1_next, PolyB2_next} = {Lambda0, Lambda1, Lambda2};
            end else begin
                L_next = L;
                D_next = D;
                {PolyB0_next, PolyB1_next, PolyB2_next} = {8'h00, PolyB0, PolyB1};
            end
        end
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            {Syndrome0, Syndrome1, Syndrome2, Syndrome3} = {8'h00, 8'h00, 8'h00, 8'h00};
        end else if(init) begin
            {Syndrome0, Syndrome1, Syndrome2, Syndrome3} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3};
        end else begin
            {Syndrome0, Syndrome1, Syndrome2, Syndrome3} = {Syndrome0, Syndrome1, Syndrome2, Syndrome3};
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            L <= `D 8'h00;//4
            D <= `D 8'h00;
            {Lambda0, Lambda1, Lambda2} <= `D {8'h00, 8'h00, 8'h00};
            {PolyB0, PolyB1, PolyB2} <= `D {8'h00, 8'h00, 8'h00};
        end else begin
            L <= `D L_next;
            D <= `D D_next;
            {Lambda0, Lambda1, Lambda2} <= `D {Lambda0_next, Lambda1_next, Lambda2_next};
            {PolyB0, PolyB1, PolyB2} <= `D {PolyB0_next, PolyB1_next, PolyB2_next};
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
            rs_lambda0 <= `D Lambda0_next;
            rs_lambda1 <= `D Lambda1_next;
            rs_lambda2 <= `D Lambda2_next;
            rs_omega0  <= `D Omega0_next; //omegah0
            rs_omega1  <= `D Omega1_next; //omegah1
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
