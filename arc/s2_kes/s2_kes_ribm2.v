`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_ribm2
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

module s2_kes_ribm2(
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

    reg [4:0] ribm2_state;
    reg [4:0] ribm2_state_next;

    reg [2:0] L;
    reg [2:0] K;

    reg [7:0] Delta0;
    reg [7:0] Delta1;
    reg [7:0] Delta2;
    reg [7:0] Delta3;
    reg [7:0] Delta4;
    reg [7:0] Delta5;
    reg [7:0] Delta6;

    reg [7:0] Gamma0;
    reg [7:0] Gamma1;
    reg [7:0] Gamma2;
    reg [7:0] Gamma3;
    reg [7:0] Gamma4;
    reg [7:0] Gamma5;
    reg [7:0] Gamma6;

    reg [2:0] L_next;

    reg [7:0] Delta0_next;
    reg [7:0] Delta1_next;
    reg [7:0] Delta2_next;
    reg [7:0] Delta3_next;
    reg [7:0] Delta4_next;
    reg [7:0] Delta5_next;
    reg [7:0] Delta6_next;

    reg [7:0] Gamma0_next;
    reg [7:0] Gamma1_next;
    reg [7:0] Gamma2_next;
    reg [7:0] Gamma3_next;
    reg [7:0] Gamma4_next;
    reg [7:0] Gamma5_next;
    reg [7:0] Gamma6_next;

    wire [7:0] delta;
    wire [7:0] gamma;

    //wire [7:0] delta_multi_G0;
    wire [7:0] delta_multi_G1;
    wire [7:0] delta_multi_G2;
    wire [7:0] delta_multi_G3;
    wire [7:0] delta_multi_G4;
    wire [7:0] delta_multi_G5;
    wire [7:0] delta_multi_G6;
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
        case (ribm2_state)
            S0: ribm2_state_next = init ? S1 : S0;
            S1: ribm2_state_next = S2;
            S2: ribm2_state_next = S3;
            S3: ribm2_state_next = S4;
            S4: ribm2_state_next = S0;
            default: ribm2_state_next = S0;
        endcase
    end

    always @(posedge clk or negedge rstn) begin
        if(!rstn) begin
            ribm2_state <= `D S0;
        end else begin
            ribm2_state <= `D ribm2_state_next;
        end
    end

    always @(*) begin
        case (ribm2_state)
            S0: K = 'd0;
            S1: K = 'd0;
            S2: K = 'd1;
            S3: K = 'd2;
            S4: K = 'd3;
            default: K = 'd0;
        endcase
    end

    assign idle  = ribm2_state[0];
    assign init = kes_ena & idle;
    assign done  = ribm2_state[4]; // kes done
    assign swap  = delta!=8'h00 && 2*L<=K; // swap Delta Gamma and calculate

    assign kes_in_process = init | ~idle;

    assign delta = Delta0;
    assign gamma = Gamma0;

    //gf2m8_multi u_gf2m8_multi_aq0 ( .x(delta), .y(Gamma0), .z(delta_multi_G0) );
    gf2m8_multi u_gf2m8_multi_aq1 ( .x(delta), .y(Gamma1), .z(delta_multi_G1) );
    gf2m8_multi u_gf2m8_multi_aq2 ( .x(delta), .y(Gamma2), .z(delta_multi_G2) );
    gf2m8_multi u_gf2m8_multi_aq3 ( .x(delta), .y(Gamma3), .z(delta_multi_G3) );
    gf2m8_multi u_gf2m8_multi_aq4 ( .x(delta), .y(Gamma4), .z(delta_multi_G4) );
    gf2m8_multi u_gf2m8_multi_aq5 ( .x(delta), .y(Gamma5), .z(delta_multi_G5) );
    gf2m8_multi u_gf2m8_multi_aq6 ( .x(delta), .y(Gamma6), .z(delta_multi_G6) );
    //gf2m8_multi u_gf2m8_multi_br0 ( .x(gamma), .y(Delta0), .z(gamma_multi_D0) );
    gf2m8_multi u_gf2m8_multi_br1 ( .x(gamma), .y(Delta1), .z(gamma_multi_D1) );
    gf2m8_multi u_gf2m8_multi_br2 ( .x(gamma), .y(Delta2), .z(gamma_multi_D2) );
    gf2m8_multi u_gf2m8_multi_br3 ( .x(gamma), .y(Delta3), .z(gamma_multi_D3) );
    gf2m8_multi u_gf2m8_multi_br4 ( .x(gamma), .y(Delta4), .z(gamma_multi_D4) );
    gf2m8_multi u_gf2m8_multi_br5 ( .x(gamma), .y(Delta5), .z(gamma_multi_D5) );
    gf2m8_multi u_gf2m8_multi_br6 ( .x(gamma), .y(Delta6), .z(gamma_multi_D6) );

    //∆ = (γ·∆ − δ·Γ) · x^(−1)
    assign Delta0_update = gamma_multi_D1 ^ delta_multi_G1;
    assign Delta1_update = gamma_multi_D2 ^ delta_multi_G2;
    assign Delta2_update = gamma_multi_D3 ^ delta_multi_G3;
    assign Delta3_update = gamma_multi_D4 ^ delta_multi_G4;
    assign Delta4_update = gamma_multi_D5 ^ delta_multi_G5;
    assign Delta5_update = gamma_multi_D6 ^ delta_multi_G6;
    assign Delta6_update = 8'h00;
    
    always @(*) begin
        if(idle) begin //load
            L_next = 'd0;
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00, 8'h00, 8'h01};
            {Gamma0_next, Gamma1_next, Gamma2_next, Gamma3_next, Gamma4_next, Gamma5_next, Gamma6_next} = {8'h01, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {Delta0_update, Delta1_update, Delta2_update, Delta3_update, Delta4_update, Delta5_update, Delta6_update};
            if(swap) begin
                L_next = K + 1 - L;
                {Gamma0_next, Gamma1_next, Gamma2_next, Gamma3_next, Gamma4_next, Gamma5_next, Gamma6_next} = {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6};                    
            end else begin
                L_next = L;
                {Gamma0_next, Gamma1_next, Gamma2_next, Gamma3_next, Gamma4_next, Gamma5_next, Gamma6_next} = {Gamma0, Gamma1, Gamma2, Gamma3, Gamma4, Gamma5, Gamma6};  
            end
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            L <= `D 'd0;//4
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {Gamma0, Gamma1, Gamma2, Gamma3, Gamma4, Gamma5, Gamma6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            L <= `D L_next;
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next};
            {Gamma0, Gamma1, Gamma2, Gamma3, Gamma4, Gamma5, Gamma6} <= `D {Gamma0_next, Gamma1_next, Gamma2_next, Gamma3_next, Gamma4_next, Gamma5_next, Gamma6_next};
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

endmodule
