library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity TmdsClkGen is
  Port(
    Reset        : in  std_logic;
    SystemClk    : in  std_logic;
    PixelClk     : out std_logic;
    PixelClkx2   : out std_logic;
    PixelClkx10  : out std_logic;
    SerdesStrobe : out std_logic;
    Locked       : out std_logic);
end TmdsClkGen;

architecture Behavioral of TmdsClkGen is
  signal pllOutx1 : std_logic;
  signal pllOutx2 : std_logic;
  signal pllOutx10 : std_logic;

  signal bufClkx2 : std_logic;

  signal feedback : std_logic;
  signal pllLocked : std_logic;
  signal bufLocked : std_logic;
begin
  Locked <= pllLocked and bufLocked;
  PixelClkx2 <= bufClkx2;

  PLLClkGen: PLL_BASE
  Generic map(
    CLKFBOUT_MULT => 10,
    CLKIN_PERIOD => 10.000,
    CLKOUT0_DIVIDE => 4,
    CLKOUT1_DIVIDE => 20,
    CLKOUT2_DIVIDE => 40)
  Port map(
    CLKFBOUT => feedback,
    CLKOUT0 => pllOutx10,
    CLKOUT1 => pllOutx2,
    CLKOUT2 => pllOutx1,
    CLKOUT3 => open,
    CLKOUT4 => open,
    CLKOUT5 => open,
    LOCKED => pllLocked,
    CLKFBIN => feedback,
    CLKIN => SystemClk,
    RST => Reset
  );

  Clkx1Buffer: BUFG
  Port map(
    I => pllOutx1,
    O => PixelClk
  );
  
  Clkx2Buffer: BUFG
  Port map(
    I => pllOutx2,
    O => bufClkx2
  );
  
  
  PllBuffer: BUFPLL
  Generic map(
    DIVIDE => 5 -- OSERDES2 can serialize 5 bits at a time
  )
  Port map(
    GCLK => bufClkx2,
    LOCKED => pllLocked,
    PLLIN => pllOutx10,
    IOCLK => PixelClkx10,
    LOCK => bufLocked,
    SERDESSTROBE => SerdesStrobe
  );
end Behavioral;

