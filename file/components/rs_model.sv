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

        bit [1583:0] rcv_buf_1,  rcv_buf_2,  rcv_buf_3,  rcv_buf_4;
        bit [1535:0] dec_buf_1,  dec_buf_2,  dec_buf_3,  dec_buf_4;
        bit [11:0]   isos_buf_1, isos_buf_2, isos_buf_3, isos_buf_4;
        bit          rde_buf_1,  rde_buf_2,  rde_buf_3,  rde_buf_4;

        bit [1:0]   RCV_BLOCK    = BLOCK1;
        bit [3:0]   RCV_BUF_DONE = NONE;
        bit [3:0]   DEC_BUF_DONE = NONE;
        integer     COUNT = 0;

        fork
            // get transactions from monitor
            forever begin
                port.get(tr);
                if(tr.rx_vld) begin
                    tr.print_rx("model get");
                    case (RCV_BLOCK)
                        BLOCK1: begin
                            $display($time, " rcv block 1");
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_1 = {rcv_buf_1[1519:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_1 = {rcv_buf_1[1535:0], tr.rx_data[63:16]}; // 6B
                                rcv_buf_2 = {rcv_buf_2[1567:0], tr.rx_data[15:0 ]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF1;
                                RCV_BLOCK = BLOCK2;
                            end
                        end
                        BLOCK2: begin
                            $display($time, " rcv block 2");
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_2 = {rcv_buf_2[1519:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_2 = {rcv_buf_2[1551:0], tr.rx_data[63:32]}; // 4B
                                rcv_buf_3 = {rcv_buf_3[1551:0], tr.rx_data[31:0 ]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF2;
                                RCV_BLOCK = BLOCK3;
                            end
                        end
                        BLOCK3: begin
                            $display($time, " rcv block 3");
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK) begin
                                rcv_buf_3 = {rcv_buf_3[1519:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_3 = {rcv_buf_3[1567:0], tr.rx_data[63:48]}; // 2B
                                rcv_buf_4 = {rcv_buf_4[1535:0], tr.rx_data[47:0 ]};
                                COUNT = 0;
                                RCV_BUF_DONE = BUF3;
                                RCV_BLOCK = BLOCK4;
                            end
                        end
                        BLOCK4: begin
                            $display($time, " rcv block 4");
                            if(COUNT < 2*`SYMBOLS_IN_BLOCK-1) begin
                                rcv_buf_4 = {rcv_buf_4[1519:0], tr.rx_data};
                                COUNT = COUNT + 1;
                            end else begin
                                rcv_buf_4 = {rcv_buf_4[1567:0], tr.rx_data}; // 
                                COUNT = 0;
                                RCV_BUF_DONE = BUF4;
                                RCV_BLOCK = BLOCK1;
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
                        $display($time, " start decoding buffer 1");
                        decode(rcv_buf_1, dec_buf_1, isos_buf_1, rde_buf_1);
                        $display($time, " end decoding buffer 1");
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF1;
                    end
                    BUF2: begin
                        $display($time, " start decoding buffer 2");
                        decode(rcv_buf_2, dec_buf_2, isos_buf_2, rde_buf_2);
                        $display($time, " end decoding buffer 2");
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF2;
                    end
                    BUF3: begin
                        $display($time, " start decoding buffer 3");
                        decode(rcv_buf_3, dec_buf_3, isos_buf_3, rde_buf_3);
                        $display($time, " end decoding buffer 3");
                        RCV_BUF_DONE = NONE;
                        DEC_BUF_DONE = BUF3;
                    end
                    BUF4: begin
                        $display($time, " start decoding buffer 4");
                        decode(rcv_buf_4, dec_buf_4, isos_buf_4, rde_buf_4);
                        $display($time, " end decoding buffer 4");
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
                        $display($time, " start write dec block 1");
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_1[1535-64*i-:64];
                            dec_tr.dec_isos = isos_buf_1[i/2];
                            dec_tr.RDE_ERROR = rde_buf_1;
                            ap.write(dec_tr);
                            dec_tr.print_dec("model write");
                        end
                        $display($time, " end write dec block 1");
                        DEC_BUF_DONE = NONE;
                    end
                    BUF2: begin
                        $display($time, " start write dec block 2");
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_2[1535-64*i-:64];
                            dec_tr.dec_isos = isos_buf_2[i/2];
                            dec_tr.RDE_ERROR = rde_buf_2;
                            ap.write(dec_tr);
                            dec_tr.print_dec("model write");
                        end
                        $display($time, " end write dec block 2");
                        DEC_BUF_DONE = NONE;
                    end
                    BUF3: begin
                        $display($time, " start write dec block 3");
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_3[1535-64*i-:64];
                            dec_tr.dec_isos = isos_buf_3[i/2];
                            dec_tr.RDE_ERROR = rde_buf_3;
                            ap.write(dec_tr);
                            dec_tr.print_dec("model write");
                        end
                        $display($time, " end write dec block 3");
                        DEC_BUF_DONE = NONE;
                    end
                    BUF4: begin
                        $display($time, " start write dec block 4");
                        for (integer i = 0; i < 2*`SYMBOLS_IN_BLOCK; i++) begin
                            dec_tr = new();
                            dec_tr.dec_vld  = 'b1;
                            dec_tr.dec_data = dec_buf_4[1535-64*i-:64];
                            dec_tr.dec_isos = isos_buf_4[i/2];
                            dec_tr.RDE_ERROR = rde_buf_4;
                            ap.write(dec_tr);
                            dec_tr.print_dec("model write");
                        end
                        $display($time, " end write dec block 4");
                        DEC_BUF_DONE = NONE;
                    end
                    default: `uvm_error("rs_model", "maybe the fifo overflowed!")
                endcase
            end
        join
    endtask // main_phase

    function void decode(bit [1583:0] rcv_data, ref bit [1535:0] dec, ref bit [11:0] isos, ref bit rde);
        bit [31:0]   syndrome;
        bit [23:0]   lambda;
        bit [15:0]   omega;
        bit [1535:0] err_dec;
        bit [11:0]   err_isos;
        int          err_flag;

        // Calculate syndrome
        $display($time, " start syn_cal");
        syn_cal(rcv_data, syndrome);
        $display($time, " end syn_cal");

        if (syndrome != 'b0) begin
            // Calculate kes
            $display($time, " start kes_cal");
            kes_cal(syndrome, lambda, omega);
            $display($time, " end kes_cal");

            // Calculate err_val and err_num
            $display($time, " start csee");
            csee(lambda, omega, err_dec, err_isos, err_flag);
            $display($time, " end csee");

            // Decode and return the result
            dec  = err_dec  ^ rcv_data[1583:48];
            isos = err_isos ^ rcv_data[43:32];
            rde  = err_flag;
        end else begin
            dec  = rcv_data[1583:48];
            isos = rcv_data[43:32];
            rde  = 0;
        end
    endfunction // decode

    function void syn_cal(bit [1583:0] rcv_data, ref bit [31:0] syndrome);
        parameter ALPHA0 = 8'd1;
        parameter ALPHA1 = 8'd2;
        parameter ALPHA2 = 8'd4;
        parameter ALPHA3 = 8'd8;
        bit [7:0] S0 = 8'b0, S1 = 8'b0, S2 = 8'b0, S3 = 8'b0;
        bit [7:0] SA1, SA2, SA3;
        bit [7:0] temp_byte;

        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            temp_byte = rcv_data[1583-8*i-:8];
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

    function void kes_cal(bit [31:0] S, ref bit[23:0] lambda, ref bit [15:0] omega);
        bit [7:0] R0=0, R1=0, R2=0, R3=0, R4=0, R5=0, R6=1;
        bit [7:0] Q0=0, Q1=0, Q2=0, Q3=S[31:24], Q4=S[23:16], Q5=S[15:8], Q6=S[7:0];
        int degR = 2*`ERROR_CORRECTION_ABILITY;
        int degQ = 2*`ERROR_CORRECTION_ABILITY-1;
        bit [7:0] a, b;
        int temp_degR;
        bit [7:0] temp_R0, temp_R1, temp_R2, temp_R3, temp_R4, temp_R5, temp_R6;
        bit [7:0] aq0, aq1, aq2, aq3, aq4, aq5;
        bit [7:0] br0, br1, br2, br3, br4, br5;

        for (integer i = 0; i < 2*`ERROR_CORRECTION_ABILITY; i++) begin
            if (degR < `ERROR_CORRECTION_ABILITY) begin
                continue; // Skip the calculation if degR is less than `ERROR_CORRECTION_ABILITY (t)
            end else begin
                // degR >= `ERROR_CORRECTION_ABILITY
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
            end
        end

        lambda = {R2, R3, R4}; // l0, l1, l2 = R2, R3, R4;
        omega  = {R5, R6}; // o0, o1 = R5, R6;
    endfunction // kes_cal

    function void csee(bit [23:0] lambda, bit [15:0] omega, ref bit [1535:0] err_dec, ref bit [11:0] err_isos, ref int err_flag);
        parameter ALPHA0   = 8'd1;
        parameter ALPHA1   = 8'd2;
        parameter ALPHA2   = 8'd4;
        parameter ALPHA58  = 8'd105;
        parameter ALPHA116 = 8'd248;
        bit [7:0] a0 = lambda[23:16], a1 = lambda[15:8], a2 = lambda[7:0];
        bit [7:0] b0 = omega[15:8], b1 = omega[7:0];
        bit [7:0] sum_chk;
        bit [7:0] error;
        bit [1583:0] error_val = 0;
        int error_num = 0;

        for (integer i = 0; i < `FEC_BLOCK_SIZE; i++) begin
            // s_utils::gf2m8_multi(a0, ALPHA0, a0);
            rs_utils::gf2m8_multi(a1, ((i == 0) ? ALPHA58 : ALPHA1),  a1);
            rs_utils::gf2m8_multi(a2, ((i == 0) ? ALPHA116 : ALPHA2), a2);
            // rs_utils::gf2m8_multi(b0, ALPHA0, b0);
            rs_utils::gf2m8_multi(b1, ((i == 0) ? ALPHA58 : ALPHA1),  b1);

            sum_chk = a0 ^ a1 ^ a2;

            if (sum_chk == 0) begin
                error_num = error_num + 1;
                rs_utils::gf2m8_divid(b0 ^ b1, a1, error);
                error_val = {error_val[1575:0], error};
            end else begin
                error_val = {error_val[1575:0], 8'd0};
            end
        end

        err_dec  = error_val[1583:48];
        err_isos = error_val[43:32];
        $display($time, " error_num=%d", error_num);
        err_flag = (error_num == 0 || error_num > 2) ? 'b1 : 'b0;;
    endfunction // csee

endclass //rs_model extends uvm_component

`endif // RS_MODEL__SV
