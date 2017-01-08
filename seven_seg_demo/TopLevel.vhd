library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library SevenSegmentLib;
use SevenSegmentLib.BcdPkg.ALL;

entity TopLevel is
  Generic( numSegments : natural := 6 );
  Port (
    CLK    : in   STD_LOGIC;
    RST    : in   STD_LOGIC;
    SW     : in   STD_LOGIC_VECTOR(7 downto 0);
    SEG_A  : out  STD_LOGIC;
    SEG_B  : out  STD_LOGIC;
    SEG_C  : out  STD_LOGIC;
    SEG_D  : out  STD_LOGIC;
    SEG_E  : out  STD_LOGIC;
    SEG_F  : out  STD_LOGIC;
    SEG_G  : out  STD_LOGIC;
    SEG_DP : out  STD_LOGIC;
    SEG_AN : out  STD_LOGIC_VECTOR (numSegments - 1 downto 0);
    TAP    : out  STD_LOGIC_VECTOR (15 downto 0));
end TopLevel;

architecture Structural of TopLevel is

  component NumericDisplay
  generic (
    Width : natural
  );
	port(
		Rst      : in  std_logic;
		Clk      : in  std_logic;
		Inputs   : in  std_logic_vector(17 downto 0);          
		Segments : out std_logic_vector(7 downto 0);
		Anodes   : out std_logic_vector(5 downto 0));
	end component;

  component MicroBlaze
  port (
    Clk : in std_logic;
    Reset : in std_logic;
    Gpo1 : out std_logic_vector(31 downto 0);
    Gpi1 : in std_logic_vector(31 downto 0);
    Gpi1_interrupt : out std_logic
  );
  end component;

  signal segments : std_logic_vector(7 downto 0);
  signal anodes   : std_logic_vector(5 downto 0);
  signal value    : std_logic_vector(17 downto 0);

  signal MbOutput : std_logic_vector(31 downto 0);
  signal MbInput  : std_logic_vector(31 downto 0);
begin
  

  SEG_A <= segments(0);
  SEG_B <= segments(1);
  SEG_C <= segments(2);
  SEG_D <= segments(3);
  SEG_E <= segments(4);
  SEG_F <= segments(5);
  SEG_G <= segments(6);
  SEG_DP <= segments(7);
  SEG_AN <= anodes;

  TAP(7 downto 0) <= segments;
  TAP(13 downto 8) <= anodes;
  TAP(15 downto 14) <= "00";

  MbInput(7 downto 0) <= SW;
  MbInput(31 downto 8) <= (others => '0');

  value(17 downto 0) <= MbOutput(17 downto 0);

  Disp: NumericDisplay
  Generic map(Width => 9)
  Port map(
    Rst => RST,
    Clk => CLK,
    Inputs => value,
    Segments => segments,
    Anodes => anodes);
  
  mcs_0: MicroBlaze
  Port map(
    Clk => CLK,
    Reset => RST,
    Gpo1 => MbOutput,
    Gpi1 => MbInput
  );

 end Structural;



