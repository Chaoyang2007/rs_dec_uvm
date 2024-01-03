`ifndef RS_BASE_TEST__SV
`define RS_BASE_TEST__SV

class rs_base_test extends uvm_test;
    `uvm_component_utils(rs_base_test)

    rs_env  env;
    rs_vsqr vsqr;

    // Constructor
    function new(string name="rs_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction // new

    // Build phase to configure components
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env  = rs_env::type_id::create("env", this);
        vsqr = rs_vsqr::type_id::create("vsqr", this);
        uvm_top.set_timeout(100000ns,0);
    endfunction // build_phase

    // Connect phase to establish connections between components
    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        vsqr.sqr = env.i_agt.sqr;
    endfunction // connect_phase

    // Report phase to report test case passed or failed
    virtual function void report_phase(uvm_phase phase);
        uvm_report_server server;
        int               err_num;
        super.report_phase(phase);
        server  = get_report_server();
        err_num = server.get_severity_count(UVM_ERROR);
        if (err_num != 0) begin
            $display($time, "TEST CASE FAILED");
        end else begin
            $display($time, "TEST CASE PASSED");
        end
    endfunction // report_phase

endclass // rs_base_test

`endif // RS_BASE_TEST__SV
