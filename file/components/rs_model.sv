`ifndef RS_MODEL__SV
`define RS_MODEL__SV

class rs_model extends uvm_component;
    `uvm_component_utils(rs_model);
    uvm_blocking_get_port #(rs_transaction) port;
    uvm_analysis_port #(rs_transaction)     ap;

    function new(string name="rs_model", uvm_component parent);
        super.new(name,parent);
    endfunction // new()

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        port = new("port", this);
        ap = new("ap", this);
    endfunction // build_phase

    task main_phase(uvm_phase phase);
        rs_transaction tr, dec_tr;

        parameter BLOCK1 = 2'b00, BLOCK2 = 2'b01, BLOCK3 = 2'b10, BLOCK4 = 2'b11;
        parameter NONE = 4'b0000;
        parameter BUF1 = 4'b0001, BUF2 = 4'b0010, BUF3 = 4'b0100, BUF4 = 4'b1000;

        bit [198`B:0] rcv_buf_1,  rcv_buf_2,  rcv_buf_3,  rcv_buf_4;
        bit [192`B:0] dec_buf_1,  dec_buf_2,  dec_buf_3,  dec_buf_4;
        bit [11:0]   isos_buf_1, isos_buf_2, isos_buf_3, isos_buf_4;
        bit          rde_buf_1,  rde_buf_2,  rde_buf_3,  rde_buf_4;

        bit [1:0]   RCV_BLOCK  = BLOCK1;
        bit [3:0]   RCV_BUF_DONE = NONE;
        bit [3:0]   DEC_BUF_DONE = NONE;
        integer     COUNT = 0;

        fork
            // get transactions from monitor
            forever begin
                port.get(tr);
                if(tr.rx_vld) begin
                    case (RCV_BLOCK)
                        BLOCK1: begin
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_1 = {rcv_buf_1[190`B:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_1 = {rcv_buf_1[192`B:0], tr.rx_data[8`B:2`B+1]}; // 6B
                                rcv_buf_2 = {rcv_buf_2[196`B:0], tr.rx_data[2`B:0]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF1;
                                RCV_BLOCK = BLOCK2;
                                `uvm_info("rs_model", $sformatf("receive block 1 done"), UVM_MEDIUM);
                            end
                        end
                        BLOCK2: begin
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_2 = {rcv_buf_2[190`B:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_2 = {rcv_buf_2[194`B:0], tr.rx_data[8`B:4`B+1]}; // 4B
                                rcv_buf_3 = {rcv_buf_3[194`B:0], tr.rx_data[4`B:0 ]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF2;
                                RCV_BLOCK = BLOCK3;
                                `uvm_info("rs_model", $sformatf("receive block 1 done"), UVM_MEDIUM);
                            end
                        end
                        BLOCK3: begin
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_3 = {rcv_buf_3[190`B:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_3 = {rcv_buf_3[196`B:0], tr.rx_data[8`B:6`B+1]}; // 2B
                                rcv_buf_4 = {rcv_buf_4[192`B:0], tr.rx_data[6`B:0 ]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF3;
                                RCV_BLOCK = BLOCK4;
                                `uvm_info("rs_model", $sformatf("receive block 1 done"), UVM_MEDIUM);
                            end
                        end
                        BLOCK4: begin
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK-1) begin
                                rcv_buf_4 = {rcv_buf_4[190`B:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_4 = {rcv_buf_4[196`B:0], tr.rx_data}; // 
                                COUNT = 0;
                                RCV_BUF_DONE = BUF4;
                                RCV_BLOCK = BLOCK1;
                                `uvm_info("rs_model", $sformatf("receive block 1 done"), UVM_MEDIUM);
                            end
                        end
                    endcase
                end
            end
            
            // decoding calculate
            forever begin
                case (RCV_BUF_DONE)
                    NONE: #`CLOCK_PERIOD;
                    BUF1: begin
                        `uvm_info("rs_model", $sformatf("start decoding buffer 1"), UVM_MEDIUM);
                        decode(rcv_buf_1, dec_buf_1, isos_buf_1, rde_buf_1);
                        `uvm_info("rs_model", $sformatf("end decoding buffer 1"), UVM_MEDIUM);
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF1;
                    end
                    BUF2: begin
                        `uvm_info("rs_model", $sformatf("start decoding buffer 2"), UVM_MEDIUM);
                        decode(rcv_buf_2, dec_buf_2, isos_buf_2, rde_buf_2);
                        `uvm_info("rs_model", $sformatf("end decoding buffer 2"), UVM_MEDIUM);
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF2;
                    end
                    BUF3: begin
                        `uvm_info("rs_model", $sformatf("start decoding buffer 3"), UVM_MEDIUM);
                        decode(rcv_buf_3, dec_buf_3, isos_buf_3, rde_buf_3);
                        `uvm_info("rs_model", $sformatf("end decoding buffer 3"), UVM_MEDIUM);
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF3;
                    end
                    BUF4: begin
                        `uvm_info("rs_model", $sformatf("start decoding buffer 4"), UVM_MEDIUM);
                        decode(rcv_buf_4, dec_buf_4, isos_buf_4, rde_buf_4);
                        `uvm_info("rs_model", $sformatf("end decoding buffer 4"), UVM_MEDIUM);
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF4;
                    end
                    default: `uvm_error("rs_model", "maybe the fifo overflowed!")
                endcase
            end

            // write transactions to scoreboard
            forever begin
                case (DEC_BUF_DONE)
                    NONE: #`CLOCK_PERIOD;
                    BUF1: begin
                        `uvm_info("rs_model", $sformatf("start write dec block 1"), UVM_MEDIUM);
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_1[(192-8*i)`B -:64];
                            dec_tr.dec_isos = isos_buf_1[11-i/2];
                            dec_tr.RDE_ERROR = rde_buf_1;
                            ap.write(dec_tr);
                        end
                        `uvm_info("rs_model", $sformatf("end write dec block 1"), UVM_MEDIUM);
                        DEC_BUF_DONE = NONE;
                    end
                    BUF2: begin
                        `uvm_info("rs_model", $sformatf("start write dec block 2"), UVM_MEDIUM);
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_2[(192-8*i)`B -:64];
                            dec_tr.dec_isos = isos_buf_2[11-i/2];
                            dec_tr.RDE_ERROR = rde_buf_2;
                            ap.write(dec_tr);
                        end
                        `uvm_info("rs_model", $sformatf("end write dec block 2"), UVM_MEDIUM);
                        DEC_BUF_DONE = NONE;
                    end
                    BUF3: begin
                        `uvm_info("rs_model", $sformatf("start write dec block 3"), UVM_MEDIUM);
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_3[(192-8*i)`B -:64];
                            dec_tr.dec_isos = isos_buf_3[11-i/2];
                            dec_tr.RDE_ERROR = rde_buf_3;
                            ap.write(dec_tr);
                        end
                        `uvm_info("rs_model", $sformatf("end write dec block 3"), UVM_MEDIUM);
                        DEC_BUF_DONE = NONE;
                    end
                    BUF4: begin
                        `uvm_info("rs_model", $sformatf("start write dec block 4"), UVM_MEDIUM);
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_4[(192-8*i)`B -:64];
                            dec_tr.dec_isos = isos_buf_4[11-i/2];
                            dec_tr.RDE_ERROR = rde_buf_4;
                            ap.write(dec_tr);
                        end
                        `uvm_info("rs_model", $sformatf("end write dec block 4"), UVM_MEDIUM);
                        DEC_BUF_DONE = NONE;
                    end
                    default: `uvm_error("rs_model", "maybe the fifo overflowed!")
                endcase
            end
        join
    endtask // main_phase

    function void decode(bit [198`B:0] rcv_data, ref bit [192`B:0] dec, ref bit [11:0] isos, ref bit rde);
        bit [31:0]   syndrome;
        bit [23:0]   lambda;
        bit [15:0]   omega;
        bit [192`B:0] err_dec;
        bit [11:0]   err_isos;
        int          err_flag;

        `uvm_info("decode", $sformatf("rcv_data=%0h",rcv_data), UVM_HIGH);
        `uvm_info("decode", $sformatf("rcv_isos=%0h",rcv_data[6`B-4:4`B+1]), UVM_HIGH);

        // Calculate syndrome
        syn_cal(rcv_data, syndrome);
        `uvm_info("decode", $sformatf("syndrome=(%0d, %0d, %0d, %0d)",syndrome[31:24], syndrome[23:16], syndrome[15:8], syndrome[7:0]), UVM_HIGH);

        if (syndrome != 'b0) begin
            `ifdef RIBM1
                `uvm_info("decode", $sformatf("ribm2 and csee_h ref-model used."), UVM_HIGH);
                // Calculate kes
                kes_cal_ribm2(syndrome, lambda, omega);
                `uvm_info("decode", $sformatf("lambda=(%0d, %0d, %0d)",lambda[23:16],lambda[15:8],lambda[7:0]), UVM_HIGH);
                `uvm_info("decode", $sformatf("omega=(%0d, %0d)",omega[15:8],omega[7:0]), UVM_HIGH);

                // Calculate err_val and err_num
                csee_h(lambda, omega, err_dec, err_isos, err_flag);
                `uvm_info("decode", $sformatf("err_data=%0h",err_dec), UVM_HIGH);
                `uvm_info("decode", $sformatf("err_isos=%0h",err_isos), UVM_HIGH);
            `else
            `ifdef RIBM2
                `uvm_info("decode", $sformatf("ribm2 and csee_h ref-model used."), UVM_HIGH);
                // Calculate kes
                kes_cal_ribm2(syndrome, lambda, omega);
                `uvm_info("decode", $sformatf("lambda=(%0d, %0d, %0d)",lambda[23:16],lambda[15:8],lambda[7:0]), UVM_HIGH);
                `uvm_info("decode", $sformatf("omega=(%0d, %0d)",omega[15:8],omega[7:0]), UVM_HIGH);

                // Calculate err_val and err_num
                csee_h(lambda, omega, err_dec, err_isos, err_flag);
                `uvm_info("decode", $sformatf("err_data=%0h",err_dec), UVM_HIGH);
                `uvm_info("decode", $sformatf("err_isos=%0h",err_isos), UVM_HIGH);
            `else
                `uvm_info("decode", $sformatf("dcme2 and csee ref-model used."), UVM_HIGH);
                // Calculate kes
                kes_cal_dcme2(syndrome, lambda, omega);
                `uvm_info("decode", $sformatf("lambda=(%0d, %0d, %0d)",lambda[23:16],lambda[15:8],lambda[7:0]), UVM_HIGH);
                `uvm_info("decode", $sformatf("omega=(%0d, %0d)",omega[15:8],omega[7:0]), UVM_HIGH);

                // Calculate err_val and err_num
                csee(lambda, omega, err_dec, err_isos, err_flag);
                `uvm_info("decode", $sformatf("err_data=%0h",err_dec), UVM_HIGH);
                `uvm_info("decode", $sformatf("err_isos=%0h",err_isos), UVM_HIGH);
            `endif // RIBM2
            `endif // RIBM1

            // Decode and return the result
            dec  = err_dec  ^ rcv_data[198`B:48];
            isos = err_isos ^ rcv_data[43:32];
            rde  = err_flag;
            `uvm_info("decode", $sformatf("dec_data=%0h",dec), UVM_HIGH);
            `uvm_info("decode", $sformatf("dec_isos=%0h",isos), UVM_HIGH);
        end else begin
            dec  = rcv_data[198`B:48];
            isos = rcv_data[43:32];
            rde  = 0;
            `uvm_info("decode", $sformatf("dec_data=%0h",dec), UVM_HIGH);
            `uvm_info("decode", $sformatf("dec_isos=%0h",isos), UVM_HIGH);
        end
    endfunction // decode

    function void syn_cal(bit [198`B:0] rcv_data, ref bit [31:0] syndrome);
        parameter ALPHA0 = 8'd1;
        parameter ALPHA1 = 8'd2;
        parameter ALPHA2 = 8'd4;
        parameter ALPHA3 = 8'd8;
        bit [7:0] S0 = 8'b0, S1 = 8'b0, S2 = 8'b0, S3 = 8'b0;
        bit [7:0] SA1, SA2, SA3;
        bit [7:0] temp_byte;

        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            temp_byte = rcv_data[(198-i)`B -:8];
            rs_utils::gf2m8_multi(S1, ALPHA1, SA1);
            rs_utils::gf2m8_multi(S2, ALPHA2, SA2);
            rs_utils::gf2m8_multi(S3, ALPHA3, SA3);
            S0  = S0  ^ temp_byte;
            S1  = SA1 ^ temp_byte;
            S2  = SA2 ^ temp_byte;
            S3  = SA3 ^ temp_byte;
        end
        syndrome = {S0, S1, S2, S3};
    endfunction // syn_cal

    function void kes_cal_dcme2(bit [31:0] S, ref bit[23:0] lambda, ref bit [15:0] omega);
        bit [7:0] R0=0, R1=0, R2=0, R3=0, R4=0, R5=0, R6=1;
        bit [7:0] Q0=1, Q1=0, Q2=0, Q3=S[31:24], Q4=S[23:16], Q5=S[15:8], Q6=S[7:0];
        int degR = 2*`T;
        int degQ = 2*`T-1;
        bit [7:0] a, b;
        int temp_degR;
        bit [7:0] temp_R0, temp_R1, temp_R2, temp_R3, temp_R4, temp_R5, temp_R6;
        bit [7:0] aq0, aq1, aq2, aq3, aq4, aq5;
        bit [7:0] br0, br1, br2, br3, br4, br5;

        for (integer i = 0; i < 2*`T; i++) begin
            if (degR < `T) begin
                continue; // Skip the calculation if degR is less than `T (t)
            end else begin
                // degR >= `T
                a = R6;
                b = Q6;
                `uvm_info("kescal", $sformatf("%0d-s R=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",i,R0,R1,R2,R3,R4,R5,R6), UVM_HIGH);
                `uvm_info("kescal", $sformatf("%0d-s Q=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",i,Q0,Q1,Q2,Q3,Q4,Q5,Q6), UVM_HIGH);
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
                    rs_utils::gf2m8_multi(a, Q0, aq0);
                    rs_utils::gf2m8_multi(a, Q1, aq1);
                    rs_utils::gf2m8_multi(a, Q2, aq2);
                    rs_utils::gf2m8_multi(a, Q3, aq3);
                    rs_utils::gf2m8_multi(a, Q4, aq4);
                    rs_utils::gf2m8_multi(a, Q5, aq5);
                    rs_utils::gf2m8_multi(b, R0, br0);
                    rs_utils::gf2m8_multi(b, R1, br1);
                    rs_utils::gf2m8_multi(b, R2, br2);
                    rs_utils::gf2m8_multi(b, R3, br3);
                    rs_utils::gf2m8_multi(b, R4, br4);
                    rs_utils::gf2m8_multi(b, R5, br5);

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
                    rs_utils::gf2m8_multi(a, Q0, aq0);
                    rs_utils::gf2m8_multi(a, Q1, aq1);
                    rs_utils::gf2m8_multi(a, Q2, aq2);
                    rs_utils::gf2m8_multi(a, Q3, aq3);
                    rs_utils::gf2m8_multi(a, Q4, aq4);
                    rs_utils::gf2m8_multi(a, Q5, aq5);
                    rs_utils::gf2m8_multi(b, R0, br0);
                    rs_utils::gf2m8_multi(b, R1, br1);
                    rs_utils::gf2m8_multi(b, R2, br2);
                    rs_utils::gf2m8_multi(b, R3, br3);
                    rs_utils::gf2m8_multi(b, R4, br4);
                    rs_utils::gf2m8_multi(b, R5, br5);

                    // Update R values
                    R0 = 0;
                    R1 = aq0 ^ br0;
                    R2 = aq1 ^ br1;
                    R3 = aq2 ^ br2;
                    R4 = aq3 ^ br3;
                    R5 = aq4 ^ br4;
                    R6 = aq5 ^ br5;
                end
                `uvm_info("kescal", $sformatf("%0d-p R=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",i,R0,R1,R2,R3,R4,R5,R6), UVM_HIGH);
                `uvm_info("kescal", $sformatf("%0d-p Q=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",i,Q0,Q1,Q2,Q3,Q4,Q5,Q6), UVM_HIGH);
            end
        end

        lambda = {R2, R3, R4}; // l0, l1, l2 = R2, R3, R4;
        omega  = {R5, R6}; // o0, o1 = R5, R6;
    endfunction // kes_cal_dcme2

    function void csee(bit [23:0] lambda, bit [15:0] omega, ref bit [192`B:0] err_dec, ref bit [11:0] err_isos, ref int err_flag);
        parameter ALPHA0   = 8'd1;
        parameter ALPHA1   = 8'd2;
        parameter ALPHA2   = 8'd4;
        parameter ALPHA58  = 8'd105;
        parameter ALPHA116 = 8'd248;
        bit [7:0] a0 = lambda[23:16], a1 = lambda[15:8], a2 = lambda[7:0];
        bit [7:0] b0 = omega[15:8], b1 = omega[7:0];
        bit [7:0] sum_chk;
        bit [7:0] err_val;
        bit [198`B:0] error_val = 0;
        int error_num = 0;

        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            // s_utils::gf2m8_multi(a0, ALPHA0, a0);
            rs_utils::gf2m8_multi(a1, ((i == 0) ? ALPHA58 : ALPHA1),  a1);
            rs_utils::gf2m8_multi(a2, ((i == 0) ? ALPHA116 : ALPHA2), a2);
            // rs_utils::gf2m8_multi(b0, ALPHA0, b0);
            rs_utils::gf2m8_multi(b1, ((i == 0) ? ALPHA58 : ALPHA1),  b1);

            sum_chk = a0 ^ a1 ^ a2;
            if (sum_chk == 'b0) begin
                error_num = error_num + 1;
                rs_utils::gf2m8_divid((b0 ^ b1), a1, err_val);
                error_val = {error_val[197`B:0], err_val};
                `uvm_info("csee", $sformatf("%0d: sum_chk = %0b",i,sum_chk), UVM_HIGH);
                `uvm_info("csee", $sformatf("err_val = %0h",err_val), UVM_HIGH);
                `uvm_info("csee", $sformatf("err_num = %0d",error_num), UVM_HIGH);
            end else begin
                error_val = {error_val[197`B:0], 8'd0};
            end
        end

        `uvm_info("rs_model", $sformatf("decoded error num is %0d", error_num), UVM_MEDIUM);
        err_dec  = error_val[198`B:6`B+1];
        err_isos = error_val[6`B-4:4`B+1];
        err_flag = (error_num == 0 || error_num > 2) ? 'b1 : 'b0;;
    endfunction // csee

    function void kes_cal_ribm2(bit [31:0] S, ref bit[23:0] lambda, ref bit [15:0] omega);
        bit [7:0] Delta0=S[31:24], Delta1=S[23:16], Delta2=S[15:8], Delta3=S[7:0], Delta4=0, Delta5=0, Delta6=1;
        bit [7:0] Gamma0=1, Gamma1=0, Gamma2=0, Gamma3=0, Gamma4=0, Gamma5=0, Gamma6=0;

        bit [7:0] delta, gamma;
        int L = 0;
        bit [7:0] temp_Delta0, temp_Delta1, temp_Delta2, temp_Delta3, temp_Delta4, temp_Delta5, temp_Delta6;
        bit [7:0] dG1, dG2, dG3, dG4, dG5, dG6;
        bit [7:0] gD1, gD2, gD3, gD4, gD5, gD6;

        for (integer K = 0; K < 2*`T; K++) begin
            // degDelta >= `T
            delta = Delta0;
            gamma = Gamma0;
            `uvm_info("kescal", $sformatf("%0d-s Delta=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",K,Delta0,Delta1,Delta2,Delta3,Delta4,Delta5,Delta6), UVM_HIGH);
            `uvm_info("kescal", $sformatf("%0d-s Gamma=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",K,Gamma0,Gamma1,Gamma2,Gamma3,Gamma4,Gamma5,Gamma6), UVM_HIGH);
            
            // Multiplications
            rs_utils::gf2m8_multi(delta, Gamma1, dG1);
            rs_utils::gf2m8_multi(delta, Gamma2, dG2);
            rs_utils::gf2m8_multi(delta, Gamma3, dG3);
            rs_utils::gf2m8_multi(delta, Gamma4, dG4);
            rs_utils::gf2m8_multi(delta, Gamma5, dG5);
            rs_utils::gf2m8_multi(delta, Gamma6, dG6);
            rs_utils::gf2m8_multi(gamma, Delta1, gD1);
            rs_utils::gf2m8_multi(gamma, Delta2, gD2);
            rs_utils::gf2m8_multi(gamma, Delta3, gD3);
            rs_utils::gf2m8_multi(gamma, Delta4, gD4);
            rs_utils::gf2m8_multi(gamma, Delta5, gD5);
            rs_utils::gf2m8_multi(gamma, Delta6, gD6);
            
            if (delta != 0 && L<<1 <= K) begin //di!=0 && 2L<=K
                // switch
                L = K + 1 - L;
                // Update Gamma values
                Gamma0 = Delta0;
                Gamma1 = Delta1;
                Gamma2 = Delta2;
                Gamma3 = Delta3;
                Gamma4 = Delta4;
                Gamma5 = Delta5;
                Gamma6 = Delta6;
            end
            // Update Delta values
            Delta0 = dG1 ^ gD1;
            Delta1 = dG2 ^ gD2;
            Delta2 = dG3 ^ gD3;
            Delta3 = dG4 ^ gD4;
            Delta4 = dG5 ^ gD5;
            Delta5 = dG6 ^ gD6;
            Delta6 = 0;

            `uvm_info("kescal", $sformatf("%0d-p Delta=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",K,Delta0,Delta1,Delta2,Delta3,Delta4,Delta5,Delta6), UVM_HIGH);
            `uvm_info("kescal", $sformatf("%0d-p Gamma=(%0d,%0d,%0d,%0d,%0d,%0d,%0d)",K,Gamma0,Gamma1,Gamma2,Gamma3,Gamma4,Gamma5,Gamma6), UVM_HIGH);
        end

        lambda = {Delta2, Delta3, Delta4}; // l0, l1, l2 = Delta2, Delta3, Delta4;
        omega  = {Delta0, Delta1}; // o0, o1 = Delta0, Delta1;
    endfunction // kes_cal_ribm2

    function void csee_h(bit [23:0] lambda, bit [15:0] omega, ref bit [192`B:0] err_dec, ref bit [11:0] err_isos, ref int err_flag);
        parameter ALPHA0   = 8'd1;
        parameter ALPHA1   = 8'd2;
        parameter ALPHA2   = 8'd4;
        parameter ALPHA58  = 8'd105;
        parameter ALPHA116 = 8'd248;
        parameter ALPHA4   = 8'd16;
        parameter ALPHA5   = 8'd32;
        parameter ALPHA232 = 8'd247;
        parameter ALPHA35  = 8'd156;
        bit [7:0] a0 = lambda[23:16], a1 = lambda[15:8], a2 = lambda[7:0];
        bit [7:0] b0 = omega[15:8], b1 = omega[7:0];
        bit [7:0] sum_chk;
        bit [7:0] err_val;
        bit [198`B:0] error_val = 0;
        int error_num = 0;

        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            // s_utils::gf2m8_multi(a0, ALPHA0, a0);
            rs_utils::gf2m8_multi(a1, ((i == 0) ? ALPHA58 : ALPHA1),  a1);
            rs_utils::gf2m8_multi(a2, ((i == 0) ? ALPHA116 : ALPHA2), a2);
            rs_utils::gf2m8_multi(b0, ((i == 0) ? ALPHA232 : ALPHA4), b0);
            rs_utils::gf2m8_multi(b1, ((i == 0) ? ALPHA35 : ALPHA5),  b1);

            sum_chk = a0 ^ a1 ^ a2;
            if (sum_chk == 'b0) begin
                error_num = error_num + 1;
                rs_utils::gf2m8_divid((b0 ^ b1), a1, err_val);
                error_val = {error_val[197`B:0], err_val};
                `uvm_info("csee", $sformatf("%0d: sum_chk = %0b",i,sum_chk), UVM_HIGH);
                `uvm_info("csee", $sformatf("err_val = %0h",err_val), UVM_HIGH);
                `uvm_info("csee", $sformatf("err_num = %0d",error_num), UVM_HIGH);
            end else begin
                error_val = {error_val[197`B:0], 8'd0};
            end
        end

        `uvm_info("rs_model", $sformatf("decoded error num is %0d", error_num), UVM_MEDIUM);
        err_dec  = error_val[198`B:6`B+1];
        err_isos = error_val[6`B-4:4`B+1];
        err_flag = (error_num == 0 || error_num > 2) ? 'b1 : 'b0;;
    endfunction // csee_h

endclass //rs_model extends uvm_component

`endif // RS_MODEL__SV
