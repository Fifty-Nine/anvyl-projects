library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Utils is 
  function countBits(data: std_logic_vector; value: std_logic)
    return natural;

  function calcQ_m(data: std_logic_vector)
    return std_logic_vector;

  function tmdsDecode(data: std_logic_vector; dataEnable: std_logic)
    return std_logic_vector;
end package;

package body Utils is 
  function countBits(data: std_logic_vector; value: std_logic)
    return natural is
    variable count : natural := 0;
  begin
    for i in data'range loop
      if data(i) = value then
        count := count + 1;
      end if;
    end loop;
    return count;
  end countBits;

  function calcQ_m(data: std_logic_vector)
    return std_logic_vector is
    variable result : std_logic_vector(8 downto 0);

    variable numOnes : natural := countBits(data, '1');
  begin
    result(0) := data(0);

    if numOnes > 4 or (numOnes = 4 and data(0) = '1') then
      result(8) := '1';
    else
      result(8) := '0';
    end if;

    for i in 1 to 7 loop
      if result(8) = '1' then
        result(i) := result(i - 1) xor data(i);
      else
        result(i) := result(i - 1) xnor data(i);
      end if;
    end loop;

    return result;
  end calcQ_m;

  function tmdsDecode(data: std_logic_vector; dataEnable: std_logic)
    return std_logic_vector is
    variable result : std_logic_vector(9 downto 0);
    variable tmp : std_logic_vector(7 downto 0);
  begin
    result := (others => 'X');
    tmp := data(7 downto 0);
    if dataEnable = '1' then
      if data(9) = '1' then 
        tmp(7 downto 0) := not tmp(7 downto 0);
      end if;

      result(0) := tmp(0);
      if data(8) = '1' then
        result(1) := tmp(1) xor tmp(0);
        result(2) := tmp(2) xor tmp(1);
        result(3) := tmp(3) xor tmp(2);
        result(4) := tmp(4) xor tmp(3);
        result(5) := tmp(5) xor tmp(4);
        result(6) := tmp(6) xor tmp(5);
        result(7) := tmp(7) xor tmp(6);
      else
        result(1) := tmp(1) xnor tmp(0);
        result(2) := tmp(2) xnor tmp(1);
        result(3) := tmp(3) xnor tmp(2);
        result(4) := tmp(4) xnor tmp(3);
        result(5) := tmp(5) xnor tmp(4);
        result(6) := tmp(6) xnor tmp(5);
        result(7) := tmp(7) xnor tmp(6);
      end if;
      result(9 downto 8) := "00";
    else
      case data is
        when "0010101011" => result := "00XXXXXXXX";
        when "1101010100" => result := "01XXXXXXXX";
        when "0010101010" => result := "10XXXXXXXX";
        when "1101010101" => result := "11XXXXXXXX";
        when others       => result := "XXXXXXXXXX";
      end case;
    end if;
    return result;
  end tmdsDecode;
end package body;

