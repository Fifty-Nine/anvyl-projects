library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package BcdPkg is
  type DigitArray is array(natural range <>) of natural range 0 to 9;
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.BcdPkg.ALL;

entity BcdEncoder is
  Generic(
    NumDigits : natural := 3;
    Width     : natural := 8);

  Port(
    Input  : in  std_logic_vector(width - 1 downto 0);
    Output : out DigitArray(NumDigits - 1 downto 0));

end BcdEncoder;

architecture Behavioral of BcdEncoder is
begin
  process (Input)
    variable acc : natural;
  begin
    acc := to_integer(unsigned(Input));
    for idx in 0 to NumDigits - 1 loop
      Output(idx) <= acc mod 10;
      acc := acc / 10;
    end loop;
  end process;
end Behavioral;

