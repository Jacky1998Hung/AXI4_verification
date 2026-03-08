// Code your testbench here
`include "uvm_macros.svh"
import uvm_pkg::*;

interface axi_if(input logic clk, input logic rst_n);
  //================================================================
  //AXI4 WRITE ADDRESS CHANNEL
  //================================================================
  
  logic awvalid;
  
  //================================================================
  //AXI4 WRITE DATA CHANNEL
  //================================================================
  
  logic wvalid;
 
  //================================================================
  //AXI4 WRITE RESPONSE CHANNEL
  //================================================================
  
  logic bvalid;
  
   //================================================================
  //AXI4 READ ADDRESS CHANNEL
  //================================================================
  
  logic arvalid;
   //================================================================
  //AXI4 READ DATA CHANNEL
  //================================================================
  
  logic rvalid;
 
      // The earliest point after reset that a master is permitted to begin driving ARVALID, AWVALID, or WVALID HIGH is at a rising ACLK edge after ARESETn is HIGH. 
    property p_awvalid_rise_timing;
      @(posedge clk) $rose(rst_n) |-> !awvalid && !wvalid && !arvalid
    endproperty
  ap_awvalid_rise_timing : assert property(p_awvalid_rise_timing) begin
        // 成功時通常不顯示訊息以保持 Log 乾淨，若要顯示可用 uvm_info
        `uvm_info("AXI_PROT", "AXI Reset Protocol check passed: Master signals are LOW at reset release.", UVM_HIGH)
    end else begin
        // 失敗時使用 uvm_error，這會自動計入 UVM Error Count
        `uvm_error("AXI_RST_ERR", $sformatf("Master valid signals rose too early after rst_n rose at %0t!", $time))
    end
      
      
endinterface

module tb;
  logic clk;
  logic rst_n;
  axi_if vif(clk, rst_n);
  
  initial begin
    clk = 0;
    rst_n = 0; //active_low
  end
  
  always #5 clk = ~clk; //100MHz
  
 initial begin 
   vif.awvalid = 0;
   #10;
   rst_n = 1;
   vif.awvalid = 1;
 end
  
  initial begin
    $dumpfile("dump1.vcd");
    $dumpvars;   
    $assertvacuousoff(0);
    #100;
    $finish();
  end
  
  
  
endmodule
