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
  component Strober is
    Generic(
      NumOutputs     : natural;
      InputClockFreq : natural;
      PulseWidth     : natural);

    Port(
      CLK     : in  STD_LOGIC;
      RST     : in  STD_LOGIC;
      SEL     : out natural range 0 to NumOutputs - 1;
      STROBES : out STD_LOGIC_VECTOR (NumOutputs - 1 downto 0));

  end component;
  component SevenSegEncoder is
    Port(
      Value : in  natural range 0 to 15;
      SegA  : out STD_LOGIC;
      SegB  : out STD_LOGIC;
      SegC  : out STD_LOGIC;
      SegD  : out STD_LOGIC;
      SegE  : out STD_LOGIC;
      SegF  : out STD_LOGIC;
      SegG  : out STD_LOGIC);
  end component;

  component BcdEncoder is
    Generic(
      NumDigits : natural;
      Width : natural);

    Port(
      Input  : in  std_logic_vector(Width - 1 downto 0);
      Output : out DigitArray(NumDigits - 1 downto 0));
  end component;

  signal which : std_logic_vector(5 downto 0);
  signal sel : natural range 0 to 5;
  signal curDigit : natural range 0 to 15;
  signal digits : DigitArray(2 downto 0);

  signal segments : std_logic_vector(7 downto 0);
begin
  SEG_A <= segments(0);
  SEG_B <= segments(1);
  SEG_C <= segments(2);
  SEG_D <= segments(3);
  SEG_E <= segments(4);
  SEG_F <= segments(5);
  SEG_G <= segments(6);
  SEG_DP <= segments(7);
  SEG_AN <= which;
  curDigit <= digits(sel mod 3);
  segments(7) <= which(0) or which(2);

  TAP(7 downto 0) <= segments;
  TAP(13 downto 8) <= which;
  TAP(15 downto 14) <= "00";


  Encoder: SevenSegEncoder
  Port map(
    Value => curDigit,
    SegA => segments(0),
    SegB => segments(1),
    SegC => segments(2),
    SegD => segments(3),
    SegE => segments(4),
    SegF => segments(5),
    SegG => segments(6)
  );

  SevenSegSelect: Strober
  Generic map(
    NumOutputs     => 6,
    InputClockFreq => 100e6,
    PulseWidth     => 1 -- ms
  )
  Port map(
    CLK => CLK,
    RST => RST,
    SEL => SEL,
    STROBES => which
  );

  BcdEncode: BcdEncoder
  Generic map(
    NumDigits => 3,
    Width => 8
  )
  Port map(
    Input => SW,
    Output => digits
  );
end Structural;



