library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library SevenSegmentLib;
use SevenSegmentLib.BcdPkg.DigitArray;

entity NumericDisplay is
  Generic(
    Width          : natural := 8;
    NumInputs      : natural := 2;
    DigitsPerInput : natural := 3;
    ClockFrequency : natural := 100e6);

  Port(
    Rst        : in  std_logic;
    Clk        : in  std_logic;
    Inputs     : in  std_logic_vector(NumInputs * Width - 1 downto 0);
    Segments   : out std_logic_vector(7 downto 0);
    Anodes     : out std_logic_vector(NumInputs * DigitsPerInput - 1 downto 0));
end NumericDisplay;

architecture Structural of NumericDisplay is
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
      Rst      : in  std_logic;
      Value    : in  natural range 0 to 15;
      DpEnable : in  std_logic;
      Segments : out std_logic_vector(7 downto 0));
  end component;

  component BcdEncoder is
    Generic(
      NumDigits : natural;
      Width : natural);

    Port(
      Input  : in  std_logic_vector(Width - 1 downto 0);
      Output : out DigitArray(NumDigits - 1 downto 0));
  end component;

  constant numDigits : natural := DigitsPerInput * NumInputs;
  signal digits : DigitArray(NumDigits - 1 downto 0);
  signal curDigit : natural range 0 to 15;
  signal sel : natural range 0 to NumDigits - 1;
begin
  Encoders: for i in 0 to NumInputs - 1 generate
    BEncoder: BcdEncoder
    Generic map(
      NumDigits => DigitsPerInput,
      Width => Width)
    Port map(
      Input => Inputs((i + 1) * Width - 1 downto i * Width),
      Output => digits((i + 1) * DigitsPerInput - 1 downto i * DigitsPerInput)
    );
  end generate Encoders;

  SSEncoder: SevenSegEncoder
  Port map(
    Rst => Rst,
    Value => curDigit,
    DpEnable => '0',
    Segments => Segments
  );

  DigitSelect: Strober
  Generic map(
    NumOutputs => NumInputs * DigitsPerInput,
    InputClockFreq => ClockFrequency,
    PulseWidth => 1
  )
  Port map(
    Rst => Rst,
    Clk => Clk,
    Sel => sel,
    Strobes => Anodes
  );

  process (sel, digits)
  begin
    curDigit <= digits(sel);
  end process;

end Structural;

