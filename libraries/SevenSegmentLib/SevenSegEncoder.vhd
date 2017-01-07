library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegEncoder is
  Port(
    Value    : in  natural range 0 to 15;
    DpEnable : in std_logic; 
    Segments : out std_logic_vector(7 downto 0));
end SevenSegEncoder;

architecture Behavioral of SevenSegEncoder is
begin
  process (Value)
  begin
    case Value is
      when  0 => segments <= DpEnable & "1111110";
      when  1 => segments <= DpEnable & "0110000";
      when  2 => segments <= DpEnable & "1101101";
      when  3 => segments <= DpEnable & "1111001";
      when  4 => segments <= DpEnable & "0110011";
      when  5 => segments <= DpEnable & "1011011";
      when  6 => segments <= DpEnable & "1011111";
      when  7 => segments <= DpEnable & "1110000";
      when  8 => segments <= DpEnable & "1111111";
      when  9 => segments <= DpEnable & "1111011";
      when 10 => segments <= DpEnable & "1110111";
      when 11 => segments <= DpEnable & "0011111";
      when 12 => segments <= DpEnable & "1001110";
      when 13 => segments <= DpEnable & "0111101";
      when 14 => segments <= DpEnable & "1001111";
      when 15 => segments <= DpEnable & "1000111";
    end case;
  end process;
end Behavioral;

