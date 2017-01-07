library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TopLevel is
  Generic( numSegments : natural := 6 );
  Port (
    SEG_A  : out  STD_LOGIC;
    SEG_B  : out  STD_LOGIC;
    SEG_C  : out  STD_LOGIC;
    SEG_D  : out  STD_LOGIC;
    SEG_E  : out  STD_LOGIC;
    SEG_F  : out  STD_LOGIC;
    SEG_G  : out  STD_LOGIC;
    SEG_DP : out  STD_LOGIC;
    SEG_AN : out  STD_LOGIC_VECTOR (numSegments - 1 downto 0);
    CLK    : in   STD_LOGIC;
    RST    : in   STD_LOGIC);
end TopLevel;

architecture Structural of TopLevel is
  component Strober is
    Generic(
      NumOutputs     : natural;
      InputClockFreq : natural;
      PulseWidth     : time);

    Port(
      CLK     : in  STD_LOGIC;
      RST     : in  STD_LOGIC;
      STROBES : out STD_LOGIC_VECTOR (NumOutputs - 1 downto 0));

  end component;
begin
  SEG_A  <= '1';
  SEG_B  <= '1';
  SEG_C  <= '1';
  SEG_D  <= '1';
  SEG_E  <= '1';
  SEG_F  <= '1';
  SEG_G  <= '1';
  SEG_DP <= '1';

  SevenSegSelect: Strober
  Generic map(
    NumOutputs     => 6,
    InputClockFreq => 100e6,
    PulseWidth     => 1 ms
  )
  Port map(
    CLK => CLK,
    RST => RST,
    STROBES => SEG_AN
  );
end Structural;



