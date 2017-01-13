library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.vcomponents.all;

entity TopLevel is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           TAP : out  STD_LOGIC_VECTOR (15 downto 0);
           --UART_TX : out  STD_LOGIC;
           --UART_RX : in  STD_LOGIC;
           VGA_BLUE : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_GREEN : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_RED : out STD_LOGIC_VECTOR(3 downto 0);
           VGA_VSYNC : out STD_LOGIC;
           VGA_HSYNC : out STD_LOGIC;
           HDMI_TX_P : out  STD_LOGIC_VECTOR (2 downto 0);
           HDMI_TX_N : out  STD_LOGIC_VECTOR (2 downto 0);
           HDMI_TX_P_CLK : out  STD_LOGIC;
           HDMI_TX_N_CLK : out  STD_LOGIC);
           --HDMI_CEC : inout  STD_LOGIC;
           --I2C_SDA : inout  STD_LOGIC;
           --I2C_SCL : inout  STD_LOGIC);
end TopLevel;

architecture Behavioral of TopLevel is
  component VideoClkGen is
  Port(
    Reset        : in  std_logic;
    SystemClk    : in  std_logic;
    PixelClk     : out std_logic;
    PixelClkx2   : out std_logic;
    PixelClkx10  : out std_logic;
    PixelClkx10_BUFPLL : out std_logic;
    SerdesStrobe : out std_logic;
    Locked       : out std_logic
  );
  end component;

  component TmdsEncoder is
  Port(
    Clk        : in  std_logic;
    Reset      : in  std_logic;
    Data       : in  std_logic_vector(7 downto 0);
    Control    : in  std_logic_vector(1 downto 0);
    DataEnable : in  std_logic;
    TmdsData   : out std_logic_vector(9 downto 0)
  );
  end component;

  component TmdsSerializer is
  Port(
    Reset   : in  std_logic;
    PClkx2  : in  std_logic;
    PClkx10 : in  std_logic;
    PData   : in  std_logic_vector(9 downto 0);
    Sync    : out std_logic;
    SData   : out std_logic);
  end component;

  constant hVisible : natural := 640;
  constant hFrontPorch : natural := 16;
  constant hSyncWidth : natural := 96;
  constant hBackPorch : natural := 48;
  constant hTotal : natural := hVisible + hFrontPorch + hSyncWidth + hBackPorch;
  constant vVisible : natural := 480;
  constant vFrontPorch : natural := 11;
  constant vSyncWidth : natural := 2;
  constant vBackPorch : natural := 31;
  constant vTotal : natural := vVisible + vFrontPorch + vSyncWidth + vBackPorch;

  signal PClk : std_logic;
  signal PClkN : std_logic;
  signal PClkOut : std_logic;
  signal PClkx10 : std_logic;
  signal PClkx2 : std_logic;

  signal locX : natural range 0 to hTotal - 1;
  signal locY : natural range 0 to vTotal - 1;

  signal sync : std_logic_vector(1 downto 0);
  signal ctl : std_logic_vector(3 downto 0);

  signal active : std_logic;
  
  signal red : std_logic_vector(7 downto 0);
  signal green : std_logic_vector(7 downto 0);
  signal blue : std_logic_vector(7 downto 0);
  
  signal tmdsRed : std_logic_vector(9 downto 0);
  signal tmdsGreen : std_logic_vector(9 downto 0);
  signal tmdsBlue : std_logic_vector(9 downto 0);

  signal tmdsSerRed : std_logic;
  signal tmdsSerGreen : std_logic;
  signal tmdsSerBlue : std_logic;

  signal UnbufTap : std_logic_vector(15 downto 0);

  -- High if reset triggered or the PLL hasn't locked.
  signal internalReset : std_logic;
  signal pllLocked : std_logic;
