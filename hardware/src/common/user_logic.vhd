---------------------------------- VHDL Code ----------------------------------
-- File         = user_logic.vhd
-- 
-- Purpose      = Logic which retains the user logic
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity user_logic is
  port 
    (
    clk                      : in  std_logic;
    input                    : in  std_logic;
    output                   : out std_logic
    );
end user_logic;



architecture rtl of user_logic is


begin


user_logic_p:
  process(clk)
    begin
      if clk'event and clk = '1' then
        output     <= input;
      end if;
    end process user_logic_p;


end;
