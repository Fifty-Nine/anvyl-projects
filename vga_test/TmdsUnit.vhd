library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity TmdsUnit is
    Port(
      HSync     : in  std_logic;
      VSync     : in  std_logic;
      Red       : in  std_logic_vector (7 downto 0);
      Green     : in  std_logic_vector (7 downto 0);
      Blue      : in  std_logic_vector (7 downto 0);
      Blanking  : in  std_logic;
      TmdsDataP : out std_logic_vector (2 downto 0);
      TmdsDataN : out std_logic_vector (2 downto 0);
      TmdsClkP  : out std_logic;
      TmdsClkN  : out std_logic);
end TmdsUnit;

architecture Behavioral of TmdsUnit is

begin


end Behavioral;

