library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library Tmds;
use Tmds.Components.TmdsUnit;

library Utility;
use Utility.Bool.all;

entity TopLevel is
  Port(
    CLK           : in  std_logic;
    RST           : in  std_logic;
    HDMI_TX_P     : out std_logic_vector(2 downto 0);
    HDMI_TX_N     : out std_logic_vector(2 downto 0);
    HDMI_TX_P_CLK : out std_logic;
    HDMI_TX_N_CLK : out std_logic;
    VGA_BLUE      : out std_logic_vector(3 downto 0);
    VGA_GREEN     : out std_logic_vector(3 downto 0);
    VGA_RED       : out std_logic_vector(3 downto 0);
    VGA_VSYNC     : out std_logic;
    VGA_HSYNC     : out std_logic;
    TAP           : out std_logic_vector(15 downto 0));
end TopLevel;

architecture Behavioral of TopLevel is
  signal pixelClk : std_logic;

  signal hSync    : std_logic;
  signal vSync    : std_logic;
  signal blanking : std_logic;
  signal red      : std_logic_vector(7 downto 0);
  signal green    : std_logic_vector(7 downto 0);
  signal blue     : std_logic_vector(7 downto 0);
begin
  VGA_BLUE <= blue(7 downto 4);
  VGA_GREEN <= green(7 downto 4);
  VGA_RED <= red(7 downto 4);
  VGA_HSYNC <= hSync;
  VGA_VSYNC <= vSync;

  TAP <= (0 => vSync, 1 => hSync, others => '0');

  Driver: TmdsUnit
  Port map(
    Reset => RST,
    SystemClk => CLK,
    PixelClk => pixelClk,
    HSync => hSync,
    VSync => vSync,
    Red => red,
    Green => green,
    Blue => blue,
    Blanking => blanking,
    TmdsDataP => HDMI_TX_P,
    TmdsDataN => HDMI_TX_N,
    TmdsClkP => HDMI_TX_P_CLK,
    TmdsClkN => HDMI_TX_N_CLK
  );

  timing: process (pixelClk, RST)
    constant hVisible : natural := 640;
    constant hFrontPorch : natural := 16;
    constant hSyncTime : natural := 96;
    constant hBackPorch : natural := 48;
    constant hBlankTime : natural := hFrontPorch + hSyncTime + hBackPorch;
    constant hTotal : natural := hBlankTime + hVisible;
    constant vVisible : natural := 480;
    constant vFrontPorch : natural := 10;
    constant vSyncTime : natural := 2;
    constant vBackPorch : natural := 33;
    constant vBlankTime : natural := vFrontPorch + vSyncTime + vBackPorch;
    constant vTotal : natural := vBlankTime + vVisible;

    variable hPos : natural range 0 to hTotal;
    variable vPos : natural range 0 to vTotal;
    variable hPosBits : std_logic_vector(9 downto 0);
    variable vPosBits : std_logic_vector(9 downto 0);
  begin
    if RST = '1' then
      hPos := 0;
      vPos := 0;
      hPosBits := (others => '0');
      vPosBits := (others => '0');
      red <= (others => '0');
      green <= (others => '0');
      blue <= (others => '0');
    elsif rising_edge(pixelClk) then
      hPos := hPos + 1;
      if hPos = hTotal then
        hPos := 0;
        vPos := vPos + 1;
        if vPos = vTotal then
          vPos := 0;
        end if;
      end if;
      
      hSync <= boolToLogic(
        hPos >= hFrontPorch and hPos < (hFrontPorch + hSyncTime)
      );

      vSync <= boolToLogic(
        vPos >= vFrontPorch and vpos < (vFrontPorch + vSyncTime)
      );

      blanking <= boolToLogic(hPos < hBlankTime or vPos < vBlankTime);

      hPosBits := std_logic_vector(to_unsigned(hPos, 10));
      vPosBits := std_logic_vector(to_unsigned(vPos, 10));

      red <=
        (
          (5 downto 0 => boolToLogic(vPosBits(4 downto 3) = not hPosBits(4 downto 3))) and
          hPosBits(5 downto 0)
        ) & "00";
      green <= hPosBits(7 downto 0) and (7 downto 0 => vPosBits(6));
      blue <= vPosBits(7 downto 0);
    end if;
  end process;


end Behavioral;
