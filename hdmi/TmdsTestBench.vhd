--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:41:04 01/09/2017
-- Design Name:   
-- Module Name:   /home/princet/anvyl-projects/hdmi/TmdsTestBench.vhd
-- Project Name:  hdmi
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TmdsEncoder
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE WORK.TmdsUtils.All;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TmdsTestBench IS
END TmdsTestBench;
 
ARCHITECTURE behavior OF TmdsTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TmdsEncoder
    PORT(
		   Clk : IN  std_logic;
	      Reset : IN  std_logic;
         Data : IN  std_logic_vector(7 downto 0);
         Control : IN  std_logic_vector(1 downto 0);
         DataEnable : IN  std_logic;
         TmdsData : OUT  std_logic_vector(9 downto 0)
        );
    END COMPONENT;
    

   --Inputs
	signal Clk : std_logic := '0';
	signal Reset : std_logic := '1';
   signal Data : std_logic_vector(7 downto 0) := (others => '0');
   signal Control : std_logic_vector(1 downto 0) := (others => '0');
   signal DataEnable : std_logic := '0';

 	--Outputs
   signal TmdsData : std_logic_vector(9 downto 0);
	signal DecodedTmdsData : std_logic_vector(9 downto 0);
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: TmdsEncoder PORT MAP (
			 Clk => Clk,
			 Reset => Reset,
          Data => Data,
          Control => Control,
          DataEnable => DataEnable,
          TmdsData => TmdsData
        );
		  
	decode_proc: process (TmdsData, DataEnable)
	begin
		DecodedTmdsData <= tmdsDecode(TmdsData, DataEnable);
	end process;
		  
	clk_process: process
	begin
		wait for 5 ns;
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
	end process;
		  
	stimulus: process
	begin
		Data <= (others => '0');
		wait for 23 ns;
		reset <= '0';
		Data <= X"00";
		DataEnable <= '1';
		wait for 20 ns;
		Data <= X"FF";
		wait for 10 ns;
		Data <= X"AA";
		wait for 10 ns;
		Data <= X"55";
		wait for 10 ns;
		DataEnable <= '0';
		Control <= "00";
		wait for 10 ns;
		Control <= "11";
		wait for 10 ns;
		Control <= "01";
		wait for 10 ns;
		Control <= "10";
		wait;
		
	end process;
END;
