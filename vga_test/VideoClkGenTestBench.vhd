LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY VideoClkGenTestBench IS
END VideoClkGenTestBench;
 
ARCHITECTURE behavior OF VideoClkGenTestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT VideoClkGen
    PORT(
         Reset : IN  std_logic;
         SystemClk : IN  std_logic;
         PixelClk : OUT  std_logic;
         PixelClkx2 : OUT  std_logic;
         PixelClkx10 : OUT  std_logic;
         SerdesStrobe : OUT  std_logic;
         Locked : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal Reset : std_logic := '0';
   signal SystemClk : std_logic := '0';

 	--Outputs
   signal PixelClk : std_logic;
   signal PixelClkx2 : std_logic;
   signal PixelClkx10 : std_logic;
   signal SerdesStrobe : std_logic;
   signal Locked : std_logic;

   -- Clock period definitions
   constant SystemClk_period : time := 10 ns;
   constant PixelClk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: VideoClkGen PORT MAP (
          Reset => Reset,
          SystemClk => SystemClk,
          PixelClk => PixelClk,
          PixelClkx2 => PixelClkx2,
          PixelClkx10 => PixelClkx10,
          SerdesStrobe => SerdesStrobe,
          Locked => Locked
        );

   -- Clock process definitions
   SystemClk_process :process
   begin
		SystemClk <= '0';
		wait for SystemClk_period/2;
		SystemClk <= '1';
		wait for SystemClk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      wait;
   end process;

END;
