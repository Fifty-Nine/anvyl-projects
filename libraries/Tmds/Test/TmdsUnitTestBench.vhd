LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

LIBRARY Tmds;
USE Tmds.Components.TmdsUnit;
USE Tmds.Utils.tmdsDecode;

ENTITY TmdsUnitTestBench IS
END TmdsUnitTestBench;

ARCHITECTURE behavior OF TmdsUnitTestBench IS 
  signal Reset : std_logic := '0';
  signal SystemClk : std_logic := '0';
  signal PixelClk : std_logic := '0';
  signal HSync : std_logic := '0';
  signal VSync : std_logic := '0';
  signal Red : std_logic_vector(7 downto 0) := X"AA";
  signal Green : std_logic_vector(7 downto 0) := X"55";
  signal Blue : std_logic_vector(7 downto 0) := X"00";
  signal Blanking : std_logic := '0';
  signal TmdsDataP : std_logic_vector(2 downto 0) := "000";
  signal TmdsDataN : std_logic_vector(2 downto 0) := "000";
  signal TmdsClkP : std_logic := '0';
  signal TmdsClkN : std_logic := '0';
    
  signal TmdsShiftBlue : std_logic_vector(9 downto 0);
  signal TmdsShiftGreen : std_logic_vector(9 downto 0);
  signal TmdsShiftRed : std_logic_vector(9 downto 0);

  signal BlueDec : std_logic_vector(7 downto 0);
  signal GreenDec : std_logic_vector(7 downto 0);
  signal RedDec : std_logic_vector(7 downto 0);
  signal CtrlDec : std_logic_vector(3 downto 0);
  signal DecHSync : std_logic;
  signal DecVSync : std_logic;
  signal DecStrobe : std_logic;
BEGIN

  uut: TmdsUnit
  Port map(
    Reset => Reset,
    SystemClk => SystemClk,
    PixelClk => PixelClk,
    HSync => HSync,
    VSync => VSync,
    Red => Red,
    Green => Green,
    Blue => Blue,
    Blanking => Blanking,
    TmdsDataP => TmdsDataP,
    TmdsDataN => TmdsDataN,
    TmdsClkP => TmdsClkP,
    TmdsClkN => TmdsClkN
  );

  clk_process:
  process
  begin
    SystemClk <= not SystemClk;
    wait for 5 ns;
  end process;

  video_process:
  process
    constant width : natural := 800;
    constant height : natural := 525;
    variable locX : natural range 0 to width - 1;
    variable locY : natural range 0 to height - 1;
  begin
    wait until reset = '0' and rising_edge(PixelClk);
    locX := (locX + 1) mod width;
    if locX = 0 then
      locY := (locY + 1) mod height;
    end if;

    if locX > 16 and locX <= 112 then
      HSync <= '1';
    else
      HSync <= '0';
    end if;

    if locY > 10 and locY <= 12 then
      VSync <= '1';
    else
      VSync <= '0';
    end if;

    if locX > 160 and locY > 45 then
      Blanking <= '0';
    else
      Blanking <= '1';
    end if;
  end process;

  deser: process
  begin
    TmdsShiftBlue <= TmdsDataP(0) & TmdsShiftBlue(9 downto 1);
    TmdsShiftGreen <= TmdsDataP(1) & TmdsShiftGreen(9 downto 1);
    TmdsShiftRed <= TmdsDataP(2) & TmdsShiftRed(9 downto 1);

    wait for 4 ns;
  end process;

  decode_sync: process
    variable TmdsDecodeBlue : std_logic_vector(9 downto 0);
    variable TmdsDecodeGreen : std_logic_vector(9 downto 0);
    variable TmdsDecodeRed : std_logic_vector(9 downto 0);
  begin
    wait until 
      TmdsShiftBlue = "0010101011" and 
      TmdsShiftGreen = "0010101011" and
      TmdsShiftRed = "0010101011";
    wait for 2 ns;

    while true loop
      TmdsDecodeBlue := tmdsDecode(TmdsShiftBlue, not Blanking);
      TmdsDecodeGreen := tmdsDecode(TmdsShiftGreen, not Blanking);
      TmdsDecodeRed := tmdsDecode(TmdsShiftRed, not Blanking);

      BlueDec <= TmdsDecodeBlue(7 downto 0);
      GreenDec <= TmdsDecodeGreen(7 downto 0); 
      RedDec <= TmdsDecodeRed(7 downto 0);
      DecHSync <= TmdsDecodeBlue(9);
      DecVSync <= TmdsDecodeBlue(8);
      CtrlDec <= TmdsDecodeRed(9 downto 8) & TmdsDecodeGreen(9 downto 8);

      DecStrobe <= '1';
      wait for 4 ns;
      DecStrobe <= '0';
      wait for 36 ns;
    end loop;
      
  end process;
END;
