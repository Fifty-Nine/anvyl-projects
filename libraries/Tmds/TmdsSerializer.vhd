library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
use UNISIM.VComponents.ALL;

entity TmdsSerializer is
  Port(
    Reset        : in  std_logic;
    PixelClkx2   : in  std_logic;
    PixelClkx10  : in  std_logic;
    SerdesStrobe : in std_logic;
    PData        : in  std_logic_vector(9 downto 0);
    SData        : out std_logic);
end TmdsSerializer;

architecture Behavioral of TmdsSerializer is
  signal serdes_data : std_logic_vector(4 downto 0);

  signal d_cascade : std_logic;
  signal d_pin_cascade : std_logic;
begin

  gearbox: process (Reset, PixelClkx2, PData)
    variable idx : natural range 0 to 1;
  begin
    if Reset = '1' then
      idx := 0;
      serdes_data <= (others => '0');
    elsif rising_edge(PixelClkx2) then
      serdes_data <= PData(idx * 5 + 4 downto idx * 5);
      idx := (idx + 1) mod 2;
    end if;
  end process;

  SerdesMaster: OSERDES2
  Generic map(
    DATA_RATE_OQ => "SDR",
    DATA_RATE_OT => "SDR",
    DATA_WIDTH => 5,
    SERDES_MODE => "MASTER"
  )
  Port map(
    CLK0 => PixelClkx10,
    CLK1 => '0',
    CLKDIV => PixelClkx2,
    IOCE => SerdesStrobe,
    D4 => '0',
    D3 => '0',
    D2 => '0',
    D1 => serdes_data(4),
    OCE => '1',
    RST => Reset,
    T4 => '1',
    T3 => '1',
    T2 => '1',
    T1 => '1',
    TCE => '1',
    SHIFTIN1 => '1',
    SHIFTIN2 => '1',
    SHIFTIN3 => d_pin_cascade,
    SHIFTIN4 => '1',
    TRAIN => '0',
    OQ => SData,
    TQ => open,
    SHIFTOUT1 => d_cascade,
    SHIFTOUT2 => open,
    SHIFTOUT3 => open,
    SHIFTOUT4 => open
  );
  SerdesSlave: OSERDES2
  Generic map(
    DATA_RATE_OQ => "SDR",
    DATA_RATE_OT => "SDR",
    DATA_WIDTH => 5,
    SERDES_MODE => "SLAVE"
  )
  Port map(
    CLK0 => PixelClkx10,
    CLK1 => '0',
    CLKDIV => PixelClkx2,
    IOCE => SerdesStrobe,
    D4 => serdes_data(3),
    D3 => serdes_data(2),
    D2 => serdes_data(1),
    D1 => serdes_data(0),
    OCE => '1',
    RST => Reset,
    T4 => '1',
    T3 => '1',
    T2 => '1',
    T1 => '1',
    TCE => '1',
    SHIFTIN1 => d_cascade,
    SHIFTIN2 => '1',
    SHIFTIN3 => '1',
    SHIFTIN4 => '1',
    TRAIN => '0',
    OQ => open,
    TQ => open,
    SHIFTOUT1 => open,
    SHIFTOUT2 => open,
    SHIFTOUT3 => d_pin_cascade,
    SHIFTOUT4 => open
  );

end Behavioral;

