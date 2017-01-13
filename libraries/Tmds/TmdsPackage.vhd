library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Components is
  component TmdsEncoder
    Port(
      Clk        : in  std_logic;
      Reset      : in  std_logic;
      Data       : in  std_logic_vector (7 downto 0);
      Control    : in  std_logic_vector (1 downto 0);
      DataEnable : in  std_logic;
      TmdsData   : out std_logic_vector (9 downto 0));
  end component;
  component TmdsSerializer
    Port(
      Reset        : in  std_logic;
      PixelClkx2   : in  std_logic;
      PixelClkx10  : in  std_logic;
      SerdesStrobe : in std_logic;
      PData        : in  std_logic_vector(9 downto 0);
      SData        : out std_logic);
  end component;
  component TmdsClkGen
  Port(
    Reset        : in  std_logic;
    SystemClk    : in  std_logic;
    PixelClk     : out std_logic;
    PixelClkx2   : out std_logic;
    PixelClkx10  : out std_logic;
    SerdesStrobe : out std_logic;
    Locked       : out std_logic);
  end component;
  component TmdsUnit
    Port(
      Reset     : in  std_logic;
      SystemClk : in  std_logic;
      PixelClk  : out std_logic;
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
  end component;
end Components;
