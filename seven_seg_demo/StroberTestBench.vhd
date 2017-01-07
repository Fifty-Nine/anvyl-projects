LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
ENTITY StroberTestBench IS
END StroberTestBench;
 
ARCHITECTURE behavior OF StroberTestBench IS 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT Strober
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         STROBES : OUT  std_logic_vector(5 downto 0)
        );
    END COMPONENT;

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
   signal STROBES : std_logic_vector(5 downto 0);

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Strober PORT MAP (
          CLK => CLK,
          RST => RST,
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

      wait for 1005 ns;
      RST <= '1';

      wait for 10 ns;
      RST <= '0';

      wait;
   end process;

END;
