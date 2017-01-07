library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Basically a demux tied to a counter. Asserts each of its outputs in
-- sequence, with the given period.
entity Strober is
  Generic( 
    -- The number of output lines.
    NumOutputs     : natural := 6;
    -- The frequency of the input clock, in Hz.
    InputClockFreq : natural := 100e6;
    -- The pulse width for each strobe.
    PulseWidth     : time := 1 ms);

  Port(
    CLK     : in  STD_LOGIC;
    RST     : in  STD_LOGIC;
    SEL     : out natural range 0 to NumOutputs - 1;
    STROBES : out STD_LOGIC_VECTOR (NumOutputs - 1 downto 0));
end Strober;

architecture Behavioral of Strober is
  constant clockDiv  : natural := (InputClockFreq * PulseWidth) / (1 sec);
  signal   counter   : natural range 0 to clockDiv := 0;
  signal   idx       : natural range 0 to NumOutputs - 1 := 0;
begin
  SEL <= idx;

  process (RST, CLK)
  begin
    if RST = '1' then
      counter <= 0;
      idx <= 0;
      STROBES <= (0 => '1', others => '0');
    elsif rising_edge(CLK) then
      if counter = clockDiv then
        counter <= 0;
        idx <= (idx + 1) mod numOutputs;
      else
        counter <= counter + 1;
      end if;
      STROBES <= (others => '0');
      STROBES(idx) <= '1';
    end if;
  end process;
end Behavioral;

