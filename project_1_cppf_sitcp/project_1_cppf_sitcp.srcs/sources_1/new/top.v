
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;

entity cppf_ethernet_top is
port(
		sysclk125m : IN std_logic ;		
		clk200 : IN std_logic ;		
        clk200_locked_i  : IN std_logic;
        		
        gtrefclk_i : in std_logic; 
--        GTH_REFCLK_P : in std_logic; 
--        GTH_REFCLK_N : in std_logic; 

		txp : out std_logic ;
		txn : out std_logic ;
		rxp : in std_logic ;
		rxn : in std_logic ;
		--TCP related
        TCP_OPEN_ACK  :OUT STD_LOGIC;
        SiTCP_RST     :OUT STD_LOGIC;    --use which reset?  output
        TCP_TX_FULL   :OUT STD_LOGIC;
        TCP_TX_DATA   :IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
--        SiTCP_clk      :OUT STD_LOGIC;   --200MHz out
        FIFO_RD_VALID :IN  STD_LOGIC;
         
        --RBCP(SlowControl related)                
        RBCP_ADDR      :OUT STD_LOGIC_VECTOR(31 downto 0);    --0x00000000--0xFFFEFFFF can be used 
        RBCP_WD        :OUT STD_LOGIC_VECTOR(7  downto 0);    --write data
        RBCP_WE        :OUT STD_LOGIC;                         --write enable 
        RBCP_RE        :OUT STD_LOGIC;                         --read enable
        RBCP_ACT       :OUT STD_LOGIC;                         --bus operating 
        RBCP_RD        :IN  STD_LOGIC_VECTOR(7  downto 0);    --read data
        RBCP_ACK       :IN  STD_LOGIC                          --acess response
);
end cppf_ethernet_top;

architecture Behavioral of cppf_ethernet_top is

	COMPONENT cppf_sitcp_top
	PORT(
		SYSCLK_200M  : IN std_logic;
		LOCKED  : IN std_logic;
		
		GMII_TX_CLK : IN std_logic;
		GMII_RX_CLK : IN std_logic;
		GMII_RX_DV : IN std_logic;
		GMII_RXD : IN std_logic_vector(7 downto 0);
		GMII_RX_ER : IN std_logic;
		GMII_CRS : IN std_logic;
		GMII_COL : IN std_logic;    
		GMII_RSTn : OUT std_logic;
		GMII_TX_EN : OUT std_logic;
		GMII_TXD : OUT std_logic_vector(7 downto 0);
		GMII_TX_ER : OUT std_logic;
		GMII_GTXCLK : OUT std_logic;
		
		GMII_MDC : OUT std_logic;	-- Clock for MDIO
	    GMII_MDIO_IN: IN std_logic;	--  Data
	    GMII_MDIO_OUT: OUT std_logic;	-- Data
	    GMII_MDIO_OE: OUT std_logic;	-- MDIO output enable
		
--		I2C_SDA : INOUT std_logic;      
--		I2C_SCL : OUT std_logic
        
        TCP_OPEN_ACK   :OUT STD_LOGIC;
        SiTCP_RST      :OUT STD_LOGIC;    --use which reset?  output
        TCP_TX_FULL    :OUT STD_LOGIC;
        TCP_TX_DATA    :IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--        SiTCP_clk      :OUT STD_LOGIC;
        FIFO_RD_VALID  :IN STD_LOGIC;
                
        RBCP_ADDR        :OUT STD_LOGIC_VECTOR(31 downto 0);      --0x00000000--0xFFFEFFFF can be used 
        RBCP_WD            :OUT STD_LOGIC_VECTOR(7  downto 0);     --write data
        RBCP_WE            :OUT STD_LOGIC;                                --write enable 
        RBCP_RE            :OUT STD_LOGIC;                                --read enable
        RBCP_ACT            :OUT STD_LOGIC;                                  --bus operating 
        RBCP_RD            :IN  STD_LOGIC_VECTOR(7  downto 0);     --read data
        RBCP_ACK            :IN  STD_LOGIC
		);
	END COMPONENT;
		
