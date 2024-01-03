`ifndef RS_MODEL__SV
`define RS_MODEL__SV

class rs_model extends uvm_component;
    `uvm_component_utils(rs_model);
    uvm_blocking_get_port #(rs_transaction) port;
    uvm_analysis_port #(rs_transaction) ap;
    function new(string name="rs_model", uvm_component parent);
        super.new(name,parent)
    endfunction //new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        port = new("port", this);
        ap = new("ap", this);
    endfunction // build_phase

    task main_phase(uvm_phase phase);
        parameter ROUND1 = 2'b00, ROUND2 = 2'b01, ROUND3 = 2'b10, ROUND4 = 2'b11;
        parameter NONE = 4'b0000, BUF1 = 4'b0001, BUF2 = 4'b0010, BUF3 = 4'b0100, BUF4 = 4'b1000;
        rs_transaction tr, dec_tr;
        bit [1583:0] rcv_buf1, rcv_buf2, rcv_buf3, rcv_buf4;
        bit rcv_buf1_done = 0;
        bit rcv_buf2_done = 0;
        bit rcv_buf3_done = 0;
        bit rcv_buf4_done = 0;
        bit [1535:0] dec_buf1, dec_buf2, dec_buf3, dec_buf4;
        bit [11:0]   isos_buf1, isos_buf2, isos_buf3, isos_buf4;
        bit dec_buf1_vld = 0;
        bit dec_buf2_vld = 0;
        bit dec_buf3_vld = 0;
        bit dec_buf4_vld = 0;
        bit dec_1_rde, dec_2_rde, dec_3_rde, dec_4_rde;
        bit [1:0]    flag_mon  = ROUND1;
        integer      count = 0;
        // get from monitor
        forever begin
            port.get(tr);
            if(tr.rx_vld) begin
                case (flag_mon)
                    ROUND1: 
                        if(count < 2*`M) begin
                            rcv_buf1 = {rcv_buf1[1519:0], tr.rx_data};
                            count = count + 1;
                        end else begin
                            rcv_buf1 = {rcv_buf1[1535:0], tr.rx_data[63:16]}; // 6B
                            rcv_buf2 = {rcv_buf2[1567:0], tr.rx_data[15:0 ]};
                            count = 0;
                            rcv_buf1_done = 1;
                            flag_mon = ROUND2;
                        end
                    ROUND2: 
                        if(count < 2*`M) begin
                            rcv_buf2 = {rcv_buf2[1519:0], tr.rx_data};
                            count = count + 1;
                        end else begin
                            rcv_buf2 = {rcv_buf2[1551:0], tr.rx_data[63:32]}; // 4B
                            rcv_buf3 = {rcv_buf3[1551:0], tr.rx_data[31:0 ]};
                            count = 0;
                            rcv_buf2_done = 1;
                            flag_mon = ROUND3;
                        end
                    ROUND3: 
                        if(count < 2*`M) begin
                            rcv_buf3 = {rcv_buf3[1519:0], tr.rx_data};
                            count = count + 1;
                        end else begin
                            rcv_buf3 = {rcv_buf3[1567:0], tr.rx_data[63:48]}; // 2B
                            rcv_buf4 = {rcv_buf4[1535:0], tr.rx_data[47:0 ]};
                            count = 0;
                            rcv_buf3_done = 1;
                            flag_mon = ROUND4;
                        end
                    ROUND4: 
                        if(count < 2*`M-1) begin
                            rcv_buf4 = {rcv_buf4[1519:0], tr.rx_data};
                            count = count + 1;
                        end else begin
                            rcv_buf4 = {rcv_buf4[1567:0], tr.rx_data}; // 
                            count = 0;
                            rcv_buf4_done = 1;
                            flag_mon = ROUND1;
                        end
                endcase
            end
        end
        
        // decode calculate
        forever begin
            case ({rcv_buf4_done, rcv_buf3_done, rcv_buf2_done, rcv_buf1_done})
                NONE: #`PERIOD;
                BUF1: {dec_buf1, isos_buf1} = decode(rcv_buf1, dec_1_rde);
                BUF2: {dec_buf2, isos_buf2} = decode(rcv_buf2, dec_2_rde);
                BUF3: {dec_buf3, isos_buf3} = decode(rcv_buf3, dec_3_rde);
                BUF4: {dec_buf4, isos_buf4} = decode(rcv_buf4, dec_4_rde);
                default: `uvm_error("maybe the fifo overflowed!")
            endcase
        end

        // write to scoreboard
        forever begin
            case ({dec_buf4_vld, dec_buf3_vld, dec_buf2_vld, dec_buf1_vld})
                NONE: // `CLOCK_PERIOD
                begin
                    dec_tr = new();
                    dec_tr.dec_vld  = 'b0;
                    ap.write(dec_tr);
                end
                BUF1: 
                begin
                    for (integer i = 0; i < 2*`M; i++) begin
                        dec_tr = new();
                        dec_tr.dec_vld  = 'b1;
                        dec_tr.dec_data = dec_buf1[1535-64*i-:64];
                        dec_tr.dec_isos = isos_buf1[i/2];
                        dec_tr.RDE_ERROR = dec_1_rde;
                        ap.write(dec_tr);
                    end
                    dec_buf1_vld = 0;
                end
                BUF2: 
                begin
                    for (integer i = 0; i < 2*`M; i++) begin
                        dec_tr = new();
                        dec_tr.dec_vld  = 'b1;
                        dec_tr.dec_data = dec_buf2[1535-64*i-:64];
                        dec_tr.dec_isos = isos_buf2[i/2];
                        dec_tr.RDE_ERROR = dec_2_rde;
                        ap.write(dec_tr);
                    end
                    dec_buf2_vld = 0;
                end
                BUF3: 
                begin
                    for (integer i = 0; i < 2*`M; i++) begin
                        dec_tr = new();
                        dec_tr.dec_vld  = 'b1;
                        dec_tr.dec_data = dec_buf3[1535-64*i-:64];
                        dec_tr.dec_isos = isos_buf3[i/2];
                        dec_tr.RDE_ERROR = dec_1_rde;
                        ap.write(dec_tr);
                    end
                    dec_buf3_vld = 0;
                end
                BUF4: 
                begin
                    for (integer i = 0; i < 2*`M; i++) begin
                        dec_tr = new();
                        dec_tr.dec_vld  = 'b1;
                        dec_tr.dec_data = dec_buf4[1535-64*i-:64];
                        dec_tr.dec_isos = isos_buf4[i/2];
                        dec_tr.RDE_ERROR = dec_4_rde;
                        ap.write(dec_tr);
                    end
                    dec_buf4_vld = 0;
                end
                default: `uvm_error("maybe the fifo overflowed!")
            endcase
        end
    endtask // main_phase

    function [1547:0] decode(bit [1583:0] rcv_data, ref bit rde);
        bit [31:0] syndrome;
        bit [39:0] kes;
        bit [23:0] lambda;
        bit [15:0] omega;
        int err_num;
        bit dec_error_flag;
        bit [1547:0] err_val;

        // Calculate syndrome
        syndrome = syn_cal(rcv_data);

        if (syndrome != 'b0) begin
            // Calculate kes
            kes = kes_cal(syndrome);
            lambda = kes[39:16];
            omega  = kes[15:0];

            // Calculate err_val and err_num
            err_val = csee(lambda, omega, err_num);

            // Decode and return the result
            decode = err_val ^ {rcv_data[1583,48], rcv_data[43:32]};

            dec_error_flag = (err_num == 0 || err_num > 2) ? 'b1 : 'b0;
        end else begin
            decode = {rcv_data[1583,48], rcv_data[43:32]};
            dec_error_flag = 0;
        end
        rde = dec_error_flag;
    endfunction // decode

    function [31:0] syn_cal(bit [1583:0] rcv_data);
        parameter ALPHA0 = 8'd1;
        parameter ALPHA1 = 8'd2;
        parameter ALPHA2 = 8'd4;
        parameter ALPHA3 = 8'd8;
        bit [7:0] S0 = 8'b0, S1 = 8'b0, S2 = 8'b0, S3 = 8'b0;
        bit [7:0] SA1, SA2, SA3;
        bit [7:0] temp_byte;

        for (integer i = 0; `N; i++) begin
            temp_byte = rcv_data[1583-8*i-:8]
            SA1 = rs_utils::gf2m8_multi(S1, ALPHA1);
            SA2 = rs_utils::gf2m8_multi(S2, ALPHA2);
            SA3 = rs_utils::gf2m8_multi(S3, ALPHA3);
            S0  = S0  ^ temp_byte;
            S1  = SA1 ^ temp_byte;
            S2  = SA2 ^ temp_byte;
            S3  = SA3 ^ temp_byte;
        end
        syn_cal = {S0, S1, S2, S3};
    endfunction // syn_cal

    function [39:0] kes_cal(bit [31:0] S);
        int t = 2;
        bit [7:0] R0=0, R1=0, R2=0, R3=0, R4=0, R5=0, R6=1;
        bit [7:0] Q0=0, Q1=0, Q2=0, Q3=S[31:24], Q4=S[23:16], Q5=S[15:8], Q6=S[7:0];
        int degR = 2*t;
        int degQ = 2*t-1;
        bit [7:0] a, b;
        int temp_degR;
        bit [7:0] temp_R0, temp_R1, temp_R2, temp_R3, temp_R4, temp_R5, temp_R6;
        bit [7:0] aq0, aq1, aq2, aq3, aq4, aq5;
        bit [7:0] br0, br1, br2, br3, br4, br5;

        for (integer i = 0; i < 2*t; i++) begin
            if (degR < t) begin
                continue; // Skip the calculation if degR is less than t
            end else begin
                // degR >= t
                a = R6;
                b = Q6;

                if (b == 0) begin
                    // shift
                    degQ = degQ - 1;
                    Q6 = Q5; Q5 = Q4; Q4 = Q3; Q3 = Q2; Q2 = Q1; Q1 = Q0; Q0 = 0;
                end
                else if (a != 0 && degR < degQ) begin
                    // switch
                    temp_degR = degR;
                    temp_R0 = R0; temp_R1 = R1; temp_R2 = R2; temp_R3 = R3; temp_R4 = R4; temp_R5 = R5; temp_R6 = R6;
                    degR = degQ - 1;
                    degQ = temp_degR;

                    // Multiplications
                    aq0 = rs_utils::gf2m8_multi(a, Q0);
                    aq1 = rs_utils::gf2m8_multi(a, Q1);
                    aq2 = rs_utils::gf2m8_multi(a, Q2);
                    aq3 = rs_utils::gf2m8_multi(a, Q3);
                    aq4 = rs_utils::gf2m8_multi(a, Q4);
                    aq5 = rs_utils::gf2m8_multi(a, Q5);
                    br0 = rs_utils::gf2m8_multi(b, R0);
                    br1 = rs_utils::gf2m8_multi(b, R1);
                    br2 = rs_utils::gf2m8_multi(b, R2);
                    br3 = rs_utils::gf2m8_multi(b, R3);
                    br4 = rs_utils::gf2m8_multi(b, R4);
                    br5 = rs_utils::gf2m8_multi(b, R5);

                    // Update R values
                    R0 = 0;
                    R1 = aq0 ^ br0;
                    R2 = aq1 ^ br1;
                    R3 = aq2 ^ br2;
                    R4 = aq3 ^ br3;
                    R5 = aq4 ^ br4;
                    R6 = aq5 ^ br5;

                    // Update Q values
                    Q0 = temp_R0;
                    Q1 = temp_R1;
                    Q2 = temp_R2;
                    Q3 = temp_R3;
                    Q4 = temp_R4;
                    Q5 = temp_R5;
                    Q6 = temp_R6;
                end
                else begin
                    // calculate
                    degR = degR - 1;

                    // Multiplications
                    aq0 = rs_utils::gf2m8_multi(a, Q0);
                    aq1 = rs_utils::gf2m8_multi(a, Q1);
                    aq2 = rs_utils::gf2m8_multi(a, Q2);
                    aq3 = rs_utils::gf2m8_multi(a, Q3);
                    aq4 = rs_utils::gf2m8_multi(a, Q4);
                    aq5 = rs_utils::gf2m8_multi(a, Q5);
                    br0 = rs_utils::gf2m8_multi(b, R0);
                    br1 = rs_utils::gf2m8_multi(b, R1);
                    br2 = rs_utils::gf2m8_multi(b, R2);
                    br3 = rs_utils::gf2m8_multi(b, R3);
                    br4 = rs_utils::gf2m8_multi(b, R4);
                    br5 = rs_utils::gf2m8_multi(b, R5);

                    // Update R values
                    R0 = 0;
                    R1 = aq0 ^ br0;
                    R2 = aq1 ^ br1;
                    R3 = aq2 ^ br2;
                    R4 = aq3 ^ br3;
                    R5 = aq4 ^ br4;
                    R6 = aq5 ^ br5;
                end
            end
        end

        kes_cal = {R2, R3, R4, R5, R6}; // l0, l1, l2 = R2, R3, R4; o0, o1 = R5, R6;
    endfunction // kes_cal

    function [1547:0] csee(bit [23:0] lambda, bit [15:0] omega, ref int err_num);
        parameter ALPHA0   = 8'd1;
        parameter ALPHA1   = 8'd2;
        parameter ALPHA2   = 8'd4;
        parameter ALPHA58  = 8'd105;
        parameter ALPHA116 = 8'd248;
        bit [7:0] a0 = lambda[23:16], a1 = lambda[15:8], a2 = lambda[7:0];
        bit [7:0] b0 = omega[15:8], b1 = omega[7:0];
        bit [7:0] sum_chk;
        int error_num = 0;
        bit [1583:0] error_val = 0;
        int [7:0] error;

        for (integer i = 0; i<`N; i++) begin
            // a0 = rs_utils::gf2m8_multi(a0, ALPHA0);
            a1 = rs_utils::gf2m8_multi(a1, (i == 0) ? ALPHA58 : ALPHA1);
            a2 = rs_utils::gf2m8_multi(a2, (i == 0) ? ALPHA116 : ALPHA2);
            // b0 = rs_utils::gf2m8_multi(b0, ALPHA0);
            b1 = rs_utils::gf2m8_multi(b1, (i == 0) ? ALPHA58 : ALPHA1);

            sum_chk = a0 ^ a1 ^ a2;

            if (sum_chk == 0) begin
                error_num = error_num + 1;
                error = rs_utils::gf2m8_divid(b0 ^ b1, a1);
                error_val = {error_val[1575:0], error};
            end else begin
                error_val = {error_val[1575:0], 8'd0};
            end
        end

        csee = {error_val[1583,48], error_val[43:32]};
        err_num = error_num;
    endfunction // csee

endclass //rs_model extends uvm_component

`endif RS_MODEL__SV