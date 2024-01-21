`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: 
// 
// Create Date: 2023/06/25 22:51:57
// Design Name: 
// Module Name: s2_kes_ribm1
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

    reg [7:0] Delta0;
    reg [7:0] Delta1;
    reg [7:0] Delta2;
    reg [7:0] Delta3;
    reg [7:0] Delta4;
    reg [7:0] Delta5;
    reg [7:0] Delta6;

    reg [7:0] Theta0;
    reg [7:0] Theta1;
    reg [7:0] Theta2;
    reg [7:0] Theta3;
    reg [7:0] Theta4;
    reg [7:0] Theta5;
    reg [7:0] Theta6;

    reg [2:0] L_next;

    reg [7:0] Delta0_next;
    reg [7:0] Delta1_next;
    reg [7:0] Delta2_next;
    reg [7:0] Delta3_next;
    reg [7:0] Delta4_next;
    reg [7:0] Delta5_next;
    reg [7:0] Delta6_next;

    reg [7:0] Theta0_next;
    reg [7:0] Theta1_next;
    reg [7:0] Theta2_next;
    reg [7:0] Theta3_next;
    reg [7:0] Theta4_next;
    reg [7:0] Theta5_next;
    reg [7:0] Theta6_next;

    wire [7:0] delta;
    reg  [7:0] gamma;
    reg  [7:0] gamma_next;

    wire [7:0] delta_multi_T0;
    wire [7:0] delta_multi_T1;
    wire [7:0] delta_multi_T2;
    wire [7:0] delta_multi_T3;
    wire [7:0] delta_multi_T4;
    wire [7:0] delta_multi_T5;
    wire [7:0] delta_multi_T6;
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
    assign init = kes_ena & idle;
    assign done  = ribm1_state[4]; // kes done
    assign swap  = delta!=8'h00 && 2*L<=K; // swap Delta Theta and calculate

    assign kes_in_process = init | ~idle;

    assign delta = Delta0;

    gf2m8_multi u_gf2m8_multi_aq0 ( .x(delta), .y(Theta0), .z(delta_multi_T0) );
    gf2m8_multi u_gf2m8_multi_aq1 ( .x(delta), .y(Theta1), .z(delta_multi_T1) );
    gf2m8_multi u_gf2m8_multi_aq2 ( .x(delta), .y(Theta2), .z(delta_multi_T2) );
    gf2m8_multi u_gf2m8_multi_aq3 ( .x(delta), .y(Theta3), .z(delta_multi_T3) );
    gf2m8_multi u_gf2m8_multi_aq4 ( .x(delta), .y(Theta4), .z(delta_multi_T4) );
    gf2m8_multi u_gf2m8_multi_aq5 ( .x(delta), .y(Theta5), .z(delta_multi_T5) );
    gf2m8_multi u_gf2m8_multi_aq6 ( .x(delta), .y(Theta6), .z(delta_multi_T6) );
    //gf2m8_multi u_gf2m8_multi_br0 ( .x(gamma), .y(Delta0), .z(gamma_multi_D0) );
    gf2m8_multi u_gf2m8_multi_br1 ( .x(gamma), .y(Delta1), .z(gamma_multi_D1) );
    gf2m8_multi u_gf2m8_multi_br2 ( .x(gamma), .y(Delta2), .z(gamma_multi_D2) );
    gf2m8_multi u_gf2m8_multi_br3 ( .x(gamma), .y(Delta3), .z(gamma_multi_D3) );
    gf2m8_multi u_gf2m8_multi_br4 ( .x(gamma), .y(Delta4), .z(gamma_multi_D4) );
    gf2m8_multi u_gf2m8_multi_br5 ( .x(gamma), .y(Delta5), .z(gamma_multi_D5) );
    gf2m8_multi u_gf2m8_multi_br6 ( .x(gamma), .y(Delta6), .z(gamma_multi_D6) );

    //∆ = γ·∆·x^(−1) − δ·Θ
    assign Delta0_update = gamma_multi_D1 ^ delta_multi_T0;
    assign Delta1_update = gamma_multi_D2 ^ delta_multi_T1;
    assign Delta2_update = gamma_multi_D3 ^ delta_multi_T2;
    assign Delta3_update = gamma_multi_D4 ^ delta_multi_T3;
    assign Delta4_update = gamma_multi_D5 ^ delta_multi_T4;
    assign Delta5_update = gamma_multi_D6 ^ delta_multi_T5;
    assign Delta6_update =                  delta_multi_T6;
    
    always @(*) begin
        if(idle) begin //load
            L_next = 'd0;
            gamma_next = 8'h01;;
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00, 8'h00, 8'h01};
            {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {rs_syn0, rs_syn1, rs_syn2, rs_syn3, 8'h00, 8'h00, 8'h01};
        end else begin
            {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next} = {Delta0_update, Delta1_update, Delta2_update, Delta3_update, Delta4_update, Delta5_update, Delta6_update};
            if(swap) begin
                L_next = K + 1 - L;
                gamma_next = delta;
                {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {Delta1, Delta2, Delta3, Delta4, Delta5, Delta6, 8'h00};                    
            end else begin
                L_next = L;
                gamma_next = gamma;
                {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next} = {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6};  
            end
        end
    end

    icg u_icg_kes_rq(.clk(clk), .ena(kes_in_process), .rstn(rstn), .gclk(kes_in_process_clk));
    always @(posedge kes_in_process_clk or negedge rstn) begin
        if(!rstn) begin
            L <= `D 'd0;//4
            gamma <= `D 8'h00;
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
            {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6} <= `D {8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00};
        end else begin
            L <= `D L_next;
            gamma <= `D gamma_next;
            {Delta0, Delta1, Delta2, Delta3, Delta4, Delta5, Delta6} <= `D {Delta0_next, Delta1_next, Delta2_next, Delta3_next, Delta4_next, Delta5_next, Delta6_next};
            {Theta0, Theta1, Theta2, Theta3, Theta4, Theta5, Theta6} <= `D {Theta0_next, Theta1_next, Theta2_next, Theta3_next, Theta4_next, Theta5_next, Theta6_next};
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
