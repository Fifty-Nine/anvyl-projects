library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.all;

library Tmds;
use Tmds.Components.all;

entity TmdsUnit is
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
end TmdsUnit;

architecture Behavioral of TmdsUnit is
  signal ctrlBlue : std_logic_vector(1 downto 0);
  signal dataEnable : std_logic;

  signal tmdsBlue  : std_logic_vector(9 downto 0);
  signal tmdsGreen : std_logic_vector(9 downto 0);
  signal tmdsRed   : std_logic_vector(9 downto 0);
  signal tmdsData  : std_logic_vector(2 downto 0);

  signal pixelClkOut  : std_logic;
  signal pixelClkOutN : std_logic;
  signal pixelClkDDR  : std_logic;
  signal pixelClkx2   : std_logic;
  signal pixelClkx10  : std_logic;
  signal serdesStrobe : std_logic;
begin
  ctrlBlue <= (1 => HSync, 0 => VSync);
  dataEnable <= not Blanking;
  PixelClk <= pixelClkOut;

  TmdsEncBlue: TmdsEncoder
  Port map(
    Clk => pixelClkOut,
    Reset => Reset,
    Data => Blue,
    Control => ctrlBlue,
    dataEnable => dataEnable,
    TmdsData => tmdsBlue
  );
  TmdsEncGreen: TmdsEncoder
  Port map(
    Clk => pixelClkOut,
    Reset => Reset,
    Data => Green,
    Control => "00",
    dataEnable => dataEnable,
    TmdsData => tmdsGreen
  );
  TmdsEncRed: TmdsEncoder
  Port map(
    Clk => pixelClkOut,
    Reset => Reset,
    Data => Red,
    Control => "00",
    dataEnable => dataEnable,
    TmdsData => tmdsRed
  );

  ClkGen: TmdsClkGen
  Port map(
    Reset => Reset,
    SystemClk => SystemClk,
    PixelClk => pixelClkOut,
    PixelClkx2 => pixelClkx2,
    PixelClkx10 => pixelClkx10,
    SerdesStrobe => serdesStrobe,
    Locked => open
  );

  TmdsSerBlue: TmdsSerializer
  Port map(
    Reset => Reset,
    PixelClkx2 => pixelClkx2,
    PixelClkx10 => pixelClkx10,
    SerdesStrobe => serdesStrobe,
    PData => tmdsBlue,
    SData => tmdsData(0)
  );
  TmdsSerGreen: TmdsSerializer
  Port map(
    Reset => Reset,
    PixelClkx2 => pixelClkx2,
    PixelClkx10 => pixelClkx10,
    SerdesStrobe => serdesStrobe,
    PData => tmdsGreen,
    SData => tmdsData(1)
  );
  TmdsSerRed: TmdsSerializer
  Port map(
    Reset => Reset,
    PixelClkx2 => pixelClkx2,
    PixelClkx10 => pixelClkx10,
    SerdesStrobe => serdesStrobe,
    PData => tmdsRed,
    SData => tmdsData(2)
  );

  OutputBuffers:
  for i in 2 downto 0 generate
    Buf: OBUFDS
    Generic map(
      IOSTANDARD => "TMDS_33"
    )
    Port map(
      I => tmdsData(i),
      O => TmdsDataP(i),
      OB => TmdsDataN(i)
    );
  end generate OutputBuffers;

  pixelClkOutN <= not pixelClkOut;
  ClkOutWorkaround: ODDR2
  Generic map(
    SRTYPE => "ASYNC"
  )
  Port map(
    C0 => pixelClkOut,
    C1 => pixelClkOutN,
    CE => '1',
    D0 => '1',
    D1 => '0',
    R => Reset,
    S => '0',
    Q => pixelClkDDR
  );

  ClkOutBuf: OBUFDS
  Generic map(
    IOSTANDARD => "TMDS_33"
  )
  Port map(
    I => pixelClkDDR,
    O => TmdsClkP,
    OB => TmdsClkN
  );

end Behavioral;

