library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SevenSegEncoder is
  Port(
    Rst      : in  std_logic;
    Value    : in  natural range 0 to 15;
    DpEnable : in  std_logic; 
    Segments : out std_logic_vector(7 downto 0));
end SevenSegEncoder;

architecture Behavioral of SevenSegEncoder is
begin
  process (Rst, Value, DpEnable)
  begin
    if Rst = '1' then
      segments <= (others => '0');
    else
      case Value is
        when  0 => segments <= DpEnable & "0111111";
        when  1 => segments <= DpEnable & "0000110";
        when  2 => segments <= DpEnable & "1011011";
        when  3 => segments <= DpEnable & "1001111";
        when  4 => segments <= DpEnable & "1100110";
        when  5 => segments <= DpEnable & "1101101";
        when  6 => segments <= DpEnable & "1111101";
        when  7 => segments <= DpEnable & "0000111";
        when  8 => segments <= DpEnable & "1111111";
        when  9 => segments <= DpEnable & "1101111";
        when 10 => segments <= DpEnable & "1110111";
        when 11 => segments <= DpEnable & "1111100";
        when 12 => segments <= DpEnable & "0111001";
        when 13 => segments <= DpEnable & "1011110";
        when 14 => segments <= DpEnable & "1111001";
        when 15 => segments <= DpEnable & "1110001";
      end case;
    end if;
  end process;
end Behavioral;

