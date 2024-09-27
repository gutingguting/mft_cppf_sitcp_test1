----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2024/09/27 10:09:37
-- Design Name: 
-- Module Name: top_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_top is
--  Port ( );
end top_top;

architecture Behavioral of top_top is
 ----================== Add SiTCP Module=========================-----
                
            Inst_ethernet_top: entity work.cppf_sitcp_top
            PORT MAP(        
                sysclk125m        => clk125,        --fabricClk_from_userClockIbufgds,  
                clk200          => clk200,  
                clk200_locked_i          => pll_locked,  
                
                --GTH
--                GTH_REFCLK_P => SC_GTH_REFCLK125P,
--                GTH_REFCLK_N => SC_GTH_REFCLK125N,
                gtrefclk_i => sitcp_gtrefclk_i,
                txp     =>  TXP_OUT_1G,                        --output
                txn     =>  TXN_OUT_1G,
                rxp     =>  RXP_IN_1G,
                rxn     =>  RXN_IN_1G,
                --SiTCP
                TCP_OPEN_ACK => open,            --out 
                SiTCP_RST      => open, --SiTCP_reset,         --out 
                TCP_TX_FULL  => open,      --out          --some of signals are not used yet
                TCP_TX_DATA  => x"00",         --in
        --         SiTCP_clk    => open,  --SiTCP_clk,         --out
                FIFO_RD_VALID=> '0',     --SiTCP_FIFO_wr_en     --in
                
                --out                                                                              
                RBCP_ADDR => RBCP_ADDR, 
                RBCP_WD => RBCP_WD,  
                RBCP_WE => RBCP_WE,   
                RBCP_RE => RBCP_RE,
                RBCP_ACT=> RBCP_ACT,   
                --in        
                RBCP_RD => RBCP_RD, 
                RBCP_ACK=> RBCP_ACK     --acess response   
            );

begin


end Behavioral;
