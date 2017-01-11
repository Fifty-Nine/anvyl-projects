----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:28:09 01/09/2017 
-- Design Name: 
-- Module Name:    TopLevel - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TopLevel is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           TAP : out  STD_LOGIC_VECTOR (15 downto 0);
           UART_TX : out  STD_LOGIC;
           UART_RX : in  STD_LOGIC;
           HDMI_TX_P : out  STD_LOGIC_VECTOR (2 downto 0);
           HDMI_TX_N : out  STD_LOGIC_VECTOR (2 downto 0);
           HDMI_TX_P_CLK : out  STD_LOGIC;
           HDMI_TX_N_CLK : out  STD_LOGIC;
           HDMI_CEC : inout  STD_LOGIC;
           I2C_SDA : inout  STD_LOGIC;
           I2C_SCL : inout  STD_LOGIC);
end TopLevel;

architecture Behavioral of TopLevel is
  signal locX : natural range 0 to 799;
  signal locY : natural range 0 to 524;

  signal hSync : std_logic;
  signal vSync : std_logic;
  signal drawArea : std_logic;
  
  signal r : std_logic_vector(7 downto 0);
  signal g : std_logic_vector(7 downto 0);
  signal b : std_logic_vector(7 downto 0);
begin
	UART_TX <= '1';
	HDMI_TX_P <= "000";
	HDMI_TX_N <= "000";
	HDMI_TX_P_CLK <= '0';
	HDMI_TX_N_CLK <= '0';
	HDMI_CEC <= 'Z';
	I2C_SDA <= 'Z';
	I2C_SCL <= 'Z';

end Behavioral;

