library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TmdsSerializer is
  Port(
    Reset   : in  std_logic;
    PClkx2  : in  std_logic;
    PClkx10 : in  std_logic;
    PData   : in  std_logic_vector(9 downto 0);
    Sync    : out std_logic;
    SData   : out std_logic);
end TmdsSerializer;

architecture Behavioral of TmdsSerializer is
begin

  process (Reset, PClkx10, PData)
    variable idx : natural range 0 to 9 := 0;
    variable value : std_logic_vector(9 downto 0);
  begin
    if Reset = '1' then
      idx := 0;
      value := (others => '0');
      SData <= value(0);
      Sync <= '0';
    elsif rising_edge(PClkx10) then
      if idx = 0 then
        value := PData;
        Sync <= '1';
      else
        Sync <= '0';
      end if;

      SData <= value(idx);
      idx := (idx + 1) mod 10;
    end if;
  end process;

end Behavioral;

