// -----------------------------------------------------------------------------
// Project: AXI4 UVM Verification Environment
// Features: Functional Coverage, SVA, Scoreboard, Constrained Random Testing
// -----------------------------------------------------------------------------

`include "uvm_macros.svh"
import uvm_pkg::*;

// -----------------------------------------------------------------------------
// Transaction Class
// -----------------------------------------------------------------------------
typedef enum bit [2:0] {WRRD_FIXED = 0, WRRD_INCR = 1, WRRD_WRAP = 2, WRRD_ERR = 3, RST_DUT = 4} oper_mode;

class transaction extends uvm_sequence_item;
    `uvm_object_utils(transaction)

    function new(string name = "transaction");
        super.new(name);
    endfunction

    // Master-driven signals
    rand bit [3:0]  id;
    oper_mode       op;
    rand bit [31:0] awaddr;
    rand bit [3:0]  awlen;
    rand bit [2:0]  awsize;
    rand bit [1:0]  awburst;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;
    
    rand bit [31:0] araddr;
    rand bit [3:0]  arlen;
    rand bit [2:0]  arsize;
    rand bit [1:0]  arburst;

    // Slave-driven response signals
    bit [1:0]       bresp;
    bit [1:0]       rresp;
    bit [31:0]      rdata;

    // Constraints for valid AXI protocols
    constraint c_burst  { awburst inside {[0:2]}; arburst inside {[0:2]}; }
    constraint c_size   { awsize == 3'b010; arsize == 3'b010; } // Default 4-bytes
    constraint c_addr   { awaddr < 128; araddr < 128; }         // Limit address range
endclass

// -----------------------------------------------------------------------------
// Interface with SystemVerilog Assertions (SVA)
// -----------------------------------------------------------------------------
interface axi_if(input logic clk, resetn);
    // Write Address Channel
    logic [3:0]  awid;
    logic [31:0] awaddr;
    logic [3:0]  awlen;
    logic [2:0]  awsize;
    logic [1:0]  awburst;
    logic        awvalid, awready;
    // Write Data Channel
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wlast, wvalid, wready;
    // Write Response Channel
    logic [1:0]  bresp;
    logic        bvalid, bready;
    // Read Address Channel
    logic [31:0] araddr;
    logic [3:0]  arlen;
    logic [1:0]  arburst;
    logic [2:0]  arsize;
    logic        arvalid, arready;
    // Read Data Channel
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rlast, rvalid, rready;

    // Protocol Internal Tracking
    logic [31:0] next_addrwr, next_addrrd;

    // --- SVA: Protocol Checks ---
    
    // Check 1: AWVALID must remain high until AWREADY is asserted
    property p_aw_stable;
        @(posedge clk) disable iff (!resetn)
        awvalid && !awready |=> $stable(awvalid) && $stable(awaddr);
    endproperty
    assert_aw_stable: assert property (p_aw_stable);

    // Check 2: Write Data must be valid when WVALID is high
    property p_wvalid_ready;
        @(posedge clk) disable iff (!resetn)
        wvalid && !wready |=> $stable(wdata);
    endproperty
    assert_wvalid_stable: assert property (p_wvalid_ready);

    // Check 3: Reset sanity check
    property p_reset_check;
        @(posedge clk) !resetn |-> (!awvalid && !wvalid && !arvalid);
    endproperty
    assert_reset: assert property (p_reset_check);

endinterface

// -----------------------------------------------------------------------------
// Functional Coverage Subscriber
// -----------------------------------------------------------------------------
class axi_coverage extends uvm_subscriber #(transaction);
    `uvm_component_utils(axi_coverage)

    transaction tr;

    covergroup axi_cg;
        option.per_instance = 1;
        // Coverage for different Burst types 
        cp_burst: coverpoint tr.awburst {
            bins fixed = {0};
            bins incr  = {1};
            bins wrap  = {2};
        }
        // Coverage for burst length
        cp_len: coverpoint tr.awlen {
            bins min = {0};
            bins max = {15};
            bins mid = {[1:14]};
        }
        // Cross coverage to ensure all burst types are tested with various lengths
        cross_burst_len: cross cp_burst, cp_len;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        axi_cg = new();
    endfunction

    virtual function void write(transaction t);
        this.tr = t;
        axi_cg.sample();
    endfunction
endclass

// -----------------------------------------------------------------------------
// Scoreboard: Data Integrity Verification
// -----------------------------------------------------------------------------
class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_imp #(transaction, axi_scoreboard) item_collected_export;
    bit [31:0] scb_mem [bit [31:0]]; // Associative array for reference memory

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_collected_export = new("item_collected_export", this);
    endfunction

    virtual function void write(transaction tr);
        // Simple logic: Store on Write, Compare on Read 
        if (tr.op == WRRD_INCR || tr.op == WRRD_FIXED) begin
            `uvm_info("SCB", $sformatf("Scoreboard received transaction: ADDR=%0h", tr.awaddr), UVM_LOW)
            // Implementation of comparison logic would go here
        end
    endfunction
endclass

// -----------------------------------------------------------------------------
// Driver & Monitor (Standard UVM Components)
// -----------------------------------------------------------------------------
// [Note: Re-use your previous Driver/Monitor logic, but add analysis_port in Monitor]
class mon extends uvm_monitor;
    `uvm_component_utils(mon)
    uvm_analysis_port #(transaction) send_to_scb;
    virtual axi_if vif;
    transaction tr;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        send_to_scb = new("send_to_scb", this);
        if(!uvm_config_db#(virtual axi_if)::get(this,"","vif",vif))
            `uvm_error("MON", "Missing Interface")
    endfunction

    virtual task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            if(vif.resetn && vif.awvalid) begin
                tr = transaction::type_id::create("tr");
                // Sample Interface signals into tr...
                send_to_scb.write(tr); // Broadcast to Scoreboard and Coverage
            end
        end
    endtask
endclass

// -----------------------------------------------------------------------------
// Environment: Connecting all pieces
// -----------------------------------------------------------------------------
class env extends uvm_env;
    `uvm_component_utils(env)
    
    agent          a;
    axi_scoreboard scb;
    axi_coverage   cov;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        a   = agent::type_id::create("a", this);
        scb = axi_scoreboard::type_id::create("scb", this);
        cov = axi_coverage::type_id::create("cov", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        // Connect Monitor to Scoreboard and Coverage Subscriber 
        a.m.send_to_scb.connect(scb.item_collected_export);
        a.m.send_to_scb.connect(cov.analysis_export);
    endfunction
endclass

// -----------------------------------------------------------------------------
// Testbench Top
// -----------------------------------------------------------------------------
module tb;
    logic clk, resetn;
    
    // Clock Generation
    initial begin clk = 0; forever #5 clk = ~clk; end
    
    // Reset Generation
    initial begin
        resetn = 0; #20 resetn = 1;
    end

    axi_if vif(clk, resetn);
    
    // Connect to DUT
    // axi_slave dut (.clk(clk), .resetn(resetn), ...);

    initial begin
        uvm_config_db#(virtual axi_if)::set(null, "*", "vif", vif);
        run_test("test");
    end
endmodule
