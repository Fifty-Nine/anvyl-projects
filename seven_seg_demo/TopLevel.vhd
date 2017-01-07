library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library WORK;
use WORK.BcdPkg.ALL;

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
    SEG_AN : out  STD_LOGIC_VECTOR (numSegments - 1 downto 0));
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

  signal which : STD_LOGIC_VECTOR(5 downto 0);
  signal sel : natural range 0 to 5;
  signal curDigit : natural range 0 to 15;
  signal digits : DigitArray(2 downto 0);
begin
  SEG_DP <= which(0) or which(2);
  SEG_AN <= which;
  curDigit <= digits(sel mod 3);

  Encoder: SevenSegEncoder
  Port map(
    Value => curDigit,
    SegA => SEG_A,
    SegB => SEG_B,
    SegC => SEG_C,
    SegD => SEG_D,
    SegE => SEG_E,
    SegF => SEG_F,
    SegG => SEG_G
  );

  SevenSegSelect: Strober
  Generic map(
    NumOutputs     => 6,
    InputClockFreq => 100e6,
    PulseWidth     => 1 ms
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



