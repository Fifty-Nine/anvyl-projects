library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegEncoder is
  Port(
    Value : in  natural range 0 to 15;
    SegA  : out STD_LOGIC;
    SegB  : out STD_LOGIC;
    SegC  : out STD_LOGIC;
    SegD  : out STD_LOGIC;
    SegE  : out STD_LOGIC;
    SegF  : out STD_LOGIC;
    SegG  : out STD_LOGIC);
end SevenSegEncoder;

architecture Behavioral of SevenSegEncoder is
  signal segments : STD_LOGIC_VECTOR(6 downto 0);
begin
  SegA <= segments(6);
  SegB <= segments(5);
  SegC <= segments(4);
  SegD <= segments(3);
  SegE <= segments(2);
  SegF <= segments(1);
  SegG <= segments(0);

  process (Value)
  begin
    case Value is
      when  0 => segments <= "1111110";
      when  1 => segments <= "0110000";
      when  2 => segments <= "1101101";
      when  3 => segments <= "1111001";
      when  4 => segments <= "0110011";
      when  5 => segments <= "1011011";
      when  6 => segments <= "1011111";
      when  7 => segments <= "1110000";
      when  8 => segments <= "1111111";
      when  9 => segments <= "1111011";
      when 10 => segments <= "1110111";
      when 11 => segments <= "0011111";
      when 12 => segments <= "1001110";
      when 13 => segments <= "0111101";
      when 14 => segments <= "1001111";
      when 15 => segments <= "1000111";
    end case;
  end process;
end Behavioral;

