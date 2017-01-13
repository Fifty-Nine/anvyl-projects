library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package Bool is
  function logicToBool(value: std_logic) return boolean;
  function boolToLogic(value: boolean) return std_logic;
end package;

package body Bool is
  function logicToBool(value: std_logic) return boolean is
  begin
    if value = '1' then
      return true;
    end if;
    return false;
  end logicToBool;

  function boolToLogic(value: boolean) return std_logic is
  begin
    if value then
      return '1';
    end if;
    return '0';
  end boolToLogic;
end package body;