begin
  VGA_BLUE <= blue(7 downto 4);
  VGA_GREEN <= green(7 downto 4);
  VGA_RED <= red(7 downto 4);
  VGA_HSYNC <= not sync(0);
  VGA_VSYNC <= not sync(1);

  ctl <= "0000";
  internalReset <= RST or not pllLocked;

  TAP <= UnbufTap;
  UnbufTap(15 downto 5) <= (others => '0');
  UnbufTap(4) <= pllLocked;

  UnbufTap(0) <= sync(0);
  UnbufTap(1) <= sync(1);

  PClkTapBuf: ODDR2
  Generic map(
    DDR_ALIGNMENT => "NONE",
    INIT => '0',
    SRTYPE => "ASYNC"
  )
  Port map(
    Q => UnbufTap(2),
    D0 => '1',
    D1 => '0',
    C0 => PClk,
    C1 => not PClk,
    CE => '1',
    R => RST,
    S => '0'
  );
  
  PClkx2TapBuf: ODDR2
  Generic map(
    DDR_ALIGNMENT => "NONE",
    INIT => '0',
    SRTYPE => "ASYNC"
  )
  Port map(
    Q => UnbufTap(3),
    D0 => '1',
    D1 => '0',
    C0 => PClkx2,
    C1 => not PClkx2,
    CE => '1',
    R => RST,
    S => '0'
  );

  count_gen: process (PClk, internalReset, locX, locY)
    variable count_vec_x : std_logic_vector(9 downto 0);
    variable count_vec_y : std_logic_vector(9 downto 0);

    variable red_calc : std_logic_vector(5 downto 0);
  begin
    if internalReset = '1' then
      locX <= 0;
      locY <= 0;
    elsif rising_edge(PClk) then
      locX <= (locX + 1) mod hTotal;

      if locX = 0 then
        locY <= (locY + 1) mod vTotal;
      end if;
    end if;
  
    if locX < hVisible and locY < vVisible then
      active <= '1';
    else
      active <= '0';
    end if;

    if locX >= (hVisible + hFrontPorch) and locX < (hTotal - hBackPorch) then
      sync(0) <= '1';
    else
      sync(0) <= '0';
    end if;

    if locY >= (vVisible + vFrontPorch) and locY < (vTotal - vBackPorch) then
      sync(1) <= '1';
    else
      sync(1) <= '0';
    end if;

    count_vec_x := std_logic_vector(to_unsigned(locX, 10));
    count_vec_y := std_logic_vector(to_unsigned(locY, 10));

    if count_vec_y(4 downto 3) = not count_vec_x(4 downto 3) then
      red_calc := (others => '1');
    else
      red_calc := (others => '0');
    end if;

    red <= (red_calc and count_vec_x(5 downto 0)) & "00";
    green <= count_vec_x(7 downto 0) and (7 downto 0 => count_vec_y(6));
    blue <= count_vec_y(7 downto 0);
  end process;

  PLL: VideoClkGen
  Port map(
    Reset => RST,
    SystemClk => CLK,
    PixelClk => PClk,
    PixelClkx2 => PClkx2,
    PixelClkx10 => PClkx10,
    PixelClkx10_BUFPLL => open,
    SerdesStrobe => open,
    Locked => pllLocked
  );

  TmdsEncBlue: TmdsEncoder
  Port map(
    Clk => PClk,
    Reset => internalReset,
    Data => blue,
    Control => sync,
    DataEnable => active,
    TmdsData => tmdsBlue
  );
  
  TmdsEncGreen: TmdsEncoder
  Port map(
    Clk => PClk,
    Reset => internalReset,
    Data => green,
    Control => ctl(1 downto 0),
    DataEnable => active,
    TmdsData => tmdsGreen
  );
  
  TmdsEncRed: TmdsEncoder
  Port map(
    Clk => PClk,
    Reset => internalReset,
    Data => red,
    Control => ctl(3 downto 2),
    DataEnable => active,
    TmdsData => tmdsRed
  );

  TmdsSerializerBlue: TmdsSerializer
  Port map(
    Reset => internalReset,
    PClkx2 => PClkx2,
    PClkx10 => PClkx10,
    PData => tmdsBlue,
    Sync => open,
    SData => tmdsSerBlue
  );
  TmdsSerializerGreen: TmdsSerializer
  Port map(
    Reset => internalReset,
    PClkx2 => PClkx2,
    PClkx10 => PClkx10,
    PData => tmdsGreen,
    Sync => open,
    SData => tmdsSerGreen
  );
  TmdsSerializerRed: TmdsSerializer
  Port map(
    Reset => internalReset,
    PClkx2 => PClkx2,
    PClkx10 => PClkx10,
    PData => tmdsRed,
    Sync => open,
    SData => tmdsSerRed
  );

  TmdsBufBlue: OBUFDS
  Generic map(IOSTANDARD => "TMDS_33")
  Port map(
    O => HDMI_TX_P(0),
    OB => HDMI_TX_N(0),
    I => tmdsSerBlue
  );
  
  TmdsBufGreen: OBUFDS
  Generic map(IOSTANDARD => "TMDS_33")
  Port map(
    O => HDMI_TX_P(1),
    OB => HDMI_TX_N(1),
    I => tmdsSerGreen
  );
  
  TmdsBufRed: OBUFDS
  Generic map(IOSTANDARD => "TMDS_33")
  Port map(
    O => HDMI_TX_P(2),
    OB => HDMI_TX_N(2),
    I => tmdsSerRed
  );

  -- Apparently, driving off-pin IO using a global buffer leads to long delays.
  -- Instantiating an ODDR2 instance to drive the output works around this
  -- limitation.
  PClkN <= not PClk;
  S6EWorkaroundFF: ODDR2
  Generic map(
    DDR_ALIGNMENT => "NONE",
    INIT => '0',
    SRTYPE => "ASYNC"
  )
  Port map(
    Q => PClkOut,
    D0 => '1',
    D1 => '0',
    C0 => PClk,
    C1 => PClkN,
    CE => '1',
    R => RST,
    S => '0'
  );

  TmdsBufClk: OBUFDS
  Generic map(IOSTANDARD => "TMDS_33")
  Port map(
    O => HDMI_TX_P_CLK,
    OB => HDMI_TX_N_CLK,
    I => PClkOut
  );
end Behavioral;

