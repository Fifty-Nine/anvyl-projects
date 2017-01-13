library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use WORK.TmdsUtils.ALL;

entity TmdsEncoder is
  Port(
    Clk        : in  std_logic;
    Reset      : in  std_logic;
    Data       : in  std_logic_vector (7 downto 0);
    Control    : in  std_logic_vector (1 downto 0);
    DataEnable : in  std_logic;
    TmdsData   : out  std_logic_vector (9 downto 0));
end TmdsEncoder;

architecture Behavioral of TmdsEncoder is
  signal q_out : std_logic_vector(9 downto 0) := (others => '0');
begin
  TmdsData <= q_out;

  process (Clk, Reset, Data, Control, DataEnable)
    variable cnt : integer := 0;
    variable q_m : std_logic_vector(8 downto 0);

    variable numOnes : natural;
    variable numZeros : natural;
    variable diff : integer;
    variable qm8x2 : natural;
  begin
    if Reset = '1' then
      cnt := 0;
      q_out <= (others => '0');
    elsif rising_edge(Clk) then
      if DataEnable = '1' then
        q_m := calcQ_m(Data);
        numOnes := countBits(q_m(7 downto 0), '1');
        numZeros := countBits(q_m(7 downto 0), '0');
        diff := numOnes - numZeros;
        
        qm8x2 := 0;
        if q_m(8) = '1' then
          qm8x2 := 2;
        end if;
        q_out(8) <= q_m(8);

        if cnt = 0 or numOnes = numZeros then
          q_out(9) <= not q_m(8);
          if q_m(8) = '1' then
            q_out(7 downto 0) <= q_m(7 downto 0);
            cnt := cnt - diff;
          else
            q_out(7 downto 0) <= not q_m(7 downto 0);
            cnt := cnt + diff;
          end if;
        else
          if (cnt > 0 and diff > 0) or (cnt < 0 and diff < 0) then
            q_out(9) <= '1';
            q_out(7 downto 0) <= not q_m(7 downto 0);
            cnt := cnt + qm8x2 - diff;
          else
            q_out(9) <= '0';
            q_out(7 downto 0) <= q_m(7 downto 0);
            cnt := cnt - qm8x2 + diff;
          end if; 
        end if;
      else
        cnt := 0;
        case Control is
          when   "01" => q_out <= "1101010100";
          when   "10" => q_out <= "0010101010";
          when   "11" => q_out <= "1101010101";
          when others => q_out <= "0010101011";
        end case;
      end if;
    end if;
  end process;

end Behavioral;

