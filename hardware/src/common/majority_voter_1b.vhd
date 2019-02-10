---------------------------------- VHDL Code ----------------------------------
-- File         = majority_voter_1b.vhd
-- 
-- Purpose      = Majority Voter 3 Inputs 1 Output
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;


entity majority_voter_1b is
  port 
    (
    input1         : in  std_logic;
    input2         : in  std_logic;
    input3         : in  std_logic;      
    output         : out std_logic
    );
end majority_voter_1b;

architecture behavioral of majority_voter_1b is

begin

output <= '1' when (input1 = '1' and input2 = '1') or
                   (input1 = '1' and input3 = '1') or
                   (input2 = '1' and input3 = '1')
              else '0';

end behavioral;

