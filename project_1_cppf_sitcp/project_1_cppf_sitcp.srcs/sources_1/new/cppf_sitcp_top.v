`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:24:42 07/28/2018 
// Design Name: 
// Module Name:    cppf_sitcp_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module
	cppf_sitcp_top(
	// System	
	   input wire        SYSCLK_200M       ,
       input wire        LOCKED       ,

	// EtherNet
		output	wire			GMII_RSTn		,
		output	wire			GMII_TX_EN		,
		output	wire	[7:0]	GMII_TXD		,
		output	wire			GMII_TX_ER		,
		input	wire			GMII_TX_CLK		,
		output	wire			GMII_GTXCLK		,

		input	wire			GMII_RX_CLK		,
		input	wire			GMII_RX_DV		,
		input	wire	[7:0]	GMII_RXD		,
		input	wire			GMII_RX_ER		,
		input	wire			GMII_CRS		,
		input	wire			GMII_COL		,


        // Management IF
        output wire GMII_MDC			,	// out	: Clock for MDIO
        input  wire GMII_MDIO_IN		,	// in	: Data
        output wire GMII_MDIO_OUT		,	// out	: Data
        output wire GMII_MDIO_OE		,	// out	: MDIO output enable
        inout  wire	 GMII_MDIO		,
        
            //connect EEPROM
    //		inout	wire			I2C_SDA			,
    //		output	wire			I2C_SCL
        
        //TCP taking data            some more signals are needed
       output  wire TCP_OPEN_ACK,   //����         //~ACK
       output  wire SiTCP_RST,
       output  wire TCP_TX_FULL,                   //SiTCP_FIFO_full
       input   wire [7:0] TCP_TX_DATA,             //data_to_SiTCP
       //output  wire SiTCP_clk,
       input   wire FIFO_RD_VALID ,                 //SiTCP_FIFO_wr_en
    
        // SlowControl (if this can not work, we can switch to IPbus or maybe receive function)
       output wire    [31:0]         RBCP_ADDR    ,  //0x00000000--0xFFFEFFFF can be used 
       output wire    [7:0]         RBCP_WD        ,  //write data
       output wire                 RBCP_WE        ,    //write enable 
       output wire                 RBCP_RE        ,    //read enable
       output wire                  RBCP_ACT        ,  //bus operating 
       input      [7:0]             RBCP_RD        ,    //read data                        
       input                       RBCP_ACK            //acess response
	);


//------------------------------------------------------------------------------
//	Buffers
//------------------------------------------------------------------------------

//	wire			PLL_CLKFB		;
	wire			BUF_TX_CLK		;
//	wire			SiTCP_RST		;
//	wire			TCP_OPEN_ACK	;
	wire			TCP_CLOSE_REQ	;
	wire			TCP_RX_WR		;
	wire	[7:0]	TCP_RX_DATA		;
//	wire			TCP_TX_FULL		;
//	wire	[31:0]	RBCP_ADDR		;
//	wire	[7:0]	RBCP_WD			;
//	wire			RBCP_WE			;
//	wire			RBCP_RE			;
//	reg				TCP_CLOSE_ACK	;
//	wire	[7:0]	TCP_TX_DATA		;
//	reg				RBCP_ACK		;
//	reg		[7:0]	RBCP_RD			;
	reg		[31:0]	OFFSET_TEST		;
//	wire	[11:0]	FIFO_DATA_COUNT	;
//	wire			FIFO_RD_VALID	;
	reg				SYS_RSTn		;
	reg		[29:0]	INICNT			;
//	wire			SDI				;
//	wire			SDO				;
//	wire			SDT				;
//	wire			SCLK			;
//	wire			MUX_SDO			;
//	wire			MUX_SDT			;
//	wire			MUX_SCLK		;
//	wire			ROM_SDO			;
//	wire			ROM_SDT			;
//	wire			ROM_SCLK		;
//	wire			RST_I2Cselector	;
	reg				GMII_1000M;
	reg		[8:0]	CNT_CLK;
	reg				CNT_RST;
	reg				CNT_LD;
	reg		[6:0]	RX_CNT;
//	wire        CLK_125M_IN;

  

	//SYS_RSTn->off//
	always@(posedge SYSCLK_200M or negedge LOCKED)begin
		if (LOCKED == 1'b0) begin
			INICNT[29:0]	<=	30'd0;
			SYS_RSTn		<= 1'b0;
		end else begin
			INICNT[29:0]	<=	INICNT[29]? INICNT[29:0]:	(INICNT[29:0] + 30'd1);
			SYS_RSTn		<=	INICNT[29];
		end
	end


//	IOBUF	sda_buf( .O(SDI), .I(0), .T(SDT | SDO), .IO(I2C_SDA) );
//	OBUF	obufiic( .O(I2C_SCL), .I(SCLK));

	assign BUF_TX_CLK = GMII_TX_CLK ;

	always@(posedge SYSCLK_200M or negedge SYS_RSTn)begin
		if (~SYS_RSTn) begin
			CNT_CLK[8:0]	<=	9'b0;
			CNT_LD			<=	1'b0;
			CNT_RST			<=	1'b1;
			GMII_1000M		<=	1'b0;
		end else begin 
			CNT_CLK[8:0]	<=	CNT_CLK[8] ? 9'd198 : CNT_CLK[8:0] - 9'd1;
			CNT_LD			<=	CNT_CLK[8];
			CNT_RST			<=	CNT_LD;
			GMII_1000M		<=	CNT_LD ? RX_CNT[6] : GMII_1000M;
		end
	end
	
	always@(posedge GMII_RX_CLK or posedge CNT_RST)begin
//	always@(posedge SYSCLK_200M or posedge CNT_RST)begin
		if (CNT_RST) begin
			RX_CNT[6:0]		<=	7'd0;
		end else begin
			RX_CNT[6:0]		<=	RX_CNT[6] ? RX_CNT[6:0] : RX_CNT[6:0] + 7'd1;
		end
	end


	WRAP_SiTCP_GMII_XC7K_32K
    #(
        .TIM_PERIOD            (8'd200)                    // = System clock frequency(MHz), integer only
    )
	SiTCP	(
		.CLK				(SYSCLK_200M),					// in	: System Clock (MII: >15MHz, GMII>129MHz)
		.RST				(1'b0),					// in	: System reset
	// Configuration parameters
		.FORCE_DEFAULTn		(1'b0),			// in	: Load default parameters
		.EXT_IP_ADDR		(32'h0000_0000),			// in	: IP address[31:0]
		.EXT_TCP_PORT		(16'h0000),					// in	: TCP port #[15:0]
		.EXT_RBCP_PORT		(16'h0000),					// in	: RBCP port #[15:0]
		.PHY_ADDR			(5'b0_0111),				// in	: PHY-device MIF address[4:0]
	// EEPROM
		.EEPROM_CS			( 		),				// out	: Chip select
		.EEPROM_SK			( 		),				// out	: Serial data clock
		.EEPROM_DI			( 		),				// out	: Serial write data
		.EEPROM_DO			(1'b0			),				// in	: Serial read data
	// user data, intialial values are stored in the EEPROM, 0xFFFF_FC3C-3F
		.USR_REG_X3C		(),							// out	: Stored at 0xFFFF_FF3C
		.USR_REG_X3D		(),							// out	: Stored at 0xFFFF_FF3D
		.USR_REG_X3E		(),							// out	: Stored at 0xFFFF_FF3E
		.USR_REG_X3F		(),							// out	: Stored at 0xFFFF_FF3F
	// MII interface
		.GMII_RSTn			(GMII_RSTn),				// out	: PHY reset
//		.GMII_1000M			(GMII_1000M),				// in	: GMII mode (0:MII, 1:GMII)        by kouhj
		.GMII_1000M			(1'b1	),				// in	: GMII mode (0:MII, 1:GMII)
		// TX
		.GMII_TX_CLK		(BUF_TX_CLK),				// in	: Tx clock
		.GMII_TX_EN			(GMII_TX_EN),				// out	: Tx enable
		.GMII_TXD			(GMII_TXD[7:0]),			// out	: Tx data[7:0]
		.GMII_TX_ER			(GMII_TX_ER),				// out	: TX error
		// RX
		.GMII_RX_CLK		(GMII_RX_CLK),				// in	: Rx clock
		.GMII_RX_DV			(GMII_RX_DV),				// in	: Rx data valid
		.GMII_RXD			(GMII_RXD[7:0]),			// in	: Rx data[7:0]
		.GMII_RX_ER			(GMII_RX_ER),				// in	: Rx error
		.GMII_CRS			(GMII_CRS),					// in	: Carrier sense
		.GMII_COL			(GMII_COL),					// in	: Collision detected
		// Management IF
		.GMII_MDC			(GMII_MDC),					// out	: Clock for MDIO
		.GMII_MDIO_IN		(GMII_MDIO),				// in	: Data
		.GMII_MDIO_OUT		(GMII_MDIO_OUT),			// out	: Data
		.GMII_MDIO_OE		(GMII_MDIO_OE),				// out	: MDIO output enable
	// User I/F
		.SiTCP_RST			(SiTCP_RST),				// out	: Reset for SiTCP and related circuits
		// TCP connection control
		.TCP_OPEN_REQ		(1'b0),						// in	: Reserved input, shoud be 0
		.TCP_OPEN_ACK		(TCP_OPEN_ACK),				// out	: Acknowledge for open (=Socket busy)
		.TCP_ERROR			(),							// out	: TCP error, its active period is equal to MSL
		.TCP_CLOSE_REQ		(TCP_CLOSE_REQ),			// out	: Connection close request
		.TCP_CLOSE_ACK		(TCP_CLOSE_REQ),			// in	: Acknowledge for closing
		// FIFO I/F
		.TCP_RX_WC			(15'b0),					// in	: Rx FIFO write count[15:0] (Unused bits should be set 1)
		.TCP_RX_WR			(TCP_RX_WR),				// out	: Write enable
		.TCP_RX_DATA		(TCP_RX_DATA[7:0]),			// out	: Write data[7:0]
		.TCP_TX_FULL		(TCP_TX_FULL),				// out	: Almost full flag
		.TCP_TX_WR			(FIFO_RD_VALID),			// in	: Write enable
		.TCP_TX_DATA		(TCP_TX_DATA[7:0]),			// in	: Write data[7:0] 
	// RBCP
		.RBCP_ACT			(RBCP_ACT		),					// out	: RBCP active
		.RBCP_ADDR			(RBCP_ADDR[31:0]),			// out	: Address[31:0]
		.RBCP_WD			(RBCP_WD[7:0]),				// out	: Data[7:0]
		.RBCP_WE			(RBCP_WE),					// out	: Write enable
		.RBCP_RE			(RBCP_RE),					// out	: Read enable
		.RBCP_ACK			(RBCP_ACK),					// in	: Access acknowledge
		.RBCP_RD			(RBCP_RD[7:0])				// in	: Read data[7:0]
	);

	
//    V7_FIFO v7_rx_fifo (
//        .clk       (SYSCLK_200M), // input clk
//        .rst       (~TCP_OPEN_ACK), // input rst
//        .din       (TCP_RX_DATA[7:0] ), // input [7 : 0] din
//        .wr_en     (TCP_RX_WR), // input wr_en
//        .rd_en     (~TCP_TX_FULL), // input rd_en
//        .dout      (TCP_TX_DATA[7:0]), // output [7 : 0] dout
//        .full      ( ), // output full
//        .empty     ( ), // output empty
//        .valid     (FIFO_RD_VALID), // output valid
//        .data_count(FIFO_DATA_COUNT[11:0]) // output [11 : 0] data_count
//    );


////RBCP_test
//	always@(posedge SYSCLK_200M)begin
//		if(RBCP_WE)begin
//			OFFSET_TEST[31:0]  <= {RBCP_ADDR[31:2],2'b00}+{RBCP_WD[7:0],RBCP_WD[7:0],RBCP_WD[7:0],RBCP_WD[7:0]};
//		end
//		RBCP_RD[7:0]	<=  (
//			((RBCP_ADDR[7:0]==8'h00)?	OFFSET_TEST[ 7: 0]:	8'h00)|
//			((RBCP_ADDR[7:0]==8'h01)?	OFFSET_TEST[15: 8]:	8'h00)|
//			((RBCP_ADDR[7:0]==8'h02)?	OFFSET_TEST[23:16]:	8'h00)|
//			((RBCP_ADDR[7:0]==8'h03)?	OFFSET_TEST[31:24]:	8'h00)
//		);
//		RBCP_ACK  <= RBCP_RE | RBCP_WE;
//	end
	
//    ila_V7 ila_sitcp
//    (
//        .clk   (SYSCLK_200M) ,
//        .probe0  (TCP_TX_DATA), 
//        .probe1 ({INICNT[29],INICNT[6:0]}), 
//        .probe2 ({SYS_RSTn,TCP_RX_WR,TCP_TX_FULL,FIFO_RD_VALID,FIFO_DATA_COUNT}),
//        .probe3 ({GMII_RX_CLK,BUF_TX_CLK,TCP_OPEN_ACK,TCP_CLOSE_REQ,GMII_TX_EN,GMII_TX_ER,GMII_RX_DV,GMII_RX_ER})
//    );

endmodule

