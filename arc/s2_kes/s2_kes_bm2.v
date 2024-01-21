`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_bm2
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

module s2_kes_bm2(
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

    reg [4:0] bm2_state;
    reg [4:0] bm2_state_next;

    reg [2:0] L;
    reg [2:0] K;

    reg [7:0] Lambda0;
    reg [7:0] Lambda1;
    reg [7:0] Lambda2;
    reg [7:0] Lambda3;

    reg [7:0] PolyB0;
    reg [7:0] PolyB1;
    reg [7:0] PolyB2;
    reg [7:0] PolyB3;

    reg [7:0] Omega0;
    reg [7:0] Omega1;
    reg [7:0] Omega2;
    reg [7:0] Omega3;

    reg [7:0] PolyC0;
    reg [7:0] PolyC1;
    reg [7:0] PolyC2;
    reg [7:0] PolyC3;

    reg [2:0] L_next;

    reg [7:0] Lambda0_next;
    reg [7:0] Lambda1_next;
    reg [7:0] Lambda2_next;
    reg [7:0] Lambda3_next;

    reg [7:0] PolyB0_next;
    reg [7:0] PolyB1_next;
    reg [7:0] PolyB2_next;
    reg [7:0] PolyB3_next;

    reg [7:0] Omega0_next;
    reg [7:0] Omega1_next;
    reg [7:0] Omega2_next;
    reg [7:0] Omega3_next;

    reg [7:0] PolyC0_next;
    reg [7:0] PolyC1_next;
    reg [7:0] PolyC2_next;
    reg [7:0] PolyC3_next;

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
    wire [7:0] Lambda3_update;

    wire [7:0] Omega0_update;
    wire [7:0] Omega1_update;
    wire [7:0] Omega2_update;
    wire [7:0] Omega3_update;

    wire [7:0] lambda0_multi_S0;
    wire [7:0] lambda0_multi_S1;
    wire [7:0] lambda1_multi_S0;
    wire [7:0] lambda0_multi_S2;
    wire [7:0] lambda1_multi_S1;
    wire [7:0] lambda2_multi_S0;
    wire [7:0] lambda0_multi_S3;
    wire [7:0] lambda1_multi_S2;
    wire [7:0] lambda2_multi_S1;
    wire [7:0] lambda3_multi_S0;

    wire [7:0] delta_multi_B0;
    wire [7:0] delta_multi_B1;
    wire [7:0] delta_multi_B2;
    wire [7:0] delta_multi_C0;
    wire [7:0] delta_multi_C1;
    wire [7:0] delta_multi_C2;

    wire idle;
    wire init;
    wire done;
    wire swap;
    wire kes_in_process;

    always @(*) begin
        case (bm2_state)
            S0: bm2_state_next = init ? S1 : S0;
            S1: bm2_state_next = S2;
            S2: bm2_state_next = S3;
            S3: bm2_state_next = S4;
            S4: bm2_state_next = S0;
            default: bm2_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            bm2_state <= `D S0;
        end else begin
            bm2_state <= `D bm2_state_next;
        end
    end

    always @(*) begin
        case (bm2_state)
            S0: K = 'd0;
            S1: K = 'd0;
            S2: K = 'd1;
            S3: K = 'd2;
            S4: K = 'd3;
            default: K = 'd0;
        endcase
    end

    assign idle = bm2_state[0];
    assign init = kes_ena & idle;
    assign done = bm2_state[4]; // kes done
    assign swap = delta!=8'h00 && 2*L<=K; // swap Lambda PolyB and calculate

    assign kes_in_process = init | ~idle;

    gf2m8_multi u_gf2m8_multi_ls0 ( .x(Lambda0), .y(Syndrome0), .z(lambda0_multi_S0) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda0), .y(Syndrome1), .z(lambda0_multi_S1) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda1), .y(Syndrome0), .z(lambda1_multi_S0) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda0), .y(Syndrome2), .z(lambda0_multi_S2) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda1), .y(Syndrome1), .z(lambda1_multi_S1) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda2), .y(Syndrome0), .z(lambda2_multi_S0) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda0), .y(Syndrome3), .z(lambda0_multi_S3) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda1), .y(Syndrome2), .z(lambda1_multi_S2) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda2), .y(Syndrome1), .z(lambda2_multi_S1) );
    gf2m8_multi u_gf2m8_multi_ls1 ( .x(Lambda3), .y(Syndrome0), .z(lambda3_multi_S0) );

    //δi=i-th coefficient of ∆·S-Ω
    assign delta = (K==0) ? lambda0_multi_S0 ^ Omega0 :
                   (K==1) ? lambda0_multi_S1 ^ lambda1_multi_S0 ^ Omega1 : 
                   (K==2) ? lambda0_multi_S2 ^ lambda1_multi_S1 ^ lambda2_multi_S0 ^ Omega2 : 
                   (K==3) ? lambda0_multi_S3 ^ lambda1_multi_S2 ^ lambda2_multi_S1 ^ lambda3_multi_S0 ^ Omega3 : 8'h00;

    gf2m8_inverse u_gf2m8_inverse_msbq ( .b(D), .b_inv(Di) );
    gf2m8_multi u_gf2m8_multi_rqi ( .x(delta), .y(Di), .z(deltaDi) );

    gf2m8_multi u_gf2m8_multi_db0 ( .x(deltaDi), .y(PolyB0), .z(delta_multi_B0) );
    gf2m8_multi u_gf2m8_multi_db1 ( .x(deltaDi), .y(PolyB1), .z(delta_multi_B1) );
    gf2m8_multi u_gf2m8_multi_db2 ( .x(deltaDi), .y(PolyB2), .z(delta_multi_B2) );

    gf2m8_multi u_gf2m8_multi_dc0 ( .x(deltaDi), .y(PolyC0), .z(delta_multi_C0) );
    gf2m8_multi u_gf2m8_multi_dc1 ( .x(deltaDi), .y(PolyC1), .z(delta_multi_C1) );
    gf2m8_multi u_gf2m8_multi_dc2 ( .x(deltaDi), .y(PolyC2), .z(delta_multi_C2) );

    //Λ = Λ - δi/δ·B
    assign Lambda0_update = Lambda0 ^ delta_multi_B0;
    assign Lambda1_update = Lambda1 ^ delta_multi_B1;
    assign Lambda2_update = Lambda2 ^ delta_multi_B2;
    //Ω = Ω - δi/δ·C
    assign Omega0_update = Omega0 ^ delta_multi_C0;
    assign Omega1_update = Omega1 ^ delta_multi_C1;
    assign Omega2_update = Omega2 ^ delta_multi_C2;
    
    always @(*) begin
        if(idle) begin //load
            L_next = 'd0;
            D_next = 8'h01;
            {Lambda0_next, Lambda1_next, Lambda2_next, Lambda3_next} = {8'h01, 8'h00, 8'h00, 8'h00};
            {Omega0_next, Omega1_next, Omega2_next, Omega3_next} = {8'h00, 8'h00, 8'h00, 8'h00};
            {PolyB0_next, PolyB1_next, PolyB2_next, PolyB3_next} = {8'h00, 8'h00, 8'h00, 8'h00};
            {PolyC0_next, PolyC1_next, PolyC2_next, PolyC3_next} = {8'h01, 8'h00, 8'h00, 8'h00};
        end else begin
            {Lambda0_next, Lambda1_next, Lambda2_next, Lambda3_next} = {Lambda0_update, Lambda1_update, Lambda2_update};
            {Omega0_next, Omega1_next, Omega2_next, Omega3_next} = {Omega0_update, Omega1_update, Omega2_update};
            if(swap) begin
                L_next = K + 1 - L;
                D_next = delta;
                {PolyB0_next, PolyB1_next, PolyB2_next, PolyB3_next} = {8'h00, Lambda0, Lambda1, Lambda2};
                {PolyC0_next, PolyC1_next, PolyC2_next, PolyC3_next} = {8'h00, Omega0, Omega1, Omega2};
            end else begin
                L_next = L;
                D_next = D;
                {PolyB0_next, PolyB1_next, PolyB2_next, PolyB3_next} = {8'h00, PolyB0, PolyB1, PolyB2};
                {PolyC0_next, PolyC1_next, PolyC2_next, PolyC3_next} = {8'h00, PolyC0, PolyC1, PolyC2};
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
            {Lambda0, Lambda1, Lambda2, Lambda3} <= `D {8'h00, 8'h00, 8'h00, 8'h00};
            {Omega0, Omega1, Omega2, Omega3} <= `D {8'h00, 8'h00, 8'h00, 8'h00};
            {PolyB0, PolyB1, PolyB2, PolyB3} <= `D {8'h00, 8'h00, 8'h00, 8'h00};
            {PolyC0, PolyC1, PolyC2, PolyC3} <= `D {8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            L <= `D L_next;
            D <= `D D_next;
            {Lambda0, Lambda1, Lambda2, Lambda3} <= `D {Lambda0_next, Lambda1_next, Lambda2_next, Lambda3_next};
            {Omega0, Omega1, Omega2, Omega3} <= `D {Omega0_next, Omega1_next, Omega2_next, Omega3_next};
            {PolyB0, PolyB1, PolyB2, PolyB3} <= `D {PolyB0_next, PolyB1_next, PolyB2_next, PolyB3_next};
            {PolyC0, PolyC1, PolyC2, PolyC3} <= `D {PolyC0_next, PolyC1_next, PolyC2_next, PolyC3_next};
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
