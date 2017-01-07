LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY StroberTestBench IS
END StroberTestBench;
 
ARCHITECTURE behavior OF StroberTestBench IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Strober
    GENERIC(
      NumOutputs : natural;
      InputClockFreq : natural;
      PulseWidth : natural);
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         sel : OUT natural range 0 to NumOutputs - 1;
         STROBES : OUT  std_logic_vector(5 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal STROBES : std_logic_vector(5 downto 0);
   signal SEL : natural range 0 to 5;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Strober 
       GENERIC MAP (
         NumOutputs => 6,
         InputClockFreq => 100e6,
         PulseWidth => 1
        )
       PORT MAP (
          CLK => CLK,
          RST => RST,
          SEL => SEL,
          STROBES => STROBES
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      RST <= '1';
      wait for 100 ns;
      RST <= '0';
      wait;
   end process;

END;