component V7_PLL
    port
     (
      clk_out1          : out    std_logic;
      clk_out2          : out    std_logic;
      reset             : in     std_logic;
      locked            : out    std_logic;
      clk_in1           : in     std_logic
     );
    end component;
	
    COMPONENT ila_V7 
    PORT (
        clk : IN STD_LOGIC;  
        probe0 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        probe1 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        probe2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
    END COMPONENT;
	
    signal  status_vector0 : std_logic_vector(15 downto 0);
    
--    signal gtrefclk_i       : std_logic;
--    signal clk_200m    : std_logic;  
--    signal clk_125m    : std_logic;  
--    signal clk_125m_i    : std_logic;  
--    signal independent_clock    : std_logic;  
--    signal locked_i          : std_logic;    
    
    
    -------------GMII interface signal-------------------------------
    signal sitcp_gmii_txd    : std_logic_vector(7 downto 0);
    signal sitcp_gmii_tx_en  : std_logic;
    signal sitcp_gmii_tx_er  : std_logic;
    signal sitcp_gmii_rxd    : std_logic_vector(7 downto 0);
    signal sitcp_gmii_rx_dv  : std_logic;
    signal sitcp_gmii_rx_er  : std_logic;
	
    -----------------------------------------------------------------
--    signal	sitcp_i2c_sda    : std_logic ;
--    signal	sitcp_i2c_scl    : std_logic ; 
    
     signal gtrefclk_bufg_out     : std_logic;
  
    signal userclk               : std_logic;                    
    signal userclk2              : std_logic;                    
    signal rxuserclk2_i          : std_logic;        
--    signal independent_clock_bufg: std_logic;
    
        --ila
    signal reset            : std_logic;
    signal SiTCP_RST_ila            : std_logic;
    signal GMII_RSTn_ila            : std_logic;
    signal pma_reset_out_ila            : std_logic;
    signal mmcm_locked_out_ila            : std_logic;
    signal resetdone_ila            : std_logic;
    signal gmii_isolate_ila            : std_logic;

begin
  
--     -- Clock circuitry for the Transceiver uses a differential input clock.
--    -- gtrefclk is routed to the tranceiver.
--       ibufds_gtrefclk : IBUFDS_GTE2
--       port map (
--          I     => GTH_REFCLK_P,
--          IB    => GTH_REFCLK_N,
--          CEB   => '0',
--          O     => gtrefclk_i,
--          ODIV2 => open
--       );
       
--    SiTCP_clk <= clk200;
    SiTCP_RST <= SiTCP_RST_ila;
    reset <= (not GMII_RSTn_ila) and SiTCP_RST_ila;
         
    Inst_cppf_sitcp_top: cppf_sitcp_top PORT MAP(
    
        SYSCLK_200M  => clk200,
        LOCKED  => clk200_locked_i,    --locked_i,
        
        GMII_RSTn => GMII_RSTn_ila,   
        GMII_TX_EN => sitcp_gmii_tx_en,
        GMII_TXD => sitcp_gmii_txd,
        GMII_TX_ER => sitcp_gmii_tx_er,
--        GMII_TX_CLK => clk_125m,  --input
        GMII_TX_CLK => userclk2,--gtrefclk_bufg_out,  --input
        GMII_GTXCLK => open,        --output
        GMII_RX_CLK => userclk2, --rxuserclk2_i,   --gtrefclk_bufg_out,   --input
        GMII_RX_DV => sitcp_gmii_rx_dv,
        GMII_RXD => sitcp_gmii_rxd,
        GMII_RX_ER => sitcp_gmii_rx_er,
        GMII_CRS => '0',
        GMII_COL => '0',
        
        GMII_MDC  => open, --GMII_MDC,	-- Clock for MDIO
        GMII_MDIO_IN => '0',--GMII_MDIO_IN,	--  Data
        GMII_MDIO_OUT => open,--GMII_MDIO_OUT,	-- Data
        GMII_MDIO_OE => open,     --GMII_MDIO_OE,	-- MDIO output enable
        
        TCP_OPEN_ACK => TCP_OPEN_ACK,
        SiTCP_RST => SiTCP_RST_ila,               --output
        TCP_TX_FULL => TCP_TX_FULL,             --some of signals are not used yet
        TCP_TX_DATA => TCP_TX_DATA,
--        SiTCP_clk => clk_200m, 
        FIFO_RD_VALID => FIFO_RD_VALID,
        
        --out                                                                                 RBCP_ADDR[1:0]->CS
        RBCP_ADDR => RBCP_ADDR,  --0x00000000--0xFFFEFFFF can be used   RBCP_ADDR[8:2]->LAi(use if else and CS to select which module)
        RBCP_WD => RBCP_WD,       --write data                                   RBCP_WD[7:0]->LDi
        RBCP_WE => RBCP_WE,          --write enable                                RE->LWR(not sure) is write the common state?
        RBCP_RE => RBCP_RE,          --read enable
        RBCP_ACT=> RBCP_ACT,   --bus operating                                use ILA to observe
        --in        
        RBCP_RD => RBCP_RD,          --read data                                   LDo->RBCP_WD[7:0]
        RBCP_ACK     => RBCP_ACK     --acess response
    );
	
  ------------------------------------------------------------------------------
  -- Instantiate the SGMII_1000basex Block (core wrapper).
  ------------------------------------------------------------------------------  
  
    SGMII_1000basex : entity work.ETH_1000BASEX_support
    port map (
	       gtrefclk_i           => gtrefclk_i,       
           gtrefclk_out           => open,
           gtrefclk_bufg_out      => gtrefclk_bufg_out,
--           gtrefclk_bufg_out      => open,
           
           txp                  => txp,
           txn                  => txn,
           rxp                  => rxp,
           rxn                  => rxn,
           mmcm_locked_out          => mmcm_locked_out_ila,
           userclk_out              => userclk,
           userclk2_out             => userclk2,
           rxuserclk_out              => open,
           rxuserclk2_out             => rxuserclk2_i,
           independent_clock_bufg    => sysclk125m,     --clk_125m,
           pma_reset_out              => pma_reset_out_ila,
           resetdone                  => resetdone_ila,
           
           gmii_txd             => sitcp_gmii_txd,
           gmii_tx_en           => sitcp_gmii_tx_en,
           gmii_tx_er           => sitcp_gmii_tx_er,
           gmii_rxd             => sitcp_gmii_rxd,
           gmii_rx_dv           => sitcp_gmii_rx_dv,
           gmii_rx_er           => sitcp_gmii_rx_er,
           gmii_isolate         => gmii_isolate_ila,
           configuration_vector => "00000",
     
          status_vector        => status_vector0,
          reset                => reset,       
          signal_detect        => '1',
  
           gt0_qplloutclk_out     => open,
           gt0_qplloutrefclk_out  => open
           );
    
--    eth_v7_pll : V7_PLL
--       port map ( 
--       clk_out1 => clk_200m,
--       clk_out2 => clk_125m,            
--       reset => '0',
--       locked => locked_i,
--       clk_in1 => sysclk125m
--     );
     
--     ila_gmii: ila_V7
--     PORT MAP (
--         clk => sysclk125m ,
--         probe0 => sitcp_gmii_txd, 
--         probe1 => sitcp_gmii_rxd, 
--         probe2(11 downto 0) => status_vector0(11 downto 0),
--         probe2(12) => SiTCP_RST_ila,
--         probe2(13) => reset,
--         probe2(14) => resetdone_ila,
--         probe2(15) => gmii_isolate_ila,
--         probe3(0) => sitcp_gmii_tx_er,
--         probe3(1) => sitcp_gmii_tx_en,
--         probe3(2) => sitcp_gmii_rx_dv,
--         probe3(3) => sitcp_gmii_rx_er,
--         probe3(4) => clk200_locked_i,
--         probe3(5) => GMII_RSTn_ila,
--         probe3(6) => mmcm_locked_out_ila,
--         probe3(7) => pma_reset_out_ila
--     );
    

end Behavioral;
