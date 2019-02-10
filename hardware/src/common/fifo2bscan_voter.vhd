---------------------------------- VHDL Code ----------------------------------
-- File         = fifo2bscan_voter.vhd
-- 
-- Purpose      = FIFO Outputs to BSCAN Inputs Voters
-- 
-- Library      = work
-- 
-- Dependencies = none
-- 
-- Author       = University of Piraeus
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity fifo2bscan_voter is
  port 
    (
    bscan_tdo_a_in           : in  std_logic_vector(2 downto 0);
    bscan_tdo_a_out          : out std_logic;
    bscan_tdo_b_in           : in  std_logic_vector(2 downto 0);
    bscan_tdo_b_out          : out std_logic
    );
end fifo2bscan_voter;

architecture behavioral of fifo2bscan_voter is

component majority_voter_1b is
  port 
    (
    input1         : in  std_logic;
    input2         : in  std_logic;
    input3         : in  std_logic;      
    output         : out std_logic
    );
end component;

begin

bscan_tdo_a_voter: majority_voter_1b
  port map
    (
    input1         => bscan_tdo_a_in(0),
    input2         => bscan_tdo_a_in(1),      
    input3         => bscan_tdo_a_in(2),
    output         => bscan_tdo_a_out
    );

bscan_tdo_b_voter: majority_voter_1b
  port map
    (
    input1         => bscan_tdo_b_in(0),
    input2         => bscan_tdo_b_in(1),      
    input3         => bscan_tdo_b_in(2),
    output         => bscan_tdo_b_out
    );

end behavioral;

