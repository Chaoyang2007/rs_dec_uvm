`ifndef RS_SCOREBOARD__SV
`define RS_SCOREBOARD__SV

class rs_scoreboard extends uvm_component;
    `uvm_component_utils(rs_scoreboard)

    rs_transaction  expect_queue[$];
    uvm_blocking_get_port #(rs_transaction) exp_port;
    uvm_blocking_get_port #(rs_transaction) act_port;

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // Build phase to configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        exp_port = new("exp_port", this);
        act_port = new("act_port", this);
    endfunction // build_phase

    // Reset phase to handle reset conditions
    task reset_phase(uvm_phase phase);
        super.reset_phase(phase);
        phase.raise_objection(this);
        expect_queue.delete();
        `uvm_info("rs_scoreboard", $sformatf("rs_scoreboard reset, expected queue is deleted"), UVM_MEDIUM);
        phase.drop_objection(this);
    endtask // reset_phase

    // Main phase to get and compare transactions
    virtual task main_phase(uvm_phase phase);
        super.main_phase(phase);
        fork
            monitor_mdl();
            compare_out();
        join
    endtask // main_phase

    // Monitor transactions from reference model
    task monitor_mdl();
        rs_transaction get_expect;
        int exp_cnt = 0;
        forever begin
            exp_port.get(get_expect);
            if (get_expect.dec_vld == 1) begin
                get_expect.print_dec("scoreboard get_expect");
                expect_queue.push_back(get_expect);
                `uvm_info("rs_scoreboard", $sformatf("ref-model: %0d-th block, %0d-th half-symbol (data, isos)=(%0h, %0b).", (exp_cnt/24+1), (exp_cnt%24+1), get_expect.dec_data, get_expect.dec_isos), UVM_MEDIUM);
                exp_cnt = exp_cnt + 1;
            end
        end
    endtask // monitor_mdl

    // Compare transactions from model with DUT out
    task compare_out();
        rs_transaction get_actual;
        rs_transaction temp_data;
        int act_cnt = 0;
        forever begin
            act_port.get(get_actual);
            if (get_actual.dec_vld == 1) begin
                get_actual.print_dec("scoreboard get_actual");
                if (expect_queue.size()) begin
                    temp_data = expect_queue.pop_front();
                    if (exp_eq_act(get_actual, temp_data)) begin
                        `uvm_info("rs_scoreboard", $sformatf("DUT: %0d-th block, %0d-th half-symbol (data, isos)=(%0h, %0b).", (act_cnt/24+1), (act_cnt%24+1), get_actual.dec_data, get_actual.dec_isos), UVM_MEDIUM);
                        if (act_cnt%24 == 23) begin
                            if (get_actual.RDE_ERROR == temp_data.RDE_ERROR) begin
                                `uvm_info("rs_scoreboard", $sformatf("%s: %0d-th block decoding %s", get_actual.RDE_ERROR ? "interrupt" : "information", (act_cnt/24+1), get_actual.RDE_ERROR ? "error!" : "done."), UVM_LOW);
                            end else begin
                                `uvm_error("rs_scoreboard", $sformatf("error: %0d-th block decoding result is different, (model, dut)=(%0b, %0b)!", (act_cnt/24+1), temp_data.RDE_ERROR, get_actual.RDE_ERROR))
                            end
                        end
                    end else begin
                        `uvm_error("rs_scoreboard", $sformatf("DUT: %0d-th block, %0d-th half-symbol (data, isos)=(%0h, %0b), unmatched to ref-model half-symbol (data, isos)=(%0h, %0b)!", (act_cnt/24+1), (act_cnt%24+1), get_actual.dec_data, get_actual.dec_isos, temp_data.dec_data, temp_data.dec_isos))
                    end
                end else begin
                    `uvm_error("rs_scoreboard", $sformatf("DUT: %0d-th block, %0d-th half-symbol (data, isos)=(%0h, %0b), while expected (ref_model) is empty!", (act_cnt/24+1), (act_cnt%24+1), get_actual.dec_data, get_actual.dec_isos))
                end
                act_cnt = act_cnt + 1;
            end
        end
    endtask // compare_out

    // Helper function to compare expected and actual transactions
    function bit exp_eq_act(rs_transaction get_actual, rs_transaction temp_data);
        return (get_actual.dec_data == temp_data.dec_data) & (get_actual.dec_isos == temp_data.dec_isos);
    endfunction // exp_eq_act
endclass // rs_scoreboard

`endif // RS_SCOREBOARD__SV
