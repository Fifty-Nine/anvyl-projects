-- TestBench Template 

  LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;
  USE ieee.math_real.all;

  LIBRARY Tmds;
  USE Tmds.Components.ALL;

  ENTITY TmdsSerializerTestBench IS
  END TmdsSerializerTestBench;

  ARCHITECTURE behavior OF TmdsSerializerTestBench IS 
    signal Reset : std_logic := '1';
    signal PixelClk : std_logic := '0';
    signal PixelClkx2 : std_logic := '0';
    signal PixelClkx10 : std_logic := '0';
    signal SerdesStrobe : std_logic := '0';
    signal PData : std_logic_vector(9 downto 0) := (others => '0');
    signal SData : std_logic;

    signal Deserialized : std_logic_vector(9 downto 0) := (others => 'U');
  BEGIN
    uut: TmdsSerializer
    Port map(
      Reset => Reset,
      PixelClkx2 => PixelClkx2,
      PixelClkx10 => PixelClkx10,
      SerdesStrobe => SerdesStrobe,
      PData => PData,
      SData => SData
    );

    pclkx10_process: process
    begin
      PixelClkx10 <= '1';
      wait for 2 ns;
      PixelClkx10 <= '0';
      wait for 2 ns;
    end process pclkx10_process;

    pclkx2_process: process
    begin
      PixelClkx2 <= '1';
      wait for 8 ns;
      SerdesStrobe <= '1';
      wait for 2 ns;
      PixelClkx2 <= '0';
      wait for 2 ns;
      SerdesStrobe <= '0';
      wait for 8 ns;
    end process pclkx2_process;

    pclk_process: process
    begin
      PixelClk <= '1';
      wait for 20 ns;
      PixelClk <= '0';
      wait for 20 ns;
    end process pclk_process;

    stimulus: process
      variable x : real;
      variable xi : natural;
      variable seed1 : positive := 16#dead#;
      variable seed2 : positive := 16#beef#;
    begin
      wait for 100 ns;
      Reset <= '0';

      while true loop
        wait until rising_edge(PixelClk);
        uniform(seed1, seed2, x);
        PData <= std_logic_vector(to_unsigned(natural(1024.0 * x), 10));
      end loop;

    end process stimulus;

    deser: process
    begin
      wait until rising_edge(PixelClkx10);
      Deserialized <= SData & Deserialized(9 downto 1);
    end process;
  END;
