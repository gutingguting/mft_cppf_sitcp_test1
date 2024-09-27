`timescale 1ns / 1ps

module top_top(
    input gtrefclk_n,
    input gtrefclk_p,
    input sysclk_n,
    input sysclk_p,
    output txp,
    output txn,
    input rxp,
    input rxn
    );
    
    wire sysclk_125;
    wire refclk_125;
    wire reset;
    wire lock;
    wire gtrefclk;
    wire clk125;
    wire clk200;
    wire lock_1;
    
    
    
    
   IBUFDS #(
      .DIFF_TERM("true"),       // Differential Termination 
      .IOSTANDARD("LVDS")     // Specify the input I/O standard
   ) IBUFDS_inst_1 (
      .O(sysclk_125),  // Buffer output
      .I(sysclk_n),  // Diff_p buffer input (connect directly to top-level port)
      .IB(sysclk_p) // Diff_n buffer input (connect directly to top-level port)
   );
   
      IBUFDS #(
      .DIFF_TERM("true"),       // Differential Termination 
      .IOSTANDARD("LVDS")     // Specify the input I/O standard
   ) IBUFDS_inst_2 (
      .O(refclk_125),  // Buffer output
      .I(gtrefclk_p),  // Diff_p buffer input (connect directly to top-level port)
      .IB(gtrefclk_n) // Diff_n buffer input (connect directly to top-level port)
   );
//      BUFG BUFG_inst (
//      .O(clk200), // 1-bit output: Clock output
//      .I(sysclk_125)  // 1-bit input: Clock input
//   );
    
    clk_wiz_0 clk_inst
    (
    .clk_out1(clk125),
    .clk_out2(gtrefclk),    ///gtref clk 125
  // Status and control signals               
    .reset(1'b0), 
    .locked(lock),
 // Clock in ports
    .clk_in1(refclk_125)
    );
    
    clk_wiz_1 clk_inst_1
    (
    .clk_out1(clk200),
  // Status and control signals               
    .reset(1'b0), 
    .locked(lock_1),
 // Clock in ports
    .clk_in1(sysclk_125)
    );
    
    wire RBCP_ADDR;
    wire RBCP_WD;
    wire RBCP_WE;
    wire RBCP_RE;
    wire RBCP_ACT;
    wire RBCP_RD;
    wire RBCP_ACK;
    
    cppf_ethernet_top	sitcp
    (
		.sysclk125m(clk125),
		.clk200(clk200),	
        .clk200_locked_i (lock),
        		
        .gtrefclk_i  (gtrefclk),
//--      .GTH_REFCLK_P : in std_logic; 
//--      .GTH_REFCLK_N : in std_logic; 

		.txp (txp),
		.txn (txn),
		.rxp (rxp),
		.rxn(rxn), 
//		--.TCP related
        .TCP_OPEN_ACK(1'bz),  
        .SiTCP_RST   (1'bz), 
        .TCP_TX_FULL  (1'bz), 
        .TCP_TX_DATA (8'b00000000), 
//--      .  SiTCP_clk      :OUT STD_LOGIC;   --200MHz out
        .FIFO_RD_VALID (1'b0),
         
//        --RBCP(SlowControl related)                
        .RBCP_ADDR   (RBCP_ADDR),
        .RBCP_WD      (RBCP_WD), 
        .RBCP_WE     (RBCP_WE), 
        .RBCP_RE    (RBCP_RE), 
        .RBCP_ACT  (RBCP_ACT), 
        .RBCP_RD (RBCP_RD), 
        .RBCP_ACK (RBCP_ACK)
	);
    
endmodule
